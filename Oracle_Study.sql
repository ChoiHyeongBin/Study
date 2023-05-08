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
