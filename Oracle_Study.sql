 -- 230315
SELECT COUNT(*) FROM EMPLOYEES ;
SELECT COUNT(*) FROM DEPARTMENTS ;

SELECT a.EMPLOYEE_ID, a.EMP_NAME, DEPARTMENT_ID ,b.DEPARTMENT_NAME 
FROM EMPLOYEES a
INNER JOIN DEPARTMENTS b
USING (department_id)
;

SELECT a.EMPLOYEE_ID , a.EMP_NAME , b.JOB_ID , b.DEPARTMENT_ID 
FROM JOB_HISTORY b
RIGHT OUTER JOIN EMPLOYEES a
	ON ( a.EMPLOYEE_ID = b.EMPLOYEE_ID 
		 AND a.DEPARTMENT_ID = b.DEPARTMENT_ID )
;

SELECT a.EMPLOYEE_ID , a.EMP_NAME , b.JOB_ID , b.DEPARTMENT_ID 
FROM JOB_HISTORY b
RIGHT OUTER JOIN EMPLOYEES a
	ON ( b.EMPLOYEE_ID =  a.EMPLOYEE_ID
		 AND b.DEPARTMENT_ID = a.DEPARTMENT_ID )
;

CREATE TABLE HONG_A (EMP_ID INT);

CREATE TABLE HONG_B (EMP_ID INT); 

INSERT INTO HONG_A VALUES (10) ;
INSERT INTO HONG_A VALUES (20) ;
INSERT INTO HONG_A VALUES (40) ;

INSERT INTO HONG_B VALUES (10) ;
INSERT INTO HONG_B VALUES (20) ;
INSERT INTO HONG_B VALUES (30) ;

SELECT * FROM HONG_A ;
SELECT * FROM HONG_B ;

SELECT *
FROM HONG_A a
FULL OUTER JOIN HONG_B b
ON (a.emp_id = b.emp_id)
;


 -- 230319
SELECT AVG(SALARY) FROM employees ;

SELECT 
	*
FROM 
	EMPLOYEES 
WHERE DEPARTMENT_ID IN (
	SELECT DEPARTMENT_ID FROM DEPARTMENTS WHERE PARENT_ID IS NOT NULL 
)
;

SELECT 
	EMPLOYEE_ID, EMP_NAME, JOB_ID
FROM 
	EMPLOYEES
WHERE 
	(EMPLOYEE_ID, JOB_ID) IN (
		SELECT EMPLOYEE_ID, JOB_ID FROM JOB_HISTORY
	)
;

SELECT a.DEPARTMENT_ID, a.DEPARTMENT_NAME 
FROM DEPARTMENTS a
WHERE EXISTS (
	SELECT 1
	FROM JOB_HISTORY b
	WHERE a.DEPARTMENT_ID = b.DEPARTMENT_ID 
)
;

SELECT *
FROM DEPARTMENTS a
WHERE EXISTS (
	SELECT *
	FROM EMPLOYEES b
	WHERE a.DEPARTMENT_ID = b.DEPARTMENT_ID 
	AND b.SALARY > (
		SELECT AVG(salary) 
		FROM EMPLOYEES
	)
)
;

UPDATE EMPLOYEES a
SET a.SALARY = (
	SELECT sal
	FROM (
		SELECT b.DEPARTMENT_ID, AVG(c.SALARY) AS sal
		FROM DEPARTMENTS b,
			 EMPLOYEES c
		WHERE b.PARENT_ID = 90
		AND b.DEPARTMENT_ID = c.DEPARTMENT_ID 
		GROUP BY b.DEPARTMENT_ID 
	) d
	WHERE a.DEPARTMENT_ID = d.DEPARTMENT_ID
)
WHERE a.DEPARTMENT_ID IN (
	SELECT DEPARTMENT_ID 
	FROM DEPARTMENTS
	WHERE PARENT_ID = 90
)
;

SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID IN (
	SELECT DEPARTMENT_ID 
	FROM DEPARTMENTS
	WHERE PARENT_ID = 90
) 
;

SELECT DEPARTMENT_ID, MIN(SALARY), MAX(SALARY) 
FROM EMPLOYEES 
WHERE DEPARTMENT_ID IN (
	SELECT DEPARTMENT_ID 
	FROM DEPARTMENTS
	WHERE PARENT_ID = 90
)
GROUP BY DEPARTMENT_ID
;

MERGE INTO EMPLOYEES a
USING (
	SELECT b.DEPARTMENT_ID, AVG(c.SALARY) AS sal
	FROM DEPARTMENTS b,
		 EMPLOYEES c
	WHERE b.PARENT_ID = 90
	AND b.DEPARTMENT_ID = c.DEPARTMENT_ID 
	GROUP BY b.DEPARTMENT_ID 
) d
ON ( a.DEPARTMENT_ID = d.DEPARTMENT_ID )
WHEN MATCHED THEN 
	UPDATE SET a.SALARY = d.sal
;

SELECT a.*
FROM (
	SELECT a.sales_month, ROUND(AVG(a.AMOUNT_SOLD)) AS month_avg
	FROM SALES a,
		 CUSTOMERS b,
		 COUNTRIES c
	WHERE a.SALES_MONTH BETWEEN '200001' AND '200012'
	AND a.CUST_ID = b.CUST_ID 
	AND b.COUNTRY_ID = c.COUNTRY_ID 
	AND c.COUNTRY_NAME = 'Italy'
	GROUP BY a.sales_month
) a,
(
	SELECT ROUND(AVG(a.AMOUNT_SOLD)) AS year_avg
	FROM SALES a,
		 CUSTOMERS b,
		 COUNTRIES c
	WHERE a.SALES_MONTH BETWEEN '200001' AND '200012'
	AND a.CUST_ID = b.CUST_ID 
	AND b.COUNTRY_ID = c.COUNTRY_ID 
	AND c.COUNTRY_NAME = 'Italy'
) b
WHERE a.month_avg > b.year_avg
;

 -- 1
SELECT SUBSTR(a.SALES_MONTH, 1, 4) AS years,
	   a.EMPLOYEE_ID,
	   SUM(a.AMOUNT_SOLD) AS AMOUNT_SOLD 
FROM SALES a,
	 CUSTOMERS b,
	 COUNTRIES c 
WHERE a.CUST_ID = b.CUST_ID 
AND b.COUNTRY_ID = c.COUNTRY_ID 
AND c.COUNTRY_NAME = 'Italy'
GROUP BY SUBSTR(a.SALES_MONTH, 1, 4), a.EMPLOYEE_ID
;

 -- 2
SELECT years,
	   MAX(AMOUNT_SOLD) AS max_sold
FROM (
	SELECT SUBSTR(a.SALES_MONTH, 1, 4) AS years,
		   a.EMPLOYEE_ID,
		   SUM(a.AMOUNT_SOLD) AS AMOUNT_SOLD 
	FROM SALES a,
		 CUSTOMERS b,
		 COUNTRIES c 
	WHERE a.CUST_ID = b.CUST_ID 
	AND b.COUNTRY_ID = c.COUNTRY_ID 
	AND c.COUNTRY_NAME = 'Italy'
	GROUP BY SUBSTR(a.SALES_MONTH, 1, 4), a.EMPLOYEE_ID
) K
GROUP BY years
ORDER BY years
;

 -- 3
SELECT emp.years,
	   emp.EMPLOYEE_ID,
	   emp.AMOUNT_SOLD
FROM (
	-- 전체
	SELECT SUBSTR(a.SALES_MONTH, 1, 4) AS years,
		   a.EMPLOYEE_ID,
		   SUM(a.AMOUNT_SOLD) AS AMOUNT_SOLD 
	FROM SALES a,
		 CUSTOMERS b,
		 COUNTRIES c 
	WHERE a.CUST_ID = b.CUST_ID 
	AND b.COUNTRY_ID = c.COUNTRY_ID 
	AND c.COUNTRY_NAME = 'Italy'
	GROUP BY SUBSTR(a.SALES_MONTH, 1, 4), a.EMPLOYEE_ID
) emp,
(
	-- 최대
	SELECT years,
		   MAX(AMOUNT_SOLD) AS max_sold
	FROM (
		SELECT SUBSTR(a.SALES_MONTH, 1, 4) AS years,
			   a.EMPLOYEE_ID,
			   SUM(a.AMOUNT_SOLD) AS AMOUNT_SOLD 
		FROM SALES a,
			 CUSTOMERS b,
			 COUNTRIES c 
		WHERE a.CUST_ID = b.CUST_ID 
		AND b.COUNTRY_ID = c.COUNTRY_ID 
		AND c.COUNTRY_NAME = 'Italy'
		GROUP BY SUBSTR(a.SALES_MONTH, 1, 4), a.EMPLOYEE_ID
	) K
	GROUP BY years
) sale
WHERE emp.years = sale.years
AND emp.AMOUNT_SOLD = sale.max_sold
ORDER BY years
;

 -- 최종
SELECT emp.years,
	   emp.EMPLOYEE_ID,
	   emp2.emp_name,
	   emp.AMOUNT_SOLD
FROM (
	-- 전체
	SELECT SUBSTR(a.SALES_MONTH, 1, 4) AS years,
		   a.EMPLOYEE_ID,
		   SUM(a.AMOUNT_SOLD) AS AMOUNT_SOLD 
	FROM SALES a,
		 CUSTOMERS b,
		 COUNTRIES c 
	WHERE a.CUST_ID = b.CUST_ID 
	AND b.COUNTRY_ID = c.COUNTRY_ID 
	AND c.COUNTRY_NAME = 'Italy'
	GROUP BY SUBSTR(a.SALES_MONTH, 1, 4), a.EMPLOYEE_ID
) emp,
(
	-- 최대
	SELECT years,
		   MAX(AMOUNT_SOLD) AS max_sold
	FROM (
		SELECT SUBSTR(a.SALES_MONTH, 1, 4) AS years,
			   a.EMPLOYEE_ID,
			   SUM(a.AMOUNT_SOLD) AS AMOUNT_SOLD 
		FROM SALES a,
			 CUSTOMERS b,
			 COUNTRIES c 
		WHERE a.CUST_ID = b.CUST_ID 
		AND b.COUNTRY_ID = c.COUNTRY_ID 
		AND c.COUNTRY_NAME = 'Italy'
		GROUP BY SUBSTR(a.SALES_MONTH, 1, 4), a.EMPLOYEE_ID
	) K
	GROUP BY years
) sale,
employees emp2
WHERE emp.years = sale.years
AND emp.AMOUNT_SOLD = sale.max_sold
AND emp.EMPLOYEE_ID = emp2.EMPLOYEE_ID
ORDER BY years
;

 -- Self-Check 1
SELECT 
	  a.EMPLOYEE_ID
	, a.EMP_NAME 
	, b.JOB_ID 
	, b.START_DATE 
	, b.END_DATE 
--	, a.DEPARTMENT_ID 
	, c.DEPARTMENT_NAME 
FROM 
	employees a
INNER JOIN 
	JOB_HISTORY b 
	ON a.EMPLOYEE_ID = b.EMPLOYEE_ID 
INNER JOIN 
	DEPARTMENTS c
	ON a.DEPARTMENT_ID = c.DEPARTMENT_ID 
ORDER BY a.EMPLOYEE_ID ASC 
;

 -- Self-Check 2
SELECT a.EMPLOYEE_ID, a.EMP_NAME, b.JOB_ID, b.DEPARTMENT_ID 
FROM employees a,
	 JOB_HISTORY b
WHERE a.EMPLOYEE_ID  = b.EMPLOYEE_ID(+)
--AND a.DEPARTMENT_ID = b.DEPARTMENT_ID(+)
--AND a.JOB_ID IN ('AC_ACCOUNT', 'test')
ORDER BY EMPLOYEE_ID ASC 
;

SELECT a.DEPARTMENT_ID, a.DEPARTMENT_NAME 
FROM DEPARTMENTS a, EMPLOYEES b
WHERE a.DEPARTMENT_ID = b.DEPARTMENT_ID 
AND b.SALARY > 3000
ORDER BY a.DEPARTMENT_NAME 
;

SELECT a.DEPARTMENT_ID, a.DEPARTMENT_NAME 
FROM 
	DEPARTMENTS a
INNER JOIN 
	EMPLOYEES b
	ON a.DEPARTMENT_ID = b.DEPARTMENT_ID 
	AND b.SALARY > 3000
--WHERE 
--	b.SALARY > 3000
ORDER BY a.DEPARTMENT_NAME 
;

 -- 230320
SELECT a.DEPARTMENT_ID, a.DEPARTMENT_NAME  
FROM DEPARTMENTS a
WHERE EXISTS (
	SELECT 1
	FROM JOB_HISTORY b
	WHERE a.DEPARTMENT_ID = b.DEPARTMENT_ID 
)
;

SELECT a.DEPARTMENT_ID, a.DEPARTMENT_NAME  
FROM DEPARTMENTS a
WHERE a.DEPARTMENT_ID IN (
	SELECT DEPARTMENT_ID 
	FROM JOB_HISTORY b
)
;

 -- Self-Check 6
SELECT emp.years,
	   emp.EMPLOYEE_ID,
	   emp2.emp_name,
	   emp.AMOUNT_SOLD
--	   sale.min_sold
FROM (
	-- 전체
	SELECT SUBSTR(a.SALES_MONTH, 1, 4) AS years,
		   a.EMPLOYEE_ID,
		   SUM(a.AMOUNT_SOLD) AS AMOUNT_SOLD 
	FROM SALES a,
		 CUSTOMERS b,
		 COUNTRIES c 
	WHERE a.CUST_ID = b.CUST_ID 
	AND b.COUNTRY_ID = c.COUNTRY_ID 
	AND c.COUNTRY_NAME = 'Italy'
	GROUP BY SUBSTR(a.SALES_MONTH, 1, 4), a.EMPLOYEE_ID
) emp,
(
	-- 최대
	SELECT years,
		   MAX(AMOUNT_SOLD) AS max_sold,
		   MIN(AMOUNT_SOLD) AS min_sold
	FROM (
		SELECT SUBSTR(a.SALES_MONTH, 1, 4) AS years,
			   a.EMPLOYEE_ID,
			   SUM(a.AMOUNT_SOLD) AS AMOUNT_SOLD 
		FROM SALES a,
			 CUSTOMERS b,
			 COUNTRIES c 
		WHERE a.CUST_ID = b.CUST_ID 
		AND b.COUNTRY_ID = c.COUNTRY_ID 
		AND c.COUNTRY_NAME = 'Italy'
		GROUP BY SUBSTR(a.SALES_MONTH, 1, 4), a.EMPLOYEE_ID
	) K
	GROUP BY years
) sale, employees emp2
WHERE emp.years = sale.years
--AND (emp.AMOUNT_SOLD = sale.max_sold OR emp.AMOUNT_SOLD = sale.min_sold)
AND emp.AMOUNT_SOLD IN (sale.max_sold, sale.min_sold)
AND emp.EMPLOYEE_ID = emp2.EMPLOYEE_ID(+)
ORDER BY years, AMOUNT_SOLD ASC
;

SELECT DEPARTMENT_ID , LPAD(' ', 3 * (LEVEL - 1)) || DEPARTMENT_NAME , LEVEL,
--	   connect_by_root DEPARTMENT_NAME AS root_name
--	   connect_by_isleaf 
	   sys_connect_by_path(DEPARTMENT_ID, '|')
FROM DEPARTMENTS
START WITH parent_id IS NULL 
CONNECT BY PRIOR DEPARTMENT_ID = PARENT_ID 
ORDER siblings BY DEPARTMENT_NAME 
;

SELECT * FROM EMPLOYEES ;

SELECT a.EMPLOYEE_ID , LPAD(' ', 3 * (LEVEL - 1)) || a.EMP_NAME AS empname 
	,  LEVEL , b.DEPARTMENT_NAME, a.DEPARTMENT_ID 
FROM EMPLOYEES a,
	 DEPARTMENTS b
WHERE a.DEPARTMENT_ID = b.DEPARTMENT_ID 
--AND a.DEPARTMENT_ID = 30
START WITH a.MANAGER_ID IS NULL 
CONNECT BY nocycle PRIOR a.EMPLOYEE_ID = a.MANAGER_ID
AND a.DEPARTMENT_ID = 30
;

UPDATE DEPARTMENTS 
SET PARENT_ID = 170
WHERE DEPARTMENT_ID = 30
;

SELECT DEPARTMENT_ID , LPAD(' ', 3 * (LEVEL - 1)) || DEPARTMENT_NAME , LEVEL, 
	   connect_by_iscycle IsLoop,
	   PARENT_ID 
FROM DEPARTMENTS 
START WITH DEPARTMENT_ID = 30
CONNECT BY nocycle PRIOR DEPARTMENT_ID = PARENT_ID 
;

CREATE TABLE ex7_1 AS
SELECT 
		rownum seq
	,	'2014' || LPAD(CEIL(rownum / 1000), 2, '0') month
	,	ROUND(dbms_random.value(100, 1000)) amt
FROM dual 
CONNECT BY LEVEL <= 12000
;

SELECT 
		MONTH
	,	SUM(amt) 
FROM ex7_1
GROUP BY MONTH 
ORDER BY MONTH
;

SELECT rownum
FROM (
	SELECT 1 AS row_num
	FROM dual
	UNION ALL 
	SELECT 1 AS row_num
	FROM dual 
) 
CONNECT BY LEVEL <= 4
;

CREATE TABLE ex7_2 AS 
SELECT /*DEPARTMENT_ID,*/
	   listagg(EMP_NAME, ',') WITHIN GROUP (ORDER BY EMP_NAME) AS empnames
FROM EMPLOYEES 
WHERE DEPARTMENT_ID IS NOT NULL 
--GROUP BY DEPARTMENT_ID
;

SELECT empnames,
	   LEVEL AS lvl
FROM (
	SELECT empnames || ',' AS empnames,
		   length(empnames) ori_len,
		   LENGTH(REPLACE(empnames, ',', '')) NEW_len
	FROM EX7_2
	WHERE department_id = 90
)
CONNECT BY LEVEL <= ori_len - NEW_len + 1
;

SELECT empnames,
	   DECODE(LEVEL, 1, 1, INSTR(empnames, ',', 1, LEVEL - 1)) start_pos ,
	   INSTR(empnames, ',', 1, LEVEL) end_pos,
	   LEVEL AS lvl
FROM (
	SELECT empnames || ',' AS empnames,
		   length(empnames) ori_len,
		   LENGTH(REPLACE(empnames, ',', '')) NEW_len
	FROM EX7_2
	WHERE department_id = 90
)
CONNECT BY LEVEL <= ori_len - NEW_len + 1
;

SELECT REPLACE(SUBSTR(empnames, start_pos, end_pos - start_pos), ',', '') AS emp 
FROM (
	SELECT empnames,
		   DECODE(LEVEL, 1, 1, INSTR(empnames, ',', 1, LEVEL - 1)) start_pos ,
		   INSTR(empnames, ',', 1, LEVEL) end_pos,
		   LEVEL AS lvl
	FROM (
		SELECT empnames || ',' AS empnames,
			   length(empnames) ori_len,
			   LENGTH(REPLACE(empnames, ',', '')) NEW_len
		FROM EX7_2
		WHERE department_id = 90
	)
	CONNECT BY LEVEL <= ori_len - NEW_len + 1
)
;


 -- 230321
WITH b2 AS (
	SELECT PERIOD , REGION ,SUM(LOAN_JAN_AMT) jan_amt 
	FROM KOR_LOAN_STATUS 
	GROUP BY PERIOD , REGION
),
c AS (
	SELECT b2.PERIOD, MAX(b2.jan_amt) max_jan_amt
	FROM b2, (
		SELECT MAX(PERIOD) max_month
		FROM KOR_LOAN_STATUS 
		GROUP BY SUBSTR(PERIOD, 1, 4) 
	) a
	WHERE b2.PERIOD = a.max_month
	GROUP BY b2.period
)
SELECT b2.*
FROM b2, c
WHERE b2.PERIOD = c.PERIOD
AND b2.jan_amt = c.max_jan_amt
ORDER BY 1 
;

SELECT SUBSTR(PERIOD, 1, 4) FROM KOR_LOAN_STATUS ;

WITH recur AS (
	SELECT DEPARTMENT_ID , PARENT_ID , DEPARTMENT_NAME , 1 AS lvl
	FROM DEPARTMENTS 
	WHERE PARENT_ID IS NULL
	UNION ALL 
	SELECT a.DEPARTMENT_ID , a.PARENT_ID , a.DEPARTMENT_NAME , b.lvl + 1
	FROM DEPARTMENTS a, recur b
	WHERE a.PARENT_ID = b.DEPARTMENT_ID
)
SEARCH DEPTH FIRST BY DEPARTMENT_NAME SET ORDER_seq
SELECT DEPARTMENT_ID, LPAD(' ', 3 * (lvl - 1)) || DEPARTMENT_NAME, lvl, ORDER_seq
FROM recur
;


 -- 230322
SELECT DEPARTMENT_ID , EMP_NAME ,
	   ROW_NUMBER() OVER (PARTITION BY DEPARTMENT_ID ORDER BY DEPARTMENT_ID, EMP_NAME) dep_rows
FROM EMPLOYEES
;

SELECT DEPARTMENT_ID , EMP_NAME, 
	   SALARY ,
	   rank() OVER (PARTITION BY DEPARTMENT_ID ORDER BY SALARY) dep_rank
FROM EMPLOYEES 
;

SELECT *
FROM (
	SELECT DEPARTMENT_ID , EMP_NAME, 
		   SALARY ,
		   rank() OVER (PARTITION BY DEPARTMENT_ID ORDER BY SALARY desc) dep_rank
	FROM EMPLOYEES 
)
WHERE dep_rank <= 3
;

SELECT DEPARTMENT_ID , EMP_NAME, 
	   SALARY ,
	   CUME_DIST() OVER (PARTITION BY DEPARTMENT_ID ORDER BY SALARY) dep_dist
FROM EMPLOYEES 
;

SELECT DEPARTMENT_ID , EMP_NAME, 
	   SALARY ,
	   RANK() OVER (PARTITION BY DEPARTMENT_ID ORDER BY SALARY) ranking,
	   CUME_DIST() OVER (PARTITION BY DEPARTMENT_ID ORDER BY SALARY) cume_dist_value,
	   PERCENT_RANK() OVER (PARTITION BY DEPARTMENT_ID ORDER BY SALARY) percentile 
FROM EMPLOYEES 
WHERE DEPARTMENT_ID = 30
;

SELECT DEPARTMENT_ID , EMP_NAME, 
	   SALARY ,
	   NTILE(8) OVER(PARTITION BY DEPARTMENT_ID ORDER BY SALARY) NTILES 
FROM EMPLOYEES 
WHERE DEPARTMENT_ID IN (30, 60)
;

SELECT EMP_NAME , HIRE_DATE , SALARY,
	   LAG(SALARY, 1, 0) OVER(ORDER BY HIRE_DATE) AS prev_sal,
	   LEAD(SALARY, 1, 0) over(ORDER BY EMP_NAME) AS next_sal 
FROM EMPLOYEES
WHERE DEPARTMENT_ID = 30
;

SELECT DEPARTMENT_ID , EMP_NAME , HIRE_DATE , SALARY,
	   sum(SALARY) OVER(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING 
	   ) AS all_salary,
	   SUM(SALARY) OVER(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 
	   ) AS first_current_sal,
	   SUM(SALARY) over(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING 
	   ) AS current_end_sal
FROM EMPLOYEES
WHERE DEPARTMENT_ID IN (30, 90)
;


 -- 230325
SELECT DEPARTMENT_ID , EMP_NAME , HIRE_DATE , SALARY ,
	   SUM(SALARY) OVER(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING 
	   ) AS all_salary,
	   SUM(SALARY) over(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		RANGE 800 PRECEDING 
	   ) AS range_sal1,
	   SUM(SALARY) OVER(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		RANGE BETWEEN 1000 PRECEDING AND CURRENT ROW 
	   ) AS range_sal2
FROM EMPLOYEES
WHERE DEPARTMENT_ID = 30
;

SELECT DEPARTMENT_ID , EMP_NAME , HIRE_DATE , SALARY ,
	   FIRST_VALUE(SALARY) OVER(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING 
	   ) AS all_salary,
	   FIRST_VALUE(SALARY) over(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 
	   ) AS fr_st_to_current_sal,
	   FIRST_VALUE(SALARY) OVER(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING 
	   ) AS fr_current_to_end_sal
FROM EMPLOYEES
WHERE DEPARTMENT_ID IN (30, 90)
;

SELECT DEPARTMENT_ID , EMP_NAME , HIRE_DATE , SALARY ,
	   nth_value(SALARY, 2) OVER(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING 
	   ) AS all_salary,
	   nth_value(SALARY, 2) over(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 
	   ) AS fr_st_to_current_sal,
	   nth_value(SALARY, 2) OVER(PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE
	   		ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING 
	   ) AS fr_current_to_end_sal
FROM EMPLOYEES
WHERE DEPARTMENT_ID IN (30, 90)
;

SELECT DEPARTMENT_ID , EMP_NAME , SALARY 
	   , NTILE(4) OVER(PARTITION BY DEPARTMENT_ID ORDER BY SALARY) NTILES
	   , WIDTH_BUCKET(SALARY, 1000, 10000, 4) widthbucket
FROM EMPLOYEES 
WHERE DEPARTMENT_ID = 60
;

WITH basis AS (
	SELECT period, REGION , SUM(LOAN_JAN_AMT) jan_amt 
	FROM KOR_LOAN_STATUS 
	GROUP BY period, REGION 
),
basis2 AS (
	SELECT period, MIN(jan_amt) min_amt, MAX(jan_amt) max_amt
	FROM basis
	GROUP BY period
)
SELECT a.period,
	   b.REGION "최소지역", b.jan_amt "최소금액",
	   c.REGION "최대지역", c.jan_amt "최대금액"
FROM basis2 a, basis b, basis c
WHERE a.period = b.period
AND   a.min_amt = b.jan_amt
AND   a.period = c. period
AND   a.max_amt = c.jan_amt
ORDER BY 1, 2 
;

SELECT 
	period, MIN(jan_amt) min_amt, MAX(jan_amt) max_amt
FROM (
	SELECT period, REGION , SUM(LOAN_JAN_AMT) jan_amt 
	FROM KOR_LOAN_STATUS 
	GROUP BY period, REGION 
)
GROUP BY period
;

WITH basis AS (
	SELECT period, REGION , SUM(LOAN_JAN_AMT) jan_amt 
	FROM KOR_LOAN_STATUS 
	GROUP BY period, REGION 
)
SELECT a.period,
	   MIN(a.REGION) keep (DENSE_RANK FIRST ORDER BY jan_amt) "최소지역",
	   MIN(jan_amt) "최소금액",
	   MAX(a.REGION) keep (DENSE_RANK LAST ORDER BY jan_amt) "최대지역",
	   MAX(jan_amt) "최대금액"
FROM basis a
GROUP BY a.period
ORDER BY 1, 2 
;

SELECT period, REGION , SUM(LOAN_JAN_AMT) jan_amt ,
	   DENSE_RANK() over(PARTITION BY period ORDER BY SUM(LOAN_JAN_AMT)) AS test
FROM KOR_LOAN_STATUS 
GROUP BY period, REGION 
;


 -- 230329
SELECT DEPARTMENT_ID , EMP_NAME , HIRE_DATE , SALARY ,
	   ROUND(RATIO_TO_REPORT(SALARY) OVER(PARTITION BY DEPARTMENT_ID), 2) * 100 || '%' AS salary_percent 
FROM EMPLOYEES 
WHERE DEPARTMENT_ID IN (30, 90)
;

CREATE TABLE ex7_3 (
	emp_id NUMBER,
	emp_name varchar2(100)
);

CREATE TABLE ex7_4 (
	emp_id NUMBER,
	emp_name varchar2(100)
);

INSERT INTO ex7_3 VALUES (101, '홍길동');
INSERT INTO ex7_3 VALUES (102, '김유신');
SELECT * FROM ex7_3 ;

INSERT ALL 
  INTO ex7_3 VALUES (103, '강감찬')
  INTO ex7_3 VALUES (104, '연개소문')
SELECT *
FROM dual 
;

INSERT ALL
  INTO ex7_3 VALUES (105, '가가가')
  INTO ex7_4 VALUES (105, '나나나')
SELECT *
FROM dual 
;

SELECT * FROM ex7_3 ;
SELECT * FROM ex7_4 ;

TRUNCATE TABLE ex7_3 ;

INSERT ALL 
  WHEN DEPARTMENT_ID = 30 THEN 
  	INTO ex7_3 VALUES (EMPLOYEE_ID, EMP_NAME)
  WHEN department_id = 90 THEN 
  	INTO ex7_4 VALUES (EMPLOYEE_ID, EMP_NAME)
SELECT DEPARTMENT_ID , EMPLOYEE_ID , EMP_NAME 
FROM employees 
;

CREATE TABLE ex7_5 (
	emp_id NUMBER,
	emp_name varchar2(100)
);

SELECT * FROM ex7_5 ;

INSERT ALL 
  WHEN DEPARTMENT_ID = 30 THEN 
  	INTO ex7_3 VALUES (EMPLOYEE_ID, EMP_NAME)
  WHEN department_id = 90 THEN 
  	INTO ex7_4 VALUES (EMPLOYEE_ID, EMP_NAME)
  ELSE 
  	INTO ex7_5 VALUES (EMPLOYEE_ID, EMP_NAME)
SELECT DEPARTMENT_ID , EMPLOYEE_ID , EMP_NAME 
FROM employees 
;


 -- 230330
INSERT ALL 
  WHEN EMPLOYEE_ID < 116 THEN 
  	INTO ex7_3 VALUES (EMPLOYEE_ID , EMP_NAME)
  WHEN SALARY < 5000 THEN 
    INTO ex7_4 VALUES (EMPLOYEE_ID , EMP_NAME)
SELECT DEPARTMENT_ID , EMPLOYEE_ID , EMP_NAME , SALARY 
FROM EMPLOYEES 
WHERE DEPARTMENT_ID = 30
;

INSERT FIRST  
  WHEN EMPLOYEE_ID < 116 THEN 
  	INTO ex7_3 VALUES (EMPLOYEE_ID , EMP_NAME)
  WHEN SALARY < 5000 THEN 
    INTO ex7_4 VALUES (EMPLOYEE_ID , EMP_NAME)
SELECT DEPARTMENT_ID , EMPLOYEE_ID , EMP_NAME , SALARY 
FROM EMPLOYEES 
WHERE DEPARTMENT_ID = 30
;

SELECT * FROM ex7_4 ;

SELECT DEPARTMENT_ID ,
	   LISTAGG(EMP_NAME, ',') WITHIN GROUP (ORDER BY EMP_NAME ASC ) AS empnames
FROM EMPLOYEES 
WHERE DEPARTMENT_ID IS NOT NULL 
GROUP BY DEPARTMENT_ID 
;

 -- Self-Check 1
 -- 못품

 -- Self-Check 2
SELECT EMPLOYEE_ID , EMP_NAME , HIRE_DATE ,
	   lead(HIRE_DATE, 1, null) OVER (ORDER BY HIRE_DATE) AS RETIRE_DATE 
FROM EMPLOYEES
WHERE JOB_ID = 'SH_CLERK'
--ORDER BY HIRE_DATE 
;

 -- Self-Check 3
WITH TBL_DATA AS (
	SELECT 
		TRUNC(MONTHS_BETWEEN(sysdate, TO_DATE(b.CUST_YEAR_OF_BIRTH, 'YYYY')) / 12, -1) AS age_group , 
	--	b.CUST_YEAR_OF_BIRTH,
		SUM(a.AMOUNT_SOLD) AS AMOUNT_SOLD
	FROM 
		sales a, CUSTOMERS b
	WHERE 
		a.CUST_ID = b.CUST_ID 
	AND a.SALES_MONTH = '200112'
	GROUP BY b.CUST_YEAR_OF_BIRTH
--	ORDER BY b.CUST_YEAR_OF_BIRTH DESC 
)
SELECT 
	TBL_DATA.age_group||'대' AS "연령대",
	SUM(TBL_DATA.AMOUNT_SOLD) AS "매출금액"
FROM TBL_DATA
GROUP BY TBL_DATA.age_group
ORDER BY TBL_DATA.age_group asc 
;

SELECT 
	b.CUST_YEAR_OF_BIRTH , a.CUST_ID 
FROM 
	sales a, CUSTOMERS b
WHERE 
	a.CUST_ID = b.CUST_ID 
AND a.SALES_MONTH = '200112'
;

SELECT DISTINCT CUST_YEAR_OF_BIRTH FROM CUSTOMERS ORDER BY CUST_YEAR_OF_BIRTH DESC  ;


 -- 230403
 -- Self-Check 4
WITH basis AS (
	SELECT 
		a.SALES_MONTH ,
		c.COUNTRY_NAME ,
		SUM(a.AMOUNT_SOLD) AS AMOUNT_SOLD
	FROM 
		sales a, CUSTOMERS b, countries c
	WHERE 
		a.CUST_ID = b.CUST_ID 
	AND b.COUNTRY_ID = c.COUNTRY_ID 
	GROUP BY a.SALES_MONTH, c.COUNTRY_NAME
)
SELECT 
	a.SALES_MONTH AS "매출월",
	min(a.COUNTRY_NAME) KEEP (DENSE_RANK FIRST ORDER BY a.AMOUNT_SOLD ASC) AS "지역(대륙)",
	MIN(a.AMOUNT_SOLD) AS "매출금액"
FROM basis a
GROUP BY a.SALES_MONTH
;

select 
        region
    ,   sum(case when period = '201111' then LOAN_JAN_AMT end) as "201111"
    ,   sum(case when period = '201112' then LOAN_JAN_AMT end) as "201112"
    ,   sum(case when period = '201210' then LOAN_JAN_AMT end) as "201210"
    ,   sum(case when period = '201211' then LOAN_JAN_AMT end) as "201211"
    ,   sum(case when period = '201212' then LOAN_JAN_AMT end) as "201212"
    ,   sum(case when period = '201310' then LOAN_JAN_AMT end) as "201310"
    ,   sum(case when period = '201311' then LOAN_JAN_AMT end) as "201311"
from 
    kor_loan_status
group by region
order by region asc 
;

 -- Self-Check 5
WITH basis AS (
	select 
	        region
	    ,	GUBUN 
	    ,   sum(case when period = '201111' then LOAN_JAN_AMT end) as COL_1--"201111"
	    ,   sum(case when period = '201112' then LOAN_JAN_AMT end) as COL_2--"201112"
	    ,   sum(case when period = '201210' then LOAN_JAN_AMT end) as COL_3--"201210"
	    ,   sum(case when period = '201211' then LOAN_JAN_AMT end) as COL_4--"201211"
	    ,   sum(case when period = '201212' then LOAN_JAN_AMT end) as COL_5--"201212"
	    ,   sum(case when period = '201310' then LOAN_JAN_AMT end) as COL_6--"201310"
	    ,   sum(case when period = '201311' then LOAN_JAN_AMT end) as COL_7--"201311"
	from 
	    kor_loan_status
	group by region, GUBUN
)
SELECT 
	a.region,
	a.GUBUN,
	a.COL_1||'( '||NVL(ROUND(RATIO_TO_REPORT(COL_1) OVER(PARTITION BY region) * 100, 0), 0)||'%'||' )' AS "201111",
	a.COL_2||'( '||NVL(ROUND(RATIO_TO_REPORT(COL_2) OVER(PARTITION BY region) * 100, 0), 0)||'%'||' )' AS "201112",
	a.COL_3||'( '||NVL(ROUND(RATIO_TO_REPORT(COL_3) OVER(PARTITION BY region) * 100, 0), 0)||'%'||' )' AS "201210",
	a.COL_4||'( '||NVL(ROUND(RATIO_TO_REPORT(COL_4) OVER(PARTITION BY region) * 100, 0), 0)||'%'||' )' AS "201211",
	a.COL_5||'( '||NVL(ROUND(RATIO_TO_REPORT(COL_5) OVER(PARTITION BY region) * 100, 0), 0)||'%'||' )' AS "201212",
	a.COL_6||'( '||NVL(ROUND(RATIO_TO_REPORT(COL_6) OVER(PARTITION BY region) * 100, 0), 0)||'%'||' )' AS "201310",
	a.COL_7||'( '||NVL(ROUND(RATIO_TO_REPORT(COL_7) OVER(PARTITION BY region) * 100, 0), 0)||'%'||' )' AS "201311"
