----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--------------------------------------------- Canine 2009 to 2014 ----------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- create aggregated table (12 mins)

CREATE TABLE PURDUE_DIAG_LEVEL_2009_2014 AS
--SELECT COUNT(*) FROM (
SELECT * from ALEUNG.PURDUE_DIAG_LEVEL_V2 t -- 21,341,633
union all
select * from ALEUNG.PURDUE_DIAG_LEVEL_2014_150406 -- 4,040,538
--) -- 25,382,171

-- update table with claim type

CREATE TABLE PURDUE_DIAG_LEVEL_2009_2014 AS 
-- SELECT COUNT(*) FROM (
SELECT a.*, b.wellcare_or_medical_flag AS claim_type
FROM PURDUE_DIAG_LEVEL_2009_2014 a LEFT JOIN DWADMIN.DW_CLAIM_HEADER b ON a.claim_no = b.claim_no
-- ) -- 25,382,171

-- WELLCARE --------------------------------------
-- Run this and work on "include list"  (2 mins)

SELECT DISTINCT 
  t.test_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t
WHERE 
     t.species = 'Canine' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.test_code IS NOT NULL AND
     t.claimedamount > 0
GROUP BY
  t.test_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 
  
-- UPLOAD INCLUDE LIST -----------------------------------------
 
-- Run this and work on and continue to work on final include list (7 mins)

SELECT DISTINCT 
  t.test_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t LEFT JOIN ALEUNG.PURDUE_INCLUDE_TEST intest ON (t.test_code = intest.test_code)
WHERE 
     t.species = 'Canine' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.test_code IS NOT NULL AND
     intest.include = 'x' AND
     (t.claimedamount < 10000 AND t.claimedamount > 1) AND
     t.claim_type <> (CASE WHEN /*to_char(t.treat_date, 'YYYY') >= '2014' AND */t.test_code = '1' THEN 'Both' 
                      WHEN /*to_char(t.treat_date, 'YYYY') >= '2014' AND*/ t.test_code = '103' THEN 'Both'
                      ELSE 'SOMETHING' END)
GROUP BY
  t.test_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 
    
-- Replace "physical exam" with this

SELECT DISTINCT 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t
WHERE 
     t.species = 'Canine' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.test_code IS NOT NULL AND
     (t.claimedamount < 10000 AND t.claimedamount > 1) AND
     (t.test_code = '1' OR t.test_code = '121') AND -- add replace code here
     t.claim_type <> 'Both' -- do this for physical exam and comprehensive health panel codes only
GROUP BY
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 
  
-- Replace "CANINE VACCINATION-DHL-P" with this

SELECT DISTINCT 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t
WHERE 
     t.species = 'Canine' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.test_code IS NOT NULL AND
     (t.claimedamount < 10000 AND t.claimedamount > 1) AND
     (t.test_code = '140' OR t.test_code = '10') -- add replace code here
--   AND  t.claim_type <> 'Both' -- do this for physical exam and comprehensive health panel codes only
GROUP BY
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 

-- Replace "CANINE VACCINATION-PARVOVIRUS" with this

SELECT DISTINCT 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t
WHERE 
     t.species = 'Canine' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.test_code IS NOT NULL AND
     (t.claimedamount < 10000 AND t.claimedamount > 1) AND
     (t.test_code = '141' OR t.test_code = '11') -- add replace code here
--   AND  t.claim_type <> 'Both' -- do this for physical exam and comprehensive health panel codes only
GROUP BY
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 

-- Replace "Fecal Test" with this

SELECT DISTINCT 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t
WHERE 
     t.species = 'Canine' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.test_code IS NOT NULL AND
     (t.claimedamount < 10000 AND t.claimedamount > 1) AND
     (t.test_code = '40' OR t.test_code = '183') -- add replace code here
--   AND  t.claim_type <> 'Both' -- do this for physical exam and comprehensive health panel codes only
GROUP BY
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 


