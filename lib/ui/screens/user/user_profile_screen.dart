import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/settings_provider.dart';
import '../auth/widgets/settings_switch.dart';
import '../auth/user_login_screen.dart';
import 'my_catches_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<ProfileProvider>(context, listen: false)
            .fetchProfile(auth.user!.uid, 'user');
      }
    });
  }

  Future<void> _selectDate(BuildContext context, ProfileProvider profileProv,
      AuthProvider authProv) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.orange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      await profileProv.updateSingleField(
        uid: authProv.user!.uid,
        role: 'user',
        fieldKey: 'birthDate',
        value: formattedDate,
      );
    }
  }

  void _showGenderDialog(String currentValue, String Function(String) t) {
    String selectedGender = (currentValue == "Male" || currentValue == "Female")
        ? currentValue
        : "Male";

    final profileProv = Provider.of<ProfileProvider>(context, listen: false);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(t('gender')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("Male"),
                value: "Male",
                groupValue: selectedGender,
                activeColor: Colors.orange,
                onChanged: (val) => setDialogState(() => selectedGender = val!),
              ),
              RadioListTile<String>(
                title: const Text("Female"),
                value: "Female",
                groupValue: selectedGender,
                activeColor: Colors.orange,
                onChanged: (val) => setDialogState(() => selectedGender = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text(t('cancel'), style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                bool success = await profileProv.updateSingleField(
                  uid: authProv.user!.uid,
                  role: 'user',
                  fieldKey: 'gender',
                  value: selectedGender,
                );
                if (success && mounted) Navigator.pop(context);
              },
              child:
                  Text(t('save'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBottomSheet(String label, String currentValue, String fieldKey,
      String Function(String) t) {
    final profileProv = Provider.of<ProfileProvider>(context, listen: false);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    if (fieldKey == 'birthDate') {
      _selectDate(context, profileProv, authProv);
      return;
    }

    if (fieldKey == 'gender') {
      _showGenderDialog(currentValue, t);
      return;
    }

    final TextEditingController controller = TextEditingController(
        text: currentValue == "Not Set" ? "" : currentValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${t('edit')} $label",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: fieldKey == 'phoneNumber'
                  ? TextInputType.phone
                  : TextInputType.text,
              decoration: InputDecoration(
                hintText: "${t('edit')} $label",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  bool success = await profileProv.updateSingleField(
                    uid: authProv.user!.uid,
                    role: 'user',
                    fieldKey: fieldKey,
                    value: controller.text.trim(),
                  );
                  if (success && mounted) Navigator.pop(context);
                },
                child: Text(t('save'),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = Provider.of<ProfileProvider>(context);
    final settingsProv = Provider.of<SettingsProvider>(context);
    final user = profileProv.userProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String t(String key) => settingsProv.translate(key);

    return Directionality(
      textDirection: settingsProv.currentLocale.languageCode == 'ar'
          ? ui.TextDirection.rtl
          : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark ? null : const Color(0xFFF8F9FA),
        body: profileProv.isLoading && user == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeaderWithImage(context, user?.name, t),
                    const SizedBox(height: 60),
                    _buildSectionTitle(t('my_info')),
                    _buildInfoCard(profileProv, t),
                    _buildSectionTitle(t('themes')),
                    _buildThemesCard(context, t),
                    _buildSectionTitle(t('more')),
                    _buildAboutCard(context, t),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderWithImage(
      BuildContext context, String? name, String Function(String) t) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius:
                BorderRadius.vertical(bottom: Radius.elliptical(200, 40)),
          ),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(t('profile'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          child: Column(
            children: [
              Consumer<ProfileProvider>(
                builder: (context, profileProv, child) {
                  final currentPhotoUrl = profileProv.userProfile?.photoUrl;
                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          key: ValueKey(currentPhotoUrl),
                          // 🟢 التعديل الوحيد هنا: تبسيط عرض الصورة لدعم الروابط المباشرة فقط
                          backgroundImage: (currentPhotoUrl != null &&
                                  currentPhotoUrl.isNotEmpty)
                              ? NetworkImage(currentPhotoUrl) as ImageProvider
                              : null,
                          child: profileProv.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.orange)
                              : (currentPhotoUrl == null ||
                                      currentPhotoUrl.isEmpty)
                                  ? const Icon(Icons.person,
                                      size: 50, color: Colors.grey)
                                  : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 16,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                            onPressed: () async {
                              final authProv = Provider.of<AuthProvider>(
                                  context,
                                  listen: false);
                              if (authProv.user != null) {
                                bool success =
                                    await profileProv.uploadProfileImage(
                                  uid: authProv.user!.uid,
                                  role: 'user',
                                );

                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(t(
                                            'Profile picture updated successfully!'))),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(name ?? "...",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ProfileProvider prov, String Function(String) t) {
    final user = prov.userProfile;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      child: Column(
        children: [
          _buildEditableField(t('name'), user?.name ?? "Not Set",
              Icons.person_outline, "name", t),
          const Divider(height: 1, indent: 60),
          _buildEditableField(t('email'), user?.email ?? "Not Set",
              Icons.email_outlined, "email", t,
              canEdit: false),
          const Divider(height: 1, indent: 60),
          _buildEditableField(t('phone'), user?.phoneNumber ?? "Not Set",
              Icons.phone_android, "phoneNumber", t),
          const Divider(height: 1, indent: 60),
          _buildEditableField(
              t('gender'), user?.gender ?? "Not Set", Icons.male, "gender", t),
          const Divider(height: 1, indent: 60),
          _buildEditableField(t('birth'), user?.birthDate ?? "Not Set",
              Icons.calendar_today, "birthDate", t),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, String value, IconData icon,
      String fieldKey, String Function(String) t,
      {bool canEdit = true}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.orange, size: 20),
      ),
      title:
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: canEdit
          ? IconButton(
              icon:
                  const Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
              onPressed: () => _showEditBottomSheet(label, value, fieldKey, t),
            )
          : null,
    );
  }

  Widget _buildThemesCard(BuildContext context, String Function(String) t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      child: Column(
        children: [
          ListTile(
            leading:
                const Icon(Icons.local_offer_outlined, color: Colors.orange),
            title: Text(t('my_catches')),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyCatchesScreen()));
            },
          ),
          const Divider(height: 1, indent: 50),
          const SettingsSwitch(
              title: "Dark Mode",
              icon: Icons.dark_mode_outlined,
              isLanguage: false),
          const Divider(height: 1, indent: 50),
          const SettingsSwitch(
              title: "Language", icon: Icons.language, isLanguage: true),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, String Function(String) t) {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ]),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.orange),
            title: Text(t('about')),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 50),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(t('logout'),
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await authProv.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const UserLoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}
