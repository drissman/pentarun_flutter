-- SPEC-KIT §5.6 — Phase 2.3 Sprint 2 — Vue des records par catégorie
-- Meilleur platform_score absolu par (level × coeff_sexe × coeff_age)
-- DISTINCT ON : conserve la ligne complète du meilleur résultat

CREATE OR REPLACE VIEW records AS
SELECT DISTINCT ON (level, coeff_sexe, coeff_age)
  id,
  profile_id,
  competition_name,
  wave_date,
  level,
  weight_kb_kg,
  coeff_kb,
  coeff_age,
  coeff_sexe,
  final_time_ms,
  official_score,
  platform_score,
  splits,
  no_count_events,
  energy_run_kcal,
  energy_steel_kcal,
  energy_total_kcal
FROM results
ORDER BY level, coeff_sexe DESC, coeff_age DESC, platform_score ASC;

-- Accès lecture pour les utilisateurs authentifiés
GRANT SELECT ON records TO authenticated;
