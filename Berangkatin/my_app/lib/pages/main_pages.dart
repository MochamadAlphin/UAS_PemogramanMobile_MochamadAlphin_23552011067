import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPagesWidget extends StatefulWidget {
  const MainPagesWidget({super.key});

  @override
  State<MainPagesWidget> createState() => _MainPagesWidgetState();
}

class _MainPagesWidgetState extends State<MainPagesWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TapGestureRecognizer _registerTapRecognizer;

  final Color primaryColor = const Color(0xFF2D2A70);
  final Color orangeAccent = const Color(0xFFED6B23);

  @override
  void initState() {
    super.initState();
    _registerTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushNamed(context, '/registerMenu');
      };
  }

  @override
  void dispose() {
    _registerTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 670),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/Background.jpg'),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white,
                          ],
                          stops: const [0, 1],
                          begin: const AlignmentDirectional(0, -1),
                          end: const AlignmentDirectional(0, 1),
                        ),
                      ),
                      alignment: const AlignmentDirectional(0, 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'BERA',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 42,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'NGK',
                                    style: TextStyle(
                                      color: orangeAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 42,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'ATIN',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 42,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Booking Elektronik & Reservasi Angkutan Kereta Indonesia',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                color: Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 50),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/loginMenu');
                          },
                          icon: const Icon(Icons.login_rounded, color: Colors.white),
                          label: const Text('Masuk Berangkatin'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Atau Kamu Mau',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
      
                            Navigator.pushNamed(
                              context,
                              '/MenuAwal',
                              arguments: 'TAMU',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orangeAccent,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          child: const Text('Masuk Tanpa Daftar'),
                        ),
                      ),

                      const SizedBox(height: 25),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: 'Belum Punya Akun?? '),
                            TextSpan(
                              text: 'Silahkan Daftar!',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: _registerTapRecognizer,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}