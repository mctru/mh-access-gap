-- ============================================================
-- Mental Health Provider Access Gap — Key Analytical Queries
-- Database: data/mh_access_gap.db | Table: hpsa_by_state
-- Sources: HRSA HPSA Data, SAMHSA NSDUH, KFF State Health Facts
-- ============================================================

-- 1. Bottom 10 states by % of mental health need currently met
SELECT state, region, pct_need_met, psychiatrists_per_100k,
       treatment_gap_pct, practitioners_needed
FROM hpsa_by_state
ORDER BY pct_need_met ASC
LIMIT 10;

-- 2. Top 10 states — best mental health provider access
SELECT state, region, pct_need_met, psychiatrists_per_100k, treatment_gap_pct
FROM hpsa_by_state
ORDER BY pct_need_met DESC
LIMIT 10;

-- 3. Regional averages — access, supply, and gap
SELECT
    region,
    ROUND(AVG(pct_need_met), 1)            AS avg_pct_need_met,
    ROUND(AVG(psychiatrists_per_100k), 1)  AS avg_psychiatrists_per_100k,
    ROUND(AVG(treatment_gap_pct), 1)       AS avg_treatment_gap_pct,
    SUM(practitioners_needed)              AS total_practitioners_needed,
    COUNT(*)                               AS state_count
FROM hpsa_by_state
GROUP BY region
ORDER BY avg_pct_need_met ASC;

-- 4. High-burden states: low access AND high treatment gap
SELECT state, region, pct_need_met, treatment_gap_pct,
       psychiatrists_per_100k, practitioners_needed, rural_pct
FROM hpsa_by_state
WHERE pct_need_met < 30 AND treatment_gap_pct > 55
ORDER BY pct_need_met ASC;

-- 5. Rural burden: high-rural vs. lower-rural states
SELECT
    CASE WHEN rural_pct >= 70 THEN 'High Rural (>=70%)'
         ELSE 'Low/Mid Rural (<70%)' END AS rural_category,
    ROUND(AVG(pct_need_met), 1)           AS avg_need_met,
    ROUND(AVG(psychiatrists_per_100k), 1) AS avg_psychiatrists,
    ROUND(AVG(treatment_gap_pct), 1)      AS avg_treatment_gap,
    COUNT(*)                              AS state_count
FROM hpsa_by_state
GROUP BY rural_category;

-- 6. States where provider supply and access gap diverge most
--    (relatively high psychiatrist supply but still high gap — systemic barriers)
SELECT state, psychiatrists_per_100k, treatment_gap_pct, pct_need_met,
       ROUND(treatment_gap_pct - (100 - pct_need_met), 1) AS gap_vs_shortage_delta
FROM hpsa_by_state
WHERE psychiatrists_per_100k > 8 AND treatment_gap_pct > 50
ORDER BY treatment_gap_pct DESC;

-- 7. Total practitioners needed by region (workforce planning)
SELECT region,
       SUM(practitioners_needed)           AS total_practitioners_needed,
       ROUND(AVG(practitioners_needed), 0) AS avg_per_state,
       MAX(practitioners_needed)           AS highest_state_need
FROM hpsa_by_state
GROUP BY region
ORDER BY total_practitioners_needed DESC;

-- 8. Population-weighted access summary
SELECT
    region,
    SUM(pop_in_hpsa_k)                              AS total_pop_in_hpsa_k,
    ROUND(AVG(pct_need_met), 1)                     AS avg_need_met,
    SUM(practitioners_needed)                       AS practitioners_needed
FROM hpsa_by_state
GROUP BY region
ORDER BY total_pop_in_hpsa_k DESC;
