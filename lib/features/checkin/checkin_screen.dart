import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/api/api_exception.dart';
import '../../core/di/providers.dart';
import '../../core/models/staff_models.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  final _query = TextEditingController();
  final _qrManual = TextEditingController();
  List<VenueTicket> _tickets = const [];
  bool _loading = false;
  String? _lastScanMessage;
  int? _priorCheckins;
  bool _scanning = false;

  @override
  void dispose() {
    _query.dispose();
    _qrManual.dispose();
    super.dispose();
  }

  String? get _eventId =>
      ref.read(sessionControllerProvider).selectedEvent?.eventId;

  Future<void> _search() async {
    final eventId = _eventId;
    if (eventId == null || _query.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final tickets = await ref
          .read(dioFactoryProvider)
          .api
          .searchTickets(eventId, _query.text.trim());
      setState(() => _tickets = tickets);
    } catch (e) {
      _toast(_err(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _scanToken(String token) async {
    final eventId = _eventId;
    if (eventId == null || token.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _scanning = false;
    });
    try {
      final result =
          await ref.read(dioFactoryProvider).api.scan(eventId, token.trim());
      setState(() {
        _lastScanMessage = result.message ?? 'Result: ${result.result}';
        _priorCheckins = result.priorCheckinCount;
        if (result.ticket != null) {
          _tickets = [result.ticket!];
        }
      });
      _toast(_lastScanMessage!);
    } catch (e) {
      _toast(_err(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkIn(VenueTicket ticket) async {
    final eventId = _eventId;
    if (eventId == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(dioFactoryProvider).api.checkIn(eventId, ticket.id);
      _toast('Checked in ${ticket.ticketNumber}');
      await _search();
    } catch (e) {
      _toast(_err(e));
    } finally {
      if (mounted) setState(() => _loading = false);
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
    if (!(event.role.canCheckin)) {
      return const Center(child: Text('Check-in not allowed for your role'));
    }

    if (_scanning) {
      return Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                if (capture.barcodes.isEmpty) return;
                final value = capture.barcodes.first.rawValue;
                if (value != null && value.isNotEmpty) {
                  _scanToken(value);
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
          'Check-in · ${event.eventTitle}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed:
                    _loading ? null : () => setState(() => _scanning = true),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _qrManual,
          decoration: InputDecoration(
            labelText: 'Or paste QR token',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.check),
              onPressed: _loading ? null : () => _scanToken(_qrManual.text),
            ),
          ),
        ),
        const SizedBox(height: 20),
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
        if (_lastScanMessage != null)
          Text(
            _lastScanMessage!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 8),
        ..._tickets.map(
          (t) => Card(
            child: ListTile(
              title: Text(t.ticketNumber),
              subtitle: Text(
                [
                  if (t.holderName != null && t.holderName!.isNotEmpty)
                    t.holderName!,
                  t.status,
                  t.holderPhone ?? '—',
                  if (_priorCheckins != null)
                    'Prior check-ins: $_priorCheckins',
                ].join(' · '),
              ),
              trailing: FilledButton(
                onPressed: t.status == 'checked_in' || _loading
                    ? null
                    : () => _checkIn(t),
                child: const Text('Check in'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
