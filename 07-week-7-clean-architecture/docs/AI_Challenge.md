# AI Prompt Challenge
[LinkPenggunaanAI](https://share.gemini.google/4nMLcWnNv5yF)

---

## Ringkasan Rekomendasi

| Kebutuhan Aplikasi | Rekomendasi Utama | Rekomendasi Alternatif | Alasan Utama |
| :--- | :--- | :--- | :--- |
| **Preferensi Tema** | **SharedPreferences** | **Hive** | Data preferensi (seperti `isDarkMode: bool` atau `themeColor: String`) bersifat Key-Value sederhana, berukuran sangat kecil, dan tidak membutuhkan query kompleks. Boilerplate minimal dan inisialisasi cepat saat awal *app splash*. |
| **Manajemen Catatan** | **Drift** | **Hive** *(jika tanpa relasi/pencarian)* | Untuk skala 1000+ catatan, pencarian (*filtering/search*), pengurutan, relasi (seperti Tag/Kategori), dan *reactive UI* (Stream) sangat kritikal. Drift memberikan type-safety penuh, query SQL terindeks yang sangat cepat, dan integrasi *Stream* otomatis ke UI Flutter. |

---

## Matrix Perbandingan Storage Engine

| Kriteria | SharedPreferences | Hive | sqflite | Drift (Moor) |
| :--- | :--- | :--- | :--- | :--- |
| **Kompleksitas Query** | Sangat Rendah (Key-Value) | Rendah (Filter manual di RAM) | Tinggi (Raw SQL: `JOIN`, `WHERE`) | Tinggi (Type-safe Query Builder + Custom SQL) |
| **Kebutuhan Relasi** | Tidak Ada | Tidak Ada (Referensi ID manual) | Sangat Baik (Foreign Keys, `JOIN`) | Sangat Baik (Foreign Keys, Expressive Joins) |
| **Reaktivitas (Stream)** | Tidak Ada (Polling / Manual) | Baik (Stream per Box / Key) | Tidak Ada (Bungkus `StreamController` manual) | Sangat Baik (Built-in Reactive `watch()` Queries) |
| **Type-Safety** | Lemah (Casting manual) | Sedang (`TypeAdapter` & generic) | Lemah (Map `<String, dynamic>`) | Sangat Tinggi (Compile-time checking via code gen) |
| **Ukuran Boilerplate** | Sangat Kecil | Kecil - Sedang | Sedang (SQL string & mapper) | Tinggi di Awal (`build_runner`) |
| **Kemudahan Testing** | Sangat Mudah | Mudah (Direktori temporary) | Agak Sulit (Perlu mock SQLite) | Sangat Mudah (In-Memory SQLite) |

---

## Skema Database untuk 1000+ Catatan (Drift / SQLite)

Memproses 1000+ catatan membutuhkan **pencarian cepat (indexing)**, **pagination**, dan **performa baca tinggi**. Berikut adalah skema SQLite/Drift yang dioptimalkan:

```dart
import 'package:drift/drift.dart';

// Tabel Kategori (Relasi 1-to-Many ke Catatan)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get colorHex => text().withLength(min: 6, max: 9).withDefault(const Constant('#FFFFFF'))();
}

// Tabel Catatan Teroptimasi
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 0, max: 200)();
  TextColumn get content => text()(); // Teks catatan panjang
  
  // Foreign key ke Kategori (Nullable jika catatan tanpa kategori)
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get customConstraints => [
    // Indeks gabungan untuk sorting & filtering 1000+ catatan dengan cepat
    Index('idx_notes_pinned_updated', 'is_pinned DESC, updated_at DESC'),
    Index('idx_notes_category', 'category_id'),
  ];
}
```

### Strategic Optimizations untuk 1000+ Catatan:
1. **Compound Index (`idx_notes_pinned_updated`)**: Menjaga query pengurutan daftar utama tetap *$O(\log N)$* alih-alih *$O(N)$* scan seluruh tabel.
2. **Lazy Loading / Pagination**: Gunakan `LIMIT` dan `OFFSET` pada query Drift saat memuat daftar catatan ke UI.
3. **Full-Text Search (FTS5)**: Jika membutuhkan fitur pencarian kata kunci pada ribuan isi konten (`content`), manfaatkan tabel SQLite Virtual `FTS5` di Drift agar pencarian teks tidak memblokir UI thread.

---

## ⚡ Analisis Trade-Off Setiap Pilihan

### 1. SharedPreferences
* **Pros:** Sangat ringan, *zero-boilerplate*, tanpa konfigurasi database.
* **Cons:** Hanya untuk tipe data primitif, tidak mendukung relasi/indexing, pembacaan file async yang tidak cocok untuk dataset koleksi.

### 2. Hive
* **Pros:** Database NoSQL Key-Value berbasis Dart murni yang sangat cepat karena memuat index ke RAM. Tanpa dependency native C/SQL.
* **Cons:** Seluruh indeks disimpan di RAM (risiko memori jika data sangat besar). Manajemen relasi data harus dilakukan secara manual di level aplikasi.

### 3. sqflite
* **Pros:** Menggunakan engine SQLite bawaan OS. Performa stabil, hemat memori karena membaca dari disk secara terporsi.
* **Cons:** Query ditulis menggunakan *raw string*, rawan runtime error/typo, tidak ada *compile-time checking*, dan membutuhkan banyak kode mapper manual.

### 4. Drift (Moor)
* **Pros:** *Type-safety* penuh pada level compile-time, otomatis update UI melalui `Stream` (`watch()`), migration tool handal, dan mendukung in-memory database untuk unit testing.
* **Cons:** Membutuhkan langkah *code generation* (`build_runner`), kurva pembelajaran awal sedikit lebih tinggi dibanding solusi sederhana.

---