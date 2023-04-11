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
	dbms_output.put_line('Success!');

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
	dbms_output.put_line('Success!');
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