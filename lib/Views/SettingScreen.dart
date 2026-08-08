import 'package:bookverse/Widgets/Settingwidget.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool readingReminder = true;
  bool autoBrightness = true;
  bool tapToTurnPage = false;
  bool showClock = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            /// -------------------- GENERAL --------------------

            const SectionTitle(title: "General"),

            SettingsSectionCard(
              children: [
                SettingsSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  title: "Dark Mode",
                  value: darkMode,
                  onChanged: (value) {
                    setState(() {
                      darkMode = value;
                    });
                  },
                ),

                const Divider(height: 1),

                SettingsArrowTile(
                  icon: Icons.text_fields,
                  title: "Font Size",
                  value: "Medium",
                  onTap: () {},
                ),

                const Divider(height: 1),

                SettingsArrowTile(
                  icon: Icons.font_download_outlined,
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

            /// -------------------- PREFERENCES --------------------

            const SectionTitle(title: "Preferences"),

            SettingsSectionCard(
              children: [
                SettingsSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: "Reading Reminder",
                  value: readingReminder,
                  onChanged: (value) {
                    setState(() {
                      readingReminder = value;
                    });
                  },
                ),

                const Divider(height: 1),

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

                const Divider(height: 1),

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

                const Divider(height: 1),

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

            const SizedBox(height: 28),

            /// -------------------- ACCOUNT --------------------

            const SectionTitle(title: "Account"),

            SettingsSectionCard(
              children: [
                SettingsArrowTile(
                  icon: Icons.lock_outline,
                  title: "Change Password",
                  value: "",
                  onTap: () {},
                ),

                const Divider(height: 1),

                LogoutTile(
                  onTap: () {
                    // Logout Code
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}