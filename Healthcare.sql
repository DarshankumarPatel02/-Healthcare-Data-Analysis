--Demographic Distribution:

--What is the total count of patients by gender?
select Gender,count(*)"Patients Count" from health_care_data
group by gender;

--What is the distribution of blood types among patients?
select Gender,blood_type,count(*)"Patients Count" from health_care_data
group by gender,blood_type order by gender;
-----------------------or-----------------------------------------
--Adds subtotal rows for each Gender and a grand total row.
SELECT Gender, blood_type, COUNT(*) AS "Patients Count"
FROM health_care_data
GROUP BY ROLLUP(Gender, blood_type)
ORDER BY blood_type,Gender,count(*);
-----------------------or-----------------------------------------
SELECT 
    COALESCE(Gender, 'Grand Total') AS Gender,
    COALESCE(blood_type, 'Subtotal for ' + COALESCE(Gender, 'whole')) AS blood_type,
    COUNT(*) AS "Patients Count"
FROM health_care_data
GROUP BY ROLLUP(Gender, blood_type)
ORDER BY 
    GROUPING(Gender),       -- Ensures subtotals and grand total come after detail rows
    Gender,                 -- Orders by Gender
    GROUPING(blood_type),   -- Ensures subtotals for blood_type come after detail rows for each gender
    blood_type;             -- Orders by blood_type within each Gender

--What is the average age of patients in the dataset?
select avg(age) as avg_age from health_care_data;

-- Admissions Overview:
--How many patients were admitted each month?
select datename(month,date_of_admission) as "Month",count(*) as "Patient Count" from health_care_data
group by datename(month,date_of_admission);

--How many patients were admitted in each hospital?
select hospital "Hospital_Name",count(*) "Patient Count" from health_care_data 
group by hospital order by count(*) desc;

--What is the average number of days between Date of Admission and Discharge Date?

--SELECT Name,DATEDIFF(day, date_of_admission, discharge_date) AS AvgDays
-- from health_care_data;

SELECT AVG(DATEDIFF(day, date_of_admission, discharge_date)) AS AvgDays
from health_care_data;
-----------------------------	or------------------------------------------------
SELECT AVG(CAST(CAST(discharge_date AS DATETIME) - CAST(date_of_admission AS DATETIME) AS INT)) AS AvgDays
FROM health_care_data;


-- Medical Condition Analysis:
--What are the most common medical conditions among patients?
--What is the number of patients with each medical condition?
select medical_condition,count(*)
as Total from health_care_data
group by medical_condition;


-- Billing Summary:
--What is the total Billing Amount for all patients?
select round(sum(billing_amount),2)"Total Billing Amount" from health_care_data;

--What is the average, minimum, and maximum Billing Amount across all patients?
select round(avg(billing_amount),2)"Average Billing Amount" from health_care_data;
select round(min(billing_amount),2)"Maximum Billing Amount" from health_care_data;
select round(max(billing_amount),2)"Minimum Billing Amount" from health_care_data;

-- What is the sum of Billing Amount grouped by Insurance Provider?
select insurance_provider,round(sum(billing_amount),2)"Total Billing Amount" from health_care_data
group by insurance_provider;

--Room Usage:
--How many patients were admitted to each Room Number?
select room_number,count(*) "Patient Count" from health_care_data
group by room_number order by count(*) desc;
--Which rooms had the highest billing amounts?
select room_number,round(MAX(billing_amount),2) "Max Billing" from health_care_data
group by room_number;


--Intermediate-Level SQL Queries
--Segmentation by Age:
--Segment patients into age groups (e.g., 0-20, 21-40, 41-60, 61+) and find the average billing amount for each segment.
SELECT 
    CASE
        WHEN age BETWEEN 0 AND 20 THEN '0-20'
        WHEN age BETWEEN 21 AND 40 THEN '21-40'
        WHEN age BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END AS Age_Category,
    ROUND(AVG(billing_amount),2) AS Avg_Billing_Amount
FROM 
    health_care_data
GROUP BY 
    CASE
        WHEN age BETWEEN 0 AND 20 THEN '0-20'
        WHEN age BETWEEN 21 AND 40 THEN '21-40'
        WHEN age BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END
ORDER BY 
    Age_Category;

