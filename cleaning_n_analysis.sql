CREATE DATABASE hr;

USE hr;

SELECT * FROM employee;

-- -----------------------------------------------------------------
-- data cleaning
--  -------------------------------------------------------------------

ALTER TABLE employee
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE employee;

SELECT birthdate FROM employee;

SET sql_safe_updates = 0;

UPDATE employee
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE employee
MODIFY COLUMN birthdate DATE;

UPDATE employee
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE employee
MODIFY COLUMN hire_date DATE;

UPDATE employee
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != ' ';

ALTER TABLE employee
MODIFY COLUMN termdate DATE;

ALTER TABLE employee ADD COLUMN age INT;

UPDATE employee
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM employee;

SELECT count(*) FROM employee WHERE age < 18;

SELECT COUNT(*) FROM employee WHERE termdate > CURDATE();

SELECT COUNT(*)
FROM employee
WHERE termdate = '0000-00-00';

SELECT location FROM employee;

-- ---------------------------------------------------------------
-- analysis
-- ---------------------------------------------------------------

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS count
FROM employee
WHERE age >= 18
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS count
FROM employee
WHERE age >= 18
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT 
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+' 
  END AS age_group, 
  COUNT(*) AS count
FROM 
  employee
WHERE 
  age >= 18
GROUP BY age_group
ORDER BY age_group;



SELECT 
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+' 
  END AS age_group, gender,
  COUNT(*) AS count
FROM 
  employee
WHERE 
  age >= 18
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) as count
FROM employee
WHERE age >= 18
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT ROUND(AVG(DATEDIFF(termdate, hire_date))/365,0) AS avg_length_of_employment
FROM employee
WHERE termdate <> '0000-00-00' AND termdate <= CURDATE() AND age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, COUNT(*) as count
FROM employee
WHERE age >= 18
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) as count
FROM employee
WHERE age >= 18
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest termination rate?
select department,
    total_count,
    terminated_count,
    terminated_count/total_count as termination_rate
from(
    select department,
    count(*) as total_count,
    sum(case when termdate<>'0000-00-00' and termdate <= curdate() then 1 else 0 End) as terminated_count
    from employee
    where age>=18
    group by department
    ) as subquery
order by termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, COUNT(*) as count
FROM employee
WHERE age >= 18
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
    year, 
    hires, 
    terminations, 
    (hires - terminations) AS net_change,
    ROUND(((hires - terminations) / hires * 100), 2) AS net_change_percent
FROM (
    SELECT 
	YEAR(hire_date) AS year, 
	COUNT(*) AS hires, 
	SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM employee
    WHERE age >= 18
    GROUP BY YEAR(hire_date)
    ) as subquery
ORDER BY year ASC;
    
-- 11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(DATEDIFF(CURDATE(), termdate)/365),0) as avg_tenure
FROM employee
WHERE termdate <= CURDATE() AND termdate <> '0000-00-00' AND age >= 18
GROUP BY department;