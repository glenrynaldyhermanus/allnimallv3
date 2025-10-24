Project Brief: Allnimall - Smart QR Pet Collar Platform

1. Project Overview
   Project Name: Allnimall
   Vision: Menciptakan platform digital yang menghubungkan pemilik hewan peliharaan dengan komunitas melalui kalung kucing pintar ber-QR code. Setiap QR code tertaut ke profil online yang komprehensif, berfungsi sebagai identitas digital, catatan kesehatan, dan alat bantu saat hewan hilang.
   Core Product: Aplikasi (Web & Mobile) yang terintegrasi dengan produk fisik berupa kalung kucing akrilik dengan QR code unik.

2. Core Objective
   Membangun sebuah aplikasi cross-platform menggunakan Flutter dan Supabase yang memungkinkan pengguna untuk:

Mengaktivasi kalung QR code baru.

Membuat dan mengelola profil detail untuk hewan peliharaan mereka.

Menampilkan profil tersebut kepada siapa saja yang memindai QR code.

Melacak lokasi pindaian terakhir dan melaporkan jika hewan peliharaan hilang.

3. Target Audience
   Pemilik Kucing: Terutama yang tinggal di area urban, peduli dengan keamanan dan kesehatan kucingnya, serta aktif secara digital.

Pencinta Hewan: Orang yang mungkin menemukan kucing hilang dan ingin membantu mengembalikannya ke pemilik.

4. Key Features & Functional Requirements
   A. QR Code & Pet Profile System
   Dynamic URL: Setiap QR code akan mengarah ke URL https://allnimall.com/pets/{uuid}.

Public Pet Profile Page: Halaman ini dapat diakses publik tanpa login.

Tampilan Tab: Informasi disajikan dalam beberapa tab untuk kerapian (misal: "Biodata", "Info Kesehatan", "Galeri Foto").

Biodata: Menampilkan name, breed, birth_date, gender, color, dll.

Info Kesehatan: Menampilkan health_status, weight, catatan vaksin, alergi, dll. (Lihat bagian "Masukan Tambahan").

Galeri Foto: Menampilkan grid gambar dari picture_url atau galeri yang terhubung.

Status "HILANG": Jika dilaporkan hilang, akan ada banner atau tag yang jelas terlihat dengan pesan "KUCING HILANG" dan tombol untuk menghubungi pemilik.

B. User & Pet Onboarding (First Scan Journey)
Deteksi Kalung Baru: Sistem akan memeriksa data pet berdasarkan {uuid} dari URL. Jika pets.name adalah "Allnimall" (atau nilai dummy lainnya), sistem mengidentifikasinya sebagai kalung baru.

Redirect ke Registrasi: Pengguna akan dialihkan ke halaman https://allnimall.com/user/new?petId={uuid}.

Registrasi Pengguna via Supabase Auth:

Input: Nama Pengguna dan Nomor Telepon.

Verifikasi: Menggunakan Supabase Auth dengan OTP via SMS/WhatsApp.

Redirect ke Pembuatan Profil Pet: Setelah berhasil login/registrasi, pengguna dialihkan ke https://allnimall.com/pet/new?petId={uuid}.

Formulir Profil Pet: Pengguna mengisi semua detail kucingnya. Setelah di-submit, data di tabel pets untuk {uuid} tersebut di-update, termasuk mengubah name dari "Allnimall" menjadi nama kucing asli dan mengisi owner_id.

C. Pet & Owner Management (Setelah Login)
Dashboard Pemilik: Halaman untuk melihat semua hewan peliharaan yang terdaftar di bawah satu akun.

Edit Profil Pet: Pemilik dapat mengedit semua informasi hewan peliharaan kapan saja.

Laporan Kehilangan: Terdapat tombol "Laporkan Kucing Hilang".

Saat ditekan, status health_status atau kolom baru (misal: is_lost) di-update.

Profil publik akan otomatis menampilkan status "HILANG".

Pemilik bisa menambahkan pesan khusus (misal: "Terakhir terlihat di sekitar Taman Menteng") dan nomor kontak darurat yang akan ditampilkan.

D. Location Tracking & History
Logging Lokasi Pindaian: Setiap kali halaman https://allnimall.com/pets/{uuid} dimuat, aplikasi web/mobile harus:

Meminta izin akses lokasi (latitude, longitude) dari browser/perangkat pemindai.

Mengirimkan data lat/lng beserta {uuid} dan timestamp ke backend Supabase.

Data ini disimpan di tabel terpisah, misalnya pet_scan_logs.

Tampilan Riwayat Pindaian: Pemilik hewan (saat login) dapat melihat peta dengan pin-point lokasi-lokasi di mana QR code kucingnya pernah dipindai.

5. Technical Stack
   Frontend Framework: Flutter (untuk membangun aplikasi Web, iOS, dan Android dari satu basis kode).

