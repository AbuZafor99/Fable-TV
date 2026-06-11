import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../../Theme/constants/app_colors.dart';
import '../../../../core/services/channel_cache_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.bgDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 21,
                      color: TColors.textPrimary,
                    ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                children: [
                  _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: Icons.refresh_rounded,
                        title: 'Refresh channel list',
                        subtitle: 'Re-download channels and streams',
                        onTap: () async {
                          Fluttertoast.showToast(msg: 'Refreshing channels…');
                          await Get.find<HomeController>().refreshAll();
                          Fluttertoast.showToast(msg: 'Channels updated');
                        },
                      ),
                      _SettingsRow(
                        icon: Icons.delete_outline_rounded,
                        title: 'Clear cache',
                        subtitle: 'Removes cached channels, recents & favorites',
                        onTap: () async {
                          await Get.find<ChannelCacheService>().clearAll();
                          await Get.find<HomeController>().refreshAll();
                          Fluttertoast.showToast(msg: 'Cache cleared');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: Icons.public_rounded,
                        title: 'Data source',
                        subtitle: 'iptv-org public API · free live channels',
                      ),
                      _SettingsRow(
                        icon: Icons.info_outline_rounded,
                        title: 'About StreamWorld',
                        subtitle: 'v0.1.0 — free worldwide live TV',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, color: TColors.divider),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: TColors.bgElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 19, color: TColors.primary),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: TColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 11.5, color: TColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: TColors.textDisabled, size: 20),
          ],
        ),
      ),
    );
  }
}
