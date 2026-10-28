# State Preferences

Contoh aplikasi Flutter untuk menyimpan profil pengguna secara lokal dengan
`shared_preferences`. Data yang disimpan meliputi nama, email, dan status login;
jangan gunakan penyimpanan ini untuk password atau data sensitif.

Aplikasi ini juga menggunakan package `provider` untuk state management,
menyimpan preferensi tema gelap, menghitung jumlah kunjungan, dan mengelola
daftar favorit. Email yang pernah tersimpan dicatat lokal untuk simulasi
pemeriksaan email duplikat.

## Persyaratan

- Flutter 3.47.7 atau yang kompatibel
- Dart 3.12.2 atau yang lebih baru dalam rentang SDK proyek

## Menjalankan aplikasi

```sh
flutter pub get
flutter run
```

Untuk menjalankan di Chrome:

```sh
flutter run -d chrome
```

Jalankan pemeriksaan kode dan tes dengan:

```sh
flutter analyze
flutter test
```
