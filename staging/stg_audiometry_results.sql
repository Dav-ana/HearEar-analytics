CREATE VIEW staging.stg_audiometry_results AS 
SELECT 
	result_id, 
	appointment_id, 
	ac_left_500hz, ac_left_1000hz,  ac_left_2000hz, ac_left_4000hz, ac_right_500hz, ac_right_1000hz, ac_right_2000hz, ac_right_4000hz , notes,
 CASE 
    WHEN ac_left_500hz IS NULL 
    OR ac_right_500hz IS NULL OR  ac_left_1000hz IS NULL OR ac_right_1000hz IS NULL OR ac_left_2000hz IS NULL OR ac_right_2000hz IS NULL OR ac_left_4000hz IS NULL OR ac_right_4000hz IS NULL
    THEN TRUE
    ELSE FALSE
END AS is_incomplete
FROM raw.raw_audiometry_results;

SELECT * 
FROM staging.stg_audiometry_results;

DROP VIEW staging.stg_audiometry_results;

CREATE VIEW staging.stg_audiometry_results AS 
SELECT 
	result_id, 
	appointment_id, 
	ac_left_500hz, ac_left_1000hz,  ac_left_2000hz, ac_left_4000hz, ac_right_500hz, ac_right_1000hz, ac_right_2000hz, ac_right_4000hz, bc_left_500hz, bc_left_1000hz,  bc_left_2000hz, bc_left_4000hz, bc_right_500hz, bc_right_1000hz, bc_right_2000hz, bc_right_4000hz , notes,
 CASE 
    WHEN ac_left_500hz IS NULL 
    OR ac_right_500hz IS NULL OR  ac_left_1000hz IS NULL OR ac_right_1000hz IS NULL OR ac_left_2000hz IS NULL OR ac_right_2000hz IS NULL OR ac_left_4000hz IS NULL OR ac_right_4000hz IS NULL
    THEN TRUE
    ELSE FALSE
END AS is_incomplete
FROM raw.raw_audiometry_results;

SELECT * 
FROM staging.stg_audiometry_results;

SELECT 
COUNT (*) 
FROM staging.stg_audiometry_results 
WHERE is_incomplete = TRUE;

