# 📘 Tulish (Tuning English)

Tulish adalah **aplikasi kamus Bahasa Inggris berbasis Android yang bekerja 100% offline**, dikembangkan menggunakan **Flutter** dan **SQLite**. Aplikasi ini dirancang untuk membantu pelajar dan mahasiswa dalam mempelajari kosakata Bahasa Inggris secara cepat, ringan, dan tanpa ketergantungan koneksi internet.

Repositori ini dibuat sebagai bagian dari proyek akademik mata kuliah **Pengembangan Aplikasi Mobile**.

---

## 🎯 Tujuan Aplikasi

* Menyediakan kamus Bahasa Inggris **tanpa koneksi internet**
* Membantu pembelajaran kosakata secara mandiri
* Memberikan pengalaman belajar yang cepat, responsif, dan personal
* Menghilangkan ketergantungan kuota internet dalam belajar

---

## ✨ Fitur Utama

### 🔍 Pencarian Kata

* Pencarian kata secara **real-time**
* Case-insensitive search
* Menampilkan hingga 50 hasil paling relevan
* Waktu respon < 200 ms

### 📖 Detail Kata

* Kata dan jenis kata (part of speech)
* Definisi lengkap
* Contoh penggunaan
* Sinonim dan antonim (jika tersedia)

### 🕘 Riwayat Pencarian

* Menyimpan kata yang pernah dicari secara otomatis
* Urut dari terbaru ke terlama
* Maksimal 500 riwayat (FIFO)
* Fitur hapus riwayat

### ⭐ Bookmark

* Tandai kata favorit
* Toggle bookmark on/off
* Daftar bookmark terpisah
* Tidak ada duplikasi kata

### 🔊 Text-to-Speech (Opsional)

* Pronunciasi kata menggunakan TTS bawaan Android
* Penanganan jika TTS tidak tersedia

### ➕ Custom Words (Opsional)

* Tambah kosakata pribadi
* Edit dan hapus kata custom
* Kata custom muncul di hasil pencarian

### 📤 Import / Export Data (Opsional)

* Export bookmark & custom words ke CSV / JSON
* Import data dari file backup
* Validasi format & handling duplikasi

### 📝 Mini Quiz (Opsional)

* Quiz dari kata acak atau bookmark
* Multiple choice / fill-in-the-blank
* Skor dan review jawaban

---

## 🧱 Arsitektur & Teknologi

* **Framework**: Flutter
* **Bahasa**: Dart
* **Database**: SQLite (Bundled + Local User Data)
* **Architecture Pattern**: MVVM / BLoC
* **State Management**: (disesuaikan implementasi)
* **Text-to-Speech**: flutter_tts

Aplikasi berjalan **standalone**, tanpa backend, API, atau koneksi internet.

---

## 🗄️ Database

* Database kamus **dibundle langsung dalam APK** (~50.000+ kata)
* Database bersifat **read-only** untuk data kata bawaan
* Data pengguna (history, bookmark, custom words) disimpan terpisah

### Skema Utama

* `words`
* `history`
* `bookmarks`
* `custom_words` (opsional)
* `quiz_results` (opsional)

Database akan otomatis disalin dari assets ke direktori aplikasi saat **first launch**.

---

## 📱 Kebutuhan Sistem

* Android 5.0 (API 21) atau lebih baru
* RAM minimum: 2 GB
* Storage kosong minimal: 100 MB
* Tidak memerlukan koneksi internet

---

## 🚀 Cara Menjalankan (Development)

### 1️⃣ Clone Repository

```bash
git clone https://github.com/Sulthan1901/Tulish.git
cd Tulish
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Jalankan Aplikasi

```bash
flutter run
```

---

## 👨‍💻 Tim Pengembang

* **Muhammad Sulthan Zaki Nasution** (231401008)
* **Michael Purba** (231401053)
* **Ahmad Sufadil** (231401119)

Program Studi Ilmu Komputer
Fakultas Ilmu Komputer dan Teknologi Informasi
Universitas Sumatera Utara

---

## 📄 Lisensi

Proyek ini dikembangkan untuk **kepentingan akademik**. Dataset kamus menggunakan sumber **open-source / public domain**.

---

## 📌 Catatan

Tulish dirancang sebagai aplikasi **offline-first dictionary**, ringan, cepat, dan ramah pengguna, cocok untuk pelajar, mahasiswa, dan pembelajar mandiri Bahasa Inggris.
