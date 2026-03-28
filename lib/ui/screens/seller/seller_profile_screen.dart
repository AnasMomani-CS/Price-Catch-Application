// lib/ui/screens/seller/seller_profile_screen.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../data/models/seller_model.dart';
import '../auth/widgets/settings_switch.dart';
import '../auth/seller_login_screen.dart';
import 'offers.dart';
import 'seller_drawer.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final Color sellerColor = const Color(0xFF64748B);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> storeCategories = [
    "Grocery",
    "Electronics",
    "Coffee Shops",
    "Supermarkets",
    "Supermarkets + Grocery",
    "Restaurants",
    "Bakery",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<ProfileProvider>(context, listen: false)
            .fetchProfile(auth.user!.uid, 'seller');
      }
    });
  }

  Future<void> _launchMapUrl(String urlString) async {
    if (urlString == "Not Set" || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add the website link first")),
      );
      return;
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("The link is incorrect; copy it from Google Maps.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open the link")),
      );
    }
  }

  void _showEditBottomSheet(String label, String currentValue, String fieldKey,
      String Function(String) t) {
    final profileProv = Provider.of<ProfileProvider>(context, listen: false);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

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
            top: 25), // 🟢 تعديل بسيط بالـ padding ليكون أرتب
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${t('edit')} $label",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 🟢 التعديل الجوهري: إذا كان الحقل هو category اعرض خيارات
            if (fieldKey == 'category')
              SizedBox(
                height: 300, // ارتفاع مناسب للقائمة
                child: ListView.separated(
                  itemCount: storeCategories.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cat = storeCategories[index];
                    final isSelected = cat == currentValue;
                    return ListTile(
                      title: Text(cat,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? sellerColor : null,
                          )),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: sellerColor)
                          : null,
                      onTap: () async {
                        // تحديث الفايربيس فوراً عند الاختيار
                        bool success = await profileProv.updateSingleField(
                          uid: authProv.user!.uid,
                          role: 'seller',
                          fieldKey: fieldKey,
                          value: cat,
                        );
                        if (success && mounted) Navigator.pop(context);
                      },
                    );
                  },
                ),
              )
            else ...[
              // 🟢 إذا كان أي حقل آخر (اسم، هاتف، وصف) اعرض TextField
              if (fieldKey == 'address')
                const Text(
                  "Go to Google Maps > Share > Copy link > then paste it here",
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: fieldKey == 'description' ? 3 : 1,
                keyboardType: fieldKey == 'phoneNumber'
                    ? TextInputType.phone
                    : TextInputType.text,
                decoration: InputDecoration(
                  hintText: fieldKey == 'address'
                      ? "Paste Map Link"
                      : "${t('edit')} $label",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: sellerColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: sellerColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    bool success = await profileProv.updateSingleField(
                      uid: authProv.user!.uid,
                      role: 'seller',
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
            ],
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
    final seller = profileProv.sellerProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String t(String key) => settingsProv.translate(key);

    return Directionality(
      textDirection: settingsProv.currentLocale.languageCode == 'ar'
          ? ui.TextDirection.rtl
          : ui.TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        // 🟢 التعديل: صار endDrawer عشان يفتح من اليمين
        endDrawer: const SellerDrawer(),
        backgroundColor: isDark ? null : const Color(0xFFF8F9FA),
        body: profileProv.isLoading && seller == null
            ? Center(child: CircularProgressIndicator(color: sellerColor))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeaderWithImage(context, seller?.name, t),
                    const SizedBox(height: 60),
                    _buildSectionTitle(t('store_info')),
                    _buildInfoCard(seller, t),
                    _buildSectionTitle(t('settings')),
                    _buildThemesCard(context, t),
                    _buildSectionTitle(t('more')),
                    _buildAboutCard(context, t),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard(SellerProfile? seller, String Function(String) t) {
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
          _buildEditableField(t('store_name'), seller?.name ?? "Not Set",
              Icons.storefront, "name", t),
          _buildEditableField(t('email'), seller?.email ?? "Not Set",
              Icons.email_outlined, "email", t,
              canEdit: false),
          _buildEditableField(t('phone'), seller?.phoneNumber ?? "Not Set",
              Icons.phone_android, "phoneNumber", t),
          _buildEditableField(t('category'), seller?.category ?? "Not Set",
              Icons.category_outlined, "category", t),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: sellerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.location_on, color: sellerColor, size: 20),
            ),
            title: Text(t('address'),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            subtitle: Text(
              (seller?.address == null ||
                      seller!.address!.isEmpty ||
                      seller.address == "Not Set")
                  ? "Link not specified"
                  : "Location linked successfully",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color:
                      (seller?.address == null || seller?.address == "Not Set")
                          ? Colors.red[400]
                          : Colors.green),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.near_me_outlined,
                      color: Colors.blue, size: 20),
                  onPressed: () => _launchMapUrl(seller?.address ?? ""),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.blue, size: 20),
                  onPressed: () => _showEditBottomSheet(
                      t('address'), seller?.address ?? "", "address", t),
                ),
              ],
            ),
          ),
          _buildEditableField(
              t('description'),
              seller?.description ?? "Not Set",
              Icons.description_outlined,
              "description",
              t),
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
            color: sellerColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: sellerColor, size: 20),
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

  Widget _buildHeaderWithImage(
      BuildContext context, String? name, String Function(String) t) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: sellerColor,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.elliptical(200, 40)),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(t('seller_profile'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(top: 10, end: 10),
                    child: IconButton(
                      icon: const Icon(Icons.menu_rounded,
                          color: Colors.white, size: 28),
                      // 🟢 التعديل: openEndDrawer عشان يفتح من اليمين
                      onPressed: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          child: Column(
            children: [
              Consumer<ProfileProvider>(
                builder: (context, profileProv, child) {
                  final currentPhotoUrl = profileProv.sellerProfile?.photoUrl;
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
                          backgroundImage: (currentPhotoUrl != null &&
                                  currentPhotoUrl.isNotEmpty)
                              ? NetworkImage(currentPhotoUrl) as ImageProvider
                              : null,
                          child: profileProv.isLoading
                              ? const CircularProgressIndicator()
                              : (currentPhotoUrl == null ||
                                      currentPhotoUrl.isEmpty)
                                  ? const Icon(Icons.store,
                                      size: 50, color: Colors.grey)
                                  : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: sellerColor,
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
                                  role: 'seller',
                                );
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Profile picture updated successfully")),
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

  Widget _buildThemesCard(BuildContext context, String Function(String) t) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.local_offer_outlined, color: sellerColor),
            title: Text(t('my_offers')),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageOffersScreen()));
            },
          ),
          const Divider(height: 1, indent: 50),

          SwitchListTile(
            activeColor: sellerColor,
            secondary: Icon(Icons.dark_mode_outlined, color: sellerColor),
            title: Text(t('dark_mode'),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            value: settings.isDarkMode,
            onChanged: (bool value) {
              settings.toggleTheme(value);
            },
          ),

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
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline, color: sellerColor),
            title: Text(t('about')),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 50),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(t('logout'), style: const TextStyle(color: Colors.red)),
            onTap: () async {
              await authProv.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const SellerLoginScreen()),
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
