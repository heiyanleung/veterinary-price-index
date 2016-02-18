select COUNT(*) from PURDUE_DIAG_LEVEL_V4 t
-- 20,059,005

select COUNT(*) from 
(
SELECT * FROM PURDUE_DIAG_LEVEL_V4 t
WHERE t.species = 'Canine'
AND t.treat_date > to_date('11/30/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2014', 'MM/DD/YYYY') 
)
-- 15,455,019

SELECT COUNT(*) from PURDUE_DIAG_LEVEL_V4_OLD t
-- 21,341,633

SELECT COUNT(*) from 
(
SELECT * FROM PURDUE_DIAG_LEVEL_V4_OLD t
WHERE t.species = 'Canine' 
AND t.treat_date > to_date('11/30/2008' , 'MM/DD/YYYY') AND t.treat_date < to_date('01/01/2014', 'MM/DD/YYYY') 
)
-- 16,464,052