-- MEDICAL --------------------------------------
-- Run this and work on "include list"  (xx mins)

SELECT DISTINCT 
  t.diag_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t
WHERE 
     t.species = 'Canine' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.diag_code IS NOT NULL AND
     t.claimedamount > 0
GROUP BY
  t.diag_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 
  
-- UPLOAD INCLUDE LIST -----------------------------------------
 
-- Run this and work on and continue to work on final include list

SELECT DISTINCT 
  t.diag_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t LEFT JOIN ALEUNG.PURDUE_INCLUDE_DIAG ind ON (t.diag_code = ind.diag_code)
WHERE 
     t.species = 'Canine' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.diag_code IS NOT NULL AND
     ind.include = 'x' AND
     (t.claimedamount < 10000 AND t.claimedamount > 1)
GROUP BY
  t.diag_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--------------------------------------------- Feline 2009 to 2014 ----------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- WELLCARE --------------------------------------
-- Run this and work on "include list"  (2 mins)

SELECT DISTINCT 
  t.test_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t
WHERE 
     t.species = 'Feline' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.test_code IS NOT NULL AND
     t.claimedamount > 0
GROUP BY
  t.test_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 
  
-- UPLOAD INCLUDE LIST -----------------------------------------
 
-- Run this and work on and continue to work on final include list (7 mins)

SELECT DISTINCT 
  t.test_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t LEFT JOIN ALEUNG.PURDUE_INCLUDE_TESTF intest ON (t.test_code = intest.test_code)
WHERE 
     t.species = 'Feline' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.test_code IS NOT NULL AND
     intest.include = 'x' AND
     (t.claimedamount < 10000 AND t.claimedamount > 1) AND
     t.claim_type <> (CASE WHEN /*to_char(t.treat_date, 'YYYY') >= '2014' AND */t.test_code = '1' THEN 'Both' 
                      WHEN /*to_char(t.treat_date, 'YYYY') >= '2014' AND */t.test_code = '103' THEN 'Both'   
                      ELSE 'SOMETHING' END)

GROUP BY
  t.test_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 

-- MEDICAL --------------------------------------
-- Run this and work on "include list"  (3 mins)

SELECT DISTINCT 
  t.diag_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t
WHERE 
     t.species = 'Feline' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.diag_code IS NOT NULL AND
     t.claimedamount > 0
GROUP BY
  t.diag_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 
  
-- UPLOAD INCLUDE LIST -----------------------------------------
 
-- Run this and work on and continue to work on final include list

SELECT DISTINCT 
  t.diag_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
FROM 
  PURDUE_DIAG_LEVEL_2009_2014 t LEFT JOIN ALEUNG.PURDUE_INCLUDE_DIAGF ind ON (t.diag_code = ind.diag_code)
WHERE 
     t.species = 'Feline' AND
     t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2015', 'MM/DD/YYYY') AND
     t.diag_code IS NOT NULL AND
     ind.include = 'x' AND
     (t.claimedamount < 10000 AND t.claimedamount > 1)
GROUP BY
  t.diag_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') 

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

---------------------------------- REGIONAL ------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- Pull all eligible medical summary

SELECT 
  t.diag_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  r.region,
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
  
FROM
  PURDUE_DIAG_LEVEL_V2 t LEFT JOIN ALEUNG.PURDUE_IN_DIAG2 ind ON t.diag_code = ind.pbs_code
                       LEFT JOIN ALEUNG.PURDUE_REGION r ON t.prov_state = r.state
WHERE 
  t.species = 'Canine' AND
  t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2014', 'MM/DD/YYYY') AND
  t.diag_code IS NOT NULL AND
  ind.include = 'x' AND
  (t.claimedamount < 10000 AND t.claimedamount > 1)
GROUP BY
  t.diag_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM'),
  r.region

-- Pull all eligible wellness summary

SELECT DISTINCT 
  t.test_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  r.region,
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
  
