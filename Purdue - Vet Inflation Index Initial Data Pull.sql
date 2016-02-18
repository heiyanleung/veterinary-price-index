CREATE TABLE PURDUE_DIAG_LEVEL_2015_SEMI AS -- run time ~ 11 mins on 01/27/2015
                                            -- run time ~ 12 mins on 02/09/2015
                                            -- run time ~ 11 mins on 03/11/2015
                                            -- run time ~ 6 mins on 04/06/2015
                                            -- run tim ~ 16 mins on 06/03/2015; 7 mins on 6/05/2015 (add claim type)
                                            -- run time ~ 46 mins on 06/15/2015 (09-14, fixed prov add and added claim variables)
                                            -- run time ~ 3 mins on 7/6/2015
SELECT DISTINCT
  aa.insured_code,
  em.insured_address1 AS PH_ADD,
  em.insured_address2 AS PH_ADD2,
  em.insured_city AS PH_CITY,
  em.insured_state AS PH_STATE,
  em.insured_zipcode AS PH_ZIP,
  aa.policy_no,
  aa.policy_renew_no AS POLICY_TERM,
  aa.effective_date AS POLICY_EFFDATE,
  aa.expire_date AS POLICY_EXPDATE,
  aa.cancellation_date AS POLICY_CANDATE,
  o.cancellationdesc AS CAN_REASON,
  i.baseproduct,
  i.wellcareproduct,
  c.claim_diagnosis_coverage AS claimproduct,
  aa.age AS PET_AGE,
  g.species,
  h.gender_desc AS PET_GENDER,
  e.breed_desc AS BREED,
  a.claim_no,
  a.claim_1st_treatment AS TREAT_DATE,
  a.claim_date_received AS CLAIM_REC_DATE, -- added since 2015
  a.claim_process_date AS CLAIM_PROCESS_DATE, -- added since 2015
  d.claim_revision_close_date AS CLAIM_CLOSE_DATE, -- added since 2015
  a.provider_code AS PROV_CODE,
  a.provider_name AS PROV_NAME,
  k.provider_address AS PROV_ADD,
  k.provider_address2 AS PROV_ADD2,
  k.provider_city AS PROV_CITY,
  k.provider_state AS PROV_STATE,
  k.provider_zipcode AS PROV_ZIP,
  k.provider_email AS PROV_EMAIL,
  c.claim_diagnosis_code DIAG_CODE,
  min(j.pbs_description) AS PBS_DESC, -- take out duplicate descriptions
  l.test_code,
  min(l.test_desc) AS TEST_DESC, -- take out duplicate descriptions
  sum(b.claimedamount) AS claimedamount,
  sum(b.paidamount) AS paidamount,
  min(f.denialcode) AS DENIAL_CODE,-- take out duplicate descriptions
  min(f.denialdesc) AS Denial_DESC, -- take out duplicate descriptions
  a.wellcare_or_medical_flag AS CLAIM_TYPE
    
FROM 
DWADMIN.DW_POLICY_HEADER aa
  LEFT JOIN DWADMIN.DW_CLAIM_HEADER a ON (aa.policyid = a.policyid)
  LEFT JOIN DWADMIN.DW_CLAIM_REVISION d ON (a.claim_id = d.claim_id)
  LEFT JOIN DWADMIN.DW_CLAIM_DIAGNOSIS c ON (d.claim_id = c.claim_id AND d.claim_revision_no = c.claim_revision_no)
  LEFT JOIN DWADMIN.DW_CLAIM_DETAILS b ON (b.claim_diagnosis_id = c.claim_diagnosis_id)
  LEFT JOIN DWDAILY.DW_DIM_INSURED em ON (em.insured_code = aa.insured_code)
  LEFT JOIN DWADMIN.DW_DIM_BREED e ON (e.breed_id = aa.breed_id)
  LEFT JOIN DWADMIN.DW_DIM_DENIAL_CODE f ON (f.denialcode_id = b.denialcode_id)
  LEFT JOIN DWADMIN.DW_DIM_SPECIES g ON (g.speciescode = e.speciescode)
  LEFT JOIN DWADMIN.DW_DIM_GENDER h ON (aa.gender_id = h.gender_id)
  LEFT JOIN DWADMIN.DW_DIM_PRODUCT_TYPE i ON (aa.product_type_id = i.product_type_id)
  LEFT JOIN DWADMIN.DW_DIM_DIAGNOSIS j ON (j.pbs_code = c.claim_diagnosis_code AND j.coverage_id = c.claim_coverage_id) -- testing
  LEFT JOIN DWADMIN.DW_DIM_PROVIDER k ON k.provider_code = a.provider_code --(k.provider_id = aa.provider_id) 
  -- instead of linking to aa.provider_id should be a.provider_id 6/15/15
  LEFT JOIN DWADMIN.DW_DIM_TESTS l ON (l.test_code = b.test_code AND l.coverage_id = c.claim_coverage_id) -- testing
  LEFT JOIN DWADMIN.DW_DIM_TREATMENT m ON (m.treatment_id = b.subclaim_item_no)
  LEFT JOIN DWADMIN.DW_CANC n ON (aa.policyid = n.policyid)
  LEFT JOIN DWADMIN.DW_DIM_CANCEL_REASON o ON (o.cancellationid = n.cancellationreasonid)

