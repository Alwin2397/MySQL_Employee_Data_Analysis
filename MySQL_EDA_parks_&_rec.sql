-- Employees with salaries above their department's average and rank them by the difference --
WITH DepartmentAverage AS (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM employee_salary
    GROUP BY dept_id
)
SELECT emp_sal.first_name, emp_sal.last_name, pd.department_name,
       emp_sal.salary, da.avg_salary,
       (emp_sal.salary - da.avg_salary) AS salary_difference,
       RANK() OVER (ORDER BY (emp_sal.salary - da.avg_salary) DESC) AS `Rank`
FROM employee_salary emp_sal
JOIN parks_departments pd
   ON emp_sal.dept_id = pd.department_id
JOIN DepartmentAverage da
   ON emp_sal.dept_id = da.dept_id
WHERE emp_sal.salary > da.avg_salary
;

-- Determining which employees would be impacted by a 10% budget cut by department --

WITH BudgetCut AS (
    SELECT dept_id, SUM(salary) * 0.90 AS reduced_budget
    FROM employee_salary
    GROUP BY dept_id
),
EmployeeImpact AS (
    SELECT emp_sal.employee_id, emp_sal.first_name, emp_sal.last_name, emp_sal.salary,
           bc.reduced_budget, emp_sal.salary - (SUM(emp_sal.salary) OVER (PARTITION BY emp_sal.dept_id)) + bc.reduced_budget AS remaining_salary
    FROM employee_salary emp_sal
    JOIN BudgetCut bc
       ON emp_sal.dept_id = bc.dept_id
)
SELECT first_name, last_name, salary, remaining_salary
FROM EmployeeImpact
WHERE remaining_salary < 0
;

-- Simulating a promotion cycle: Promote the youngest employee in each department and increase their salary by 10%. --

WITH YoungestEmployees AS (
    SELECT emp_sal.employee_id, emp_sal.first_name, emp_sal.last_name, emp_sal.salary, emp_sal.dept_id
    FROM employee_demographics emp_dem
    JOIN employee_salary emp_sal
       ON emp_dem.employee_id = emp_sal.employee_id
    WHERE emp_dem.age = (SELECT MIN(emp_dem2.age)
                         FROM employee_demographics emp_dem2
                         JOIN employee_salary emp_sal2
                            ON emp_dem2.employee_id = emp_sal2.employee_id
                         WHERE emp_sal2.dept_id = emp_sal.dept_id)
)
UPDATE employee_salary
SET salary = salary * 1.10
WHERE employee_id IN (SELECT employee_id FROM YoungestEmployees)
;

-- Departmental salary distributions by percentile --

WITH PercentileCalc AS (
    SELECT pd.department_name, emp_sal.first_name, emp_sal.last_name, emp_sal.salary,
           NTILE(4) OVER (PARTITION BY pd.department_name ORDER BY emp_sal.salary DESC) AS quartile
    FROM employee_salary emp_sal
    JOIN parks_departments pd
       ON emp_sal.dept_id = pd.department_id
)
SELECT department_name, quartile, COUNT(*) AS employee_count, AVG(salary) AS avg_salary
FROM PercentileCalc
GROUP BY department_name, quartile
;

-- Finding the correlation between age and salary in the organization --

WITH AgeSalary AS (
    SELECT emp_dem.age, emp_sal.salary
    FROM employee_demographics emp_dem
    JOIN employee_salary emp_sal
       ON emp_dem.employee_id = emp_sal.employee_id
)
SELECT 
    SUM((age - (SELECT AVG(age) FROM AgeSalary)) * (salary - (SELECT AVG(salary) FROM AgeSalary))) / 
    (SQRT(SUM(POW(age - (SELECT AVG(age) FROM AgeSalary), 2))) * 
     SQRT(SUM(POW(salary - (SELECT AVG(salary) FROM AgeSalary), 2)))) AS correlation_coefficient
FROM AgeSalary
;



