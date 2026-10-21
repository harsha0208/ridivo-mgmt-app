import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/di/providers.dart';
import '../../core/models/staff_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_tokens.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _versionLabel = '…';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _versionLabel = 'v${info.version} (${info.buildNumber})';
      });
    } catch (_) {
      if (!mounted) return;
      // Fallback to pubspec version if the native plugin isn't ready
      // (e.g. after hot reload without a full restart).
      setState(() => _versionLabel = 'v1.0.0 (1)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final staff = session.staff;
    final selected = session.selectedEvent;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account', style: AppTextStyles.darkAppBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: SvgPicture.asset(
              'assets/icons/ridivo_logo.svg',
              width: 64,
              height: 64,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            staff?.fullName.isNotEmpty == true
                ? staff!.fullName
                : 'Staff account',
            style: AppTextStyles.darkH2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            staff?.email ?? '',
            style: AppTextStyles.darkBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionCard(
            title: 'Account',
            children: [
              _DetailRow(label: 'Name', value: staff?.fullName ?? '—'),
              _DetailRow(label: 'Email', value: staff?.email ?? '—'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'Current event',
            children: [
              _DetailRow(
                label: 'Event',
                value: selected?.eventTitle ?? '—',
              ),
              _DetailRow(
                label: 'Role',
                value: _roleLabel(selected?.role),
              ),
            ],
          ),
          if (session.events.length > 1) ...[
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              title: 'Assigned events',
              children: [
                for (final e in session.events)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      e.eventTitle,
                      style: AppTextStyles.darkBodyStrong,
                    ),
                    subtitle: Text(
                      _roleLabel(e.role),
                      style: AppTextStyles.darkCaption,
                    ),
                    trailing: e.eventId == selected?.eventId
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      ref
                          .read(sessionControllerProvider)
                          .selectEvent(e.eventId);
                    },
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () async {
              // Pop account first so MaterialApp can swap home to Login.
              Navigator.of(context).pop();
              await ref.read(sessionControllerProvider).logout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _versionLabel,
            textAlign: TextAlign.center,
            style: AppTextStyles.darkCaption,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  String _roleLabel(StaffRole? role) {
    switch (role) {
      case StaffRole.checkin:
        return 'Check-in';
      case StaffRole.seller:
        return 'Seller';
      case StaffRole.timing:
        return 'Timing';
      case StaffRole.manager:
        return 'Manager';
      case StaffRole.unknown:
      case null:
        return '—';
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkBgSurface,
        borderRadius: AppRadius.bmd,
        border: Border.all(color: AppColors.darkBorderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTextStyles.darkLabelUpper),
          const SizedBox(height: AppSpacing.mdSm),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: AppTextStyles.darkCaption),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.darkBodyStrong),
          ),
        ],
      ),
    );
  }
}