WHERE
  d.claim_revision_status = 'Claim Complete'
  AND d.claim_revision_close_date IS NOT NULL
  AND (a.claim_1st_treatment >= to_date('1/1/2015','MM/DD/YYYY') AND a.claim_1st_treatment <= to_date('6/30/2015','MM/DD/YYYY'))
-- AND (d.CLAIM_REVISION_CLOSE_DATE  >=  to_date('1/1/2015','MM/DD/YYYY') AND d.CLAIM_REVISION_CLOSE_DATE  <=  to_date('6/30/2015','MM/DD/YYYY')) 
-- beginning 2015, capture everything closed at point of data run with no limitation on claim close date

GROUP BY
  aa.insured_code,
  em.insured_address1,
  em.insured_address2,
  em.insured_city,
  em.insured_state,
  em.insured_zipcode,
  aa.policy_no,
  aa.policy_renew_no,
  aa.effective_date,
  aa.cancellation_date,
  o.cancellationdesc,
  aa.expire_date,
  i.baseproduct,
  i.wellcareproduct,
  c.claim_diagnosis_coverage,
  aa.age,
  g.species,
  h.gender_desc,
  e.breed_desc,
  a.claim_no,
  a.claim_1st_treatment,
  a.claim_date_received, -- added since 2015
  a.claim_process_date, -- added since 2015
  d.claim_revision_close_date, -- added since 2015
  a.provider_code,
  a.provider_name,
  k.provider_address,
  k.provider_address2,
  k.provider_city,
  k.provider_state,
  k.provider_zipcode,
  k.provider_email,
  c.claim_diagnosis_code,
  l.test_code,
  a.wellcare_or_medical_flag
  
ORDER BY
  aa.insured_code

-- Number of claims = 1,210,245; number of diagnosis = 4,050,710 on 02/09/2015
-- Number of claims = 1,215,991; number of diagnosis = 4,067,998 on 01/27/2015
-- Number of claims = 1,206,989; number of diagnosis = 4,040,538 on 04/6/2015
-- Number of claims = 1,031,892; number of diagnosis = 3,466,223 on 06/03/2015  (ONLY 2014 Treat Date)
   -- Number of claims = 1,031,892; number of diagnosis = 3,466,223 on 06/03/2015  (after adding claim type)
-- Number of claims = 6,536,680; number of diagnosis = 21,349,051 on 06/15/2015 (2009-2014) (2014: 1,031,892; 3,466,223)
-- 2015Q1 diagnosis = 681,899; claims = 202,630 (jan = 89443; feb = 72793; mar = 40394) on 07/06/2015
--                  = 681,039; claims = 202,342 (jan = 89327; feb = 72697; mar = 40318) on 08/06/2015
-- with limit: 2015 Jan-Jun diagnosis = 1,730,687; claims = 507,428 (jan = 99002, feb = 89232, mar = 100495, apr = 96710, may = 83189, jun = 38800)
-- w/out limit: 2015 Jan-Jun diagnosis = 1,979,610; claims = 582,132 (jan = 100526, feb = 91093, mar = 103777, apr = 102363, may = 95778, jun = 88595)
-- File export time ~ 267.42 mins to local drive on 10/08/2014
-- File export time ~ 900+ mins to local drive on 2/11/2014
-- File export time ~ 188 mins to local drive on 6/15/2014
-- File export time ~ 5 mins to local drive on 8/18/2015

-----------------------------------------------------------------------------------------------------------------------
------------------------------------------ Count Validation -----------------------------------------------------------

SELECT to_char(a.treat_date, 'MM'), COUNT(*) from 
(
SELECT DISTINCT t.claim_no, t.treat_date
FROM PURDUE_DIAG_LEVEL_2015_SEMI t
--WHERE to_char(t.treat_date, 'MM') = '05'
) a
GROUP BY to_char(a.treat_date, 'MM')
ORDER BY to_char(a.treat_date, 'MM')

-----------------------------------------------------------------------------------------------------------------------
------------------------------------------ 2013 Q4 and 2014 Q4 comparisons --------------------------------------------

select COUNT(*) 
-- from (SELECT DISTINCT t.claim_no 
FROM PURDUE_DIAG_LEVEL_2014_150406 t
WHERE (t.treat_date >= to_date('10/1/2014','MM/DD/YYYY') AND t.treat_date <= to_date('12/31/2014','MM/DD/YYYY'))
-- )

-- 176,427 claims, 578,962 diagnoses

select COUNT(*) 
-- from (SELECT DISTINCT t.claim_no 
FROM PURDUE_DIAG_LEVEL_2014_150209 t
WHERE (t.treat_date >= to_date('10/1/2014','MM/DD/YYYY') AND t.treat_date <= to_date('12/31/2014','MM/DD/YYYY'))
--)

-- 178,029 claims, 583,562 diagnoses


select COUNT(*) 
--from (SELECT DISTINCT t.claim_no 
FROM SPIKE_Claims_2013 t
WHERE (t.treat_date >= to_date('10/1/2013','MM/DD/YYYY') AND t.treat_date <= to_date('12/31/2013','MM/DD/YYYY'))
--)

-- 169,999 claims, 527,854 diagnoses
