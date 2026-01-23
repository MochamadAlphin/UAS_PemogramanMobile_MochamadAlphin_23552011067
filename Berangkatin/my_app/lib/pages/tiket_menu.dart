import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sidebar.dart'; // Import file sidebar
import 'bukti.dart'; 

class TiketMenu extends StatefulWidget {
  final String userName;

  const TiketMenu({super.key, this.userName = "PENUMPANG"});

  @override
  State<TiketMenu> createState() => _TiketMenuState();
}

class _TiketMenuState extends State<TiketMenu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SupabaseClient supabase = Supabase.instance.client;

  final Color primaryColor = const Color(0xFF2D2A70);
  final Color accentColor = const Color(0xFFED6B23);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  Future<List<Map<String, dynamic>>> _fetchTiketSaya() async {
    if (widget.userName == "TAMU") return [];

    try {
      final response = await supabase
          .from('transaksi')
          .select('''
            *,
            jadwal:id_jadwal (
              id_jadwal,
              nama_kereta,
              kelas,
              tanggal,
              jam_berangkat,
              jam_tiba,
              stasiun_asal,
              stasiun_tujuan,
              harga
            )
          ''')
          .order('tgl_beli', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("DEBUG ERROR Fetch Tiket: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isGuest = widget.userName == "TAMU";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: SideBar(userName: widget.userName),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "TIKET SAYA",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Text(
                  isGuest ? "AKSES TERBATAS" : "RIWAYAT PEMBELIAN TIKET",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: isGuest 
                ? _buildGuestLockState() 
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchTiketSaya(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: accentColor));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      final transaksiList = snapshot.data!;

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                        itemCount: transaksiList.length,
                        itemBuilder: (context, index) {
                          final trx = transaksiList[index];
                          final jadwal = trx['jadwal'] as Map<String, dynamic>? ?? {};

                          String berangkat = (jadwal['jam_berangkat'] ?? '00:00').toString();
                          String tiba = (jadwal['jam_tiba'] ?? '00:00').toString();
                          if (berangkat.length > 5) berangkat = berangkat.substring(0, 5);
                          if (tiba.length > 5) tiba = tiba.substring(0, 5);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildTicketCard(
                              context: context,
                              fullTransaksiData: trx,
                              fullJadwalData: jadwal,
                              trainName: jadwal['nama_kereta'] ?? 'KAI',
                              date: jadwal['tanggal'] ?? '-',
                              departureTime: berangkat,
                              arrivalTime: tiba,
                              origin: jadwal['stasiun_asal'] ?? '-',
                              destination: jadwal['stasiun_tujuan'] ?? '-',
                              totalPrice: (trx['total_bayar'] as num?)?.toInt() ?? 0,
                              status: trx['status'] ?? 'PENDING',
                            ),
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      // --- PENERAPAN BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavSidebar(
        currentIndex: 1, // Indeks 1 biasanya untuk Tiket/Riwayat
        userName: widget.userName,
      ),
    );
  }

  // ... (Sisa fungsi _build lainnya tetap sama seperti kode Anda)
  
  Widget _buildGuestLockState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.lock_person_rounded, size: 80, color: accentColor),
            ),
            const SizedBox(height: 24),
            Text(
              "Ups! Fitur Terkunci",
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            const SizedBox(height: 12),
            Text(
              "Silakan login terlebih dahulu untuk melihat riwayat tiket.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/loginMenu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("LOGIN SEKARANG", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                "Belum ada riwayat transaksi",
                style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard({
    required BuildContext context,
    required Map<String, dynamic> fullTransaksiData,
    required Map<String, dynamic> fullJadwalData,
    required String trainName,
    required String date,
    required String departureTime,
    required String arrivalTime,
    required String origin,
    required String destination,
    required int totalPrice,
    required String status,
  }) {
    bool isLunas = ["LUNAS", "SUCCESS", "BERHASIL"].contains(status.toUpperCase());

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trainName, 
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18, color: primaryColor)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLunas ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              color: isLunas ? Colors.green : Colors.red, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 10
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(date, 
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStationInfo(departureTime, origin, CrossAxisAlignment.start),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.train_rounded, color: accentColor, size: 24),
                          const SizedBox(height: 8),
                          _buildRouteConnector(),
                        ],
                      ),
                    ),
                    _buildStationInfo(arrivalTime, destination, CrossAxisAlignment.end),
                  ],
                ),
              ],
            ),
          ),
          _buildDashedLine(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TOTAL BAYAR", 
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey[500], letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      "Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: primaryColor)
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuktiScreen(
                          transaksi: fullTransaksiData,
                          tiket: fullJadwalData,
                          namaUser: widget.userName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                  label: const Text("E-TIKET"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationInfo(String time, String code, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: primaryColor)),
        const SizedBox(height: 2),
        Text(code, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor)),
      ],
    );
  }

  Widget _buildRouteConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Divider(color: Colors.grey[300], thickness: 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [ _buildDot(), _buildDot() ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot() => Container(
    height: 8, width: 8, 
    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: accentColor, width: 2))
  );

  Widget _buildDashedLine() {
    return Row(
      children: [
        _buildSideNotch(true),
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          return Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              (constraints.constrainWidth() / 10).floor(), 
              (index) => SizedBox(width: 5, height: 1.5, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey[300])))
            ),
          );
        })),
        _buildSideNotch(false),
      ],
    );
  }

  Widget _buildSideNotch(bool isLeft) => Container(
    height: 20, width: 10, 
    decoration: BoxDecoration(
      color: backgroundColor, 
      borderRadius: BorderRadius.only(
        topRight: isLeft ? const Radius.circular(10) : Radius.zero, 
        bottomRight: isLeft ? const Radius.circular(10) : Radius.zero, 
        topLeft: !isLeft ? const Radius.circular(10) : Radius.zero, 
        bottomLeft: !isLeft ? const Radius.circular(10) : Radius.zero
      )
    )
  );
}