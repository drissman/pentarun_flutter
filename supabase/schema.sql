-- SPEC-KIT §2 — Schéma Supabase PENTARUN v2.0
-- Exécuter via : psql postgresql://postgres:[PASSWORD]@db.nlmcyeevyybxqcxqduyf.supabase.co:5432/postgres -f supabase/schema.sql
-- Ou via l'éditeur SQL du dashboard Supabase

-- ─── Extensions ───────────────────────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── Table profiles ───────────────────────────────────────────────────────────
-- SPEC-KIT §3.2 — Profil athlète persistant

CREATE TABLE IF NOT EXISTS profiles (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id       UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  nom           TEXT NOT NULL,
  prenom        TEXT NOT NULL,
  sexe          TEXT NOT NULL CHECK (sexe IN ('HOMME', 'FEMME')),
  date_naissance DATE NOT NULL,
  poids_kg      INT NOT NULL CHECK (poids_kg BETWEEN 30 AND 200),
  taille_cm     INT NOT NULL CHECK (taille_cm BETWEEN 100 AND 250),
  niveau_habituel TEXT NOT NULL CHECK (niveau_habituel IN ('DÉCOUVERTE','ACTIF','CHALLENGER','ELITE','TITAN')),
  kb_habituel_kg  INT NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Table results ────────────────────────────────────────────────────────────
-- SPEC-KIT §4.1 — Résultat de course

CREATE TABLE IF NOT EXISTS results (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  profile_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  competition_name TEXT,
  wave_date        DATE NOT NULL,
  level            TEXT NOT NULL CHECK (level IN ('DÉCOUVERTE','ACTIF','CHALLENGER','ELITE','TITAN')),
  weight_kb_kg     INT NOT NULL,
  coeff_kb         DOUBLE PRECISION NOT NULL,
  coeff_age        DOUBLE PRECISION NOT NULL,
  coeff_sexe       DOUBLE PRECISION NOT NULL,
  final_time_ms    INT NOT NULL CHECK (final_time_ms > 0),
  official_score   DOUBLE PRECISION NOT NULL,
  -- SPEC-KIT §5.2 — scorePlateforme = finalTimeMs × coeff_KB × coeff_age × coeff_sexe
  platform_score   DOUBLE PRECISION NOT NULL,
  splits           INT[] NOT NULL DEFAULT '{}',
  no_count_events  INT NOT NULL DEFAULT 0,
  energy_run_kcal  DOUBLE PRECISION,
  energy_steel_kcal DOUBLE PRECISION,
  energy_total_kcal DOUBLE PRECISION,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index pour les classements (SPEC-KIT §5.6)
CREATE INDEX IF NOT EXISTS results_platform_score_idx ON results(level, platform_score ASC);
CREATE INDEX IF NOT EXISTS results_profile_date_idx ON results(profile_id, wave_date DESC);

-- ─── Row Level Security ───────────────────────────────────────────────────────
-- SPEC-KIT §2 — Sécurité des données

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE results  ENABLE ROW LEVEL SECURITY;

-- Profils : lecture publique, écriture uniquement par le propriétaire
CREATE POLICY "profiles_select_all"
  ON profiles FOR SELECT USING (true);

CREATE POLICY "profiles_insert_own"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = auth_id);

CREATE POLICY "profiles_update_own"
  ON profiles FOR UPDATE
  USING (auth.uid() = auth_id);

-- Résultats : lecture publique, insertion authentifiée uniquement
CREATE POLICY "results_select_all"
  ON results FOR SELECT USING (true);

CREATE POLICY "results_insert_auth"
  ON results FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    EXISTS (SELECT 1 FROM profiles WHERE id = profile_id AND auth_id = auth.uid())
  );

-- ─── Fonction recherche profil par nom ───────────────────────────────────────

CREATE OR REPLACE FUNCTION search_profiles(query TEXT)
RETURNS SETOF profiles
LANGUAGE sql STABLE SECURITY DEFINER
AS $$
  SELECT * FROM profiles
  WHERE nom ILIKE '%' || query || '%' OR prenom ILIKE '%' || query || '%'
  ORDER BY nom, prenom
  LIMIT 10;
$$;
