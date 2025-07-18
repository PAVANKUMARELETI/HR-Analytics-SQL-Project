-- SQL Project: Comprehensive HR Analysis
-- This script has been updated to use the new dataset schema.

-- Part 1: Foundational & Demographic Analysis

-- Query 1: What is the total number of employees?
SELECT COUNT(emp_no) AS total_employees FROM employees;

-- Query 2: What is the overall employee distribution by gender?
SELECT gender, COUNT(emp_no) AS num_employees, ROUND(COUNT(emp_no) * 100.0 / (SELECT COUNT(*) FROM employees), 2) AS percentage
FROM employees
GROUP BY gender;

-- Query 3: What is the employee distribution across different departments?
SELECT department, COUNT(emp_no) AS num_employees
FROM employees
GROUP BY department
ORDER BY num_employees DESC;

-- Query 4: What is the gender distribution within each department?
SELECT department, gender, COUNT(emp_no) AS num_employees
FROM employees
GROUP BY department, gender
ORDER BY department, gender;

-- Query 5: What is the distribution of employees by marital status?
SELECT marital_status, COUNT(emp_no) AS num_employees
FROM employees
GROUP BY marital_status
ORDER BY num_employees DESC;

-- Query 6: What is the distribution of employees by age band?
SELECT age_band, COUNT(emp_no) AS num_employees
FROM employees
GROUP BY age_band
ORDER BY age_band;


-- Part 2: Attrition Analysis

-- Query 7: What is the overall attrition rate?
SELECT attrition, COUNT(emp_no) AS num_employees, ROUND(COUNT(emp_no) * 100.0 / (SELECT COUNT(*) FROM employees), 2) AS percentage
FROM employees
GROUP BY attrition;

-- Query 8: Which department has the highest attrition rate?
SELECT department, COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS attrition_count, COUNT(emp_no) AS total_employees, ROUND((COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(emp_no)), 2) AS attrition_rate
FROM employees
GROUP BY department
ORDER BY attrition_rate DESC;

-- Query 9: How does attrition correlate with job satisfaction?
SELECT job_satisfaction, COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS attrition_count, COUNT(emp_no) AS total_employees, ROUND((COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(emp_no)), 2) AS attrition_rate
FROM employees
GROUP BY job_satisfaction
ORDER BY job_satisfaction;

-- Query 10: What is the attrition rate by gender?
SELECT gender, ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(emp_no), 2) AS attrition_rate_percentage
FROM employees
GROUP BY gender;

-- Query 11: How does marital status affect attrition?
SELECT marital_status, ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(emp_no), 2) AS attrition_rate_percentage
FROM employees
GROUP BY marital_status
ORDER BY attrition_rate_percentage DESC;

-- Query 12: What is the attrition rate based on business travel frequency?
SELECT business_travel, ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(emp_no), 2) AS attrition_rate_percentage
FROM employees
GROUP BY business_travel
ORDER BY attrition_rate_percentage DESC;


-- Part 3: Job Role & Education Analysis

-- Query 13: What is the average job satisfaction across the company?
SELECT ROUND(AVG(job_satisfaction), 2) AS company_average_satisfaction
FROM employees;

-- Query 14: Which department has the highest average job satisfaction?
SELECT department, ROUND(AVG(job_satisfaction), 2) AS average_satisfaction
FROM employees
GROUP BY department
ORDER BY average_satisfaction DESC;

-- Query 15: What is the average job satisfaction by job role?
SELECT job_role, ROUND(AVG(job_satisfaction), 2) AS average_satisfaction
FROM employees
GROUP BY job_role
ORDER BY average_satisfaction DESC;

-- Query 16: What are the most common education fields?
SELECT education_field, COUNT(emp_no) AS num_employees
FROM employees
GROUP BY education_field
ORDER BY num_employees DESC;

-- Query 17: Which job roles have the highest number of employees who have left?
SELECT job_role, COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) as attrition_count
FROM employees
GROUP BY job_role
ORDER BY attrition_count DESC;