FROM basis a
--ORDER BY region ASC, GUBUN ASC
ORDER BY DECODE(region, '서울', 1, '부산', 2), region ASC, gubun ASC 
;

DECLARE 
	vi_num NUMBER ;
BEGIN 
	vi_num := 100;

	dbms_output.put_line(vi_num);
END;

DECLARE 
	a integer := 2**2*3**2;
BEGIN 
	dbms_output.put_line('a = ' || to_char(a));
END;

DECLARE 
	a integer := 2**2*3**2;
BEGIN 
	/* 실행부
	   dbms_output을 이용한 변수 값 출력
	 */
	dbms_output.put_line('a = ' || to_char(a));
END;

DECLARE 
	vs_emp_name varchar2(80);	-- 사원명 변수
	vs_dep_name	varchar2(80);	-- 부서명 변수
BEGIN 
	SELECT a.EMP_NAME , b.DEPARTMENT_NAME 
	INTO vs_emp_name, vs_dep_name
	FROM EMPLOYEES a,
		 DEPARTMENTS b
	WHERE a.DEPARTMENT_ID = b.DEPARTMENT_ID 
	AND   a.EMPLOYEE_ID = 100;

	dbms_output.put_line(vs_emp_name || ' - ' || vs_dep_name);
END;

DECLARE 
	vs_emp_name EMPLOYEES.EMP_NAME%TYPE;
	vs_dep_name	DEPARTMENTS.DEPARTMENT_NAME%TYPE;
BEGIN 
	SELECT a.EMP_NAME , b.DEPARTMENT_NAME 
	INTO vs_emp_name, vs_dep_name
	FROM EMPLOYEES a,
		 DEPARTMENTS b
	WHERE a.DEPARTMENT_ID = b.DEPARTMENT_ID 
	AND   a.EMPLOYEE_ID = 100;

	dbms_output.put_line(vs_emp_name || ' - ' || vs_dep_name);
END;

CREATE TABLE ch08_varchar2(
	var1 varchar2(4000)
);
SELECT * FROM ch08_varchar2 ;
INSERT INTO ch08_varchar2 (var1)
VALUES ('test');

DECLARE 
	vs_sql_varchar2 varchar2(4000);
	vs_plsql_varchar2 varchar2(32767);
BEGIN 
	-- ch08_varchar2 테이블의 값을 변수에 담는다.
	SELECT var1
	INTO vs_sql_varchar2
	FROM ch08_varchar2;

	-- PL/SQL 변수에 4000 BYTE 이상 크기의 값을 넣는다.
	vs_plsql_varchar2 := vs_sql_varchar2 || ' - ' || vs_sql_varchar2 || ' - ' || vs_sql_varchar2;

	-- 각 변수 크기를 출력한다.
	dbms_output.put_line('SQL VARCHAR2 길이 : ' || lengthb(vs_sql_varchar2));
	dbms_output.put_line('PL/SQL VARCHAR2 길이 : ' || lengthb(vs_plsql_varchar2));
END;

 -- 230405
 -- Self-Check 1
DECLARE 
	vi_num NUMBER;
BEGIN 
	vi_num := 3 * 1;
	dbms_output.put_line('3 * 1 = ' || vi_num);
	vi_num := 3 * 2;
	dbms_output.put_line('3 * 2 = ' || vi_num);
	vi_num := 3 * 3;
	dbms_output.put_line('3 * 3 = ' || vi_num);
	vi_num := 3 * 4;
	dbms_output.put_line('3 * 4 = ' || vi_num);
	vi_num := 3 * 5;
	dbms_output.put_line('3 * 5 = ' || vi_num);
	vi_num := 3 * 6;
	dbms_output.put_line('3 * 6 = ' || vi_num);
	vi_num := 3 * 7;
	dbms_output.put_line('3 * 7 = ' || vi_num);
	vi_num := 3 * 8;
	dbms_output.put_line('3 * 8 = ' || vi_num);
	vi_num := 3 * 9;
	dbms_output.put_line('3 * 9 = ' || vi_num);
END;

 -- Self-Check 2
DECLARE 
	vs_emp_name EMPLOYEES.EMP_NAME%TYPE;
	vs_email	EMPLOYEES.EMAIL%TYPE;
BEGIN 
	SELECT EMP_NAME , EMAIL 
	INTO vs_emp_name, vs_email
	FROM EMPLOYEES
	WHERE EMPLOYEE_ID = '201';

	dbms_output.put_line('사원 이름 : ' || vs_emp_name || ', ' || '이메일 주소 : ' || vs_email);
END;

DECLARE 
	vs_next_id EMPLOYEES.EMPLOYEE_ID%TYPE;
BEGIN 
	SELECT MAX(EMPLOYEE_ID) + 1 
	INTO vs_next_id
	FROM EMPLOYEES ;

	INSERT INTO EMPLOYEES (EMPLOYEE_ID, EMP_NAME, EMAIL, HIRE_DATE, MANAGER_ID) 
	VALUES (vs_next_id, 'Harrison Ford', 'HARRIS', sysdate, 50) ;
END;

SELECT MAX(EMPLOYEE_ID) + 1 
FROM EMPLOYEES ;
SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID = 208 ;

DECLARE 
	vn_num1 NUMBER := 1;
	vn_num2 NUMBER := 2;
BEGIN 
	IF vn_num1 >= vn_num2 THEN 
		dbms_output.put_line(vn_num1 || '이 큰 수');
	ELSE 
		dbms_output.put_line(vn_num2 || '이 큰 수');
	END IF;
END;

DECLARE 
	vn_salary NUMBER := 0;
	vn_deparment_id NUMBER := 0;
BEGIN 
	vn_deparment_id := ROUND(dbms_random.value(10, 120), -1);

	SELECT SALARY 
	INTO vn_salary
	FROM EMPLOYEES 
	WHERE DEPARTMENT_ID = vn_deparment_id
	AND rownum = 1;

	dbms_output.put_line(vn_salary);

	IF vn_salary BETWEEN 1 AND 3000 THEN 
		dbms_output.put_line('낮음');
	ELSIF vn_salary BETWEEN 3001 AND 6000 THEN 
		dbms_output.put_line('중간');
	ELSIF vn_salary BETWEEN 6001 AND 10000 THEN 
		dbms_output.put_line('높음');
	ELSE 
		dbms_output.put_line('최상위');
	END IF;
END;

SELECT ROUND(dbms_random.value(10, 120), -1) FROM dual ;

SELECT COMMISSION_PCT
FROM EMPLOYEES 
WHERE COMMISSION_PCT IS NOT NULL 
;

DECLARE 
	vn_salary NUMBER := 0;
	vn_deparment_id NUMBER := 0;
	vn_commission NUMBER := 0;
BEGIN 
	vn_deparment_id := ROUND(dbms_random.value(10, 120), -1);

	SELECT SALARY , COMMISSION_PCT 
	INTO vn_salary, vn_commission
	FROM EMPLOYEES 
	WHERE DEPARTMENT_ID = vn_deparment_id
--	AND COMMISSION_PCT IS NOT NULL 
	AND rownum = 1;

	dbms_output.put_line(vn_salary || ', ' || vn_commission);

	IF vn_commission > 0 THEN 
		IF vn_commission > 0.15 THEN 
			dbms_output.put_line(vn_salary * vn_commission);
		END IF;
	ELSE 
		dbms_output.put_line(vn_salary);
	END IF;
END;

DECLARE 
	vn_salary NUMBER := 0;
	vn_deparment_id NUMBER := 0;
BEGIN 
	vn_deparment_id := ROUND(dbms_random.value(10, 120), -1);

	SELECT SALARY 
	INTO vn_salary
	FROM EMPLOYEES 
	WHERE DEPARTMENT_ID = vn_deparment_id
	AND rownum = 1;

	dbms_output.put_line(vn_salary);

	CASE WHEN vn_salary BETWEEN 1 AND 3000 THEN 
			dbms_output.put_line('낮음');
		when vn_salary BETWEEN 3001 AND 6000 THEN 
			dbms_output.put_line('중간');
		WHEN vn_salary BETWEEN 6001 AND 10000 THEN 
			dbms_output.put_line('높음');
		ELSE 
			dbms_output.put_line('최상위');
	END case;
END;

DECLARE 
	vn_base_num NUMBER := 3;
	vn_cnt		NUMBER := 1;
BEGIN 
	LOOP 
		dbms_output.put_line(vn_base_num || '*' || vn_cnt || '= ' || vn_base_num * vn_cnt);
		vn_cnt := vn_cnt + 1;
	
		EXIT WHEN vn_cnt > 9;
	END LOOP ;
END;

DECLARE 
	vn_base_num NUMBER := 3;
	vn_cnt		NUMBER := 1;
BEGIN 
WHILE vn_cnt <= 9
LOOP 
	dbms_output.put_line(vn_base_num || '*' || vn_cnt || '= ' || vn_base_num * vn_cnt);
	vn_cnt := vn_cnt + 1;
END LOOP ;
END;

DECLARE 
	vn_base_num CONSTANT NUMBER := 3;
BEGIN 
	FOR i IN 1..9
	LOOP 
		dbms_output.put_line(vn_base_num || '*' || i || '= ' || vn_base_num * i);
	END LOOP;
END;

DECLARE 
	vn_base_num CONSTANT NUMBER := 3;
BEGIN 
	FOR i IN REVERSE 1..9
	LOOP 
		dbms_output.put_line(vn_base_num || '*' || i || '= ' || vn_base_num * i);
	END LOOP;
END;

DECLARE 
	vn_base_num CONSTANT NUMBER := 3;
BEGIN 
	FOR i IN 1..9
	LOOP 
		CONTINUE WHEN i = 5;
		dbms_output.put_line(vn_base_num || '*' || i || '= ' || vn_base_num * i);
	END LOOP;
END;

DECLARE 
	vn_base_num NUMBER := 3;
BEGIN 
	<<third>>
	FOR i IN 1..9
	LOOP 
		CONTINUE WHEN i = 5;
		dbms_output.put_line(vn_base_num || '*' || i || '= ' || vn_base_num * i);
		IF i = 3 THEN 
			GOTO fourth;
		END IF;
	END LOOP;

	<<fourth>>
	vn_base_num := 4;
	FOR i IN 1..9
	LOOP
		dbms_output.put_line(vn_base_num || '*' || i || '= ' || vn_base_num * i);
	END LOOP;
END;

SELECT MOD(10, 3) FROM dual ;
SELECT floor(10 / 3) FROM dual ;

CREATE OR REPLACE FUNCTION my_mod(num1 NUMBER, num2 NUMBER)
	RETURN NUMBER 
IS 
	vn_remainder NUMBER := 0;
	vn_quotient	 NUMBER := 0;
BEGIN 
	vn_quotient  := floor(num1 / num2);
	vn_remainder := num1 - (num2 * vn_quotient);

	RETURN vn_remainder;
END;

SELECT my_mod(14, 3) reminder FROM dual ;

CREATE OR REPLACE FUNCTION fn_get_country_name(p_country_id NUMBER)
	RETURN varchar2 
IS 
	vs_country_name countries.COUNTRY_NAME%TYPE;
BEGIN 
	SELECT COUNTRY_NAME 
	INTO vs_country_name
	FROM countries
	WHERE COUNTRY_ID = p_country_id;

	RETURN vs_country_name;
END;

SELECT fn_get_country_name(52777) coun1, fn_get_country_name(10000) coun2 FROM dual ;

SELECT * FROM countries ;

CREATE OR REPLACE FUNCTION fn_get_country_name(p_country_id NUMBER)
	RETURN varchar2 
IS 
	vs_country_name countries.COUNTRY_NAME%TYPE;
	vn_count NUMBER := 0;
BEGIN 
	SELECT count(*) 
	INTO vn_count
	FROM countries
	WHERE COUNTRY_ID = p_country_id;

	IF vn_count = 0 THEN 
		vs_country_name := '해당국가 없음';
	ELSE 
		SELECT COUNTRY_NAME 
		INTO vs_country_name
		FROM countries
		WHERE COUNTRY_ID = p_country_id;
	END IF ;

	RETURN vs_country_name;
END;


 -- 230409
CREATE OR REPLACE FUNCTION fn_get_user
	RETURN varchar2 
IS 
	vs_user_name varchar2(80);
BEGIN 
	SELECT USER
	INTO vs_user_name
	FROM dual;

	RETURN vs_user_name;
END;

SELECT fn_get_user(), fn_get_user
FROM dual ;

CREATE OR REPLACE PROCEDURE ORA_USER.MY_NEW_JOB_PROC
( p_job_id IN JOBS.JOB_ID%TYPE,
  p_job_title IN JOBS.JOB_TITLE%TYPE,
  p_min_sal IN JOBS.MIN_SALARY%TYPE,
  p_max_sal IN JOBS.MAX_SALARY%TYPE )
IS
	
BEGIN
	INSERT INTO JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY, CREATE_DATE, UPDATE_DATE)
	-- INSERT할 컬럼 인자들을 다 넣어주지 않으면 컴파일시 에러발생
	VALUES (p_job_id, p_job_title, p_min_sal, p_max_sal, sysdate, sysdate);

	COMMIT;
END MY_NEW_JOB_PROC;

EXEC MY_NEW_JOB_PROC ('SM_JOB1', 'Sample JOB1', 1000, 5000);

BEGIN 
	ORA_USER.MY_NEW_JOB_PROC ('SM_JOB2', 'Sample JOB2', 8000, 4000);
END;

CALL ORA_USER.MY_NEW_JOB_PROC('SM_JOB1', 'Sample JOB1', 1000, 5000);

--GRANT EXECUTE ON dbms_crypto TO ORA_USER ;

SELECT *
FROM JOBS 
WHERE JOB_ID = 'SM_JOB1'
;

CREATE OR REPLACE PROCEDURE MY_NEW_JOB_PROC
( p_job_id IN JOBS.JOB_ID%TYPE,
  p_job_title IN JOBS.JOB_TITLE%TYPE,
  p_min_sal IN JOBS.MIN_SALARY%TYPE:=10,
  p_max_sal IN JOBS.MAX_SALARY%TYPE:=100
--  p_upd_date OUT JOBS.UPDATE_DATE%TYPE
)
IS
	vn_cnt NUMBER := 0;
	vn_cur_date JOBS.UPDATE_DATE%TYPE := sysdate ;
BEGIN
	IF p_min_sal < 1000 THEN
		dbms_output.put_line('최소 급여값은 1000 이상이어야 합니다.');
		RETURN;
	END IF;
	
	SELECT COUNT(*) 
	INTO vn_cnt
	FROM JOBS
	WHERE JOB_ID = p_job_id;

	IF vn_cnt = 0 THEN 
		INSERT INTO JOBS (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY, CREATE_DATE, UPDATE_DATE)
		VALUES (p_job_id, p_job_title, p_min_sal, p_max_sal, vn_cur_date, vn_cur_date);
	ELSE 
		UPDATE JOBS 
		SET	   JOB_TITLE = p_job_title,
			   MIN_SALARY = p_min_sal,
			   MAX_SALARY = p_max_sal,
			   UPDATE_DATE = vn_cur_date 
		WHERE JOB_ID = p_job_id;
	END IF;

--	p_upd_date := vn_cur_date;

	COMMIT;
END;

BEGIN 
	MY_NEW_JOB_PROC('SM_JOB1', 'Sample JOB1', 1000, 6000);
END;

BEGIN 
	MY_NEW_JOB_PROC(p_job_id => 'SM_JOB1', p_job_title => 'Sample JOB1', p_min_sal => 2000, p_max_sal => 7000);
END;

BEGIN 
	MY_NEW_JOB_PROC('SM_JOB1', 'Sample JOB1');
END;

DECLARE 
	vd_cur_date JOBS.UPDATE_DATE%TYPE ;
BEGIN
	MY_NEW_JOB_PROC('SM_JOB1', 'Sample JOB1', 2000, 6000, vd_cur_date);

	dbms_output.put_line(vd_cur_date);
END;

CREATE OR REPLACE PROCEDURE my_parameter_test_proc (
	p_var1 varchar2,
	p_var2 OUT varchar2,
	p_var3 IN OUT varchar2 )
IS 
	
BEGIN 
	dbms_output.put_line('p_var1 value = ' || p_var1);
	dbms_output.put_line('p_var2 value = ' || p_var2);
	dbms_output.put_line('p_var3 value = ' || p_var3);

	p_var2 := 'B2';
	p_var3 := 'C2';
END;
	
DECLARE 
	v_var1 varchar2(10) := 'A';
	v_var2 varchar2(10) := 'B';
	v_var3 varchar2(10) := 'C';
BEGIN 
	my_parameter_test_proc(v_var1, v_var2, v_var3);

	dbms_output.put_line('v_var1 value = ' || v_var1);
	dbms_output.put_line('v_var2 value = ' || v_var2);
	dbms_output.put_line('v_var3 value = ' || v_var3);
END;

DECLARE 
	vn_base_num NUMBER := 3;
BEGIN 
	FOR i IN reverse 1..9
	LOOP
		dbms_output.put_line(vn_base_num || '*' || i || '= ' || vn_base_num * i);
	END LOOP;	
END;

DECLARE 
	vi_num NUMBER ;
BEGIN 
	vi_num := 100;

	dbms_output.put_line(vi_num);
END;

SELECT INITCAP('test') FROM dual ;

 -- Self-Check 2
CREATE OR REPLACE FUNCTION my_initcap(str varchar2)
	RETURN varchar2
IS 
	vn_str varchar2(80);
BEGIN 
	vn_str := UPPER(SUBSTR(str, 0, 1))||SUBSTR(str, 2);

	RETURN vn_str;
END ;

SELECT UPPER(SUBSTR('test str', 0, 1))||SUBSTR('test str', 2) FROM dual ;
SELECT SUBSTR('test str', 2) FROM dual ;

SELECT my_initcap('jason mraz') FROM dual ;

SELECT TO_CHAR(LAST_DAY('20230109'), 'DD') FROM dual ;

 -- Self-Check 3
CREATE OR REPLACE FUNCTION my_last_day(dt varchar2)
	RETURN varchar2
IS 
	vs_last_day varchar2(23);
BEGIN 
	vs_last_day := TO_CHAR(LAST_DAY(dt), 'DD');

	RETURN vs_last_day;
END;

SELECT my_last_day('20220201') FROM dual ;

CREATE TABLE ch09_dept (
	department_id NUMBER,
	department_name varchar2(100),
	levels number
);

SELECT 
	DEPARTMENT_ID , 
	LPAD(' ', 3 * (LEVEL - 1)) || DEPARTMENT_NAME ,
	LEVEL 
FROM 
	DEPARTMENTS 
START WITH parent_id IS NULL
CONNECT BY PRIOR DEPARTMENT_ID = PARENT_ID 
ORDER siblings BY DEPARTMENT_NAME 
;

 -- Self-Check 4
CREATE OR REPLACE PROCEDURE my_hier_dept_proc
IS 

BEGIN 
	DELETE FROM ch09_dept ;
	
	INSERT INTO ch09_dept (department_id, department_name, levels)
	SELECT 
		DEPARTMENT_ID , 
		LPAD(' ', 3 * (LEVEL - 1)) || DEPARTMENT_NAME ,
		LEVEL 
	FROM 
		DEPARTMENTS 
	START WITH parent_id IS NULL
	CONNECT BY PRIOR DEPARTMENT_ID = PARENT_ID 
	ORDER siblings BY DEPARTMENT_NAME ;
END;

SELECT * FROM ch09_dept;

CALL my_hier_dept_proc();


 -- 230410
 -- Self-Check 5
CREATE OR REPLACE PROCEDURE MY_NEW_JOB_PROC2
( p_job_id IN JOBS.JOB_ID%TYPE,
  p_job_title IN JOBS.JOB_TITLE%TYPE,
  p_min_sal IN JOBS.MIN_SALARY%TYPE,
  p_max_sal IN JOBS.MAX_SALARY%TYPE )
IS
	vn_cnt NUMBER := 0;
BEGIN
	MERGE INTO JOBS a
	USING (SELECT COUNT(*) AS cnt 
			FROM JOBS
			WHERE JOB_ID = p_job_id) b
	ON (b.cnt = 1)
	WHEN MATCHED THEN 
		UPDATE  
		SET	   a.JOB_TITLE = p_job_title,
			   a.MIN_SALARY = p_min_sal,
			   a.MAX_SALARY = p_max_sal,
			   a.UPDATE_DATE = sysdate 
		WHERE a.JOB_ID = p_job_id
	WHEN NOT MATCHED THEN 
		INSERT (a.JOB_ID, a.JOB_TITLE, a.MIN_SALARY, a.MAX_SALARY, a.CREATE_DATE, a.UPDATE_DATE)
		VALUES (p_job_id, p_job_title, p_min_sal, p_max_sal, sysdate, sysdate);

	COMMIT;
END;

BEGIN 
	MY_NEW_JOB_PROC2('SM_JOB$', 'test222', 200023, 100044);
END;

CREATE TABLE ch09_deparments AS 
SELECT DEPARTMENT_ID , DEPARTMENT_NAME , PARENT_ID 
FROM DEPARTMENTS ;

SELECT * FROM ch09_deparments ;

 -- Self-Check 6
CREATE OR REPLACE PROCEDURE my_dept_manage_proc
( p_department_id IN DEPARTMENTS.DEPARTMENT_ID%TYPE,
  p_deparment_name IN DEPARTMENTS.DEPARTMENT_NAME%TYPE,
  p_parent_id IN DEPARTMENTS.PARENT_ID%TYPE,
  p_proc_flag IN varchar2	-- 인수선언할때 byte수 지정안함
)
IS 
	vn_cnt NUMBER := 0;
BEGIN 
--	dbms_output.put_line('1');
	IF p_proc_flag = 'upsert' THEN 
--		dbms_output.put_line('2');
		SELECT COUNT(*) 
		INTO vn_cnt
		FROM DEPARTMENTS
		WHERE DEPARTMENT_ID = p_department_id;
	
		CASE WHEN vn_cnt > 0 THEN
--			dbms_output.put_line('3');
			UPDATE ch09_deparments
			SET  DEPARTMENT_NAME = p_deparment_name,
				 PARENT_ID = p_parent_id
			WHERE DEPARTMENT_ID = p_department_id;
			 ELSE 
--				 dbms_output.put_line('4');
				INSERT INTO ch09_deparments (DEPARTMENT_ID, DEPARTMENT_NAME, PARENT_ID)
				VALUES (p_department_id, p_deparment_name, p_parent_id);
		END CASE;
	ELSE 
--		dbms_output.put_line('5');
		SELECT COUNT(*) 
		INTO vn_cnt
		FROM EMPLOYEES
		WHERE DEPARTMENT_ID = p_department_id;
	
		CASE WHEN vn_cnt > 0 THEN
			dbms_output.put_line('해당 부서에 속한 사원이 존재합니다.');
			RETURN;
			 ELSE 
				 dbms_output.put_line('6');
				 DELETE FROM ch09_deparments WHERE DEPARTMENT_ID = p_department_id;
		END CASE;
	END IF;

	COMMIT;
END;

BEGIN 
	my_dept_manage_proc(280, 'QA팀', 210, 'delete');
END;

SELECT * FROM ch09_deparments d ;
SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID = '280' ;


 -- 230411
DECLARE 
	vi_num NUMBER := 0;
BEGIN 
	vi_num := 10 / 0;
	dbms_output.put_line('Success!');

	EXCEPTION WHEN OTHERS THEN
		dbms_output.put_line('오류가 발생했습니다');
END;

CREATE OR REPLACE PROCEDURE ch10_no_exception_proc
IS 
	vi_num NUMBER := 0;
BEGIN 
	vi_num := 10 / 0;
	dbms_output.put_line('Success!');
END;

CREATE OR REPLACE PROCEDURE ch10_exception_proc
IS 
	vi_num NUMBER := 0;
BEGIN 
	vi_num := 10 / 0;
	dbms_output.put_line('Success! 11');

	EXCEPTION 
	WHEN ZERO_DIVIDE THEN
		dbms_output.put_line('오류 1');
		dbms_output.put_line('SQL ERROR MESSAGE1: ' || sqlerrm);
--		dbms_output.put_line(sqlerrm(sqlcode));
--		dbms_output.put_line(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	WHEN OTHERS THEN 
		dbms_output.put_line('오류 2');
		dbms_output.put_line('SQL ERROR MESSAGE2: ' || sqlerrm);
END;

DECLARE 
	vi_num NUMBER := 0;
BEGIN 
	ch10_no_exception_proc;
	dbms_output.put_line('Success!');
END;

DECLARE 
	vi_num NUMBER := 0;
BEGIN 
	ch10_exception_proc;
	dbms_output.put_line('Success! 22');
END;

BEGIN 
	ch10_exception_proc;
END;

CREATE OR REPLACE PROCEDURE ch10_upd_jobid_proc
( p_employee_id employees.EMPLOYEE_ID%TYPE,
  p_job_id jobs.JOB_ID%TYPE )
IS 
	vn_cnt NUMBER := 0;
BEGIN 
	SELECT 1
	INTO vn_cnt
	FROM JOBS 
	WHERE JOB_ID = p_job_id;

	UPDATE employees
	SET JOB_ID = p_job_id
	WHERE EMPLOYEE_ID = p_employee_id;

--	IF vn_cnt = 0 THEN
--		dbms_output.put_line('job_id가 없습니다');
--		return;
--	ELSE 
--		UPDATE employees
--		SET JOB_ID = p_job_id
--		WHERE EMPLOYEE_ID = p_employee_id;
--	END IF;

	COMMIT;

EXCEPTION 
WHEN no_data_found THEN
	dbms_output.put_line(sqlerrm);
	dbms_output.put_line(p_job_id || '에 해당되는 job_id가 없습니다.');
WHEN OTHERS THEN 
	dbms_output.put_line('기타 에러: ' || sqlerrm);
END;

BEGIN 
	ch10_upd_jobid_proc(200, 'SM_JOB4');
END;

SELECT 1 FROM jobs WHERE JOB_ID = 'SM_JOB4' ;
SELECT * FROM employees WHERE EMPLOYEE_ID = '200' ;

CREATE OR REPLACE PROCEDURE ch10_ins_emp_proc(
	p_emp_name employees.EMP_NAME%TYPE,
	p_department_id departments.DEPARTMENT_ID%TYPE,
	p_hire_month varchar2 )
IS 
	vn_employee_id employees.EMPLOYEE_ID%TYPE;
	vd_curr_date   DATE := sysdate;
	vn_cnt		   NUMBER := 0;

	ex_invalid_depid EXCEPTION;

	ex_invalid_month EXCEPTION;
	pragma exception_init (ex_invalid_month, -1843);
BEGIN 
	SELECT COUNT(*)
	INTO vn_cnt
	FROM DEPARTMENTS 
	WHERE DEPARTMENT_ID = p_department_id;

	IF vn_cnt = 0 THEN 
		raise ex_invalid_depid;
	END IF;

	IF substr(p_hire_month, 5, 2) NOT BETWEEN '01' AND '12' THEN 
		raise ex_invalid_month;
	END IF;

	SELECT MAX(employee_id) + 1 
	INTO vn_employee_id
	FROM EMPLOYEES;
	
	INSERT INTO EMPLOYEES ( employee_id, EMP_NAME, HIRE_DATE, DEPARTMENT_ID )
	VALUES ( vn_employee_id, p_emp_name, to_date(p_hire_month || '01'), p_department_id );

	COMMIT;

EXCEPTION 
WHEN ex_invalid_depid THEN 
	dbms_output.put_line('해당 부서번호가 없습니다.');
WHEN ex_invalid_month THEN 
	dbms_output.put_line(sqlcode);
	dbms_output.put_line(sqlerrm);
	dbms_output.put_line('1~12월 범위를 벗어난 월입니다.');
WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);

END;

BEGIN 
	ch10_ins_emp_proc('홍길동', 110, '201314');
END;

SELECT * FROM DEPARTMENTS ;
SELECT to_date('201312' || '01') FROM dual ;
SELECT '201314' || '01' FROM dual ;


 -- 230412
CREATE OR REPLACE PROCEDURE ch10_raise_test_proc( p_num NUMBER )
IS 
	
BEGIN 
	IF p_num <= 0 THEN 
--		raise invalid_number;
		raise_application_error(-20000, '양수만 입력받을 수 있단 말입니다!');
	END IF;

	dbms_output.put_line(p_num);

EXCEPTION 
WHEN invalid_number THEN 
	dbms_output.put_line('양수만 입력받을 수 있습니다.');
WHEN OTHERS THEN 
	dbms_output.put_line(sqlcode);
	dbms_output.put_line(sqlerrm);
END;

BEGIN 
	ch10_raise_test_proc(-10);
END;

CREATE TABLE error_log (
	error_seq		NUMBER,				 -- 에러 시퀀스
	prog_name		varchar2(80),		 -- 프로그램명
	error_code		NUMBER,				 -- 에러코드
	error_message	varchar2(300),		 -- 에러 메시지
	error_line		varchar2(100),		 -- 에러 라인
	error_date		DATE DEFAULT sysdate -- 에러 발생 일자
);

SELECT * FROM error_log ;

CREATE SEQUENCE error_seq
	   INCREMENT BY 1
	   START WITH 1
	   MINVALUE 1
	   MAXVALUE 999999
	   nocycle
	   nocache;
	   
CREATE OR REPLACE PROCEDURE error_log_proc (
	p_prog_name error_log.PROG_NAME%TYPE,
	p_error_code error_log.ERROR_CODE%TYPE,
	p_error_message error_log.ERROR_MESSAGE%TYPE,
	p_error_line error_log.ERROR_LINE%TYPE )
IS 

BEGIN 
	INSERT INTO error_log (ERROR_SEQ, PROG_NAME, ERROR_CODE, ERROR_MESSAGE, ERROR_LINE)
	VALUES (error_seq.nextval, p_prog_name, p_error_code, p_error_message, p_error_line);

	COMMIT;
END;

CREATE OR REPLACE PROCEDURE ch10_ins_emp2_proc(
	p_emp_name employees.EMP_NAME%TYPE,
	p_department_id departments.DEPARTMENT_ID%TYPE,
	p_hire_month varchar2 )
IS 
	vn_employee_id employees.EMPLOYEE_ID%TYPE;
	vd_curr_date   DATE := sysdate;
	vn_cnt		   NUMBER := 0;

	ex_invalid_depid EXCEPTION;
	pragma exception_init (ex_invalid_depid, -20000);

	ex_invalid_month EXCEPTION;
	pragma exception_init (ex_invalid_month, -1843);

	v_err_code error_log.error_code%TYPE;
	v_err_msg error_log.error_message%TYPE;
	v_err_line error_log.error_line%TYPE;
BEGIN 
	SELECT COUNT(*)
	INTO vn_cnt
	FROM DEPARTMENTS 
	WHERE DEPARTMENT_ID = p_department_id;

	IF vn_cnt = 0 THEN 
		raise ex_invalid_depid;
	END IF;

	IF substr(p_hire_month, 5, 2) NOT BETWEEN '01' AND '12' THEN 
		raise ex_invalid_month;
	END IF;

	SELECT MAX(employee_id) + 1 
	INTO vn_employee_id
	FROM EMPLOYEES;
	
	INSERT INTO EMPLOYEES ( employee_id, EMP_NAME, HIRE_DATE, DEPARTMENT_ID )
	VALUES ( vn_employee_id, p_emp_name, to_date(p_hire_month || '01'), p_department_id );

	COMMIT;

EXCEPTION 
WHEN ex_invalid_depid THEN 
	v_err_code := sqlcode;
	v_err_msg := sqlerrm;
	v_err_line := dbms_utility.format_error_backtrace;
	ROLLBACK;
	error_log_proc('ch12_ins_emp2_proc', v_err_code, v_err_msg, v_err_line);
WHEN ex_invalid_month THEN 
	v_err_code := sqlcode;
	v_err_msg := sqlerrm;
	v_err_line := dbms_utility.format_error_backtrace;
	ROLLBACK;
	error_log_proc('ch12_ins_emp2_proc', v_err_code, v_err_msg, v_err_line);
WHEN OTHERS THEN 
	v_err_code := sqlcode;
	v_err_msg := sqlerrm;
	v_err_line := dbms_utility.format_error_backtrace;
	ROLLBACK;
	error_log_proc('ch12_ins_emp2_proc', v_err_code, v_err_msg, v_err_line);
END;

BEGIN 
	ch10_ins_emp2_proc('HONG', 100, '201413');
END;

SELECT * FROM DEPARTMENTS WHERE DEPARTMENT_ID = 1000 ;

SELECT * FROM error_log ;


 -- 230418
CREATE TABLE app_user_define_error (
	error_code 	  NUMBER,				-- 에러코드
	error_message varchar2(300),		-- 에러 메시지
	create_date   DATE DEFAULT sysdate,	-- 등록일자
	PRIMARY KEY (error_code)
);

INSERT INTO app_user_define_error (error_code, error_message)
VALUES (-1843, '지정한 월이 부적합합니다.');
INSERT INTO app_user_define_error (error_code, error_message)
VALUES (-20000, '해당 부서가 없습니다.');

SELECT * FROM app_user_define_error ;
SELECT * FROM ERROR_LOG ;

CREATE OR REPLACE PROCEDURE error_log_proc (
	p_prog_name error_log.PROG_NAME%TYPE,
	p_error_code error_log.ERROR_CODE%TYPE,
	p_error_message error_log.ERROR_MESSAGE%TYPE,
	p_error_line error_log.ERROR_LINE%TYPE )
IS 
	vn_error_code ERROR_LOG.ERROR_CODE%TYPE := p_error_code;
	vn_error_message ERROR_LOG.error_message%TYPE := p_error_message;
BEGIN 
	dbms_output.put_line(vn_error_code);
	BEGIN 
		SELECT error_message
		INTO vn_error_message
		FROM app_user_define_error
		WHERE error_code = vn_error_code;
		
	EXCEPTION WHEN no_data_found THEN 
		vn_error_message := p_error_message;
	END;
	
	dbms_output.put_line(vn_error_message);
	INSERT INTO error_log (ERROR_SEQ, PROG_NAME, ERROR_CODE, ERROR_MESSAGE, ERROR_LINE)
	VALUES (error_seq.nextval, p_prog_name, vn_error_code, vn_error_message, p_error_line);

	COMMIT;
END;

CREATE OR REPLACE PROCEDURE ch10_ins_emp2_proc(
	p_emp_name employees.EMP_NAME%TYPE,
	p_department_id departments.DEPARTMENT_ID%TYPE,
	p_hire_month varchar2 )
IS 
	vn_employee_id employees.EMPLOYEE_ID%TYPE;
	vd_curr_date   DATE := sysdate;
	vn_cnt		   NUMBER := 0;

	ex_invalid_depid EXCEPTION;
	pragma exception_init (ex_invalid_depid, -20000);

	ex_invalid_month EXCEPTION;
	pragma exception_init (ex_invalid_month, -1843);

	v_err_code error_log.error_code%TYPE;
	v_err_msg error_log.error_message%TYPE;
	v_err_line error_log.error_line%TYPE;
