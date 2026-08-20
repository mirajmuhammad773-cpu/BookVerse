import 'package:bookverse/Auths/SigninScreen.dart';
import 'package:bookverse/ViewModels/BrightnessProvider.dart';
import 'package:bookverse/ViewModels/FontProvider.dart';
import 'package:bookverse/ViewModels/UserProvider.dart';
import 'package:bookverse/Widgets/Settingwidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  // ============================================================
  // LOCAL SETTINGS
  // ============================================================

  bool readingReminder = true;
  bool autoBrightness = true;
  bool tapToTurnPage = false;
  bool showClock = true;

  // ============================================================
  // PASSWORD CONTROLLERS
  // ============================================================

  final TextEditingController
      _currentPasswordController =
      TextEditingController();

  final TextEditingController
      _newPasswordController =
      TextEditingController();

  final TextEditingController
      _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.text,
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          children: [
            // ==================================================
            // GENERAL
            // ==================================================

            const SectionTitle(
              title: "General",
            ),

            SettingsSectionCard(
              children: [
                // ==============================================
                // FONT SIZE
                // ==============================================

                SettingsArrowTile(
                  icon: Icons.text_fields,
                  title: "Font Size",
                  value: "Medium",
                  onTap: () {},
                ),

                const Divider(
                  height: 1,
                ),

                // ==============================================
                // FONT STYLE
                // ==============================================

                Consumer<FontProvider>(
                  builder: (
                    context,
                    fontProvider,
                    child,
                  ) {
                    return SettingsArrowTile(
                      icon:
                          Icons.font_download_outlined,
                      title: "Font Style",
                      value:
                          fontProvider.selectedFontName,
                      onTap: () {
                        _showFontSelectionDialog(
                          context,
                        );
                      },
                    );
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ==============================================
                // LANGUAGE
                // ==============================================

                SettingsArrowTile(
                  icon: Icons.language,
                  title: "Language",
                  value: "English",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            // ==================================================
            // READING
            // ==================================================

            const SectionTitle(
              title: "Reading",
            ),

            SettingsSectionCard(
              children: [
                // ==============================================
                // READING BRIGHTNESS
                // ==============================================

                Consumer<BrightnessProvider>(
                  builder: (
                    context,
                    brightnessProvider,
                    child,
                  ) {
                    return SettingsArrowTile(
                      icon:
                          Icons.brightness_6_outlined,
                      title: "Reading Brightness",
                      value: brightnessProvider
                          .brightnessModeName,
                      onTap: () {
                        _showBrightnessDialog(
                          context,
                        );
                      },
                    );
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ==============================================
                // READING REMINDER
                // ==============================================

                SettingsSwitchTile(
                  icon: Icons
                      .notifications_active_outlined,
                  title: "Reading Reminder",
                  value: readingReminder,
                  onChanged: (value) {
                    setState(() {
                      readingReminder = value;
                    });
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ==============================================
                // AUTO BRIGHTNESS
                // ==============================================

                SettingsSwitchTile(
                  icon: Icons.wb_sunny_outlined,
                  title: "Auto Brightness",
                  value: autoBrightness,
                  onChanged: (value) {
                    setState(() {
                      autoBrightness = value;
                    });
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ==============================================
                // TAP TO TURN PAGE
                // ==============================================

                SettingsSwitchTile(
                  icon: Icons.touch_app_outlined,
                  title: "Tap to Turn Page",
                  value: tapToTurnPage,
                  onChanged: (value) {
                    setState(() {
                      tapToTurnPage = value;
                    });
                  },
                ),

                const Divider(
                  height: 1,
                ),

                // ==============================================
                // SHOW CLOCK
                // ==============================================

                SettingsSwitchTile(
                  icon: Icons.access_time_outlined,
                  title: "Show Clock",
                  value: showClock,
                  onChanged: (value) {
                    setState(() {
                      showClock = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            // ==================================================
            // ACCOUNT
            // ==================================================

            const SectionTitle(
              title: "Account",
            ),

            SettingsSectionCard(
              children: [
                // ==============================================
                // CHANGE PASSWORD
                // ==============================================

                SettingsArrowTile(
                  icon: Icons.lock_outline,
                  title: "Change Password",
                  value: "",
                  onTap:
                      _showChangePasswordDialog,
                ),

                const Divider(
                  height: 1,
                ),

                // ==============================================
                // LOGOUT
                // ==============================================

                LogoutTile(
                  onTap: _logout,
                ),
              ],
            ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FONT SELECTION
  // ============================================================

  void _showFontSelectionDialog(
    BuildContext context,
  ) {
    final FontProvider fontProvider =
        context.read<FontProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: 20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  "Choose Font",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                // ============================================
                // ROBOTO
                // ============================================

                _fontOption(
                  context: sheetContext,
                  fontProvider: fontProvider,
                  font: FontProvider.roboto,
                  name: "Roboto",
                ),

                // ============================================
                // BRITTANY SIGNATURE
                // ============================================

                _fontOption(
                  context: sheetContext,
                  fontProvider: fontProvider,
                  font: FontProvider.brittanySignature,
                  name: "Brittany Signature",
                ),

                // ============================================
                // DANCING
                // ============================================

                _fontOption(
                  context: sheetContext,
                  fontProvider: fontProvider,
                  font: FontProvider.dancing,
                  name: "Dancing",
                ),

                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // FONT OPTION
  // ============================================================

  Widget _fontOption({
    required BuildContext context,
    required FontProvider fontProvider,
    required String font,
    required String name,
  }) {
    final bool isSelected =
        fontProvider.selectedFont == font;

    // Material is intentionally added here.
    // It fixes the Flutter ListTile ink splash warning.
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          isSelected
              ? Icons.radio_button_checked
              : Icons.radio_button_off,
          color: isSelected
              ? AppColors.primary
              : Colors.grey,
        ),

        title: Text(
          name,
          style: TextStyle(
            fontFamily: font,
            fontSize: 18,
          ),
        ),

        trailing: isSelected
            ? const Icon(
                Icons.check,
                color: AppColors.primary,
              )
            : null,

        onTap: () async {
          await fontProvider.selectFont(
            font,
          );

          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  // ============================================================
  // BRIGHTNESS DIALOG
  // ============================================================

  void _showBrightnessDialog(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: false,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return Consumer<BrightnessProvider>(
          builder: (
            context,
            brightnessProvider,
            child,
          ) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    // ========================================
                    // TITLE
                    // ========================================

                    const Text(
                      "Reading Brightness",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      "Brightness will only apply to ReaderScreen",
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            AppColors.subtitle,
                      ),
                      textAlign:
                          TextAlign.center,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ========================================
                    // NORMAL
                    // ========================================

                    _brightnessOption(
                      context: sheetContext,
                      provider:
                          brightnessProvider,
                      mode:
                          BrightnessProvider.normal,
                      icon: Icons
                          .brightness_auto_outlined,
                      title: "Normal",
                    ),

                    // ========================================
                    // LOW
                    // ========================================

                    _brightnessOption(
                      context: sheetContext,
                      provider:
                          brightnessProvider,
                      mode:
                          BrightnessProvider.low,
                      icon: Icons
                          .brightness_4_outlined,
                      title: "Low",
                    ),

                    // ========================================
                    // MEDIUM
                    // ========================================

                    _brightnessOption(
                      context: sheetContext,
                      provider:
                          brightnessProvider,
                      mode:
                          BrightnessProvider.medium,
                      icon: Icons
                          .brightness_6_outlined,
                      title: "Medium",
                    ),

                    // ========================================
                    // HIGH
                    // ========================================

                    _brightnessOption(
                      context: sheetContext,
                      provider:
                          brightnessProvider,
                      mode:
                          BrightnessProvider.high,
                      icon: Icons
                          .brightness_7_outlined,
                      title: "High",
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // BRIGHTNESS OPTION
  // ============================================================

  Widget _brightnessOption({
    required BuildContext context,
    required BrightnessProvider provider,
    required String mode,
    required IconData icon,
    required String title,
  }) {
    final bool isSelected =
        provider.brightnessMode == mode;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? AppColors.primary
              : Colors.grey.shade700,
        ),

        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected
                ? FontWeight.w600
                : FontWeight.w400,
            color: AppColors.text,
          ),
        ),

        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              )
            : null,

        onTap: () async {
          await provider.selectBrightness(
            mode,
          );

          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  // ============================================================
  // CHANGE PASSWORD DIALOG
  // ============================================================

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    _obscureCurrentPassword = true;
    _obscureNewPassword = true;
    _obscureConfirmPassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                "Change Password",
              ),

              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    // ==========================================
                    // CURRENT PASSWORD
                    // ==========================================

                    TextField(
                      controller:
                          _currentPasswordController,
                      obscureText:
                          _obscureCurrentPassword,
                      decoration:
                          InputDecoration(
                        labelText:
                            "Current Password",
                        prefixIcon:
                            const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setDialogState(
                              () {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              },
                            );
                          },
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ==========================================
                    // NEW PASSWORD
                    // ==========================================

                    TextField(
                      controller:
                          _newPasswordController,
                      obscureText:
                          _obscureNewPassword,
                      decoration:
                          InputDecoration(
                        labelText:
                            "New Password",
                        prefixIcon:
                            const Icon(
                          Icons
                              .lock_reset_outlined,
                        ),
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setDialogState(
                              () {
                                _obscureNewPassword =
                                    !_obscureNewPassword;
                              },
                            );
                          },
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ==========================================
                    // CONFIRM PASSWORD
                    // ==========================================

                    TextField(
                      controller:
                          _confirmPasswordController,
                      obscureText:
                          _obscureConfirmPassword,
                      decoration:
                          InputDecoration(
                        labelText:
                            "Confirm Password",
                        prefixIcon:
                            const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setDialogState(
                              () {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              },
                            );
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    "Cancel",
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {
                    await _changePassword(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    "Update",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _changePassword(
    BuildContext dialogContext,
  ) async {
    final String currentPassword =
        _currentPasswordController.text
            .trim();

    final String newPassword =
        _newPasswordController.text
            .trim();

    final String confirmPassword =
        _confirmPasswordController.text
            .trim();

    if (currentPassword.isEmpty) {
      _showMessage(
        "Please enter your current password.",
      );
      return;
    }

    if (newPassword.isEmpty) {
      _showMessage(
        "Please enter your new password.",
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage(
        "Please confirm your new password.",
      );
      return;
    }

    if (newPassword.length < 6) {
      _showMessage(
        "Password must be at least 6 characters.",
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage(
        "New passwords do not match.",
      );
      return;
    }

    if (currentPassword == newPassword) {
      _showMessage(
        "New password must be different from current password.",
      );
      return;
    }

    final UserProvider userProvider =
        context.read<UserProvider>();

    FocusScope.of(context).unfocus();

    final bool success =
        await userProvider.changePassword(
      currentPassword:
          currentPassword,
      newPassword:
          newPassword,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(
        dialogContext,
      );

      _showMessage(
        "Password updated successfully.",
      );

      return;
    }

    _showMessage(
      userProvider.errorMessage ??
          "Unable to update password.",
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final bool? confirmLogout =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Logout",
          ),

          content: const Text(
            "Are you sure you want to logout?",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                "Logout",
              ),
            ),
          ],
        );
      },
    );

    if (confirmLogout != true) {
      return;
    }

    final UserProvider userProvider =
        context.read<UserProvider>();

    final bool success =
        await userProvider.logout();

    if (!mounted) return;

    if (!success) {
      _showMessage(
        userProvider.errorMessage ??
            "Unable to logout.",
      );

      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const BookVerseSignInScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
  }
}