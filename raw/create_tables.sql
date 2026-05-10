CREATE TABLE raw.dim_locations (
    location_id     INT PRIMARY KEY,
    branch_name     VARCHAR(100),
    postcode        VARCHAR(10)
);

CREATE TABLE raw.dim_patients (
    patient_id      INT PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    date_of_birth   DATE,
    home_postcode   VARCHAR(10)
);

CREATE TABLE raw.fct_appointments (
    appointment_id      INT PRIMARY KEY,
    patient_id          INT REFERENCES raw.dim_patients(patient_id),
    location_id         INT REFERENCES raw.dim_locations(location_id),
    appointment_date    DATE,
    appointment_type    VARCHAR(50)
);

CREATE TABLE raw.raw_audiometry_results (
    result_id           INT PRIMARY KEY,
    appointment_id      INT REFERENCES raw.fct_appointments(appointment_id),
    ac_left_500hz       NUMERIC(5,1),
    ac_left_1000hz      NUMERIC(5,1),
    ac_left_2000hz      NUMERIC(5,1),
    ac_left_4000hz      NUMERIC(5,1),
    ac_right_500hz      NUMERIC(5,1),
    ac_right_1000hz     NUMERIC(5,1),
    ac_right_2000hz     NUMERIC(5,1),
    ac_right_4000hz     NUMERIC(5,1),
    bc_left_500hz       NUMERIC(5,1),
    bc_left_1000hz      NUMERIC(5,1),
    bc_left_2000hz      NUMERIC(5,1),
    bc_left_4000hz      NUMERIC(5,1),
    bc_right_500hz      NUMERIC(5,1),
    bc_right_1000hz     NUMERIC(5,1),
    bc_right_2000hz     NUMERIC(5,1),
    bc_right_4000hz     NUMERIC(5,1),
    notes               TEXT
);

