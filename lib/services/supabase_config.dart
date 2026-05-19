// Supabase baglanti bilgileri.
//
// Algo trade ekrani Supabase'e baglanir. Iki deger gerekir:
//   url     : proje adresi (asagida hazir).
//   anonKey : herkese acik "anon public" anahtar.
//
// anonKey'i bulmak icin: Supabase panosu -> Project Settings -> API ->
// "Project API keys" altindaki "anon public" anahtarini kopyalayip
// asagidaki anonKey degerine yapistir.
//
// Not: anon anahtar gizli degildir, mobil uygulamalarda kullanilmak
// icindir. Asil gizli olan service_role anahtaridir, o buraya konmaz.

class SupabaseConfig {
  static const String url = 'https://jeqncdumzlzpkjyxpvol.supabase.co';

  // Supabase "anon public" anahtari (mobil istemci icin, gizli degil).
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImplcW5jZHVtemx6cGtqeXhwdm9sIiwi'
      'cm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTczMzMsImV4cCI6MjA5NDE5MzMzM30'
      '.-6HWQDELyM9BUx6C7310n-mfTFMYolyBqvjE40SLcm8';
}
