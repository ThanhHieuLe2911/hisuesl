import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hisuesl/core/constants/app_colors.dart';
import 'package:hisuesl/features/auth/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String? currentAvatarBase64;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    this.currentAvatarBase64,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();

  String? _newAvatarBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  // --- LOGIC CHỌN ẢNH ---
  Future<void> _pickAndCompressImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      var result = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 300,
        minWidth: 300,
        quality: 70,
      );

      setState(() {
        _newAvatarBase64 = base64Encode(result);
      });
    }
  }

  // --- HÀM HIỆN DIALOG ---
  void _showResultDialog(bool isSuccess, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon trạng thái
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_rounded : Icons.priority_high_rounded,
                  size: 40,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 16),

              // Tiêu đề
              Text(
                isSuccess ? "Thành Công!" : "Có Lỗi Xảy Ra",
                style: GoogleFonts.dongle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.red,
                    height: 1.0
                ),
              ),

              // Nội dung thông báo
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.dongle(fontSize: 26, color: Colors.grey.shade700, height: 1.1),
              ),
              const SizedBox(height: 24),

              // Nút bấm
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? AppColors.primary : Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // Đóng Dialog
                    if (isSuccess) {
                      Navigator.pop(context); // Đóng màn hình Edit về Profile
                    }
                  },
                  child: Text(
                    // --- SỬA LỖI 2: Đổi text thành "TRỞ VỀ" ---
                    isSuccess ? "TRỞ VỀ" : "THỬ LẠI",
                    style: GoogleFonts.dongle(
                        fontSize: 28,
                        color: isSuccess ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold // Dialog giữ bold ok
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIC LƯU ---
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String res = await AuthService().updateUserProfile(
      name: _nameController.text.trim(),
      base64Image: _newAvatarBase64,
    );

    if (_oldPassController.text.isNotEmpty && _newPassController.text.isNotEmpty) {
      String passRes = await AuthService().changePassword(
          _oldPassController.text,
          _newPassController.text
      );

      if (passRes != "Success") {
        if (passRes.contains("incorrect") || passRes.contains("wrong-password")) {
          res = "Mật khẩu hiện tại không đúng!";
        } else if (passRes.contains("weak-password")) {
          res = "Mật khẩu mới quá yếu (cần > 6 ký tự).";
        } else if (passRes.contains("too-many-requests")) {
          res = "Thao tác quá nhiều lần, vui lòng thử lại sau.";
        } else {
          res = "Lỗi đổi mật khẩu: Vui lòng kiểm tra lại.";
        }
      }
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (res == "Success") {
        _showResultDialog(true, "Thông tin của bạn đã được cập nhật.");
      } else {
        _showResultDialog(false, res);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (_newAvatarBase64 != null) {
      avatarImage = MemoryImage(base64Decode(_newAvatarBase64!));
    } else if (widget.currentAvatarBase64 != null && widget.currentAvatarBase64!.isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(widget.currentAvatarBase64!));
      } catch (e) {
        print("Lỗi ảnh cũ: $e");
      }
    }

    final inputStyle = GoogleFonts.dongle(fontSize: 28, color: Colors.black, height: 1.2);
    final labelStyle = GoogleFonts.dongle(fontSize: 24, color: Colors.grey, height: 1.0);
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Chỉnh sửa Hồ sơ", style: GoogleFonts.dongle(fontSize: 32, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. AVATAR
              GestureDetector(
                onTap: _pickAndCompressImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                          border: Border.all(color: AppColors.primary, width: 3),
                          image: avatarImage != null
                              ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                              : null,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
                      ),
                      child: avatarImage == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 2. TÊN HIỂN THỊ
              TextFormField(
                controller: _nameController,
                style: inputStyle,
                decoration: InputDecoration(
                  labelText: "Tên hiển thị",
                  labelStyle: labelStyle,
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                validator: (val) => val!.isEmpty ? "Tên không được để trống" : null,
              ),
              const SizedBox(height: 30),

              // 3. ĐỔI MẬT KHẨU
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Đổi mật khẩu (Không bắt buộc)", style: GoogleFonts.dongle(fontSize: 26, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _oldPassController,
                obscureText: true,
                style: inputStyle,
                decoration: InputDecoration(
                  labelText: "Mật khẩu hiện tại",
                  labelStyle: labelStyle,
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPassController,
                obscureText: true,
                style: inputStyle,
                decoration: InputDecoration(
                  labelText: "Mật khẩu mới",
                  labelStyle: labelStyle,
                  border: borderStyle,
                  enabledBorder: borderStyle,
                  prefixIcon: const Icon(Icons.key_rounded, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),

              const SizedBox(height: 40),

              // 4. NÚT LƯU
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "THAY ĐỔI",
                    // --- SỬA LỖI 1: Bỏ font bold mặc định của nút ---
                    style: GoogleFonts.dongle(
                        fontSize: 34, // Tăng size lên 26
                        fontWeight: FontWeight.w400, // Ép về Normal để không bị vỡ font
                        color: Colors.white,
                        height: 1.0
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}