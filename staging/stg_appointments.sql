CREATE VIEW staging.stg_appointments AS 
SELECT 
	appointment_id, 
	patient_id, 
	location_id, 
	appointment_date, 
	LOWER(appointment_type) AS appointment_type 
FROM raw.fct_appointments;

SELECT * FROM staging.stg_appointments;