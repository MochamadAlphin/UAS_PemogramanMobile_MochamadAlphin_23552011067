import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bukti.dart';

class HasilPencarian extends StatefulWidget {
  final Map<String, dynamic> tiket;
  final int penumpang;
  final DateTime tanggal;

  const HasilPencarian({
    super.key,
    required this.tiket,
    required this.penumpang,
    required this.tanggal,
  });

  @override
  State<HasilPencarian> createState() => _HasilPencarianState();
}

class _HasilPencarianState extends State<HasilPencarian> {
  final supabase = Supabase.instance.client;
  final userFirebase = FirebaseAuth.instance.currentUser;
  final TextEditingController _promoController = TextEditingController();

  int? idVoucherTerpakai;
  int potonganHarga = 0; 
  bool isPromoApplied = false;
  bool _isProcessing = false;
  List<Map<String, dynamic>> _availableVouchers = [];

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final data = await supabase
          .from('vouchers')
          .select()
          .eq('status', 'Aktif')
          .gt('kuota', 0)
          .gte('tgl_expired', today);
      
      setState(() {
        _availableVouchers = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint("Error fetch voucher: $e");
    }
  }

  Future<int?> _getSupabaseUserId() async {
    if (userFirebase?.email == null) return null;
    try {
      final userData = await supabase
          .from('users') 
          .select('id_user')
          .eq('email', userFirebase!.email!)
          .maybeSingle();
      
      return userData != null ? userData['id_user'] as int : null;
    } catch (e) {
      debugPrint("Error mencari ID User: $e");
      return null;
    }
  }

