import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/api/api_exception.dart';
import '../../core/di/providers.dart';
import '../../core/models/staff_models.dart';
import 'timing_groups_models.dart';
import 'timing_groups_store.dart';

final timingGroupsStoreProvider = Provider<TimingGroupsStore>((ref) {
  return TimingGroupsStore(ref.watch(sharedPreferencesProvider));
});

class TimingScreen extends ConsumerStatefulWidget {
  const TimingScreen({super.key});

  @override
  ConsumerState<TimingScreen> createState() => _TimingScreenState();
}

class _TimingScreenState extends ConsumerState<TimingScreen> {
  final _query = TextEditingController();
  List<VenueTicket> _tickets = const [];
  TimingGroupsState _state = TimingGroupsState.empty();
  bool _loading = false;
  bool _scanning = false;
  String _scanSlot = 'current';
  String? _loadedEventId;
  Timer? _tick;
  int _nowMs = DateTime.now().millisecondsSinceEpoch;

  @override
  void dispose() {
    _tick?.cancel();
    _query.dispose();
    super.dispose();
  }

  String? get _eventId =>
      ref.read(sessionControllerProvider).selectedEvent?.eventId;

  void _ensureHydrated(String? eventId) {
    if (eventId == null || eventId == _loadedEventId) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || eventId == _loadedEventId) return;
      setState(() {
        _loadedEventId = eventId;
        _state = ref.read(timingGroupsStoreProvider).load(eventId);
      });
      _syncTick();
    });
  }

  Future<void> _persist() async {
    final eventId = _eventId;
    if (eventId == null) return;
    await ref.read(timingGroupsStoreProvider).save(eventId, _state);
    _syncTick();
  }

  void _syncTick() {
    final running = _state.current?.members.any(
          (m) => m.status == MemberStatus.running,
        ) ??
        false;
    if (running && _tick == null) {
      _tick = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (!mounted) return;
        setState(() => _nowMs = DateTime.now().millisecondsSinceEpoch);
      });
    } else if (!running && _tick != null) {
      _tick?.cancel();
      _tick = null;
    }
  }

  Future<void> _search() async {
    final eventId = _eventId;
    if (eventId == null || _query.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final tickets = await ref
          .read(dioFactoryProvider)
          .api
          .searchTickets(eventId, _query.text.trim());
      setState(() {
        _tickets = tickets.where((t) => t.isChallenge).toList();
      });
      if (_tickets.isEmpty && tickets.isNotEmpty) {
        _toast('No challenge tickets (laps > 0) in results');
      }
    } catch (e) {
      _toast(_err(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  TimingGroup _ensure(TimingGroup? group, String name) {
    return group ?? TimingGroup.create(name: name);
  }

  Future<void> _addTo(VenueTicket ticket, String slot) async {
    final where = _state.slotForTicket(ticket.id);
    if (where != null) {
      _toast('Already in $where group');
      return;
    }
    if (!ticket.isChallenge) {
      _toast('Challenge tickets only (laps > 0)');
      return;
    }
    final inReview = _state.current?.status == GroupStatus.review ||
        _state.current?.status == GroupStatus.saving;
    if (slot == 'current' && inReview) {
      _toast('Finish saving the current review first');
      return;
    }
    setState(() {
      if (slot == 'current') {
        final g = _ensure(_state.current, 'Current');
        g.members.add(TimingMember.fromTicket(ticket));
        if (g.status != GroupStatus.running) g.status = GroupStatus.staging;
        _state.current = g;
      } else {
        final g = _ensure(_state.next, 'Next');
        g.members.add(TimingMember.fromTicket(ticket));
        g.status = GroupStatus.staging;
        _state.next = g;
      }
    });
    await _persist();
    _toast('Added to $slot');
  }

  Future<void> _scanToSlot(String token, String slot) async {
    final eventId = _eventId;
    if (eventId == null || token.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _scanning = false;
    });
    try {
      final result = await ref
          .read(dioFactoryProvider)
          .api
          .resolveQR(eventId, token.trim());
      if (result.result != 'valid' || result.ticket == null) {
        _toast(result.message ?? result.result);
        return;
      }
      await _addTo(result.ticket!, slot);
    } catch (e) {
      _toast(_err(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(String slot, String ticketId) async {
    setState(() {
      final g = slot == 'current' ? _state.current : _state.next;
      if (g == null) return;
      TimingMember? member;
      for (final m in g.members) {
        if (m.ticketId == ticketId) {
          member = m;
          break;
        }
      }
      if (member == null || member.status != MemberStatus.queued) return;
      g.members.removeWhere((x) => x.ticketId == ticketId);
      if (g.members.isEmpty) {
        if (slot == 'current') {
          _state.current = null;
        } else {
          _state.next = null;
        }
      }
    });
    await _persist();
  }

  Future<void> _startMembers({List<String>? ticketIds}) async {
    final g = _state.current;
    if (g == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final ids = ticketIds?.toSet();
    setState(() {
      for (final m in g.members) {
        if (m.status != MemberStatus.queued) continue;
        if (ids != null && !ids.contains(m.ticketId)) continue;
        m.status = MemberStatus.running;
        m.startedAtMs = now;
      }
      g.status = GroupStatus.running;
    });
    await _persist();
  }

  Future<void> _finishMember(String ticketId) async {
    final g = _state.current;
    if (g == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      for (final m in g.members) {
        if (m.ticketId != ticketId || m.status != MemberStatus.running) continue;
        final start = m.startedAtMs;
        if (start == null) continue;
        final dur = now - start;
        m.status = MemberStatus.finished;
        m.finishedAtMs = now;
        m.durationMs = dur;
        m.editedDurationMs = dur;
      }
      if (g.allDone) g.status = GroupStatus.review;
    });
    await _persist();
  }

  Future<void> _dnfMember(String ticketId) async {
    final g = _state.current;
    if (g == null) return;
    setState(() {
      for (final m in g.members) {
        if (m.ticketId != ticketId) continue;
        if (m.status != MemberStatus.running &&
            m.status != MemberStatus.queued) {
          continue;
        }
        m.status = MemberStatus.dnf;
        m.finishedAtMs = DateTime.now().millisecondsSinceEpoch;
        m.durationMs = null;
        m.editedDurationMs = null;
      }
      if (g.allDone) g.status = GroupStatus.review;
    });
    await _persist();
  }

  Future<void> _setEditedDuration(String ticketId, String raw) async {
    final g = _state.current;
    if (g == null || g.status != GroupStatus.review) return;
    final ms = parseDurationInput(raw);
    setState(() {
      for (final m in g.members) {
        if (m.ticketId != ticketId || m.status != MemberStatus.finished) {
          continue;
        }
        m.editedDurationMs = ms ?? m.durationMs;
      }
    });
    await _persist();
  }

  Future<void> _discardCurrent() async {
    setState(() {
      _state.current = _state.next;
      _state.next = null;
    });
    await _persist();
    _toast('Discarded current group');
  }

  Future<void> _saveAll() async {
    final eventId = _eventId;
    final g = _state.current;
    final next = _state.next;
    if (eventId == null || g == null || g.status != GroupStatus.review) return;

    setState(() {
      g.status = GroupStatus.saving;
      _loading = true;
    });
    await _persist();

    final remaining = <TimingMember>[];
    final dnfMembers =
        g.members.where((m) => m.status == MemberStatus.dnf).toList();
    var saved = 0;
    var failed = 0;

    for (final m in g.members) {
      if (m.status == MemberStatus.dnf) continue;
      if (m.status != MemberStatus.finished || m.startedAtMs == null) {
        remaining.add(m);
        continue;
      }
      final duration = m.effectiveDurationMs;
      if (duration == null || duration <= 0) {
        m.saveError = 'Invalid duration';
        remaining.add(m);
        failed += 1;
        continue;
      }
      final started = DateTime.fromMillisecondsSinceEpoch(m.startedAtMs!);
      final finished = started.add(Duration(milliseconds: duration));
      try {
        await ref.read(dioFactoryProvider).api.recordTiming(
              eventId,
              m.ticketId,
              startedAt: started,
              finishedAt: finished,
              lapsTarget: m.lapsIncluded > 0 ? m.lapsIncluded : null,
            );
        saved += 1;
      } catch (e) {
        m.saveError = _err(e);
        remaining.add(m);
        failed += 1;
      }
    }

    if (!mounted) return;

    if (failed == 0) {
      setState(() {
        _state.current = next;
        _state.next = null;
        _loading = false;
      });
      await _persist();
      _toast(saved > 0 ? 'Saved $saved timing(s)' : 'Group cleared');
    } else {
      final seen = <String>{};
      final members = <TimingMember>[
        ...remaining,
        ...dnfMembers,
      ].where((m) => seen.add(m.ticketId)).toList();
      setState(() {
        g.status = GroupStatus.review;
        g.members = members;
        _loading = false;
      });
      await _persist();
      _toast('Saved $saved, $failed failed — fix and retry');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _err(Object e) {
    if (e is ApiException) return e.message;
    final err = (e as dynamic).error;
    if (err is ApiException) return err.message;
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(
      sessionControllerProvider.select((s) => s.selectedEvent),
    );
    if (event == null) {
      return const Center(child: Text('Select an event'));
    }
    if (!(event.role.canTiming)) {
      return const Center(child: Text('Timing not allowed for your role'));
    }

    _ensureHydrated(event.eventId);

    final current = _state.current;
    final next = _state.next;
    final inReview = current?.status == GroupStatus.review ||
        current?.status == GroupStatus.saving;
    final canStartAll = current != null &&
        current.status != GroupStatus.review &&
        current.status != GroupStatus.saving &&
        current.members.any((m) => m.status == MemberStatus.queued);

    if (_scanning) {
      return Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                if (capture.barcodes.isEmpty) return;
                final value = capture.barcodes.first.rawValue;
                if (value != null && value.isNotEmpty) {
                  _scanToSlot(value, _scanSlot);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () => setState(() => _scanning = false),
              child: const Text('Close scanner'),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Timing · ${event.eventTitle}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Challenge tickets only. Scan a ticket QR or search, then add to Current / Next.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _loading || inReview
                    ? null
                    : () => setState(() {
                          _scanSlot = 'current';
                          _scanning = true;
                        }),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan → Current'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () => setState(() {
                          _scanSlot = 'next';
                          _scanning = true;
                        }),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan → Next'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _query,
          decoration: InputDecoration(
            labelText: 'Lookup ticket # or phone',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _loading ? null : _search,
            ),
          ),
          onSubmitted: (_) => _search(),
        ),
        if (_loading) const LinearProgressIndicator(),
        const SizedBox(height: 12),
        ..._tickets.map((t) {
          final where = _state.slotForTicket(t.id);
          return Card(
            child: ListTile(
              title: Text(t.ticketNumber),
              subtitle: Text(
                'Laps ${t.lapsIncluded} · ${t.holderName ?? '—'}'
                '${where != null ? ' · in $where' : ''}',
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: _loading || where != null || inReview
                        ? null
                        : () => _addTo(t, 'current'),
                    child: const Text('Current'),
                  ),
                  TextButton(
                    onPressed: _loading || where != null
                        ? null
                        : () => _addTo(t, 'next'),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        _GroupCard(
          title: 'Current group',
          group: current,
          nowMs: _nowMs,
          live: true,
          stagingOnly: false,
          canStartAll: canStartAll,
          loading: _loading,
          onStartAll: () => _startMembers(),
          onStartOne: (id) => _startMembers(ticketIds: [id]),
          onFinish: _finishMember,
          onDnf: _dnfMember,
          onRemove: (id) => _remove('current', id),
          onEditDuration: _setEditedDuration,
          onSaveAll: _saveAll,
          onDiscard: _discardCurrent,
        ),
        const SizedBox(height: 12),
        _GroupCard(
          title: 'Next group',
          group: next,
          nowMs: _nowMs,
          live: false,
          stagingOnly: true,
          canStartAll: false,
          loading: _loading,
          onStartAll: () {},
          onStartOne: (_) {},
          onFinish: (_) {},
          onDnf: (_) {},
          onRemove: (id) => _remove('next', id),
          onEditDuration: (_, __) async {},
          onSaveAll: () {},
          onDiscard: () {},
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.title,
    required this.group,
    required this.nowMs,
    required this.live,
    required this.stagingOnly,
    required this.canStartAll,
    required this.loading,
    required this.onStartAll,
    required this.onStartOne,
    required this.onFinish,
    required this.onDnf,
    required this.onRemove,
    required this.onEditDuration,
    required this.onSaveAll,
    required this.onDiscard,
  });

  final String title;
  final TimingGroup? group;
  final int nowMs;
  final bool live;
  final bool stagingOnly;
  final bool canStartAll;
  final bool loading;
  final VoidCallback onStartAll;
  final void Function(String ticketId) onStartOne;
  final void Function(String ticketId) onFinish;
  final void Function(String ticketId) onDnf;
  final void Function(String ticketId) onRemove;
  final Future<void> Function(String ticketId, String raw) onEditDuration;
  final VoidCallback onSaveAll;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final inReview = group?.status == GroupStatus.review ||
        group?.status == GroupStatus.saving;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group == null ? title : '$title (${group!.status.name})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (!stagingOnly && canStartAll)
                  FilledButton(
                    onPressed: loading ? null : onStartAll,
                    child: const Text('Start all'),
                  ),
                if (!stagingOnly && inReview) ...[
                  TextButton(
                    onPressed: loading || group?.status == GroupStatus.saving
                        ? null
                        : onDiscard,
                    child: const Text('Discard'),
                  ),
                  FilledButton(
                    onPressed: loading || group?.status == GroupStatus.saving
                        ? null
                        : onSaveAll,
                    child: Text(
                      group?.status == GroupStatus.saving
                          ? 'Saving…'
                          : 'Save all',
                    ),
                  ),
                ],
              ],
            ),
            if (group == null || group!.members.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  stagingOnly
                      ? 'Stage the next wave here while Current is running.'
                      : 'No riders — search and add tickets.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ...group!.members.map((m) {
                String? elapsed;
                if (m.status == MemberStatus.running &&
                    m.startedAtMs != null &&
                    live) {
                  elapsed = formatDurationMs(nowMs - m.startedAtMs!);
                } else if (m.status == MemberStatus.finished && !inReview) {
                  elapsed = formatDurationMs(m.durationMs ?? 0);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.ticketNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${m.holderName ?? '—'} · Laps ${m.lapsIncluded}'
                                  '${elapsed != null ? ' · $elapsed' : ''}'
                                  '${m.status == MemberStatus.dnf ? ' · DNF' : ''}'
                                  '${m.saveError != null ? ' · ${m.saveError}' : ''}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 4,
                            children: [
                              if (!stagingOnly &&
                                  !inReview &&
                                  m.status == MemberStatus.queued)
                                TextButton(
                                  onPressed: () => onStartOne(m.ticketId),
                                  child: const Text('Start'),
                                ),
                              if (!stagingOnly &&
                                  !inReview &&
                                  m.status == MemberStatus.running) ...[
                                FilledButton(
                                  onPressed: () => onFinish(m.ticketId),
                                  child: const Text('Finish'),
                                ),
                                OutlinedButton(
                                  onPressed: () => onDnf(m.ticketId),
                                  child: const Text('DNF'),
                                ),
                              ],
                              if (!stagingOnly &&
                                  !inReview &&
                                  m.status == MemberStatus.queued)
                                TextButton(
                                  onPressed: () => onDnf(m.ticketId),
                                  child: const Text('DNF'),
                                ),
                              if (m.status == MemberStatus.queued)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () => onRemove(m.ticketId),
                                ),
                            ],
                          ),
                        ],
                      ),
                      if (inReview && m.status == MemberStatus.finished)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: _DurationField(
                            key: ValueKey(
                              '${m.ticketId}-${m.editedDurationMs ?? m.durationMs}',
                            ),
                            initial: formatDurationMs(
                              m.effectiveDurationMs ?? 0,
                            ),
                            onCommit: (v) => onEditDuration(m.ticketId, v),
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DurationField extends StatefulWidget {
  const _DurationField({
    super.key,
    required this.initial,
    required this.onCommit,
  });

  final String initial;
  final Future<void> Function(String) onCommit;

  @override
  State<_DurationField> createState() => _DurationFieldState();
}

class _DurationFieldState extends State<_DurationField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          isDense: true,
          labelText: 'Duration (m:ss.s)',
          border: OutlineInputBorder(),
        ),
        style: const TextStyle(fontFamily: 'monospace'),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSubmitted: widget.onCommit,
        onTapOutside: (_) => widget.onCommit(_controller.text),
      ),
    );
  }
}
