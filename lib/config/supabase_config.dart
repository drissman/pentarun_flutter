// SPEC-KIT §2 — Configuration Supabase
// Remplacer SUPABASE_URL et SUPABASE_ANON_KEY par les valeurs du projet
// Settings → API dans le dashboard Supabase

class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'https://nlmcyeevyybxqcxqduyf.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5sbWN5ZWV2eXlieHFjeHFkdXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQzNzkxODUsImV4cCI6MjA4OTk1NTE4NX0'
      '._gQv5PAGIM6sbB4HWktZ225l2oe0ewumMXf6Ag2t080';

  static bool get isConfigured =>
      supabaseUrl != 'SUPABASE_URL' && supabaseAnonKey != 'SUPABASE_ANON_KEY';
}