Backend & Database: Supabase

Database: PostgreSQL (menggunakan skema yang sudah disediakan).

Authentication: Supabase Auth (Phone OTP).

Storage: Supabase Storage (untuk upload foto-foto hewan).

Edge Functions: Untuk logika backend seperti mencatat lokasi pindaian.

Framework : Go Router, Riverpod (dengan konsep Usecase)

6. Database Schema
   Menggunakan skema tabel pets yang telah disediakan. Disarankan menambahkan tabel baru:

SQL

CREATE TABLE public.pet_scan_logs (
id uuid NOT NULL DEFAULT gen_random_uuid(),
created_at timestamptz NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
pet_id uuid NOT NULL,
latitude numeric,
longitude numeric,
scanned_by_ip text,
user_agent text,
PRIMARY KEY (id),
FOREIGN KEY (pet_id) REFERENCES public.pets(id)
); 7. UI/UX Design Guidelines
Aesthetic: Fun, clean, modern, dan approachable.

Color Palette:

Primary: Ungu (misal: #8A2BE2 - BlueViolet)

Secondary: Pink (misal: #FF69B4 - HotPink)

Accent/Neutral: Putih, abu-abu muda, dan mungkin warna cerah lain seperti kuning atau toska untuk tombol aksi.

Micro-interactions:

Animasi halus saat memuat halaman atau data.

Efek hover atau on-press yang responsif pada tombol dan elemen interaktif.

Transisi antar tab yang mulus.

Animasi loading spinner yang custom dan menarik.

Typography: Gunakan font yang mudah dibaca dan terkesan ramah (misal: Poppins, Nunito, atau sejenisnya).

Iconography: Gunakan ikon yang konsisten dan mudah dipahami.

Masukan Tambahan untuk Pengembangan Aplikasi 💡
Berikut adalah beberapa ide tambahan untuk membuat produkmu lebih unggul dan bermanfaat:

1. Perkaya Fitur Kesehatan 🩺
   Daripada hanya status, buat tab "Kesehatan" lebih interaktif.

Log Vaksin & Obat: Pemilik bisa mencatat tanggal vaksin, obat cacing, atau pengobatan lainnya.

Jadwalkan Pengingat: Fitur untuk mengatur notifikasi push (via aplikasi) untuk jadwal vaksin berikutnya, pemberian obat, atau jadwal ke dokter hewan. Ini menambah nilai guna aplikasi secara drastis.

Upload Dokumen: Izinkan pemilik meng-upload file PDF rekam medis atau sertifikat dari dokter hewan ke Supabase Storage.

2. Peningkatan Fitur "Kucing Hilang" 😿
   Tombol "Saya Menemukan Kucing Ini": Di profil publik kucing yang hilang, tambahkan tombol ini. Tombol ini bisa membuka chat anonim dengan pemilik (menggunakan Supabase Realtime) atau mengirim notifikasi ke pemilik beserta lokasi penemu. Ini melindungi privasi kedua belah pihak.

Mode "Pencarian Aktif": Saat mode ini aktif, setiap pindaian QR akan langsung mengirimkan notifikasi real-time ke ponsel pemilik dengan tautan Google Maps ke lokasi pindaian.

3. Monetisasi & Model Bisnis 💰
   Pikirkan bagaimana proyek ini akan menghasilkan pendapatan.

Penjualan Produk Fisik: Keuntungan utama dari penjualan kalung akrilik itu sendiri.

Model Freemium:

Gratis: Semua fitur yang kamu sebutkan di atas.

Premium (Langganan Bulanan/Tahunan): Tawarkan fitur-fitur canggih seperti:

Riwayat lokasi pindaian tanpa batas (versi gratis mungkin hanya 7 hari terakhir).

Menambahkan lebih dari 2-3 hewan peliharaan.

Fitur pengingat kesehatan.

Opsi untuk membuat profil lebih kustom (tema warna, layout, dll).

4. Aspek Teknis & Keamanan 🔐
   Perlindungan Privasi: Jangan pernah menampilkan informasi pribadi pemilik (nama, no. HP, alamat) di profil publik kecuali jika hewan peliharaan dilaporkan "HILANG" dan pemilik secara eksplisit menyetujui untuk menampilkannya.

URL Shortener: Pertimbangkan menggunakan URL shortener (seperti Bitly atau custom) untuk URL di QR code. Ini membuat QR code lebih sederhana, tidak terlalu padat, dan lebih mudah dipindai, terutama jika dicetak kecil. Kamu tetap bisa me-redirect dari URL pendek ke URL panjang allnimall.com/pets/{uuid}.

Semoga brief ini sangat membantu untuk dieksekusi oleh AI atau tim developer! Sukses dengan project Allnimall-nya! 🚀
