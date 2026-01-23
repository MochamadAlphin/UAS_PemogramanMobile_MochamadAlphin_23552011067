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
Halaman Awal  
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

## Tampilan Aplikasi

Halaman Awal

<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/222477f2-649c-442b-a63f-fe85b1ac74cd" />

Masuk Tanpa Login

<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/b3485770-491c-4832-92a6-f01f9ab09409" />
<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/9f9ecb6f-d0ba-4804-aee9-a7ee68dafaa8" />

Autentifikasi diwajibkan login


Login / Register

<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/420a8611-cca7-46c7-8e9d-1995792c8593" />
<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/4198b791-e9b5-4eed-921a-ca9e29c77e31" />

Yang Lainnya 

<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/67dc4d3b-1415-41ff-bde2-05edf734e790" />
<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/3889c0b8-493e-436b-b4a3-ee6186544046" />
<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/2f1e0d2e-cdaf-43b7-9453-7d6b2caaa70f" />
<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/0d0ab214-0bad-4784-bbb0-813e46164f81" />
<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/aeaed0d8-657e-476b-a6f6-89179247431a" />
<img width="404" height="853" alt="image" src="https://github.com/user-attachments/assets/b9620af9-9763-4524-86dd-6eefcb963774" />

## Demo Aplikasi 

![Recording 2026-01-22 095922](https://github.com/user-attachments/assets/056113b8-baad-4f39-adfc-04a17a8607fc)

## Animasi / Transisi

![Recording 2026-01-24 014245](https://github.com/user-attachments/assets/772a6f66-cee3-4218-983d-e3cb25021bca)

---

## Database yang Digunakan

- **Firebase Authentication**  
  Digunakan untuk proses login dan register pengguna

- **Supabase**  
  Digunakan untuk menyimpan data pengguna, jadwal, users, transaksi

---

## Tautan Proyek 
https://berangkatin.netlify.app/  

---

##  Pengembang

- Nama        : *Mochamad Alphin*
- NIM         : *23552011067*  
- Mata Kuliah : Pemrograman Mobile II
- Dosen Pengampu : Muhammad Ikhwan Fathulloh, S.Kom.
