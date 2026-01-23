import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sidebar.dart'; 
import 'main_pages.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  const ProfilePage({super.key, this.userName = "PENUMPANG"});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final Color primaryColor = const Color(0xFF2D2A70);
  final Color accentColor = const Color(0xFFED6B23);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color errorColor = const Color(0xFFE53935); 

  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchProfileByEmail();
  }

  Future<void> _fetchProfileByEmail() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final firebase.User? currentUser = firebase.FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.email != null) {
        final String userEmail = currentUser.email!.toLowerCase().trim();
        
        final data = await supabase
            .from('users')
            .select()
            .eq('email', userEmail)
            .maybeSingle();

        if (mounted) {
          setState(() {
            _userData = data;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error Fetch Data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatGender(String? genderCode) {
    if (genderCode == null) return "-";
    if (genderCode.toUpperCase() == 'L') return "Laki-laki";
    if (genderCode.toUpperCase() == 'P') return "Perempuan";
    return genderCode;
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = _userData?['nama'] ?? widget.userName;
    final String userId = _userData?['id_user']?.toString() ?? "-";

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: SideBar(userName: displayName),
      

      bottomNavigationBar: BottomNavSidebar(
        currentIndex: 3, 
        userName: displayName,
      ),

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fetchProfileByEmail,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: "Refresh Data",
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : _userData == null
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchProfileByEmail,
                  color: accentColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildModernHeader(displayName, userId),
                        
                        const SizedBox(height: 20),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildInfoTile(Icons.badge_outlined, "Nomor Induk Kependudukan (NIK)", _userData?['nik'] ?? "-"),
                              _buildInfoTile(Icons.email_outlined, "Alamat Email", _userData?['email'] ?? "-"),
                              _buildInfoTile(Icons.phone_iphone_rounded, "Nomor Telepon", _userData?['telp'] ?? "-"),
                              _buildInfoTile(Icons.wc_rounded, "Jenis Kelamin", _formatGender(_userData?['gender'])),
                              
                              const SizedBox(height: 30),
                              
              
                              _buildLogoutButton(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }


  Widget _buildModernHeader(String name, String id) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            image: const DecorationImage(
              image: NetworkImage("https://www.transparenttextures.com/patterns/cubes.png"),
              opacity: 0.1,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "P",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40, 
                      fontWeight: FontWeight.bold, 
                      color: primaryColor
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                name.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "ID: $id",
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, 
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, 
                    color: Colors.black87, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _showLogoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: errorColor,
          elevation: 0,
          side: BorderSide(color: errorColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: errorColor),
            const SizedBox(width: 10),
            Text(
              "KELUAR AKUN",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            "Data Profil Tidak Ditemukan",
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchProfileByEmail,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Konfirmasi Keluar", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await firebase.FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPagesWidget()),
                  (route) => false,
                );
              }
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}