CREATE TABLE mart.mart_hearing_results AS 
WITH base AS (
SELECT 
sa.appointment_id, 
sa.patient_id, 
sa.location_id,
sa.appointment_date,
sa.appointment_type,
sp.first_name,
sp.last_name,
sp.age,
sp.date_of_birth,
ROUND((sr.ac_left_500hz + sr.ac_left_1000hz + sr.ac_left_2000hz + sr.ac_left_4000hz) / 4, 0) AS pta_left_ac,
ROUND((sr.ac_right_500hz + sr.ac_right_1000hz + sr.ac_right_2000hz + sr.ac_right_4000hz) / 4,0) AS pta_right_ac, 
ROUND((sr.bc_left_500hz + sr.bc_left_1000hz + sr.bc_left_2000hz + sr.bc_left_4000hz) / 4,0) AS pta_left_bc, 
ROUND((sr.bc_right_500hz + sr.bc_right_1000hz + sr.bc_right_2000hz + sr.bc_right_4000hz) / 4,0) AS pta_right_bc,
sr.is_incomplete
FROM staging.stg_appointments AS sa
LEFT JOIN staging.stg_patients AS sp USING (patient_id)
LEFT JOIN staging.stg_audiometry_results AS sr USING (appointment_id)
),
classified AS (
SELECT
*,
CASE WHEN is_incomplete IS NULL THEN NULL
WHEN is_incomplete = TRUE THEN NULL
WHEN pta_left_ac <=20 THEN 'Normal'
WHEN pta_left_ac <=40 THEN 'Mild'
WHEN pta_left_ac <=70 THEN 'Moderate'
WHEN pta_left_ac <=95 THEN 'Severe'
ELSE 'Profound' 
END AS severity_left,
CASE WHEN is_incomplete IS NULL THEN NULL
WHEN is_incomplete = TRUE THEN NULL
WHEN pta_right_ac <=20 THEN 'Normal'
WHEN pta_right_ac <=40 THEN 'Mild'
WHEN pta_right_ac <=70 THEN 'Moderate'
WHEN pta_right_ac <=95 THEN 'Severe'
ELSE 'Profound' 
END AS severity_right
FROM base),
gap_calc AS (
SELECT 
*, 
(pta_left_ac - pta_left_bc) AS abg_left, 
(pta_right_ac -pta_right_bc) AS abg_right
FROM classified
), 
loss_type AS(
SELECT 
*, 
CASE WHEN severity_left IS NULL THEN NULL
WHEN severity_left = 'Normal' THEN NULL
WHEN pta_left_bc <=20 AND abg_left >=15 THEN 'Conductive'
WHEN pta_left_bc >20 AND abg_left <15 THEN 'Sensorineural'
WHEN pta_left_bc >20 AND abg_left >= 15 THEN 'Mixed'
ELSE 'Inconclusive'
END AS loss_type_left,
CASE WHEN severity_right IS NULL THEN NULL
WHEN severity_right = 'Normal' THEN NULL
WHEN pta_right_bc <=20 AND abg_right >=15 THEN 'Conductive'
WHEN pta_right_bc >20 AND abg_right <15 THEN 'Sensorineural'
WHEN pta_right_bc >20 AND abg_right >= 15 THEN 'Mixed'
ELSE 'Inconclusive'
END AS loss_type_right
FROM gap_calc)
SELECT 
*, 
CASE WHEN loss_type_left IS NULL AND loss_type_right IS NULL THEN NULL
WHEN loss_type_left IS NULL AND loss_type_right IS NOT NULL THEN 'Unilateral'
WHEN loss_type_right IS NULL AND loss_type_left IS NOT NULL THEN 'Unilateral'
WHEN ABS(pta_left_ac - pta_right_ac) >= 20 THEN 'Asymmetrical'
WHEN loss_type_left = loss_type_right THEN 'Bilateral'
ELSE 'Bilateral'
END AS laterality
FROM loss_type;

SELECT * FROM mart.mart_hearing_results;