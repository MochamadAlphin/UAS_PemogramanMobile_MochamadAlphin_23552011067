import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SideBar extends StatelessWidget {
  final String userName;
  
  // Constructor sudah benar, tapi saat dipanggil di menu_awal harus diberi data
  const SideBar({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E2150), Color(0xFF141633)],
              ),
            ),
            accountName: Text(
              userName,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold, 
                fontSize: 18,
                color: Colors.white
              ),  
            ),
            accountEmail: const Text(
              "Penumpang Setia Kereta Api", 
              style: TextStyle(color: Colors.white70)
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF1E2150), size: 40),
            ),
          ),
          _buildListTile(context, Icons.home_outlined, "Beranda", '/menuAwal'),
          _buildListTile(context, Icons.airplane_ticket_outlined, "Tiket Saya", '/tiketMenu'),
          _buildListTile(context, Icons.local_offer_outlined, "Promo Menarik", '/promo'),
          _buildListTile(context, Icons.person_outline_rounded, "Profil Saya", '/profile'),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: Text(
              "Keluar Akun", 
              style: GoogleFonts.plusJakartaSans(color: Colors.red, fontWeight: FontWeight.bold)
            ),
            onTap: () {
              // Pastikan route '/loginMenu' sudah terdaftar di main.dart
              Navigator.pushNamedAndRemoveUntil(context, '/loginMenu', (route) => false);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E2150)),
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
      onTap: () {
        Navigator.pop(context); // Tutup drawer
        // Mengirimkan userName kembali ke route tujuan agar data tidak hilang
        Navigator.pushReplacementNamed(context, routeName, arguments: userName);
      },
    );
  }
}

class BottomNavSidebar extends StatelessWidget {
  final int currentIndex;
  final String userName;

  const BottomNavSidebar({super.key, required this.currentIndex, required this.userName});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF1E2150),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
      onTap: (index) {
        if (index == currentIndex) return;
        List<String> routes = ['/MenuAwal', '/tiketMenu', '/promo', '/profile'];
        Navigator.pushReplacementNamed(context, routes[index], arguments: userName);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Pesan"),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: "Tiket"),
        BottomNavigationBarItem(icon: Icon(Icons.local_offer_outlined), label: "Promo"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
      ],
    );
  }
}