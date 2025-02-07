SELECT *
FROM prescription;

SELECT COUNT(drug_name)
FROM drug;

SELECT COUNT(distinct drug_name)
FROM drug;

SELECT COUNT(drug_name)
FROM prescription;

SELECT COUNT(DISTINCT drug_name)
FROM prescription;

SELECT *
FROM prescriber;


SELECT SUM(total_claim_count) AS total_number_of_claims, pr.npi, pr.nppes_provider_last_org_name AS last_name, pr.nppes_provider_first_name AS first_name
FROM prescriber as pr LEFT JOIN prescription AS pn ON pr.npi = pn.npi
WHERE total_claim_count IS NOT NULL
AND drug_name IS NOT NULL
GROUP BY pr.npi, last_name, first_name
ORDER BY total_number_of_claims DESC;

-------------------------------------------------------1)a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.


SELECT COUNT(DISTINCT npi)
FROM prescription; --------------20592

SELECT COUNT (DISTINCT drug_name)
FROM prescription;

SELECT COUNT(DISTINCT npi)
FROM prescriber;-----------------25050

SELECT SUM(total_claim_count) AS total_number_of_claims, pr.specialty_description, pr.nppes_provider_last_org_name AS last_name, pr.nppes_provider_first_name AS first_name
FROM prescriber as pr LEFT JOIN prescription AS pn ON pr.npi = pn.npi
WHERE total_claim_count IS NOT NULL
AND drug_name IS NOT NULL
GROUP BY pr.specialty_description, last_name, first_name
ORDER BY total_number_of_claims DESC;


--------------------------------------------------------1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, 
--------------------------------------------------------and the total number of claims.

SELECT SUM(total_claim_count) AS total_number_of_claims, pr.specialty_description
FROM prescriber as pr LEFT JOIN prescription AS pn ON pr.npi = pn.npi
WHERE total_claim_count IS NOT NULL
AND drug_name IS NOT NULL
GROUP BY pr.specialty_description
ORDER BY total_number_of_claims DESC
LIMIT 1;

SELECT *
FROM drug;

--------------------------------------------------------2a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT SUM(total_claim_count) AS total_claim_count, specialty_description
FROM prescription AS pn LEFT JOIN prescriber AS pr ON pn.npi = pr.npi
LEFT JOIN drug ON pn.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y'
AND total_claim_count IS NOT NULL
GROUP BY specialty_description
ORDER BY total_claim_count DESC; ------------------------------my answer

-------------------
SELECT
	specialty_description
	, SUM(total_claim_count) AS total_claims
FROM prescription
INNER JOIN prescriber USING(npi)
WHERE drug_name IN (SELECT drug_name FROM drug GROUP BY drug_name HAVING MAX(opioid_drug_flag) = 'Y')
GROUP BY specialty_description
ORDER BY total_claims DESC
LIMIT 10;
--------------------------------------------------------
--------------------------------------------------------2b. Which specialty had the most total number of claims for opioids?

SELECT description_flag,npi
FROM prescriber
LEFT JOIN prescription
USING (npi)
EXCEPT
SELECT drug_name, npi
FROM prescription
LEFT JOIN prescriber 
USING (npi);

SELECT DISTINCT specialty_description
FROM prescriber
WHERE npi IN (SELECT npi
FROM prescriber AS pr LEFT JOIN prescription AS pn
USING (npi)
EXCEPT
SELECT npi
FROM prescription);  ---------------------------------my answer



SELECT DISTINCT specialty_description
FROM prescriber
LEFT JOIN prescription USING (npi)
WHERE prescription.npi IS NULL; --------------------same answer

--------------------------------------------------------2c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions 
--------------------------------------------------------in the prescription table?

SELECT SUM(total_claim_count) AS total_claim_count AS total_claim_count, specialty_description, 
FROM prescription AS pn LEFT JOIN prescriber AS pr ON pn.npi = pr.npi
LEFT JOIN drug ON pn.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y'
AND total_claim_count IS NOT NULL
GROUP BY specialty_description
ORDER BY total_claim_count DESC; -----------discard

SELECT oc.specialty_description, ROUND((oc.total_claim_opioid * 100 / tc.total_claims),2) AS opioid_percentage
FROM ---------------joining total count for opioid only
(SELECT DISTINCT specialty_description, SUM(total_claim_count) AS total_claim_opioid
FROM prescriber AS pr LEFT JOIN prescription AS pn ON pr.npi = pn.npi 
LEFT JOIN drug ON drug.drug_name = pn.drug_name
WHERE opioid_drug_flag = 'Y'
AND total_claim_count IS NOT NULL
GROUP BY specialty_description) AS oc
LEFT JOIN ----------------joining total claim count
(SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber AS pr INNER JOIN prescription AS pn ON pr.npi = pn.npi
WHERE total_claim_count IS NOT NULL
GROUP BY specialty_description) AS tc
ON tc.specialty_description = oc.specialty_description
ORDER BY opioid_percentage DESC;  ---------------good?


---------------------------------------------------------2d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that 
---------------------------------------------------------specialty which are for opioids. Which specialties have a high percentage of opioids?

SELECT DISTINCT generic_name, MAX(total_drug_cost::money) AS total_cost
FROM prescription AS pn LEFT JOIN drug USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC
LIMIT 1;

---------------------------------------------------------3a Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, MAX(total_30_days_f)

SELECT total_day_supply
FROM prescription
ORDER BY total_day_supply; ----- there is no data on total day supply < 0.

