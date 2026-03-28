import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/settings_provider.dart';

class SettingsSwitch extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isLanguage; 

  const SettingsSwitch({
    super.key,
    required this.title,
    required this.icon,
    this.isLanguage = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: isLanguage
          ? DropdownButton<String>(
              value: settings.currentLocale.languageCode,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) settings.changeLanguage(newValue);
              },
              items: const [
                DropdownMenuItem(value: 'ar', child: Text("العربية")),
                DropdownMenuItem(value: 'en', child: Text("English")),
              ],
            )
          : Switch(
              value: settings.isDarkMode,
              activeThumbColor: Colors.orange[800], // لون يتناسب مع براند Price Catch
              onChanged: (value) => settings.toggleTheme(value),
            ),
    );
  }
}