BEGIN 
	SELECT COUNT(*)
	INTO vn_cnt
	FROM DEPARTMENTS 
	WHERE DEPARTMENT_ID = p_department_id;

	IF vn_cnt = 0 THEN 
		raise ex_invalid_depid;
	END IF;

	IF substr(p_hire_month, 5, 2) NOT BETWEEN '01' AND '12' THEN 
		raise ex_invalid_month;
	END IF;

	SELECT MAX(employee_id) + 1 
	INTO vn_employee_id
	FROM EMPLOYEES;
	
	INSERT INTO EMPLOYEES ( employee_id, EMP_NAME, HIRE_DATE, DEPARTMENT_ID )
	VALUES ( vn_employee_id, p_emp_name, to_date(p_hire_month || '01'), p_department_id );

	COMMIT;

EXCEPTION 
WHEN ex_invalid_depid THEN 
	v_err_code := sqlcode;
	v_err_line := dbms_utility.format_error_backtrace;
	ROLLBACK;
	error_log_proc('ch12_ins_emp2_proc', v_err_code, v_err_msg, v_err_line);
WHEN ex_invalid_month THEN 
	v_err_code := sqlcode;
--	v_err_msg := sqlerrm;
	v_err_line := dbms_utility.format_error_backtrace;
	ROLLBACK;
	error_log_proc('ch12_ins_emp2_proc', v_err_code, v_err_msg, v_err_line);
WHEN OTHERS THEN 
	v_err_code := sqlcode;
	v_err_msg := sqlerrm||' : others문';
	v_err_line := dbms_utility.format_error_backtrace;
	ROLLBACK;
	error_log_proc('ch12_ins_emp2_proc', v_err_code, v_err_msg, v_err_line);
END;

BEGIN 
	ch10_ins_emp2_proc('HONG', 100, '2014013');
END;

SELECT * FROM ERROR_LOG ;

CREATE TABLE ch10_sales (
	sales_month varchar2(8),
	country_name varchar2(40),
	prod_category varchar2(50),
	channel_desc varchar2(20),
	sales_amt number
);

CREATE OR REPLACE PROCEDURE iud_ch10_sales_proc (
	p_sales_month ch10_sales.sales_month%type
)
IS 

BEGIN 
	INSERT INTO ch10_sales (SALES_MONTH, COUNTRY_NAME, PROD_CATEGORY, CHANNEL_DESC, SALES_AMT)
	SELECT a.SALES_MONTH, c.COUNTRY_NAME , d.PROD_CATEGORY , e.CHANNEL_DESC , SUM(a.AMOUNT_SOLD) 
	FROM sales a, customers b, countries c, products d, channels e
	WHERE a.SALES_MONTH = p_sales_month
	AND a.CUST_ID = b.CUST_ID 
	AND b.COUNTRY_ID = c.COUNTRY_ID 
	AND a.PROD_ID = d.PROD_ID 
	AND a.CHANNEL_ID = e.CHANNEL_ID 
	GROUP BY a.SALES_MONTH, c.COUNTRY_NAME , d.PROD_CATEGORY , e.CHANNEL_DESC ;

	COMMIT;

EXCEPTION WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
	ROLLBACK;
END;

BEGIN 
	iud_ch10_sales_proc('199901');
END;

SELECT a.SALES_MONTH, c.COUNTRY_NAME , d.PROD_CATEGORY , e.CHANNEL_DESC , SUM(a.AMOUNT_SOLD) 
FROM sales a, customers b, countries c, products d, channels e
WHERE a.SALES_MONTH = '199902'
AND a.CUST_ID = b.CUST_ID 
AND b.COUNTRY_ID = c.COUNTRY_ID 
AND a.PROD_ID = d.PROD_ID 
AND a.CHANNEL_ID = e.CHANNEL_ID 
GROUP BY a.SALES_MONTH, c.COUNTRY_NAME , d.PROD_CATEGORY , e.CHANNEL_DESC ;

SELECT COUNT(*) FROM ch10_sales;

--TRUNCATE TABLE ch10_sales ;


 -- 230420
ALTER TABLE ch10_sales ADD CONSTRAINTS pk_ch10_sales PRIMARY KEY 
(SALES_MONTH, COUNTRY_NAME, PROD_CATEGORY, CHANNEL_DESC);

ALTER TABLE ch10_sales DROP PRIMARY KEY ;

CREATE TABLE ch10_country_month_sales (
	sales_month varchar2(8),
	country_name varchar2(40),
	sales_amt NUMBER,
	PRIMARY KEY (sales_month, country_name)
);

CREATE OR REPLACE PROCEDURE iud_ch10_sales_proc (
	p_sales_month ch10_sales.sales_month%TYPE,
	p_country_name ch10_sales.COUNTRY_NAME%TYPE
)
IS 

BEGIN 
	DELETE ch10_sales
	WHERE SALES_MONTH = p_sales_month
	AND COUNTRY_NAME = p_country_name;

	INSERT INTO ch10_sales (SALES_MONTH, COUNTRY_NAME, PROD_CATEGORY, CHANNEL_DESC, SALES_AMT)
	SELECT a.SALES_MONTH, c.COUNTRY_NAME , d.PROD_CATEGORY , e.CHANNEL_DESC , SUM(a.AMOUNT_SOLD) 
	FROM sales a, customers b, countries c, products d, channels e
	WHERE a.SALES_MONTH = p_sales_month
	AND c.COUNTRY_NAME = p_country_name
	AND a.CUST_ID = b.CUST_ID 
	AND b.COUNTRY_ID = c.COUNTRY_ID 
	AND a.PROD_ID = d.PROD_ID 
	AND a.CHANNEL_ID = e.CHANNEL_ID 
	GROUP BY a.SALES_MONTH, c.COUNTRY_NAME , d.PROD_CATEGORY , e.CHANNEL_DESC ;

	UPDATE ch10_sales
	SET SALES_AMT = 10 * TO_NUMBER(TO_CHAR(SYSDATE, 'ss'))
	WHERE SALES_MONTH = p_sales_month
	AND COUNTRY_NAME = p_country_name;

	SAVEPOINT mysavepoint;

	INSERT INTO ch10_country_month_sales
	SELECT SALES_MONTH , COUNTRY_NAME , SUM(SALES_AMT)  
	FROM ch10_sales
	WHERE SALES_MONTH = p_sales_month
	AND COUNTRY_NAME = p_country_name
	GROUP BY SALES_MONTH , COUNTRY_NAME;

EXCEPTION WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
	ROLLBACK TO mysavepoint;

	COMMIT;
END;

--TRUNCATE TABLE ch10_sales ;
SELECT DISTINCT SALES_AMT FROM ch10_sales ;
SELECT * FROM ch10_country_month_sales ;

BEGIN 
	iud_ch10_sales_proc('199901', 'Italy');
END;

SELECT a.SALES_MONTH, c.COUNTRY_NAME , d.PROD_CATEGORY , e.CHANNEL_DESC , SUM(a.AMOUNT_SOLD) 
FROM sales a, customers b, countries c, products d, channels e
WHERE a.SALES_MONTH = '199901'
AND c.COUNTRY_NAME = 'Italy'
AND a.CUST_ID = b.CUST_ID 
AND b.COUNTRY_ID = c.COUNTRY_ID 
AND a.PROD_ID = d.PROD_ID 
AND a.CHANNEL_ID = e.CHANNEL_ID 
GROUP BY a.SALES_MONTH, c.COUNTRY_NAME , d.PROD_CATEGORY , e.CHANNEL_DESC ;

SELECT SALES_MONTH , COUNTRY_NAME , SUM(SALES_AMT)  
FROM ch10_sales
WHERE SALES_MONTH = '199901'
AND COUNTRY_NAME = 'Italy'
GROUP BY SALES_MONTH , COUNTRY_NAME;

CREATE TABLE ch10_departments AS 
SELECT DEPARTMENT_ID , DEPARTMENT_NAME 
FROM DEPARTMENTS ;

ALTER TABLE ch10_departments ADD CONSTRAINTS pk_ch10_deparments PRIMARY KEY (DEPARTMENT_ID);

SELECT * FROM ch10_departments ;

CREATE OR REPLACE PROCEDURE ch10_iud_dep_proc (
	p_department_id DEPARTMENTS.DEPARTMENT_ID%TYPE, 
	p_department_name DEPARTMENTS.DEPARTMENT_NAME%TYPE,
	p_flag char
)
IS 
	vn_cnt NUMBER := 0;

	ex_exist_employee EXCEPTION;
	pragma exception_init (ex_exist_employee, -20000);
BEGIN 
	CASE 
		WHEN p_flag = 'I' THEN
			INSERT INTO ch10_departments VALUES (p_department_id, p_department_name);
		WHEN p_flag = 'U' THEN
			UPDATE ch10_departments 
			SET DEPARTMENT_NAME = p_department_name
			WHERE DEPARTMENT_ID = p_department_id;
		WHEN p_flag = 'D' THEN
			SELECT COUNT(*) 
			INTO vn_cnt
			FROM EMPLOYEES
			WHERE DEPARTMENT_ID = p_department_id;
			
			IF vn_cnt > 0 THEN
--				raise ex_exist_employee;
				raise_application_error(-20001, '해당 부서에 할당된 사원이 존재하여, 삭제가 불가능합니다.');
			END IF;			
		
			DELETE FROM ch10_departments
			WHERE DEPARTMENT_ID = p_department_id;
	END CASE;

	COMMIT;

EXCEPTION 
WHEN dup_val_on_index THEN 
	dbms_output.put_line('dup_val_on_index 에러 발생!');
	dbms_output.put_line('sqlcode : ' || sqlcode);
	dbms_output.put_line('sqlerrm : ' || sqlerrm);
	ROLLBACK;
WHEN ex_exist_employee THEN
	dbms_output.put_line('sqlcode : ' || sqlcode);
	dbms_output.put_line(sqlerrm||'해당 부서에 할당된 사원이 존재하여, 삭제가 불가능합니다.');
	ROLLBACK;
WHEN OTHERS THEN 
	dbms_output.put_line('OTHERS 에러 발생!');
	dbms_output.put_line('sqlcode : ' || sqlcode);
	dbms_output.put_line('sqlerrm : ' || sqlerrm);
	ROLLBACK;
END;

BEGIN 
	ch10_iud_dep_proc('10', '총무기획부', 'D');
END;

SELECT COUNT(*) 
FROM EMPLOYEES
WHERE DEPARTMENT_ID = '1000'
;

DECLARE 
	vn_department_id employees.department_id%TYPE := 80;
BEGIN 
	UPDATE employees
	SET EMP_NAME = EMP_NAME 
	WHERE DEPARTMENT_ID = vn_department_id;

	dbms_output.put_line(SQL%rowcount);
	COMMIT;

END;

SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID = '80' ;


 -- 230423
DECLARE 
	vs_emp_name employees.emp_name%TYPE;
	
	CURSOR cur_emp_dep (cp_department_id employees.department_id%type)
	IS 
	SELECT EMP_NAME 
	FROM employees 
	WHERE DEPARTMENT_ID = cp_department_id;
BEGIN 
	OPEN cur_emp_dep (90);

	LOOP 
		FETCH cur_emp_dep INTO vs_emp_name;
	
		EXIT WHEN cur_emp_dep%notfound;
	
		dbms_output.put_line(vs_emp_name);
	END LOOP;
	
	CLOSE cur_emp_dep;
END;

SELECT EMP_NAME 
FROM employees 
WHERE DEPARTMENT_ID = '90';

DECLARE 
	CURSOR cur_emp_dep (cp_department_id employees.department_id%type)
	IS 
	SELECT EMP_NAME 
	FROM employees 
	WHERE DEPARTMENT_ID = cp_department_id;
BEGIN 
	FOR emp_rec IN cur_emp_dep(90)
	LOOP
		dbms_output.put_line(emp_rec.emp_name);
	END LOOP;
	
END;

DECLARE 

BEGIN 
	FOR emp_rec IN (
		SELECT EMP_NAME 
		FROM employees 
		WHERE DEPARTMENT_ID = 90
	)
	LOOP
		dbms_output.put_line(emp_rec.emp_name);
	END LOOP;
END;

DECLARE 
	vs_emp_name employees.emp_name%TYPE;
	
	TYPE emp_dep_curtype IS REF CURSOR;
	emp_dep_curvar emp_dep_curtype;
BEGIN 
	OPEN emp_dep_curvar FOR SELECT EMP_NAME 
							FROM EMPLOYEES 
							WHERE DEPARTMENT_ID = 90;
							
	LOOP 
		FETCH emp_dep_curvar INTO vs_emp_name;
	
		EXIT WHEN emp_dep_curvar%notfound;
	
		dbms_output.put_line(vs_emp_name);
	END LOOP;
END;

 -- 빌트인 커서 타입
DECLARE 
	vs_emp_name employees.emp_name%TYPE;
	
	emp_dep_curvar sys_refcursor;
BEGIN 
	OPEN emp_dep_curvar FOR SELECT EMP_NAME 
							FROM EMPLOYEES 
							WHERE DEPARTMENT_ID = 90;
							
	LOOP 
		FETCH emp_dep_curvar INTO vs_emp_name;
	
		EXIT WHEN emp_dep_curvar%notfound;
	
		dbms_output.put_line(vs_emp_name);
	END LOOP;
END;

 -- 커서 변수를 매개변수로 전달하기
DECLARE 
	emp_dep_curvar sys_refcursor;

	vs_emp_name employees.emp_name%TYPE;

	PROCEDURE test_cursor_argu (p_curvar IN OUT sys_refcursor)
	IS 
		c_temp_curvar sys_refcursor;
	BEGIN 
		OPEN c_temp_curvar FOR
		SELECT EMP_NAME 
		FROM EMPLOYEES 
		WHERE DEPARTMENT_ID = 90;
	
		p_curvar := c_temp_curvar;
	END;
	
BEGIN 
	test_cursor_argu(emp_dep_curvar);

	LOOP
		FETCH emp_dep_curvar INTO vs_emp_name;
		EXIT WHEN emp_dep_curvar%notfound;
		dbms_output.put_line(vs_emp_name);
	END LOOP;	
END;

 -- 커서 표현식
SELECT d.DEPARTMENT_NAME ,
	   CURSOR (
	       SELECT e.EMP_NAME 
	       FROM EMPLOYEES e
	       WHERE e.DEPARTMENT_ID = d.DEPARTMENT_ID 
	   ) AS emp_name 
FROM DEPARTMENTS d 
WHERE d.DEPARTMENT_ID = 90
;

 -- 익명 블록에서 커서 표현식 사용
DECLARE 
	CURSOR mytest_cursor IS 
	SELECT d.DEPARTMENT_NAME ,
		   CURSOR (
		       SELECT e.EMP_NAME 
		       FROM EMPLOYEES e
		       WHERE e.DEPARTMENT_ID = d.DEPARTMENT_ID 
		   ) AS emp_name 
	FROM DEPARTMENTS d 
	WHERE d.DEPARTMENT_ID = 90;

	vs_department_name DEPARTMENTS.department_name%TYPE;

	c_emp_name sys_refcursor;

	vs_emp_name EMPLOYEES.emp_name%TYPE;
BEGIN 
	OPEN mytest_cursor;

	LOOP
		FETCH mytest_cursor INTO vs_department_name, c_emp_name;
		EXIT WHEN mytest_cursor%notfound;
		dbms_output.put_line('부서명 : '||vs_department_name);
	
		LOOP
			FETCH c_emp_name INTO vs_emp_name;
			EXIT WHEN c_emp_name%notfound;
		
			dbms_output.put_line('    사원명 : '||vs_emp_name);
		END LOOP;
	END LOOP;
END;


 -- 230427
DECLARE 
	TYPE depart_rect IS RECORD (
		department_id	number(6),
		department_name varchar2(80),
		parent_id		number(6),
		manager_id		number(6)
	);

	vr_dep depart_rect;
BEGIN 
	
END;

DECLARE 
	TYPE depart_rect IS RECORD (
		department_id	departments.department_id%type,
		department_name departments.department_name%type,
		parent_id		departments.parent_id%type,
		manager_id		departments.manager_id%type
	);

	vr_dep depart_rect;

	vr_dep2 depart_rect;
BEGIN 
	vr_dep.department_id := 999;
	vr_dep.department_name := '테스트부서';
	vr_dep.parent_id := 100;
	vr_dep.manager_id := NULL;

	vr_dep2 := vr_dep;

	dbms_output.put_line('vr_dep2.department_id : ' || vr_dep2.department_id);
	dbms_output.put_line('vr_dep2.department_name : ' || vr_dep2.department_name);
	dbms_output.put_line('vr_dep2.parent_id : ' || vr_dep2.parent_id);
	dbms_output.put_line('vr_dep2.manager_id : ' || vr_dep2.manager_id);
END;

CREATE TABLE ch11_dep AS 
SELECT DEPARTMENT_ID , DEPARTMENT_NAME , PARENT_ID , MANAGER_ID 
FROM DEPARTMENTS ;

TRUNCATE TABLE ch11_dep;

DECLARE  
	TYPE depart_rect IS RECORD (
		department_id	departments.department_id%type,
		department_name departments.department_name%type,
		parent_id		departments.parent_id%type,
		manager_id		departments.manager_id%type
	);

	vr_dep depart_rect;
BEGIN 
	vr_dep.department_id := 999;
	vr_dep.department_name := '테스트부서';
	vr_dep.parent_id := 100;
	vr_dep.manager_id := NULL;

	INSERT INTO ch11_dep 
	VALUES (vr_dep.department_id, vr_dep.department_name, vr_dep.parent_id, vr_dep.manager_id);

	INSERT INTO ch11_dep VALUES vr_dep;

	COMMIT;
END;

SELECT * FROM ch11_dep ;

CREATE TABLE ch11_dep2 AS 
SELECT *
FROM DEPARTMENTS ;

TRUNCATE TABLE ch11_dep2 ;

DECLARE 
	vr_dep departments%rowtype;
BEGIN 
	SELECT *
	INTO vr_dep
	FROM DEPARTMENTS 
	WHERE DEPARTMENT_ID = 20;

	INSERT INTO ch11_dep2 VALUES vr_dep;

	COMMIT;
END;

SELECT * FROM ch11_dep2 ;

 -- 커서형 레코드
DECLARE 
	CURSOR c1 IS 
	SELECT DEPARTMENT_ID , DEPARTMENT_NAME , PARENT_ID , MANAGER_ID 
	FROM DEPARTMENTS ;

	vr_dep c1%rowtype;
BEGIN 
	DELETE ch11_dep;

	OPEN c1;

	LOOP
		FETCH c1 INTO vr_dep;
	
		EXIT WHEN c1%notfound;
		INSERT INTO ch11_dep VALUES vr_dep;
	END LOOP;
	
	COMMIT;
END;

SELECT * FROM ch11_dep ;

 -- 레코드 변수로 update
DECLARE  
	vr_dep ch11_dep%rowtype;
BEGIN 
	vr_dep.department_id := 20;
	vr_dep.department_name := '테스트';
	vr_dep.parent_id := 10;
	vr_dep.manager_id := 200;

	UPDATE ch11_dep
	SET ROW = vr_dep
	WHERE department_id = vr_dep.department_id;

	COMMIT;
END;

 -- 중첩 레코드
DECLARE 
	TYPE dep_rec IS RECORD (
		dep_id		departments.department_id%TYPE,
		dep_name 	departments.department_name%type
	);

	TYPE emp_rec IS RECORD (
		emp_id		employees.employee_id%TYPE,
		emp_name 	employees.emp_name%TYPE,
		dep			dep_rec
	);

	vr_emp_rec emp_rec;
BEGIN 
	SELECT a.EMPLOYEE_ID , a.EMP_NAME , a.DEPARTMENT_ID , b.DEPARTMENT_NAME 
	INTO vr_emp_rec.emp_id, vr_emp_rec.emp_name, vr_emp_rec.dep.dep_id, vr_emp_rec.dep.dep_name
	FROM EMPLOYEES a,
		DEPARTMENTS b
	WHERE a.EMPLOYEE_ID = 100
	AND a.DEPARTMENT_ID = b.DEPARTMENT_ID;

	dbms_output.put_line('emp_id : ' || vr_emp_rec.emp_id);
	dbms_output.put_line('emp_name : ' || vr_emp_rec.emp_name);
	dbms_output.put_line('dep_id : ' || vr_emp_rec.dep.dep_id);
	dbms_output.put_line('dep_name : ' || vr_emp_rec.dep.dep_name);
END;


 -- 230428
 -- 컬렉션: 연관 배열
DECLARE 
	TYPE av_type IS TABLE OF varchar2(40)
					INDEX BY pls_integer;
				
	vav_test av_type;
BEGIN 
	vav_test(10) := '10에 대한 값';
	vav_test(20) := '20에 대한 값';

	dbms_output.put_line(vav_test(10));
	dbms_output.put_line(vav_test(20));
END;

 -- VARRAY
DECLARE 
	TYPE va_type IS varray(5) OF varchar2(20);

	vva_test va_type;

	vn_cnt NUMBER := 0;
BEGIN 
	vva_test := va_type('FIRST', 'SECOND', 'THIRD', '', '');

	LOOP
		vn_cnt := vn_cnt + 1;
		IF vn_cnt > 5 THEN
			EXIT;
		END IF;
	
		dbms_output.put_line(vva_test(vn_cnt));
	END LOOP;

	dbms_output.put_line(chr(10));	-- 줄바꿈

	vva_test(2) := 'TEST';
	vva_test(4) := 'FOURTH';

	vn_cnt := 0;
	LOOP
		vn_cnt := vn_cnt + 1;
		IF vn_cnt > 5 THEN
			EXIT;
		END IF;
	
		dbms_output.put_line(vva_test(vn_cnt));
	END LOOP;
END;

 -- 중첩 테이블
DECLARE 
	TYPE nt_typ IS TABLE OF varchar2(10);

	vnt_test nt_typ;
BEGIN 
	vnt_test := nt_typ('FIRST', 'SECOND', 'THIRD');

	dbms_output.put_line(vnt_test(1));
	dbms_output.put_line(vnt_test(2));
	dbms_output.put_line(vnt_test(3));
END;

 -- 컬렉션 DELETE 메소드
DECLARE 
	TYPE av_type IS TABLE OF varchar2(40)	-- 값 타입
					INDEX BY varchar2(10);	-- 인덱스 타입
					
	vav_test av_type;

	vn_cnt NUMBER := 0;
BEGIN 
	vav_test('A') := '10에 대한 값';
	vav_test('B') := '20에 대한 값';
	vav_test('C') := '20에 대한 값';

	vn_cnt := vav_test.count;
	dbms_output.put_line('삭제 전 요소 개수: ' || vn_cnt);
	vav_test.delete('A', 'B');

	vn_cnt := vav_test.count;

	dbms_output.put_line('삭제 후 요소 개수: ' || vn_cnt);
END;

 -- TRIM 메소드
DECLARE 
	TYPE nt_type IS TABLE OF varchar2(10);

	vnt_test nt_type;
BEGIN 
	vnt_test := nt_type('FIRST', 'SECOND', 'THIRD', 'FOURTH', 'FIFTH');

	vnt_test.trim(2);

	dbms_output.put_line(vnt_test(1));
	dbms_output.put_line(vnt_test(2));
	dbms_output.put_line(vnt_test(3));
	dbms_output.put_line(vnt_test(4));

EXCEPTION WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
	dbms_output.put_line(DBMS_utility.format_error_backtrace);
END;

 -- EXTEND 메소드
DECLARE 
	TYPE nt_type IS TABLE OF varchar2(10);

	vnt_test nt_type;
BEGIN 
	vnt_test := nt_type('FIRST', 'SECOND', 'THIRD');

	vnt_test.extend;
	vnt_test(4) := 'fourth';
	dbms_output.put_line(vnt_test(4));

	vnt_test.extend(2, 1);
	dbms_output.put_line('첫번쨰 : ' || vnt_test(1));

	dbms_output.put_line('추가한 요소1 : ' || vnt_test(5));
	dbms_output.put_line('추가한 요소2 : ' || vnt_test(6));
END;

 -- FIRST, LAST 메소드
DECLARE 
	TYPE nt_typ IS TABLE OF varchar2(10);

	vnt_test nt_typ;
BEGIN 
	vnt_test := nt_typ('FIRST', 'SECOND', 'THIRD', 'FOURTH', 'FIFTH');

	FOR i IN vnt_test.FIRST..vnt_test.LAST 
	LOOP
		dbms_output.put_line(i || '번쨰 요소 값: ' || vnt_test(i));
	END LOOP;
	
END;

 -- COUNT, LIMIT 메소드
DECLARE 
	TYPE nt_typ IS TABLE OF varchar2(10);	-- 중첩 테이블
	TYPE va_type IS varray(5) OF varchar2(10);

	vnt_test nt_typ;
	vva_test va_type;
BEGIN 
	vnt_test := nt_typ('FIRST', 'SECOND', 'THIRD', 'FOURTH');
	vva_test := va_type('첫번쨰', '두번쨰', '세번쨰', '네번쨰');

	dbms_output.put_line('varray count: ' || vva_test.count);
	dbms_output.put_line('중첩 테이블 count: ' || vnt_test.count);

	dbms_output.put_line('varray limit: ' || vva_test.limit);
	dbms_output.put_line('중첩 테이블 limit: ' || vnt_test.limit);
END;

 -- PRIOR, NEXT 메소드
DECLARE 
	TYPE va_type IS varray(5) OF varchar2(10);

	vva_test va_type;
BEGIN 
	vva_test := va_type('첫번쨰', '두번쨰', '세번쨰', '네번쨰');

	dbms_output.put_line('FIRST의 PRIOR : ' || vva_test.PRIOR(vva_test.first));
	dbms_output.put_line('last의 NEXT : ' || vva_test.NEXT(vva_test.last));

	dbms_output.put_line('인덱스3의 PRIOR: ' || vva_test.PRIOR(3));
	dbms_output.put_line('인덱스3의 NEXT: ' || vva_test.NEXT(3));
END;

 -- 사용자 정의 타입
CREATE OR REPLACE TYPE ch11_va_type IS varray(5) OF varchar2(20);

CREATE OR REPLACE TYPE ch11_nt_type IS TABLE OF varchar2(20);

DECLARE 
	vva_test ch11_va_type;
	vnt_test ch11_nt_type;
BEGIN 
	vva_test := ch11_va_type('FIRST', 'SECOND', 'THIRD', '', '');
	vnt_test := ch11_nt_type('FIRST', 'SECOND', 'THIRD', '');

	dbms_output.put_line(vva_test(4));
	dbms_output.put_line(vnt_test(1));
END;

 -- VARRAY 타입인 요소로 구성된 VARRAY 타입의 컬렉션
DECLARE 
	TYPE va_type1 IS varray(5) OF NUMBER;

	TYPE va_type11 IS varray(3) OF va_type1;

	va_test va_type11;
BEGIN 
	va_test := va_type11(va_type1(1, 2, 3, 4, 5), va_type1(2, 4, 6, 8, 10), va_type1(3, 6, 9, 12, 15));
			  
	dbms_output.put_line('2곱하기 3은 ' || va_test(2)(3));
	dbms_output.put_line('3곱하기 5은 ' || va_test(3)(5));
END;


 -- 230502
 -- 레코드 타입을 요소로 가진 중첩 테이블
DECLARE 
	TYPE nt_type IS TABLE OF EMPLOYEES%rowtype;

	vnt_test nt_type;
BEGIN 
	vnt_test := nt_type();
	vnt_test.extend;	-- 요소 1개 추가 (NULL 항목)

	SELECT *
	INTO vnt_test(1)
	FROM EMPLOYEES
	WHERE EMPLOYEE_ID = 100;

	dbms_output.put_line(vnt_test(1).employee_id);
	dbms_output.put_line(vnt_test(1).EMP_NAME);
END;

 -- 레코드 타입을 요소로 가진 중첩 테이블 2
DECLARE 
	TYPE nt_type IS TABLE OF EMPLOYEES%rowtype;

	vnt_test nt_type;
BEGIN 
	vnt_test := nt_type();
	
	FOR rec IN (SELECT * FROM EMPLOYEEs)
	LOOP 
		vnt_test.extend;
		vnt_test(vnt_test.last) := rec;
	END LOOP;
	
	FOR i IN vnt_test.FIRST..vnt_test.LAST
	loop
		dbms_output.put_line(vnt_test(i).employee_id || ' - ' || vnt_test(i).EMP_NAME);
	END LOOP;
END;

 -- 한 대륙에 여러 국가가 있는 사용자 정의 타입을 생성함
CREATE OR REPLACE TYPE country_var IS varray(7) OF varchar2(30);

CREATE TABLE ch11_continent(
	continent varchar2(50),
	country_nm country_var
);

DECLARE  
	
BEGIN 
	INSERT INTO ch11_continent
	VALUES ('아시아', country_var('한국', '중국', '일본'));

	INSERT INTO ch11_continent
	VALUES ('북아메리카', country_var('미국', '캐나다', '멕시코'));

	INSERT INTO ch11_continent
	VALUES ('유럽', country_var('영국', '프랑스', '독일', '스위스'));

	COMMIT;
END;

 -- country_var 타입 변수를 생성해 유럽의 다른 국가를 집어 넣은 뒤, 위에서 입력한 국가를 통째로 변경
DECLARE 
	new_country country_var := country_var('이탈리아', '스페인', '네덜란드', '체코', '포르투갈');

	country_list country_var;
BEGIN 
	UPDATE ch11_continent
	SET country_nm = new_country
	WHERE continent = '유럽';

	COMMIT;

	SELECT country_nm
	INTO country_list
	FROM ch11_continent
	WHERE continent = '유럽';

	FOR i IN country_list.FIRST..country_list.LAST
	LOOP
		dbms_output.put_line('유럽국가명 = ' || country_list(i));
	END LOOP;
END;

SELECT * FROM ch11_continent ;

 -- 테이블 컬럼 타입으로 중첩 테이블 사용하기
CREATE OR REPLACE TYPE country_nt IS TABLE OF varchar2(30);

CREATE TABLE ch11_continent_nt(
	continent varchar2(50),
	country_nm country_nt
)
nested TABLE country_nm store AS country_nm_nt;

DECLARE 
	new_country country_nt := country_nt('이탈리아', '스페인', '네덜란드', '체코', '포르투갈');
	country_list country_nt;
BEGIN 
	INSERT INTO ch11_continent_nt
	VALUES ('아시아', country_nt('한국', '중국', '일본'));

	INSERT INTO ch11_continent_nt
	VALUES ('북아메리카', country_nt('미국', '캐나다', '멕시코'));

	INSERT INTO ch11_continent_nt
	VALUES ('유럽', country_nt('영국', '프랑스', '독일', '스위스'));

	UPDATE ch11_continent_nt
	SET country_nm = new_country
	WHERE continent = '유럽';

	COMMIT;

	SELECT country_nm
	INTO country_list
	FROM ch11_continent_nt
	WHERE continent = '유럽';

	FOR i IN country_list.FIRST..country_list.LAST
	LOOP
		dbms_output.put_line('유럽국가명 = ' || country_list(i));
	END LOOP;
END;

SELECT * FROM ch11_continent_nt ;


 -- 230503
SELECT * FROM ch11_continent ;

 -- 컬렉션에 들어있는 값 추출하기
SELECT CONTINENT , b.*
FROM ch11_continent a, table(a.COUNTRY_NM) b
WHERE CONTINENT = '유럽'
;

SELECT *
FROM table(
	SELECT d.country_nm
	FROM ch11_continent_nt d
	WHERE d.CONTINENT = '유럽'
)
;

 -- 중첩 테이블로 기존 컬럼에 새로운 요소값 추가
DECLARE 
	country_list country_nt;
BEGIN 
	SELECT country_nm
	INTO country_list
	FROM ch11_continent_nt
	WHERE continent = '유럽';

	FOR i IN country_list.FIRST..country_list.LAST
	LOOP
		dbms_output.put_line('유럽국가명(OLD) = ' || country_list(i));
	END LOOP;
	
	INSERT INTO table(
		SELECT d.country_nm
		FROM ch11_continent_nt d
		WHERE d.CONTINENT = '유럽')
	VALUES ('벨기에');

	COMMIT;

	dbms_output.put_line('-----------------------------');

	SELECT country_nm
	INTO country_list
	FROM ch11_continent_nt
	WHERE continent = '유럽'; 
	
	FOR i IN country_list.FIRST..country_list.LAST
	LOOP
		dbms_output.put_line('유럽국가명(NEW) = ' || country_list(i));
	END LOOP;
END;

 -- 중첩 테이블로 기존 요소 값 변경
DECLARE 
	country_list country_nt;
BEGIN 
	UPDATE TABLE(
		SELECT d.country_nm
		FROM ch11_continent_nt d
		WHERE d.CONTINENT = '유럽') t
	SET value(t) = '영국'
	WHERE t.column_value = '이탈리아';
	
	COMMIT;
	
	SELECT country_nm
	INTO country_list
	FROM ch11_continent_nt
	WHERE continent = '유럽';

	FOR i IN country_list.FIRST..country_list.LAST
	LOOP
		dbms_output.put_line('유럽국가명(NEW) = ' || country_list(i));
	END LOOP;
END;

 -- 중첩 테이블로 DELETE 작업
DECLARE 
	country_list country_nt;
BEGIN 
	DELETE FROM table(
		SELECT d.country_nm
		FROM ch11_continent_nt d
		WHERE d.CONTINENT = '유럽') t
	WHERE t.column_value = '영국';

	COMMIT;
	
	SELECT country_nm
	INTO country_list
	FROM ch11_continent_nt
	WHERE continent = '유럽';

	FOR i IN country_list.FIRST..country_list.LAST
	LOOP
		dbms_output.put_line('유럽국가명(NEW) = ' || country_list(i));
	END LOOP;
END;

 -- Self-Check 1
 -- 부서별 계층형 쿼리
SELECT DEPARTMENT_ID , LPAD(' ', 3 * (LEVEL - 1)) || DEPARTMENT_NAME , LEVEL
FROM DEPARTMENTS
START WITH parent_id IS NULL 
CONNECT BY PRIOR DEPARTMENT_ID = PARENT_ID 
;

 -- WITH문을 이용한 부서별 계층형 쿼리
WITH DEPARTMENTS_hierarchy (DEPARTMENT_ID, DEPARTMENT_NAME, lv) AS (
	SELECT 
		  DEPARTMENT_ID 
		, DEPARTMENT_NAME 
		, 1 AS lv
	FROM DEPARTMENTS
	WHERE PARENT_ID IS NULL
	UNION ALL 
	SELECT 
		  b.DEPARTMENT_ID 
		, LPAD(' ', 3 * ((a.lv + 1) - 1)) || b.DEPARTMENT_NAME 
		, a.lv + 1 AS lv
	FROM DEPARTMENTS_hierarchy a
	LEFT OUTER JOIN DEPARTMENTS b
		ON a.DEPARTMENT_ID = b.PARENT_ID 
	WHERE b.DEPARTMENT_ID IS NOT NULL
)
SEARCH DEPTH FIRST BY DEPARTMENT_ID SET sort_order
SELECT 
	t1.DEPARTMENT_ID
	, t1.DEPARTMENT_NAME
	, t1.lv
FROM DEPARTMENTS_hierarchy t1
;

 -- 커서와 반복문을 사용한 계층형 쿼리 
 -- (*'Result Set 변수 또는 질의의 리턴 유형이 일치하지 않습니다' 에러 발생)
 -- (*WITH문 리턴값이 변수 값이랑 안 맞는 이유를 모르겠다.)
DECLARE 
--	TYPE dep_curtype IS REF CURSOR;
--	dep_curvar dep_curtype;
	dep_curvar sys_refcursor;

	vs_department_id DEPARTMENTS.DEPARTMENT_ID%TYPE;
	vs_department_name DEPARTMENTS.DEPARTMENT_NAME%TYPE;
	vs_lv char(1);

	PROCEDURE my_dep_hier_proc(p_curvar IN OUT dep_curtype)
	IS 
		c_temp_cursor dep_curtype;
	BEGIN 
		OPEN c_temp_cursor FOR 
		-------------------- 참조 테이블 시작 ----------------