  Future<void> _applyPromoManual() async {
    final kode = _promoController.text.trim();
    if (kode.isEmpty) return;
    
    setState(() => _isProcessing = true);
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final voucherData = await supabase
          .from('vouchers')
          .select()
          .eq('kode_voucher', kode)
          .eq('status', 'Aktif')
          .gt('kuota', 0)
          .gte('tgl_expired', today)
          .maybeSingle();

      if (voucherData != null) {
        _setVoucher(voucherData);
      } else {
        _resetPromo("Voucher tidak valid atau sudah habis.");
      }
    } catch (e) {
      _resetPromo("Gagal mengecek voucher.");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _setVoucher(Map<String, dynamic> v) {
    setState(() {
      idVoucherTerpakai = v['id_voucher'] as int;
      potonganHarga = (v['potongan_harga'] as num).toInt();
      isPromoApplied = true;
      _promoController.text = v['kode_voucher'];
    });
    _showSnackbar("Voucher Berhasil Dipasang!", Colors.green);
  }

  void _resetPromo(String message) {
    setState(() {
      idVoucherTerpakai = null;
      potonganHarga = 0;
      isPromoApplied = false;
    });
    _showSnackbar(message, Colors.red);
  }

  Future<void> _prosesBayar() async {
    if (userFirebase == null) {
      _showSnackbar("Silakan login terlebih dahulu.", Colors.red);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final int? realUserId = await _getSupabaseUserId();
      
      if (realUserId == null) {
        throw "User belum terdaftar di tabel users database.";
      }

      final int idJadwal = int.parse(widget.tiket['id_jadwal'].toString());

      final int hargaSatuan = (widget.tiket['harga'] as num).toInt();
      final int hargaAsli = hargaSatuan * widget.penumpang;
      final int totalBayarCalculated = hargaAsli - potonganHarga;

      final Map<String, dynamic> dataTransaksi = {
        'id_user': realUserId, // bigint
        'id_jadwal': idJadwal, // bigint
        'id_voucher': idVoucherTerpakai, // bigint (nullable)
        'harga_asli': hargaAsli, // bigint
        'total_bayar': totalBayarCalculated < 0 ? 0 : totalBayarCalculated, // bigint
        'status': 'lunas', // text
        'tgl_beli': DateTime.now().toIso8601String(), // timestamptz
        'penumpang': widget.penumpang, // numeric
      };

      final response = await supabase
          .from('transaksi')
          .insert(dataTransaksi)
          .select()
          .single();

      if (idVoucherTerpakai != null) {
        final vData = await supabase.from('vouchers').select('kuota').eq('id_voucher', idVoucherTerpakai!).single();
        await supabase.from('vouchers').update({'kuota': (vData['kuota'] as int) - 1}).eq('id_voucher', idVoucherTerpakai!);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BuktiScreen(
              transaksi: response,
              tiket: widget.tiket,
              namaUser: userFirebase?.displayName ?? userFirebase?.email ?? "Pelanggan",
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("DB_ERROR_DETAIL: $e");
      _showSnackbar("Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 3))
    );
  }

  @override
  Widget build(BuildContext context) {
    final int hargaAsli = (widget.tiket['harga'] as num).toInt() * widget.penumpang;
    final int totalBayar = hargaAsli - potonganHarga;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Konfirmasi Pesanan", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserBanner(),
                  const SizedBox(height: 20),
                  Text("Detail Tiket", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _buildTiketCard(),
                  const SizedBox(height: 25),
                  _buildVoucherSection(),
                  const SizedBox(height: 25),
                  Text("Rincian Harga", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _buildRincianHarga(hargaAsli, totalBayar.toDouble()),
                  const SizedBox(height: 30),
                  _buildButtonBayar(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.blue.shade100)
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.person, color: Colors.blue)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kontak Pemesan", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(userFirebase?.email ?? 'Tamu', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTiketCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.tiket['nama_kereta'] ?? "Kereta Api", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                child: Text(widget.tiket['kelas'] ?? "Eksekutif", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStationText(widget.tiket['stasiun_asal'] ?? "Asal", widget.tiket['jam_berangkat'] ?? "--:--", CrossAxisAlignment.start),
              const Icon(Icons.swap_horiz, color: Colors.orange, size: 30),
              _buildStationText(widget.tiket['stasiun_tujuan'] ?? "Tujuan", widget.tiket['jam_tiba'] ?? "--:--", CrossAxisAlignment.end),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoKecil(Icons.calendar_today, DateFormat('dd MMM yyyy').format(widget.tanggal)),
              _infoKecil(Icons.event_seat, "Kursi: ${widget.tiket['no_kursi'] ?? 'A1'}"),
              _infoKecil(Icons.people, "${widget.penumpang} Orang"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVoucherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Voucher Promo", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: _showVoucherPicker, 
              child: const Text("Lihat Semua", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
            )
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                decoration: InputDecoration(
                  hintText: "Masukkan kode promo...",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _applyPromoManual,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2150), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
              ),
              child: const Text("Klaim", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  void _showVoucherPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Pilih Voucher Tersedia", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              if (_availableVouchers.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text("Tidak ada voucher aktif")),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _availableVouchers.map((v) => ListTile(
                    leading: const Icon(Icons.confirmation_number, color: Colors.orange),
                    title: Text(v['kode_voucher'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Potongan Rp ${NumberFormat('#,###').format(v['potongan_harga'])}"),
                    onTap: () {
                      _setVoucher(v);
                      Navigator.pop(context);
                    },
                  )).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  Widget _buildRincianHarga(int asli, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _priceRow("Harga Tiket (x${widget.penumpang})", "Rp ${NumberFormat('#,###').format(asli)}"),
          if (isPromoApplied) _priceRow("Potongan Promo", "- Rp ${NumberFormat('#,###').format(potonganHarga)}", isGreen: true),
          const Divider(height: 30),
          _priceRow("Total Pembayaran", "Rp ${NumberFormat('#,###').format(total)}", isBold: true),
        ],
      ),
    );
  }

  Widget _buildStationText(String name, String time, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(time, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _infoKecil(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 14),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }

  Widget _priceRow(String label, String val, {bool isGreen = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? Colors.black : Colors.grey[600], fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(val, style: TextStyle(color: isGreen ? Colors.green : Colors.black, fontWeight: FontWeight.bold, fontSize: isBold ? 18 : 14)),
      ],
    );
  }

  Widget _buildButtonBayar() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _prosesBayar,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2150), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: const Text("Konfirmasi & Bayar Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}