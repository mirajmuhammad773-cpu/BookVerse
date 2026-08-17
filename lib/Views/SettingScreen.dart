import 'package:bookverse/Auths/SigninScreen.dart';
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
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            AppColors.background,
        centerTitle: true,

        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: AppColors.text,
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.symmetric(
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

                SettingsArrowTile(
                  icon: Icons.text_fields,
                  title: "Font Size",
                  value: "Medium",
                  onTap: () {},
                ),

                const Divider(height: 1),

                SettingsArrowTile(
                  icon:
                      Icons.font_download_outlined,
                  title: "Font Style",
                  value: "Roboto",
                  onTap: () {},
                ),

                const Divider(height: 1),

                SettingsArrowTile(
                  icon: Icons.language,
                  title: "Language",
                  value: "English",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==================================================
            // PREFERENCES
            // ==================================================

            const SectionTitle(
              title: "Preferences",
            ),

            SettingsSectionCard(
              children: [

                SettingsSwitchTile(
                  icon: Icons
                      .notifications_active_outlined,
                  title: "Reading Reminder",
                  value: readingReminder,
                  onChanged: (value) {
                    setState(() {
                      readingReminder =
                          value;
                    });
                  },
                ),

                const Divider(height: 1),

                SettingsSwitchTile(
                  icon:
                      Icons.wb_sunny_outlined,
                  title: "Auto Brightness",
                  value: autoBrightness,
                  onChanged: (value) {
                    setState(() {
                      autoBrightness =
                          value;
                    });
                  },
                ),

                const Divider(height: 1),

                SettingsSwitchTile(
                  icon:
                      Icons.touch_app_outlined,
                  title: "Tap to Turn Page",
                  value: tapToTurnPage,
                  onChanged: (value) {
                    setState(() {
                      tapToTurnPage =
                          value;
                    });
                  },
                ),

                const Divider(height: 1),

                SettingsSwitchTile(
                  icon:
                      Icons.access_time_outlined,
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

            const SizedBox(height: 28),

            // ==================================================
            // ACCOUNT
            // ==================================================

            const SectionTitle(
              title: "Account",
            ),

            SettingsSectionCard(
              children: [

                SettingsArrowTile(
                  icon:
                      Icons.lock_outline,
                  title: "Change Password",
                  value: "",
                  onTap:
                      _showChangePasswordDialog,
                ),

                const Divider(height: 1),

                LogoutTile(
                  onTap: _logout,
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
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

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [

                    // ==================================================
                    // CURRENT PASSWORD
                    // ==================================================

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
                            setDialogState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
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

                    const SizedBox(height: 14),

                    // ==================================================
                    // NEW PASSWORD
                    // ==================================================

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
                          Icons.lock_reset_outlined,
                        ),

                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setDialogState(() {
                              _obscureNewPassword =
                                  !_obscureNewPassword;
                            });
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

                    const SizedBox(height: 14),

                    // ==================================================
                    // CONFIRM PASSWORD
                    // ==================================================

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
                            setDialogState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
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

                  child:
                      const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () async {

                    await _changePassword(
                      dialogContext,
                    );
                  },

                  child:
                      const Text("Update"),
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

    // ==========================================================
    // VALIDATION
    // ==========================================================

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

    // ==========================================================
    // PROVIDER
    // ==========================================================

    final UserProvider userProvider =
        context.read<UserProvider>();

    // Close keyboard
    FocusScope.of(context).unfocus();

    final bool success =
        await userProvider.changePassword(
      currentPassword:
          currentPassword,
      newPassword:
          newPassword,
    );

    if (!mounted) return;

    // ==========================================================
    // SUCCESS
    // ==========================================================

    if (success) {

      Navigator.pop(
        dialogContext,
      );

      _showMessage(
        "Password updated successfully.",
      );

      return;
    }

    // ==========================================================
    // ERROR
    // ==========================================================

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

          title:
              const Text("Logout"),

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

              child:
                  const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              child:
                  const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirmLogout != true) {
      return;
    }

    // ==========================================================
    // LOGOUT PROVIDER
    // ==========================================================

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

    // ==========================================================
    // GO TO SIGN IN
    // ==========================================================

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
          content: Text(message),
        ),
      );
  }
}