# BERANGKATIN
## Booking Elektronik & Reservasi Angkutan Kereta Indonesia

**BERANGKATIN** adalah aplikasi **mobile Android berbasis Flutter** untuk pemesanan tiket kereta api.  
Aplikasi ini memungkinkan pengguna untuk mencari jadwal kereta, memesan tiket, memilih kursi, melakukan simulasi pembayaran, serta menyimpan tiket secara digital.

---

## Tujuan Proyek

Tujuan dari pengembangan aplikasi **BERANGKATIN** adalah:

- Menerapkan pengembangan aplikasi mobile menggunakan **Flutter**
- Mengimplementasikan **REST API** (menggunakan Mock API)
- Menggunakan **Firebase** untuk autentikasi dan database
- Melakukan **deployment aplikasi mobile**

---

## Fitur Mobile Application

### Autentikasi
- Halaman Login
- Halaman Register
- Validasi input pengguna
- Penyimpanan status login pengguna

### Beranda
- Input stasiun asal dan stasiun tujuan
- Pemilihan tanggal keberangkatan
- Tombol pencarian jadwal kereta

### Daftar Jadwal Kereta
- Menampilkan daftar jadwal kereta
- Informasi waktu keberangkatan, harga, dan kelas kereta
- Navigasi ke halaman detail jadwal

### Pemilihan Kursi
- Tampilan layout kursi kereta
- Pemilihan kursi yang tersedia
- Penyimpanan data kursi yang dipilih

### Pembayaran
- Ringkasan detail pemesanan
- Simulasi proses pembayaran
- Status pembayaran (berhasil / gagal)

### Tiket Digital
- Menampilkan tiket elektronik
- Detail perjalanan kereta
- Informasi kursi dan jadwal

### Profil
- Menampilkan informasi pengguna
- Logout dari aplikasi

---

## Alur Aplikasi (Mobile Flow)
Splash Screen
↓
Login / Register
↓
Home (Cari Jadwal)
↓
Daftar Jadwal Kereta
↓
Detail Jadwal & Pilih Kursi
↓
Pembayaran
↓
Tiket Digital

## Firebase yang Digunakan

- **Firebase Authentication**  
  Digunakan untuk proses login dan register pengguna

- **Firebase Firestore**  
  Digunakan untuk menyimpan data pengguna dan data tiket

---

## 👨‍💻 Pengembang

- Nama        : *Mochamad Alphin*
- NIM         : *23552011067*  
- Mata Kuliah : Pemrograman Mobile II
- Dosen Pengampu : Muhammad Ikhwan Fathulloh, S.Kom.
