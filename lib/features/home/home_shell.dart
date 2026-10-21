import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/di/providers.dart';
import '../../core/models/staff_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_tokens.dart';
import '../checkin/checkin_screen.dart';
import '../profile/profile_screen.dart';
import '../timing/timing_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final role = session.currentRole;
    final canCheckin = role?.canCheckin ?? false;
    final canTiming = role?.canTiming ?? false;
    final sellerOnly = role?.isSellerOnly ?? false;

    final destinations = <_Dest>[];
    if (canCheckin) {
      destinations.add(
        const _Dest(
          label: 'Check-in',
          icon: Icons.qr_code_scanner,
          child: CheckinScreen(),
        ),
      );
    }
    if (canTiming) {
      destinations.add(
        const _Dest(
          label: 'Timing',
          icon: Icons.timer_outlined,
          child: TimingScreen(),
        ),
      );
    }

    if (_index >= destinations.length) {
      _index = 0;
    }

    final eventTitle = session.selectedEvent?.eventTitle;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.md,
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/ridivo_logo.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                eventTitle ?? 'Event Management',
                style: AppTextStyles.darkAppBarTitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        actions: [
          if (session.events.length > 1)
            PopupMenuButton<String>(
              tooltip: 'Switch event',
              icon: const Icon(Icons.swap_horiz),
              color: AppColors.darkBgElevated,
              onSelected: (id) {
                ref.read(sessionControllerProvider).selectEvent(id);
              },
              itemBuilder: (context) => [
                for (final e in session.events)
                  PopupMenuItem(
                    value: e.eventId,
                    child: Text(
                      '${e.eventTitle} (${e.role.name})',
                      style: AppTextStyles.darkBodyStrong,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          IconButton(
            tooltip: 'Account',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: sellerOnly || destinations.isEmpty
          ? _SellerBlocked(
              role: role,
              eventTitle: session.selectedEvent?.eventTitle,
            )
          : destinations[_index].child,
      bottomNavigationBar: destinations.length < 2
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    label: d.label,
                  ),
              ],
            ),
    );
  }
}

class _Dest {
  const _Dest({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;
}

class _SellerBlocked extends StatelessWidget {
  const _SellerBlocked({this.role, this.eventTitle});

  final StaffRole? role;
  final String? eventTitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 56,
              color: AppColors.darkTextMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              role == StaffRole.seller
                  ? 'Seller features are not available in this app'
                  : 'No check-in or timing access for this event',
              style: AppTextStyles.darkH3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              role == StaffRole.seller
                  ? 'Use the Ridivo admin website to sell and upgrade tickets'
                      '${eventTitle != null ? ' for $eventTitle' : ''}.'
                  : 'Ask a manager to update your staff role, or switch events.',
              style: AppTextStyles.darkBody,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
