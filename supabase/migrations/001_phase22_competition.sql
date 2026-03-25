-- SPEC-KIT §7.1 — Phase 2.2 : tables compétition connectée
-- Migration non-breaking : aucune modification des tables existantes profiles/results
-- sauf ajout colonne nullable wave_id dans results

-- ─── Table competitions ────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS competitions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organizer_id  UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  nom           TEXT NOT NULL,
  lieu          TEXT NOT NULL,
  date_event    DATE NOT NULL,
  statut        TEXT NOT NULL DEFAULT 'brouillon'
                CHECK (statut IN ('brouillon','en_cours','termine')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Table waves ──────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS waves (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  competition_id UUID NOT NULL REFERENCES competitions(id) ON DELETE CASCADE,
  numero         INT NOT NULL,
  niveau         TEXT NOT NULL CHECK (niveau IN ('DÉCOUVERTE','ACTIF','CHALLENGER','ELITE','TITAN')),
  statut         TEXT NOT NULL DEFAULT 'attente'
                 CHECK (statut IN ('attente','en_cours','terminee')),
  started_at     TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── Table wave_athletes ──────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS wave_athletes (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wave_id           UUID NOT NULL REFERENCES waves(id) ON DELETE CASCADE,
  profile_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  dossard           INT,
  kb_kg             INT NOT NULL,
  -- Progression live (mis à jour en temps réel par le juge)
  station_actuelle  INT NOT NULL DEFAULT 0,
  splits_ms         INT[] NOT NULL DEFAULT '{}',
  no_count_events   INT NOT NULL DEFAULT 0,
  statut_athlete    TEXT NOT NULL DEFAULT 'attente'
                    CHECK (statut_athlete IN ('attente','en_course','termine','dnf')),
  final_time_ms     INT,
  official_score    DOUBLE PRECISION,
  platform_score    DOUBLE PRECISION,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (wave_id, profile_id)
);

-- Index pour les requêtes live (vue directeur + spectateurs)
CREATE INDEX IF NOT EXISTS wave_athletes_wave_idx ON wave_athletes(wave_id);
CREATE INDEX IF NOT EXISTS waves_competition_idx ON waves(competition_id);

-- ─── Colonne wave_id dans results (nullable — backward compatible) ──────────

ALTER TABLE results ADD COLUMN IF NOT EXISTS wave_id UUID REFERENCES waves(id);
CREATE INDEX IF NOT EXISTS results_wave_idx ON results(wave_id);

-- ─── Row Level Security ────────────────────────────────────────────────────────

ALTER TABLE competitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE waves        ENABLE ROW LEVEL SECURITY;
ALTER TABLE wave_athletes ENABLE ROW LEVEL SECURITY;

-- competitions : lecture publique, écriture par l'organisateur (auth_id → profiles)
CREATE POLICY "comp_select_all" ON competitions FOR SELECT USING (true);
CREATE POLICY "comp_insert_own" ON competitions FOR INSERT
  WITH CHECK (
    auth.uid() = (SELECT auth_id FROM profiles WHERE id = organizer_id)
  );
CREATE POLICY "comp_update_own" ON competitions FOR UPDATE
  USING (
    auth.uid() = (SELECT auth_id FROM profiles WHERE id = organizer_id)
  );

-- waves : lecture publique, écriture par l'organisateur de la compétition
CREATE POLICY "waves_select_all" ON waves FOR SELECT USING (true);
CREATE POLICY "waves_write_organizer" ON waves FOR ALL
  USING (
    auth.uid() = (
      SELECT p.auth_id FROM profiles p
      JOIN competitions c ON c.organizer_id = p.id
      WHERE c.id = competition_id
    )
  );

-- wave_athletes : lecture publique, écriture par tout utilisateur authentifié
-- (juge authentifié ou organisateur)
CREATE POLICY "wa_select_all" ON wave_athletes FOR SELECT USING (true);
CREATE POLICY "wa_insert_auth" ON wave_athletes FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "wa_update_auth" ON wave_athletes FOR UPDATE
  USING (auth.uid() IS NOT NULL);
CREATE POLICY "wa_delete_auth" ON wave_athletes FOR DELETE
  USING (auth.uid() IS NOT NULL);

-- ─── Réplication Realtime ─────────────────────────────────────────────────────
-- Activer la réplication pour les tables utilisées par Supabase Realtime
-- À exécuter aussi dans le dashboard : Settings > Replication > Tables
ALTER PUBLICATION supabase_realtime ADD TABLE wave_athletes;
ALTER PUBLICATION supabase_realtime ADD TABLE waves;