FROM
  PURDUE_DIAG_LEVEL_V2 t LEFT JOIN ALEUNG.PURDUE_IN_TEST2 intest ON t.test_code = intest.test_code
                       LEFT JOIN ALEUNG.Purdue_Region r ON (t.prov_state = r.state)
WHERE 
  t.species = 'Canine' AND
  t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2014', 'MM/DD/YYYY') AND
  t.test_code IS NOT NULL AND
  intest.include = 'x' AND
  (t.claimedamount < 10000 AND t.claimedamount > 1)
GROUP BY
  t.test_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM'),
  r.region
  
-- Replace Physical (wellness) with this to include routine exam in medical too

SELECT DISTINCT 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  r.region,
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
  
FROM
  PURDUE_DIAG_LEVEL_V2 t LEFT JOIN ALEUNG.Purdue_Region r ON t.prov_state = r.state
WHERE 
  t.species = 'Canine' AND
  t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2014', 'MM/DD/YYYY') AND
  (t.test_code = '1' OR t.diag_code = '1004') AND
  (t.claimedamount < 10000 AND t.claimedamount > 1)
GROUP BY
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM'),
  r.region
  
----------------------------------------------------------------------------------------------------------------
---------------------------------- Zonal ------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
-- Pull all eligible medical summary

SELECT DISTINCT 
  t.diag_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  zz.zonal,
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
  
FROM
  PURDUE_DIAG_LEVEL_V2 t LEFT JOIN ALEUNG.PURDUE_IN_DIAG2 ind ON t.diag_code = ind.pbs_code
                       LEFT JOIN ALEUNG.PURDUE_ZONAL zz ON (SUBSTR(t.prov_zip, 1, 5) = zz.id)
WHERE 
  t.species = 'Canine' AND
  t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2014', 'MM/DD/YYYY') AND
  t.diag_code IS NOT NULL AND
  ind.include = 'x' AND
  (t.claimedamount < 10000 AND t.claimedamount > 1)
GROUP BY
  t.diag_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM'),
  zz.zonal

-- Pull all eligible wellness summary

SELECT DISTINCT 
  t.test_code, 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  zz.zonal,
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
  
FROM
  PURDUE_DIAG_LEVEL_V2 t LEFT JOIN ALEUNG.PURDUE_IN_TEST2 intest ON t.test_code = intest.test_code
                       LEFT JOIN ALEUNG.Purdue_Zonal zz ON (SUBSTR(t.prov_zip, 1, 5) = zz.id)
WHERE 
  t.species = 'Canine' AND
  t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2014', 'MM/DD/YYYY') AND
  t.test_code IS NOT NULL AND
  intest.include = 'x' AND
  (t.claimedamount < 10000 AND t.claimedamount > 1)
GROUP BY
  t.test_code, 
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM'),
  zz.zonal
  
-- Replace Physical (wellness) with this to include routine exam in medical too

SELECT DISTINCT 
  to_char(t.treat_date, 'YYYY') AS YEAR, 
  to_char(t.treat_date, 'MM') AS MONTH, 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM') AS period, 
  zz.zonal,
  SUM(t.claimedamount) AS sum_C, 
  SUM(t.paidamount) AS sum_P,
  COUNT(*) AS cnt, 
  MEDIAN(t.claimedamount) AS med
  
FROM
  PURDUE_DIAG_LEVEL_V2 t LEFT JOIN ALEUNG.Purdue_Zonal zz ON (SUBSTR(t.prov_zip, 1, 5) = zz.id)
WHERE 
  t.species = 'Canine' AND
  t.treat_date > to_date('12/31/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2014', 'MM/DD/YYYY') AND
  (t.test_code = '1' OR t.diag_code = '1004') AND
  (t.claimedamount < 10000 AND t.claimedamount > 1)
GROUP BY
  to_char(t.treat_date, 'YYYY'), 
  to_char(t.treat_date, 'MM'), 
  to_char(t.treat_date, 'YYYY')||'-'||to_char(t.treat_date, 'MM'),
  zz.zonal
