-- SPEC-KIT §7.2 — Phase 2.2 Sprint 5 — Accès spectateur anonyme + display_name dénormalisé
-- Non-breaking : uniquement ajout de colonne nullable + politiques RLS supplémentaires

-- ─── Colonne display_name dénormalisée dans wave_athletes ────────────────────
-- Stocke nom + prénom au moment de l'inscription pour éviter une jointure profiles
-- lors de l'accès anonyme (spectateurs sans compte)
ALTER TABLE wave_athletes ADD COLUMN IF NOT EXISTS display_name TEXT;

-- ─── Politiques RLS anonymes (lecture seule) ─────────────────────────────────
-- Uniquement pour les compétitions en cours (statut = 'en_cours')

-- Compétitions en cours : lecture anonyme
CREATE POLICY "anon_read_competitions_live"
  ON competitions FOR SELECT TO anon
  USING (statut = 'en_cours');

-- Vagues des compétitions en cours : lecture anonyme
CREATE POLICY "anon_read_waves_live"
  ON waves FOR SELECT TO anon
  USING (
    competition_id IN (
      SELECT id FROM competitions WHERE statut = 'en_cours'
    )
  );

-- wave_athletes des vagues actives : lecture anonyme (display_name inclus, pas de profil joint)
CREATE POLICY "anon_read_wave_athletes_live"
  ON wave_athletes FOR SELECT TO anon
  USING (
    wave_id IN (
      SELECT w.id FROM waves w
      JOIN competitions c ON c.id = w.competition_id
      WHERE c.statut = 'en_cours'
    )
  );
