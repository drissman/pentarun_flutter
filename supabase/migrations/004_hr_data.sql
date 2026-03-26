-- SPEC-KIT §6.3–6.6 — Phase 3 — Colonnes cardio dans results
-- Non-breaking : toutes les colonnes sont nullable (rétrocompatible avec résultats sans HR)

ALTER TABLE results
  ADD COLUMN IF NOT EXISTS fc_moy           INTEGER,
  ADD COLUMN IF NOT EXISTS fc_max_atteinte  INTEGER,
  ADD COLUMN IF NOT EXISTS trimp            NUMERIC(8, 2),
  ADD COLUMN IF NOT EXISTS coeff_physio     NUMERIC(6, 4),
  ADD COLUMN IF NOT EXISTS platform_score_hr NUMERIC(15, 3),
  -- Tampon brut JSON optionnel (fc, timestamp[]) pour recalcul futur
  ADD COLUMN IF NOT EXISTS hr_data          JSONB;

-- Index partiel sur platform_score_hr pour les classements HR futurs
CREATE INDEX IF NOT EXISTS idx_results_platform_score_hr
  ON results (platform_score_hr ASC)
  WHERE platform_score_hr IS NOT NULL;
