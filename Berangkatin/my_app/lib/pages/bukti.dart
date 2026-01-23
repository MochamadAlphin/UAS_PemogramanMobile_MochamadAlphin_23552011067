import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BuktiScreen extends StatelessWidget {
  final Map<String, dynamic> transaksi;
  final Map<String, dynamic> tiket;
  final String namaUser;

  const BuktiScreen({
    super.key,
    required this.transaksi,
    required this.tiket,
    required this.namaUser,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    
    String jamBerangkat = (tiket['jam_berangkat'] ?? '00:00').toString();
    String jamTiba = (tiket['jam_tiba'] ?? '00:00').toString();
    if (jamBerangkat.length > 5) jamBerangkat = jamBerangkat.substring(0, 5);
    if (jamTiba.length > 5) jamTiba = jamTiba.substring(0, 5);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Background gelap elegan
      appBar: AppBar(
        title: Text("E-Ticket Resmi", 
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context), // Kembali ke daftar tiket
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
        
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
        
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 70),
                        const SizedBox(height: 12),
                        Text("Tiket Terkonfirmasi", 
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 20, color: const Color(0xFF0F172A))),
                        Text("Order ID: #TRX-${transaksi['id_transaksi'] ?? 'N/A'}", 
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),

  
                  const _TicketDivider(),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _stationInfo(tiket['stasiun_asal'] ?? '-', jamBerangkat, "Asal"),
                            const Icon(Icons.train, color: Color(0xFF1E293B), size: 28),
                            _stationInfo(tiket['stasiun_tujuan'] ?? '-', jamTiba, "Tujuan"),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Divider(color: Color(0xFFF1F5F9), thickness: 2),
                        const SizedBox(height: 15),
                        
                        _gridInfo("Nama Penumpang", namaUser, Icons.person_outline),
                        _gridInfo("Nama Kereta", "${tiket['nama_kereta'] ?? 'KAI'} (${tiket['kelas'] ?? '-'})", Icons.directions_railway_filled_outlined),
                        _gridInfo("Jumlah Penumpang", "${transaksi['penumpang'] ?? '1'} Orang", Icons.people_outline),
                        _gridInfo("Tanggal Keberangkatan", tiket['tanggal'] ?? '-', Icons.calendar_today_outlined),
                      ],
                    ),
                  ),

                  const _TicketDivider(),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Bayar", style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                            Text(formatCurrency.format(transaksi['total_bayar'] ?? 0), 
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 22, color: const Color(0xFF1E2150))),
                          ],
                        ),
                        const SizedBox(height: 30),
                        
                        Container(
                          height: 70,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://bwipjs-api.metafloor.com/?bcid=code128&text=KAI-${transaksi['id_transaksi']}&includetext&height=10"),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("Tunjukkan barcode ini kepada petugas stasiun", 
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text("Kembali ke Daftar Tiket", 
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _stationInfo(String city, String time, String label) {
    return Column(
      crossAxisAlignment: label == "Asal" ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        Text(city, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _gridInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[500])),
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketDivider extends StatelessWidget {
  const _TicketDivider();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: List.generate(20, (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 2,
              color: index.isEven ? Colors.grey[200] : Colors.transparent,
            ),
          )),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _notch(true),
            _notch(false),
          ],
        )
      ],
    );
  }

  Widget _notch(bool left) => Container(
    height: 20, width: 10,
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.only(
        topRight: left ? const Radius.circular(10) : Radius.zero, 
        bottomRight: left ? const Radius.circular(10) : Radius.zero,
        topLeft: !left ? const Radius.circular(10) : Radius.zero,
        bottomLeft: !left ? const Radius.circular(10) : Radius.zero,
      ),
    ),
  );
}