--		SELECT DEPARTMENT_ID 
--		FROM DEPARTMENTS d ;
		WITH DEPARTMENTS_hierarchy (DEPARTMENT_ID, DEPARTMENT_NAME, lv) AS (
			SELECT 
				  DEPARTMENT_ID 
				, DEPARTMENT_NAME 
				, 1 AS lv
			FROM DEPARTMENTS
			WHERE PARENT_ID IS NULL
			UNION ALL 
			SELECT 
				  b.DEPARTMENT_ID 
				, LPAD(' ', 3 * ((a.lv + 1) - 1)) || b.DEPARTMENT_NAME 
				, a.lv + 1 AS lv
			FROM DEPARTMENTS_hierarchy a
			LEFT OUTER JOIN DEPARTMENTS b
				ON a.DEPARTMENT_ID = b.PARENT_ID 
			WHERE b.DEPARTMENT_ID IS NOT NULL
		)
		SEARCH DEPTH FIRST BY DEPARTMENT_ID SET sort_order
		SELECT 
			CAST(t1.DEPARTMENT_ID AS NUMBER(6, 0)) AS DEPARTMENT_ID
			, t1.DEPARTMENT_NAME
			, t1.lv
		FROM DEPARTMENTS_hierarchy t1;
		-------------------- 참조 테이블 끝 ----------------
		
		p_curvar := c_temp_cursor;
	END;	
BEGIN 
	my_dep_hier_proc(dep_curvar);

	LOOP
		FETCH dep_curvar INTO vs_department_id;
		EXIT WHEN dep_curvar%notfound;
		dbms_output.put_line('부서번호: '||vs_department_id);
	END LOOP;	
END;

 -- 커서, 반복문으로 억지로 구현..(프로시저를 못씀)
DECLARE 

BEGIN 
	FOR emp_rec IN (
		WITH DEPARTMENTS_hierarchy (DEPARTMENT_ID, DEPARTMENT_NAME, lv) AS (
			SELECT 
				  DEPARTMENT_ID 
				, DEPARTMENT_NAME 
				, 1 AS lv
			FROM DEPARTMENTS
			WHERE PARENT_ID IS NULL
			UNION ALL 
			SELECT 
				  b.DEPARTMENT_ID 
				, LPAD(' ', 3 * ((a.lv + 1) - 1)) || b.DEPARTMENT_NAME 
				, a.lv + 1 AS lv
			FROM DEPARTMENTS_hierarchy a
			LEFT OUTER JOIN DEPARTMENTS b
				ON a.DEPARTMENT_ID = b.PARENT_ID 
			WHERE b.DEPARTMENT_ID IS NOT NULL
		)
		SEARCH DEPTH FIRST BY DEPARTMENT_ID SET sort_order
		SELECT 
			CAST(t1.DEPARTMENT_ID AS NUMBER(6, 0)) AS DEPARTMENT_ID
			, t1.DEPARTMENT_NAME
			, t1.lv
		FROM DEPARTMENTS_hierarchy t1
	)
	LOOP
		dbms_output.put_line('부서번호: '||emp_rec.DEPARTMENT_ID||' 부서명: '||emp_rec.DEPARTMENT_NAME||' LV: '||emp_rec.lv);
	END LOOP;
END;


 -- 230504
 -- Self-Check 2
 -- to_be
DECLARE 
	TYPE nt_type IS TABLE OF EMPLOYEES%rowtype;

	vnt_test nt_type;
BEGIN 
	vnt_test := nt_type();
	vnt_test.extend;	-- 요소 1개 추가 (NULL 항목)

	SELECT *
	INTO vnt_test(1)
	FROM EMPLOYEES
	WHERE EMPLOYEE_ID = 100;

	dbms_output.put_line(vnt_test(1).employee_id);
	dbms_output.put_line(vnt_test(1).EMP_NAME);
END;

 -- as_is
DECLARE 
	TYPE nt_type IS TABLE OF varchar2(20)
					INDEX BY varchar2(20);

	vnt_test nt_type;
BEGIN 
	vnt_test('다원') := 'test';
	
	dbms_output.put_line(vnt_test('다원'));
END;


 -- 230505
 -- Self-Check 3
CREATE OR REPLACE TYPE nt_ch11_emp IS TABLE OF varchar2(20);	-- 중첩 테이블

DECLARE 
	vr_emp EMPLOYEES%rowtype;	-- 테이블형 레코드 변수

	vnt_test nt_ch11_emp;
BEGIN 	
	vnt_test := nt_ch11_emp('Harrison Ford');

	SELECT * 
	INTO vr_emp
	FROM EMPLOYEES 
	WHERE EMP_NAME = vnt_test(1);

	dbms_output.put_line(vr_emp.email);
END;

 -- Self-Check 4 (*중첩테이블에 조인문 넣을 방법이 없음)
CREATE OR REPLACE PROCEDURE table_dept_proc(
	p_department_id IN DEPARTMENTS.DEPARTMENT_ID%type
)
IS 
	TYPE nt_type IS TABLE OF EMPLOYEES%rowtype;

	vnt_test nt_type;
BEGIN 
	vnt_test := nt_type();
	
	FOR rec IN (
		SELECT 
			a.EMPLOYEE_ID, a.EMP_NAME, b.DEPARTMENT_NAME 
		FROM 
			EMPLOYEES a
		INNER JOIN 
			DEPARTMENTS b
			ON a.DEPARTMENT_ID = b.DEPARTMENT_ID 
		WHERE 
			a.DEPARTMENT_ID = p_department_id
	)
	LOOP
		vnt_test.extend;
		vnt_test(vnt_test.last) := rec;
	END LOOP;
	
	FOR i IN vnt_test.FIRST..vnt_test.LAST
	LOOP
		dbms_output.put_line(vnt_test(i).EMPLOYEE_ID);
	END LOOP;
END;

BEGIN 
	
END;

DECLARE 
	TYPE nt_type IS TABLE OF EMPLOYEES%rowtype;

	vnt_test nt_type;

--	v_department_name DEPARTMENTS.DEPARTMENT_NAME%TYPE := 'test';
	v_department_name varchar2(20);
BEGIN 
	vnt_test := nt_type();
	
	FOR rec IN (
--		SELECT 
----			CAST(a.EMPLOYEE_ID AS varchar2(6)) AS EMPLOYEE_ID
----			, a.EMP_NAME, b.DEPARTMENT_NAME 
--			a.EMPLOYEE_ID
--			, a.EMP_NAME
--			, (
--				SELECT DEPARTMENT_NAME
--				FROM DEPARTMENTS 
--				WHERE DEPARTMENT_ID = a.DEPARTMENT_ID 
--			) AS DEPARTMENT_NAME
--		FROM 
--			EMPLOYEES a
--		WHERE 
--			a.DEPARTMENT_ID = 50
		SELECT * FROM EMPLOYEES 
	)
	LOOP
		vnt_test.extend;
		vnt_test(vnt_test.last) := rec;
	END LOOP;
	
	FOR i IN vnt_test.FIRST..vnt_test.LAST
	LOOP
		dbms_output.put_line(vnt_test(i).DEPARTMENT_ID);
	
		SELECT DEPARTMENT_NAME
		INTO v_department_name
		FROM DEPARTMENTS 
		WHERE DEPARTMENT_ID = vnt_test(i).DEPARTMENT_ID 
		
		dbms_output.put_line(v_department_name);
	END LOOP;
END;

SELECT 
--			CAST(a.EMPLOYEE_ID AS varchar2(6)) AS EMPLOYEE_ID
--			, a.EMP_NAME, b.DEPARTMENT_NAME 
			*
		FROM 
			EMPLOYEES a
		INNER JOIN 
			DEPARTMENTS b
			ON a.DEPARTMENT_ID = b.DEPARTMENT_ID 
		WHERE 
			a.DEPARTMENT_ID = 50;
			
SELECT DEPARTMENT_NAME
FROM DEPARTMENTS 
WHERE DEPARTMENT_ID = 50
;

 -- 패키지 선언부
CREATE OR REPLACE PACKAGE hr_pkg IS 

	FUNCTION fn_get_emp_name(pn_employee_id IN number)
	RETURN varchar2;
	
	PROCEDURE new_emp_proc(ps_emp_name IN varchar2, pd_hire_date IN varchar2);
	
	PROCEDURE retire_emp_proc(pn_employee_id IN number);
	
	 -- 사번을 입력받아 부서명을 반환하는 함수
	FUNCTION fn_get_dep_name(pn_employee_id IN number)
		RETURN varchar2;

END hr_pkg;

 -- 패키지 본문
CREATE OR REPLACE PACKAGE BODY hr_pkg IS 

	FUNCTION fn_get_emp_name(pn_employee_id IN number)
		RETURN varchar2
	IS 
		vs_emp_name employees.EMP_NAME%TYPE;
	BEGIN 
		SELECT EMP_NAME 
		INTO vs_emp_name
		FROM EMPLOYEES 
		WHERE EMPLOYEE_ID = pn_employee_id;
	
		RETURN nvl(vs_emp_name, '해당사원없음');
	END fn_get_emp_name;
	
	PROCEDURE new_emp_proc(ps_emp_name IN varchar2, pd_hire_date IN varchar2)
	IS 
		vn_emp_id employees.employee_id%TYPE;
		vd_hire_date DATE := to_date(pd_hire_date, 'YYYY-MM-DD');
	BEGIN 
		SELECT NVL(MAX(EMPLOYEE_ID), 0) + 1
		INTO vn_emp_id
		FROM EMPLOYEES;
	
		INSERT INTO EMPLOYEES (EMPLOYEE_ID, EMP_NAME, HIRE_DATE, CREATE_DATE, UPDATE_DATE) 
		VALUES (vn_emp_id, ps_emp_name, nvl(vd_hire_date, sysdate), sysdate, sysdate);
	
		COMMIT;
	
	EXCEPTION WHEN OTHERS THEN 
		dbms_output.put_line('에러: ' || sqlerrm);
		ROLLBACK;
	END new_emp_proc;
	
	PROCEDURE retire_emp_proc(pn_employee_id IN number)
	IS 
		vn_cnt NUMBER := 0;
		e_no_data	EXCEPTION;
	BEGIN 
		UPDATE EMPLOYEES 
		SET RETIRE_DATE = SYSDATE 
		WHERE EMPLOYEE_ID = pn_employee_id
		AND RETIRE_DATE IS NULL;
	
		vn_cnt := SQL%rowcount;
		dbms_output.put_line('vn_cnt: '||vn_cnt);
	
		IF vn_cnt = 0 THEN 
			raise e_no_data;
		END IF;
	
		COMMIT;
	
	EXCEPTION WHEN e_no_data THEN 
		dbms_output.put_line(pn_employee_id||'에 해당되는 퇴사처리할 사원이 없습니다!');
		ROLLBACK;
	WHEN OTHERS THEN 
		dbms_output.put_line('에러: ' || sqlerrm);
		ROLLBACK;
	END retire_emp_proc;

	 -- 사번을 입력받아 부서명을 반환하는 함수
	FUNCTION fn_get_dep_name(pn_employee_id IN number)
		RETURN varchar2
	IS 
		vs_dep_name departments.DEPARTMENT_NAME%TYPE;
	BEGIN 
		SELECT b.DEPARTMENT_NAME 
		INTO vs_dep_name
		FROM EMPLOYEES a, DEPARTMENTS b
		WHERE a.EMPLOYEE_ID = pn_employee_id
		AND a.DEPARTMENT_ID = b.DEPARTMENT_ID ;
	
		RETURN vs_dep_name;
	END fn_get_dep_name;

END hr_pkg;

SELECT hr_pkg.FN_GET_EMP_NAME(171) 
FROM dual ;

BEGIN 
	hr_pkg.new_emp_proc('Julia Roberts', '20140110');
END;

BEGIN 
	hr_pkg.retire_emp_proc(299);
END;

SELECT * FROM EMPLOYEES ;

CREATE OR REPLACE PROCEDURE ch12_dep_proc(pn_employee_id IN number)
IS 
	vs_dep_name departments.DEPARTMENT_NAME%TYPE;
BEGIN 
	vs_dep_name := hr_pkg.fn_get_dep_name(pn_employee_id);

	dbms_output.put_line(nvl(vs_dep_name, '부서명 없음'));
END;

BEGIN 
	CH12_DEP_PROC(208);
END;


 -- 230507
 -- 상수와 변수 선언
CREATE OR REPLACE PACKAGE ch12_var IS
	c_test constant varchar2(10) := 'TEST';

	v_test varchar2(10);

	FUNCTION fn_get_value RETURN varchar2;

	PROCEDURE sp_set_value (ps_value varchar2);
END ch12_var;

BEGIN 
	dbms_output.put_line(ch12_var.c_test);
	ch12_var.v_test := 'FIRST';
	dbms_output.put_line(ch12_var.v_test);
END;

BEGIN 
	dbms_output.put_line(ch12_var.v_test);
END;

 -- 본문에 상수와 변수 선언
CREATE OR REPLACE PACKAGE BODY ch12_var IS
	c_test_body constant varchar2(10) := 'CONSTANT_BODY';

	v_test_body varchar2(10);

	FUNCTION fn_get_value RETURN varchar2
	IS 
	
	BEGIN 
		RETURN nvl(v_test_body, 'NULL 이다');
	END fn_get_value;

	PROCEDURE sp_set_value (ps_value varchar2)
	IS 
	
	BEGIN 
		v_test_body := ps_value;
	END sp_set_value;
END ch12_var;

BEGIN 
	dbms_output.put_line(ch12_var.c_test_body);
	dbms_output.put_line(ch12_var.v_test_body);
END;

DECLARE 
	vs_value varchar2(10);
BEGIN 
	ch12_var.sp_set_value('EXTERNAL');

	vs_value := ch12_var.fn_get_value;
	dbms_output.put_line(vs_value);
END;

 -- 패키지 선언부에 커서 전체를 선언하는 형태
CREATE OR REPLACE PACKAGE ch12_cur_pkg IS 
	CURSOR pc_empdep_cur (dep_id IN departments.DEPARTMENT_ID%type)
	IS 
		SELECT a.EMPLOYEE_ID , a.EMP_NAME , b.DEPARTMENT_NAME 
		FROM EMPLOYEES a, DEPARTMENTS b
		WHERE a.DEPARTMENT_ID = dep_id
		AND a.DEPARTMENT_ID = b.DEPARTMENT_ID ;
	
	 -- ROWTYPE형 커서 헤더 선언
	CURSOR pc_depname_cur(dep_id IN departments.DEPARTMENT_ID%type)
		RETURN departments%rowtype;
	
	 -- 사용자 정의 레코드 타입
	TYPE emp_dep_rt IS RECORD (
		emp_id employees.employee_id%TYPE,
		emp_name employees.emp_name%TYPE,
		job_title jobs.job_title%type
	);

	 -- 사용자 정의 레코드를 반환하는 커서
	CURSOR pc_empdep2_cur (p_job_id IN jobs.job_id%type)
		RETURN emp_dep_rt;
END ch12_cur_pkg;

BEGIN 
	FOR rec IN ch12_cur_pkg.pc_empdep_cur(30)
	LOOP
		dbms_output.put_line(rec.EMP_NAME || ' - ' || rec.DEPARTMENT_NAME);
	END LOOP;
END;

 -- 패키지 본문
CREATE OR REPLACE PACKAGE BODY ch12_cur_pkg IS 
	-- ROWTYPE형 커서 본문
	CURSOR pc_depname_cur(dep_id IN departments.DEPARTMENT_ID%type)
		RETURN departments%rowtype
	IS 
		SELECT *
		FROM DEPARTMENTS 
		WHERE DEPARTMENT_ID = dep_id;
	
	 -- 사용자 정의 레코드를 반환하는 커서
	CURSOR pc_empdep2_cur (p_job_id IN jobs.job_id%type)
		RETURN emp_dep_rt
	IS 
		SELECT a.EMPLOYEE_ID , a.EMP_NAME , b.JOB_TITLE 
		FROM EMPLOYEES a,
			 jobs b
		WHERE a.JOB_ID = p_job_id
		AND a.JOB_ID = b.JOB_ID;
END ch12_cur_pkg;

BEGIN 
	FOR rec IN ch12_cur_pkg.pc_depname_cur(30)
	LOOP
		dbms_output.put_line(rec.department_id || ' - ' || rec.department_name);
	END LOOP;
END;

BEGIN 
	FOR rec IN ch12_cur_pkg.pc_empdep2_cur('FI_ACCOUNT')
	LOOP
		dbms_output.put_line(rec.emp_id || ' - ' || rec.emp_name || ' - ' || rec.job_title);
	END LOOP;
END;

DECLARE 
	dep_cur ch12_cur_pkg.pc_depname_cur%rowtype;
BEGIN 
	OPEN ch12_cur_pkg.pc_depname_cur(30);

	LOOP
		FETCH ch12_cur_pkg.pc_depname_cur INTO dep_cur;
		EXIT WHEN ch12_cur_pkg.pc_depname_cur%notfound;
		dbms_output.put_line(dep_cur.DEPARTMENT_ID || ' - ' || dep_cur.department_name);
	END LOOP;
	
	CLOSE ch12_cur_pkg.pc_depname_cur;
END;


 -- 230508
 -- 패키지에 컬렉션 선언
CREATE OR REPLACE PACKAGE ch12_col_pkg IS
	pragma serially_reusable;
	-- 중첩 테이블 선언
	TYPE nt_dep_name IS TABLE OF varchar2(30);

	pv_nt_dep_name nt_dep_name := nt_dep_name();

	PROCEDURE make_dep_proc(p_par_id IN number);
END ch12_col_pkg;

CREATE OR REPLACE PACKAGE BODY ch12_col_pkg IS 
	pragma serially_reusable;
	PROCEDURE make_dep_proc(p_par_id IN number)
	IS 
	BEGIN 
		FOR rec IN (	-- 커서
			SELECT DEPARTMENT_NAME 
			FROM DEPARTMENTS
			WHERE PARENT_ID = p_par_id
		)
		LOOP
			pv_nt_dep_name.extend();
			dbms_output.put_line('pv_nt_dep_name.count: '||pv_nt_dep_name.count);
			pv_nt_dep_name(pv_nt_dep_name.count) := rec.DEPARTMENT_NAME;
		END LOOP;
	END make_dep_proc;
END ch12_col_pkg;

BEGIN 
	ch12_col_pkg.make_dep_proc(100);

	FOR i IN 1..ch12_col_pkg.pv_nt_dep_name.count
	LOOP
		dbms_output.put_line(ch12_col_pkg.pv_nt_dep_name(i));
	END LOOP;
END;

BEGIN 
	FOR i IN 1..ch12_col_pkg.pv_nt_dep_name.count
	LOOP
		dbms_output.put_line(ch12_col_pkg.pv_nt_dep_name(i));
	END LOOP;
END;

 -- 오버로딩 패키지
CREATE OR REPLACE PACKAGE ch12_overload_pkg IS 
	PROCEDURE get_dep_nm_proc(p_emp_id IN NUMBER);

	PROCEDURE get_dep_nm_proc(p_emp_name IN varchar2);
END ch12_overload_pkg;

CREATE OR REPLACE PACKAGE BODY ch12_overload_pkg IS 
	PROCEDURE get_dep_nm_proc(p_emp_id IN NUMBER)
	IS 
		vs_dep_nm departments.DEPARTMENT_NAME%TYPE;
	BEGIN 
		SELECT b.DEPARTMENT_NAME 
		INTO vs_dep_nm
		FROM EMPLOYEES a, DEPARTMENTS b
		WHERE a.EMPLOYEE_ID = p_emp_id
		AND a.DEPARTMENT_ID = b.DEPARTMENT_ID ;
	
		dbms_output.put_line('emp_id: '|| p_emp_id || ' - ' || vs_dep_nm);
	END get_dep_nm_proc;

	PROCEDURE get_dep_nm_proc(p_emp_name IN varchar2)
	IS 
		vs_dep_nm departments.DEPARTMENT_NAME%TYPE;
	BEGIN 
		SELECT b.DEPARTMENT_NAME 
		INTO vs_dep_nm
		FROM EMPLOYEES a, DEPARTMENTS b
		WHERE a.EMP_NAME = p_emp_name
		AND a.DEPARTMENT_ID = b.DEPARTMENT_ID ;
	
		dbms_output.put_line('emp_id: '|| p_emp_name || ' - ' || vs_dep_nm);
	END get_dep_nm_proc;
END ch12_overload_pkg;

BEGIN 
	ch12_overload_pkg.get_dep_nm_proc(176);

	ch12_overload_pkg.get_dep_nm_proc('Jonathon Taylor');
END;

 -- 패키지 리스트 조회
SELECT OWNER , OBJECT_NAME , OBJECT_TYPE , STATUS
FROM ALL_OBJECTS 
WHERE OBJECT_TYPE = 'PACKAGE'
AND ( OBJECT_NAME LIKE 'DBMS%' OR OBJECT_NAME LIKE 'UTL%' )
ORDER BY OBJECT_NAME 
;

 -- 생성 스크립트 추출
SELECT dbms_metadata.get_ddl('TABLE', 'EMPLOYEES', 'ORA_USER')
FROM dual ;

SELECT dbms_metadata.get_ddl('PACKAGE', 'CH12_OVERLOAD_PKG', 'ORA_USER')
FROM dual ;

 -- 권한 부여
--grant select_catalog_role to ora_user;

 -- Self-Check 1
 -- 패키지 선언부
CREATE OR REPLACE PACKAGE hr_pkg2 IS 

	 -- 부서이름 반환
	FUNCTION fn_get_dep_name(pn_department_id IN number)
	RETURN varchar2;
	
	 -- 신규부서 입력
	PROCEDURE new_dep_proc(
		ps_dep_name IN varchar2, pn_parent_id IN NUMBER, pn_mng_id IN NUMBER
	);
	
	 -- 부서 삭제
	PROCEDURE del_dep_proc(pn_department_id IN number);

END hr_pkg2;

SELECT * FROM DEPARTMENTS ;

 -- 패키지 본문
CREATE OR REPLACE PACKAGE BODY hr_pkg2 IS 

	 -- 부서이름 반환
	FUNCTION fn_get_dep_name(pn_department_id IN number)
		RETURN varchar2
	IS 
		vs_department_name DEPARTMENTS.DEPARTMENT_NAME%TYPE;
	BEGIN 
		SELECT DEPARTMENT_NAME  
		INTO vs_department_name
		FROM DEPARTMENTS 
		WHERE DEPARTMENT_ID = pn_department_id;
	
		RETURN nvl(vs_department_name, '해당부서없음');
	END fn_get_dep_name;
	
	 -- 신규부서 입력
	PROCEDURE new_dep_proc(
		ps_dep_name IN varchar2, pn_parent_id IN NUMBER, pn_mng_id IN NUMBER
	)
	IS 
		vn_department_id DEPARTMENTS.department_id%TYPE;
	BEGIN 
		SELECT NVL(MAX(DEPARTMENT_ID), 0) + 1
		INTO vn_department_id
		FROM DEPARTMENTS;
	
		INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, PARENT_ID, MANAGER_ID, CREATE_DATE, UPDATE_DATE) 
		VALUES (vn_department_id, ps_dep_name, pn_parent_id, pn_mng_id, sysdate, sysdate);
	
		COMMIT;
	
	EXCEPTION WHEN OTHERS THEN 
		dbms_output.put_line('에러: ' || sqlerrm);
		ROLLBACK;
	END new_dep_proc;
	
	 -- 부서 삭제
	PROCEDURE del_dep_proc(pn_department_id IN number)
	IS 
		vn_employee_cnt NUMBER := 0;
		vn_cnt NUMBER := 0;
		e_exist_employee	EXCEPTION;
		e_no_data			EXCEPTION;
	BEGIN 
		SELECT COUNT(*) 
		INTO vn_employee_cnt
		FROM EMPLOYEES 
		WHERE DEPARTMENT_ID = pn_department_id;
		
		IF vn_employee_cnt > 0 THEN 
			raise e_exist_employee;
		END IF;
	
		DELETE FROM DEPARTMENTS WHERE DEPARTMENT_ID = pn_department_id;
	
		vn_cnt := SQL%rowcount;
		dbms_output.put_line('vn_cnt: '||vn_cnt);
	
		IF vn_cnt = 0 THEN 
			raise e_no_data;
		END IF;
	
		COMMIT;
	
	EXCEPTION 
	WHEN e_exist_employee THEN
		dbms_output.put_line(pn_department_id||' 부서에 해당되는 사원이 존재합니다!');
		ROLLBACK;
	WHEN e_no_data THEN 
		dbms_output.put_line(pn_department_id||'에 해당되는 부서가 없습니다!');
		ROLLBACK;
	WHEN OTHERS THEN 
		dbms_output.put_line('에러: ' || sqlerrm);
		ROLLBACK;
	END del_dep_proc;

END hr_pkg2;

SELECT hr_pkg2.fn_get_dep_name(444) FROM dual ;

BEGIN 
	hr_pkg2.new_dep_proc('테스트부서', 50, '273');
END;

SELECT * FROM DEPARTMENTS ;

BEGIN 
	hr_pkg2.del_dep_proc(273);
END;


 -- 230511
 -- Self-Check 2
CREATE OR REPLACE PACKAGE ch12_seq_pkg IS 

	FUNCTION get_nextval RETURN NUMBER;

END ch12_seq_pkg;

CREATE OR REPLACE PACKAGE BODY ch12_seq_pkg IS 

	n_seq NUMBER := 0;

	FUNCTION get_nextval RETURN NUMBER
	IS 
	
	BEGIN 
		n_seq := n_seq + 1;
	
		RETURN n_seq;
	END get_nextval;

END ch12_seq_pkg;

BEGIN 
	dbms_output.put_line('새로운 번호: ' || ch12_seq_pkg.get_nextval);
END;

 -- Self-Check 3
CREATE OR REPLACE PACKAGE ch12_exacur_pkg IS 

	 -- ROWTYPE형 커서 헤더 선언
	CURSOR pc_depname_cur( dep_id IN departments.DEPARTMENT_ID%type )
		RETURN departments%rowtype;

	PROCEDURE dep_inqr_proc(dep_id IN departments.DEPARTMENT_ID%type);
	
END ch12_exacur_pkg;

CREATE OR REPLACE PACKAGE BODY ch12_exacur_pkg IS 

	CURSOR pc_depname_cur( dep_id IN departments.DEPARTMENT_ID%type )
		RETURN departments%rowtype
	IS 
		SELECT *
		FROM DEPARTMENTS
		WHERE DEPARTMENT_ID = dep_id;

	PROCEDURE dep_inqr_proc(dep_id IN departments.DEPARTMENT_ID%type)
	IS 
		dep_cur pc_depname_cur%rowtype;
	BEGIN 
		-- 열려있으면 닫는 작업 수행
		IF pc_depname_cur%isopen THEN 
			CLOSE pc_depname_cur;
		END IF;
	
		OPEN pc_depname_cur(dep_id);
--		dbms_output.put_line('isopen: ' || pc_depname_cur%ISOPEN);	-- *찍는건 안됨. 오류발생
	
		LOOP
			FETCH pc_depname_cur INTO dep_cur;
		EXIT WHEN pc_depname_cur%notfound;
		dbms_output.put_line(dep_cur.DEPARTMENT_ID || ' - ' || dep_cur.DEPARTMENT_NAME);
		END LOOP;
		
--		CLOSE pc_depname_cur;
	END dep_inqr_proc;
	
END ch12_exacur_pkg;

BEGIN 
	ch12_exacur_pkg.dep_inqr_proc(80);
END;

 -- Self-Check 4
CREATE OR REPLACE PACKAGE ch12_dep_pkg IS 

	CURSOR pc_dep_cur( pc_parent_id IN departments.DEPARTMENT_ID%type )
		RETURN departments%rowtype;

	FUNCTION get_dep_hierarchy(dep_id IN departments.DEPARTMENT_ID%type) 
	RETURN varchar2;

	FUNCTION get_dep_hierarchy(p_dep_id IN departments.DEPARTMENT_ID%TYPE, p_parent_id IN departments.parent_id%type)
	RETURN varchar2;

END ch12_dep_pkg;

CREATE OR REPLACE PACKAGE BODY ch12_dep_pkg IS 

	CURSOR pc_dep_cur( pc_parent_id IN departments.DEPARTMENT_ID%type )
		RETURN departments%rowtype
	IS 
		SELECT *
		FROM DEPARTMENTS 
		WHERE PARENT_ID = pc_parent_id;

	FUNCTION get_dep_hierarchy(dep_id IN departments.DEPARTMENT_ID%type) 
		RETURN varchar2
	IS 
--		vs_dep departments%rowtype;	-- *레코드는 리턴이 안되는걸로 보임
		vs_dep_nm departments.department_name%TYPE;
	BEGIN 
		SELECT DEPARTMENT_NAME 
		INTO vs_dep_nm
		FROM DEPARTMENTS 
		WHERE DEPARTMENT_ID = dep_id;

		RETURN vs_dep_nm;
	END get_dep_hierarchy;

	FUNCTION get_dep_hierarchy(p_dep_id IN departments.DEPARTMENT_ID%TYPE, p_parent_id IN departments.parent_id%type)
		RETURN varchar2
	IS 
		vs_dep_nm departments.department_name%TYPE;
		dep_cur pc_dep_cur%rowtype;
	BEGIN 
		SELECT DEPARTMENT_NAME 
		INTO vs_dep_nm
		FROM DEPARTMENTS 
		WHERE DEPARTMENT_ID = p_dep_id;

		-- 열려있으면 닫는 작업 수행
		IF pc_dep_cur%isopen THEN 
			CLOSE pc_dep_cur;
		END IF;
	
		OPEN pc_dep_cur(p_parent_id);
--		dbms_output.put_line('isopen: ' || pc_depname_cur%ISOPEN);	-- *찍는건 안됨. 오류발생
	
		LOOP
			FETCH pc_dep_cur INTO dep_cur;
			EXIT WHEN pc_dep_cur%notfound;
			dbms_output.put_line(dep_cur.DEPARTMENT_ID || ' - ' || dep_cur.DEPARTMENT_NAME);
		END LOOP;
		
		RETURN vs_dep_nm;
	END get_dep_hierarchy;
END ch12_dep_pkg;

BEGIN 
	dbms_output.put_line('부서번호: ' || 30 || ', ' || '부서명: ' ||ch12_dep_pkg.get_dep_hierarchy(30));
END;

BEGIN 
	dbms_output.put_line('부서번호: ' || 40 || ', ' || '부서명: ' ||ch12_dep_pkg.get_dep_hierarchy(40, 40));
END;


 -- 230512
 -- Self-Check 5
SELECT dbms_metadata.get_ddl('PACKAGE', 'DBMS_OUTPUT', 'SYS') FROM dual ;

SELECT *
FROM ALL_OBJECTS 
WHERE OBJECT_TYPE = 'PACKAGE'
AND OBJECT_NAME LIKE 'DBMS_OUTPUT%'
;

 -- 동적 SQL - NDS
