-- SQL Project: Comprehensive Employee Data Analysis
-- This script contains all 41 queries from the project plan.

-- Part 1: Foundational & Demographic Analysis

-- Query 1: What is the total number of employees?
SELECT COUNT("Employee ID") AS total_employees FROM employees;

-- Query 2: What is the overall employee distribution by gender?
SELECT Gender, COUNT("Employee ID") AS num_employees, ROUND(COUNT("Employee ID") * 100.0 / (SELECT COUNT(*) FROM employees), 2) AS percentage
FROM employees
GROUP BY Gender;

-- Query 3: What is the employee distribution across different departments?
SELECT Department, COUNT("Employee ID") AS num_employees
FROM employees
GROUP BY Department
ORDER BY num_employees DESC;

-- Query 4: What is the gender distribution within each department?
SELECT Department, Gender, COUNT("Employee ID") AS num_employees
FROM employees
GROUP BY Department, Gender
ORDER BY Department, Gender;

-- Query 5: What is the average tenure (years at the company) of all employees?
SELECT ROUND(AVG("Years at Company"), 2) AS average_tenure_years
FROM employees;


-- Part 2: Attrition (Turnover) Analysis

-- Query 6: What is the overall attrition rate?
SELECT Attrition, COUNT("Employee ID") AS num_employees, ROUND(COUNT("Employee ID") * 100.0 / (SELECT COUNT(*) FROM employees), 2) AS percentage
FROM employees
GROUP BY Attrition;

-- Query 7: Which department has the highest attrition rate?
SELECT Department, COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS attrition_count, COUNT("Employee ID") AS total_employees, ROUND((COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT("Employee ID")), 2) AS attrition_rate
FROM employees
GROUP BY Department
ORDER BY attrition_rate DESC;

-- Query 8: How does attrition correlate with performance rating?
SELECT "Performance Rating", COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS attrition_count, COUNT("Employee ID") AS total_employees, ROUND((COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT("Employee ID")), 2) AS attrition_rate
FROM employees
GROUP BY "Performance Rating"
ORDER BY "Performance Rating";

-- Query 9: What is the attrition rate by gender?
SELECT Gender, ROUND(COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT("Employee ID"), 2) AS attrition_rate_percentage
FROM employees
GROUP BY Gender;

-- Query 10: Is there a relationship between years at the company and attrition?
WITH TenureBuckets AS (
    SELECT "Employee ID", Attrition,
        CASE
            WHEN "Years at Company" <= 2 THEN '0-2 Years'
            WHEN "Years at Company" BETWEEN 3 AND 5 THEN '3-5 Years'
            WHEN "Years at Company" BETWEEN 6 AND 10 THEN '6-10 Years'
            ELSE '10+ Years'
        END AS tenure_bucket
    FROM employees
)
SELECT tenure_bucket, COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS attrition_count, COUNT("Employee ID") AS total_employees, ROUND(COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT("Employee ID"), 2) AS attrition_rate
FROM TenureBuckets
GROUP BY tenure_bucket
ORDER BY tenure_bucket;


-- Part 3: Compensation & Pay Equity Analysis

-- Query 11: What is the average salary across the company?
SELECT ROUND(AVG(Salary), 2) AS company_average_salary
FROM employees;

-- Query 12: What is the average salary by department?
SELECT Department, ROUND(AVG(Salary), 2) AS average_salary
FROM employees
GROUP BY Department
ORDER BY average_salary DESC;

-- Query 13: What is the average salary by gender? (Company-wide pay gap)
SELECT Gender, ROUND(AVG(Salary), 2) AS average_salary
FROM employees
GROUP BY Gender;

-- Query 14: How does the gender pay gap look within each department?
SELECT Department, Gender, ROUND(AVG(Salary), 2) AS average_salary
FROM employees
GROUP BY Department, Gender
ORDER BY Department, average_salary DESC;

-- Query 15: Who are the top 5 highest-paid employees in the company?
SELECT "Full Name", Department, Salary
FROM employees
ORDER BY Salary DESC
LIMIT 5;

-- Query 16: Who are the top 3 highest-paid employees in each department?
WITH RankedSalaries AS (
    SELECT "Full Name", Department, Salary, DENSE_RANK() OVER(PARTITION BY Department ORDER BY Salary DESC) as salary_rank
    FROM employees
)
SELECT "Full Name", Department, Salary
FROM RankedSalaries
WHERE salary_rank <= 3;

