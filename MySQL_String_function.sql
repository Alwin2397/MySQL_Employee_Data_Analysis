-- String Functions --

SELECT length('Skyfall');

SELECT first_name, length(first_name)
FROM employee_demographics
ORDER BY 2
;

SELECT UPPER(first_name),Upper(Last_name)
FROM employee_demographics
;

SELECT LOWER(first_name),LOWER(Last_name)
FROM employee_demographics
;

SELECT TRIM('   DUCK   ');
SELECT LTRIM('   DUCK   ');
SELECT RTRIM('   DUCK   ');

-- SUBSTRING --

SELECT first_name,
LEFT(first_name, 5),
RIGHT(last_name, 5),
SUBSTRING(First_name, 3 ,2)
birth_date,
SUBSTRING(birth_date,6,2) AS Birth_month
FROM employee_demographics;

-- REPLACE --

 SELECT first_name, REPLACE(first_name, 'a','z')   
 FROM employee_demographics;
 
 
 SELECT LOCATE('W','ALWIN');
 
 SELECT first_name First_Name, last_name Last_Name, 
 CONCAT(first_name," ",Last_name) AS Full_Name
 FROM employee_demographics
 ;
 
  





