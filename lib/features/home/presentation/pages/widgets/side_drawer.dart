import 'package:flutter/material.dart';
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person,
                      title: 'profile'.tr(),
                      onTap: () => onMenuItemSelected(0),
                    ),
                    _buildMenuItem(
                      icon: Icons.lock,
                      title: 'Med Locker',
                      onTap: () => onMenuItemSelected(1),
                    ),
                    _buildMenuItem(
                      icon: Icons.wallet,
                      title: 'Wallet',
                      onTap: () => onMenuItemSelected(2),
                    ),
                    _buildMenuItem(
                      icon: Icons.info,
                      title: 'about'.tr(),
                      onTap: () => onMenuItemSelected(3),
                    ),
                    _buildMenuItem(
                      icon: Icons.contact_page,
                      title: 'contact_us'.tr(),
                      onTap: () => onMenuItemSelected(4),
                    ),

                    // --- Existing Diagnostic Bookings (Normal) ---
                    _buildMenuItem(
                      icon: Icons.medical_services,
                      title: 'Diagnostic Bookings',
                      onTap: () => onMenuItemSelected(5),
                    ),

                    // --- Expandable Hospital Bookings (New) ---
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: const Icon(Icons.local_hospital, color: Colors.black87),
                        title: const Text(
                          'Hospital Bookings',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        children: [
                          _buildSubMenuItem(
                            title: 'Hospital Diagnostic Bookings',
                            onTap: () {
                              Navigator.of(context).pop();
                              onMenuItemSelected(9);
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Pharmacy Bookings',
                            onTap: () {
                              Navigator.of(context).pop();
                              onMenuItemSelected(10);
                            },
                          ),
                          _buildSubMenuItem(
                            title: 'Doctor Bookings',
                            onTap: () {
                              Navigator.of(context).pop();
                              onMenuItemSelected(11);
                            },
                          ),

                        ],
                      ),
                    ),

                    _buildMenuItem(
                      icon: Icons.science,
                      title: 'LabTest Bookings',
                      onTap: () => onMenuItemSelected(6),
                    ),
                    _buildMenuItem(
                      icon: Icons.medication,
                      title: 'Pharmacy Bookings',
                      onTap: () {
                        Navigator.of(context).pop();
                        onMenuItemSelected(12); // new index
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.credit_card,
                      title: 'My eCard',
                      onTap: () {
                        Navigator.of(context).pop();
                        onMenuItemSelected(13); // new index
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.medical_services,
                      title: 'Online Doctor Bookings',
                      onTap: () {
                        Navigator.of(context).pop();
                        onMenuItemSelected(14); // new index
                      },
                    ),
                    const Divider(height: 20, thickness: 1),
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