-- Query 17: What is the distribution of employees across different salary brackets?
WITH SalaryBuckets AS (
    SELECT "Employee ID",
        CASE
            WHEN Salary < 50000 THEN '1. < $50k'
            WHEN Salary BETWEEN 50000 AND 80000 THEN '2. $50k - $80k'
            WHEN Salary BETWEEN 80001 AND 120000 THEN '3. $80k - $120k'
            ELSE '4. > $120k'
        END AS salary_range
    FROM employees
)
SELECT salary_range, COUNT("Employee ID") AS num_employees
FROM SalaryBuckets
GROUP BY salary_range
ORDER BY salary_range;

-- Query 18: How does average salary correlate with performance rating?
SELECT "Performance Rating", ROUND(AVG(Salary), 2) AS average_salary
FROM employees
GROUP BY "Performance Rating"
ORDER BY "Performance Rating";


-- Part 4: Performance & Tenure Analysis

-- Query 19: What is the average performance rating for the company?
SELECT ROUND(AVG("Performance Rating"), 2) AS average_performance_rating
FROM employees;

-- Query 20: Which department has the highest average performance rating?
SELECT Department, ROUND(AVG("Performance Rating"), 2) AS avg_performance
FROM employees
GROUP BY Department
ORDER BY avg_performance DESC;

-- Query 21: What is the distribution of performance ratings?
SELECT "Performance Rating", COUNT("Employee ID") AS num_employees
FROM employees
GROUP BY "Performance Rating"
ORDER BY "Performance Rating";

-- Query 22: How does tenure affect performance rating?
SELECT
    CASE
        WHEN "Years at Company" <= 2 THEN '0-2 Years'
        WHEN "Years at Company" BETWEEN 3 AND 5 THEN '3-5 Years'
        ELSE '5+ Years'
    END AS tenure_bucket,
    ROUND(AVG("Performance Rating"), 2) AS avg_performance
FROM employees
GROUP BY tenure_bucket
ORDER BY tenure_bucket;

-- Query 23: Who are the longest-serving employees? (Top 5)
SELECT "Full Name", Department, "Years at Company"
FROM employees
ORDER BY "Years at Company" DESC
LIMIT 5;

-- Query 24: What is the average tenure by department?
SELECT Department, ROUND(AVG("Years at Company"), 2) AS avg_tenure_years
FROM employees
GROUP BY Department
ORDER BY avg_tenure_years DESC;


-- Part 5: Advanced & Combined Insights

-- Query 25: Who are the high-performing employees (rating > 4) with low salaries (below dept avg)?
WITH DeptAvgSalary AS (
    SELECT Department, AVG(Salary) as avg_dept_salary
    FROM employees
    GROUP BY Department
)
SELECT e."Full Name", e.Department, e.Salary, e."Performance Rating", ROUND(d.avg_dept_salary, 2) AS avg_dept_salary
FROM employees e
JOIN DeptAvgSalary d ON e.Department = d.Department
WHERE e."Performance Rating" > 4 AND e.Salary < d.avg_dept_salary;

-- Query 26: What is the attrition rate for employees with tenure less than 2 years?
SELECT ROUND(COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT("Employee ID"), 2) AS early_attrition_rate
FROM employees
WHERE "Years at Company" <= 2;

-- Query 27: How does the salary of employees who left compare to those who stayed, by department?
SELECT Department, Attrition, ROUND(AVG(Salary), 2) AS average_salary
FROM employees
GROUP BY Department, Attrition
ORDER BY Department, Attrition;

-- Query 28: Which department has the biggest salary range (max salary - min salary)?
SELECT Department, MAX(Salary) - MIN(Salary) AS salary_range
FROM employees
GROUP BY Department
ORDER BY salary_range DESC
LIMIT 1;

-- Query 29: What is the performance rating distribution for employees who have left the company?
SELECT "Performance Rating", COUNT("Employee ID") AS num_employees
FROM employees
WHERE Attrition = 'Yes'
GROUP BY "Performance Rating"
ORDER BY "Performance Rating";

-- Query 30: What is the ratio of the highest salary to the lowest salary in each department?
SELECT Department, ROUND(MAX(Salary) * 1.0 / MIN(Salary), 2) AS salary_ratio
FROM employees
GROUP BY Department
ORDER BY salary_ratio DESC;

-- Query 31: Find departments where the average tenure of employees who left is higher than the company average tenure.
SELECT Department
FROM employees
WHERE Attrition = 'Yes'
GROUP BY Department
HAVING AVG("Years at Company") > (SELECT AVG("Years at Company") FROM employees);


-- Part 6: Advanced Scenarios with Window Functions

-- Query 32: For each employee, show their salary and the salary of the next-highest paid employee in their department.
SELECT
    "Full Name",
    Department,
    Salary,
    LEAD(Salary, 1) OVER (PARTITION BY Department ORDER BY Salary DESC) AS next_highest_salary