BEGIN 
	EXECUTE IMMEDIATE 'SELECT EMPLOYEE_ID , EMP_NAME , JOB_ID 
					   FROM EMPLOYEES WHERE JOB_ID = ''AD_ASST''';
END;

SELECT EMPLOYEE_ID , EMP_NAME , JOB_ID 
FROM EMPLOYEES 
WHERE JOB_ID = 'AD_ASST'
;

DECLARE
	vn_emp_id 	employees.employee_id%TYPE;
	vn_emp_name employees.emp_name%TYPE;
	vn_job_id 	employees.job_id%TYPE;
BEGIN 
	EXECUTE IMMEDIATE 'SELECT EMPLOYEE_ID , EMP_NAME , JOB_ID 
					   FROM EMPLOYEES WHERE JOB_ID = ''AC_MGR'' '
					   INTO vn_emp_id, vn_emp_name, vn_job_id;
					  
	dbms_output.put_line(vn_emp_id);
	dbms_output.put_line(vn_emp_name);
	dbms_output.put_line(vn_job_id);
END;

 -- 실제 현장 예시
DECLARE
	vn_emp_id 	employees.employee_id%TYPE;
	vn_emp_name employees.emp_name%TYPE;
	vn_job_id 	employees.job_id%TYPE;

	vs_sql varchar2(1000);
BEGIN 
	vs_sql := 'SELECT EMPLOYEE_ID , EMP_NAME , JOB_ID 
			   FROM EMPLOYEES WHERE JOB_ID = ''AC_MGR'' ';
	
	EXECUTE IMMEDIATE vs_sql INTO vn_emp_id, vn_emp_name, vn_job_id;
					  
	dbms_output.put_line(vn_emp_id);
	dbms_output.put_line(vn_emp_name);
	dbms_output.put_line(vn_job_id);
END;
 
 -- 바인드 변수 처리 1
DECLARE
	vn_emp_id 	employees.employee_id%TYPE;
	vn_emp_name employees.emp_name%TYPE;
	vn_job_id 	employees.job_id%TYPE;

	vs_sql varchar2(1000);
BEGIN 
	vs_sql := 'SELECT EMPLOYEE_ID , EMP_NAME , JOB_ID 
			   FROM EMPLOYEES 
			   WHERE JOB_ID = ''SA_REP''
			   and salary < 7000
			   and manager_id = 148 ';
	
	EXECUTE IMMEDIATE vs_sql INTO vn_emp_id, vn_emp_name, vn_job_id;
					  
	dbms_output.put_line(vn_emp_id);
	dbms_output.put_line(vn_emp_name);
	dbms_output.put_line(vn_job_id);
END;

 -- 바인드 변수 처리 2
DECLARE
	vn_emp_id 	employees.employee_id%TYPE;
	vs_emp_name employees.emp_name%TYPE;
	vs_job_id 	employees.job_id%TYPE;

	vs_sql varchar2(1000);

	vs_job employees.job_id%TYPE := 'SA_REP';
	vn_manager employees.manager_id%TYPE := 148;
	vn_sal employees.salary%TYPE := 7000;
	
BEGIN 
	vs_sql := 'SELECT EMPLOYEE_ID , EMP_NAME , JOB_ID 
			   FROM EMPLOYEES 
			   WHERE JOB_ID = :a
			   and salary < :b
			   and manager_id = :c ';
	
	EXECUTE IMMEDIATE vs_sql INTO vn_emp_id, vs_emp_name, vs_job_id
	USING vs_job, vn_sal, vn_manager;
					  
	dbms_output.put_line(vn_emp_id);
	dbms_output.put_line(vs_emp_name);
	dbms_output.put_line(vs_job_id);
END;

CREATE TABLE ch13_physicist (
	ids NUMBER,
	names varchar2(50),
	birth_dt date
);

DECLARE 
	vn_ids ch13_physicist.ids%TYPE := 10;
	vs_name ch13_physicist.names%TYPE := 'Albert Einstein';
	vd_dt ch13_physicist.birth_dt%TYPE := to_date('1879-03-14', 'YYYY-MM-DD');

	vs_sql varchar2(1000);
BEGIN 
	vs_sql := 'INSERT INTO ch13_physicist VALUES (:a, :a, :a)';

	EXECUTE IMMEDIATE vs_sql USING vn_ids, vs_name, vd_dt;
	
	COMMIT;
END;

DECLARE 
	vn_ids ch13_physicist.ids%TYPE := 10;
	vs_name ch13_physicist.names%TYPE := 'Max Planck';
	vd_dt ch13_physicist.birth_dt%TYPE := to_date('1858-04-23', 'YYYY-MM-DD');

	vs_sql varchar2(1000);
	vn_cnt NUMBER := 0;
BEGIN 
	vs_sql := 'update ch13_physicist
			   set names = :a,
				   birth_dt = :a
			   where ids = :a ' ;
			  
	EXECUTE IMMEDIATE vs_sql USING vs_name, vd_dt, vn_ids;

	SELECT NAMES 
	INTO vs_name
	FROM ch13_physicist;

	dbms_output.put_line('UPDATE 후 이름: ' || vs_name);

	vs_sql := 'delete ch13_physicist
			   where ids = :a ';
			  
	EXECUTE IMMEDIATE vs_sql USING vn_ids;

	SELECT COUNT(*) 
	INTO vn_cnt
	FROM ch13_physicist;

	dbms_output.put_line('vn_cnt: ' || vn_cnt);
	COMMIT;
END;

SELECT * FROM ch13_physicist ;


 -- 230514
CREATE OR REPLACE PROCEDURE ch13_bind_proc1(
	pv_arg1 IN varchar2,
	pn_arg2 IN NUMBER,
	pd_arg3 IN DATE 
)
IS 
BEGIN 
	dbms_output.put_line('pv_arg1: ' || pv_arg1);
	dbms_output.put_line('pn_arg2: ' || pn_arg2);
	dbms_output.put_line('pd_arg3: ' || pd_arg3);
END;

DECLARE 
	vs_data1 varchar2(30) := 'Albert Einstein';
	vn_data2 NUMBER := 100;
	vd_date3 DATE := to_date('1879-03-14', 'YYYY-MM-DD');

	vs_sql varchar2(1000);
BEGIN 
	ch13_bind_proc1(vs_data1, vn_data2, vd_date3);

	dbms_output.put_line('----------------------------------');

	vs_sql := 'begin ch13_bind_proc1(:a, :a, :c); end;';

	EXECUTE IMMEDIATE vs_sql USING vs_data1, vn_data2, vd_date3;
END;

 -- 동적 SQL로 프로시저에서 출력, 입출력 변수값 가져오기
CREATE OR REPLACE PROCEDURE ch13_bind_proc2 (
	pv_arg1 IN varchar2,
	pv_arg2 OUT varchar2,
	pv_arg3 IN OUT varchar2
)
IS 
BEGIN 
	dbms_output.put_line('pv_arg1: ' || pv_arg1);

	pv_arg2 := '두 번째 OUT 변수';
	pv_arg3 := '세 번쨰 INOUT 변수';
END;

DECLARE 
	vs_data1 varchar2(30) := 'Albert Einstein';
	vs_data2 varchar2(30);
	vs_data3 varchar2(30);

	vs_sql varchar2(1000);
BEGIN 
	vs_sql := 'begin ch13_bind_proc2(:a, :b, :c); end;';
	EXECUTE IMMEDIATE vs_sql USING vs_data1, OUT vs_data2, IN OUT vs_data3;

	dbms_output.put_line('vs_data1: ' || vs_data1);
	dbms_output.put_line('vs_data2: ' || vs_data2);
	dbms_output.put_line('vs_data3: ' || vs_data3);
END;

 -- 동적 SQL을 사용하여 DDL문 실행
CREATE OR REPLACE PROCEDURE ch13_ddl_proc ( pd_arg1 date )
IS 
	vs_sql varchar2(1000);
BEGIN 
	vs_sql := 'CREATE TABLE ch13_ddl_tab ( col1 varchar2(30) )';
	EXECUTE IMMEDIATE vs_sql;
	
	dbms_output.put_line('pd_arg1: ' || pd_arg1);
END;

BEGIN 
	ch13_ddl_proc(sysdate);
END;

DESC ch13_ddl_tab;	-- *안 먹음

SELECT sysdate FROM dual ;

 -- 세션 파라미터 정보 변경
CREATE OR REPLACE PROCEDURE ch13_ddl_proc ( pd_arg1 IN DATE )
IS 
	vs_sql varchar2(1000);
BEGIN 
	vs_sql := 'alter session set nls_date_format = "YYYY/MM/DD"';
	EXECUTE IMMEDIATE vs_sql;
	dbms_output.put_line('pd_arg1: ' || pd_arg1);
END;

BEGIN 
	ch13_ddl_proc(sysdate);
END;

--TRUNCATE TABLE CH13_PHYSICIST ;

INSERT INTO CH13_PHYSICIST VALUES (1, 'Galileo Galilei', to_date('1564-02-15', 'YYYY-MM-DD'));
INSERT INTO CH13_PHYSICIST VALUES (2, 'Isaac Newton', to_date('1643-01-04', 'YYYY-MM-DD'));
INSERT INTO CH13_PHYSICIST VALUES (3, 'Max Plank', to_date('1858-04-23', 'YYYY-MM-DD'));
INSERT INTO CH13_PHYSICIST VALUES (4, 'Albert Einstein', to_date('1879-03-14', 'YYYY-MM-DD'));
COMMIT;

SELECT * FROM CH13_PHYSICIST ;

 -- OPEN FOR문
DECLARE 
	TYPE query_physicist IS REF CURSOR;
	myPhysicist query_physicist;
	empPhysicist CH13_PHYSICIST%rowtype;

	vs_sql varchar2(1000);
BEGIN 
	vs_sql := 'select * from CH13_PHYSICIST';

	OPEN myPhysicist FOR vs_sql;
	LOOP
		FETCH myPhysicist INTO empPhysicist;
		EXIT WHEN myPhysicist%notfound;
		dbms_output.put_line(empPhysicist.names);
	END LOOP;
	
	CLOSE myPhysicist;
END;


 -- 230515
 -- 바인드 변수를 활용한 OPEN FOR문
DECLARE 
	myPhysicist sys_refcursor;

	empPhysicist CH13_PHYSICIST%rowtype;

	vs_sql varchar2(1000);
	vn_id CH13_PHYSICIST.ids%TYPE := 1;
	vs_names CH13_PHYSICIST.names%TYPE := 'Albert%';
BEGIN 
	vs_sql := 'select * from CH13_PHYSICIST where ids > :a and names like :a ';
	OPEN myPhysicist FOR vs_sql USING vn_id, vs_names;

	LOOP
		FETCH myPhysicist INTO empPhysicist;
		EXIT WHEN myPhysicist%notfound;
		dbms_output.put_line(empPhysicist.names);
	END LOOP;
	
	CLOSE myPhysicist;
END;

SELECT * FROM CH13_PHYSICIST ;

 -- BULK COLLECT INTO를 사용한 정적 SQL
DECLARE
	TYPE rec_physicist IS RECORD (
		ids CH13_PHYSICIST.ids%TYPE,
		names CH13_PHYSICIST.names%TYPE,
		birth_dt CH13_PHYSICIST.birth_dt%type
	);

	TYPE NT_physicist IS TABLE OF rec_physicist;

	vr_physicist NT_physicist;
BEGIN 
	SELECT *
	BULK COLLECT INTO vr_physicist
	FROM CH13_PHYSICIST;

	FOR i IN 1..vr_physicist.count
	LOOP
		dbms_output.put_line(vr_physicist(i).names);
	END LOOP;
END;

 -- BULK COLLECT INTO를 사용한 동적 SQL
DECLARE
	TYPE rec_physicist IS RECORD (
		ids CH13_PHYSICIST.ids%TYPE,
		names CH13_PHYSICIST.names%TYPE,
		birth_dt CH13_PHYSICIST.birth_dt%type
	);

	TYPE NT_physicist IS TABLE OF rec_physicist;

	vr_physicist NT_physicist;

	vs_sql varchar2(1000);
	vn_ids CH13_PHYSICIST.ids%TYPE := 1;
BEGIN 
	vs_sql := 'select * from CH13_PHYSICIST where ids > :a';

	EXECUTE IMMEDIATE vs_sql BULK COLLECT INTO vr_physicist USING vn_ids;
	
	FOR i IN 1..vr_physicist.count
	LOOP
		dbms_output.put_line(vr_physicist(i).names);
	END LOOP;
END;

 -- DBMS_SQL을 사용한 동적 SQL (NDS와 다른 방식)
DECLARE 
	vn_emp_id employees.employee_id%TYPE;
	vs_emp_name employees.emp_name%TYPE;
	vs_job_id employees.job_id%TYPE;

	vs_sql varchar2(1000);

	vs_job employees.job_id%TYPE := 'SA_REP';
	vn_sal employees.salary%TYPE := 7000;
	vn_manager employees.manager_id%TYPE := 148;

	-- 1. 커서를 연다
	vn_cur_id NUMBER := dbms_sql.open_cursor();
	vn_return NUMBER;
BEGIN 
	vs_sql := 'select employee_id, emp_name, job_id
			   from employees
			   where job_id = :a
			   and salary < :b
			   and manager_id = :c';
			  
	 -- 2. 파싱
	dbms_sql.parse(vn_cur_id, vs_sql, dbms_sql.native);

	 -- 3. 바인드 변수 연결
	dbms_sql.bind_variable(vn_cur_id, ':a', vs_job);
	dbms_sql.bind_variable(vn_cur_id, ':b', vn_sal);
	dbms_sql.bind_variable(vn_cur_id, ':c', vn_manager);

	 -- 4. 결과 선택 컬럼 정의
	dbms_sql.define_column(vn_cur_id, 1, vn_emp_id);
	dbms_sql.define_column(vn_cur_id, 2, vs_emp_name, 80);
	dbms_sql.define_column(vn_cur_id, 3, vs_job_id, 10);

	 -- 5. 쿼리 실행
	vn_return := dbms_sql.execute(vn_cur_id);

	 -- 6. 결과 패치
	LOOP
		IF dbms_sql.fetch_rows (vn_cur_id) = 0 THEN 
			EXIT;
		END IF;
		
		 -- 7. 패치된 결과 값 받아오기
		dbms_sql.column_value(vn_cur_id, 1, vn_emp_id);
		dbms_sql.column_value(vn_cur_id, 2, vs_emp_name);
		dbms_sql.column_value(vn_cur_id, 3, vs_job_id);
	
		dbms_output.put_line('vn_emp_id: ' || vn_emp_id);
		dbms_output.put_line('vs_emp_name: ' || vs_emp_name);
		dbms_output.put_line('vs_job_id: ' || vs_job_id);
	END LOOP;

	dbms_sql.close_cursor(vn_cur_id);
END;


 -- 230517
SELECT * FROM CH13_PHYSICIST ;

--INSERT INTO CH13_PHYSICIST VALUES (2, 'Isaac Newton', to_date('1643-01-01', 'YYYY-MM-DD'));

 -- DBMS_SQL로 UPDATE문 처리
DECLARE 
	vn_ids CH13_PHYSICIST.ids%TYPE := 3;
	vs_name CH13_PHYSICIST.names%TYPE := ' UPDATED';

	vs_sql varchar2(1000);

	vn_cur_id NUMBER := dbms_sql.open_cursor();	-- 1. 커서를 연다.
	vn_return NUMBER;
BEGIN 
	vs_sql := 'UPDATE CH13_PHYSICIST set names = names || :a where ids < :b';	-- 기존 데이터(names) + ' UPDATED'

	 -- 2. 파싱
	dbms_sql.parse(vn_cur_id, vs_sql, dbms_sql.native);

	 -- 3. 바인드 변수 연결
	dbms_sql.bind_variable(vn_cur_id, ':a', vs_name);
	dbms_sql.bind_variable(vn_cur_id, ':b', vn_ids);

	 -- 4. 쿼리 실행
	vn_return := dbms_sql.execute(vn_cur_id);

	dbms_sql.close_cursor(vn_cur_id);
	dbms_output.put_line('UPDATE 결과건수: ' || vn_return);
	COMMIT;
END;

 -- DBMS_SQL로 DELETE문 처리
DECLARE 
	vn_ids CH13_PHYSICIST.ids%TYPE := 3;

	vs_sql varchar2(1000);

	vn_cur_id NUMBER := dbms_sql.open_cursor();	-- 1. 커서를 연다.
	vn_return NUMBER;
BEGIN 
	vs_sql := 'DELETE CH13_PHYSICIST where ids < :b';

	 -- 2. 파싱
	dbms_sql.parse(vn_cur_id, vs_sql, dbms_sql.native);

	 -- 3. 바인드 변수 연결
	dbms_sql.bind_variable(vn_cur_id, ':b', vn_ids);

	 -- 4. 쿼리 실행
	vn_return := dbms_sql.execute(vn_cur_id);

	dbms_sql.close_cursor(vn_cur_id);
	dbms_output.put_line('DELETE 결과건수: ' || vn_return);
	COMMIT;
END;

--TRUNCATE TABLE CH13_PHYSICIST ;

DECLARE 
	vn_ids_array  dbms_sql.number_table;
	vs_name_array dbms_sql.varchar2_table;
	vd_dt_array   dbms_sql.date_table;

	vs_sql varchar2(1000);

	vn_cur_id NUMBER := dbms_sql.open_cursor();
	vn_return NUMBER;
BEGIN 
	vn_ids_array(1) := 1;
	vs_name_array(1) := 'Galileo Galilei';
	vd_dt_array(1) := to_date('1564-02-15', 'YYYY-MM-DD');

	vn_ids_array(2) := 2;
	vs_name_array(2) := 'Isaac Newton';
	vd_dt_array(2) := to_date('1643-01-04', 'YYYY-MM-DD');

	vn_ids_array(3) := 3;
	vs_name_array(3) := 'Max Plank';
	vd_dt_array(3) := to_date('1858-04-23', 'YYYY-MM-DD');

	vn_ids_array(4) := 4;
	vs_name_array(4) := 'Albert Einstein';
	vd_dt_array(4) := to_date('1879-03-14', 'YYYY-MM-DD');

	vs_sql := 'INSERT INTO CH13_PHYSICIST values (:a, :b, :c)';

	dbms_sql.parse(vn_cur_id, vs_sql, dbms_sql.native);

	dbms_sql.bind_array(vn_cur_id, ':a', vn_ids_array);
	dbms_sql.bind_array(vn_cur_id, ':b', vs_name_array);
	dbms_sql.bind_array(vn_cur_id, ':c', vd_dt_array);

	vn_return := dbms_sql.execute(vn_cur_id);

	dbms_sql.close_cursor(vn_cur_id);

	dbms_output.put_line('결과건수: ' || vn_return);
	COMMIT;
END;


 -- 230519
SELECT * FROM CH13_PHYSICIST ;

 -- BIND_ARRAY로 UPDATE, DELETE 처리
DECLARE 
	vn_ids_array  dbms_sql.number_table;
	vs_name_array dbms_sql.varchar2_table;

	vs_sql varchar2(1000);

	vn_cur_id NUMBER := dbms_sql.open_cursor();
	vn_return NUMBER;
BEGIN 
	vn_ids_array(1) := 1;
	vs_name_array(1) := 'Galileo Galilei';

	vn_ids_array(2) := 2;
	vs_name_array(2) := 'Isaac Newton';

	vn_ids_array(3) := 3;
	vs_name_array(3) := 'Max Plank';

	vn_ids_array(4) := 4;
	vs_name_array(4) := 'Albert Einstein';

	vs_sql := 'UPDATE CH13_PHYSICIST set names = :a where ids = :b';

	dbms_sql.parse(vn_cur_id, vs_sql, dbms_sql.native);

	dbms_sql.bind_array(vn_cur_id, ':a', vs_name_array);
	dbms_sql.bind_array(vn_cur_id, ':b', vn_ids_array);

	vn_return := dbms_sql.execute(vn_cur_id);

	dbms_sql.close_cursor(vn_cur_id);

	dbms_output.put_line('결과건수: ' || vn_return);
	COMMIT;
END;

 -- TO_REFCURSOR로 커서 변수에 결과 받기
DECLARE 
	vc_cur sys_refcursor;
	va_emp_id dbms_sql.number_table;
	va_emp_name dbms_sql.varchar2_table;

	vs_sql varchar2(1000);

	vs_job employees.job_id%TYPE := 'SA_REP';
	vn_sal employees.salary%TYPE := 9000;
	vn_manager employees.manager_id%TYPE := 148;

	-- 1. 커서를 연다
	vn_cur_id NUMBER := dbms_sql.open_cursor();
	vn_return NUMBER;
BEGIN 
	vs_sql := 'select employee_id, emp_name
			   from employees
			   where job_id = :a
			   and salary < :b
			   and manager_id = :c';
			  
	 -- 2. 파싱
	dbms_sql.parse(vn_cur_id, vs_sql, dbms_sql.native);

	 -- 3. 바인드 변수 연결
	dbms_sql.bind_variable(vn_cur_id, ':a', vs_job);
	dbms_sql.bind_variable(vn_cur_id, ':b', vn_sal);
	dbms_sql.bind_variable(vn_cur_id, ':c', vn_manager);

	 -- 4. 쿼리 실행
	vn_return := dbms_sql.execute(vn_cur_id);

	 -- 5. 커서로 변환
	vc_cur := dbms_sql.to_refcursor(vn_cur_id);

	 -- 6. 결과 패치
	FETCH vc_cur BULK COLLECT INTO va_emp_id, va_emp_name;

	FOR i IN 1..va_emp_id.count LOOP
		dbms_output.put_line(va_emp_id(i) || ' - ' || va_emp_name(i));
	END LOOP;
	
	CLOSE vc_cur;
END;

select employee_id, emp_name
from employees
where job_id = 'SA_REP'
and salary < 9000
and manager_id = 148
;

 -- DBMS_SQL 패키지를 이용해 컬럼 값을 세로로 출력하기
CREATE OR REPLACE PROCEDURE print_table(p_query IN varchar2)
IS 
	l_theCursor integer DEFAULT DBMS_SQL.OPEN_cursor;
	l_columnValue varchar2(4000);
	l_status integer;
	l_descTbl dbms_sql.desc_tab;
	l_colCnt NUMBER;
BEGIN 
	dbms_sql.parse(l_theCursor, p_query, dbms_sql.native);

	dbms_sql.describe_columns(l_theCursor, l_colCnt, l_descTbl);

	FOR i IN 1..l_colCnt
	LOOP
		dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000);
	END LOOP;
	
	l_status := dbms_sql.execute(l_theCursor);

	WHILE ( dbms_sql.fetch_rows(l_theCursor) > 0 )
	LOOP
		FOR i IN 1..l_colCnt
		LOOP
			dbms_sql.column_value(l_theCursor, i, l_columnValue);
			dbms_output.put_line(rpad(l_descTbl(i).col_name, 30) || ': ' || l_columnValue);
		END LOOP;
		dbms_output.put_line('--------------------');
	END LOOP;
	
	dbms_sql.close_cursor(l_theCursor);
END;

BEGIN 
	print_table('select * from CH13_PHYSICIST');
END;

 -- 신규 테이블에 데이터 이관
CREATE OR REPLACE PROCEDURE insert_ddl(p_table IN varchar2)
IS 
	l_theCursor integer DEFAULT DBMS_SQL.OPEN_cursor;
	l_columnValue varchar2(4000);
	l_status integer;
	l_descTbl dbms_sql.desc_tab;
	l_colCnt NUMBER;

	v_sel_sql varchar2(1000);
	v_ins_sql varchar2(1000);
BEGIN 
	v_sel_sql := 'select * from ' || p_table || ' where rownum = 1';
	
	dbms_sql.parse(l_theCursor, v_sel_sql, dbms_sql.native);

	dbms_sql.describe_columns(l_theCursor, l_colCnt, l_descTbl);

	v_ins_sql := 'insert into ' || p_table || ' ( ';

	FOR i IN 1..l_colCnt
	LOOP
		IF i = l_colCnt THEN 
			v_ins_sql := v_ins_sql || l_descTbl(i).col_name || ' )';
		ELSE 
			v_ins_sql := v_ins_sql || l_descTbl(i).col_name || ', ';
		END IF;
	END LOOP;
	
	dbms_output.put_line(v_ins_sql);

	dbms_sql.close_cursor(l_theCursor);
END;

BEGIN 
	insert_ddl('CH13_PHYSICIST');
END;

BEGIN 
	insert_ddl('customers');
END;

 -- Self-Check 1
CREATE OR REPLACE PROCEDURE ch13_exam_crt_table_proc(pv_src_table IN varchar2)
IS 
	vs_sql varchar2(1000);
BEGIN 
	vs_sql := 'CREATE TABLE ' || pv_src_table || '_NEW AS
			   SELECT * FROM ' || pv_src_table || ' where 1 = 2';
			  
	EXECUTE IMMEDIATE vs_sql;
END;

BEGIN 
	ch13_exam_crt_table_proc('CH13_PHYSICIST');
END;

SELECT * FROM CH13_PHYSICIST_NEW ;

 -- Self-Check 2
CREATE OR REPLACE PROCEDURE ch13_exam_crt_table_proc(pv_src_table IN varchar2)
IS 
	vs_sql varchar2(1000);
	vn_cnt NUMBER := 0;

	e_exist_table EXCEPTION;
BEGIN 
	vs_sql := 'SELECT count(*) from tabs where TABLE_NAME = ''' || pv_src_table || '_NEW''';
	dbms_output.put_line('vs_sql: ' || vs_sql);

	EXECUTE IMMEDIATE vs_sql INTO vn_cnt;
	
	dbms_output.put_line('vn_cnt: ' || vn_cnt);

	IF vn_cnt > 0 THEN 
		raise e_exist_table;
	END IF;
	
	vs_sql := 'CREATE TABLE ' || pv_src_table || '_NEW AS
			   SELECT * FROM ' || pv_src_table || ' where 1 = 2';
			  
	EXECUTE IMMEDIATE vs_sql;

EXCEPTION 
WHEN e_exist_table THEN 
	dbms_output.put_line(pv_src_table || '_NEW 테이블이 이미 존재합니다!');
	ROLLBACK;
WHEN OTHERS THEN 
	dbms_output.put_line('에러: ' || sqlerrm);
	ROLLBACK;
END;

BEGIN 
	ch13_exam_crt_table_proc('CH13_PHYSICIST');
END;

SELECT * FROM CH13_PHYSICIST_NEW ;


 -- 230522
 -- Self-Check 3
CREATE TABLE CH13_PHYSICIST_2 AS
SELECT *
FROM CH13_PHYSICIST
;

SELECT * FROM CH13_PHYSICIST_2 ;

--TRUNCATE TABLE CH13_PHYSICIST_2 ;

DECLARE 
	TYPE rec_physicist IS RECORD (
		IDS			CH13_PHYSICIST.ids%TYPE,
		NAMES		CH13_PHYSICIST.NAMES%TYPE,
		BIRTH_DT 	CH13_PHYSICIST.BIRTH_DT%type
	);

	TYPE NT_physicist IS TABLE OF rec_physicist;

	vr_physicist NT_physicist;
BEGIN 
	SELECT *
	BULK COLLECT INTO vr_physicist
	FROM CH13_PHYSICIST;

	FOR i IN 1..vr_physicist.count
	LOOP
		INSERT INTO CH13_PHYSICIST_2 VALUES (vr_physicist(i).IDS, vr_physicist(i).NAMES, vr_physicist(i).BIRTH_DT);
	END LOOP;

	COMMIT;
END;

 -- Self-Check 4, 5
DECLARE 
	TYPE rec_physicist IS RECORD (
		IDS			CH13_PHYSICIST.ids%TYPE,
		NAMES		CH13_PHYSICIST.NAMES%TYPE,
		BIRTH_DT 	CH13_PHYSICIST.BIRTH_DT%type
	);

	TYPE NT_physicist IS TABLE OF rec_physicist;

	vr_physicist NT_physicist;

	vn_ids_array dbms_sql.number_table;
	vs_name_array dbms_sql.varchar2_table;
	vd_dt_array dbms_sql.date_table;

	vs_sql varchar2(1000);

	vn_cur_id NUMBER := dbms_sql.open_cursor();
	vn_return NUMBER;
BEGIN 
	SELECT *
	BULK COLLECT INTO vr_physicist
	FROM CH13_PHYSICIST;

	FOR i IN 1..vr_physicist.count
	LOOP
		vn_ids_array(i) := vr_physicist(i).IDS;
		vs_name_array(i) := vr_physicist(i).NAMES;
		vd_dt_array(i) := vr_physicist(i).BIRTH_DT;
	END LOOP;

	vs_sql := 'insert into CH13_PHYSICIST_2 values (:a, :b, :c)';

	dbms_sql.parse(vn_cur_id, vs_sql, dbms_sql.native);

	dbms_sql.bind_array(vn_cur_id, ':a', vn_ids_array);
	dbms_sql.bind_array(vn_cur_id, ':b', vs_name_array);
	dbms_sql.bind_array(vn_cur_id, ':c', vd_dt_array);

	vn_return := dbms_sql.execute(vn_cur_id);

	dbms_sql.close_cursor(vn_cur_id);
	dbms_output.put_line('결과건수: ' || vn_return);
	COMMIT;
END;

SELECT * FROM CH13_PHYSICIST_2 ;
--TRUNCATE TABLE CH13_PHYSICIST_2 ;

 -- 트랜잭션 GTT
CREATE GLOBAL TEMPORARY TABLE ch14_tranc_gtt (
	ids NUMBER,
	names varchar2(50),
	birth_dt DATE 
)
ON COMMIT DELETE ROWS;

SELECT * FROM ch14_tranc_gtt ;

DECLARE 
	vn_cnt int := 0;
	vn_cnt2 int := 0;
BEGIN 
	INSERT INTO ch14_tranc_gtt 
	SELECT *
	FROM CH13_PHYSICIST ;

	SELECT COUNT(*) 
	INTO vn_cnt
	FROM ch14_tranc_gtt;

	COMMIT;

	SELECT COUNT(*) 
	INTO vn_cnt2
	FROM ch14_tranc_gtt;

	dbms_output.put_line('COMMIT 전: ' || vn_cnt);
	dbms_output.put_line('COMMIT 후: ' || vn_cnt2);
END;

CREATE GLOBAL TEMPORARY TABLE ch14_sess_gtt (
	ids NUMBER,
	names varchar2(50),
	birth_dt DATE 
)
ON COMMIT PRESERVE ROWS;

 -- 세션 GTT
DECLARE 
	vn_cnt int := 0;
	vn_cnt2 int := 0;
BEGIN 
	INSERT INTO ch14_sess_gtt 
	SELECT *
	FROM CH13_PHYSICIST ;

	SELECT COUNT(*) 
	INTO vn_cnt
	FROM ch14_sess_gtt;

	COMMIT;

	SELECT COUNT(*) 
	INTO vn_cnt2
	FROM ch14_sess_gtt;

	dbms_output.put_line('COMMIT 전: ' || vn_cnt);
	dbms_output.put_line('COMMIT 후: ' || vn_cnt2);
END;

SELECT * FROM ch14_sess_gtt ;

 -- 사용자 정의 테이블 함수
CREATE OR REPLACE TYPE ch14_num_nt IS TABLE OF NUMBER;	-- 중첩 테이블(컬렉션)

CREATE OR REPLACE FUNCTION fn_ch14_table1 (p_n number)
	RETURN ch14_num_nt
IS 
	vnt_return ch14_num_nt := ch14_num_nt();
BEGIN 
	FOR i IN 1..p_n
	LOOP
		vnt_return.extend;
		vnt_return(i) := i;
	END LOOP;

	RETURN vnt_return;
END;

SELECT fn_ch14_table1(10) FROM dual ;

SELECT * FROM table(fn_ch14_table1(10));

 -- OBJECT
CREATE OR REPLACE TYPE ch14_obj_type1 AS OBJECT (
	varchar_col1 varchar2(100),
	varchar_col2 varchar2(100),
	num_col		 NUMBER,
	date_col	 date
);

 -- OBJECT 형 중첩테이블
CREATE OR REPLACE TYPE ch14_cmplx_nt IS TABLE OF ch14_obj_type1;

 -- 패키지
CREATE OR REPLACE PACKAGE ch14_empty_pkg
IS 
	 -- 커서
	TYPE emp_refc_t IS REF CURSOR RETURN employees%rowtype;
END ch14_empty_pkg;

 -- 커서를 매개변수로 받아, OBJECT 타입을 반환하는 테이블 함수
CREATE OR REPLACE FUNCTION fn_ch14_table2(p_cur ch14_empty_pkg.emp_refc_t)
	RETURN ch14_cmplx_nt
IS 
	v_cur p_cur%rowtype;

	vnt_return ch14_cmplx_nt := ch14_cmplx_nt();
BEGIN 
	LOOP
		FETCH p_cur INTO v_cur;
		EXIT WHEN p_cur%notfound;
	
		vnt_return.extend();
		vnt_return(vnt_return.last) := ch14_obj_type1(NULL, NULL, NULL, NULL);
	
		vnt_return(vnt_return.last).varchar_col1 := v_cur.emp_name;
		vnt_return(vnt_return.last).varchar_col2 := v_cur.phone_number;
		vnt_return(vnt_return.last).num_col 	 := v_cur.employee_id;
		vnt_return(vnt_return.last).date_col 	 := v_cur.hire_date;
	END LOOP;

	RETURN vnt_return;
END;

SELECT *
FROM table(fn_ch14_table2(CURSOR (SELECT * FROM EMPLOYEES WHERE rownum < 6)));

CREATE OR REPLACE FUNCTION fn_ch14_pipe_table(p_n number)
	RETURN ch14_num_nt -- 중첩테이블 컬렉션
	pipelined 
IS 
	vnt_return ch14_num_nt := ch14_num_nt();
BEGIN 
	FOR i IN 1..p_n
	LOOP
		vnt_return.extend;
		vnt_return(i) := i;
	
		pipe ROW (vnt_return(i));
	END LOOP;
	RETURN;
END;

SELECT *
FROM table(fn_ch14_pipe_table(10));

SELECT *
FROM table(fn_ch14_table1(4000000));

SELECT *
FROM table(fn_ch14_pipe_table(4000000));


 -- 230523
 -- PIPE ROW 문 여러번 쓰기
CREATE OR REPLACE FUNCTION fn_ch14_pipe_table2 ( p_cur ch14_empty_pkg.emp_refc_t )
	RETURN ch14_cmplx_nt
	pipelined
IS 
	v_cur p_cur%rowtype;

	vnt_return ch14_cmplx_nt := ch14_cmplx_nt();
BEGIN 
	LOOP
		FETCH p_cur INTO v_cur;
		EXIT WHEN p_cur%notfound;
	
		vnt_return.extend();
		vnt_return(vnt_return.last) := ch14_obj_type1(NULL, NULL, NULL, NULL);
		vnt_return(vnt_return.last).varchar_col1 := v_cur.emp_name;
		vnt_return(vnt_return.last).varchar_col2 := v_cur.phone_number;
		vnt_return(vnt_return.last).num_col 	 := v_cur.employee_id;
		vnt_return(vnt_return.last).date_col 	 := v_cur.hire_date;
		pipe ROW (vnt_return(vnt_return.last));
	
		vnt_return(vnt_return.last).varchar_col1 := v_cur.job_id;
		vnt_return(vnt_return.last).varchar_col2 := v_cur.email;
		pipe ROW (vnt_return(vnt_return.last));
	END LOOP;
	RETURN;
END;

SELECT *
FROM table(fn_ch14_pipe_table2(CURSOR (SELECT * FROM EMPLOYEES WHERE rownum < 6 ORDER BY employee_id ASC )));

SELECT * FROM EMPLOYEES WHERE emp_name = 'Steven King' ;

 -- 학생들의 과목별 성적을 담은 테이블
CREATE TABLE ch14_score_table (
	years	 varchar2(4),	-- 연도
	gubun 	 varchar2(30),	-- 구분(중간/기말)
	subjects varchar2(30),	-- 과목
	score	 NUMBER			-- 점수
);

INSERT INTO ch14_score_table VALUES ('2014', '중간고사', '국어', 92);
INSERT INTO ch14_score_table VALUES ('2014', '중간고사', '영어', 87);
INSERT INTO ch14_score_table VALUES ('2014', '중간고사', '수학', 67);
INSERT INTO ch14_score_table VALUES ('2014', '중간고사', '과학', 80);
INSERT INTO ch14_score_table VALUES ('2014', '중간고사', '지리', 93);
INSERT INTO ch14_score_table VALUES ('2014', '중간고사', '독일어', 82);
INSERT INTO ch14_score_table VALUES ('2014', '기말고사', '국어', 88);
INSERT INTO ch14_score_table VALUES ('2014', '기말고사', '영어', 80);
INSERT INTO ch14_score_table VALUES ('2014', '기말고사', '수학', 93);
INSERT INTO ch14_score_table VALUES ('2014', '기말고사', '과학', 91);
INSERT INTO ch14_score_table VALUES ('2014', '기말고사', '지리', 89);
INSERT INTO ch14_score_table VALUES ('2014', '기말고사', '독일어', 83);
COMMIT;

SELECT * FROM ch14_score_table ;

 -- 전통적인 DECODE 혹은 CASE
SELECT years, gubun,
	CASE WHEN subjects = '국어' THEN score ELSE 0 END "국어",
	CASE WHEN subjects = '영어' THEN score ELSE 0 END "영어",
	CASE WHEN subjects = '수학' THEN score ELSE 0 END "수학",
	CASE WHEN subjects = '과학' THEN score ELSE 0 END "과학",
	CASE WHEN subjects = '지리' THEN score ELSE 0 END "지리",
	CASE WHEN subjects = '독일어' THEN score ELSE 0 END "독일어"
FROM ch14_score_table
;

 -- 전통적인 DECODE 혹은 CASE 2
SELECT years, gubun,
	SUM(국어) AS 국어, SUM(영어) AS 영어, SUM(수학) AS 수학, 
	SUM(과학) AS 과학, SUM(지리) AS 지리, SUM(독일어) AS 독일어
FROM (
	SELECT years, gubun,
		CASE WHEN subjects = '국어' THEN score ELSE 0 END "국어",
		CASE WHEN subjects = '영어' THEN score ELSE 0 END "영어",
		CASE WHEN subjects = '수학' THEN score ELSE 0 END "수학",
		CASE WHEN subjects = '과학' THEN score ELSE 0 END "과학",
		CASE WHEN subjects = '지리' THEN score ELSE 0 END "지리",
		CASE WHEN subjects = '독일어' THEN score ELSE 0 END "독일어"
	FROM ch14_score_table
)
GROUP BY years, gubun
;

 -- WITH절 사용
WITH mains AS (
	SELECT years, gubun,
		CASE WHEN subjects = '국어' THEN score ELSE 0 END "국어",
		CASE WHEN subjects = '영어' THEN score ELSE 0 END "영어",
		CASE WHEN subjects = '수학' THEN score ELSE 0 END "수학",
		CASE WHEN subjects = '과학' THEN score ELSE 0 END "과학",
		CASE WHEN subjects = '지리' THEN score ELSE 0 END "지리",
		CASE WHEN subjects = '독일어' THEN score ELSE 0 END "독일어"
	FROM ch14_score_table
)
SELECT years, gubun,
	SUM(국어) AS 국어, SUM(영어) AS 영어, SUM(수학) AS 수학, 
	SUM(과학) AS 과학, SUM(지리) AS 지리, SUM(독일어) AS 독일어
FROM mains
GROUP BY years, gubun
;

 -- PIVOT
SELECT *
FROM (
	SELECT years, gubun, subjects, score
	FROM ch14_score_table
)
pivot ( sum(score)
	FOR subjects IN ('국어', '영어', '수학', '과학', '지리', '독일어')
)
;


 -- 230525
CREATE TABLE ch14_score_col_table(
	years varchar2(4),
	gubun varchar2(30),
	korean NUMBER,
	english NUMBER,
	math NUMBER,
	science NUMBER,
	geology NUMBER,
	german NUMBER
);

INSERT INTO ch14_score_col_table 
VALUES ('2014', '중간고사', 92, 87, 67, 80, 93, 82);

INSERT INTO ch14_score_col_table 
VALUES ('2014', '기말고사', 88, 80, 93, 91, 89, 83);

SELECT * FROM ch14_score_col_table ;

 -- 컬럼을 로우로 전환 - UNION ALL
SELECT years, gubun, '국어' AS subject, korean AS score
FROM ch14_score_col_table
UNION ALL 
SELECT years, gubun, '영어' AS subject, english AS score
FROM ch14_score_col_table
UNION ALL 
SELECT years, gubun, '수학' AS subject, english AS score
FROM ch14_score_col_table
UNION ALL 
SELECT years, gubun, '과학' AS subject, english AS score
FROM ch14_score_col_table
UNION ALL 
SELECT years, gubun, '지리' AS subject, english AS score
FROM ch14_score_col_table
UNION ALL 
SELECT years, gubun, '독일어' AS subject, english AS score
FROM ch14_score_col_table
ORDER BY 1, 2 DESC
;

 -- UNPIVOT
