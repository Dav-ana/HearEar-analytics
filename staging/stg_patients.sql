CREATE VIEW staging.stg_patients AS
SELECT
    patient_id, 
	first_name, 
	last_name, 
	date_of_birth, 
	AGE(CURRENT_DATE, date_of_birth) AS age, 
	home_postcode
FROM raw.dim_patients;

DROP VIEW staging.stg_patients;

CREATE VIEW staging.stg_patients AS 
SELECT 
	patient_id, 
	first_name, last_name, 
	date_of_birth, 
	DATE_PART('year', AGE(CURRENT_DATE, date_of_birth)) AS age, 
	home_postcode 
FROM raw.dim_patients;

SELECT * FROM staging.stg_patients;