SELECT DISTINCT generic_name, ROUND((total_drug_cost / total_day_supply),2) AS cost_per_day
FROM prescription LEFT JOIN drug USING (drug_name)
ORDER BY cost_per_day DESC;


---------------------------------------------------------3b) Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. 
---------------------------------------------------------Google ROUND to see how this works.

SELECT DISTINCT drug_name,
CASE 
WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' 
ELSE 'neither' 
END AS drug_type
FROM drug
GROUP BY drug_name, drug_type
ORDER BY drug_type DESC;
------------------------------------------------------4a)For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y',
------------------------------------------------------says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. 
WITH opioid_antibiotic AS(SELECT DISTINCT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic' 
ELSE 'neither' 
END AS drug_type
FROM drug
)
SELECT
SUM(CASE WHEN drug_type = 'opioid' THEN total_drug_cost ELSE 0 END)::money AS opioid_count,
SUM(CASE WHEN drug_type = 'antibiotic' THEN total_drug_cost ELSE 0 END)::money AS antibiotic_count
FROM opioid_antibiotic INNER JOIN prescription AS pn USING(drug_name);


-------------------------------------------------------4b) Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
-------
SELECT *
FROM cbsa;
---
WITH tn_cbsa_count AS(
SELECT COUNT(cbsa) AS tn_cbsa, cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%'
GROUP BY cbsaname);                    --------------------shows all the counts for different places in TN icluding other states AND TN (otherwise put (%TN)) also LIKE because ILIKE was showing place that had
-----tn in it but wasn't actual TN state, all the states for TN are capitolized TN ------
WITH tn_cbsa_count AS(
SELECT COUNT(cbsa) AS tn_cbsa, cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%'
GROUP BY cbsaname)
SELECT SUM(tn_cbsa::numeric) AS total_cbsa_in_tn
FROM tn_cbsa_count;                    ---------------------5a)shows all the counts per town/city so multiple cbsa in one place

WITH tn_cbsa_count AS(
SELECT COUNT(DISTINCT cbsa) AS tn_cbsa, cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%'
GROUP BY cbsaname)
SELECT SUM(tn_cbsa::numeric) AS total_cbsa_in_tn
FROM tn_cbsa_count;                    ---------------------5a)shows how many unique cbsa are in TN city/towns


-------------------------------------------------------5a) How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

SELECT SUM(population) AS total_population, cbsaname
FROM population AS pn INNER JOIN cbsa USING (fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC;  ------------------------------first part of 5b

WITH cbsa_population AS (
SELECT SUM(population) AS total_population, cbsaname
FROM population AS pn INNER JOIN cbsa USING (fipscounty)
GROUP BY cbsaname
)
SELECT MAX(total_population) AS max_pop, MIN(total_population) AS min_pop, cbsaname
FROM cbsa_population
GROUP BY cbsaname
ORDER BY max_pop, min_pop;



SELECT COUNT(DISTINCT fipscounty)
FROM cbsa;

SELECT COUNT(DISTINCT fipscounty)
FROM population;

SELECT *
FROM cbsa


-------------------------------------------------------5b) Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
WITH county_without_cbsa AS(
SELECT fipscounty, population
FROM population LEFT JOIN cbsa USING (fipscounty)
GROUP BY fipscounty, population
EXCEPT 
SELECT fipscounty, population
FROM cbsa INNER JOIN population USING (fipscounty))
SELECT SUM(population) AS pop_count, county
FROM county_without_cbsa LEFT JOIN fips_county USING(fipscounty)
GROUP BY county
ORDER BY pop_count DESC
LIMIT 1;


--------------------------------------------------------5c) What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT drug_name, total_claim_count AS total_claim_count_over_3000
FROM prescription INNER JOIN drug USING(drug_name)
WHERE total_claim_count >=3000
ORDER BY total_claim_count_over_3000 DESC;


--------------------------------------------------------6a)Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count AS total_claim_count_over_3000,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' ELSE 'non-opioid' END AS opioid
FROM prescription INNER JOIN drug USING(drug_name)
WHERE total_claim_count >=3000
ORDER BY total_claim_count_over_3000 DESC;


--------------------------------------------------------6b) For each instance that you found in part a, add a column that indicates whether the drug is an opioid.


SELECT drug_name, total_claim_count AS total_claim_count_over_3000, nppes_provider_last_org_name AS provider_last_name, nppes_provider_first_name AS provider_first_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' ELSE 'non-opioid' END AS opioid
FROM prescription INNER JOIN drug USING(drug_name)
INNER JOIN prescriber AS pr ON pr.npi = prescription.npi
WHERE total_claim_count >=3000
ORDER BY total_claim_count_over_3000 DESC;



--------------------------------------------------------6c) Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.





--------------------------------------------------------7)The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. 
--------------------------------------------------------Hint: The results from all 3 parts will have 637 rows.

SELECT drug_name, npi
FROM prescriber CROSS JOIN drug 
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';



--------------------------------------------------------7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of 
--------------------------------------------------------Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it.
--------------------------------------------------------You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


WITH prescriber_drug AS(
SELECT drug_name, npi
FROM prescriber CROSS JOIN drug 
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y')
SELECT pd.npi, pd.drug_name, COALESCE(pn.total_claim_count,0) AS total_claim_count
FROM prescriber_drug AS pd
LEFT JOIN prescription AS pn
ON pd.npi = pn.npi AND pd.drug_name = pn.drug_name
ORDER BY total_claim_count DESC;


--------------------------------------------------------7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. 
--------------------------------------------------------You should report the npi, the drug name, and the number of claims (total_claim_count).
--------------------------------------------------------c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