FROM
    employees;

-- Query 33: For each employee, calculate the difference between their salary and the salary of the employee directly below them in their department.
SELECT
    "Full Name",
    Department,
    Salary,
    Salary - LAG(Salary, 1, 0) OVER (PARTITION BY Department ORDER BY Salary DESC) AS difference_from_previous
FROM
    employees;

-- Query 34: Divide employees in each department into four salary quartiles (groups).
SELECT
    "Full Name",
    Department,
    Salary,
    NTILE(4) OVER (PARTITION BY Department ORDER BY Salary DESC) AS salary_quartile
FROM
    employees;

-- Query 35: Find the cumulative salary distribution within each department.
SELECT
    "Full Name",
    Department,
    Salary,
    ROUND(CUME_DIST() OVER (PARTITION BY Department ORDER BY Salary) * 100, 2) AS salary_percentile_rank
FROM
    employees;

-- Query 36: Calculate the rolling 3-employee average salary within each department.
SELECT
    "Full Name",
    Department,
    Salary,
    AVG(Salary) OVER (PARTITION BY Department ORDER BY "Years at Company" ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS rolling_3_person_avg_salary
FROM
    employees;

-- Query 37: Identify employees whose salary is greater than the average salary of their respective department.
WITH DepartmentAvg AS (
    SELECT
        "Employee ID",
        Department,
        Salary,
        AVG(Salary) OVER (PARTITION BY Department) AS avg_dept_salary
    FROM employees
)
SELECT
    "Employee ID",
    Department,
    Salary,
    ROUND(avg_dept_salary, 2) AS department_average_salary
FROM DepartmentAvg
WHERE Salary > avg_dept_salary;


-- Part 7: Blinkit-Inspired Business Scenarios

-- Query 38: Inventory Management: Identify "Over-stocked" vs. "Under-stocked" Departments.
SELECT
    Department,
    COUNT("Employee ID") AS num_employees,
    ROUND(AVG("Performance Rating"), 2) AS avg_performance,
    CASE
        WHEN AVG("Performance Rating") < 3.0 AND COUNT("Employee ID") > 50 THEN 'Over-stocked (Low Performance, High Headcount)'
        WHEN AVG("Performance Rating") > 4.0 AND COUNT("Employee ID") < 20 THEN 'Under-stocked (High Performance, Low Headcount)'
        ELSE 'Balanced'
    END AS department_status
FROM
    employees
GROUP BY
    Department
ORDER BY
    avg_performance;

-- Query 39: Customer Segmentation: Segment Employees like Customers.
SELECT
    "Full Name",
    "Performance Rating",
    "Years at Company",
    Salary,
    CASE
        WHEN "Performance Rating" >= 4 AND "Years at Company" >= 5 THEN 'High-Value (Top Performer, Loyal)'
        WHEN "Performance Rating" < 3 AND Attrition = 'No' THEN 'At-Risk (Low Performer)'
        WHEN "Performance Rating" >= 4 AND "Years at Company" < 2 THEN 'Rising Star (High Potential)'
        ELSE 'Core Employee'
    END AS employee_segment
FROM
    employees
WHERE Attrition = 'No';

-- Query 40: Delivery Route Optimization: Find the "Most Efficient" Career Paths.
WITH SalaryQuartiles AS (
    SELECT
        "Employee ID",
        Department,
        "Years at Company",
        NTILE(4) OVER (PARTITION BY Department ORDER BY Salary) AS salary_quartile
    FROM employees
)
SELECT
    Department,
    ROUND(AVG("Years at Company"), 2) AS avg_years_to_top_quartile
FROM
    SalaryQuartiles
WHERE
    salary_quartile = 4 -- Top 25% of earners
GROUP BY
    Department
ORDER BY
    avg_years_to_top_quartile ASC;

-- Query 41: Sales Forecasting: Predict Future Attrition "Hotspots".
WITH TenurePerformance AS (
    SELECT
        Department,
        AVG(CASE WHEN "Years at Company" <= 2 THEN "Performance Rating" END) AS avg_rating_new_hires,
        AVG(CASE WHEN "Years at Company" > 5 THEN "Performance Rating" END) AS avg_rating_veterans
    FROM
        employees
    GROUP BY
        Department
)
SELECT
    Department,
    ROUND(avg_rating_new_hires, 2) AS new_hire_performance,
    ROUND(avg_rating_veterans, 2) AS veteran_performance
FROM
    TenurePerformance
WHERE
    avg_rating_new_hires < avg_rating_veterans
ORDER BY
    (avg_rating_veterans - avg_rating_new_hires) DESC;