SELECT *
FROM ch14_score_col_table
unpivot ( score
		  FOR subjects IN (
			  korean AS '국어',
			  ENGLISH AS '영어',
			  MATH AS '수학',
			  SCIENCE AS '과학',
			  GEOLOGY AS '지리',
			  GERMAN AS '독일어'
		  )
)
;

 -- 파이프라인 테이블 함수용 OBJECT 타입
CREATE OR REPLACE TYPE ch14_obj_subject AS OBJECT (
	years varchar2(4),
	gubun varchar2(30),
	subjects varchar2(30),
	score NUMBER 
);

 -- 컬렉션 타입
CREATE OR REPLACE TYPE ch14_subject_nt IS TABLE OF ch14_obj_subject;

CREATE OR REPLACE FUNCTION fn_ch14_pipe_table3
	RETURN ch14_subject_nt
	pipelined
IS
	vp_cur sys_refcursor;
	v_cur ch14_score_col_table%rowtype;

	vnt_return ch14_subject_nt := ch14_subject_nt();
BEGIN 
	OPEN vp_cur FOR SELECT * FROM ch14_score_col_table;

	LOOP
		FETCH vp_cur INTO v_cur;
		EXIT WHEN vp_cur%notfound;
	
		vnt_return.extend();
		vnt_return(vnt_return.last) := ch14_obj_subject(NULL, NULL, NULL, NULl);
	
		vnt_return(vnt_return.last).years := v_cur.YEARS;
		vnt_return(vnt_return.last).gubun := v_cur.GUBUN;
		vnt_return(vnt_return.last).subjects := '국어';
		vnt_return(vnt_return.last).score := v_cur.KOREAN;
		pipe ROW (vnt_return(vnt_return.last));

		vnt_return(vnt_return.last).subjects := '영어';
		vnt_return(vnt_return.last).score := v_cur.ENGLISH;
		pipe ROW (vnt_return(vnt_return.last));
	
		vnt_return(vnt_return.last).subjects := '수학';
		vnt_return(vnt_return.last).score := v_cur.ENGLISH;
		pipe ROW (vnt_return(vnt_return.last));
	
		vnt_return(vnt_return.last).subjects := '과학';
		vnt_return(vnt_return.last).score := v_cur.ENGLISH;
		pipe ROW (vnt_return(vnt_return.last));
	
		vnt_return(vnt_return.last).subjects := '지리';
		vnt_return(vnt_return.last).score := v_cur.ENGLISH;
		pipe ROW (vnt_return(vnt_return.last));
	
		vnt_return(vnt_return.last).subjects := '독일어';
		vnt_return(vnt_return.last).score := v_cur.ENGLISH;
		pipe ROW (vnt_return(vnt_return.last));
	END LOOP;
	RETURN;
END;

SELECT *
FROM TABLE(fn_ch14_pipe_table3)
;

 -- Self-Check 4
SELECT * FROM KOR_LOAN_STATUS WHERE period LIKE '2013%';

SELECT *
FROM (
	SELECT GUBUN, region, LOAN_JAN_AMT
	FROM KOR_LOAN_STATUS WHERE period LIKE '2013%'
)
pivot ( SUM(LOAN_JAN_AMT) 
	FOR region IN ('서울', '부산', '인천', '광주', '대전', '대구', '울산')
)
ORDER BY gubun DESC 
;

 -- DBMS_JOB의 서브 프로그램
CREATE TABLE ch15_job_test(
	seq NUMBER,
	insert_date date
);

CREATE OR REPLACE PROCEDURE ch15_job_test_proc
IS 
	vn_next_seq NUMBER;
BEGIN 
	SELECT nvl(MAX(seq), 0) + 1
	INTO vn_next_seq
	FROM ch15_job_test;

	INSERT INTO ch15_job_test VALUES (vn_next_seq, sysdate);

	COMMIT;

EXCEPTION WHEN OTHERS THEN 
	ROLLBACK;
	dbms_output.put_line(sqlerrm);
END;

 -- 잡 등록
DECLARE 
	v_job_no NUMBER;
BEGIN 
	dbms_job.submit(
		job => v_job_no,
		what => 'ch15_job_test_proc;',
		next_date => sysdate,
		INTERVAL => 'sysdate + 1/60/24'	-- 1분에 1번
	);

	COMMIT;

	dbms_output.put_line('v_job_no: ' || v_job_no);
END;

SELECT seq, TO_CHAR(insert_date, 'YYYY-MM-DD HH24:MI:SS') 
FROM ch15_job_test 
ORDER BY seq DESC 
;


 -- 230526
 -- 오라클에 등록된 잡의 각종 정보를 담고 있는 뷰
SELECT job, last_date, last_sec, next_date, next_sec, broken ,INTERVAL , failures, what
FROM user_jobs ;

BEGIN 
	dbms_job.broken(23, true);

	COMMIT;
END;

--TRUNCATE TABLE ch15_job_test;

 -- 잡의 속성 변경
BEGIN 
	dbms_job.change(
		job => 24,
		what => 'ch15_job_test_proc;',
		next_date => sysdate,
		INTERVAL => 'sysdate + 3/60/24'	-- 3분
	);

	COMMIT;
END;

BEGIN
	dbms_job.run(23);
	COMMIT;
END;

BEGIN 
	dbms_job.remove(24);
	COMMIT;
END;

 -- 프로그램 객체 생성
BEGIN 
	dbms_scheduler.create_program(
		program_name => 'my_program1',
		program_type => 'STORED_PROCEDURE',
		program_action => 'ch15_job_test_proc',
		comments => '첫번째 프로그램'
	);
END;

SELECT PROGRAM_NAME, PROGRAM_TYPE, PROGRAM_ACTION, NUMBER_OF_ARGUMENTS, ENABLED, COMMENTS
FROM USER_SCHEDULER_PROGRAMS 
;

BEGIN 
	dbms_scheduler.create_schedule(
		schedule_name => 'my_schedule1',
		start_date => NULL,
		repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',	-- 1분에 1번
		end_date => NULL,
		comments => '1분마다 수행'
	);
END;

SELECT SCHEDULE_NAME, SCHEDULE_TYPE, START_DATE, REPEAT_INTERVAL, END_DATE, COMMENTS
FROM USER_SCHEDULER_SCHEDULES 
;

BEGIN 
	dbms_scheduler.create_job(
		job_name => 'my_job1',
		job_type => 'STORED_PROCEDURE',
		job_action => 'ch15_job_test_proc',
		repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',	-- 1분에 1번
		comments => '버전1 잡객체'
	);
END;

SELECT JOB_NAME, JOB_STYLE, JOB_TYPE, JOB_ACTION, REPEAT_INTERVAL, ENABLED, AUTO_DROP, STATE, COMMENTS
FROM USER_SCHEDULER_JOBS 
;

--TRUNCATE TABLE ch15_job_test ;

BEGIN 
	dbms_scheduler.enable('my_job1');
END;

SELECT seq, TO_CHAR(insert_date, 'YYYY-MM-DD HH24:MI:SS') 
FROM ch15_job_test 
ORDER BY seq DESC 
;

SELECT LOG_ID, LOG_DATE, JOB_NAME, OPERATION, STATUS
FROM USER_SCHEDULER_JOB_LOG 
;

SELECT LOG_DATE, JOB_NAME, STATUS, ERROR#, REQ_START_DATE, ACTUAL_START_DATE, RUN_DURATION
FROM user_scheduler_job_run_details ;

BEGIN 
	dbms_scheduler.disable('my_job2');
END;

BEGIN 
	dbms_scheduler.create_job(
		job_name => 'my_job2',
		program_name => 'my_program1',
		schedule_name => 'my_schedule1',
		comments => '버전2 잡객체'
	);
END;

SELECT JOB_NAME, JOB_STYLE, JOB_TYPE, JOB_ACTION, SCHEDULE_NAME, SCHEDULE_TYPE, REPEAT_INTERVAL, ENABLED, 
		AUTO_DROP, STATE, COMMENTS
FROM USER_SCHEDULER_JOBS 
;

BEGIN 
	dbms_scheduler.enable('my_job2');
END;

SELECT seq, TO_CHAR(insert_date, 'YYYY-MM-DD HH24:MI:SS') 
FROM ch15_job_test 
ORDER BY seq DESC 
;

BEGIN 
	dbms_scheduler.enable('my_program1');
END;

BEGIN 
--	dbms_scheduler.create_job(
--		job_name => 'MY_EX_JOB1',
--		job_type => 'EXECUTABLE',
--		job_action => 'C:\Windows\System32\cmd.exe',
--		number_of_arguments => 2,
--		repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',
--		comments => '외부파일 실행 잡객체'
--	);

	dbms_scheduler.set_job_argument_value('MY_EX_JOB1', 1, '/c');

	dbms_scheduler.set_job_argument_value('MY_EX_JOB1', 2, 'c:\scheduler_test.bat');
	dbms_scheduler.enable('MY_EX_JOB1');
END;

 -- 체인
 -- 1. 넣을 테이블 만들기
CREATE TABLE ch15_changed_object (
	OBJECT_name 	varchar2(128),	-- 객체명
	object_type 	varchar2(50),	-- 객체 유형
	created			DATE,			-- 객체 생성일자
	last_ddl_time	DATE,			-- 객체 변경일자
	status 			varchar2(7),	-- 객체 상태
	creation_date 	DATE 			-- 생성일자
);

 -- 2. 일주일 간 수정된 객체 정보를 확인하는 프로시저
CREATE OR REPLACE PROCEDURE ch15_check_objects_prc
IS 
	vn_cnt NUMBER := 0;
BEGIN 
	SELECT COUNT(*) 
	INTO vn_cnt
	FROM USER_OBJECTS a
	WHERE LAST_DDL_TIME BETWEEN sysdate - 7 AND sysdate
	AND NOT EXISTS (
		SELECT 1
		FROM ch15_changed_object b
		WHERE a.OBJECT_NAME = b.OBJECT_NAME
	);
	
	IF vn_cnt = 0 THEN 
		raise_application_error(-20001, '변경된 객체 없음');		-- 사용자 에러코드 함수
	END IF;
END;

 -- 3. 변경된 객체 정보를 저장하는 프로시저
CREATE OR REPLACE PROCEDURE ch15_make_objects_prc
IS 
BEGIN 
	INSERT INTO ch15_changed_object (
		OBJECT_NAME,
		OBJECT_TYPE,
		CREATED,
		LAST_DDL_TIME,
		STATUS,
		CREATION_DATE
	)
	SELECT  OBJECT_NAME,
			OBJECT_TYPE,
			CREATED,
			LAST_DDL_TIME,
			STATUS,
			sysdate
	FROM USER_OBJECTS a
	WHERE LAST_DDL_TIME BETWEEN sysdate - 7 AND sysdate
	AND NOT EXISTS (
		SELECT 1
		FROM ch15_changed_object b
		WHERE a.OBJECT_NAME = b.OBJECT_NAME
	);

	COMMIT;

EXCEPTION WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
	raise_application_error(-20002, sqlerrm);	-- 사용자 에러코드 함수
	ROLLBACK;
END;


 -- 230528
 -- 4. 프로그램 객체 만들기
BEGIN 
	dbms_scheduler.create_program(
		program_name => 'MY_CHAIN_PROG1',
		program_type => 'STORED_PROCEDURE',
		program_action => 'ch15_check_objects_prc',
		comments => '첫번째 체인 프로그램'
	);

	dbms_scheduler.create_program(
		program_name => 'MY_CHAIN_PROG2',
		program_type => 'STORED_PROCEDURE',
		program_action => 'ch15_make_objects_prc',
		comments => '두번째 체인 프로그램'
	);

	dbms_scheduler.enable('MY_CHAIN_PROG1');
	dbms_scheduler.enable('MY_CHAIN_PROG2');
END;

 -- 5. 체인 생성
BEGIN 
	dbms_scheduler.create_chain(
		chain_name => 'MY_CHAIN1',
		rule_set_name => NULL,
		evaluation_interval => NULL,
		comments => '첫 번째 체인'
	);
END;

 -- 6. 스텝 생성
BEGIN 
	 -- STEP1
	dbms_scheduler.define_chain_step(
		chain_name => 'MY_CHAIN1',
		step_name => 'STEP1',
		program_name => 'MY_CHAIN_PROG1'
	);

	 -- STEP2
	dbms_scheduler.define_chain_step(
		chain_name => 'MY_CHAIN1',
		step_name => 'STEP2',
		program_name => 'MY_CHAIN_PROG2'
	);
END;

 -- 7. 룰 생성
BEGIN 
	 -- 최초 STEP1을 시작시키는 룰
	dbms_scheduler.define_chain_rule(
		chain_name => 'MY_CHAIN1',
		CONDITION => 'TRUE',
		ACTION => 'START STEP1',
		rule_name => 'MY_RULE1',
		comments => 'START 룰'
	);
END;

BEGIN 
	 -- 2번째 룰
	dbms_scheduler.define_chain_rule(
		chain_name => 'MY_CHAIN1',
		CONDITION => 'STEP1 ERROR_CODE = 20001',
		ACTION => 'END',
		rule_name => 'MY_RULE2',
		comments => '룰2'
	);
END;

BEGIN 
	 -- STEP1에서 STEP2로 가는 룰
	dbms_scheduler.define_chain_rule(
		chain_name => 'MY_CHAIN1',
		CONDITION => 'STEP1 SUCCEEDED',
		ACTION => 'START STEP2',
		rule_name => 'MY_RULE3',
		comments => '룰3'
	);

	 -- STEP2를 마치고 종료하는 룰
	dbms_scheduler.define_chain_rule(
		chain_name => 'MY_CHAIN1',
		CONDITION => 'STEP2 SUCCEEDED',
		ACTION => 'END',
		rule_name => 'MY_RULE4',
		comments => '룰4'
	);
END;

 -- 8. 잡 생성
BEGIN 
	dbms_scheduler.create_job(
		job_name => 'MY_CHAIN_JOBS',
		job_type => 'CHAIN',
		job_action => 'MY_CHAIN1',
		repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',
		comments => '체인을 실행하는 잡'
	);
END;

SELECT *
FROM USER_SCHEDULER_CHAINS ;

SELECT CHAIN_NAME, STEP_NAME, PROGRAM_NAME, STEP_TYPE, SKIP, PAUSE
FROM USER_SCHEDULER_CHAIN_STEPS ;

SELECT *
FROM USER_SCHEDULER_CHAIN_RULES ;

BEGIN 
	dbms_scheduler.enable('MY_CHAIN1');

	dbms_scheduler.enable('MY_CHAIN_JOBS');
END;

SELECT LOG_DATE, JOB_SUBNAME, OPERATION, STATUS, ADDITIONAL_INFO
FROM USER_SCHEDULER_JOB_LOG
WHERE job_name = 'MY_CHAIN_JOBS'
;

SELECT LOG_DATE, JOB_SUBNAME, STATUS, ACTUAL_START_DATE, RUN_DURATION, ADDITIONAL_INFO
FROM USER_SCHEDULER_JOB_RUN_DETAILS 
WHERE job_name = 'MY_CHAIN_JOBS'
;

SELECT * FROM ch15_changed_object ;

BEGIN 
	dbms_stats.gather_table_stats(ownname => 'ora_user', tabname => 'ch15_changed_object');
END;

SELECT table_name, NUM_ROWS, BLOCKS, EMPTY_BLOCKS, AVG_ROW_LEN FROM USER_TAB_STATISTICS
WHERE TABLE_NAME = 'CH15_CHANGED_OBJECT';

SELECT * FROM user_tables ;

 -- Self-Check 1
CREATE OR REPLACE PROCEDURE ch15_example1_prc
IS 
	vp_cur sys_refcursor;
	v_cur user_tables%rowtype;
BEGIN 
	OPEN vp_cur FOR SELECT * FROM user_tables ;

	LOOP
		FETCH vp_cur INTO v_cur;
		EXIT WHEN vp_cur%notfound;
	
		dbms_output.put_line('테이블명: ' || v_cur.TABLE_NAME);
	
		dbms_stats.gather_table_stats(ownname => 'ora_user', tabname => v_cur.TABLE_NAME);	-- 통계정보 생성 프로시저
	END LOOP;

	dbms_output.put_line('통계정보 생성완료.');

EXCEPTION WHEN OTHERS THEN 
	dbms_output.put_line('에러 발생 !! 내용: ' || sqlerrm);
	ROLLBACK;
END;

BEGIN 
	ch15_example1_prc();
END;

 -- Self-Check 2
DECLARE 
	v_job_no NUMBER;
BEGIN 
	dbms_job.submit(
		job => v_job_no,
		what => 'ch15_example1_prc;',
		next_date => sysdate,
		INTERVAL => 'TRUNC(SYSDATE) + 1 + 17/24'
	);

	COMMIT;

	dbms_output.put_line('v_job_no: ' || v_job_no);
END;

SELECT job, last_date, last_sec, next_date, next_sec, broken ,INTERVAL , failures, what
FROM user_jobs ;

 -- Self-Check 3
BEGIN 
	dbms_scheduler.create_job(
		job_name => 'stats_prc_job1',
		job_type => 'STORED_PROCEDURE',
		job_action => 'ch15_example1_prc',
		repeat_interval => 'FREQ=DAILY; BYHOUR=17',
		comments => '통계정보 생성 버전1 잡객체'
	);
END;

SELECT JOB_NAME, JOB_STYLE, JOB_TYPE, JOB_ACTION, SCHEDULE_NAME, SCHEDULE_TYPE, REPEAT_INTERVAL, ENABLED, 
		AUTO_DROP, STATE, COMMENTS
FROM USER_SCHEDULER_JOBS 
;

BEGIN 
	dbms_scheduler.enable('stats_prc_job1');
END;


 -- 230529
BEGIN 
	dbms_scheduler.disable('stats_prc_job1');
END;

 -- Self-Check 4
BEGIN 
	dbms_scheduler.create_program(
		program_name => 'stats_prc_program1',
		program_type => 'STORED_PROCEDURE',
		program_action => 'ch15_example1_prc',
		comments => '통계정보 첫번째 프로그램'
	);
END;

SELECT PROGRAM_NAME, PROGRAM_TYPE, PROGRAM_ACTION, NUMBER_OF_ARGUMENTS, ENABLED, COMMENTS
FROM USER_SCHEDULER_PROGRAMS 
;

BEGIN 
	dbms_scheduler.create_schedule(
		schedule_name => 'stats_prc_schedule1',
		start_date => NULL,
		repeat_interval => 'FREQ=DAILY; BYHOUR=17',
		end_date => NULL,
		comments => '매일 오후 5시 수행'
	);
END;

SELECT SCHEDULE_NAME, SCHEDULE_TYPE, START_DATE, REPEAT_INTERVAL, END_DATE, COMMENTS
FROM USER_SCHEDULER_SCHEDULES 
;

BEGIN 
	dbms_scheduler.create_job(
		job_name => 'stats_prc_job2',
		program_name => 'stats_prc_program1',
		schedule_name => 'stats_prc_schedule1',
		comments => '통계정보 생성 버전2 잡객체'
	);
END;

SELECT /*JOB_NAME, program_name, JOB_TYPE, JOB_ACTION, SCHEDULE_NAME, SCHEDULE_TYPE, REPEAT_INTERVAL, ENABLED, 
		AUTO_DROP, STATE, COMMENTS*/*
FROM USER_SCHEDULER_JOBS 
;

BEGIN 
	dbms_scheduler.enable('stats_prc_program1');
END;

SELECT LOG_DATE, JOB_SUBNAME, STATUS, ACTUAL_START_DATE, RUN_DURATION, ADDITIONAL_INFO
FROM USER_SCHEDULER_JOB_RUN_DETAILS 
WHERE job_name = 'stats_prc_job2'
;

 -- 일괄처리를 위한, 사원 테이블과 유사한 형태의 대상 테이블
CREATE TABLE emp_bulk (	
	bulk_id		NUMBER	NOT NULL,
	"EMPLOYEE_ID" NUMBER(6,0) NOT NULL, 
	"EMP_NAME" VARCHAR2(80) NOT NULL, 
	"EMAIL" VARCHAR2(50), 
	"PHONE_NUMBER" VARCHAR2(30), 
	"HIRE_DATE" DATE NOT NULL, 
	"SALARY" NUMBER(8,2), 
	"MANAGER_ID" NUMBER(6,0), 
	"COMMISSION_PCT" NUMBER(2,2), 
	"RETIRE_DATE" DATE, 
	"DEPARTMENT_ID" NUMBER(6,0), 
	"JOB_ID" VARCHAR2(10), 
	dep_name varchar2(100),
	job_title varchar2(80)
);

SELECT * FROM emp_bulk ;
SELECT COUNT(*)  FROM EMPLOYEES ;

BEGIN 
	FOR i IN 1..10000
	LOOP
		INSERT INTO emp_bulk (
			BULK_ID,
			EMPLOYEE_ID,
			EMP_NAME,
			EMAIL,
			PHONE_NUMBER,
			HIRE_DATE,
			SALARY,
			MANAGER_ID,
			COMMISSION_PCT,
			RETIRE_DATE,
			DEPARTMENT_ID,
			JOB_ID
		)
		SELECT i,
			EMPLOYEE_ID,
			EMP_NAME,
			EMAIL,
			PHONE_NUMBER,
			HIRE_DATE,
			SALARY,
			MANAGER_ID,
			COMMISSION_PCT,
			RETIRE_DATE,
			DEPARTMENT_ID,
			JOB_ID
			FROM EMPLOYEES;
	END LOOP;

	COMMIT;
END;

SELECT * FROM emp_bulk ;

 -- emp_bulk 테이블을 조회하는 커서와 반복문을 이용한 익명 블록
DECLARE 
	 -- 커서 선언
	CURSOR c1 IS 
	SELECT employee_id
	FROM EMP_BULK ;

	vn_cnt NUMBER := 0;
	vn_emp_id NUMBER;
	vd_sysdate DATE;
	vn_total_time NUMBER := 0;
BEGIN 
	vd_sysdate := sysdate;

	OPEN c1;

	LOOP
		FETCH c1 INTO vn_emp_id;
		EXIT WHEN c1%notfound;
	
		vn_cnt := vn_cnt + 1;
	END LOOP;

	CLOSE c1;

	vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;

	dbms_output.put_line('전체건수: ' || vn_cnt);
	dbms_output.put_line('소요 시간: ' || vn_total_time || '초');
END;

 -- BULK COLLECT 사용
DECLARE 
	 -- 커서 선언
	CURSOR c1 IS 
	SELECT employee_id
	FROM EMP_BULK ;

	 -- 컬렉션 타입 선언
	TYPE bkEmpTP IS TABLE OF emp_bulk.employee_id%TYPE;
	vnt_bkEmpTp bkEmpTP;

	vd_sysdate DATE;
	vn_total_time NUMBER := 0;
BEGIN 
	vd_sysdate := sysdate;

	OPEN c1;

	FETCH c1 BULK COLLECT INTO vnt_bkEmpTp;

	CLOSE c1;

	vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;

	dbms_output.put_line('전체건수: ' || vnt_bkEmpTp.count);
	dbms_output.put_line('소요 시간: ' || vn_total_time || '초');
END;

SELECT * FROM emp_bulk ;

 -- 인덱스 생성
CREATE INDEX emp_bulk_idx01 ON emp_bulk( BULK_ID );	-- BULK_ID 뒤에 ASC 생략

 -- 통계 정보 생성
BEGIN 
	dbms_stats.gather_table_stats('ORA_USER', 'EMP_BULK');
END;

 -- 커서와 FOR문을 활용해 데이터 갱신
DECLARE 
	 -- 커서 선언
	CURSOR c1 IS 
	SELECT DISTINCT bulk_id
	FROM EMP_BULK ;

	 -- 컬렉션 타입 선언
	TYPE BulkIDTP IS TABLE OF emp_bulk.bulk_id%TYPE;
	vnt_BulkID BulkIDTP;

	vd_sysdate DATE;
	vn_total_time NUMBER := 0;
BEGIN 
	vd_sysdate := sysdate;

	OPEN c1;

	FETCH c1 BULK COLLECT INTO vnt_BulkID;

	FOR i IN 1..vnt_BulkID.count
	LOOP
		UPDATE EMP_BULK
		SET retire_date = hire_date
		WHERE bulk_id = vnt_BulkID(i);
	END LOOP;
	COMMIT;
	CLOSE c1;

	vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;

	dbms_output.put_line('전체건수: ' || vnt_BulkID.count);
	dbms_output.put_line('소요 시간: ' || vn_total_time || '초');
END;

 -- FORALL문 사용
DECLARE 
	 -- 커서 선언
	CURSOR c1 IS 
	SELECT DISTINCT bulk_id
	FROM EMP_BULK ;

	 -- 컬렉션 타입 선언
	TYPE BulkIDTP IS TABLE OF emp_bulk.bulk_id%TYPE;
	vnt_BulkID BulkIDTP;

	vd_sysdate DATE;
	vn_total_time NUMBER := 0;
BEGIN 
	vd_sysdate := sysdate;

	OPEN c1;

	FETCH c1 BULK COLLECT INTO vnt_BulkID;

	FORALL i IN 1..vnt_BulkID.count
		UPDATE EMP_BULK
		SET retire_date = hire_date
		WHERE bulk_id = vnt_BulkID(i);
	
	COMMIT;

	CLOSE c1;

	vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;

	dbms_output.put_line('전체건수: ' || vnt_BulkID.count);
	dbms_output.put_line('FORALL 소요 시간: ' || vn_total_time || '초');
END;

 -- 부서코드를 받아 부서명을 반환하는 함수
CREATE OR REPLACE FUNCTION fn_get_depname_normal( pv_dept_id varchar2 )
	RETURN varchar2
IS 
	vs_dep_name departments.DEPARTMENT_NAME%TYPE;
BEGIN 
	SELECT department_name
	INTO vs_dep_name
	FROM DEPARTMENTS 
	WHERE department_id = pv_dept_id;

	RETURN vs_dep_name;

EXCEPTION WHEN OTHERS THEN 
	RETURN '';
END;

SELECT * FROM EMP_BULK ;

 -- EMP_BULK 테이블의 dep_name 컬럼 값 갱신
DECLARE 
	vn_cnt NUMBER := 0;
	vd_sysdate DATE;
	vn_total_time NUMBER := 0;
BEGIN 
	vd_sysdate := sysdate;

	UPDATE EMP_BULK
	SET dep_name = fn_get_depname_normal(department_id)
	WHERE bulk_id BETWEEN 1 AND 1000;
	
	vn_cnt := SQL%rowcount;

	COMMIT;

	vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;

	dbms_output.put_line(' UPDATE 건수: ' || vn_cnt);
	dbms_output.put_line('소요 시간: ' || vn_total_time || '초');
END;

SELECT department_id, dep_name, COUNT(*) 
FROM EMP_BULK 
WHERE bulk_id BETWEEN 1 AND 1000
GROUP BY department_id, dep_name
ORDER BY department_id, dep_name
;


 -- 230601
 -- RESULT CACHE 기능이 탑재된 함수
CREATE OR REPLACE FUNCTION fn_get_depname_rsltcache(pv_dept_id varchar2)
	RETURN varchar2
	result_cache
	relies_on (departments)
IS
	vs_dep_name departments.DEPARTMENT_NAME%TYPE;
BEGIN 
	SELECT department_name
	INTO vs_dep_name
	FROM DEPARTMENTS
	WHERE department_id = pv_dept_id;

	RETURN vs_dep_name;

EXCEPTION WHEN OTHERS THEN 
	RETURN '';
END;

SELECT DISTINCT department_id FROM EMP_BULK ;

DECLARE 
	vn_cnt NUMBER := 0;
	vd_sysdate DATE;
	vn_total_time NUMBER := 0;
BEGIN 
	vd_sysdate := sysdate;

	UPDATE EMP_BULK
	SET dep_name = fn_get_depname_rsltcache(department_id)
	WHERE bulk_id BETWEEN 1 AND 1000;
	
	vn_cnt := SQL%rowcount;

	COMMIT;

	vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;

	dbms_output.put_line('전체건수: ' || vn_cnt);
	dbms_output.put_line('소요 시간: ' || vn_total_time || '초');
END;

SELECT *
FROM "V$RESULT_CACHE_STATISTICS" 
;

 -- ALTER SESSION으로 병렬 쿼리 처리
DECLARE 
	vn_cnt NUMBER := 0;
	vd_sysdate DATE;
	vn_total_time NUMBER := 0;

	vs_emp_name employees.emp_name%TYPE;
	
	TYPE emp_dep_curtype IS REF CURSOR;
	emp_dep_curvar emp_dep_curtype;
BEGIN 
	EXECUTE IMMEDIATE 'ALTER SESSION FORCE PARALLEL QUERY PARALLEL 4';
	
	vd_sysdate := sysdate;

	OPEN emp_dep_curvar FOR SELECT EMP_NAME 
							FROM EMPLOYEES 
							WHERE DEPARTMENT_ID = 90;
							
	LOOP 
		FETCH emp_dep_curvar INTO vs_emp_name;
	
		EXIT WHEN emp_dep_curvar%notfound;
	
--		dbms_output.put_line(vs_emp_name);
	END LOOP;
	
	vn_cnt := SQL%rowcount;

	COMMIT;

	vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;

	dbms_output.put_line('전체건수: ' || vn_cnt);
	dbms_output.put_line('소요 시간: ' || vn_total_time || '초');
END;

 -- 병렬 DML
DECLARE 

BEGIN 
	EXECUTE IMMEDIATE 'alter session force parallel dml parallel 4';
	
	INSERT INTO ch14_score_col_table 
	VALUES ('2015', '중간고사', 92, 87, 67, 80, 93, 82);
	COMMIT;

	UPDATE ch14_score_col_table
	SET KOREAN = 40
	WHERE GUBUN = '기말고사';
	COMMIT;

	EXECUTE IMMEDIATE 'alter session disable parallel dml';
END;

SELECT * FROM ch14_score_col_table;

SELECT * FROM jobs ;

 -- Self-Check 2
CREATE OR REPLACE FUNCTION fn_get_jobtitle_rsltcache(pv_job_id varchar2)
	RETURN varchar2
	result_cache
	relies_on (JOBS)
IS 
	vs_job_title jobs.JOB_TITLE%TYPE;
BEGIN 
	SELECT JOB_TITLE
	INTO vs_job_title
	FROM JOBS 
	WHERE job_id = pv_job_id;

	RETURN vs_job_title;

EXCEPTION WHEN OTHERS THEN 
	RETURN '';
END;

SELECT fn_get_jobtitle_rsltcache('AD_PRES') FROM dual ;

DECLARE 

BEGIN 
	dbms_output.put_line(fn_get_jobtitle_rsltcache('AD_PRES'));
END;

 -- Self-Check 3
SELECT * FROM EMP_BULK WHERE BULK_id BETWEEN 1001 AND 1000000 ORDER BY bulk_id ASC ;

DECLARE 
	vn_cnt NUMBER := 0;
	vd_sysdate DATE;
	vn_total_time NUMBER := 0;
BEGIN 
	vd_sysdate := sysdate;

	UPDATE EMP_BULK
	SET JOB_TITLE = fn_get_jobtitle_rsltcache(JOB_ID);
--	WHERE bulk_id BETWEEN 1 AND 1000;
	
	vn_cnt := SQL%rowcount;

	COMMIT;

	vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;

	dbms_output.put_line('전체건수: ' || vn_cnt);
	dbms_output.put_line('소요 시간: ' || vn_total_time || '초');
END;

 -- 데이터 딕셔너리 뷰
SELECT table_name, num_rows, last_analyzed FROM user_tables WHERE num_rows = 0 AND table_name = 'EX7_5' ;

BEGIN 
	dbms_stats.gather_table_stats(ownname => 'ora_user', tabname => 'EX7_5');
END;

SELECT * FROM user_objects ;
SELECT * FROM user_procedures ;
SELECT * FROM user_arguments ;
SELECT * FROM USER_DEPENDENCIES WHERE referenced_name = 'ch10_ins_emp_proc' ;
SELECT * FROM user_source ;


 -- 230602
CREATE OR REPLACE PACKAGE ch17_src_test_pkg IS 

	pv_name varchar2(30) := 'CH17_SRC_TEST_PKG';

END ch17_src_test_pkg;

SELECT * 
FROM user_source 
WHERE name = 'CH17_SRC_TEST_PKG'
ORDER BY line ASC 
;

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS 

	pvv_temp varchar2(30) := 'TEST';

END ch17_src_test_pkg;

SELECT * 
FROM user_source 
WHERE name = 'CH17_SRC_TEST_PKG'
ORDER BY TYPE , line ASC 
;

 -- 사원 테이블을 사용하는 모든 프로그램과 해당 소스
SELECT *
FROM user_source
WHERE text LIKE '%EMPLOYEES%'
OR text LIKE '%employees%'
ORDER BY name, TYPE, line
;

SELECT *
FROM user_source
WHERE UPPER(text) LIKE '%EMPLOYEES%'
ORDER BY name, TYPE, line
;

 -- 소스 백업하기
CREATE TABLE bk_source_20230602 AS 
	SELECT *
	FROM user_source
	ORDER BY name, TYPE, line ASC 
;

SELECT * FROM bk_source_20230602 ;

 -- 디버깅 대상 프로그램 만들기
CREATE TABLE ch17_sales_detail (
	channel_name varchar2(50),
	prod_name varchar2(300),
	cust_name varchar2(100),
	emp_name varchar2(100),
	sales_date DATE,
	sales_month varchar2(6),
	sales_qty NUMBER DEFAULT 0,
	sales_amt NUMBER DEFAULT 0
);

CREATE INDEX idx_ch17_sales_dtl ON ch17_sales_detail (sales_month);

CREATE OR REPLACE PACKAGE ch17_src_test_pkg IS 

	pv_name varchar2(30) := 'CH17_SRC_TEST_PKG';

	PROCEDURE sales_detail_prc(
		ps_month IN varchar2,
		pn_amt IN NUMBER,
		pn_rate IN number
	);

END ch17_src_test_pkg;

CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS 

	PROCEDURE sales_detail_prc(
		ps_month IN varchar2,	-- 월
		pn_amt IN NUMBER,		-- 금액
		pn_rate IN NUMBER		-- 할인률
	)
	IS 
		vd_sysdate DATE;
		vn_total_time NUMBER := 0;
	BEGIN 
		dbms_output.put_line('-----------------------<변수값 출력>-----------------------');
		dbms_output.put_line('ps_month: ' || ps_month);
		dbms_output.put_line('pn_amt: ' || pn_amt);
		dbms_output.put_line('pn_rate: ' || pn_rate);
		dbms_output.put_line('----------------------------------------------------------');
		
		 -- 1. ps_month에 해당하는 월의 ch17_sales_detail 데이터 삭제
		vd_sysdate := sysdate;
	
		DELETE ch17_sales_detail
		WHERE sales_month = ps_month;
	
		vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;
		dbms_output.put_line('DELETE 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time);
	
		 -- 2. ps_month에 해당하는 월의 ch17_sales_detail 데이터 생성
		vd_sysdate := sysdate;
	
		INSERT INTO ch17_sales_detail
		SELECT b.prod_name,
			   d.channel_desc,
			   c.cust_name,
			   e.emp_name,
			   a.sales_date,
			   a.sales_month,
			   SUM(a.quantity_sold) ,
			   SUM(a.amount_sold) 
		FROM SALES a,
			 PRODUCTS b,
			 CUSTOMERS c,
			 CHANNELS d,
			 EMPLOYEES e
		WHERE a.sales_month = ps_month
		AND   a.prod_id = b.prod_id
		AND   a.cust_id = c.cust_id
		AND   a.channel_id = d.channel_id
		AND   a.employee_id = e.employee_id
		GROUP BY b.prod_name,
			   	 d.channel_desc,
			     c.cust_name,
			     e.emp_name,
			     a.sales_date,
			     a.sales_month;
			    
		vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;
		dbms_output.put_line('INSERT 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time);
			    
		 -- 3. 판매금액(sales_amt)이 pn_amt보다 큰 건은 pn_rate 비율만큼 할인
		vd_sysdate := sysdate;
	
		UPDATE ch17_sales_detail
		SET sales_amt = sales_amt - (sales_amt * pn_rate * 0.01)
		WHERE sales_month = ps_month
		AND sales_amt > pn_amt;
	
		vn_total_time := (sysdate - vd_sysdate) * 60 * 60 * 24;
		dbms_output.put_line('UPDATE 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time);
	
		COMMIT;
		EXCEPTION WHEN OTHERS THEN 
			dbms_output.put_line(sqlerrm);
			ROLLBACK;
	
	END sales_detail_prc;

END ch17_src_test_pkg;

SELECT SUM(SALES_AMT) FROM ch17_sales_detail ;

BEGIN 
	ch17_src_test_pkg.sales_detail_prc(
		ps_month => '200112',
		pn_amt => 50,
		pn_rate => 32.5
	);
END;

SELECT 
	DATA.*
FROM (
	SELECT b.prod_name,
		   d.channel_desc,
		   c.cust_name,
		   e.emp_name,
		   a.sales_date,
		   a.sales_month,
		   SUM(a.quantity_sold) ,
		   SUM(a.amount_sold) AMOUNT_SOLD 
	FROM SALES a,
		 PRODUCTS b,
		 CUSTOMERS c,
		 CHANNELS d,
		 EMPLOYEES e
	WHERE a.sales_month = '200112'
	AND   a.prod_id = b.prod_id
	AND   a.cust_id = c.cust_id
	AND   a.channel_id = d.channel_id
	AND   a.employee_id = e.employee_id
	GROUP BY b.prod_name,
		   	 d.channel_desc,
		     c.cust_name,
		     e.emp_name,
		     a.sales_date,
		     a.sales_month
) DATA 
WHERE 
	DATA.AMOUNT_SOLD > 10000
;

SELECT sales_month, COUNT(*)  
FROM ch17_sales_detail
GROUP BY sales_month
ORDER BY sales_month
;

 -- 소요 시간 계산의 다른 방법
CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS 

	PROCEDURE sales_detail_prc(
		ps_month IN varchar2,	-- 월
		pn_amt IN NUMBER,		-- 금액
		pn_rate IN NUMBER		-- 할인률
	)
	IS 
		vn_total_time NUMBER := 0;
	BEGIN 
		dbms_output.put_line('-----------------------<변수값 출력>-----------------------');
		dbms_output.put_line('ps_month: ' || ps_month);
		dbms_output.put_line('pn_amt: ' || pn_amt);
		dbms_output.put_line('pn_rate: ' || pn_rate);
		dbms_output.put_line('----------------------------------------------------------');
		
		 -- 1. ps_month에 해당하는 월의 ch17_sales_detail 데이터 삭제
		vn_total_time := dbms_utility.get_time;
	
		DELETE ch17_sales_detail
		WHERE sales_month = ps_month;
	
		vn_total_time := (dbms_utility.get_time - vn_total_time) / 100;
		dbms_output.put_line('DELETE 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time);
	
		 -- 2. ps_month에 해당하는 월의 ch17_sales_detail 데이터 생성
		vn_total_time := dbms_utility.get_time;
	
		INSERT INTO ch17_sales_detail
		SELECT b.prod_name,
			   d.channel_desc,
			   c.cust_name,
			   e.emp_name,
			   a.sales_date,
			   a.sales_month,
			   SUM(a.quantity_sold) ,
			   SUM(a.amount_sold) 
		FROM SALES a,
			 PRODUCTS b,
			 CUSTOMERS c,
			 CHANNELS d,
			 EMPLOYEES e
		WHERE a.sales_month = ps_month
		AND   a.prod_id = b.prod_id
		AND   a.cust_id = c.cust_id
		AND   a.channel_id = d.channel_id
		AND   a.employee_id = e.employee_id
		GROUP BY b.prod_name,
			   	 d.channel_desc,
			     c.cust_name,
			     e.emp_name,
			     a.sales_date,
			     a.sales_month;
			    
		vn_total_time := (dbms_utility.get_time - vn_total_time) / 100;
		dbms_output.put_line('INSERT 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time);
			    
		 -- 3. 판매금액(sales_amt)이 pn_amt보다 큰 건은 pn_rate 비율만큼 할인
		vn_total_time := dbms_utility.get_time;
	
		UPDATE ch17_sales_detail
		SET sales_amt = sales_amt - (sales_amt * pn_rate * 0.01)
		WHERE sales_month = ps_month
		AND sales_amt > pn_amt;
	
		vn_total_time := (dbms_utility.get_time - vn_total_time) / 100;
		dbms_output.put_line('UPDATE 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time);
	
		COMMIT;
		EXCEPTION WHEN OTHERS THEN 
			dbms_output.put_line(sqlerrm);
			ROLLBACK;
	
	END sales_detail_prc;

END ch17_src_test_pkg;

 -- 로그 테이블
CREATE TABLE program_log(
	log_id NUMBER,				-- 로그 아이디
	program_name varchar2(100),	-- 프로그램명
	parameters varchar2(500),	-- 프로그램 매개변수
	state varchar2(10),			-- 상태(Running, Completed, Error)
	start_time timestamp,		-- 시작시간
	end_time timestamp,			-- 종료시간
	log_desc varchar2(2000)		-- 로그내용
);

 -- 시퀀스 생성
CREATE SEQUENCE prg_log_seq
INCREMENT BY 1
START WITH 1
MINVALUE 1
MAXVALUE 1000000
nocycle 
nocache;

 -- 로그 쌓는 루틴 추가
CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS 

	PROCEDURE sales_detail_prc(
		ps_month IN varchar2,	-- 월
		pn_amt IN NUMBER,		-- 금액
		pn_rate IN NUMBER		-- 할인률
	)
	IS 
		vn_total_time NUMBER := 0;
	
		vn_log_id NUMBER;
		vs_parameters varchar2(500);
		vs_prg_log varchar2(2000);
	BEGIN 
		vs_parameters := 'ps_month => ' || ps_month || ', pn_amt => ' || pn_amt || ' , pn_rate => ' || pn_rate;
	
		BEGIN 
			vn_log_id := prg_log_seq.nextval;
			INSERT INTO program_log (
				LOG_ID,
				PROGRAM_NAME,
				PARAMETERS,
				STATE,
				START_TIME
			)
			VALUES (
				vn_log_id,
				'CH17_SRC_TEST_PKG.sales_detail_prc',
				vs_parameters,
				'Running',
				systimestamp
			);
		
			COMMIT;
		END;
		
		 -- 1. ps_month에 해당하는 월의 ch17_sales_detail 데이터 삭제
		vn_total_time := dbms_utility.get_time;
	
		DELETE ch17_sales_detail
		WHERE sales_month = ps_month;
	
		vn_total_time := (dbms_utility.get_time - vn_total_time) / 100;
	
		vs_prg_log := 'DELETE 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time || chr(13);
	
		 -- 2. ps_month에 해당하는 월의 ch17_sales_detail 데이터 생성
		vn_total_time := dbms_utility.get_time;
	
		INSERT INTO ch17_sales_detail
		SELECT b.prod_name,
			   d.channel_desc,
			   c.cust_name,
			   e.emp_name,
			   a.sales_date,
			   a.sales_month,
			   SUM(a.quantity_sold) ,
			   SUM(a.amount_sold) 
		FROM SALES a,
			 PRODUCTS b,
			 CUSTOMERS c,
			 CHANNELS d,
			 EMPLOYEES e
		WHERE a.sales_month = ps_month
		AND   a.prod_id = b.prod_id
		AND   a.cust_id = c.cust_id
		AND   a.channel_id = d.channel_id
		AND   a.employee_id = e.employee_id
		GROUP BY b.prod_name,
			   	 d.channel_desc,
			     c.cust_name,
			     e.emp_name,
			     a.sales_date,
			     a.sales_month;
			    
		vn_total_time := (dbms_utility.get_time - vn_total_time) / 100;
		
		vs_prg_log := vs_prg_log || 'INSERT 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time || chr(13);
			    
		 -- 3. 판매금액(sales_amt)이 pn_amt보다 큰 건은 pn_rate 비율만큼 할인
		vn_total_time := dbms_utility.get_time;
	
		UPDATE ch17_sales_detail
		SET sales_amt = sales_amt - (sales_amt * pn_rate * 0.01)
		WHERE sales_month = ps_month
		AND sales_amt > pn_amt;
	
		vn_total_time := (dbms_utility.get_time - vn_total_time) / 100;
		
		vs_prg_log := vs_prg_log || 'UPDATE 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time || chr(13);
	
		COMMIT;
	
		BEGIN 
			UPDATE program_log
			SET state = 'Completed',
				end_time = SYSTIMESTAMP,
				log_desc = vs_prg_log || '작업종료!'
			WHERE log_id = vn_log_id;
		
			COMMIT;
		END;
	
		EXCEPTION WHEN OTHERS THEN 
			BEGIN 
				vs_prg_log := sqlerrm;
			
				UPDATE program_log
				SET state = 'Error',
					end_time = SYSTIMESTAMP,
					log_desc = vs_prg_log
				WHERE log_id = vn_log_id;
			
				COMMIT;
			END;
			ROLLBACK;
	
	END sales_detail_prc;
END ch17_src_test_pkg;

BEGIN 
	ch17_src_test_pkg.sales_detail_prc(
		ps_month => '200112',
		pn_amt => 50,
		pn_rate => 32.5
	);
END;

SELECT * FROM program_log ;

SELECT prg_log_seq.currval FROM dual ;


 -- 230604
 -- 동적 쿼리 디버깅
CREATE OR REPLACE PROCEDURE ch17_dynamic_test (
	p_emp_id NUMBER,
	p_emp_name varchar2,
	p_job_id varchar2
)
IS 
	vs_query varchar2(1000);
	vn_cnt NUMBER := 0;
	vs_empname employees.emp_name%TYPE := '%' || p_emp_name || '%';
BEGIN 
	vs_query := 'select count(*) ' || chr(13);
	vs_query := vs_query || ' from employees ' || chr(13);
	vs_query := vs_query || ' where 1=1 ' || chr(13);

	IF p_emp_id IS NOT NULL THEN
		vs_query := vs_query || ' and employee_id = ' || p_emp_id || chr(13);
	END IF;
	
	IF p_emp_name IS NOT null THEN
		vs_query := vs_query || ' and emp_name like ' || '''' || vs_empname || '''' || chr(13);
	END IF;
	
	IF p_job_id IS NOT null THEN
		vs_query := vs_query || ' and job_id = ' || '''' || p_job_id || '''' || chr(13);
	END IF;
	
	EXECUTE IMMEDIATE vs_query INTO vn_cnt;

	dbms_output.put_line('결과건수: ' || vn_cnt);
	dbms_output.put_line(vs_query);
END;

BEGIN 
	ch17_dynamic_test(171, NULL, null);
END;

BEGIN 
	ch17_dynamic_test(null, 'Jon', null);
END;

BEGIN 
	ch17_dynamic_test(null, null, 'SA_REP');
END;

BEGIN 
	ch17_dynamic_test(null, 'Jon', 'SA_REP');
END;

 -- 동적 쿼리 디버깅용 테이블
CREATE TABLE ch17_dyquery(
	program_name varchar2(50),
	query_text clob
);

CREATE OR REPLACE PROCEDURE ch17_dynamic_test (
	p_emp_id NUMBER,
	p_emp_name varchar2,
	p_job_id varchar2
)
IS 
	vs_query varchar2(1000);
	vn_cnt NUMBER := 0;
	vs_empname employees.emp_name%TYPE := '%' || p_emp_name || '%';
BEGIN 
	vs_query := 'select count(*) ' || chr(13);
	vs_query := vs_query || ' from employees ' || chr(13);
	vs_query := vs_query || ' where 1=1 ' || chr(13);

	IF p_emp_id IS NOT NULL THEN
		vs_query := vs_query || ' and employee_id = ' || p_emp_id || chr(13);
	END IF;
	
	IF p_emp_name IS NOT null THEN
		vs_query := vs_query || ' and emp_name like ' || '''' || vs_empname || '''' || chr(13);
	END IF;
	
	IF p_job_id IS NOT null THEN
		vs_query := vs_query || ' and job_id = ' || '''' || p_job_id || '''' || chr(13);
	END IF;
	
	EXECUTE IMMEDIATE vs_query INTO vn_cnt;

	dbms_output.put_line('결과건수: ' || vn_cnt);
	
	DELETE ch17_dyquery;

	INSERT INTO ch17_dyquery (program_name, query_text)
	VALUES ('ch17_dynamic_test', vs_query);

	COMMIT;
END;

BEGIN 
	ch17_dynamic_test(null, 'Jon', 'SA_REP');
END;

SELECT * FROM ch17_dyquery ;
SELECT * FROM EMPLOYEES ;

 -- 사원의 급여을 갱신하는 프로시저
CREATE OR REPLACE PROCEDURE ch17_upd_test_prc (
	pn_emp_id NUMBER,
	pn_rate number
)
IS 
	vn_salary NUMBER := 0;
BEGIN 
	UPDATE EMPLOYEES 
	SET salary = salary * pn_rate * 0.01
	WHERE employee_id = pn_emp_id;

	SELECT salary
	INTO vn_salary
	FROM employees
	WHERE employee_id = pn_emp_id; 

	dbms_output.put_line('사번: ' || pn_emp_id);
	dbms_output.put_line('급여: ' || vn_salary);

	COMMIT;
END;

BEGIN 
	ch17_upd_test_prc(171, 10);
END;

 -- RETURNING INTO 절 - 단일 로우 UPDATE
DECLARE 
	vn_salary NUMBER := 0;
	vs_empname varchar2(30);
BEGIN 
	UPDATE EMPLOYEES 
	SET salary = 10000
	WHERE employee_id = 171
	returning emp_name, salary 
	INTO vs_empname, vn_salary;

	COMMIT;

	dbms_output.put_line('변경 사원명: ' || vs_empname);
	dbms_output.put_line('변경 급여: ' || vn_salary);
END;

 -- RETURNING INTO 절 - 다중 로우 UPDATE
DECLARE 
	TYPE NT_EMP_REC IS RECORD (
		emp_name employees.emp_name%TYPE,
		department_id employees.department_id%TYPE,
		retire_date employees.retire_date%type
	);

 	 -- NT_EMP_REC 레코드를 요소로 하는 중첩 테이블
	TYPE NTT_EMP IS TABLE OF NT_EMP_REC;

	VR_EMP NTT_EMP;
BEGIN 
	UPDATE EMPLOYEES 
	SET retire_date = sysdate 
	WHERE department_id = 100
	returning emp_name, department_id, retire_date
	BULK COLLECT INTO VR_EMP;

	COMMIT;

	FOR i IN VR_EMP.FIRST..VR_EMP.LAST
	LOOP
		dbms_output.put_line(i || '-----------------------------');
		dbms_output.put_line('변경 사원명: ' || VR_EMP(i).emp_name);
		dbms_output.put_line('변경 부서: ' || VR_EMP(i).department_id);
		dbms_output.put_line('retire_date: ' || VR_EMP(i).retire_date);
	END LOOP;
END;

SELECT * FROM EMPLOYEES ;

 -- RETURNING INTO 절 - 단일 로우 DELETE
 -- 사원 테이블을 복사한 emp_bk 테이블
CREATE TABLE emp_bk AS 
SELECT *
FROM EMPLOYEES 
;

SELECT * FROM emp_bk WHERE department_id = 60 ;

DECLARE 
	vn_salary NUMBER := 0;
	vs_empname varchar2(30);
BEGIN 
	DELETE emp_bk
	WHERE employee_id = 171
	returning emp_name, salary
	INTO vs_empname, vn_salary;

	COMMIT;

	dbms_output.put_line('삭제 사원명: ' || vs_empname);
	dbms_output.put_line('삭제 급여: ' || vn_salary);
END;

 -- 다중 로우 DELETE
DECLARE 
	TYPE NT_EMP_REC IS RECORD (
		emp_name employees.emp_name%TYPE,
		department_id employees.department_id%TYPE,
		job_id employees.job_id%type
	);

 	 -- NT_EMP_REC 레코드를 요소로 하는 중첩 테이블
	TYPE NTT_EMP IS TABLE OF NT_EMP_REC;

	VR_EMP NTT_EMP;
BEGIN 
	DELETE emp_bk
	WHERE department_id = 60
	returning emp_name, department_id, job_id
	BULK COLLECT INTO VR_EMP;

	COMMIT;

	FOR i IN VR_EMP.FIRST..VR_EMP.LAST
	LOOP
		dbms_output.put_line(i || '-----------------------------');
		dbms_output.put_line('변경 사원명: ' || VR_EMP(i).emp_name);
		dbms_output.put_line('변경 부서: ' || VR_EMP(i).department_id);
		dbms_output.put_line('job_id: ' || VR_EMP(i).job_id);
	END LOOP;
END;


 -- 230607
SELECT * FROM USER_DEPENDENCIES WHERE REFERENCED_TYPE = 'TABLE' AND REFERENCED_NAME = 'EMPLOYEES' ;

 -- Self-Check 3
CREATE OR REPLACE PROCEDURE log_proc (
	ps_flag IN varchar2,
	ps_prog_nm IN varchar2,
	ps_parameters IN varchar2,
	pn_log_id IN NUMBER,
	ps_prg_log IN varchar2
)
IS
	vs_prg_log varchar2(2000);
BEGIN 
	dbms_output.put_line('pn_log_id: ' || pn_log_id);
	dbms_output.put_line('ps_prog_nm: ' || ps_prog_nm);
	dbms_output.put_line('ps_parameters: ' || ps_parameters);

	case 
		WHEN ps_flag = 'I' THEN 
			dbms_output.put_line('INSERT');
		
			INSERT INTO program_log (
				LOG_ID,
				PROGRAM_NAME,
				PARAMETERS,
				STATE,
				START_TIME
			)
			VALUES (
				pn_log_id,
				ps_prog_nm,
				ps_parameters,
				'Running',
				systimestamp
			);
		WHEN ps_flag = 'U' THEN 
			dbms_output.put_line('UPDATE');

			UPDATE program_log
			SET state = 'Completed',
				end_time = SYSTIMESTAMP,
				log_desc = ps_prg_log || '작업종료!'
			WHERE log_id = pn_log_id;
		
			COMMIT;
	END case;

	COMMIT;

EXCEPTION WHEN OTHERS THEN 
	BEGIN 
		vs_prg_log := sqlerrm;
		
		UPDATE program_log
		SET state = 'Error',
			end_time = SYSTIMESTAMP,
			log_desc = vs_prg_log || ' (log_proc 프로시저 실행 오류)'
		WHERE log_id = pn_log_id;
	
		COMMIT;
	END;
	ROLLBACK;
END;

 -- Self-Check 4
CREATE OR REPLACE PACKAGE BODY ch17_src_test_pkg IS 

	PROCEDURE sales_detail_prc(
		ps_month IN varchar2,	-- 월
		pn_amt IN NUMBER,		-- 금액
		pn_rate IN NUMBER		-- 할인률
	)
	IS 
		vn_total_time NUMBER := 0;
	
		vn_log_id NUMBER;
		vs_parameters varchar2(500);
		vs_prg_log varchar2(2000);
	BEGIN 
		vn_log_id := prg_log_seq.nextval;
		vs_parameters := 'ps_month => ' || ps_month || ', pn_amt => ' || pn_amt || ' , pn_rate => ' || pn_rate;
	
		BEGIN 
			log_proc('I', 'CH17_SRC_TEST_PKG.sales_detail_prc', vs_parameters, vn_log_id, null);
		END;
		dbms_output.put_line('111');
		 -- 1. ps_month에 해당하는 월의 ch17_sales_detail 데이터 삭제
		vn_total_time := dbms_utility.get_time;
	
		DELETE ch17_sales_detail
		WHERE sales_month = ps_month;
	
		vn_total_time := (dbms_utility.get_time - vn_total_time) / 100;
	
		vs_prg_log := 'DELETE 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time || chr(13);
	
		 -- 2. ps_month에 해당하는 월의 ch17_sales_detail 데이터 생성
		vn_total_time := dbms_utility.get_time;
	
		INSERT INTO ch17_sales_detail
		SELECT b.prod_name,
			   d.channel_desc,
			   c.cust_name,
			   e.emp_name,
			   a.sales_date,
			   a.sales_month,
			   SUM(a.quantity_sold) ,
			   SUM(a.amount_sold) 
		FROM SALES a,
			 PRODUCTS b,
			 CUSTOMERS c,
			 CHANNELS d,
			 EMPLOYEES e
		WHERE a.sales_month = ps_month
		AND   a.prod_id = b.prod_id
		AND   a.cust_id = c.cust_id
		AND   a.channel_id = d.channel_id
		AND   a.employee_id = e.employee_id
		GROUP BY b.prod_name,
			   	 d.channel_desc,
			     c.cust_name,
			     e.emp_name,
			     a.sales_date,
			     a.sales_month;
			    
		vn_total_time := (dbms_utility.get_time - vn_total_time) / 100;
		dbms_output.put_line('222');
		vs_prg_log := vs_prg_log || 'INSERT 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time || chr(13);
			    
		 -- 3. 판매금액(sales_amt)이 pn_amt보다 큰 건은 pn_rate 비율만큼 할인
		vn_total_time := dbms_utility.get_time;
	
		UPDATE ch17_sales_detail
		SET sales_amt = sales_amt - (sales_amt * pn_rate * 0.01)
		WHERE sales_month = ps_month
		AND sales_amt > pn_amt;
	
		vn_total_time := (dbms_utility.get_time - vn_total_time) / 100;
		
		vs_prg_log := vs_prg_log || 'UPDATE 건수: ' || SQL%rowcount || ' , 소요 시간: ' || vn_total_time || chr(13);
	
		COMMIT;
	
		BEGIN 
			log_proc('U', null, NULL, vn_log_id, vs_prg_log);
		END;
	
		EXCEPTION WHEN OTHERS THEN 
			BEGIN 
				vs_prg_log := sqlerrm;
			
				UPDATE program_log
				SET state = 'Error',
					end_time = SYSTIMESTAMP,
					log_desc = vs_prg_log
				WHERE log_id = vn_log_id;
			
				COMMIT;
			END;
			ROLLBACK;
	
	END sales_detail_prc;
END ch17_src_test_pkg;

BEGIN 
	ch17_src_test_pkg.sales_detail_prc(
		ps_month => '200112',
		pn_amt => 50,
		pn_rate => 32.5
	);
END;

SELECT * FROM PROGRAM_LOG pl ORDER BY log_id DESC ;

SELECT * FROM CH17_SALES_DETAIL csd WHERE sales_month = '200112' ;


 -- 230609
 -- 메일 전송 전 사전준비
 -- 1. ACL 등록 및 권한 할당
BEGIN 
	dbms_network_acl_admin.create_acl(
		acl => 'my_mail.xml',
		description => '메일전송용 ACL',
		principal => 'ORA_USER',
		is_grant => TRUE,
		privilege => 'connect'
	);

	COMMIT;
END;

 -- 2. 권한 등록
BEGIN 
	dbms_network_acl_admin.add_privilege(
		acl => 'my_mail.xml',
		principal => 'ORA_USER',
		is_grant => TRUE,
		privilege => 'resolve'
	);

	COMMIT;
END;

 -- 3. ACL과 호스트명 연결
BEGIN 
	dbms_network_acl_admin.assign_acl(
		acl => 'my_mail.xml',
		host => 'localhost',
		lower_port => 25
	);

	COMMIT;
END;

SELECT * FROM DBA_NETWORK_ACLS ;

 -- 한글 메일 테스트
DECLARE 
	vv_host varchar2(30) := 'localhost';	-- SMTP 서버명
	vn_port NUMBER := 25;	-- 포트번호
	vv_domain varchar2(30) := 'hbchoi.mydns.jp';

	vv_from varchar2(50) := 'hbchoi@hbchoi.mydns.jp';	-- 보내는 주소
	vv_to varchar2(50) := 'hbchoi@hbchoi.mydns.jp';		-- 받는 주소
	
	c utl_smtp.CONNECTION;	-- SMTP 서버 연결 객체
BEGIN 
	c := utl_smtp.open_connection(vv_host, vn_port);	-- SMTP 서버와 연결
	
	utl_smtp.helo(c, vv_domain);	-- HELO
	utl_smtp.mail(c, vv_from);		-- 보내는 사람
	utl_smtp.rcpt(c, vv_to);		-- 받는 사람
	
	utl_smtp.open_data(c);	-- 메일 본문 작성 시작
	utl_smtp.write_data(c, 'From: ' || '"choi2" <hbchoi@hbchoi.mydns.jp>' || utl_tcp.crlf);	-- 보내는 사람
	utl_smtp.write_data(c, 'To: ' || '"choi1" <hbchoi@hbchoi.mydns.jp>' || utl_tcp.crlf);	-- 받는 사람

	utl_smtp.write_data(c, 'Subject: Test' || utl_tcp.crlf);	-- 제목
	utl_smtp.write_data(c, utl_tcp.crlf);	-- 한 줄 띄우기
	utl_smtp.write_raw_data(c, utl_raw.CAST_to_raw('한글 메일 테스트' || utl_tcp.crlf));	-- 본문
	
	utl_smtp.close_data(c);

	 -- 종료
	utl_smtp.quit(c);

EXCEPTION 
WHEN utl_smtp.invalid_operation THEN 
	 -- UTL_SMTP를 사용하는 메일에서 잘못된 작업입니다.
	dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
WHEN utl_smtp.transient_error THEN 
	-- 일시적인 전자 메일 문제 - 다시 시도
	dbms_output.put_line(' Temporary e-mail issue - try again');
	utl_smtp.quit(c);
WHEN utl_smtp.permanent_error THEN 
	 -- 영구 오류 발생
	dbms_output.put_line(' Permanent Error Encountered.');
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
END;

select '홍길동', utl_raw.CAST_to_raw('한글 메일 테스트') from dual;
select UTL_RAW.CAST_TO_VARCHAR2('C8ABB1E6B5BF') from dual;

 -- 보낸 사람, 받는 사람, 제목을 한글로 작성하기
DECLARE 
	vv_host varchar2(30) := 'localhost';	-- SMTP 서버명
	vn_port NUMBER := 25;	-- 포트번호
	vv_domain varchar2(30) := 'hbchoi.mydns.jp';
	vv_from varchar2(50) := 'hbchoi@hbchoi.mydns.jp';	-- 보내는 주소
	vv_to varchar2(50) := 'hbchoi@hbchoi.mydns.jp';		-- 받는 주소
	
	c utl_smtp.CONNECTION;	-- SMTP 서버 연결 객체
BEGIN 
	c := utl_smtp.open_connection(vv_host, vn_port);	-- SMTP 서버와 연결
	
	utl_smtp.helo(c, vv_domain);	-- HELO
	utl_smtp.mail(c, vv_from);		-- 보내는 사람
	utl_smtp.rcpt(c, vv_to);		-- 받는 사람
	
	utl_smtp.open_data(c);	-- 메일 본문 작성 시작
	
	vv_text := 'From: ' || '"홍길동" <hbchoi@hbchoi.mydns.jp>' || utl_tcp.crlf;	-- 보내는 사람
	vv_text := vv_text || 'To: ' || '"홍길동" <hbchoi@hbchoi.mydns.jp>' || utl_tcp.crlf;	-- 받는 사람
	vv_text := vv_text || 'Subject: 한글제목' || utl_tcp.crlf;	-- 제목
	vv_text := vv_text || utl_tcp.crlf;	-- 한 줄 띄우기
	vv_text := vv_text || '한글 메일 테스트' || utl_tcp.crlf;	-- 본문
	
	utl_smtp.write_raw_data(c, utl_raw.cast_to_raw(vv_text));
	
	utl_smtp.close_data(c);
	utl_smtp.quit(c);

EXCEPTION 
WHEN utl_smtp.invalid_operation THEN 
	 -- UTL_SMTP를 사용하는 메일에서 잘못된 작업입니다.
	dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
WHEN utl_smtp.transient_error THEN 
	-- 일시적인 전자 메일 문제 - 다시 시도
	dbms_output.put_line(' Temporary e-mail issue - try again');
	utl_smtp.quit(c);
WHEN utl_smtp.permanent_error THEN 
	 -- 영구 오류 발생
	dbms_output.put_line(' Permanent Error Encountered.');
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
END;

select * from nls_database_parameters where parameter = 'NLS_CHARACTERSET';

 -- HTML 메일 보내기
DECLARE 
	vv_host varchar2(30) := 'localhost';				-- SMTP 서버명
	vn_port NUMBER := 25;								-- 포트번호
	vv_domain varchar2(30) := 'hbchoi.mydns.jp';
	vv_from varchar2(50) := 'hbchoi@hbchoi.mydns.jp';	-- 보내는 주소
	vv_to varchar2(50) := 'hbchoi@hbchoi.mydns.jp';		-- 받는 주소
	
	c utl_smtp.CONNECTION;	-- SMTP 서버 연결 객체
	vv_html varchar2(200);	-- HTML 메시지를 담을 변수
BEGIN 
	c := utl_smtp.open_connection(vv_host, vn_port);	-- SMTP 서버와 연결
	
	utl_smtp.helo(c, vv_domain);	-- HELO
	utl_smtp.mail(c, vv_from);		-- 보내는 사람
	utl_smtp.rcpt(c, vv_to);		-- 받는 사람
	
	utl_smtp.open_data(c);	-- 메일 본문 작성 시작
	
	utl_smtp.write_data(c, 'MIME-Version: 1.0' || utl_tcp.crlf);	-- MIME 버전
	utl_smtp.write_data(c, 'Content-Type: text/html; charset="euc-kr"' || utl_tcp.crlf);
	
	utl_smtp.write_raw_data(c, utl_raw.CAST_to_raw('From: ' || '"홍길동" <hbchoi@hbchoi.mydns.jp>' || utl_tcp.crlf) );	-- 보내는 사람
	utl_smtp.write_raw_data(c, utl_raw.CAST_to_raw('To: ' || '"홍길동" <hbchoi@hbchoi.mydns.jp>' || utl_tcp.crlf) );	-- 받는 사람
	utl_smtp.write_raw_data(c, utl_raw.CAST_to_raw('Subject: HTML 테스트 메일' || utl_tcp.crlf) );	-- 제목
	utl_smtp.write_data(c, utl_tcp.crlf);	-- 한 줄 띄우기

	 -- HTML 본문을 작성
	vv_html := '<HEAD>
	<TITLE>HTML 테스트</TITLE>
	</HEAD>
	<BODY>
	<p>이 메일은 <b>HTML</b><i>버전</i>으로</p>
	<p>작성된 <strong>메일</strong>입니다. </p>
	</BODY>
	</HTML>';

	 -- 메일 본문
	utl_smtp.write_raw_data(c, utl_raw.CAST_to_raw(vv_html || utl_tcp.crlf));
	
	utl_smtp.close_data(c);
	utl_smtp.quit(c);

EXCEPTION 
WHEN utl_smtp.invalid_operation THEN 
	 -- UTL_SMTP를 사용하는 메일에서 잘못된 작업입니다.
	dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
WHEN utl_smtp.transient_error THEN 
	-- 일시적인 전자 메일 문제 - 다시 시도
	dbms_output.put_line(' Temporary e-mail issue - try again');
	utl_smtp.quit(c);
WHEN utl_smtp.permanent_error THEN 
	 -- 영구 오류 발생
	dbms_output.put_line(' Permanent Error Encountered.');
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
END;

 -- 첨부파일 보내기
 -- 세팅
CREATE OR REPLACE directory smtp_file AS 'C:\ch18_file';

 -- 매개변수로 디렉토리와 파일명을 받아, 이 파일을 읽어 RAW 타입으로 반환하는 함수
CREATE OR REPLACE FUNCTION fn_get_raw_file(
	p_dir varchar2,
	p_file varchar2
)
	RETURN raw 
IS 
	vf_buffer raw(32767);
	vf_raw	  raw(32767);
	vf_type UTL_FILE.FILE_TYPE;
BEGIN 
	vf_type := UTL_FILE.fopen(p_dir, p_file, 'rb');

	IF UTL_FILE.is_open(vf_type) THEN 
		LOOP
		BEGIN 
			dbms_output.put_line('get_raw 타기 전 vf_buffer: ' || vf_buffer);
			UTL_FILE.get_raw(vf_type, vf_buffer, 32767);
			dbms_output.put_line('get_raw 타고 나서 vf_buffer: ' || vf_buffer);
			vf_raw := vf_raw || vf_buffer;
		
		EXCEPTION 
			WHEN no_data_found THEN 
				EXIT;
			WHEN OTHERS THEN 
				dbms_output.put_line('fn_get_raw_file 함수 -> others 에러');
				dbms_output.put_line('sqlerrm: ' || sqlerrm);
				EXIT;
		END;
		END LOOP;
	END IF;

	UTL_FILE.fclose(vf_type);
	RETURN vf_raw;
END;


 -- 230619
 -- 파일을 첨부해 메일 전송
DECLARE 
	vv_host 	varchar2(30) := 'localhost';				-- SMTP 서버명
	vn_port 	NUMBER := 25;								-- 포트번호
	vv_domain 	varchar2(30) := 'hbchoi.mydns.jp';
	vv_from 	varchar2(50) := 'hbchoi@hbchoi.mydns.jp';	-- 보내는 주소
	vv_to 		varchar2(50) := 'hbchoi@hbchoi.mydns.jp';	-- 받는 주소
	
	c			utl_smtp.CONNECTION;
	vv_html		varchar2(200);	-- HTML 메시지를 담을 변수
	
	 -- boundary 표시를 위한 변수
	vv_boundary varchar2(50) := 'DIFOJSLKDFO.WEFOWJFOWE';

	vv_directory varchar2(30) := 'SMTP_FILE';			-- 파일이 있는 디렉토리명
	vv_filename	 varchar2(30) := 'ch18_txt_file.txt';	-- 파일명
	vf_file_buff raw(32767);	-- 실제 파일을 담을 RAW타입 변수
	vf_temp_buff raw(54);		-- 메일에 파일을 한 줄씩 쓸때 사용할 RAW타입 변수
	vn_file_len  NUMBER := 0;	-- 파일 길이
	
	 -- 한 줄당 올 수 있는 BASE64 변환된 데이터 최대 길이
	vn_base64_max_len NUMBER := 54;	-- 76 * (3/4);
	vn_pos			  NUMBER := 1;	-- 파일 위치를 담는 변수
	
	 -- 파일을 한 줄씩 자를 때 사용할 단위 바이트 수
	vn_divide NUMBER := 0;
BEGIN 
	c := utl_smtp.open_connection(vv_host, vn_port);

	utl_smtp.helo(c, vv_domain);	-- HELO
	utl_smtp.mail(c, vv_from);		-- 보내는 사람
	utl_smtp.rcpt(c, vv_to);		-- 받는 사람
	
	utl_smtp.open_data(c);	-- 메일 본문 작성 시작
	utl_smtp.write_data(c, 'MIME-Version: 1.0' || utl_tcp.crlf);	-- MIME 버전
	utl_smtp.write_data(c, 'Content-Type: multipart/mixed; boundary="' 
						|| vv_boundary || '"' || utl_tcp.crlf);
	
	utl_smtp.write_raw_data(c, utl_raw.cast_to_raw('From: ' || '"홍길동" 
							<hbchoi@hbchoi.mydns.jp>' || utl_tcp.crlf));
	utl_smtp.write_raw_data(c, utl_raw.cast_to_raw('To: ' || '"홍길동" 
							<hbchoi@hbchoi.mydns.jp>' || utl_tcp.crlf));
	utl_smtp.write_raw_data(c, utl_raw.cast_to_raw('Subject: HTML 첨부파일 테스트' || utl_tcp.crlf));
	utl_smtp.write_data(c, utl_tcp.crlf);

	 -- HTML 본문 작성
	vv_html := '<HEAD>
	<TITLE>HTML 테스트</TITLE>
	</HEAD>
	<BODY>
	<p>이 메일은 <b>HTML</b><i>버전</i>으로</p>
	<p>첨부파일까지 들어간 <strong>메일</strong>입니다. </p>
	</BODY>
	</HTML>';

	 -- 메일 본문
	utl_smtp.write_data(c, '--' || vv_boundary || utl_tcp.crlf);
	utl_smtp.write_data(c, 'Content-Type: text/html;' || utl_tcp.crlf);
	utl_smtp.write_data(c, 'charset=euc-kr' || utl_tcp.crlf);
	utl_smtp.write_data(c, utl_tcp.crlf);
	utl_smtp.write_raw_data(c, utl_raw.cast_to_raw(vv_html || utl_tcp.crlf));
	utl_smtp.write_data(c, utl_tcp.crlf);

	-- 첨부파일 추가
	utl_smtp.write_data(c, '--' || vv_boundary || utl_tcp.crlf);
	utl_smtp.write_data(c, 'Content-Type: application/octet-stream; name="' || vv_filename || '"' || utl_tcp.crlf);
	utl_smtp.write_data(c, 'Content-Transfer-Encoding: base64' || utl_tcp.crlf);
	utl_smtp.write_data(c, 'Content-Disposition: attachment; filename="' || vv_filename || '"' || utl_tcp.crlf);
	utl_smtp.write_data(c, utl_tcp.crlf);

	vf_file_buff := fn_get_raw_file(vv_directory, vv_filename);
	vn_file_len := dbms_lob.getlength(vf_file_buff);

	IF vn_file_len <= vn_base64_max_len THEN 
		vn_divide := vn_file_len;
	ELSE 
		vn_divide := vn_base64_max_len;
	END IF;

	vn_pos := 0;
	WHILE  vn_pos < vn_file_len
	LOOP
		IF (vn_file_len - vn_pos) >= vn_divide THEN
			vn_divide := vn_divide;
		ELSE 
			vn_divide := vn_file_len - vn_pos;
		END IF;
		
		vf_temp_buff := utl_raw.substr(vf_file_buff, vn_pos, vn_divide);
		utl_smtp.write_raw_data(c, utl_encode.base64_encode(vf_temp_buff));
		utl_smtp.write_data(c, utl_tcp.crlf);
		vn_pos := vn_pos + vn_divide;
	END LOOP;

	utl_smtp.write_data(c, '--' || vv_boundary || '--' || utl_tcp.crlf);

	utl_smtp.close_data(c);
	utl_smtp.quit(c);	-- 메일 세션 종료

EXCEPTION 
WHEN utl_smtp.invalid_operation THEN 
	 -- UTL_SMTP를 사용하는 메일에서 잘못된 작업입니다.
	dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
WHEN utl_smtp.transient_error THEN 
	 -- 일시적인 전자 메일 문제 - 다시 시도
	dbms_output.put_line(' Temporary e-mail issue - try again');
	utl_smtp.quit(c);
WHEN utl_smtp.permanent_error THEN 
	 -- 영구 오류가 발생했습니다.
	dbms_output.put_line(' Permanent Error Encountered.');
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
WHEN OTHERS THEN 
	 -- UTL_SMTP를 사용하는 메일에서 잘못된 작업입니다.
	dbms_output.put_line(sqlerrm);
	utl_smtp.quit(c);
END;


 -- 230620
 -- utl_mail 패키지로 간단한 메일 전송
BEGIN 
	utl_mail.send(
		sender => 'hbchoi@hbchoi.mydns.jp',
		recipients => 'hbchoi@hbchoi.mydns.jp',
		cc => NULL,
		bcc => NULL,
		subject => 'UTL_MAIL 전송 테스트',
		message => 'UTL_MAIL을 이용해 전송하는 메일입니다',
		mime_type => 'text/plain; charset=euc-kr',
		priority => 3,
		replyto => 'hbchoi@hbchoi.mydns.jp'
	);

EXCEPTION WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
END;

 -- HTML 형식의 메일 보내기
DECLARE 
	vv_html varchar2(300);
BEGIN 
	vv_html := '<HEAD>
	<TITLE>HTML 테스트</TITLE>
	</HEAD>
	<BODY>
	<p>이 메일은 <b>HTML</b><i>버전</i>으로</p>
	<p><strong>UTL_MAIL</strong> 패키지를 사용해 보낸 메일입니다. </p>
	</BODY>
	</HTML>';

	utl_mail.send(
		sender => 'hbchoi@hbchoi.mydns.jp',
		recipients => 'hbchoi@hbchoi.mydns.jp',
		cc => NULL,
		bcc => NULL,
		subject => 'UTL_MAIL 전송 테스트2',
		message => vv_html,
		mime_type => 'text/html; charset=euc-kr',
		priority => 1,
		replyto => 'hbchoi@hbchoi.mydns.jp'
	);

EXCEPTION WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
END;

 -- 첨부파일 전송
DECLARE 
	vv_directory varchar2(30) := 'SMTP_FILE';			-- 파일이 있는 디렉토리명
	vv_filename	 varchar2(30) := 'ch18_txt_file.txt';	-- 파일명 (jpg는 안되는걸로 보임)
	vf_file_buff raw(32767);							-- 실제 파일을 담을 RAW타입 변수
	vv_html varchar2(300);
BEGIN 
	vv_html := '<HEAD>
	<TITLE>HTML 테스트</TITLE>
	</HEAD>
	<BODY>
	<p>이 메일은 <b>HTML</b><i>버전</i>으로</p>
	<p><strong>UTL_MAIL</strong> 패키지를 사용해 보낸 메일입니다. </p>
	</BODY>
	</HTML>';

	 -- 파일 읽어오기
	vf_file_buff := fn_get_raw_file(vv_directory, vv_filename);

	utl_mail.send_attach_raw(
		sender => 'hbchoi@hbchoi.mydns.jp',
		recipients => 'hbchoi@hbchoi.mydns.jp',
		cc => NULL,
		bcc => NULL,
		subject => 'UTL_MAIL 파일전송 테스트',
		message => vv_html,
		mime_type => 'text/html; charset=euc-kr',
		priority => 1,
		attachment => vf_file_buff,
		att_inline => true,
		att_mime_type => 'application/octet',
		att_filename => vv_filename,
		replyto => 'hbchoi@hbchoi.mydns.jp'
	);

EXCEPTION WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
END;


 -- 230621
 -- dbms_crypto 패키지를 사용해 문자열 데이터를 암호화/복호화
DECLARE 
	input_string varchar2(200) := 'The Oracle';	-- 암호화할 VARCHAR2 데이터
	output_string varchar2(200);				-- 복호화된 VARCHAR2 데이터
	
	encrypted_raw raw(2000);	-- 암호화된 데이터
	decrypted_raw raw(2000);	-- 복호화할 데이터
	
	num_key_bytes NUMBER := 256/8;	-- 암호화 키를 만들 길이 (256비트, 32바이트)
	key_bytes_raw raw(32);			-- 암호화 키
	
	 -- 암호화 슈트
	encryption_type pls_integer;
BEGIN 
	 -- 암호화 슈트 설정
	encryption_type := dbms_crypto.encrypt_aes256 + -- 256비트 키를 사용한 AES 암호화
					   dbms_crypto.chain_cbc + 		-- CBC 모드
					   dbms_crypto.PAD_pkcs5;		-- PKCS5로 이루어진 패딩
					   
	dbms_output.put_line('원본 문자열: ' || input_string);

	 -- RANDOMBYTES 함수를 사용해 암호화 키 생성
	key_bytes_raw := dbms_crypto.RANDOMBYTES(num_key_bytes);

	 -- ENCRYPT 함수로 암호화를 한다. 원본 문자열을 UTL_I18N.string_to_raw를 사용해 RAW 타입으로 변환한다.
	encrypted_raw := dbms_crypto.ENCRYPT(src => UTL_I18N.string_to_raw(input_string, 'AL32UTF8'),
										 typ => encryption_type,
										 KEY => key_bytes_raw
										);
									
	 -- 암호화된 RAW 데이터를 출력
	dbms_output.put_line('암호화된 RAW 데이터: ' || encrypted_raw);

	 -- 암호화 한 데이터를 다시 복호화(암호화했던 키와 암호화 슈트는 동일하게 사용해야 한다.)
	decrypted_raw := dbms_crypto.decrypt(src => encrypted_raw,
										 typ => encryption_type,
										 KEY => key_bytes_raw
										);
									
	dbms_output.put_line('decrypted_raw: ' || decrypted_raw);
									
	 -- 복호화된 RAW 타입 데이터를 UTL_I18N.raw_to_char를 사용해 다시 VARCHAR2로 변환
	output_string := UTL_I18N.raw_to_char(decrypted_raw, 'AL32UTF8');

	 -- 복호화된 문자열 출력
	dbms_output.put_line('복호화된 문자열: ' || output_string);
END;


 -- 230622
 -- 단방향 암호화 해시 함수
DECLARE 
	input_string varchar2(200) := 'The Oracle';	-- 입력 VARCHAR2 데이터
	input_raw 	 raw(128);	-- 입력 RAW 데이터
	
	encrypted_raw raw(2000);	-- 암호화 데이터
	
	key_string varchar2(8) := 'secret';	-- MAC 함수에서 사용할 비밀 키
	
	 -- 비밀키를 RAW 타입으로 변환
	raw_key raw(128) := utl_raw.cast_to_raw(CONVERT(key_string, 'AL32UTF8', 'US7ASCII'));
BEGIN 
	 -- VARCHAR2를 RAW 타입으로 변환
	input_raw := UTL_I18N.string_to_raw(input_string, 'AL32UTF8');

	dbms_output.put_line('------------ HASH 함수 ------------');
	encrypted_raw := dbms_crypto.hash(src => input_raw,
									  typ => dbms_crypto.hash_sh1);
									 
	dbms_output.put_line('입력 문자열의 해시값: ' || rawtohex(encrypted_raw));

	dbms_output.put_line('------------ MAC 함수 ------------');
	encrypted_raw := dbms_crypto.mac(src => input_raw,
									 typ => dbms_crypto.hmac_md5,
									 KEY => raw_key);
									
	dbms_output.put_line('MAC 값: ' || rawtohex(encrypted_raw));
END;

 -- 안전한 암호화 키 관리 방법
DECLARE 
	vv_ddl varchar2(1000);	-- 패키지 소스를 저장하는 변수
BEGIN 
	 -- 패키지 소스를 vv_ddl에 설정
	vv_ddl := 'create or replace package ch19_wrap_pkg is 
			   pv_key_string varchar2(30) := ''OracleKey''; end ch19_wrap_pkg;';
			  
	 -- CREATE_WRAPPED 프로시저를 사용하면 패키지 소스를 숨기는 것과 동시에 컴파일도 수행한다.
	dbms_ddl.CREATE_WRAPPED(vv_ddl);

EXCEPTION WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
END;

BEGIN 
	dbms_output.put_line(ch19_wrap_pkg.pv_key_string);
END;

 -- 나만의 유틸리티 프로그램
CREATE OR REPLACE PACKAGE my_util_pkg IS 
	 -- 1. 프로그램 소스 검색 프로시저
	PROCEDURE program_search_prc(ps_src_text IN varchar2);

	 -- 2. 객체 검색 프로시저
	PROCEDURE object_search_prc(ps_obj_name IN varchar2);

	 -- 3. 테이블 Layout 출력
	PROCEDURE table_layout_prc(ps_table_name IN varchar2);

	 -- 4. 컬럼 값을 세로로 출력
	PROCEDURE print_col_value_prc(ps_query IN varchar2);

	 -- 이메일 전송과 관련된 패키지 상수
	pv_host varchar2(10)   := 'localhost';			-- SMTP 서버명
	pn_port NUMBER 		   := 25;					-- 포트번호
	pv_domain varchar2(30) := 'hbchoi.mydns.jp';	-- 도메인명
	
	pv_boundary varchar2(50)  := 'DIF0JSLKDWFEF0.WEF0WJF0WE';	-- boundary text
	pv_directory varchar2(50) := 'SMTP_FILE';	-- 파일이 있는 디렉토리명
	
	 -- 5. 이메일 전송
	PROCEDURE email_send_prc(
		ps_from    IN varchar2,
		ps_to 	   IN varchar2,
		ps_subject IN varchar2,
		ps_body    IN varchar2,
		ps_content IN varchar2 DEFAULT 'text/plain;',	-- 해당 문서를 플레인 텍스트로 만들어, HTML 태그까지 모두 보여주는 데이터 타입
		ps_file_nm IN varchar2
	);

	 -- 6. 비밀번호 생성
	FUNCTION fn_create_pass(ps_input IN varchar2, ps_add IN varchar2)
	RETURN raw;

	 -- 7. 비밀번호 체크
	FUNCTION fn_check_pass(ps_input IN varchar2, ps_add IN varchar2, p_raw IN raw)
	RETURN varchar2;

	 -- 8. 암호화 함수
	FUNCTION fn_encrypt(ps_input_string IN varchar2)
	RETURN raw;

	 -- 9. 복호화 함수
	FUNCTION fn_decrypt(prw_encrypt IN raw)
	RETURN varchar2;
END my_util_pkg;

CREATE OR REPLACE PACKAGE BODY my_util_pkg IS 
	 -- 1. 프로그램 소스 검색 프로시저
	PROCEDURE program_search_prc(ps_src_text IN varchar2)
	IS 
		vs_search varchar2(100);
		vs_name   varchar2(1000);
	BEGIN
		 -- 찾을 키워드 앞뒤에 '%'를 붙인다.
		vs_search := '%' || nvl(ps_src_text, '%') || '%';
		
		 -- dba_source에서 입력된 키워드로 소스를 검색한다.
		 -- 입력 키워드가 대문자 혹은 소문자가 될 수 있으므로 UPPER, LOWER 함수를 이용해 검색한다.
		FOR c_cur IN (
			SELECT name, TYPE, line, text
			FROM user_source
			WHERE text LIKE upper(vs_search)
			OR 	  text LIKE lower(vs_search)
			ORDER BY name, TYPE, line
		)
		LOOP 
			vs_name := c_cur.name || '-' || c_cur.TYPE || '-' || c_cur.line 
						|| ' : ' || REPLACE(c_cur.text, chr(10), '');	-- '\n'를 빈 문자열로 치환
			dbms_output.put_line(vs_name);
		END LOOP;
		
	END program_search_prc;

 	 -- 2. 객체 검색 프로시저
	PROCEDURE object_search_prc(ps_obj_name IN varchar2)
	IS 
		vs_search varchar2(100);
		vs_name   varchar2(1000);
	BEGIN 
		 -- 찾을 키워드 앞뒤에 '%'를 붙인다.
		vs_search := '%' || nvl(ps_obj_name, '%') || '%';
		
		 -- referenced_name 입력된 키워드로 참조 객체를 검색한다.
		FOR c_cur IN (
			SELECT name, TYPE
			FROM USER_DEPENDENCIES 
			WHERE referenced_name LIKE UPPER(vs_search) 
			ORDER BY name, TYPE
		)
		LOOP 
			vs_name := c_cur.name || '-' || c_cur.TYPE;
			dbms_output.put_line(vs_name);
		END LOOP;
	END object_search_prc;

	 -- 3. 테이블 Layout 출력
	PROCEDURE table_layout_prc(ps_table_name IN varchar2)
	IS
		vs_table_name varchar2(50) := upper(ps_table_name);
		vs_owner	  varchar2(50);
		vs_columns	  varchar2(300);
	BEGIN 
		BEGIN 
			 -- 테이블이 있는지 검색
			SELECT owner
			INTO vs_owner
			FROM ALL_TABLES 
			WHERE table_name = vs_table_name;
		 -- 해당 테이블이 없으면 빠져나감
		EXCEPTION WHEN no_data_found THEN 
			dbms_output.put_line(vs_table_name || '라는 테이블이 존재하지 않습니다.');
			RETURN;
		END;
	
		 -- 테이블명 출력
		dbms_output.put_line('---------------------------------------------------');
		dbms_output.put_line('테이블: ' || vs_table_name || ' , 소유자: ' || vs_owner);
		dbms_output.put_line('---------------------------------------------------');
	
		 -- 컬럼 정보 검색 및 출력
		FOR c_cur IN (
			/*SELECT column_name, data_type, data_length, nullable, data_default
			FROM ALL_TAB_COLS 
			WHERE table_name = vs_table_name
			ORDER BY column_id*/
			SELECT 
				  atc.OWNER 
				, atc.column_name
				, atc.data_type
				, atc.data_length
				, atc.nullable
				, atc.data_default
				, ai.INDEX_NAME
			FROM 
				ALL_TAB_COLS atc
			INNER JOIN 
				ALL_INDEXES ai
				ON atc.table_name = ai.table_name
				AND atc.OWNER = ai.OWNER 
			WHERE atc.table_name = UPPER('departments') 
			ORDER BY atc.column_id
		)
		LOOP
			 -- 컬럼 정보를 출력한다.
			vs_columns := rpad(c_cur.column_name, 20) || rpad(c_cur.data_type, 15)
							|| rpad(c_cur.data_length, 5)
							|| rpad(c_cur.nullable, 2) || rpad(nvl(c_cur.data_default, ' '), 10)
							|| rpad(c_cur.INDEX_NAME, 15);
			dbms_output.put_line(vs_columns);
		END LOOP;		
	END table_layout_prc;

	 -- 4. 컬럼 값을 세로로 출력
	PROCEDURE print_col_value_prc(ps_query IN varchar2)
	IS 
		l_theCursor   integer DEFAULT dbms_sql.open_cursor;	-- 커서를 연다
		l_columnValue varchar2(4000);
		l_status	  integer;
		l_descTbl	  dbms_sql.desc_tab;
		l_colCnt	  NUMBER;
	BEGIN 
		 -- 쿼리 구문이 ps_query 매개변수에 들어오므로 이를 파싱한다.
		dbms_sql.parse(l_theCursor, ps_query, dbms_sql.native);
	
		 -- DESCRIBE_column 프로시저: 커서에 대한 컬럼 정보를 DBMS_SQL.DESC_TAB형 변수에 넣는다.
		dbms_sql.DESCRIBE_columns(l_theCursor, l_colCnt, l_descTbl);
	
		 -- 선택된 컬럼 개수만큼 루프를 돌며 DEFINE_COLUMN 프로시저를 호출해 컬럼을 정의한다.
		FOR i IN 1..l_colCnt
		LOOP 
			dbms_sql.DEFINE_COLUMN(l_theCursor, i, l_columnValue, 4000);
		END LOOP;
		
		 -- 실행
		l_status := dbms_sql.execute(l_theCursor);
	
		WHILE ( dbms_sql.fetch_rows(l_theCursor) > 0 )
		LOOP
			FOR i IN 1..l_colCnt
			LOOP
				dbms_sql.column_value(l_theCursor, i, l_columnValue);
				dbms_output.put_line(rpad(l_descTbl(i).col_name, 30) || ': ' || l_columnValue);
			END LOOP;
			dbms_output.put_line('------------------------');
		END LOOP;
		
		dbms_sql.close_cursor(l_theCursor);
	END print_col_value_prc;

	 -- 5. 이메일 전송
	PROCEDURE email_send_prc(
		ps_from    IN varchar2,	-- 보내는 사람
		ps_to 	   IN varchar2,	-- 받는 사람
		ps_subject IN varchar2,	-- 제목
		ps_body    IN varchar2,	-- 본문
		ps_content IN varchar2 DEFAULT 'text/plain;',	-- 해당 문서를 플레인 텍스트로 만들어, HTML 태그까지 모두 보여주는 데이터 타입
		ps_file_nm IN varchar2	-- 첨부파일
	)
	IS
		vc_con utl_smtp.CONNECTION;
	
		v_bfile 	  bfile;		-- 파일을 담을 변수
		vn_bfile_size NUMBER := 0;	-- 파일 크기
		
		v_temp_blob  blob 	:= empty_blob;	-- 파일을 옮겨담을 blob 타입 변수
		vn_blob_size NUMBER := 0;			-- BLOB 변수 크기
		vn_amount 	 NUMBER := 54;			-- 54 단위로 파일을 잘라 메일에 붙이기 위함
		v_tmp_raw 	 raw(54);				-- 54 단위로 자른 파일내용이 담긴 RAW 타입 변수
		vn_pos 		 NUMBER := 1;			-- 파일 위치를 담는 변수
	BEGIN 
		vc_con := utl_smtp.open_connection(pv_host, pn_port);
		utl_smtp.helo(vc_con, pv_domain);	-- HELO
		utl_smtp.mail(vc_con, ps_from);		-- 보내는 사람
		utl_smtp.rcpt(vc_con, ps_to);		-- 받는 사람
		
		utl_smtp.open_data(vc_con);		-- 메일 본문 작성 시작
		utl_smtp.write_data(vc_con, 'MIME-Version: 1.0' || utl_tcp.crlf);	-- MIME 버전
		utl_smtp.write_data(vc_con, 'Content-Type: multipart/mixed; boundary="' 
							|| pv_boundary || '"' || utl_tcp.crlf);
		utl_smtp.write_raw_data(vc_con, utl_raw.cast_to_raw('From: ' || ps_from || utl_tcp.crlf));
		utl_smtp.write_raw_data(vc_con, utl_raw.cast_to_raw('To: ' || ps_to || utl_tcp.crlf));
		utl_smtp.write_raw_data(vc_con, utl_raw.cast_to_raw('Subject: ' || ps_subject || utl_tcp.crlf));
		utl_smtp.write_data(vc_con, utl_tcp.crlf);
	
		 -- 메일 본문
		utl_smtp.write_data(vc_con, '--' || pv_boundary || utl_tcp.crlf);
		utl_smtp.write_data(vc_con, 'Content-Type: ' || ps_content || utl_tcp.crlf);
		utl_smtp.write_data(vc_con, 'charset=euc-kr' || utl_tcp.crlf);
		utl_smtp.write_data(vc_con, utl_tcp.crlf);
		utl_smtp.write_raw_data(vc_con, utl_raw.cast_to_raw(ps_body || utl_tcp.crlf));
		utl_smtp.write_data(vc_con, utl_tcp.crlf);
	
		 -- 첨부파일이 있다면
		IF ps_file_nm IS NOT NULL THEN 
			utl_smtp.write_data(vc_con, '--' || pv_boundary || utl_tcp.crlf);
			utl_smtp.write_data(vc_con, 'Content-Type: application/octet-stream; name ="' 
								|| ps_file_nm || '"' || utl_tcp.crlf);
			utl_smtp.write_data(vc_con, 'Content-Transfer-Encoding: base64' || utl_tcp.crlf);
			utl_smtp.write_data(vc_con, 'Content-Disposition: attachment; filename="' 
								|| ps_file_nm || '"' || utl_tcp.crlf);
			utl_smtp.write_data(vc_con, utl_tcp.crlf);
		
			 -- 파일 처리 시작
			 -- 파일을 읽어 BFILE 변수인 v_bfile에 담는다.
			v_bfile := bfilename(pv_directory, ps_file_nm);
			 -- v_bfile 담은 파일을 읽기 전용으로 연다.
			dbms_lob.open(v_bfile, dbms_lob.lob_readonly);
			 -- v_bfile에 담긴 파일의 크기를 가져온다.
			vn_bfile_size := dbms_lob.getlength(v_bfile);
		
			 -- v_bfile를 BLOB 변수인 v_temp_blob에 담기 위해 초기화
			dbms_lob.createtemporary(v_temp_blob, true);
			 -- v_bfile에 담긴 파일을 v_temp_blob로 옮긴다.
			dbms_lob.loadfromfile(v_temp_blob, v_bfile, vn_bfile_size);
			 -- v_temp_blob의 크기를 구한다.
			vn_blob_size := dbms_lob.getlength(v_temp_blob);
		
			 -- vn_pos 초깃값은 1, v_temp_blob 크기보다 작은 경우 루프
			WHILE vn_pos < vn_blob_size
			LOOP
				-- v_temp_blob에 담긴 파일을 vn_amount(54)씩 잘라 v_tmp_raw에 담는다.
				dbms_lob.read(v_temp_blob, vn_amount, vn_pos, v_tmp_raw);
				 -- 잘라낸 v_tmp_raw를 메일에 첨부한다.
				utl_smtp.write_raw_data(vc_con, utl_encode.base64_encode(v_tmp_raw));
				utl_smtp.write_data(vc_con, utl_tcp.crlf);
			
				v_tmp_raw := NULL;
				vn_pos := vn_pos + vn_amount;
			END LOOP;
			
			dbms_lob.freetemporary(v_temp_blob);	-- v_temp_blob 메모리 해제
			dbms_lob.fileclose(v_bfile);	-- v_bfile 닫기
		END IF;	-- 첨부파일 처리 종료
		
		 -- 맨 마지막 boundary에는 앞과 뒤에 '--'를 반드시 붙여야 한다.
		utl_smtp.write_data(vc_con, '--' || pv_boundary || '--' || utl_tcp.crlf);
	
		utl_smtp.close_data(vc_con);	-- 메일 본문 작성 종료
		utl_smtp.quit(vc_con);			-- 메일 세션 종료
		
	EXCEPTION 
	WHEN utl_smtp.invalid_operation THEN 
		 -- UTL_SMTP를 사용하는 메일에서 잘못된 작업입니다.
		dbms_output.put_line(' Invalid Operation in Mail attempt using UTL_SMTP.');
		dbms_output.put_line(sqlerrm);
		utl_smtp.quit(vc_con);
	WHEN utl_smtp.transient_error THEN 
		 -- 일시적인 전자 메일 문제 - 다시 시도
		dbms_output.put_line(' Temporary e-mail issue - try again');
		utl_smtp.quit(vc_con);
	WHEN utl_smtp.permanent_error THEN 
		 -- 영구 오류가 발생했습니다.
		dbms_output.put_line(' Permanent Error Encountered.');
		dbms_output.put_line(sqlerrm);
		utl_smtp.quit(vc_con);
	WHEN OTHERS THEN 
		dbms_output.put_line(sqlerrm);
		utl_smtp.quit(vc_con);
	END email_send_prc;

	 -- 6. 비밀번호 생성
	FUNCTION fn_create_pass(ps_input IN varchar2, ps_add IN varchar2)
		RETURN raw
	IS 
		v_raw 		   raw(32747);
		v_key_raw 	   raw(32747);
		v_input_string varchar2(100);
	BEGIN 
		 -- 키 값을 가진 ch19_wrap_pkg 패키지의 pv_key_string 상수를 가져와 RAW 타입으로 변환한다.
		v_key_raw := utl_raw.cast_to_raw(ch19_wrap_pkg.pv_key_string);
	
		 -- 좀더 보안을 강화하기 위해 두 개의 입력 매개변수와 특수문자인 $%를 조합해 MAC 함수의 첫번째 매개변수로 넘긴다.
		v_input_string := ps_input || '$%' || ps_add;
	
		 -- MAC 함수를 사용해 입력 문자열을 RAW 타입으로 변환한다.
		v_raw := dbms_crypto.mac(src => utl_raw.cast_to_raw(v_input_string)
								,typ => dbms_crypto.hmac_sh1	-- MD5보다 나은 버전 (MD5: 암호화는 가능하지만, 복호화가 매우 어렵)
								,KEY => v_key_raw);
							
		RETURN v_raw;
	END fn_create_pass;

	 -- 7. 비밀번호 체크
	FUNCTION fn_check_pass(ps_input IN varchar2, ps_add IN varchar2, p_raw IN raw)
		RETURN varchar2
	IS
		v_raw 		   raw(32747);
		v_key_raw 	   raw(32747);
		v_input_string varchar2(100);
	
		v_rtn varchar2(10) := 'N';
	BEGIN 
		 -- 키 값을 가진 ch19_wrap_pkg 패키지의 pv_key_string 상수를 가져와 RAW 타입으로 변환한다.
		v_key_raw := utl_raw.cast_to_raw(ch19_wrap_pkg.pv_key_string);
	
		 -- 좀더 보안을 강화하기 위해 두 개의 입력 매개변수와 특수문자인 $%를 조합해 MAC 함수의 첫번째 매개변수로 넘긴다.
		v_input_string := ps_input || '$%' || ps_add;
	
		 -- MAC 함수를 사용해 입력 문자열을 RAW 타입으로 변환한다.
		v_raw := dbms_crypto.mac(src => utl_raw.cast_to_raw(v_input_string)
								,typ => dbms_crypto.hmac_sh1	-- MD5보다 나은 버전 (MD5: 암호화는 가능하지만, 복호화가 매우 어렵)
								,KEY => v_key_raw);
							
		IF v_raw = p_raw THEN 
			v_rtn := 'Y';
		ELSE 
			v_rtn := 'N';
		END IF;
	
		RETURN v_rtn;
	END fn_check_pass;

	 -- 8. 암호화 함수
	FUNCTION fn_encrypt(ps_input_string IN varchar2)
		RETURN raw
	IS
		encrypted_raw raw(32747);
		v_key_raw raw(32747);			-- 암호화 키
		encryption_type pls_integer;	-- 암호화 슈트
	BEGIN 
		 -- 암호화 키 값을 가져온다.
		v_key_raw := ch19_wrap_pkg.key_bytes_raw;
	
		 -- 암호화 슈트 설정
		encryption_type := dbms_crypto.encrypt_aes256 + -- 256비트 키를 사용한 AES 암호화
						   dbms_crypto.chain_cbc + 		-- CBC 모드
						   dbms_crypto.pad_pkcs5;		-- pkcs5로 이루어진 패딩
						   
		encrypted_raw := dbms_crypto.encrypt(
			src => utl_I18N.string_to_raw(ps_input_string, 'AL32UTF8'),
			typ => encryption_type,
			KEY => v_key_raw
		);
		
		RETURN encrypted_raw;
	END fn_encrypt;

	 -- 9. 복호화 함수
	FUNCTION fn_decrypt(prw_encrypt IN raw)
		RETURN varchar2
	IS
		vs_return varchar2(100);
		v_key_raw raw(32747);			-- 암호화 키
		encryption_type pls_integer;	-- 암호화 슈트
		decrypted_raw raw(2000);		-- 복호화 데이터
	BEGIN 
		 -- 암호화 키 값을 가져온다.
		v_key_raw := ch19_wrap_pkg.key_bytes_raw;
	
		 -- 암호화 슈트 설정
		encryption_type := dbms_crypto.encrypt_aes256 + -- 256비트 키를 사용한 AES 암호화
						   dbms_crypto.chain_cbc + 		-- CBC 모드
						   dbms_crypto.pad_pkcs5;		-- pkcs5로 이루어진 패딩
						   
		decrypted_raw := dbms_crypto.decrypt(
			src => prw_encrypt,
			typ => encryption_type,
			KEY => v_key_raw
		);
	
		vs_return := utl_I18N.raw_to_char(decrypted_raw, 'AL32UTF8');
	
		RETURN vs_return;
	END fn_decrypt;
END my_util_pkg;

BEGIN 
	my_util_pkg.program_search_prc('departments');
END;

SELECT name, TYPE, line, text
FROM user_source
WHERE text LIKE upper('%departments%')
OR 	  text LIKE lower('%departments%')
ORDER BY name, TYPE, line
;

SELECT rpad(' ', 15)
	|| rpad('test2', 15) FROM dual ;

BEGIN 
	my_util_pkg.object_search_prc('departments');
END;

SELECT name, TYPE, referenced_name
FROM USER_DEPENDENCIES 
WHERE referenced_name LIKE UPPER('departments') 
ORDER BY name, TYPE
;

BEGIN 
	my_util_pkg.table_layout_prc('departments');
END;

SELECT 
	  atc.OWNER 
	, atc.column_name
	, atc.data_type
	, atc.data_length
	, atc.nullable
	, atc.data_default
	, ai.INDEX_NAME
FROM 
	ALL_TAB_COLS atc
INNER JOIN 
	ALL_INDEXES ai
	ON atc.table_name = ai.table_name
	AND atc.OWNER = ai.OWNER 
WHERE atc.table_name = UPPER('departments') 
AND atc.OWNER = 'ORA_USER'
ORDER BY atc.column_id
;

SELECT * FROM ALL_INDEXES ;

SELECT column_name, data_type, data_length, nullable, data_default
FROM ALL_TAB_COLS 
WHERE table_name = UPPER('departments') 
ORDER BY column_id
;

SELECT owner
FROM ALL_TABLES 
WHERE table_name = UPPER('departments') ;


 -- 230625
BEGIN 
	my_util_pkg.print_col_value_prc('select * from departments where rownum < 3');
END;

 -- 메일 전송
DECLARE 
	vv_html varchar2(1000);
BEGIN 
	vv_html := '<HTML><HEAD>
	<TITLE>HTML 테스트</TITLE>
	</HEAD>
	<BODY>
	<p>이 메일은 <b>HTML</b><i>버전</i>으로</p>
	<p><strong>my_util_pkg</strong> 패키지의 email_send_prc 프로시저를 사용해 보낸 메일입니다. </p>
	</BODY>
	</HTML>';

	 -- 이메일 전송
	my_util_pkg.email_send_prc(
		ps_from    => 'hbchoi@hbchoi.mydns.jp',
		ps_to 	   => 'hbchoi@hbchoi.mydns.jp',
		ps_subject => '테스트 메일',
		ps_body    => vv_html,
		ps_content => 'text/html;',
		ps_file_nm => '12.jpg'
	);
END;

 -- 230626
 -- 비밀번호를 담을 테이블
CREATE TABLE ch19_user (
	user_id   varchar2(50),		-- 사용자아이디
	user_name varchar2(100),	-- 사용자명
	pass 	  raw(2000)			-- 비밀번호
);

INSERT INTO ch19_user(user_id, user_name)
VALUES ('gdhong', '홍길동');

SELECT * FROM ch19_user ;

DECLARE 
	vs_pass varchar2(20);
BEGIN 
	vs_pass := 'HONG';

	UPDATE ch19_user
	SET pass = my_util_pkg.fn_create_pass(vs_pass, user_id)
	WHERE user_id = 'gdhong';

	COMMIT;
END;

DECLARE 
	vs_pass varchar2(20);
	v_raw 	raw(32747);
BEGIN 
	vs_pass := 'HONG';

	SELECT pass
	INTO v_raw
	FROM ch19_user
	WHERE user_id = 'gdhong';

	IF my_util_pkg.fn_check_pass(vs_pass, 'gdhong', v_raw) = 'Y' THEN 
		dbms_output.put_line('아이디와 비밀번호가 동일합니다.');
	ELSE 
		dbms_output.put_line('아이디와 비밀번호가 다릅니다.');
	END IF;
END;

 -- 암호화 키
DECLARE 
	vv_ddl varchar2(1000);	-- 패키지 소스를 저장하는 변수
BEGIN 
	vv_ddl := 'create or replace package ch19_wrap_pkg is 
			   pv_key_string constant varchar2(30) := ''OracleKey'';
			   key_bytes_raw constant raw(32) 
			  := ''1181C249F0F9C3343E8FF2BCCF370D3C9F70E973531DEC1C5066B54F27A507DB'';
			  END ch19_wrap_pkg;';
	
	dbms_ddl.create_wrapped(vv_ddl);

EXCEPTION WHEN OTHERS THEN 
	dbms_output.put_line(sqlerrm);
END;

ALTER TABLE CH19_USER ADD phone_number raw(2000);
 
SELECT utl_raw.cast_to_varchar2(PHONE_NUMBER) FROM ch19_user ;

BEGIN 
	UPDATE ch19_user
	SET PHONE_NUMBER = my_util_pkg.fn_encrypt('010-0000-0001')
	WHERE USER_ID = 'gdhong';
END;

 -- 복호화
DECLARE
	v_raw raw(2000);
	vs_phone_number varchar2(50);
BEGIN 
	SELECT PHONE_NUMBER
	INTO v_raw
	FROM ch19_user
	WHERE user_id = 'gdhong';

	vs_phone_number := my_util_pkg.fn_decrypt(v_raw);
	dbms_output.put_line('전화번호: ' || vs_phone_number);
END;
