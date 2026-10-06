CREATE DATABASE healthcare_db;
USE healthcare_db;

CREATE TABLE healthcare_data (
  patient_id VARCHAR(20),
  age INT,
  gender VARCHAR(20),
  blood_type VARCHAR(5),
  medical_condition VARCHAR(50),
  date_of_admission DATE,
  doctor VARCHAR(100),
  hospital VARCHAR(100),
  insurance_provider VARCHAR(50),
  billing_amount DECIMAL(12,2),
  room_number INT,
  admission_type VARCHAR(20),
  discharge_date DATE,
  medication VARCHAR(50),
  test_results VARCHAR(20),
  hospital_latitude DECIMAL(10,6),
  hospital_longitude DECIMAL(10,6)
);

  LOAD DATA LOCAL INFILE 'data/healthcare_data.csv'
  INTO TABLE healthcare_data
  FIELDS TERMINATED BY ',' ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  IGNORE 1 ROWS;


-- 0. DATA QUALITY CHECKS

SELECT COUNT(*)                        AS total_rows,
       COUNT(DISTINCT patient_id)      AS unique_patients,
       SUM(billing_amount < 0)         AS negative_billing_rows,
       MIN(date_of_admission)          AS first_admission,
       MAX(date_of_admission)          AS last_admission
FROM healthcare_data;

-- 1. CLEAN VIEW (used by every query below and by Power BI)
--    - adds length_of_stay and age_group
--    - excludes the 108 rows with negative billing amounts

CREATE VIEW healthcare_clean AS
SELECT
    patient_id,
    age,
    CASE
        WHEN age < 18 THEN '13-17'
        WHEN age < 30 THEN '18-29'
        WHEN age < 45 THEN '30-44'
        WHEN age < 60 THEN '45-59'
        WHEN age < 75 THEN '60-74'
        ELSE '75+'
    END AS age_group,
    gender,
    blood_type,
    medical_condition,
    date_of_admission,
    discharge_date,
    DATEDIFF(discharge_date, date_of_admission) AS length_of_stay,
    doctor,
    hospital,
    insurance_provider,
    billing_amount,
    room_number,
    admission_type,
    medication,
    test_results,
    hospital_latitude,
    hospital_longitude
FROM healthcare_data
WHERE billing_amount >= 0;

SELECT COUNT(*) AS clean_rows FROM healthcare_clean;


-- Q1. Age groups, genders, blood types: who is admitted most?

-- Age groups
SELECT age_group, COUNT(*) AS patients,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM healthcare_clean
GROUP BY age_group
ORDER BY age_group;

-- Gender
SELECT gender, COUNT(*) AS patients,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM healthcare_clean
GROUP BY gender
ORDER BY patients DESC;

-- Blood type
SELECT blood_type, COUNT(*) AS patients,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM healthcare_clean
GROUP BY blood_type
ORDER BY patients DESC;

-- Age group x gender
SELECT age_group, gender, COUNT(*) AS patients
FROM healthcare_clean
GROUP BY age_group, gender
ORDER BY age_group, gender;


-- Q2. Most diagnosed conditions, and which groups they affect

SELECT medical_condition, COUNT(*) AS patients,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM healthcare_clean
GROUP BY medical_condition
ORDER BY patients DESC;

-- Condition by gender
SELECT medical_condition, gender, COUNT(*) AS patients
FROM healthcare_clean
GROUP BY medical_condition, gender
ORDER BY medical_condition, patients DESC;

-- Condition by age group
SELECT medical_condition, age_group, COUNT(*) AS patients
FROM healthcare_clean
GROUP BY medical_condition, age_group
ORDER BY medical_condition, age_group;

-- Average age per condition
SELECT medical_condition, ROUND(AVG(age), 1) AS avg_age
FROM healthcare_clean
GROUP BY medical_condition
ORDER BY avg_age DESC;


-- Q3. Length of stay by condition, hospital, admission type

SELECT medical_condition, ROUND(AVG(length_of_stay), 2) AS avg_los_days
FROM healthcare_clean
GROUP BY medical_condition
ORDER BY avg_los_days DESC;

SELECT hospital, ROUND(AVG(length_of_stay), 2) AS avg_los_days
FROM healthcare_clean
GROUP BY hospital
ORDER BY avg_los_days DESC;

SELECT admission_type, ROUND(AVG(length_of_stay), 2) AS avg_los_days
FROM healthcare_clean
GROUP BY admission_type
ORDER BY avg_los_days DESC;

-- Condition x admission type
SELECT medical_condition, admission_type,
       ROUND(AVG(length_of_stay), 2) AS avg_los_days
FROM healthcare_clean
GROUP BY medical_condition, admission_type
ORDER BY medical_condition, admission_type;


-- Q4. Treatment cost by condition, hospital, insurance provider

SELECT medical_condition,
       ROUND(AVG(billing_amount), 2) AS avg_billing,
       ROUND(SUM(billing_amount), 2) AS total_billing
FROM healthcare_clean
GROUP BY medical_condition
ORDER BY avg_billing DESC;

SELECT hospital,
       ROUND(AVG(billing_amount), 2) AS avg_billing,
       ROUND(SUM(billing_amount), 2) AS total_billing
FROM healthcare_clean
GROUP BY hospital
ORDER BY avg_billing DESC;

