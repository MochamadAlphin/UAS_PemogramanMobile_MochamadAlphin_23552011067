import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'sidebar.dart';

class Voucher {
  final int idVoucher;
  final String kodeVoucher;
  final int potonganHarga;
  final int kuota;
  final String tglExpired;
  final String status;
  final String imagePath;

  Voucher({
    required this.idVoucher,
    required this.kodeVoucher,
    required this.potonganHarga,
    required this.kuota,
    required this.tglExpired,
    required this.status,
    required this.imagePath,
  });

  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      idVoucher: map['id_voucher'] ?? 0,
      kodeVoucher: map['kode_voucher'] ?? '-',
      potonganHarga: map['potongan_harga'] ?? 0,
      kuota: map['kuota'] ?? 0,
      tglExpired: map['tgl_expired'] ?? '-',
      status: map['status'] ?? 'Unknown',
      imagePath: 'assets/images/promo1.jpg', 
    );
  }
}

class PromoPage extends StatefulWidget {
  final String userName;
  const PromoPage({super.key, this.userName = "PENUMPANG"});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  final Color primaryColor = const Color(0xFF2D2A70);
  final Color accentColor = const Color(0xFFED6B23);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  final supabase = Supabase.instance.client;
  List<Voucher> _vouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    try {
      setState(() => _isLoading = true);
      
      final data = await supabase
          .from('vouchers')
          .select()
          .order('id_voucher', ascending: true);

      if (mounted) {
        setState(() {
          _vouchers = (data as List).map((v) => Voucher.fromMap(v)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetching Vouchers: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String formatRupiah(int amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: SideBar(userName: widget.userName),
      appBar: AppBar(
        title: Text(
          "VOUCHER SAYA",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fetchVouchers,
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: _buildWelcomeHeader(),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: accentColor))
                : _vouchers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchVouchers,
                        color: accentColor,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                          itemCount: _vouchers.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _vouchers.length) return _buildFooterNote();
                            return _buildHorizontalPromoCard(context, _vouchers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavSidebar(
        currentIndex: 2,
        userName: widget.userName,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text("Belum ada voucher tersedia", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Klaim Voucher Anda",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Gunakan kode di bawah untuk potongan harga.",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalPromoCard(BuildContext context, Voucher v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: SizedBox(
                width: 120,
                child: Image.asset(
                  v.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.confirmation_number, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusBadge(v.status),
                            Text(
                              formatRupiah(v.potonganHarga),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Voucher Perjalanan",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Sisa: ${v.kuota} • Exp: ${v.tglExpired}",
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryColor.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              v.kodeVoucher,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: v.kodeVoucher));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Kode ${v.kodeVoucher} disalin!"),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            },
                            child: Text(
                              "SALIN",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green.withOpacity(0.2))),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: Colors.green[700], fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Divider(color: Colors.grey[300], indent: 80, endIndent: 80),
          const SizedBox(height: 10),
          Text(
            "Promo resmi E-Ticket Kereta Api.\nSyarat & Ketentuan berlaku.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }
}