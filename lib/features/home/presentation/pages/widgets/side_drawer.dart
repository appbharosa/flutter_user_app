import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/core/utils/translations.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../language/pages/language_selection_page.dart';

class SideMenuDialog extends StatelessWidget {
  final Function(int) onMenuItemSelected;

  const SideMenuDialog({super.key, required this.onMenuItemSelected});

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'logout'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'logout'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'user_data');
      await storage.delete(key: 'user_registration_data');

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LanguageSelectionPage()),
              (route) => false,
        );
      }
    }
  }

  void _shareApp(BuildContext context) async {
    const String appUrl = 'https://play.google.com/store/apps/details?id=com.medrayder.user&pcampaignid=web_share';
    try {
      await Share.share(
        'Check out MedRayder App: $appUrl',
        subject: 'MedRayder Health App',
      );
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: appUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(26, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.asset(
                      'assets/logos.png',
                      height: 47,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LanguageSelectionPage(fromHome: true)),
                      );
                    },
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.transparent,
                      child: Image.asset('assets/language_icon.png', height: 40, width: 50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Menu items

            // Menu items (reordered)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    // 1. Profile
                    _buildMenuItem(
                      icon: Icons.person,
                      title: 'profile'.tr(),
                      onTap: () => onMenuItemSelected(0),
                    ),
                    // 2. Med Locker
                    _buildMenuItem(
                      icon: Icons.lock,
                      title: 'med_locker'.tr(),
                      onTap: () => onMenuItemSelected(1),
                    ),
                    // 3. Wallet
                    _buildMenuItem(
                      icon: Icons.wallet,
                      title: 'wallet'.tr(),
                      onTap: () => onMenuItemSelected(2),
                    ),
                    // 4. Care Plans
                    _buildMenuItem(
                      icon: Icons.subscriptions,
                      title: 'care_plans'.tr(),
                      onTap: () => onMenuItemSelected(3),
                    ),
                    // 5. My eCard
                    _buildMenuItem(
                      icon: Icons.credit_card,
                      title: 'my_ecard'.tr(),
                      onTap: () {
                        Navigator.of(context).pop();
                        onMenuItemSelected(13);
                      },
                    ),
                    // 6. Acko Insurance (custom tile, not using index)
                    ListTile(
                      leading: Image.asset(
                        'assets/acko.png',
                        width: 28,
                        height: 28,
                      ),
                      title:  Text(
                        'acko_insurance'.tr(),
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      onTap: () async {
                        const url = 'https://www.acko.com/authn/v1/signin?next%2Fmyaccount=&client_id=acko_webapp&redirect_uri=https%3A%2F%2Fwww.acko.com%2Fplatform%2Fauth%2Ftoken%2Facko_webapp&response_type=code&identity_type=d2c&scope=offline_access&realm=acko';
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not open the link.')),
                          );
                        }
                      },
                    ),
                    // 7. Bookings (Expandable)
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: const Icon(Icons.local_hospital, color: Colors.black87),
                        title:  Text(
                          'bookingss'.tr(),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        children: [
                          _buildSubMenuItem(
                            title: 'diagnostic_bookings'.tr(),
                            onTap: () => onMenuItemSelected(6),
                          ),
                          _buildSubMenuItem(
                            title: 'hospital_diagnostic_bookings'.tr(),
                            onTap: () => onMenuItemSelected(7),
                          ),
                          _buildSubMenuItem(
                            title: 'hospital_pharmacy_bookings'.tr(),
                            onTap: () => onMenuItemSelected(8),
                          ),
                          _buildSubMenuItem(
                            title: 'hospital_doctor_bookings'.tr(),
                            onTap: () => onMenuItemSelected(9),
                          ),
                          _buildSubMenuItem(
                            title: 'lab_test_bookings'.tr(),
                            onTap: () => onMenuItemSelected(10),
                          ),
                          _buildSubMenuItem(
                            title: 'pharmacy_bookings'.tr(),
                            onTap: () => onMenuItemSelected(11),
                          ),
                          _buildSubMenuItem(
                            title: 'online_doctor_bookings'.tr(),
                            onTap: () => onMenuItemSelected(12),
                          ),
                        ],
                      ),
                    ),
                    // 8. Contact Us
                    _buildMenuItem(
                      icon: Icons.contact_page,
                      title: 'contact_us'.tr(),
                      onTap: () => onMenuItemSelected(5),
                    ),
                    // 9. About
                    _buildMenuItem(
                      icon: Icons.info,
                      title: 'about'.tr(),
                      onTap: () => onMenuItemSelected(4),
                    ),
                    // 10. Share
                    _buildMenuItem(
                      icon: Icons.share,
                      title: 'share'.tr(),
                      onTap: () {
                        Navigator.of(context).pop();
                        _shareApp(context);
                      },
                    ),
                    const Divider(height: 20, thickness: 1),
                    // 11. Logout
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'logout'.tr(),
                      onTap: () => _showLogoutDialog(context),
                      textColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  
  Widget _buildSubMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: const Text('•', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 4, // reduces space between bullet and text
      contentPadding: const EdgeInsets.only(left: 32),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }


}