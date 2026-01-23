import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

enum Gender { LakiLaki, Perempuan }

class RegisterMenu extends StatefulWidget {
  const RegisterMenu({super.key});

  @override
  State<RegisterMenu> createState() => _RegisterMenuState();
}

class _RegisterMenuState extends State<RegisterMenu> {
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  Gender? _selectedGender;
  bool _isObscure = true;
  bool _isLoading = false;
  final Color primaryColor = const Color(0xFFED6B23);

  final sb.SupabaseClient supabase = sb.Supabase.instance.client;

  Widget _buildFadeIn({required Widget child, required double delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: (600 * delay).toInt()),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty ||
        _nikController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty ||
        _selectedGender == null) {
      _showSnackBar("Mohon lengkapi semua data!");
      return;
    }

    if (_nikController.text.length != 16) {
      _showSnackBar("NIK harus berjumlah 16 digit!");
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      _showSnackBar("Konfirmasi password tidak sesuai!");
      return;
    }

    setState(() => _isLoading = true);
    User? firebaseUser;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passController.text.trim());
      
      firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        String genderValue = _selectedGender == Gender.LakiLaki ? "L" : "P";

        await supabase.from('users').insert({
          "nama": _nameController.text.trim(),
          "nik": _nikController.text.trim(),
          "telp": _phoneController.text.trim(),
          "email": _emailController.text.trim().toLowerCase(),
          "gender": genderValue,
          "password": _passController.text.trim(), 
        });

        if (mounted) {
          _showSnackBar("Registrasi Berhasil! Silahkan Masuk.");
          Navigator.pop(context); 
        }
      }

    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Error Firebase Auth");
    } on sb.PostgrestException catch (e) {
      if (firebaseUser != null) await firebaseUser.delete();
      _showSnackBar("Database Error: ${e.message}");
    } catch (e) {
      if (firebaseUser != null) await firebaseUser.delete();
      _showSnackBar("Terjadi kesalahan: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 12)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                _buildFadeIn(
                  delay: 1.0,
                  child: _buildLogo(),
                ),

                const SizedBox(height: 20),
                
                _buildFadeIn(
                  delay: 1.2,
                  child: Column(
                    children: [
                      Text(
                        "PENDAFTARAN TIKET",
                        style: GoogleFonts.plusJakartaSans(
                          color: primaryColor, 
                          fontSize: 22, 
                          fontWeight: FontWeight.w800, 
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Lengkapi data sesuai KTP Anda",
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                
                _buildFadeIn(
                  delay: 1.4,
                  child: _buildRegisterTicket(),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 100, width: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => 
              Icon(Icons.train, size: 50, color: primaryColor),
        ),
      ),
    );
  }

  Widget _buildRegisterTicket() {
    return ClipPath(
      clipper: TicketClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("DATA IDENTITAS"),
                  const SizedBox(height: 15),
                  _buildField("NAMA LENGKAP", _nameController, Icons.person_outline),
                  _buildField("NOMOR NIK (16 DIGIT)", _nikController, Icons.badge_outlined, isNumber: true, maxLength: 16),
                  _buildField("NOMOR TELEPON", _phoneController, Icons.phone_android_outlined, isNumber: true, maxLength: 13),
                  _buildField("ALAMAT EMAIL", _emailController, Icons.mail_outline),
                  _buildGenderDropdown(),
                  const SizedBox(height: 20),
                  _buildSectionTitle("KEAMANAN"),
                  const SizedBox(height: 15),
                  _buildField("KATA SANDI", _passController, Icons.lock_outline, isPass: true),
                  _buildField("KONFIRMASI SANDI", _confirmPassController, Icons.lock_reset, isPass: true),
                  const SizedBox(height: 30),
                  _buildRegisterButton(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: primaryColor)),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: Colors.grey[200])),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isPass = false, bool isNumber = false, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
          TextField(
            controller: controller,
            obscureText: isPass ? _isObscure : false,
            keyboardType: isNumber ? TextInputType.number : TextInputType.emailAddress,
            inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(maxLength)] : null,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              counterText: "",
              prefixIcon: Icon(icon, color: primaryColor, size: 20),
              suffixIcon: isPass ? IconButton(
                icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              ) : null,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[200]!)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("GENDER", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
        DropdownButtonFormField<Gender>(
          value: _selectedGender,
          items: Gender.values.map((Gender gender) {
            return DropdownMenuItem<Gender>(
              value: gender, 
              child: Text(
                gender == Gender.LakiLaki ? "Laki-laki" : "Perempuan", 
                style: GoogleFonts.plusJakartaSans(fontSize: 14)
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedGender = val),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.wc_outlined, color: primaryColor, size: 20),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("KONFIRMASI PENDAFTARAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.grey[50],
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Text("Sudah punya akun? MASUK DISINI", style: GoogleFonts.plusJakartaSans(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = 12.0;
    double clipPosition = size.height * 0.88; 
    path.lineTo(0, clipPosition);
    path.arcToPoint(Offset(0, clipPosition + 20), radius: Radius.circular(radius), clockwise: true);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, clipPosition + 20);
    path.arcToPoint(Offset(size.width, clipPosition), radius: Radius.circular(radius), clockwise: true);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}