-- Query 18: What is the distribution of education levels?
SELECT education, COUNT(emp_no) as num_employees
FROM employees
GROUP BY education
ORDER BY education;


-- Part 4: Advanced Scenarios with Window Functions

-- Query 19: Rank job roles within each department by the number of employees.
WITH RoleCounts AS (
    SELECT department, job_role, COUNT(emp_no) as num_employees
    FROM employees
    GROUP BY department, job_role
)
SELECT department, job_role, num_employees,
       RANK() OVER(PARTITION BY department ORDER BY num_employees DESC) as role_rank_in_dept
FROM RoleCounts;

-- Query 20: What is the job satisfaction percentile for each employee within their department?
SELECT
    emp_no,
    department,
    job_satisfaction,
    ROUND(CUME_DIST() OVER (PARTITION BY department ORDER BY job_satisfaction) * 100, 2) AS satisfaction_percentile_rank
FROM
    employees;

-- Query 21: For each employee, find the average job satisfaction of their department.
SELECT
    emp_no,
    department,
    job_satisfaction,
    AVG(job_satisfaction) OVER (PARTITION BY department) as avg_dept_satisfaction
FROM employees;

-- Query 22: Identify employees with job satisfaction lower than their department's average.
WITH DeptSatisfaction AS (
    SELECT
        emp_no,
        department,
        job_satisfaction,
        AVG(job_satisfaction) OVER (PARTITION BY department) AS avg_dept_satisfaction
    FROM employees
)
SELECT
    emp_no,
    department,
    job_satisfaction,
    ROUND(avg_dept_satisfaction, 2) AS department_average_satisfaction
FROM DeptSatisfaction
WHERE job_satisfaction < avg_dept_satisfaction;


-- Part 5: Blinkit-Inspired Business Scenarios

-- Query 23: Customer Segmentation: Segment employees based on satisfaction and age.
SELECT
    emp_no,
    job_satisfaction,
    age_band,
    CASE
        WHEN job_satisfaction >= 4 AND age_band IN ('45-55', 'Over 55') THEN 'High-Value (Satisfied Veteran)'
        WHEN job_satisfaction < 3 AND attrition = 'No' THEN 'At-Risk (Unsatisfied Employee)'
        WHEN job_satisfaction >= 4 AND age_band IN ('Under 25', '25-34') THEN 'Rising Star (Satisfied Youth)'
        ELSE 'Core Employee'
    END AS employee_segment
FROM
    employees
WHERE attrition = 'No';

-- Query 24: Inventory Management: Identify "High-Satisfaction" vs. "Low-Satisfaction" Departments.
SELECT
    department,
    COUNT(emp_no) AS num_employees,
    ROUND(AVG(job_satisfaction), 2) AS avg_satisfaction,
    CASE
        WHEN AVG(job_satisfaction) < 2.5 THEN 'Intervention Needed (Low Satisfaction)'
        WHEN AVG(job_satisfaction) > 3.5 THEN 'High-Performing (High Satisfaction)'
        ELSE 'Balanced'
    END AS department_status
FROM
    employees
GROUP BY
    department
ORDER BY
    avg_satisfaction;

-- Query 25: Attrition Forecasting: Find departments where job satisfaction for younger employees is lower than for older employees.
WITH AgeBandSatisfaction AS (
    SELECT
        department,
        AVG(CASE WHEN age_band IN ('Under 25', '25-34') THEN job_satisfaction END) AS avg_satisfaction_young,
        AVG(CASE WHEN age_band IN ('45-55', 'Over 55') THEN job_satisfaction END) AS avg_satisfaction_veteran
    FROM
        employees
    GROUP BY
        department
)
SELECT
    department,
    ROUND(avg_satisfaction_young, 2) AS young_employee_satisfaction,
    ROUND(avg_satisfaction_veteran, 2) AS veteran_employee_satisfaction
FROM
    AgeBandSatisfaction
WHERE
    avg_satisfaction_young < avg_satisfaction_veteran
ORDER BY
    (avg_satisfaction_veteran - avg_satisfaction_young) DESC;