--What is the most common medical condition within each age group?
--USING CTE-----
WITH Age_Segment as
(
	SELECT
	CASE WHEN age BETWEEN 0 AND 20 THEN '0-20'
	     WHEN age BETWEEN 21 AND 40 THEN '21-40'
	     WHEN age BETWEEN 41 AND 60 THEN '41-60'
		 ELSE '60+'
	END AS Age_Category,
	medical_condition from
	health_care_data
)
select
	Age_Category,medical_condition,
	count(*) as "Patient Count"
	from Age_Segment
group by Age_category,medical_condition
order by Age_category,medical_condition;

--Admission Type Analysis:
--What is the proportion of Elective vs. Emergency admissions?
select admission_type,count(*) as Patient_COUNT,
FORMAT(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM health_care_data),'N2') AS Patient_Proportion
from health_care_data
where admission_type IN ('Elective','Emergency')
group by admission_type;

--What is the average billing amount for Elective and Emergency admissions?
select admission_type,avg(billing_amount) as avg_billing from health_care_data
where admission_type IN ('Elective','Emergency')
group by admission_type;

--What is the average length of stay for each admission type?

SELECT admission_type,AVG(DATEDIFF(day, date_of_admission, discharge_date)) AS AvgDays
from health_care_data
group by admission_type;

--Time-Based Billing Trends:

--How has the average Billing Amount changed month over month?
select datename(month,date_of_admission) as "MONTH",YEAR(date_of_admission) "YEAR",avg(billing_amount) "AVG_BILL"
from health_care_data
group by datename(month,date_of_admission),YEAR(date_of_admission),MONTH(date_of_admission)
order by YEAR,MONTH(date_of_admission);


--What is the average length of stay by Date of Admission (group by year/month)?
select datename(month,date_of_admission) as "MONTH",YEAR(date_of_admission) "YEAR",
AVG(DATEDIFF(day, date_of_admission, discharge_date)) AS AvgDays
from health_care_data
group by datename(month,date_of_admission),YEAR(date_of_admission),MONTH(date_of_admission)
order by YEAR,MONTH(date_of_admission);

--Medication Patterns:

--What is the most prescribed medication for each medical condition?
select medical_condition,medication,count(*) as "Perscribed_Count" from health_care_data 
group by medical_condition,medication
order by count(*) desc;

--What is the average billing amount for patients prescribed each type of medication?
select medical_condition,medication,round(avg(billing_amount),2) as "AVG_BILL" from health_care_data 
group by medical_condition,medication
order by avg(billing_amount);

--Doctor Performance Analysis:
--Which doctor has the highest average billing amount for their patients?
select doctor,avg(billing_amount) as "avgbillamount" from health_care_data
group by doctor order by avg(billing_amount) desc;

--What is the average length of stay for patients under each doctor?
select doctor,AVG(DATEDIFF(day, date_of_admission, discharge_date)) AS AvgDays
from health_care_data
group by doctor
order by AvgDays desc;


--Window Functions (Cumulative and Ranking):
--Rank patients by Billing Amount within each Hospital using a window function.
SELECT 
    hospital,
    Name,
    billing_amount,
    RANK() OVER (PARTITION BY hospital ORDER BY billing_amount DESC) AS BillingRank
FROM 
    health_care_data;

--Calculate the cumulative total Billing Amount for patients by Date of Admission.
SELECT 
    date_of_admission,
    Name,
    round(billing_amount,2) "BillingAmount",
    round(SUM(billing_amount) OVER (ORDER BY date_of_admission),2) AS CumulativeBillingAmount
FROM 
    health_care_data
ORDER BY 
    date_of_admission;

--Segmentation Based on Billing:

--Segment patients into high-billing and low-billing categories based on the median billing amount.--
-- Calculate the Median Billing Amount
-- Calculate Billing Quartiles
WITH BillingDistribution AS (
    SELECT 
        name,
        billing_amount,
        NTILE(2) OVER (ORDER BY billing_amount) AS BillingQuartile
    FROM 
        health_care_data
)

-- Segment patients based on the quartiles
SELECT 
    name,
    billing_amount,
    CASE
        WHEN BillingQuartile = 2 THEN 'High-Billing'
        ELSE 'Low-Billing'
    END AS BillingCategory
FROM 
    BillingDistribution
ORDER BY 
    billing_amount;

