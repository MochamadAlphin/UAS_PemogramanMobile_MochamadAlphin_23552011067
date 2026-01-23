import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:intl/intl.dart';
import 'sidebar.dart'; 
import 'hasil_pencarian.dart'; 
import 'promo.dart'; 

class MenuAwal extends StatefulWidget {
  const MenuAwal({super.key});

  @override
  State<MenuAwal> createState() => _MenuAwalState();
}

class _MenuAwalState extends State<MenuAwal> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final user = FirebaseAuth.instance.currentUser;
  final supabase = sb.Supabase.instance.client;

  final Color primaryColor = const Color(0xFF1E2150);
  final Color accentColor = const Color(0xFFFB8C00);
  final Color bgColor = const Color(0xFFF8FAFC);

  String _userName = "MEMUAT..."; 
  bool _isLoading = true; 
  bool _isSearching = false; 
  bool _isGuest = false; 

  String kelasDipilih = "Ekonomi"; 
  DateTime tanggalPergi = DateTime.now();
  int jumlahPenumpang = 1;

  final List<String> daftarKelas = ["Ekonomi", "Premium", "Eksekutif"];
  List<dynamic> listTiket = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initData());
  }

  Future<void> _initData() async {
    if (!mounted) return;

    _cariTiket();

    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args == 'TAMU') {
      setState(() {
        _isGuest = true;
        _userName = "TAMU";
        _isLoading = false;
        kelasDipilih = "Ekonomi";
      });
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      if (user != null) {
        final userData = await supabase
            .from('users')
            .select('nama')
            .eq('id_user', user!.uid)
            .maybeSingle();
        
        if (mounted) {
          setState(() {
            if (userData != null && userData['nama'] != null && userData['nama'].toString().isNotEmpty) {
              _userName = userData['nama'].toString().toUpperCase();
            } else {
              _userName = (user?.displayName ?? user?.email?.split('@')[0] ?? "USER").toUpperCase();
            }
          });
        }
      } else {
        setState(() => _userName = "GUEST");
      }
      
    } catch (e) {
      debugPrint("Error Initial Load: $e");
      if (mounted) {
        setState(() => _userName = (user?.displayName ?? "USER").toUpperCase());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cariTiket() async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    
    try {
      final response = await supabase
          .from('jadwal')
          .select()
          .eq('kelas', kelasDipilih)
          .order('jam_berangkat', ascending: true);

      if (mounted) {
        setState(() {
          listTiket = response;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint("Search Error: $e");
      if (mounted) {
        setState(() {
          listTiket = [];
          _isSearching = false;
        });
      }
    }
  }

  void _handleBooking(dynamic tiket) {
    if (_isGuest) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Akses Terbatas"),
          content: const Text("Silahkan daftar atau login terlebih dahulu untuk memesan tiket."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/loginMenu', (route) => false),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text("Login"),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HasilPencarian(
        tiket: tiket,
        penumpang: jumlahPenumpang,
        tanggal: tanggalPergi,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideBar(userName: _userName),
      backgroundColor: bgColor,
      bottomNavigationBar: BottomNavSidebar(currentIndex: 0, userName: _userName),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : RefreshIndicator(
              onRefresh: _initData,
              color: accentColor,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildHeader(),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildSectionTitle("Jadwal $kelasDipilih Hari Ini"),
                        _buildTiketList(),
                        _buildSectionTitle("Promo Spesial"),
                        _buildPromoSlider(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_isGuest ? "Selamat Datang," : "Mau kemana hari ini?", 
                        style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14)),
                      Text(_userName, 
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildFilterForm(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildKelasSelector(),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCompactInput(Icons.calendar_month, "Tanggal", 
                  DateFormat('dd MMM').format(tanggalPergi), 
                  () async {
                    DateTime? picked = await showDatePicker(
                      context: context, initialDate: tanggalPergi,
                      firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (picked != null) {
                      setState(() => tanggalPergi = picked);
                      _cariTiket();
                    }
                  }),
              ),
              const VerticalDivider(),
              Expanded(
                child: _buildCompactInput(Icons.group, "Penumpang", "$jumlahPenumpang Orang", 
                  () => setState(() => jumlahPenumpang = (jumlahPenumpang < 4) ? jumlahPenumpang + 1 : 1)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKelasSelector() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daftarKelas.length,
        itemBuilder: (context, index) {
          bool isSelected = kelasDipilih == daftarKelas[index];
          return GestureDetector(
            onTap: () {
              setState(() => kelasDipilih = daftarKelas[index]);
              _cariTiket();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(daftarKelas[index], 
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? Colors.white : Colors.black54, 
                  fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactInput(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey)),
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTiketList() {
    if (_isSearching && listTiket.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()));
    }
    
    if (listTiket.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.train_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("Jadwal $kelasDipilih tidak tersedia", 
              style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listTiket.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final tiket = listTiket[index];
        final hargaFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(tiket['harga']);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tiket['nama_kereta'] ?? "KAI", 
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                    Text(hargaFormat,
                      style: GoogleFonts.plusJakartaSans(color: accentColor, fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _routeNode(tiket['jam_berangkat'], tiket['stasiun_asal']),
                    Icon(Icons.arrow_forward_rounded, color: accentColor.withOpacity(0.4)),
                    _routeNode(tiket['jam_tiba'], tiket['stasiun_tujuan'], isEnd: true),
                  ],
                ),
                const Divider(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _handleBooking(tiket),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Pesan Sekarang", 
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _routeNode(String time, String station, {bool isEnd = false}) {
    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(time, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor)),
        Text(station, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: primaryColor)),
          Text("Lihat Semua", style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPromoSlider() {
    return SizedBox(
      height: 160, 
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _promoCard('assets/images/promo2.jpg'),
        ],
      ),
    );
  }

  Widget _promoCard(String assetPath) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PromoPage()),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85, 
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(assetPath), 
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}