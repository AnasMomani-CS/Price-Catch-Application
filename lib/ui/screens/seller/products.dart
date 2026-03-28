// lib/ui/screens/user/manage_products_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/products_provider.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<ProductsProvider>(context, listen: false)
            .fetchProducts(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsProv = context.watch<ProductsProvider>();
    final products = productsProv.products;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.sellerDeepDark),
        title: const Text(
          "Manage Products",
          style: TextStyle(
            color: AppColors.sellerDeepDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: InkWell(
              onTap: () => _showAddEditBottomSheet(context, null),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoBanner(), // النص الأصلي رجع هون
          if (productsProv.isLoading)
            const Expanded(
                child: Center(
                    child: CircularProgressIndicator(color: Colors.blue)))
          else if (products.isEmpty)
            _buildEmptyState()
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: products.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemBuilder: (context, index) =>
                    _buildProductCard(products[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    bool isActive = product["isActive"] ?? true;
    String productId = product["id"];
    String? imageUrl = product["imageUrl"];

    //  ا تحويل النص لرقم بأمان
    double originalPrice = double.tryParse(
            product["originalPrice"]?.toString() ??
                product["price"]?.toString() ??
                '0.0') ??
        0.0;
    double discount =
        double.tryParse(product["discountPercentage"]?.toString() ?? '0.0') ??
            0.0;
    double finalPrice =
        double.tryParse(product["price"]?.toString() ?? '0.0') ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[100],
                            child: const Icon(Icons.image_not_supported)))
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[100],
                        child: const Icon(Icons.image)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product["name"] ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text("${finalPrice.toStringAsFixed(2)} JOD",
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        if (discount > 0) ...[
                          const SizedBox(width: 8),
                          Text(originalPrice.toStringAsFixed(2),
                              style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5)),
                            child: Text("-${discount.toInt()}%",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(product["description"] ?? "",
                        maxLines: 1,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatusToggle(productId, isActive),
              const Spacer(),
              _buildIconBtn(
                  icon: Icons.edit_outlined,
                  bgColor: const Color(0xFFE3F2FD),
                  iconColor: Colors.blue[700]!,
                  onTap: () => _showAddEditBottomSheet(context, product)),
              const SizedBox(width: 10),
              _buildIconBtn(
                  icon: Icons.delete_outline,
                  bgColor: const Color(0xFFFFEBEE),
                  iconColor: Colors.red[700]!,
                  onTap: () =>
                      Provider.of<ProductsProvider>(context, listen: false)
                          .deleteProduct(productId)),
            ],
          )
        ],
      ),
    );
  }

  void _showAddEditBottomSheet(
      BuildContext context, Map<String, dynamic>? currentProduct) {
    final TextEditingController nameController =
        TextEditingController(text: currentProduct?["name"] ?? "");
    final TextEditingController originalPriceController = TextEditingController(
        text:
            (currentProduct?["originalPrice"] ?? currentProduct?["price"] ?? "")
                .toString());
    final TextEditingController discountController = TextEditingController(
        text: (currentProduct?["discountPercentage"] ?? "0").toString());
    final TextEditingController descController =
        TextEditingController(text: currentProduct?["description"] ?? "");

    final bool isEditing = currentProduct != null;
    File? selectedImage;
    bool isSaving = false;
    double calculatedFinalPrice =
        double.tryParse(currentProduct?["price"]?.toString() ?? '0.0') ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          void updateFinalPrice() {
            double original =
                double.tryParse(originalPriceController.text) ?? 0.0;
            double disc = double.tryParse(discountController.text) ?? 0.0;
            setModalState(() {
              calculatedFinalPrice = original - (original * (disc / 100));
            });
          }

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEditing ? "Edit Product" : "Add New Product",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      final img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (img != null)
                        setModalState(() => selectedImage = File(img.path));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: selectedImage != null
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            : (currentProduct?["imageUrl"] != null
                                ? Image.network(currentProduct!["imageUrl"],
                                    fit: BoxFit.cover)
                                : const Icon(Icons.add_a_photo)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                      controller: nameController, hint: "Product Name"),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              controller: originalPriceController,
                              hint: "Price (JOD)",
                              isNumber: true,
                              onChanged: (_) => updateFinalPrice())),
                      const SizedBox(width: 15),
                      Expanded(
                          child: _buildTextField(
                              controller: discountController,
                              hint: "Discount %",
                              isNumber: true,
                              onChanged: (_) => updateFinalPrice())),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                        "Final Price after discount: ${calculatedFinalPrice.toStringAsFixed(2)} JOD",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                      controller: descController,
                      hint: "Description",
                      maxLines: 2),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25))),
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (nameController.text.isEmpty ||
                                  originalPriceController.text.isEmpty) return;
                              setModalState(() => isSaving = true);
                              final auth = Provider.of<AuthProvider>(context,
                                  listen: false);
                              final productsProv =
                                  Provider.of<ProductsProvider>(context,
                                      listen: false);
                              if (auth.user != null) {
                                if (isEditing) {
                                  await productsProv.updateProduct(
                                    productId: currentProduct!["id"],
                                    sellerUid: auth.user!.uid,
                                    name: nameController.text,
                                    description: descController.text,
                                    originalPrice: double.tryParse(
                                            originalPriceController.text) ??
                                        0.0,
                                    discountPercentage: double.tryParse(
                                            discountController.text) ??
                                        0.0,
                                    price: calculatedFinalPrice,
                                    currentImageUrl: currentProduct["imageUrl"],
                                    newImageFile: selectedImage,
                                  );
                                } else {
                                  await productsProv.addProduct(
                                    sellerUid: auth.user!.uid,
                                    name: nameController.text,
                                    description: descController.text,
                                    originalPrice: double.tryParse(
                                            originalPriceController.text) ??
                                        0.0,
                                    discountPercentage: double.tryParse(
                                            discountController.text) ??
                                        0.0,
                                    price: calculatedFinalPrice,
                                    imageFile: selectedImage,
                                  );
                                }
                              }
                              if (context.mounted) Navigator.pop(context);
                            },
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(isEditing ? "Save Changes" : "Add Product",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //  إعادة النص الأصلي للبانر
  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.inventory_rounded,
                color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Showcase Your Items!", 
                  style: TextStyle(
                      color: AppColors.sellerDeepDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  "Add clear images and details to help users decide.", 
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // الـ Widgets المساعدة الأخرى
  Widget _buildStatusToggle(String productId, bool isActive) {
    return InkWell(
      onTap: () => Provider.of<ProductsProvider>(context, listen: false)
          .toggleProductStatus(productId, isActive),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: isActive
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(Icons.circle,
              color: isActive ? Colors.green : Colors.grey, size: 10),
          const SizedBox(width: 6),
          Text(isActive ? "Active" : "Inactive",
              style: TextStyle(
                  color: isActive ? Colors.green : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      int maxLines = 1,
      bool isNumber = false,
      Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.backgroundLight,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2))),
    );
  }

  Widget _buildIconBtn(
      {required IconData icon,
      required Color bgColor,
      required Color iconColor,
      required VoidCallback onTap}) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20)));
  }

  Widget _buildEmptyState() {
    return Expanded(
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
      const SizedBox(height: 15),
      const Text("No products yet!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
    ])));
  }
}
