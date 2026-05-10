# HearEar Analytics Engineering Project

## Project Overview

HearEar is a fictional multi-branch private audiology clinic based in London. This project takes four raw clinical datasets — locations, patients, appointments, and audiometry results — and transforms them through a structured SQL pipeline into a single analytical table. The final output classifies each patient's hearing loss by severity, type, and laterality using British Society of Audiology (BSA) standards.

---

## Tech Stack

- PostgreSQL
- pgAdmin 
- Synthetic data generated with the assistance of Claude (Anthropic)

---

## Data Architecture

This project follows a three-layer analytics engineering structure:

```
raw → staging → mart
```

| Layer | Schema | Type | Purpose |
|---|---|---|---|
| Raw | `raw` | Tables | Source data loaded exactly as received, never modified and unmanipulated |
| Staging | `staging` | Views | Cleaned, standardised data ready for use |
| Mart | `mart` | Table | Final analytical output with clinical classifications |

### Why three layers?

The raw layer is kept in its original format untouched so that the data can always be traced back to its source. The staging layer handles cleaning and standardisation so that the mart layer can focus entirely on clinical logic. Each layer has a single purpose.

---

## Source Tables (Raw Layer)

| Table | Rows | Description |
|---|---|---|
| `raw.dim_locations` | 8 | HearEar branch locations across London |
| `raw.dim_patients` | 30 | Patient demographics |
| `raw.fct_appointments` | 50 | Appointment records across all branches |
| `raw.raw_audiometry_results` | 30 | Air and bone conduction thresholds per appointment |

---

## Staging Layer

Three views clean and standardise the raw data before it reaches the mart.

### `staging.stg_patients`
- Calculates patient age dynamically from date of birth using `DATE_PART('year', AGE(CURRENT_DATE, date_of_birth))` so the value is always current at query time.

### `staging.stg_appointments`
- Standardises `appointment_type` to lowercase to prevent inconsistent grouping downstream (e.g. `Hearing Assessment` and `hearing assessment` being treated as separate values).

### `staging.stg_audiometry_results`
- Includes all air conduction (AC) and bone conduction (BC) threshold columns.
- Adds an `is_incomplete` flag. A test is flagged as incomplete if any AC threshold is NULL. BC NULLs are not flagged as incomplete — bone conduction is not always clinically indicated (see assumptions below).

---

## Mart Layer

### `mart.mart_hearing_results`

The final output table. One row per appointment. Only Hearing Assessment appointments have audiometry data — Hearing Aid Fitting and Follow-up appointments return NULL for all clinical classification columns.

#### Columns

| Column | Description |
|---|---|
| `appointment_id` | Unique appointment identifier |
| `patient_id` | Patient identifier |
| `location_id` | Branch identifier |
| `appointment_date` | Date of appointment |
| `appointment_type` | Type of appointment (standardised to lowercase) |
| `first_name`, `last_name` | Patient name |
| `age` | Dynamically calculated patient age |
| `date_of_birth` | Patient date of birth |
| `pta_left_ac` | Pure Tone Average — left ear, air conduction (dB HL) |
| `pta_right_ac` | Pure Tone Average — right ear, air conduction (dB HL) |
| `pta_left_bc` | Pure Tone Average — left ear, bone conduction (dB HL) |
| `pta_right_bc` | Pure Tone Average — right ear, bone conduction (dB HL) |
| `abg_left` | Air-bone gap — left ear (AC minus BC) |
| `abg_right` | Air-bone gap — right ear (AC minus BC) |
| `is_incomplete` | TRUE if any AC threshold is NULL |
| `severity_left` | BSA severity classification — left ear |
| `severity_right` | BSA severity classification — right ear |
| `loss_type_left` | Hearing loss type — left ear |
| `loss_type_right` | Hearing loss type — right ear |
| `laterality` | Bilateral, Unilateral, or Asymmetrical |

---

## Clinical Logic

### Pure Tone Average (PTA)

PTA is the average of air conduction thresholds at 500, 1000, 2000, and 4000 Hz. These four frequencies cover the speech range and are the standard frequencies used by the BSA for clinical reporting. PTA is calculated separately for each ear and for both air and bone conduction.

```
PTA = (500 Hz + 1000 Hz + 2000 Hz + 4000 Hz) / 4
```

### Severity Classification (BSA Standards)

Severity is classified per ear based on AC PTA. BSA severity bands are used rather than WHO bands.

| PTA (dB HL) | Severity |
|---|---|
| ≤20 | Normal |
| 21–40 | Mild |
| 41–70 | Moderate |
| 71–95 | Severe |
| >95 | Profound |

Severity is reported per ear rather than combined, because hearing loss is frequently asymmetrical and combining the two ears into a single value would lose clinically important information.

### Hearing Loss Type Classification

Type is classified per ear using BC PTA and the air-bone gap (AC minus BC).

| BC PTA (dB HL) | Air-Bone Gap | Type |
|---|---|---|
| ≤20 | <15 dB | Normal |
| ≤20 | ≥15 dB | Conductive |
| >20 | <15 dB | Sensorineural |
| >20 | ≥15 dB | Mixed |

### Laterality Classification

| Condition | Laterality |
|---|---|
| Both ears no loss or incomplete | NULL |
| One ear has loss, other is normal or NULL | Unilateral |
| PTA difference between ears ≥20 dB | Asymmetrical |
| Both ears have the same loss type | Bilateral |

---

## Key Design Decisions & Assumptions

**Incomplete tests are flagged, not deleted.** Removing incomplete rows would hide the fact that a test was attempted. Flagging them keeps the data traceable and allows reporting on test completion rates by branch.

**BC NULLs in normal hearing patients are not flagged as incomplete.** Bone conduction testing is not clinically indicated when AC thresholds are within normal limits. Flagging these rows as incomplete would be clinically incorrect.

**BSA severity bands are used, not WHO.** This project is modelled on UK private audiology practice where BSA standards apply.

**PTA uses four core frequencies (500–4000 Hz).** These cover the speech banana and are the standard frequencies for BSA PTA reporting. 250 Hz and 8000 Hz are excluded for simplicity.

**Severity is reported per ear.** Combining left and right ear severity into a single value would mask asymmetrical presentations, which are clinically significant.

**Age is calculated dynamically.** Storing a fixed age value would become stale. Using `DATE_PART('year', AGE(CURRENT_DATE, date_of_birth))` ensures age is always accurate at query time.

**Appointment type is standardised to lowercase.** This prevents grouping errors in downstream analysis caused by inconsistent casing from data entry.