SELECT insurance_provider,
       ROUND(AVG(billing_amount), 2) AS avg_billing,
       ROUND(SUM(billing_amount), 2) AS total_billing
FROM healthcare_clean
GROUP BY insurance_provider
ORDER BY avg_billing DESC;

-- Condition x hospital average cost
SELECT medical_condition, hospital, ROUND(AVG(billing_amount), 2) AS avg_billing
FROM healthcare_clean
GROUP BY medical_condition, hospital
ORDER BY medical_condition, avg_billing DESC;


-- Q5. Hospitals: patient volume and outcomes (test results)

SELECT hospital, COUNT(*) AS patients
FROM healthcare_clean
GROUP BY hospital
ORDER BY patients DESC;

-- Test result counts and % within each hospital
SELECT hospital, test_results, COUNT(*) AS patients,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY hospital), 2) AS pct_within_hospital
FROM healthcare_clean
GROUP BY hospital, test_results
ORDER BY hospital, test_results;

-- % abnormal per hospital
SELECT hospital,
       ROUND(SUM(test_results = 'Abnormal') * 100.0 / COUNT(*), 2) AS pct_abnormal,
       ROUND(SUM(test_results = 'Normal') * 100.0 / COUNT(*), 2)   AS pct_normal,
       ROUND(SUM(test_results = 'Inconclusive') * 100.0 / COUNT(*), 2) AS pct_inconclusive
FROM healthcare_clean
GROUP BY hospital
ORDER BY pct_abnormal DESC;


-- Q6. Medications by condition, and consistency across hospitals

SELECT medical_condition, medication, COUNT(*) AS prescriptions,
       RANK() OVER (PARTITION BY medical_condition ORDER BY COUNT(*) DESC) AS rnk
FROM healthcare_clean
GROUP BY medical_condition, medication
ORDER BY medical_condition, rnk;

-- Top medication per condition
SELECT medical_condition, medication, prescriptions
FROM (
    SELECT medical_condition, medication, COUNT(*) AS prescriptions,
           ROW_NUMBER() OVER (PARTITION BY medical_condition ORDER BY COUNT(*) DESC) AS rn
    FROM healthcare_clean
    GROUP BY medical_condition, medication
) t
WHERE rn = 1;

-- Consistency across hospitals: medication mix per hospital

SELECT hospital, medication, COUNT(*) AS prescriptions,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY hospital), 2) AS pct_within_hospital
FROM healthcare_clean
GROUP BY hospital, medication
ORDER BY hospital, prescriptions DESC;


-- Q7. Admission type: volume, length of stay, cost

SELECT admission_type,
       COUNT(*) AS patients,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct,
       ROUND(AVG(length_of_stay), 2) AS avg_los_days,
       ROUND(AVG(billing_amount), 2) AS avg_billing
FROM healthcare_clean
GROUP BY admission_type
ORDER BY patients DESC;

-- Admission type by hospital
SELECT hospital, admission_type, COUNT(*) AS patients
FROM healthcare_clean
GROUP BY hospital, admission_type
ORDER BY hospital, admission_type;


-- Q8. Insurance providers: coverage, cost, outcomes

SELECT insurance_provider,
       COUNT(*) AS patients,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_patients,
       ROUND(AVG(billing_amount), 2) AS avg_billing,
       ROUND(AVG(length_of_stay), 2) AS avg_los_days,
       ROUND(SUM(test_results = 'Abnormal') * 100.0 / COUNT(*), 2) AS pct_abnormal
FROM healthcare_clean
GROUP BY insurance_provider
ORDER BY patients DESC;

-- Insurer x test result
SELECT insurance_provider, test_results, COUNT(*) AS patients
FROM healthcare_clean
GROUP BY insurance_provider, test_results
ORDER BY insurance_provider, test_results;


-- Q9. Geography: hospital locations and regional differences

SELECT hospital, hospital_latitude, hospital_longitude,
       COUNT(*) AS patients,
       ROUND(AVG(billing_amount), 2) AS avg_billing,
       ROUND(AVG(length_of_stay), 2) AS avg_los_days,
       ROUND(SUM(test_results = 'Abnormal') * 100.0 / COUNT(*), 2) AS pct_abnormal
FROM healthcare_clean
GROUP BY hospital, hospital_latitude, hospital_longitude
ORDER BY patients DESC;

-- Most common condition per hospital
SELECT hospital, medical_condition, patients
FROM (
    SELECT hospital, medical_condition, COUNT(*) AS patients,
           ROW_NUMBER() OVER (PARTITION BY hospital ORDER BY COUNT(*) DESC) AS rn
    FROM healthcare_clean
    GROUP BY hospital, medical_condition
) t
WHERE rn = 1;


-- BONUS: Trends over time

SELECT YEAR(date_of_admission) AS admission_year,
       COUNT(*) AS patients,
       ROUND(AVG(billing_amount), 2) AS avg_billing,
       ROUND(AVG(length_of_stay), 2) AS avg_los_days
FROM healthcare_clean
GROUP BY YEAR(date_of_admission)
ORDER BY admission_year;

SELECT YEAR(date_of_admission) AS yr, MONTH(date_of_admission) AS mth,
       COUNT(*) AS patients
FROM healthcare_clean
GROUP BY YEAR(date_of_admission), MONTH(date_of_admission)
ORDER BY yr, mth;

