-- SPEC-KIT §3.5.4 — Phase 3.5 — Feature flag CV Assist sur les profils
-- Non-breaking : colonne nullable avec default '{}'

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS features TEXT[] DEFAULT '{}';

-- Activation manuelle par admin :
-- UPDATE profiles SET features = ARRAY['cv_rep_counting'] WHERE id = '<uuid>';

-- Vue utilitaire : profils avec CV activé
CREATE OR REPLACE VIEW profiles_cv_enabled AS
SELECT id, nom, prenom, auth_id
FROM profiles
WHERE 'cv_rep_counting' = ANY(features);

GRANT SELECT ON profiles_cv_enabled TO authenticated;

-- Colonne cv_rep_count dans results (nullable — absent si CV non utilisé)
ALTER TABLE results
  ADD COLUMN IF NOT EXISTS cv_rep_count INTEGER;
