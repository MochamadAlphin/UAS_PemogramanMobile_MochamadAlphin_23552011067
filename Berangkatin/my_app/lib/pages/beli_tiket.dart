import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BeliTiket extends StatefulWidget {
  final String asal;
  final String tujuan;
  final String kelas;
  final String tanggal;

  const BeliTiket({
    super.key,
    required this.asal,
    required this.tujuan,
    required this.kelas,
    required this.tanggal,
  });

  @override
  State<BeliTiket> createState() => _BeliTiketState();
}

class _BeliTiketState extends State<BeliTiket> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _jadwalTersedia = [];

  @override
  void initState() {
    super.initState();
    _fetchJadwal();
  }

  Future<void> _fetchJadwal() async {
    try {
      final data = await supabase
          .from('jadwal')
          .select()
          .eq('stasiun_asal', widget.asal)
          .eq('stasiun_tujuan', widget.tujuan)
          .eq('kelas', widget.kelas);

      setState(() {
        _jadwalTersedia = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error Fetching Jadwal: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2D2A70);
    const Color accentColor = Color(0xFFED6B23);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.asal} → ${widget.tujuan}",
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("${widget.tanggal} • ${widget.kelas}",
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jadwalTersedia.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _jadwalTersedia.length,
                  itemBuilder: (context, index) {
                    final jadwal = _jadwalTersedia[index];
                    return _buildTicketCard(jadwal, primaryColor, accentColor);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.train_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text("Jadwal Tidak Ditemukan",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Coba pilih rute atau kelas lain"),
        ],
      ),
    );
  }

  Widget _buildTicketCard(dynamic item, Color primary, Color accent) {
    final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    
    final double harga = (item['harga'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: () => _konfirmasiPemesanan(item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['nama_kereta'] ?? "Kereta Api",
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: primary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                    child: Text(item['kelas'], style: TextStyle(fontSize: 10, color: primary, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _timeColumn(item['jam_berangkat'], "Asal"),
                  const Icon(Icons.arrow_right_alt, color: Colors.grey),
                  _timeColumn(item['jam_tiba'], "Tujuan"),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(currencyFormatter.format(harga),
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: accent)),
                  Text("Pilih", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: primary)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeColumn(String time, String label) {
    return Column(
      children: [
        Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _konfirmasiPemesanan(dynamic jadwal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Konfirmasi Tiket", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text("Apakah anda yakin ingin memesan kereta ${jadwal['nama_kereta']}?"),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFED6B23), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("YA, LANJUTKAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}