--For each segment, what is the average length of stay and most common medical condition?
WITH SegmentedData AS (
    SELECT
        name,
        DATEDIFF(day, date_of_admission, discharge_date) AS length_of_stay,
        medical_condition,
        CASE
            WHEN age BETWEEN 0 AND 20 THEN '0-20'
            WHEN age BETWEEN 21 AND 40 THEN '21-40'
            WHEN age BETWEEN 41 AND 60 THEN '41-60'
            ELSE '61+'
        END AS age_category
    FROM
        health_care_data
),

AverageLengthOfStay AS (
    SELECT
        age_category,
        AVG(length_of_stay) AS avg_length_of_stay
    FROM
        SegmentedData
    GROUP BY
        age_category
),

MostCommonCondition AS (
    SELECT
        age_category,
        medical_condition,
        COUNT(*) AS condition_count
    FROM
        SegmentedData
    GROUP BY
        age_category, medical_condition
),

RankedConditions AS (
    SELECT
        age_category,
        medical_condition,
        condition_count,
        ROW_NUMBER() OVER (PARTITION BY age_category ORDER BY condition_count DESC) AS rn
    FROM
        MostCommonCondition
)

SELECT
    A.age_category,
    A.avg_length_of_stay,
    R.medical_condition AS most_common_condition
FROM
    AverageLengthOfStay A
JOIN
    RankedConditions R
ON
    A.age_category = R.age_category
WHERE
    R.rn = 1
ORDER BY
    A.age_category;


--Group by Doctor and calculate the percentile rank of each doctor based on the total Billing Amount.
WITH DoctorBilling AS (
    SELECT 
        doctor,
        SUM(billing_amount) AS total_billing
    FROM 
        health_care_data
    GROUP BY 
        doctor
),
RankedBilling AS (
    SELECT 
        doctor,
        total_billing,
        PERCENT_RANK() OVER (ORDER BY total_billing DESC) AS percentile_rank
    FROM 
        DoctorBilling
)

SELECT 
    doctor,
    total_billing,
    percentile_rank
FROM 
    RankedBilling
ORDER BY 
    percentile_rank DESC;

--Group patients by Blood Type and calculate the average Billing Amount and length of stay for each group.
SELECT 
    blood_type,
    AVG(billing_amount) AS avg_billing_amount,
    AVG(DATEDIFF(day, date_of_admission, discharge_date)) AS avg_length_of_stay
FROM 
    health_care_data
GROUP BY 
    blood_type;

--Trend Analysis:
--Analyze if there is any seasonal pattern in the admissions for specific medical conditions by grouping Date of Admission 
-- by month.
SELECT 
    MONTH(date_of_admission) AS admission_month,
    medical_condition,
    COUNT(*) AS num_admissions,
    AVG(billing_amount) AS avg_billing_amount
FROM 
    health_care_data
GROUP BY 
    MONTH(date_of_admission), medical_condition
ORDER BY 
    admission_month;

--Identify time periods (months or years) where there is a spike in certain Medical Conditions and analyze related 
-- Billing Amounts.
WITH MonthlyAdmissions AS (
    SELECT 
        YEAR(date_of_admission) AS admission_year,
        MONTH(date_of_admission) AS admission_month,
        medical_condition,
        COUNT(*) AS num_admissions,
        AVG(billing_amount) AS avg_billing_amount
    FROM 
        health_care_data
    GROUP BY 
        YEAR(date_of_admission), MONTH(date_of_admission), medical_condition
)

SELECT TOP 10
    admission_year,
    admission_month,
    medical_condition,
    num_admissions,
    avg_billing_amount
FROM 
    MonthlyAdmissions
ORDER BY 
    num_admissions DESC

--Rank the top 5 patients in each hospital based on the length of stay using a window function.
WITH PatientRankings AS (
    SELECT 
        Name,
        DATEDIFF(day, date_of_admission, discharge_date) AS length_of_stay,
        RANK() OVER (PARTITION BY Name ORDER BY DATEDIFF(day, date_of_admission, discharge_date) DESC) AS rank
    FROM 
        health_care_data
)

SELECT 
    Name,
    length_of_stay,
    rank
FROM 
    PatientRankings
WHERE 
    rank <= 5
ORDER BY 
    Name, rank;
