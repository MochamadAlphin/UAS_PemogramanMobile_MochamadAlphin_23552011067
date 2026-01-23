import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginMenu extends StatefulWidget {
  const LoginMenu({super.key});

  @override
  State<LoginMenu> createState() => _LoginMenuState();
}

class _LoginMenuState extends State<LoginMenu> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF2D2A70);

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Mohon lengkapi email dan password");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null && mounted) {
        final String uid = userCredential.user!.uid;
        _showSnackBar("Login Berhasil! Selamat Datang.");
        
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/MenuAwal', 
          (route) => false,
          arguments: uid, 
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Terjadi kesalahan";
      switch (e.code) {
        case 'user-not-found': errorMessage = "Akun tidak ditemukan."; break;
        case 'wrong-password': errorMessage = "Password salah."; break;
        case 'invalid-credential': errorMessage = "Email atau Password salah."; break;
        default: errorMessage = e.message ?? "Login Gagal";
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar("Gagal terhubung ke server");
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
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        "BERANGKATIN",
                        style: GoogleFonts.plusJakartaSans(
                          color: primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        "Silakan masuk untuk melanjutkan perjalanan",
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                _buildFadeIn(
                  delay: 1.5,
                  child: _buildLoginCard(),
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
    return Hero(
      tag: 'logo',
      child: Container(
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
      ),
    );
  }

  Widget _buildLoginCard() {
    return ClipPath(
      clipper: TicketClipper(),
      child: Container(
        width: double.infinity,
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("BOARDING PASS", 
                        style: GoogleFonts.plusJakartaSans(
                          color: primaryColor, 
                          fontWeight: FontWeight.w800, 
                          fontSize: 12
                        )
                      ),
                      Icon(Icons.airplane_ticket_outlined, color: primaryColor, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "ALAMAT EMAIL",
                    controller: _emailController,
                    icon: Icons.mail_outline_rounded,
                    hint: "contoh@email.com",
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "KATA SANDI",
                    controller: _passwordController,
                    icon: Icons.lock_outline_rounded,
                    hint: "••••••••",
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading 
          ? const SizedBox(height: 20, width: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("MASUK SEKARANG", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.grey[50],
      child: Column(
        children: [
          Text("Belum punya akun?", 
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/registerMenu'),
            child: Text("BUAT AKUN BARU", 
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: primaryColor
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, 
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10, 
            fontWeight: FontWeight.bold, 
            color: Colors.grey[500]
          )
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: primaryColor, size: 20),
            suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, 
                    size: 20, color: Colors.grey),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
            filled: true,
            fillColor: Colors.grey[50],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = 12.0;
    double clipPosition = size.height * 0.72; 
    path.lineTo(0, clipPosition);
    path.arcToPoint(Offset(0, clipPosition + (radius * 2)), 
        radius: Radius.circular(radius), clockwise: true);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, clipPosition + (radius * 2));
    path.arcToPoint(Offset(size.width, clipPosition), 
        radius: Radius.circular(radius), clockwise: true);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}