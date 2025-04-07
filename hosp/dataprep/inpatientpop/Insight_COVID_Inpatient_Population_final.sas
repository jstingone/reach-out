/************************************************************/
/* PROGRAM NAME: Insight_COVID_Population_JAS_final.sas		*/
/* PROGRAMMER: Cong Zhang with Additions from 				*/
/*				Jeanette Stingone							*/
/* DATE: 7/22/2023											*/
/* PROGRAM RUNNING TIME: ~HOURS								*/
/* PURPOSE: Create COVID+ Population for Insight Inpatients	*/
/************************************************************/

/*  1 Create Encounter Data for Inpatients Admitted Between 03/01/2020 And 02/28/2021 */
/*  2 Create COVID+ Diagnosis Data for Inpatients Admitted Between 03/01/2020 And 02/28/2021 */
/*  3 Create COVID+ Lab Data for Inpatients Admitted Between 03/01/2020 And 02/28/2021 */
/*  4 Create COVID+ Population of Insight Data, Defined as COVID+ Inpatients Admitted Between 03/01/2020 And 02/28/2021 */
/*  5 Create Demographic Data for COVID+ Population of Insight Data */
/*  6 Create Address Data for COVID+ Population of Insight Data */
/*  7 Create Comorbidities Data for COVID+ Population of Insight Data */
/*  8 Create Vital Data for COVID+ Population of Insight Data */
/*  9 Create Smoking Data for COVID+ Population of Insight Data */
/* 10 Create Acute Respiratory Distress Syndrome (ARDS) Data for COVID+ Population of Insight Data */
/* 11 Create Pneumonia Data for COVID+ Population of Insight Data */
/* 12 Create Mechanical Ventilation Data for COVID+ Population of Insight Data*/
/* 13 Create Dialysis Data for COVID+ Population of Insight Data*/
/* 14 Prepare Nevi Data */
/* 15 Prepare Pollution Data */
/* 16 Create Model-Ready Dataset for COVID+ Population of Insight Data by Joining Datasets from Previous Steps and Merging/Cleaning Adjacent Visits */
/* 17 Generate Preliminary Distributions of Model-Ready Dataset for COVID+ Population of Insight Data */

libname DataSAS  "L:\dcore-prj0131-SHARED\dcore-prj0131-Stingone\INSIGHT_Stingone_2021-08-16_SAS";
libname DataNevi "L:\dcore-prj0131-SHARED\dcore-prj0131-Stingone\Datasets_JAS";
libname DataCong "L:\dcore-prj0131-SHARED\dcore-prj0131-Stingone\INSIGHT_Cong\Datasets";

option COMPRESS = YES;

/* 1. Encounter Data */
/* 1.1 Check Leading 0 in Charater Variables of Encounter Data before Converting to Numeric Type */
PROC SQL;
SELECT count(*) AS num_patid_start_with_0	/* 0 row: No leading 0 in patid of encounter data */
FROM DataSAS.encounter
WHERE substr(strip(ssid),1,1) = '0';
QUIT;

/* 1.2 Create Encounter Data of All Patients */
PROC SQL;
CREATE TABLE encounterid_patid_date AS
SELECT encounterid,
	   input(ssid, best.) AS patid, /* convert to numeric */
	   ADMIT_DATE AS admit_date,
	   DHMS(ADMIT_DATE,0,0,ADMIT_TIME) AS admit_date_time FORMAT = DATETIME19.
FROM DataSAS.encounter;
QUIT; /* 23485890 rows and 4 columns */

/* 1.3 Check Duplicates in Encounter Data of All Patients */
PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid) AS num_patid_per_encounter /* ! Each encounterid of Encounter Data corresponds to ONLY 1 patid ! */
	 FROM encounterid_patid_date
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

SELECT num_admit_date_per_encounter, COUNT(num_admit_date_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT admit_date) AS num_admit_date_per_encounter /* ! Each encounterid of Encounter Data corresponds to ONLY 1 admit_date ! */
	 FROM encounterid_patid_date
	 GROUP BY encounterid)
GROUP BY num_admit_date_per_encounter;
QUIT;

PROC SORT
DATA = encounterid_patid_date NODUPKEY
DUPOUT = encounterid_patid_date_dup	/* 0 duplicate rows */
OUT = encounterid_patid_date_uniq;	/* 23485890 unique rows */
BY encounterid patid;
RUN;

PROC SORT
DATA = encounterid_patid_date_uniq NODUPKEY
DUPOUT = encounterid_patid_date_dup				/* 0 duplicate encounterid */
OUT = DataCong.encounterid_patid_date_all_data;	/* 23485890 unique encounterid */
BY encounterid;
RUN;

/* 1.4 Create Encounter Data of Inpatients Admitted Between 03/01/2020 And 02/28/2021 */
PROC SQL;
CREATE TABLE DataCong.encounter AS
SELECT encounterid,
	CASE
	   WHEN upcase(strip(enc_type)) = 'IP' THEN 'Inpatient'
	   WHEN upcase(strip(enc_type)) = 'EI' THEN 'Inpatient from Emergency'
	   ELSE upcase(strip(enc_type))
	END AS encounter_type,
	   input(ssid, best.) AS patid, /* convert to numeric */
	   ADMIT_DATE AS admit_date,
	   ADMIT_TIME AS admit_time,
	   DHMS(ADMIT_DATE,0,0,ADMIT_TIME) AS admit_date_time FORMAT = DATETIME19.,
	CASE
	   WHEN ADMIT_DATE IS NULL THEN .
	   WHEN ADMIT_DATE  < '01MAR2020'd THEN 0
	   WHEN ADMIT_DATE <= '30JUN2020'd THEN 1
	   WHEN ADMIT_DATE <= '31OCT2020'd THEN 2
	   WHEN ADMIT_DATE <= '28FEB2021'd THEN 3
	   ELSE 0
	END AS admit_date_phase,
       DISCHARGE_DATE AS discharge_date,
	   DISCHARGE_TIME AS discharge_time,
	   DHMS(DISCHARGE_DATE,0,0,DISCHARGE_TIME) AS discharge_date_time FORMAT = DATETIME19.,
	CASE
	   WHEN upcase(strip(discharge_disposition)) = 'A' THEN 'Alive'
	   WHEN upcase(strip(discharge_disposition)) = 'E' THEN 'Expired'
	   WHEN upcase(strip(discharge_disposition)) IN ('OT', 'NI', 'UN') THEN 'Unknown'
	   ELSE ''
	END AS discharge_disposition,
	   INTCK('day', admit_date, discharge_date) AS hospital_days
	   /* INTCK('minute', CALCULATED admit_date_time, CALCULATED discharge_date_time) / 60 AS hospital_hours */
FROM DataSAS.encounter
WHERE (admit_date BETWEEN '01MAR2020'd AND '28FEB2021'd)
	   AND upcase(strip(enc_type)) IN ('IP','EI')
ORDER BY encounterid, patid, admit_date;
QUIT; /* 205571 rows and 12 columns */

/* 1.5 Check Missings in Encounter Data of Inpatients Admitted Between 03/01/2020 And 02/28/2021 */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,								/* 0 obs */
	   NMISS(encounter_type) AS encounter_type_miss_num,						/* 0 obs */
	   NMISS(patid) AS patid_miss_num,											/* 0 obs */
	   NMISS(admit_date) AS admit_date_miss_num,								/* 0 obs */
	   NMISS(admit_time) AS admit_time_miss_num,								/* 3 obs */
	   NMISS(admit_time)/count(*) AS admit_time_miss_per,						/* 0.0015% obs */
	   NMISS(admit_date_time) AS admit_date_time_miss_num,						/* 3 obs */
	   NMISS(admit_date_time)/count(*) AS admit_date_time_miss_per,				/* 0.0015% obs */
	   NMISS(admit_date_phase) AS admit_date_phase_miss_num,					/* 0 obs */
	   NMISS(discharge_date) AS discharge_date_miss_num,						/* 0 obs */
	   NMISS(discharge_time) AS discharge_time_miss_num,						/* 8 obs */
	   NMISS(discharge_time)/count(*) AS discharge_time_miss_per,				/* 0.0039% obs */
	   NMISS(discharge_date_time) AS discharge_date_time_miss_num,				/* 8 obs */
	   NMISS(discharge_date_time)/count(*) AS discharge_date_time_miss_per,		/* 0.0039% obs */
	   NMISS(discharge_disposition) AS discharge_disposition_miss_num,			/* 0 obs */
	   NMISS(hospital_days) AS hospital_days_miss_num							/* 0 obs */
FROM DataCong.encounter;
QUIT;


/* 2. Diagnosis Data */
/* 2.1 Check Leading 0 in Charater Variables of Diagnosis Data before Converting to Numeric Type */
PROC SQL;
SELECT count(*) AS num_encounterid_start_with_0	/* 0 row: No leading 0 in encounterid of diagnosis data */
FROM DataSAS.diagnosis
WHERE substr(strip(encounterid),1,1) = '0';

SELECT count(*) AS num_patid_start_with_0		/* 0 row: No leading 0 in patid of diagnosis data */
FROM DataSAS.diagnosis
WHERE substr(strip(ssid),1,1) = '0';
QUIT;


/****************************************************************************************************************************/
/* CAUTION !!! It takes about 1 hour and 20 minutes to run this section of code, so it is put in the comments to save time! */
/* This section of code generates a dataset called "dup_patid_per_encnter_in_diag", which shows that within raw		*/
/* diagnosis data, many encounterid correspond to more than one patid.  The following sections starting from 2.2-2.7 	*/
/* solve this problem for Inpatients with COVID+ Diagnosis by matching on both encounterid and patid and then  */
/* ensuring that patid in the encounter table matches the patid in the diagnosis table. */

* PROC SQL;
* SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
* FROM
*	(SELECT COUNT(DISTINCT ssid) AS num_patid_per_encounter
*	 FROM DataSAS.diagnosis
*	 GROUP BY encounterid)
* GROUP BY num_patid_per_encounter;

* CREATE TABLE DataCong.dup_patid_per_encnter_in_diag AS
* SELECT *
* FROM DataSAS.diagnosis
* WHERE encounterid IN
*	(SELECT encounterid
*	 FROM DataSAS.diagnosis
*	 GROUP BY encounterid
*	 HAVING COUNT(DISTINCT ssid) > 1) /* !!!!!!!!!! WARNING: encounterid correspond to multiple patid !!!!!!!!!! */
* ORDER BY encounterid, ssid;
* QUIT;
/****************************************************************************************************************************/


/* 2.2 Create COVID+ Diagnosis Data of All Admit Dates */
PROC SQL;
CREATE TABLE DataCong.diagnosis AS
SELECT diagnosisid,
	   input(encounterid, best.) AS encounterid,	/* convert to numeric */
	CASE
	   WHEN upcase(strip(enc_type)) = 'IP' THEN 'Inpatient'
	   WHEN upcase(strip(enc_type)) = 'EI' THEN 'Inpatient from Emergency'
	   ELSE upcase(strip(enc_type))
	END AS enc_type_diagnosis,
	   input(ssid, best.) AS patid_diagnosis,		/* convert to numeric */
	   ADMIT_DATE AS admit_date_diagnosis,
	   DX_DATE AS dx_date,
	   upcase(strip(dx_type)) AS dx_type,
       upcase(strip(dx)) AS dx
FROM DataSAS.diagnosis
WHERE upcase(strip(dx)) IN ('B34.2','B97.21','B97.29','U07.1') /* Ref: COVID-19 DX Codes */
ORDER BY encounterid, patid_diagnosis, diagnosisid;
QUIT; /* 1541567 rows and 8 columns */

/* 2.3 Check Missings in COVID+ Diagnosis Data of All Admit Dates */
PROC SQL;
SELECT NMISS(diagnosisid) AS diagnosisid_miss_num,			/* 0 obs */
	   NMISS(encounterid) AS encounterid_miss_num,			/* 0 obs */
	   NMISS(enc_type_diagnosis) AS enc_type_miss_num,		/* 0 obs */
	   NMISS(patid_diagnosis) AS patid_miss_num,			/* 0 obs */
	   NMISS(admit_date_diagnosis) AS admit_date_miss_num,	/* 0 obs */
	   NMISS(dx_date) AS dx_date_miss_num,					/* 759884 obs */
	   NMISS(dx_date)/count(*) AS dx_date_miss_per,			/* 49.293% obs */
	   NMISS(dx_type) AS dx_type_miss_num,					/* 0 obs */
	   NMISS(dx) AS dx_miss_num								/* 0 obs */
FROM DataCong.diagnosis;
QUIT;

/* 2.4 Check Duplicates in COVID+ Diagnosis Data of All Admit Dates */
PROC SORT
DATA = DataCong.diagnosis NODUPKEY
DUPOUT = diagnosis_dup	/* 0 duplicate diagnosisid */
OUT = diagnosis_uniq;	/* 1541567 unique diagnosisid */
BY diagnosisid;
RUN; 

PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid_diagnosis) AS num_patid_per_encounter
	 FROM DataCong.diagnosis
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

CREATE TABLE diagnosis_dup_patid AS
SELECT *
FROM DataCong.diagnosis
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.diagnosis
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT patid_diagnosis) > 1) /* !!!!!!!!!! WARNING: 4 encounterid correspond to 2 patid. Cleaned later when matching patid to patid_diagnosis !!!!!!!!!! */
ORDER BY encounterid, patid_diagnosis, admit_date_diagnosis;
QUIT;

PROC SQL;
SELECT num_admit_date_per_encounter, COUNT(num_admit_date_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT admit_date_diagnosis) AS num_admit_date_per_encounter
	 FROM DataCong.diagnosis
	 GROUP BY encounterid)
GROUP BY num_admit_date_per_encounter;

CREATE TABLE diagnosis_dup_admit_date AS
SELECT *
FROM DataCong.diagnosis
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.diagnosis
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT admit_date_diagnosis) > 1) /* !!!!!!!!!! WARNING: 4 encounterid correspond to 2 admit_date !!!!!!!!!! */
ORDER BY encounterid, patid_diagnosis, admit_date_diagnosis;

SELECT *
FROM diagnosis_dup_admit_date
WHERE diagnosisid NOT IN
	(SELECT diagnosisid
	 FROM diagnosis_dup_patid); /* 0 row: All duplicate admit_date are due to duplicate patid */
QUIT;

PROC SQL;
SELECT num_diagnosis_per_encounter, COUNT(num_diagnosis_per_encounter) AS num_encounter
FROM
	(SELECT encounterid, COUNT(diagnosisid) AS num_diagnosis_per_encounter /* ! NOTE: many encounterid have hundreds of diagnosisid ! */
	 FROM DataCong.diagnosis
	 GROUP BY encounterid)
GROUP BY num_diagnosis_per_encounter;

CREATE TABLE diagnosis_dup AS
SELECT *, COUNT(diagnosisid) AS num_diagnosis_per_encounter
FROM DataCong.diagnosis
GROUP BY encounterid
HAVING num_diagnosis_per_encounter > 400 
ORDER BY num_diagnosis_per_encounter, encounterid, patid_diagnosis, admit_date_diagnosis;
QUIT;

/* 2.5 Create COVID+ Diagnosis Data of Inpatients Admitted Between 03/01/2020 And 02/28/2021 */
PROC SQL;
CREATE TABLE diagnosis_encounter AS
SELECT *
FROM DataCong.diagnosis AS d
INNER JOIN DataCong.encounter AS e
	ON d.encounterid = e.encounterid;
QUIT; /* 491077 rows and 19 columns */

PROC SQL;
CREATE TABLE DataCong.diagnosis_encounter AS
SELECT *
FROM diagnosis_encounter
WHERE (patid = patid_diagnosis) AND (admit_date = admit_date_diagnosis) AND (encounter_type = enc_type_diagnosis);
QUIT; /* 491054 rows and 19 columns */

PROC SQL;
CREATE TABLE diagnosis_encounter_error AS
SELECT *
FROM diagnosis_encounter
WHERE encounterid IN 
	(SELECT encounterid
	 FROM diagnosis_encounter
	 WHERE (patid ^= patid_diagnosis) OR (admit_date ^= admit_date_diagnosis) OR (encounter_type ^= enc_type_diagnosis)
	);
QUIT; /* !!!!!!!!!! NOTE: This identifies those rows where data doesn't match across tables. Isn't used further */

/* 2.6 Create Unique encounterid List for COVID+ Diagnosis Data of Inpatients Admitted Between 03/01/2020 And 02/28/2021 */
PROC SQL;
CREATE TABLE diagnosis_covid_encounterid AS
SELECT DISTINCT encounterid AS encounterid,
	   1 AS covid_diagnosis
FROM DataCong.diagnosis_encounter;
QUIT; /* 59380 rows */

PROC SQL;
CREATE TABLE diagnosis_covid_encounterid AS
SELECT encounterid,
	   patid,
	   admit_date,
	   1 AS covid_diagnosis
FROM DataCong.diagnosis_encounter;
QUIT; /* 491054 rows */

/*Comparing to above to ensure same number are identified each way*/

PROC SORT
DATA = diagnosis_covid_encounterid NODUP
DUPOUT = diagnosis_covid_encounterid_dup	/* 431674 duplicate encounterid */
OUT = DataCong.diagnosis_covid_encounterid;	/*  59380 unique encounterid */
BY encounterid;
RUN; 

PROC SORT
DATA = DataCong.diagnosis_covid_encounterid NODUPKEY
DUPOUT = diagnosis_covid_encounterid_dup	/* 0 duplicate encounterid */
OUT = diagnosis_covid_encounterid_uniq;		/* 59380 unique encounterid */
BY encounterid;
RUN; 

PROC SORT
DATA = DataCong.diagnosis_covid_encounterid NODUPKEY
DUPOUT = diagnosis_covid_encounterid_dup	/* 0 duplicate encounterid */
OUT = diagnosis_covid_encounterid_uniq;		/* 59380 unique encounterid */
BY patid admit_date encounterid;
RUN; 

PROC SORT
DATA = diagnosis_covid_encounterid_uniq NODUPKEY
DUPOUT = diagnosis_covid_encounterid_dup	/* !!!!!!!!!! WARNING: 26961 duplicate encounterid at the same admit_date for the same patid. Need to be removed from final dataset. !!!!!!!!!! */
OUT = diagnosis_covid_encounterid_date;		/* 32419 unique encounterid */
BY patid admit_date;
RUN; 

/* Action: Incorrect correspondences in Diagnosis Data are removed when applying patid = patid_diagnosis */

/* 3. Lab Data */
/* 3.1 Check Leading 0 in Charater Variables of Lab Data before Converting to Numeric Type */
PROC SQL;
SELECT count(*) AS num_encounterid_start_with_0	/* 0 row: No leading 0 in encounterid of lab data */
FROM DataSAS.lab_result_cm
WHERE substr(strip(encounterid),1,1) = '0';

SELECT count(*) AS num_patid_start_with_0		/* 0 row: No leading 0 in patid of lab data */
FROM DataSAS.lab_result_cm
WHERE substr(strip(ssid),1,1) = '0';
QUIT;

/* 3.2 Create COVID+ Lab Data of All Admit Dates */
PROC SQL;
CREATE TABLE DataCong.lab AS
SELECT lab_result_cm_id,
	   input(encounterid, best.) AS encounterid,	/* convert to numeric */
	   input(ssid, best.) AS patid_lab,				/* convert to numeric */
	   SPECIMEN_DATE AS specimen_date,				/* specimen_date within 7 days from admission */
	   upcase(strip(lab_px_type)) AS lab_px_type,
	   upcase(strip(lab_loinc)) AS lab_loinc,
	   upcase(strip(result_qual)) AS result_qual
FROM DataSAS.lab_result_cm
WHERE upcase(strip(lab_loinc)) IN ('94306-8','94309-2','94500-6','94502-2','94531-1','94532-9') /* Ref: COVID-19 Lab Codes */
	  AND upcase(strip(result_qual)) = 'POSITIVE'
ORDER BY encounterid, patid_lab, lab_result_cm_id;
QUIT; /* 151660 rows and 7 columns */

/* 3.3 Check Missings in COVID+ Lab Data of All Admit Dates */
PROC SQL;
SELECT NMISS(lab_result_cm_id) AS lab_result_cm_id_miss_num,				/* 0 obs */
	   NMISS(encounterid) AS encounterid_miss_num,							/* 33224 obs */ /* !!!!!!!!!! WARNING: 33224 missing encounterid !!!!!!!!!! */
	   NMISS(encounterid)/N(lab_result_cm_id) AS encounterid_miss_per,		/* 21.9069% obs */
	   NMISS(patid_lab) AS patid_miss_num,									/* 0 obs */
	   NMISS(specimen_date) AS specimen_date_miss_num,						/* 0 obs */
	   NMISS(lab_px_type) AS lab_px_type_miss_num,							/* 0 obs */
	   NMISS(lab_loinc) AS lab_loinc_miss_num,								/* 0 obs */
	   NMISS(result_qual) AS result_qual_miss_num							/* 0 obs */
FROM DataCong.lab;
QUIT;

/* 3.4 Check Duplicates in COVID+ Lab Data of All Admit Dates */
PROC SORT
DATA = DataCong.lab NODUPKEY
DUPOUT = lab_dup	/* 0 duplicate lab_result_cm_id */
OUT = lab_uniq;		/* 151660 unique lab_result_cm_id */
BY lab_result_cm_id;
RUN; 

PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid_lab) AS num_patid_per_encounter
	 FROM DataCong.lab
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

CREATE TABLE lab_dup_patid AS
SELECT *
FROM DataCong.lab
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.lab
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT patid_lab) > 1) /* !!!!!!!!!! WARNING: 6 encounterid correspond to 2 patid !!!!!!!!!! */
ORDER BY encounterid, patid_lab, specimen_date;
QUIT;

PROC SQL;
SELECT num_lab_result_per_encounter, COUNT(num_lab_result_per_encounter) AS num_encounter
FROM
	(SELECT encounterid, COUNT(lab_result_cm_id) AS num_lab_result_per_encounter /* ! NOTE: Many encounterid have multiple lab_result_cm_id ! */
	 FROM DataCong.lab
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid)
GROUP BY num_lab_result_per_encounter;

CREATE TABLE lab_result_dup AS
SELECT *, COUNT(lab_result_cm_id) AS num_lab_result_per_encounter
FROM DataCong.lab
WHERE encounterid IS NOT NULL
GROUP BY encounterid
HAVING num_lab_result_per_encounter >= 10 
ORDER BY num_lab_result_per_encounter, encounterid, patid_lab, specimen_date;
QUIT;

PROC SQL;
SELECT num_specimen_date_per_encounter, COUNT(num_specimen_date_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT specimen_date) AS num_specimen_date_per_encounter /* ! NOTE: many encounterid correspond to multiple specimen_date ! */
	 FROM DataCong.lab
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid)
GROUP BY num_specimen_date_per_encounter;

CREATE TABLE lab_dup_specimen_date AS
SELECT *
FROM DataCong.lab
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.lab
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT specimen_date) > 1)
ORDER BY encounterid, patid_lab, specimen_date;
QUIT;

/* 3.5 Create COVID+ Lab Data of Inpatients Admitted Between 03/01/2020 And 02/28/2021 with Specimen Dates within 7 Days of Addmitance */
PROC SQL;
CREATE TABLE lab_encounter AS
SELECT *,
	CASE
		WHEN specimen_date - admit_date > 7 THEN 1
		WHEN specimen_date - admit_date <= 7 AND specimen_date - admit_date >= 0 THEN 0
		WHEN specimen_date - admit_date < 0 AND specimen_date - admit_date IS NOT NULL THEN -1
		ELSE .
	END AS specimen_late
FROM DataCong.lab AS l
INNER JOIN DataCong.encounter AS e
	ON l.encounterid = e.encounterid;
QUIT; /* 10274 rows and 19 columns */

PROC SQL;
SELECT specimen_late, COUNT(lab_result_cm_id) AS num_specimen_late
FROM lab_encounter
GROUP BY specimen_late;
QUIT;

PROC SQL;
CREATE TABLE DataCong.lab_encounter AS
SELECT *
FROM lab_encounter
Where (patid = patid_lab) AND (specimen_late = 0);
QUIT;	/* 9302 rows and 19 columns, 9302 / 10274 = 90.5% */

/* 3.6 Create Unique encounterid List for COVID+ Lab Data of Inpatients Admitted Between 03/01/2020 And 02/28/2021 with Specimen Dates within 7 Days of Addmitance */
PROC SQL;
CREATE TABLE lab_covid_encounterid AS
SELECT DISTINCT encounterid AS encounterid,
	   1 AS covid_lab
FROM DataCong.lab_encounter;
QUIT; /* 8923 rows */

PROC SORT
DATA = lab_covid_encounterid NODUPKEY
DUPOUT = lab_covid_encounterid_dup		/* 0 duplicate encounterid */
OUT = DataCong.lab_covid_encounterid;	/* 8923 unique encounterid */
BY encounterid;
RUN; 

/* 3.7 Summary of Lab Data Cleaning.  */
/* Action: Incorrect correspondences in Lab Data are deleted when applying patid = patid_lab */
/*Not all patients with COVID-19 diagnosis have test data recorded within encounter. Use COVID Diagnosis ICD (which includes having a positive test)*/
/*to Define Cohort Rather than Testing*/


/* 4. COVID+ Population */
/* 4.1. Create Unique encounterid List for COVID+ Population from Diagnosis and Lab Data */
PROC SQL;
CREATE TABLE diagnosis_lab_covid_encounterid AS
SELECT CASE
		WHEN d.encounterid IS NOT NULL THEN d.encounterid
		WHEN d.encounterid IS NULL AND l.encounterid IS NOT NULL THEN l.encounterid
		ELSE .
	   END AS encounterid,
	   d.covid_diagnosis,
	   l.covid_lab
FROM DataCong.diagnosis_covid_encounterid AS d
FULL JOIN DataCong.lab_covid_encounterid AS l
	ON d.encounterid = l.encounterid;
QUIT; /* 64702 rows and 3 columns */

PROC SORT
DATA = diagnosis_lab_covid_encounterid NODUPKEY
DUPOUT = diagnosis_lab_covid_encounter_dp		/* 0 duplicate encounterid */
OUT = DataCong.diagnosis_lab_covid_encounterid;	/* 64702 unique encounterid */
BY encounterid;
RUN; 

PROC SQL;
SELECT N(covid_diagnosis) AS num_covid_diagnosis,			/* 59380 obs */
	   N(covid_diagnosis)/COUNT(*) AS per_covid_diagnosis,	/* 91.7746% obs */
	   N(covid_lab) AS num_covid_lab,						/* 8923 obs */ 
	   N(covid_lab)/COUNT(*) AS per_covid_lab				/* 13.7909% obs */  /* Both 3610 obs, 5.58% */
FROM DataCong.diagnosis_lab_covid_encounterid;
QUIT;

/* !!! NOTE !!!	*/
/*  Lab Data is incomplete. Likely not including test data done outside admittance			*/
/* Therefore, we do not use the result of 4.1 for the following steps!						*/
/* Instead, we use ONLY Diagnosis Data from 2.6 to define the COVID+ Population!			*/
/* !!! NOTE !!!	*/

/* 4.2 Create COVID+ Population for Insight Data */
PROC SQL;
CREATE TABLE DataCong.insight_covid_encounters AS
SELECT enct.*, diag.covid_diagnosis
FROM DataCong.encounter AS enct		 					/* From 1.4 */
INNER JOIN DataCong.diagnosis_covid_encounterid AS diag	/* From 2.6 */ /* ! Do NOT use the result of 4.1 ! */
	ON enct.encounterid = diag.encounterid
ORDER BY enct.patid, enct.admit_date, enct.encounterid;
QUIT; /* 59380 rows and 13 columns */


/*NOTE: patients can have multiple encounterids for the same admission. Thus need to use patientid (patid) and the date of admission to create population*/

PROC SQL;
CREATE TABLE insight_covid_encounters AS
SELECT *
FROM DataCong.insight_covid_encounters
WHERE encounterid IN
	(SELECT MIN(encounterid) AS min_encounterid
	 FROM DataCong.insight_covid_encounters
	 GROUP BY encounter_type, patid, admit_date, admit_date_phase, discharge_date, discharge_disposition, hospital_days, covid_diagnosis)
ORDER BY patid, admit_date, encounterid;
QUIT; /* 34924 rows and 13 columns */ /* Removes complete duplicates*/


/*NOTE: there are individuals with different encounter_types listed for same encounter. Refer to document rules of deduplicating encounters.xlsx and notes in code for cleaning*/

PROC SQL;
CREATE TABLE DataCong.insight_covid_encounters AS
SELECT *
FROM insight_covid_encounters
WHERE encounterid NOT IN
	(SELECT encounterid
	 FROM insight_covid_encounters
	 GROUP BY patid, admit_date, admit_date_phase, discharge_date, discharge_disposition, hospital_days, covid_diagnosis
	 HAVING COUNT(DISTINCT encounter_type) > 1 AND encounter_type = 'Inpatient')
ORDER BY patid, admit_date, encounterid;
QUIT; /* 33794 rows and 13 columns */ /*Of those that have more than one encounter_type listed, removes the Inpatient type (because these have both inpatient and EDtoInpatient)*/

PROC SQL;
CREATE TABLE insight_covid_encounters AS
SELECT *
FROM DataCong.insight_covid_encounters
WHERE encounterid NOT IN
	(SELECT encounterid
	 FROM DataCong.insight_covid_encounters
	 GROUP BY patid, admit_date, admit_date_phase, discharge_date, hospital_days, covid_diagnosis
	 HAVING COUNT(DISTINCT discharge_disposition) > 1 AND discharge_disposition = 'Unknown')
ORDER BY patid, admit_date, encounterid;
QUIT; /* 32687 rows and 13 columns */ /*Identifies those that have more than one discharge disposition listed and removes the one that is 'unknown'*/ 

PROC SQL;
CREATE TABLE DataCong.insight_covid_encounters AS
SELECT *
FROM insight_covid_encounters
WHERE encounterid NOT IN
	(SELECT encounterid
	 FROM insight_covid_encounters
	 GROUP BY patid, admit_date, admit_date_phase, discharge_date, hospital_days, covid_diagnosis
	 HAVING COUNT(DISTINCT discharge_disposition) > 1 AND hospital_days > 0 AND discharge_disposition = 'Expired')
ORDER BY patid, admit_date, encounterid;
QUIT; /* 32668 rows and 13 columns */ /*Identifies those that have more than one discharge disposition and removes the one where the person is 'expired'*/

PROC SQL;
CREATE TABLE insight_covid_encounters AS
SELECT *
FROM DataCong.insight_covid_encounters
WHERE encounterid NOT IN
	(SELECT encounterid
	 FROM DataCong.insight_covid_encounters
	 GROUP BY patid, admit_date, admit_date_phase, discharge_date, hospital_days, covid_diagnosis
	 HAVING COUNT(DISTINCT discharge_disposition) > 1 AND hospital_days = 0 AND discharge_disposition = 'Alive')
ORDER BY patid, admit_date, encounterid;
QUIT; /* 32666 rows and 13 columns */  /*Identifies those that have more than one discharge disposition and removes the one where the person is 'alive' when they haven't been in the*/
											/*hospital for at least 1 day*/

PROC SQL;
CREATE TABLE DataCong.insight_covid_encounters AS
SELECT *
FROM insight_covid_encounters
WHERE encounterid NOT IN
	(SELECT encounterid
	 FROM insight_covid_encounters
	 GROUP BY patid, admit_date, admit_date_phase, covid_diagnosis
	 HAVING COUNT(DISTINCT discharge_date) > 1 AND MIN(hospital_days) = 0 AND hospital_days = 0)
ORDER BY patid, admit_date, encounterid;
QUIT; /* 32451 rows and 13 columns */ /*Of those with more than one dischrage date, it removes the entry where the length of admission is less than 1 day*/

PROC SQL;
CREATE TABLE insight_covid_encounters AS
SELECT *
FROM DataCong.insight_covid_encounters
WHERE encounterid NOT IN
	(SELECT encounterid
	 FROM DataCong.insight_covid_encounters
	 GROUP BY patid, admit_date, admit_date_phase, covid_diagnosis
	 HAVING COUNT(DISTINCT discharge_date) > 1 AND MIN(hospital_days) ^= 0)
ORDER BY patid, admit_date, encounterid;
QUIT; /* 32387 rows and 13 columns */ /*Removes entries with more than one discharge date where at least one entry wasn't a 0 day entry*/

PROC SORT
DATA = insight_covid_encounters NODUPKEY
DUPOUT = insight_covid_encounters_dup		/* 0 duplicate encounterid at the same admit_date for the same patid */
OUT = DataCong.insight_covid_encounters;	/* 32387 unique encounterid */
BY patid admit_date;
RUN; 

/* 5. Demographic Data */
/* 5.1 Check Leading 0 in Charater Variables of Demographic Data before Converting to Numeric Type */
PROC SQL;
CREATE TABLE patid_demo AS
SELECT substr(strip(ssid),1,1) AS patid_1st
FROM DataSAS.demographic
WHERE substr(strip(ssid),1,1) = '0';
QUIT; /* 0 row: patid from demographic data has no leading 0 */

/* 5.2 Create Demographic Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.demographic AS
SELECT input(ssid, best.) AS patid, /* convert to numeric */
	   BIRTH_DATE AS birth_date,
	CASE 
	   WHEN upcase(strip(sex)) IS NULL THEN ''
	   WHEN upcase(strip(sex)) = 'F' THEN 'Female'
	   WHEN upcase(strip(sex)) = 'M' THEN 'Male'
	   WHEN upcase(strip(sex)) IN ('A','OT') THEN 'Other'
	   ELSE ''
	END AS sex,
	CASE
	   WHEN upcase(strip(race)) IS NULL THEN ''
	   WHEN upcase(strip(race)) = '01' THEN 'AmericanIndian_AlaskaNative'
	   WHEN upcase(strip(race)) = '02' THEN 'Asian'
	   WHEN upcase(strip(race)) = '03' THEN 'Black'
	   WHEN upcase(strip(race)) = '04' THEN 'NativeHawaiian_PI'
	   WHEN upcase(strip(race)) = '05' THEN 'White'
	   WHEN upcase(strip(race)) = '06' THEN 'MultipleRace'
	   WHEN upcase(strip(race)) = '07' THEN 'Declined'
	   WHEN upcase(strip(race)) = 'OT' THEN 'Other'
	   ELSE ''
	END AS race,
	CASE
	   WHEN upcase(strip(hispanic)) IS NULL THEN ''
	   WHEN upcase(strip(hispanic)) = 'Y' THEN 'Yes'
	   WHEN upcase(strip(hispanic)) = 'N' THEN 'No'
	   WHEN upcase(strip(hispanic)) = 'R' THEN 'Declined'
	   ELSE ''
	END AS hispanic
FROM DataSAS.demographic
WHERE CALCULATED patid IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters)
ORDER BY patid;
QUIT; /* 29119 rows and 5 columns */

/* 5.3 Check Duplicates in Demographic Data of COVID+ Patients */
PROC SORT
DATA = DataCong.demographic NODUPKEY
DUPOUT = demographic_dup	/* 0 duplicate patid */
OUT = demographic_uniq;		/* 29119 unique patid */
BY patid;
RUN;

/* 5.4 Check Missings in Demographic Data of COVID+ Patients */
PROC SQL;
SELECT NMISS(patid) AS patid_miss_num,			 		/* 0 obs */
	   NMISS(birth_date) AS birth_date_miss_num, 		/* 0 obs */
	   NMISS(sex) AS sex_miss_num,				 		/* 1 obs */
	   NMISS(sex)/N(patid) AS sex_miss_per,		 		/* 0.0034% obs */
	   NMISS(race) AS race_miss_num,			 		/* 2405 obs */
	   NMISS(race)/N(patid) AS race_miss_per,			/* 8.2592% obs */
	   NMISS(hispanic) AS hispanic_miss_num,	 		/* 2860 obs */
	   NMISS(hispanic)/N(patid) AS hispanic_miss_per	/* 9.8218% obs */
FROM demographic_uniq;
QUIT;

/* 5.5 Create Demographic Data of COVID+ Encounters */
PROC SQL;
CREATE TABLE demographic_covid AS
SELECT d.*, m.birth_date, INTCK('year', m.birth_date, admit_date) AS age, m.sex, m.race, m.hispanic
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN demographic_uniq AS m
	ON d.patid = m.patid
ORDER BY encounterid, patid, admit_date;
QUIT; /* 32387 rows and 18 columns */

/* 5.6 Check Missings in Demographic Data of COVID+ Encounters */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,			/* 0 obs */
	   NMISS(patid) AS patid_miss_num,			 			/* 0 obs */
	   NMISS(birth_date) AS birth_date_miss_num, 			/* 0 obs */
	   NMISS(age) AS age_miss_num, 							/* 0 obs */
	   NMISS(sex) AS sex_miss_num,				 			/* 3 obs */
	   NMISS(sex)/N(encounterid) AS sex_miss_per,			/* 0.0093% obs */
	   NMISS(race) AS race_miss_num,			 			/* 2714 obs */
	   NMISS(race)/N(encounterid) AS race_miss_per,			/* 8.3799% obs */
	   NMISS(hispanic) AS hispanic_miss_num,	 			/* 3098 obs */
	   NMISS(hispanic)/N(encounterid) AS hispanic_miss_per	/* 9.5656% obs */
FROM demographic_covid;
QUIT;

/* 5.7 Check Duplicates in Demographic Data of COVID+ Encounters */
PROC SORT
DATA = demographic_covid NODUP
DUPOUT = demographic_covid_dup	/* 0 duplicate rows */
OUT = demographic_covid_uniq;	/* 32387 unique rows */
BY encounterid;
RUN;

PROC SORT
DATA = demographic_covid_uniq NODUPKEY
DUPOUT = demo_covid_dup_encounterid	/* 0 duplicate encounterid */
OUT = DataCong.demographic_covid;	/* 32387 unique encounterid */
BY encounterid;
RUN;



/* 6. Address Data */
/* 6.1 Check Leading 0 in Charater Variables of Address Data before Converting to Numeric Type */
PROC SQL;
CREATE TABLE patid_address AS
SELECT substr(strip(ssid),1,1) AS patid_1st
FROM DataSAS.lds_address_history
WHERE substr(strip(ssid),1,1) = '0';
QUIT; /* 0 row: patid from address data has no leading 0 */

/* 6.2 Create Address Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.address AS
SELECT addressid,
	   input(ssid, best.) AS patid, /* convert to numeric */
	   upcase(strip(address_state)) AS address_state,
	   upcase(strip(address_city)) AS address_city,
	   upcase(strip(address_zip5)) AS address_zip5,
	   upcase(strip(address_zip9)) AS address_zip9,
	CASE
		WHEN strip(address_zip5) IS NOT NULL THEN upcase(strip(address_zip5))
		WHEN strip(address_zip9) IS NOT NULL THEN upcase(substr(strip(address_zip9),1,5))
		ELSE ''
	END AS address_zip,
	   ADDRESS_PERIOD_START AS address_period_start,
	   ADDRESS_PERIOD_END AS address_period_end
FROM DataSAS.lds_address_history
WHERE CALCULATED patid IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters)
ORDER BY patid, address_period_start, address_period_end, address_zip;
QUIT; /* 80293 rows and 9 columns */

/* 6.3 Check Duplicates in Address Data of COVID+ Patients */
PROC SORT
DATA = DataCong.address NODUPKEY
DUPOUT = address_dup 	/*     0 duplicate addressid */
OUT = address_uniq;		/* 80293 unique addressid */
BY addressid;
RUN;

PROC SORT
DATA = address_uniq NODUPKEY
DUPOUT = address_dup	/*     0 duplicate rows */
OUT = address;			/* 80293 unique rows */
BY patid address_state address_city address_zip5 address_zip9 address_zip address_period_start address_period_end addressid;
RUN;

PROC SORT
DATA = address NODUPKEY
DUPOUT = address_dup	/* 26403 duplicate rows: ONLY addressid is different, while the rest variables have the same values */
OUT = address_uniq;		/* 53890 unique rows: Keep the smallest addressid, while the rest variables have the same values */
BY patid address_state address_city address_zip5 address_zip9 address_zip address_period_start address_period_end;
RUN;

PROC SQL;
CREATE TABLE address_zip_dup AS
SELECT u.*, d.num_address_zip_per_patid_start
FROM address_uniq as u
RIGHT JOIN
	(SELECT patid, address_period_start, COUNT(address_zip) AS num_address_zip_per_patid_start
	 FROM address_uniq
	 GROUP BY patid, address_period_start
	 HAVING CALCULATED num_address_zip_per_patid_start ^= 1) AS d	/* WARNING: many encounterid correspond to hundreds of address_zip! */
	ON u.patid = d.patid AND u.address_period_start = d.address_period_start
ORDER BY patid, address_period_start;
QUIT;
/* patid 291004 matches 2 zipcodes on the same address_period_start date 20SEP2019:				*/
/* 1. address_period_end date for zipcode 10705 is 28SEP2019									*/
/* 2. address_period_end date for zipcode 10456 is missing, which could be later than 28SEP2019 */
/* Solution: Keep the record with missing address_period_end date								*/

PROC SORT
DATA = address_uniq NODUPKEY
DUPOUT = address_dup	/*     0 duplicate rows */
OUT = address;			/* 53890 unique rows */
BY patid address_period_start address_period_end;
RUN;

PROC SORT
DATA = address NODUPKEY
DUPOUT = address_dup	/* 1 duplicate row for each patient on the same address_period_start date */
OUT = address_uniq;		/* 53889 unique rows for each patient on the same address_period_start date */
BY patid address_period_start;
RUN;

/* 6.4 Check Missings in Address Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.address AS
SELECT *
FROM address_uniq
WHERE NOT (address_state IS NULL AND address_city IN ('BEIJING', 'HONG KONG', 'KYVYI RIH')); /* address_state is missing for foreign cities */
QUIT; /* 53886 rows and 9 columns */

PROC SQL;
SELECT NMISS(addressid) AS addressid_miss_num,								/* 0 obs */
	   NMISS(patid) AS patid_miss_num,										/* 0 obs */
	   NMISS(address_state) AS address_state_miss_num,						/* 1 obs */
	   NMISS(address_state)/N(patid) AS address_state_miss_per,				/* 0.0019% obs */
	   NMISS(address_city) AS address_city_miss_num,						/* 1 obs */ 
	   NMISS(address_city)/N(patid) AS address_city_miss_per,				/* 0.0019% obs */
	   NMISS(address_zip5) AS address_zip5_miss_num,						/* 5578 obs */
	   NMISS(address_zip5)/N(patid) AS address_zip5_miss_per,				/* 10.3515% obs */
	   NMISS(address_zip9) AS address_zip9_miss_num, 						/* 48309 obs */
	   NMISS(address_zip9)/N(patid) AS address_zip9_miss_per,				/* 89.6504% obs */
	   NMISS(address_zip) AS address_zip_miss_num, 							/* 1 obs */
	   NMISS(address_zip)/N(patid) AS address_zip_miss_per,					/* 0.0019% obs */
	   NMISS(address_period_start) AS address_period_start_miss_num,		/* 0 obs */
	   NMISS(address_period_end) AS address_period_end_miss_num,			/* 53838 obs */
   	   NMISS(address_period_end)/N(patid) AS address_period_end_miss_per	/* 99.9109% obs */
FROM DataCong.address;
QUIT;

/* 6.5 Create Address Data of COVID+ Encounters */
PROC SQL;
CREATE TABLE DataCong.address_covid AS
SELECT d.*, a.addressid, a.address_state, a.address_city, a.address_zip5, a.address_zip9, a.address_zip, a.address_period_start, a.address_period_end, 
	   INTCK('day', address_period_start, admit_date) AS admit_addr_start_date_diff
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN DataCong.address AS a
	ON d.patid = a.patid
WHERE address_period_start <= admit_date
ORDER BY encounterid, admit_date, address_period_start;
QUIT; /* 59589 rows and 22 columns */

PROC SQL;
CREATE TABLE address_covid AS
SELECT a.*, m.min_admit_addr_start_date_diff
FROM DataCong.address_covid AS a
LEFT JOIN
		(SELECT encounterid, MIN(admit_addr_start_date_diff) AS min_admit_addr_start_date_diff
		 FROM DataCong.address_covid
		 GROUP BY encounterid) AS m
	ON a.encounterid = m.encounterid
WHERE admit_addr_start_date_diff = min_admit_addr_start_date_diff;
QUIT; /* 32304 rows and 23 columns */

PROC SORT
DATA = address_covid NODUP
DUPOUT = address_covid_dup	/* 0 duplicate rows */
OUT = address_covid_uniq;	/* 32304 unique rows */
BY encounterid;
RUN;

PROC SQL;
CREATE TABLE address_covid AS
SELECT d.*, a.addressid, a.address_state, a.address_city, a.address_zip5, a.address_zip9, a.address_zip, a.address_period_start, a.address_period_end, 
	   a.admit_addr_start_date_diff, a.min_admit_addr_start_date_diff
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN address_covid_uniq AS a
	ON d.encounterid = a.encounterid
ORDER BY encounterid, admit_date, address_period_start;
QUIT; /* 32387 rows and 23 columns */

/* 6.6 Check Missings in Address Data of COVID+ Encounters */
PROC SQL;
SELECT NMISS(addressid) AS addressid_miss_num,										/* 676 obs */
	   NMISS(addressid)/N(encounterid) AS addressid_miss_per,						/* 2.0873% obs */
	   NMISS(patid) AS patid_miss_num,												/* 0 obs */
	   NMISS(address_state) AS address_state_miss_num,								/* 677 obs */
	   NMISS(address_state)/N(encounterid) AS address_state_miss_per,				/* 2.0903% obs */
	   NMISS(address_city) AS address_city_miss_num,								/* 677 obs */ 
	   NMISS(address_city)/N(encounterid) AS address_city_miss_per,					/* 2.0903% obs */
	   NMISS(address_zip5) AS address_zip5_miss_num,								/* 4336 obs */
	   NMISS(address_zip5)/N(encounterid) AS address_zip5_miss_per,					/* 13.3881% obs */
	   NMISS(address_zip9) AS address_zip9_miss_num, 								/* 28727 obs */
	   NMISS(address_zip9)/N(encounterid) AS address_zip9_miss_per,					/* 88.6992% obs */ /*Most do not have 9-digit ZIP*/
	   NMISS(address_zip) AS address_zip_miss_num, 									/* 676 obs */
	   NMISS(address_zip)/N(encounterid) AS address_zip_miss_per,					/* 2.0873% obs */
	   NMISS(address_period_start) AS address_period_start_miss_num,				/* 676 obs */
   	   NMISS(address_period_start)/N(encounterid) AS address_period_start_miss_per,	/* 2.0873% obs */
	   NMISS(address_period_end) AS address_period_end_miss_num,					/* 32382 obs */
   	   NMISS(address_period_end)/N(encounterid) AS address_period_end_miss_per		/* 99.9846% obs */
FROM address_covid;
QUIT;

/* 6.7 Check Duplicates in Address Data of COVID+ Encounters */
PROC SORT
DATA = address_covid NODUP
DUPOUT = address_covid_dup	/* 0 duplicate rows */
OUT = address_covid_uniq;	/* 32387 unique rows */
BY encounterid;
RUN;

PROC SORT
DATA = address_covid_uniq NODUPKEY
DUPOUT = address_covid_dup_encounterid	/* 0 duplicate encounterid */
OUT = DataCong.address_covid;			/* 32387 unique encounterid */
BY encounterid;
RUN;



/* 7. Comorbidities Data */	/* Note: Comorbidities must be recorded no later than the admit date of COVID+ Diagnosis. */
/* 7.1 Diabetes Data */
/* 7.1.1 Create Diabetes Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.comorbidity_diabetes AS
SELECT diagnosisid,
	   input(encounterid, best.) AS encounterid, /* convert to numeric, for linking encounter data */
	   upcase(strip(enc_type)) AS enc_type_diabetes,
	   input(ssid, best.) AS patid_diabetes,	 /* convert to numeric */
	   ADMIT_DATE AS admit_date_diabetes,
	   DX_DATE AS dx_date,
	   upcase(strip(dx_type)) AS dx_type,
       upcase(strip(dx)) AS dx,
	CASE
		WHEN substr(upcase(strip(dx)),1,3) IN ('E08','E09','E10','E11','E12','E13') THEN 1
		ELSE 0
	END AS diabetes
FROM DataSAS.diagnosis
WHERE CALCULATED patid_diabetes IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters)
	  AND CALCULATED diabetes = 1
ORDER BY encounterid, patid_diabetes, diagnosisid;
QUIT; /* 861163 rows and 9 columns */

/* 7.1.2 Check Duplicates in Diabetes Data of COVID+ Patients */
PROC SORT
DATA = DataCong.comorbidity_diabetes NODUPKEY
DUPOUT = comorbidity_diabetes_dup	/* 0 duplicate diagnosisid */
OUT = comorbidity_diabetes_uniq;	/* 861163 unique diagnosisid */
BY diagnosisid;
RUN; 

PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid_diabetes) AS num_patid_per_encounter
	 FROM DataCong.comorbidity_diabetes
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

CREATE TABLE comorbidity_diabetes_dup_patid AS
SELECT *
FROM DataCong.comorbidity_diabetes
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.comorbidity_diabetes
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT patid_diabetes) > 1) /* !!!!!!!!!! ERROR: 2 encounterid correspond to 2 patid !!!!!!!!!! */
ORDER BY encounterid, patid_diabetes, admit_date_diabetes;
QUIT;

PROC SQL;
SELECT num_admit_date_per_encounter, COUNT(num_admit_date_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT admit_date_diabetes) AS num_admit_date_per_encounter
	 FROM DataCong.comorbidity_diabetes
	 GROUP BY encounterid)
GROUP BY num_admit_date_per_encounter;

CREATE TABLE comorbidity_dup_admit_date AS
SELECT *
FROM DataCong.comorbidity_diabetes
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.comorbidity_diabetes
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT admit_date_diabetes) > 1) /* !!!!!!!!!! WARNING: 2 encounterid correspond to 2 admit_date !!!!!!!!!! */
ORDER BY encounterid, patid_diabetes, admit_date_diabetes;

SELECT *
FROM comorbidity_dup_admit_date
WHERE diagnosisid NOT IN
	(SELECT diagnosisid
	 FROM comorbidity_diabetes_dup_patid); /* 0 row: All duplicate admit_date are due to duplicate patid */
QUIT;

PROC SQL;
CREATE TABLE DataCong.comorbidity_diabetes AS
SELECT *
FROM comorbidity_diabetes_uniq;
QUIT; /* 861117 rows and 9 columns */


PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid_diabetes) AS num_patid_per_encounter	/* Each encounterid of Diabetes Data corresponds to ONLY 1 patid_diabetes */
	 FROM DataCong.comorbidity_diabetes
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

SELECT num_admit_date_per_encounter, COUNT(num_admit_date_per_encounter) AS num_encounter /* Each encounterid of Diabetes Data corresponds to ONLY 1 admit_date_diabetes */
FROM
	(SELECT COUNT(DISTINCT admit_date_diabetes) AS num_admit_date_per_encounter
	 FROM DataCong.comorbidity_diabetes
	 GROUP BY encounterid)
GROUP BY num_admit_date_per_encounter;
QUIT;

/* 7.1.3 Check Missings in Diabetes Data of COVID+ Patients */
PROC SQL;
SELECT NMISS(diagnosisid) AS diagnosisid_miss_num,			/* 0 obs */
	   NMISS(encounterid) AS encounterid_miss_num,			/* 0 obs */
	   NMISS(patid_diabetes) AS patid_miss_num,				/* 0 obs */
	   NMISS(admit_date_diabetes) AS admit_date_miss_num,	/* 0 obs */
	   NMISS(enc_type_diabetes) AS enc_type_miss_num,		/* 0 obs */
	   NMISS(dx_date) AS dx_date_miss_num,					/* 560338 obs */
	   NMISS(dx_date)/N(diagnosisid) AS dx_date_miss_per,	/* 65.0711% obs */
	   NMISS(dx_type) AS dx_type_miss_num,					/* 0 obs */
	   NMISS(dx) AS dx_miss_num								/* 0 obs */
FROM DataCong.comorbidity_diabetes;
QUIT;

/* 7.1.4 Create Diabetes Data of COVID+ Encounters */
PROC SQL;
CREATE TABLE comorbidity_diabetes_covid AS
SELECT d.*, c.diagnosisid, c.admit_date_diabetes, c.enc_type_diabetes, c.dx_date, c.dx_type, c.dx, c.diabetes,
	CASE
		WHEN diabetes = 1 THEN 1
		ELSE 0
	END AS diabetes_updated
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN DataCong.comorbidity_diabetes AS c
	ON d.patid = c.patid_diabetes
WHERE NOT (admit_date IS NOT NULL AND admit_date < admit_date_diabetes)
ORDER BY encounterid, admit_date, admit_date_diabetes;
QUIT; /* 922400 rows and 21 columns */

PROC SQL;
SELECT num_diabetes_per_encounter, COUNT(num_diabetes_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT diabetes_updated) AS num_diabetes_per_encounter	/* Each encounterid of Diabetes Data corresponds to ONLY 1 diabetes status */
	 FROM comorbidity_diabetes_covid
	 GROUP BY encounterid)
GROUP BY num_diabetes_per_encounter;
QUIT;

PROC SORT
DATA = comorbidity_diabetes_covid NODUPKEY
DUPOUT = comorbidity_diabetes_covid_dup	/* 758980 duplicate rows */
OUT = comorbidity_diabetes_covid_uniq;	/* 163420 unique rows */
BY encounterid admit_date_diabetes;
RUN;

PROC SORT
DATA = comorbidity_diabetes_covid_uniq NODUPKEY
DUPOUT = comorbidity_diabetes_covid_dup	/* 131381 duplicate encounterid */
OUT = comorbidity_diabetes_covid;		/*  32039 unique encounterid */
BY encounterid;
RUN;

PROC SQL;
CREATE TABLE DataCong.comorbidity_diabetes_covid AS
SELECT d.*, c.admit_date_diabetes,
	CASE
		WHEN c.diabetes_updated = 1 THEN 1
		ELSE 0
	END AS diabetes
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN comorbidity_diabetes_covid AS c
	ON d.encounterid = c.encounterid
ORDER BY encounterid, admit_date, admit_date_diabetes;
QUIT; /* 32387 rows and 15 columns */

/* 7.1.5 Check Missings in Diabetes Data of COVID+ Encounters */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,						/* 0 obs */
	   NMISS(patid) AS patid_miss_num,									/* 0 obs */
	   NMISS(admit_date) AS admit_date_miss_num,						/* 0 obs */
	   NMISS(covid_diagnosis) AS covid_diagnosis_miss_num,				/* 0 obs */
	   NMISS(admit_date_diabetes) AS diabetes_date_miss_num,			/* 19064 obs */
	   NMISS(admit_date_diabetes)/count(*) AS diabetes_date_miss_per,	/* 58.8631% obs */
	   NMISS(diabetes) AS diabetes_miss_num								/* 0 obs */
FROM DataCong.comorbidity_diabetes_covid;
QUIT;

/* 7.1.6 Check Duplicates in Diabetes Data of COVID+ Encounters */
PROC SQL;
SELECT num_diabetes_per_encounter, COUNT(num_diabetes_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT diabetes) AS num_diabetes_per_encounter	/* Each encounterid of Diabetes Data corresponds to ONLY 1 diabetes status */
	 FROM DataCong.comorbidity_diabetes_covid
	 GROUP BY encounterid)
GROUP BY num_diabetes_per_encounter;
QUIT;

PROC SORT
DATA = DataCong.comorbidity_diabetes_covid NODUPKEY
DUPOUT = comorbidity_diabetes_covid_dup	/* 0 duplicate rows */
OUT = comorbidity_diabetes_covid_uniq;	/* 32387 unique rows */
BY encounterid admit_date_diabetes;
RUN;

PROC SORT
DATA = comorbidity_diabetes_covid_uniq NODUPKEY
DUPOUT = comorbidity_diabetes_covid_dup		/* 0 duplicate encounterid */
OUT = DataCong.comorbidity_diabetes_covid;	/* 32387 unique encounterid */
BY encounterid;
RUN;


/* 7.2 Asthma Data */
/* 7.2.1 Create Asthma Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.comorbidity_asthma AS
SELECT diagnosisid,
	   input(encounterid, best.) AS encounterid, 	/* convert to numeric, for linking encounter data */
	   upcase(strip(enc_type)) AS enc_type_asthma,
	   input(ssid, best.) AS patid_asthma,	 		/* convert to numeric */
	   ADMIT_DATE AS admit_date_asthma,
	   DX_DATE AS dx_date,
	   upcase(strip(dx_type)) AS dx_type,
       upcase(strip(dx)) AS dx,
	CASE
		WHEN substr(upcase(strip(dx)),1,5) IN ('J45.2','J45.3','J45.4','J45.5') OR substr(upcase(strip(dx)),1,6) IN ('J45.90') THEN 1
		ELSE 0
	END AS asthma
FROM DataSAS.diagnosis
WHERE CALCULATED patid_asthma IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters)
	  AND CALCULATED asthma = 1
ORDER BY encounterid, patid_asthma, diagnosisid;
QUIT; /* 110188 rows and 9 columns */

/* 7.2.2 Check Duplicates in Asthma Data of COVID+ Patients */
PROC SORT
DATA = DataCong.comorbidity_asthma NODUPKEY
DUPOUT = comorbidity_asthma_dup	/* 0 duplicate diagnosisid */
OUT = comorbidity_asthma_uniq;	/* 110188 unique diagnosisid */
BY diagnosisid;
RUN; 

PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid_asthma) AS num_patid_per_encounter
	 FROM DataCong.comorbidity_asthma
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

CREATE TABLE comorbidity_asthma_dup_patid AS
SELECT *
FROM DataCong.comorbidity_asthma
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.comorbidity_asthma
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT patid_asthma) > 1) /* !!!!!!!!!! ERROR: 2 encounterid correspond to 2 patid !!!!!!!!!! */
ORDER BY encounterid, patid_asthma, admit_date_asthma;
QUIT;

PROC SQL;
SELECT num_admit_date_per_encounter, COUNT(num_admit_date_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT admit_date_asthma) AS num_admit_date_per_encounter
	 FROM DataCong.comorbidity_asthma
	 GROUP BY encounterid)
GROUP BY num_admit_date_per_encounter;

CREATE TABLE comorbidity_dup_admit_date AS
SELECT *
FROM DataCong.comorbidity_asthma
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.comorbidity_asthma
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT admit_date_asthma) > 1) /* !!!!!!!!!! WARNING: 2 encounterid correspond to 2 admit_date !!!!!!!!!! */
ORDER BY encounterid, patid_asthma, admit_date_asthma;

SELECT *
FROM comorbidity_dup_admit_date
WHERE diagnosisid NOT IN
	(SELECT diagnosisid
	 FROM comorbidity_asthma_dup_patid); /* 0 row: All duplicate admit_date are due to duplicate patid. OK since we are matching on patid only. */
QUIT;

PROC SQL;
CREATE TABLE DataCong.comorbidity_asthma AS
SELECT *
FROM comorbidity_asthma_uniq;
QUIT; /* 110177 rows and 9 columns */


PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid_asthma) AS num_patid_per_encounter	/* Each encounterid of Asthma Data corresponds to ONLY 1 patid_asthma */
	 FROM DataCong.comorbidity_asthma
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

SELECT num_admit_date_per_encounter, COUNT(num_admit_date_per_encounter) AS num_encounter	/* Each encounterid of Asthma Data corresponds to ONLY 1 admit_date_asthma */
FROM
	(SELECT COUNT(DISTINCT admit_date_asthma) AS num_admit_date_per_encounter
	 FROM DataCong.comorbidity_asthma
	 GROUP BY encounterid)
GROUP BY num_admit_date_per_encounter;
QUIT;

/* 7.2.3 Check Missings in Asthma Data of COVID+ Patients */
PROC SQL;
SELECT NMISS(diagnosisid) AS diagnosisid_miss_num,		/* 0 obs */
	   NMISS(encounterid) AS encounterid_miss_num,		/* 0 obs */
	   NMISS(patid_asthma) AS patid_miss_num,			/* 0 obs */
	   NMISS(admit_date_asthma) AS admit_date_miss_num,	/* 0 obs */
	   NMISS(enc_type_asthma) AS enc_type_miss_num,		/* 0 obs */
	   NMISS(dx_date) AS dx_date_miss_num,				/* 71543 obs */
	   NMISS(dx_date)/count(*) AS dx_date_miss_per,		/* 64.9346% obs */
	   NMISS(dx_type) AS dx_type_miss_num,				/* 0 obs */
	   NMISS(dx) AS dx_miss_num							/* 0 obs */
FROM DataCong.comorbidity_asthma;
QUIT;

/* 7.2.4 Create Asthma Data of COVID+ Encounters */
PROC SQL;
CREATE TABLE comorbidity_asthma_covid AS
SELECT d.*, c.diagnosisid, c.admit_date_asthma, c.enc_type_asthma, c.dx_date, c.dx_type, c.dx, c.asthma,
	CASE
		WHEN asthma = 1 THEN 1
		ELSE 0
	END AS asthma_updated
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN DataCong.comorbidity_asthma AS c
	ON d.patid = c.patid_asthma
WHERE NOT (admit_date IS NOT NULL AND admit_date < admit_date_asthma)
ORDER BY encounterid, admit_date, admit_date_asthma;
QUIT; /* 137375 rows and 21 columns */

PROC SQL;
SELECT num_asthma_per_encounter, COUNT(num_asthma_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT asthma_updated) AS num_asthma_per_encounter	/* Each encounterid of Diabetes Data corresponds to ONLY 1 asthma status */
	 FROM comorbidity_asthma_covid
	 GROUP BY encounterid)
GROUP BY num_asthma_per_encounter;
QUIT;

PROC SORT
DATA = comorbidity_asthma_covid NODUPKEY
DUPOUT = comorbidity_asthma_covid_dup	/* 81534 duplicate rows */
OUT = comorbidity_asthma_covid_uniq;	/* 55841 unique rows */
BY encounterid admit_date_asthma;
RUN;

PROC SORT
DATA = comorbidity_asthma_covid_uniq NODUPKEY
DUPOUT = comorbidity_asthma_covid_dup	/* 23683 duplicate encounterid */
OUT = comorbidity_asthma_covid;			/* 32158 unique encounterid */
BY encounterid;
RUN;

PROC SQL;
CREATE TABLE DataCong.comorbidity_asthma_covid AS
SELECT d.*, c.admit_date_asthma,
	CASE
		WHEN c.asthma_updated = 1 THEN 1
		ELSE 0
	END AS asthma
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN comorbidity_asthma_covid AS c
	ON d.encounterid = c.encounterid
ORDER BY encounterid, admit_date, admit_date_asthma;
QUIT; /* 32387 rows and 15 columns */

/* 7.2.5 Check Missings in Asthma Data of COVID+ Encounters */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,					/* 0 obs */
	   NMISS(patid) AS patid_miss_num,								/* 0 obs */
	   NMISS(admit_date) AS admit_date_miss_num,					/* 0 obs */
	   NMISS(covid_diagnosis) AS covid_diagnosis_miss_num,			/* 0 obs */
	   NMISS(admit_date_asthma) AS asthma_date_miss_num,			/* 27389 obs */
	   NMISS(admit_date_asthma)/count(*) AS asthma_date_miss_per,	/* 84.5679% obs */
	   NMISS(asthma) AS asthma_miss_num								/* 0 obs */
FROM DataCong.comorbidity_asthma_covid;
QUIT;

/* 7.2.6 Check Duplicates in Asthma Data of COVID+ Encounters */
PROC SQL;
SELECT num_asthma_per_encounter, COUNT(num_asthma_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT asthma) AS num_asthma_per_encounter	/* Each encounterid of Diabetes Data corresponds to ONLY 1 asthma status */
	 FROM DataCong.comorbidity_asthma_covid
	 GROUP BY encounterid)
GROUP BY num_asthma_per_encounter;
QUIT;

PROC SORT
DATA = DataCong.comorbidity_asthma_covid NODUPKEY
DUPOUT = comorbidity_asthma_covid_dup	/* 0 duplicate rows */
OUT = comorbidity_asthma_covid_uniq;	/* 32387 unique rows */
BY encounterid admit_date_asthma;
RUN;

PROC SORT
DATA = comorbidity_asthma_covid_uniq NODUPKEY
DUPOUT = comorbidity_asthma_covid_dup		/* 0 duplicate encounterid */
OUT = DataCong.comorbidity_asthma_covid;	/* 32387 unique encounterid */
BY encounterid;
RUN;

/* 7.3 Hypertension Data */
/* 7.3.1 Create Hypertension Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.comorbidity_hyper AS
SELECT diagnosisid,
	   input(encounterid, best.) AS encounterid, 	/* convert to numeric, for linking encounter data */
	   upcase(strip(enc_type)) AS enc_type_hyper,
	   input(ssid, best.) AS patid_hyper,	 		/* convert to numeric */
	   ADMIT_DATE AS admit_date_hyper,
	   DX_DATE AS dx_date,
	   upcase(strip(dx_type)) AS dx_type,
       upcase(strip(dx)) AS dx,
	CASE
		WHEN substr(upcase(strip(dx)),1,3) IN ('I10','I11','I12','I13')  THEN 1
		ELSE 0
	END AS hyper
FROM DataSAS.diagnosis
WHERE CALCULATED patid_hyper IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters)
	  AND CALCULATED hyper = 1
ORDER BY encounterid, patid_hyper, diagnosisid;
QUIT; /* 792600 rows and 9 columns */

/* 7.3.2 Check Duplicates in hypertension Data of COVID+ Patients */
PROC SORT
DATA = DataCong.comorbidity_hyper NODUPKEY
DUPOUT = comorbidity_hyper_dup	/* 0 duplicate diagnosisid */
OUT = comorbidity_hyper_uniq;	/* 792600 unique diagnosisid */
BY diagnosisid;
RUN; 

PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid_hyper) AS num_patid_per_encounter
	 FROM DataCong.comorbidity_hyper
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

CREATE TABLE comorbidity_hyper_dup_patid AS
SELECT *
FROM DataCong.comorbidity_hyper
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.comorbidity_hyper
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT patid_hyper) > 1) /* !!!!!!!!!! WARNING: 10 encounterid correspond to 2 patid !!!!!!!!!! */
ORDER BY encounterid, patid_hyper, admit_date_hyper;
QUIT;

PROC SQL;
SELECT num_admit_date_per_encounter, COUNT(num_admit_date_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT admit_date_hyper) AS num_admit_date_per_encounter
	 FROM DataCong.comorbidity_hyper
	 GROUP BY encounterid)
GROUP BY num_admit_date_per_encounter;

CREATE TABLE comorbidity_dup_admit_date AS
SELECT *
FROM DataCong.comorbidity_hyper
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.comorbidity_hyper
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT admit_date_hyper) > 1) /* !!!!!!!!!! WARNING: 10 encounterid correspond to 2 admit_date !!!!!!!!!! */
ORDER BY encounterid, patid_hyper, admit_date_hyper;

SELECT *
FROM comorbidity_dup_admit_date
WHERE diagnosisid NOT IN
	(SELECT diagnosisid
	 FROM comorbidity_hyper_dup_patid); /* 0 row: All duplicate admit_date are due to same encounterids for patid. Okay since we are just appending onto patid */
QUIT;

PROC SQL;
CREATE TABLE DataCong.comorbidity_hyper AS
SELECT *
FROM comorbidity_hyper_uniq;
QUIT; /* 792600 rows and 9 columns */


PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid_hyper) AS num_patid_per_encounter	/* Each encounterid of hyper Data corresponds to ONLY 1 patid_hyper */
	 FROM DataCong.comorbidity_hyper
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

SELECT num_admit_date_per_encounter, COUNT(num_admit_date_per_encounter) AS num_encounter	/* Each encounterid of hyper Data corresponds to ONLY 1 admit_date_hyper */
FROM
	(SELECT COUNT(DISTINCT admit_date_hyper) AS num_admit_date_per_encounter
	 FROM DataCong.comorbidity_hyper
	 GROUP BY encounterid)
GROUP BY num_admit_date_per_encounter;
QUIT;

/* 7.3.3 Check Missings in hypertension Data of COVID+ Patients */
PROC SQL;
SELECT NMISS(diagnosisid) AS diagnosisid_miss_num,		/* 0 obs */
	   NMISS(encounterid) AS encounterid_miss_num,		/* 0 obs */
	   NMISS(patid_hyper) AS patid_miss_num,			/* 0 obs */
	   NMISS(admit_date_hyper) AS admit_date_miss_num,	/* 0 obs */
	   NMISS(enc_type_hyper) AS enc_type_miss_num,		/* 0 obs */
	   NMISS(dx_date) AS dx_date_miss_num,				/* 425472 obs */
	   NMISS(dx_date)/count(*) AS dx_date_miss_per,		/* 53.6805% obs */
	   NMISS(dx_type) AS dx_type_miss_num,				/* 0 obs */
	   NMISS(dx) AS dx_miss_num							/* 0 obs */
FROM DataCong.comorbidity_hyper;
QUIT;

/* 7.3.4 Create hypertension Data of COVID+ Encounters: note joining by patid and then order by encounter */
PROC SQL;
CREATE TABLE comorbidity_hyper_covid AS
SELECT d.*, c.diagnosisid, c.admit_date_hyper, c.enc_type_hyper, c.dx_date, c.dx_type, c.dx, c.hyper,
	CASE
		WHEN hyper = 1 THEN 1
		ELSE 0
	END AS hyper_updated
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN DataCong.comorbidity_hyper AS c
	ON d.patid = c.patid_hyper
WHERE NOT (admit_date IS NOT NULL AND admit_date < admit_date_hyper)
ORDER BY encounterid, admit_date, admit_date_hyper;
QUIT; /* 804150 rows and 21 columns */

PROC SQL;
SELECT num_hyper_per_encounter, COUNT(num_hyper_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT hyper_updated) AS num_hyper_per_encounter	/* Each encounterid of Hypertension Data (from COVID data) corresponds to ONLY 1 hypertension status */
	 FROM comorbidity_hyper_covid
	 GROUP BY encounterid)
GROUP BY num_hyper_per_encounter;
QUIT;

PROC SORT
DATA = comorbidity_hyper_covid NODUPKEY
DUPOUT = comorbidity_hyper_covid_dup	/* 633539 duplicate rows */
OUT = comorbidity_hyper_covid_uniq;	/* 55841 unique rows */
BY encounterid admit_date_hyper;
RUN;

PROC SORT
DATA = comorbidity_hyper_covid_uniq NODUPKEY
DUPOUT = comorbidity_hyper_covid_dup	/* 23683 duplicate encounterid */
OUT = comorbidity_hyper_covid;			/* 32158 unique encounterid */
BY encounterid;
RUN;

PROC SQL;
CREATE TABLE DataCong.comorbidity_hyper_covid AS
SELECT d.*, c.admit_date_hyper,
	CASE
		WHEN c.hyper_updated = 1 THEN 1
		ELSE 0
	END AS hyper
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN comorbidity_hyper_covid AS c
	ON d.encounterid = c.encounterid
ORDER BY encounterid, admit_date, admit_date_hyper;
QUIT; /* 32387 rows and 15 columns */

/* 7.3.5 Check Missings in hypertension Data of COVID+ Encounters */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,					/* 0 obs */
	   NMISS(patid) AS patid_miss_num,								/* 0 obs */
	   NMISS(admit_date) AS admit_date_miss_num,					/* 0 obs */
	   NMISS(covid_diagnosis) AS covid_diagnosis_miss_num,			/* 0 obs */
	   NMISS(admit_date_hyper) AS hyper_date_miss_num,			/* 27389 obs */
	   NMISS(admit_date_hyper)/count(*) AS hyper_date_miss_per,	/* 84.5679% obs */
	   NMISS(hyper) AS hyper_miss_num								/* 0 obs */
FROM DataCong.comorbidity_hyper_covid;
QUIT;

/* 7.3.6 Check Duplicates in hypertension Data of COVID+ Encounters */
PROC SQL;
SELECT num_hyper_per_encounter, COUNT(num_hyper_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT hyper) AS num_hyper_per_encounter	/* Each encounterid of Hypertension Data corresponds to ONLY 1 hyper status */
	 FROM DataCong.comorbidity_hyper_covid
	 GROUP BY encounterid)
GROUP BY num_hyper_per_encounter;
QUIT;

PROC SORT
DATA = DataCong.comorbidity_hyper_covid NODUPKEY
DUPOUT = comorbidity_hyper_covid_dup	/* 0 duplicate rows */
OUT = comorbidity_hyper_covid_uniq;	/* 32387 unique rows */
BY encounterid admit_date_hyper;
RUN;

PROC SORT
DATA = comorbidity_hyper_covid_uniq NODUPKEY
DUPOUT = comorbidity_hyper_covid_dup		/* 0 duplicate encounterid */
OUT = DataCong.comorbidity_hyper_covid;	/* 32387 unique encounterid */
BY encounterid;
RUN;

proc freq data=DataCong.comorbidity_hyper_covid;
table hyper;
run;

/* 8. Vital Data */
/* 8.1 Check Leading 0 in Character Variables of Vital Data before Converting to Numeric Type */
PROC SQL;
CREATE TABLE patid_vital AS
SELECT substr(strip(ssid),1,1) AS patid_1st
FROM DataSAS.vital
WHERE substr(strip(ssid),1,1) = '0';
QUIT; /* 0 row: patid from vital data has no leading 0 */

/* 8.2 Create Vital Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.vital AS
SELECT vitalid,
	   input(encounterid, best.) AS encounterid,	/* convert to numeric */
	   input(ssid, best.) AS patid_vital, 			/* convert to numeric */
	   MEASURE_DATE AS measure_date,
	   MEASURE_TIME AS measure_time,
	   ht,
	   wt,
	   diastolic,
	   systolic,
	   original_bmi
FROM DataSAS.vital
WHERE CALCULATED patid_vital IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters)
	  AND (ht IS NOT NULL OR wt IS NOT NULL OR diastolic IS NOT NULL OR systolic IS NOT NULL OR original_bmi IS NOT NULL)
ORDER BY encounterid, patid_vital, vitalid;
QUIT; /* 14126591 rows and 10 columns */

/* 8.3 Check Missings in Vital Data of COVID+ Patients */
PROC SQL;
SELECT NMISS(vitalid) AS vitalid_miss_num,							/* 0 obs */
	   NMISS(encounterid) AS encounterid_miss_num,					/* 1719384 obs */ /* !!!!!!!!!! WARNING: 1719384 missing encounterid !!!!!!!!!! */
	   NMISS(encounterid)/N(vitalid) AS encounterid_miss_per,		/* 12.1713% obs */
	   NMISS(patid_vital) AS patid_miss_num,						/* 0 obs */
	   NMISS(measure_date) AS measure_date_miss_num,				/* 0 obs */
	   NMISS(measure_time) AS measure_time_miss_num,				/* 0 obs */
	   NMISS(ht) AS ht_miss_num,									/* 12933201 obs, normal for long format data */
	   NMISS(wt) AS wt_miss_num,									/* 12347638 obs, normal for long format data */
	   NMISS(original_bmi) AS bmi_miss_num,							/* 12989754 obs, normal for long format data */
	   NMISS(diastolic) AS diastolic_miss_num,						/*  4109180 obs, normal for long format data */
	   NMISS(systolic) AS systolic_miss_num							/*  4156019 obs, normal for long format data */
FROM DataCong.vital;
QUIT;

/* 8.4 Check Duplicates in Vital Data of COVID+ Patients */
PROC SORT
DATA = DataCong.vital NODUPKEY
DUPOUT = vital_dup	/* 0 duplicate vitalid */
OUT = vital_uniq;	/* 14126591 unique vitalid */
BY vitalid;
RUN; 

PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid_vital) AS num_patid_per_encounter /* !!!!!!!!!! WARNING: 132 encounterid correspond to 2 patid !!!!!!!!!! */
	 FROM DataCong.vital
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

CREATE TABLE vital_dup_patid AS
SELECT *
FROM DataCong.vital
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.vital
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT patid_vital) > 1) /* !!!!!!!!!! WARNING: 132 encounterid correspond to 2 patid !!!!!!!!!! */
ORDER BY encounterid, patid_vital, measure_date;
QUIT;

PROC SQL;
SELECT num_measure_date_per_encounter, COUNT(num_measure_date_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT measure_date) AS num_measure_date_per_encounter	/* WARNING: many encounterid correspond to hundreds of measure_date! */
	 FROM DataCong.vital
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid)
GROUP BY num_measure_date_per_encounter;

CREATE TABLE vital_dup_measure_date AS
SELECT *
FROM DataCong.vital
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.vital
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid
	 HAVING COUNT(DISTINCT measure_date) > 1)	/* WARNING: many encounterid correspond to hundreds of measure_date! */
ORDER BY encounterid, patid_vital, measure_date;
QUIT;

PROC SQL;
CREATE TABLE vital AS
SELECT v.*
FROM DataCong.vital AS v
LEFT JOIN DataCong.encounterid_patid_date_all_data AS e
	ON v.encounterid = e.encounterid
WHERE NOT (patid_vital IS NOT NULL AND patid_vital ^= patid); /* Solution: Apply filter condition: patid_vital = patid */
QUIT; /* 12394369 rows and 10 columns */

PROC SQL;
SELECT num_patid_per_encounter, COUNT(num_patid_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT patid_vital) AS num_patid_per_encounter /* !!!!!!!!!! Each encounterid of Encounter Data corresponds to ONLY 1 patid !!!!!!!!!! */
	 FROM vital
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid)
GROUP BY num_patid_per_encounter;

SELECT num_measure_date_per_encounter, COUNT(num_measure_date_per_encounter) AS num_encounter
FROM
	(SELECT COUNT(DISTINCT measure_date) AS num_measure_date_per_encounter	/* WARNING: many encounterid correspond to hundreds of measure_date! */
	 FROM vital
	 WHERE encounterid IS NOT NULL
	 GROUP BY encounterid)
GROUP BY num_measure_date_per_encounter;
QUIT;

PROC SORT
DATA = vital NODUPKEY
DUPOUT = vital_dup	/*  1907563 duplicate rows */
OUT = vital_uniq;	/* 10486806 unique rows */
BY encounterid patid_vital measure_date measure_time ht wt diastolic systolic original_bmi;
RUN; 

/* 8.5 Create Height Data of COVID+ Patients */
PROC SQL;
CREATE TABLE vital_ht AS
SELECT vitalid, encounterid, patid_vital, measure_date, measure_time, ht 
FROM vital_uniq
WHERE ht IS NOT NULL;
QUIT; /* 978226 rows and 6 columns */

PROC SQL;
CREATE TABLE vital_ht_median AS
SELECT patid_vital, measure_date, MEDIAN(ht) AS ht_median /*Taking median of multiple values listed*/
FROM vital_ht
GROUP BY patid_vital, measure_date;
QUIT; /* 400540 rows and 3 columns */

PROC SQL;
CREATE TABLE vital_covid_ht AS
SELECT d.*, measure_date,
	   INTCK('day', measure_date, admit_date) AS admit_measure_date_diff,
	   CASE
			WHEN CALCULATED admit_measure_date_diff >= 0 THEN 1
			ELSE -1
	   END AS admit_measure_date_diff_sign,
	   ABS(CALCULATED admit_measure_date_diff) AS admit_measure_date_diff_abs,
	   ht_median
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN vital_ht_median AS v
	ON d.patid = v.patid_vital
WHERE CALCULATED admit_measure_date_diff <= 365 AND CALCULATED admit_measure_date_diff >= -7 /*Using measurements from the year before admission and up to 7 days after*/
ORDER BY encounterid, admit_date, measure_date;
QUIT; /* 122306 rows and 18 columns */

PROC SQL;
CREATE TABLE DataCong.vital_covid_ht AS
SELECT v.*, min_admit_measure_date_diff_abs
FROM vital_covid_ht AS v
LEFT JOIN
		(SELECT encounterid, admit_measure_date_diff_sign, MIN(admit_measure_date_diff_abs) AS min_admit_measure_date_diff_abs 
		 FROM vital_covid_ht
		 GROUP BY encounterid, admit_measure_date_diff_sign) AS m
	ON v.encounterid = m.encounterid AND v.admit_measure_date_diff_sign = m.admit_measure_date_diff_sign
WHERE admit_measure_date_diff_abs = min_admit_measure_date_diff_abs;
QUIT; /* 37137 rows and 19 columns */

PROC SQL;
CREATE TABLE vital_covid_ht AS
SELECT v.*, max_admit_measure_date_diff
FROM DataCong.vital_covid_ht AS v
LEFT JOIN
		(SELECT encounterid, MAX(admit_measure_date_diff) AS max_admit_measure_date_diff
		 FROM DataCong.vital_covid_ht
		 GROUP BY encounterid) AS m
	ON v.encounterid = m.encounterid
WHERE admit_measure_date_diff = max_admit_measure_date_diff;
QUIT; /* 28185 rows and 20 columns */

PROC SORT
DATA = vital_covid_ht NODUPKEY
DUPOUT = vital_covid_ht_dup	/* 0 duplicate encounterid */
OUT = vital_covid_ht_uniq;	/* 28185 unique encounterid */
BY encounterid;
RUN; 

PROC SQL;
CREATE TABLE vital_covid_ht AS
SELECT d.*, v.measure_date, v.ht_median
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN vital_covid_ht_uniq AS v
	ON d.encounterid = v.encounterid
ORDER BY encounterid, admit_date, measure_date;
QUIT; /* 32387 rows and 15 columns */

PROC SORT
DATA = vital_covid_ht NODUPKEY
DUPOUT = vital_covid_ht_dup		/* 0 duplicate encounterid */
OUT = DataCong.vital_covid_ht;	/* 32387 unique encounterid */
BY encounterid;
RUN;

/* 8.6 Create Weight Data of COVID+ Patients */
PROC SQL;
CREATE TABLE vital_wt AS
SELECT vitalid, encounterid, patid_vital, measure_date, measure_time, wt 
FROM vital_uniq
WHERE wt IS NOT NULL;
QUIT; /* 1470751 rows and 6 columns */

PROC SQL;
CREATE TABLE vital_wt_median AS
SELECT patid_vital, measure_date, MEDIAN(wt) AS wt_median
FROM vital_wt
GROUP BY patid_vital, measure_date;
QUIT; /* 597835 rows and 3 columns */

PROC SQL;
CREATE TABLE vital_covid_wt AS
SELECT d.*, measure_date,
	   INTCK('day', measure_date, admit_date) AS admit_measure_date_diff,
	   CASE
			WHEN CALCULATED admit_measure_date_diff >= 0 THEN 1
			ELSE -1
	   END AS admit_measure_date_diff_sign,
	   ABS(CALCULATED admit_measure_date_diff) AS admit_measure_date_diff_abs,
	   wt_median
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN vital_wt_median AS v
	ON d.patid = v.patid_vital
WHERE CALCULATED admit_measure_date_diff <= 180 AND CALCULATED admit_measure_date_diff >= -7 /*Use weights from 6 months prior to 1 week after admission*/
ORDER BY encounterid, admit_date, measure_date;
QUIT; /* 121972 rows and 18 columns */

PROC SQL;
CREATE TABLE DataCong.vital_covid_wt AS
SELECT v.*, min_admit_measure_date_diff_abs
FROM vital_covid_wt AS v
LEFT JOIN
		(SELECT encounterid, admit_measure_date_diff_sign, MIN(admit_measure_date_diff_abs) AS min_admit_measure_date_diff_abs
		 FROM vital_covid_wt
		 GROUP BY encounterid, admit_measure_date_diff_sign) AS m
	ON v.encounterid = m.encounterid AND v.admit_measure_date_diff_sign = m.admit_measure_date_diff_sign
WHERE admit_measure_date_diff_abs = min_admit_measure_date_diff_abs;
QUIT; /* 39430 rows and 19 columns */

PROC SQL;
CREATE TABLE vital_covid_wt AS
SELECT v.*, max_admit_measure_date_diff
FROM DataCong.vital_covid_wt AS v
LEFT JOIN
		(SELECT encounterid, MAX(admit_measure_date_diff) AS max_admit_measure_date_diff
		 FROM DataCong.vital_covid_wt
		 GROUP BY encounterid) AS m
	ON v.encounterid = m.encounterid
WHERE admit_measure_date_diff = max_admit_measure_date_diff;
QUIT; /* 29010 rows and 20 columns */

PROC SORT
DATA = vital_covid_wt NODUPKEY
DUPOUT = vital_covid_wt_dup	/* 0 duplicate encounterid */
OUT = vital_covid_wt_uniq;	/* 29010 unique encounterid */
BY encounterid;
RUN; 

PROC SQL;
CREATE TABLE vital_covid_wt AS
SELECT d.*, v.measure_date, v.wt_median
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN vital_covid_wt_uniq AS v
	ON d.encounterid = v.encounterid
ORDER BY encounterid, admit_date, measure_date;
QUIT; /* 32387 rows and 15 columns */

PROC SORT
DATA = vital_covid_wt NODUPKEY
DUPOUT = vital_covid_wt_dup		/* 0 duplicate encounterid */
OUT = DataCong.vital_covid_wt;	/* 32387 unique encounterid */
BY encounterid;
RUN;

/* 8.7 Create Original BMI Data of COVID+ Patients */
PROC SQL;
CREATE TABLE vital_original_bmi AS
SELECT vitalid, encounterid, patid_vital, measure_date, measure_time, original_bmi 
FROM vital_uniq
WHERE original_bmi IS NOT NULL;
QUIT; /* 953808 rows and 6 columns */

PROC SQL;
CREATE TABLE vital_original_bmi_median AS
SELECT patid_vital, measure_date, MEDIAN(original_bmi) AS original_bmi_median
FROM vital_original_bmi
GROUP BY patid_vital, measure_date;
QUIT; /* 493384 rows and 3 columns */

PROC SQL;
CREATE TABLE vital_covid_original_bmi AS
SELECT d.*, measure_date,
	   INTCK('day', measure_date, admit_date) AS admit_measure_date_diff,
	   CASE
			WHEN CALCULATED admit_measure_date_diff >= 0 THEN 1
			ELSE -1
	   END AS admit_measure_date_diff_sign,
	   ABS(CALCULATED admit_measure_date_diff) AS admit_measure_date_diff_abs,
	   original_bmi_median
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN vital_original_bmi_median AS v
	ON d.patid = v.patid_vital
WHERE CALCULATED admit_measure_date_diff <= 180 AND CALCULATED admit_measure_date_diff >= -7
ORDER BY encounterid, admit_date, measure_date;
QUIT; /* 86730 rows and 18 columns */

PROC SQL;
CREATE TABLE DataCong.vital_covid_original_bmi AS
SELECT v.*, min_admit_measure_date_diff_abs
FROM vital_covid_original_bmi AS v
LEFT JOIN
		(SELECT encounterid, admit_measure_date_diff_sign, MIN(admit_measure_date_diff_abs) AS min_admit_measure_date_diff_abs
		 FROM vital_covid_original_bmi
		 GROUP BY encounterid, admit_measure_date_diff_sign) AS m
	ON v.encounterid = m.encounterid AND v.admit_measure_date_diff_sign = m.admit_measure_date_diff_sign
WHERE admit_measure_date_diff_abs = min_admit_measure_date_diff_abs;
QUIT; /* 28786 rows and 19 columns */

PROC SQL;
CREATE TABLE vital_covid_original_bmi AS
SELECT v.*, max_admit_measure_date_diff
FROM DataCong.vital_covid_original_bmi AS v
LEFT JOIN
		(SELECT encounterid, MAX(admit_measure_date_diff) AS max_admit_measure_date_diff
		 FROM DataCong.vital_covid_original_bmi
		 GROUP BY encounterid) AS m
	ON v.encounterid = m.encounterid
WHERE admit_measure_date_diff = max_admit_measure_date_diff;
QUIT; /* 27562 rows and 20 columns */

PROC SORT
DATA = vital_covid_original_bmi NODUPKEY
DUPOUT = vital_covid_original_bmi_dup	/* 0 duplicate encounterid */
OUT = vital_covid_original_bmi_uniq;	/* 27562 unique encounterid */
BY encounterid;
RUN; 

PROC SQL;
CREATE TABLE vital_covid_original_bmi AS
SELECT d.*, v.measure_date, v.original_bmi_median
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN vital_covid_original_bmi_uniq AS v
	ON d.encounterid = v.encounterid
ORDER BY encounterid, admit_date, measure_date;
QUIT; /* 32387 rows and 15 columns */

PROC SORT
DATA = vital_covid_original_bmi NODUPKEY
DUPOUT = vital_covid_original_bmi_dup		/* 0 duplicate encounterid */
OUT = DataCong.vital_covid_original_bmi;	/* 32387 unique encounterid */
BY encounterid;
RUN;

/* 8.8 Create Final Height, Weight, BMI Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.vital_covid_ht_wt_bmi AS
SELECT h.encounterid, h.patid, h.admit_date, h.covid_diagnosis, h.measure_date AS measure_date_ht, h.ht_median,
	   w.measure_date AS measure_date_wt, w.wt_median, b.measure_date AS measure_date_original_bmi, b.original_bmi_median,
	CASE
		WHEN h.ht_median >= 10 THEN h.ht_median
		ELSE .
	END AS height,
	CASE
		WHEN w.wt_median >=5 THEN w.wt_median
		ELSE .
	END AS weight,
	CASE
		WHEN b.original_bmi_median >= 10 AND b.original_bmi_median <= 90 THEN b.original_bmi_median
		ELSE 703 * CALCULATED weight / (CALCULATED height * CALCULATED height)
	END AS bmi_num,
	CASE
		WHEN CALCULATED bmi_num IS NULL THEN ''
		WHEN CALCULATED bmi_num  < 10 THEN 'Biologically Impossible' /*This variable construction is not used in later analyses. Recoded in R in subsequent scripts*/
		WHEN CALCULATED bmi_num < 30 THEN ' or less'
		WHEN CALCULATED bmi_num <= 40 THEN '31-40 (Obesity)'
		WHEN CALCULATED bmi_num <= 90 THEN '41 or more (Morbidly Obesity)'
		ELSE 'Biologically Impossible'
	END AS bmi_cat
FROM DataCong.vital_covid_ht AS h
LEFT JOIN DataCong.vital_covid_wt AS w
	ON h.encounterid = w.encounterid
LEFT JOIN DataCong.vital_covid_original_bmi AS b
	ON h.encounterid = b.encounterid
ORDER BY h.encounterid, h.patid, h.admit_date;
QUIT; /* 32387 rows and 14 columns */

/* 8.9 Create Blood Pressure Data of COVID+ Patients */
PROC SQL;
CREATE TABLE vital_bp AS
SELECT vitalid, encounterid, patid_vital, measure_date, measure_time, diastolic, systolic 
FROM vital_uniq
/* WHERE diastolic IS NOT NULL AND systolic IS NULL;	/*   39560 rows */
/* WHERE systolic IS NOT NULL AND diastolic IS NULL;	/*       0 rows */
WHERE systolic IS NOT NULL AND diastolic IS NOT NULL;	/* 7044461 rows and 7 columns */
QUIT;

PROC SQL;
CREATE TABLE vital_bp_first AS
SELECT v.*
FROM vital_bp AS v
LEFT JOIN
		(SELECT patid_vital, measure_date, MIN(measure_time) AS measure_time_first FORMAT = TIME5.
		 FROM vital_bp
		 GROUP BY patid_vital, measure_date) AS f
	ON v.patid_vital = f.patid_vital AND v.measure_date = f.measure_date
WHERE v.measure_time = measure_time_first
ORDER BY patid_vital, measure_date, measure_time, vitalid;
QUIT; /* 2141738 rows and 7 column */

PROC SORT
DATA = vital_bp_first NODUPKEY
DUPOUT = vital_bp_first_dup	/* 1003231 duplicate rows for the same bp values at the same time on the same day */ 
OUT = vital_bp_first_uniq;	/* 1138507    unique rows for the same bp values at the same time on the same day */
BY patid_vital measure_date measure_time diastolic systolic;
RUN; 

PROC SQL;
CREATE TABLE vital_bp_first_multiple_bp AS /* 38402 rows: different bp values at the same time on the same day */
SELECT *
FROM vital_bp_first_uniq
GROUP BY patid_vital, measure_date
HAVING COUNT(*) > 1;
QUIT;

PROC SORT
DATA = vital_bp_first_uniq NODUPKEY
DUPOUT = vital_bp_first_dup	/* 0 duplicate rows */
OUT = vital_bp_first;		/* 1138507 unique rows */
BY patid_vital measure_date vitalid;
RUN; 

PROC SORT
DATA = vital_bp_first NODUPKEY
DUPOUT = vital_bp_first_dup	/*   19414 duplicate bp values for each patient at the same time on the same day  */
OUT = vital_bp_first_uniq;	/* 1119093    unique bp values for each patient at the same time on the same day  */
BY patid_vital measure_date;
RUN; 

PROC SQL;
CREATE TABLE vital_covid_bp AS
SELECT d.*, measure_date, measure_time,
	   INTCK('day', measure_date, admit_date) AS admit_measure_date_diff,
	   diastolic, systolic
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN vital_bp_first_uniq AS v
	ON d.patid = v.patid_vital
WHERE CALCULATED admit_measure_date_diff <= 7 AND CALCULATED admit_measure_date_diff >= 0 /*Only using measures within week of admission*/
ORDER BY encounterid, admit_date, measure_date;
QUIT; /* 47253 rows and 18 columns */

PROC SQL;
CREATE TABLE DataCong.vital_covid_bp AS
SELECT v.*, min_admit_measure_date_diff
FROM vital_covid_bp AS v
LEFT JOIN
		(SELECT encounterid, MIN(admit_measure_date_diff) AS min_admit_measure_date_diff
		 FROM vital_covid_bp
		 GROUP BY encounterid) AS m
	ON v.encounterid = m.encounterid
WHERE admit_measure_date_diff = min_admit_measure_date_diff;
QUIT; /* 28478 rows and 19 columns */

PROC SORT
DATA = DataCong.vital_covid_bp NODUPKEY
DUPOUT = vital_covid_bp_dup	/* 0 duplicate encounterid */
OUT = vital_covid_bp_uniq;	/* 28478 unique encounterid */
BY encounterid;
RUN; 

PROC SQL;
CREATE TABLE vital_covid_bp AS
SELECT d.*, v.measure_date, v.measure_time, v.diastolic AS diastolic_first, v.systolic AS systolic_first
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN vital_covid_bp_uniq AS v
	ON d.encounterid = v.encounterid
ORDER BY encounterid, admit_date, measure_date;
QUIT; /* 32387 rows and 17 columns */

PROC SORT
DATA = vital_covid_bp NODUPKEY
DUPOUT = vital_covid_bp_dup		/* 0 duplicate encounterid */
OUT = DataCong.vital_covid_bp;	/* 32387 unique encounterid */
BY encounterid;
RUN;

/* 8.10 Create Vital Data of COVID+ Encounters */
PROC SQL;
CREATE TABLE DataCong.vital_covid_ht_wt_bmi_bp AS
SELECT v.*, b.measure_date AS measure_date_bp, b.measure_time AS measure_time_bp, b.diastolic_first, b.systolic_first
FROM DataCong.vital_covid_ht_wt_bmi AS v
LEFT JOIN DataCong.vital_covid_bp AS b
	ON v.encounterid = b.encounterid
ORDER BY v.encounterid, v.patid, v.admit_date;
QUIT; /* 32387 rows and 18 columns */



/* 9. Smoking Data */
/* 9.1 Create Smoking Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.smoking AS
SELECT vitalid,
	   input(encounterid, best.) AS encounterid,	/* convert to numeric */
	   input(ssid, best.) AS patid_smk, 			/* convert to numeric */
	   MEASURE_DATE AS measure_date_smk,
	   upcase(strip(smoking)) AS smoking,
	   upcase(strip(tobacco)) AS tobacco
FROM DataSAS.vital
WHERE CALCULATED patid_smk IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters) AND
	  (smoking IS NOT NULL OR tobacco IS NOT NULL)
ORDER BY patid_smk, smoking, tobacco, measure_date_smk, vitalid;
QUIT; /* 448130 rows and 6 columns */

PROC FREQ
	DATA = DataCong.smoking;
	TABLES smoking tobacco / MISSING;
	TABLES smoking * tobacco / MISSING;
RUN;

PROC SQL;
CREATE TABLE smoking AS
SELECT *
FROM DataCong.smoking
WHERE smoking = '05';
QUIT; /* 42426 rows and 6 columns */

PROC FREQ
	DATA = smoking;
	TABLES smoking tobacco / MISSING;
	TABLES smoking * tobacco / MISSING;
RUN;

/* 9.2 Check Duplicates in Smoking Data of COVID+ Patients */
PROC SORT
DATA = smoking NODUPKEY
DUPOUT = smoking_dup	/* 19760 duplicate rows */
OUT = DataCong.smoking;	/* 22666 unique rows and 6 columns */
BY patid_smk measure_date_smk;
RUN;

PROC SQL;
SELECT num_measure_date_per_patid, COUNT(num_measure_date_per_patid) AS num_patid
FROM
	(SELECT COUNT(measure_date_smk) AS num_measure_date_per_patid /* ! Many patid have multiple smoking measure dates ! */
	 FROM DataCong.smoking
	 GROUP BY patid_smk)
GROUP BY num_measure_date_per_patid;

SELECT patid_smk, COUNT(measure_date_smk) AS num_measure_date_per_patid /* ! Many patid have multiple smoking measure dates ! */
FROM DataCong.smoking
GROUP BY patid_smk
HAVING num_measure_date_per_patid ^= 1;
QUIT;

PROC SQL;
CREATE TABLE smoking AS
SELECT i.encounterid, i.patid, i.admit_date, s.measure_date_smk, s.smoking, s.tobacco,
	   INTCK('day', i.admit_date, s.measure_date_smk) AS admit_measure_gap_smk,
	   ABS(INTCK('day', i.admit_date, s.measure_date_smk)) AS abs_admit_measure_gap_smk
FROM DataCong.insight_covid_encounters AS i
INNER JOIN DataCong.smoking AS s
	ON i.patid = s.patid_smk;
QUIT; /* 27620 rows and 8 columns */

PROC SQL;
CREATE TABLE DataCong.smoking AS
SELECT encounterid, patid, admit_date, measure_date_smk, admit_measure_gap_smk, smoking, tobacco
FROM smoking
GROUP BY patid, admit_date
HAVING abs_admit_measure_gap_smk = MIN(abs_admit_measure_gap_smk);
QUIT; /* 3199 rows and 7 columns */

PROC SQL;
SELECT num_msrdate_per_patid_admitdate, COUNT(num_msrdate_per_patid_admitdate) AS num_patid_admitdate_group
FROM
	(SELECT COUNT(measure_date_smk) AS num_msrdate_per_patid_admitdate /* ! 5 patid have 2 closest smoking measure dates to admit date, with one before and the other after admit date ! */
	 FROM DataCong.smoking
	 GROUP BY patid, admit_date)
GROUP BY num_msrdate_per_patid_admitdate;

SELECT patid, admit_date, COUNT(measure_date_smk) AS num_msrdate_per_patid_admitdate /* ! 5 patid have 2 closest smoking measure dates to admit date, with one before and the other after admit date ! */
FROM DataCong.smoking
GROUP BY patid, admit_date
HAVING num_msrdate_per_patid_admitdate ^= 1;
QUIT;

PROC SORT
DATA = DataCong.smoking NODUPKEY
DUPOUT = smoking_dup	/* 0 duplicate rows */
OUT = smoking;			/* 3199 unique rows and 9 columns */
BY patid admit_date measure_date_smk;
RUN;

PROC SORT
DATA = smoking NODUPKEY
DUPOUT = smoking_dup	/* 5 duplicate rows */
OUT = DataCong.smoking;	/* 3194 unique rows and 9 columns: for these 5 pairs of duplicate closest smoking measure dates to admit date, keep the one before admit date! */
BY patid admit_date;
RUN;

/* 9.3 Check Missings in Smoking Data of COVID+ Patients */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,						/* 0 obs */
	   NMISS(patid) AS patid_miss_num,									/* 0 obs */
	   NMISS(admit_date) AS admit_date_miss_num, 						/* 0 obs */
	   NMISS(measure_date_smk) AS measure_date_smk_miss_num,			/* 0 obs */
	   NMISS(admit_measure_gap_smk) AS admit_measure_gap_smk_miss_num,	/* 0 obs */
	   NMISS(smoking) AS smoking_miss_num,								/* 0 obs */
	   NMISS(tobacco) AS tobacco_miss_num								/* 0 obs */
FROM DataCong.smoking;
QUIT;

/* 9.4 Create Smoking Data of COVID+ Encounters */

/*Any indicator of smoking in record is considered smoking; no indication assumes non-smoker*/
PROC SQL;
CREATE TABLE DataCong.smoking_covid AS
SELECT i.encounterid, i.patid, i.admit_date, s.measure_date_smk, s.admit_measure_gap_smk, s.smoking, s.tobacco,
	CASE
	   WHEN s.smoking IS NULL THEN 0
	   ELSE 1
	END AS smoke
FROM DataCong.insight_covid_encounters AS i
LEFT JOIN DataCong.smoking AS s
	ON i.encounterid = s.encounterid;
QUIT; /* 32387 rows and 8 columns */

/* 9.5 Check Missings in Smoking Data of COVID+ Encounters */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,										/* 0 obs */
	   NMISS(patid) AS patid_miss_num,													/* 0 obs */
	   NMISS(admit_date) AS admit_date_miss_num, 										/* 0 obs */
	   NMISS(measure_date_smk) AS measure_date_smk_miss_num,							/* 29193 obs */
	   NMISS(measure_date_smk)/N(encounterid) AS measure_date_smk_miss_per,				/* 90.138% obs */
	   NMISS(admit_measure_gap_smk) AS admit_measure_gap_smk_miss_num,					/* 29193 obs */
	   NMISS(admit_measure_gap_smk)/N(encounterid) AS admit_measure_gap_smk_miss_per,	/* 90.138% obs */
	   NMISS(smoking) AS smoking_miss_num,												/* 29193 obs */
	   NMISS(smoking)/N(encounterid) AS smoking_miss_per,								/* 90.138% obs */
	   NMISS(tobacco) AS tobacco_miss_num,												/* 29193 obs */
	   NMISS(tobacco)/N(encounterid) AS tobacco_miss_per,								/* 90.138% obs */
	   NMISS(smoke) AS smoke_miss_num													/* 0 obs */
FROM DataCong.smoking_covid;
QUIT;

/* 9.6 Check Duplicates in Smoking Data of COVID+ Encounters */
PROC SORT
DATA = DataCong.smoking_covid NODUPKEY
DUPOUT = smoking_covid_dup	/* 0 duplicate rows */
OUT = smoking_covid;		/* 32387 unique rows */
BY encounterid admit_date;
RUN;

PROC SORT
DATA = smoking_covid NODUPKEY
DUPOUT = smoking_covid_dup		/* 0 duplicate encounterid */
OUT = DataCong.smoking_covid;	/* 32387 unique encounterid */
BY encounterid;
RUN;


/* 10. Acute Respiratory Distress Syndrome (ARDS) Data */
/* 10.1 Create Acute Respiratory Distress Syndrome (ARDS) Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.ards AS
SELECT diagnosisid,
	   input(encounterid, best.) AS encounterid,	/* convert to numeric */
	   input(ssid, best.) AS patid,					/* convert to numeric */
	   ADMIT_DATE AS admit_date_ards,
	   DX_DATE AS dx_date_ards,
	   INTCK('day', admit_date_ards, dx_date_ards) AS admit_dx_gap_ards,
       upcase(strip(dx)) AS dx
FROM DataSAS.diagnosis
WHERE CALCULATED patid IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters) AND
	  admit_date_ards IN
		(SELECT DISTINCT admit_date
		 FROM DataCong.insight_covid_encounters) AND
	  upcase(strip(dx)) = 'J80' /* Ref: COVID-19 DX Codes */
ORDER BY encounterid, patid, diagnosisid;
QUIT; /* 146652 rows and 7 columns */

/* 10.2 Check Duplicates in Acute Respiratory Distress Syndrome (ARDS) Data of COVID+ Patients */
PROC SORT
DATA = DataCong.ards NODUPKEY
DUPOUT = ards_dup	/* 118913 duplicate rows */
OUT = ards;			/*  27739 unique rows and 7 columns */
BY patid admit_date_ards dx_date_ards admit_dx_gap_ards dx;
RUN;

PROC SQL;
CREATE TABLE DataCong.ards AS
SELECT a.*
FROM ards AS a
LEFT JOIN
		(SELECT patid, admit_date_ards, MIN(ABS(admit_dx_gap_ards)) AS min_abs_admit_dx_gap_ards
		 FROM ards
		 GROUP BY patid, admit_date_ards) AS m
	ON a.patid = m.patid AND a.admit_date_ards = m.admit_date_ards
WHERE ABS(a.admit_dx_gap_ards) = m.min_abs_admit_dx_gap_ards; /* Patients may have multiple ARDS diagnois dates for one admit date. Therefore, keep the closest ARDS diagnosis date to admit date. */
QUIT; /* 5354 rows and 7 columns */

PROC SQL;
SELECT num_encnter_per_patid_admitdate, COUNT(num_encnter_per_patid_admitdate) AS num_patid_admitdate_group
FROM
	(SELECT COUNT(encounterid) AS num_encnter_per_patid_admitdate /* ! 13 patid have 2 closest ARDS diagnosis dates to admit date, with one before and the other after admit date ! */
	 FROM DataCong.ards
	 GROUP BY patid, admit_date_ards)
GROUP BY num_encnter_per_patid_admitdate;

SELECT patid, admit_date_ards, COUNT(encounterid) AS num_encnter_per_patid_admitdate /* ! 13 patid have 2 closest ARDS diagnosis dates to admit date, with one before and the other after admit date ! */
FROM DataCong.ards
GROUP BY patid, admit_date_ards
HAVING num_encnter_per_patid_admitdate ^= 1;
QUIT;

PROC SORT
DATA = DataCong.ards NODUPKEY
DUPOUT = ards_dup	/* 0 duplicate rows */
OUT = ards;			/* 5354 unique rows and 7 columns */
BY patid admit_date_ards DESCENDING admit_dx_gap_ards;
RUN;

PROC SORT
DATA = ards NODUPKEY
DUPOUT = ards_dup		/* 13 duplicate rows */
OUT = DataCong.ards;	/* 5341 unique rows and 7 columns: for these 13 pairs of duplicate closest ARDS diagnosis dates to admit date, keep the one after admit date as indicator! */
BY patid admit_date_ards;
RUN;

PROC SQL;
SELECT num_encnter_per_patid_admitdate, COUNT(num_encnter_per_patid_admitdate) AS num_patid_admitdate_group
FROM
	(SELECT COUNT(encounterid) AS num_encnter_per_patid_admitdate /* ! Each patid has ONLY 1 ARDS diagnosis date on each admit date ! */
	 FROM DataCong.ards
	 GROUP BY patid, admit_date_ards)
GROUP BY num_encnter_per_patid_admitdate;
QUIT;

PROC SQL;
CREATE TABLE ards AS
SELECT i.encounterid, i.patid, a.admit_date_ards, a.dx_date_ards, a.admit_dx_gap_ards, a.dx
FROM DataCong.insight_covid_encounters AS i
INNER JOIN DataCong.ards AS a
	ON i.patid = a.patid
WHERE a.admit_date_ards = i.admit_date; /* restricting to where admit date of ARDS diagnosis = admit date of COVID+ diagnosis */
QUIT; /* 4387 rows and 6 columns */

PROC SORT
DATA = ards NODUPKEY
DUPOUT = ards_dup		/* 0 duplicate rows */
OUT = DataCong.ards;	/* 4387 unique rows and 6 columns */
BY patid admit_date_ards;
RUN;

/* 10.3 Check Missings in Acute Respiratory Distress Syndrome (ARDS) Data of COVID+ Patients */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,			 					/* 0 obs */
	   NMISS(patid) AS patid_miss_num, 											/* 0 obs */
	   NMISS(admit_date_ards) AS admit_date_ards_miss_num, 						/* 0 obs */
	   NMISS(dx_date_ards) AS dx_date_ards_miss_num,							/* 1552 obs */
	   NMISS(dx_date_ards)/N(encounterid) AS dx_date_ards_miss_per,				/* 35.3773% obs */
	   NMISS(admit_dx_gap_ards) AS admit_dx_gap_ards_miss_num,					/* 1552 obs */
	   NMISS(admit_dx_gap_ards)/N(encounterid) AS admit_dx_gap_ards_miss_per,	/* 35.3773% obs */
	   NMISS(dx) AS dx_miss_num				 									/* 0 obs */
FROM DataCong.ards;
QUIT;

/* 10.4 Create Acute Respiratory Distress Syndrome (ARDS) Variable */
PROC SQL;
CREATE TABLE DataCong.ards_covid AS
SELECT i.encounterid, i.patid, i.admit_date, a.admit_date_ards, a.dx_date_ards, a.admit_dx_gap_ards, a.dx,
	CASE
	   WHEN a.dx IS NULL THEN 0
	   ELSE 1
	END AS ards
FROM DataCong.insight_covid_encounters AS i
LEFT JOIN DataCong.ards AS a
	ON i.patid = a.patid AND i.admit_date = a.admit_date_ards; /* admit date of ARDS diagnosis = admit date of COVID+ diagnosis */
QUIT; /* 32387 rows and 8 columns */

/* 10.5 Check Missings in Acute Respiratory Distress Syndrome (ARDS) Variable of COVID+ Encounters */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,			 					/* 0 obs */
	   NMISS(patid) AS patid_miss_num, 											/* 0 obs */
	   NMISS(admit_date) AS admit_date_miss_num,		 						/* 0 obs */
	   NMISS(admit_date_ards) AS admit_date_ards_miss_num, 						/* 28000 obs */
	   NMISS(admit_date_ards)/N(encounterid) AS admit_date_ards_miss_per,		/* 86.4544% obs */
	   NMISS(dx_date_ards) AS dx_date_ards_miss_num,							/* 29552 obs */
	   NMISS(dx_date_ards)/N(encounterid) AS dx_date_ards_miss_per,				/* 91.2465% obs */
	   NMISS(admit_dx_gap_ards) AS admit_dx_gap_ards_miss_num,					/* 29552 obs */
	   NMISS(admit_dx_gap_ards)/N(encounterid) AS admit_dx_gap_ards_miss_per,	/* 91.2465% obs */
	   NMISS(dx) AS dx_miss_num,				 								/* 28000 obs */
	   NMISS(dx)/N(encounterid) AS dx_miss_per,									/* 86.4544% obs */
	   NMISS(ards) AS ards_miss_num				 								/* 0 obs */
FROM DataCong.ards_covid;
QUIT;

/* 10.6 Check Duplicates in Acute Respiratory Distress Syndrome (ARDS) Data of COVID+ Encounters */
PROC SORT
DATA = DataCong.ards_covid NODUPKEY
DUPOUT = ards_covid_dup	/* 0 duplicate rows */
OUT = ards_covid;		/* 32387 unique rows */
BY encounterid admit_date_ards;
RUN;

PROC SORT
DATA = ards_covid NODUPKEY
DUPOUT = ards_covid_dup		/* 0 duplicate encounterid */
OUT = DataCong.ards_covid;	/* 32387 unique encounterid */
BY encounterid;
RUN;


/* 11. Pneumonia Data */
/* 11.1 Create Pneumonia Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.pneumo AS
SELECT diagnosisid,
	   input(encounterid, best.) AS encounterid,	/* convert to numeric */
	   input(ssid, best.) AS patid,					/* convert to numeric */
	   ADMIT_DATE AS admit_date_pneumo,
	   DX_DATE AS dx_date_pneumo,
	   INTCK('day', admit_date_pneumo, dx_date_pneumo) AS admit_dx_gap_pneumo,
       upcase(strip(dx)) AS dx
FROM DataSAS.diagnosis
WHERE CALCULATED patid IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters) AND
	  admit_date_pneumo IN
		(SELECT DISTINCT admit_date
		 FROM DataCong.insight_covid_encounters) AND
	  upcase(strip(dx)) IN  ('J12.81', 'J12.82', 'J12.8', 'J12.9')  /* Ref: COVID-19 DX Codes Tab in DD and literature (pmc9848441 and pmid37399892) */
ORDER BY encounterid, patid, diagnosisid;
QUIT; /* 16612 rows and 7 columns */

/* 11.2 Check Duplicates in Pneumonia Data of COVID+ Patients */
PROC SORT
DATA = DataCong.pneumo NODUPKEY
DUPOUT = pneumo_dup	/*  duplicate rows */
OUT = pneumo;		/*  unique rows and 7 columns */
BY patid admit_date_pneumo dx_date_pneumo admit_dx_gap_pneumo dx;
RUN;

PROC SQL;
CREATE TABLE DataCong.pneumo AS
SELECT a.*
FROM pneumo AS a
LEFT JOIN
		(SELECT patid, admit_date_pneumo, MIN(ABS(admit_dx_gap_pneumo)) AS min_abs_admit_dx_gap_pneumo
		 FROM pneumo
		 GROUP BY patid, admit_date_pneumo) AS m
	ON a.patid = m.patid AND a.admit_date_pneumo = m.admit_date_pneumo
WHERE ABS(a.admit_dx_gap_pneumo) = m.min_abs_admit_dx_gap_pneumo;
QUIT; /* 3006 rows and 7 columns */

PROC SQL;
SELECT num_encnter_per_patid_admitdate, COUNT(num_encnter_per_patid_admitdate) AS num_patid_admitdate_group
FROM
	(SELECT COUNT(encounterid) AS num_encnter_per_patid_admitdate /* ! Each patid has ONLY 1 Pneumonia diagnosis date on each admit date ! */
	 FROM DataCong.pneumo
	 GROUP BY patid, admit_date_pneumo)
GROUP BY num_encnter_per_patid_admitdate;
QUIT;

PROC SQL;
CREATE TABLE pneumo AS
SELECT i.encounterid, i.patid, a.admit_date_pneumo, a.dx_date_pneumo, a.admit_dx_gap_pneumo, a.dx
FROM DataCong.insight_covid_encounters AS i
INNER JOIN DataCong.pneumo AS a
	ON i.patid = a.patid
WHERE a.admit_date_pneumo = i.admit_date; /* admit date of Pneumonia diagnosis = admit date of COVID+ diagnosis */
QUIT; /* 1620 rows and 6 columns */

PROC SORT
DATA = pneumo NODUPKEY
DUPOUT = pneumo_dup		/* 0 duplicate rows */
OUT = DataCong.pneumo;	/*  unique rows and 6 columns */
BY patid admit_date_pneumo;
RUN;

/* 11.3 Check Missings in Pneumonia Data of COVID+ Patients */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,			 						/* 0 obs */
	   NMISS(patid) AS patid_miss_num, 												/* 0 obs */
	   NMISS(admit_date_pneumo) AS admit_date_pneumo_miss_num, 						/* 0 obs */
	   NMISS(dx_date_pneumo) AS dx_date_pneumo_miss_num,							/*  obs */
	   NMISS(dx_date_pneumo)/N(encounterid) AS dx_date_pneumo_miss_per,				/*  obs */
	   NMISS(admit_dx_gap_pneumo) AS admit_dx_gap_pneumo_miss_num,					/*  obs */
	   NMISS(admit_dx_gap_pneumo)/N(encounterid) AS admit_dx_gap_pneumo_miss_per,	/*  obs */
	   NMISS(dx) AS dx_miss_num				 										/* 0 obs */
FROM DataCong.pneumo;
QUIT;

/* 11.4 Create Pneumonia Data of COVID+ Encounters */
PROC SQL;
CREATE TABLE DataCong.pneumo_covid AS
SELECT i.encounterid, i.patid, i.admit_date, a.admit_date_pneumo, a.dx_date_pneumo, a.admit_dx_gap_pneumo, a.dx,
	CASE
	   WHEN a.dx IS NULL THEN 0
	   ELSE 1
	END AS pneumo
FROM DataCong.insight_covid_encounters AS i
LEFT JOIN DataCong.pneumo AS a
	ON i.patid = a.patid AND i.admit_date = a.admit_date_pneumo; /* admit date of Pneumonia diagnosis = admit date of COVID+ diagnosis */
QUIT; /* 32387 rows and 8 columns */

/* 11.5 Check Missings in Pneumonia Data of COVID+ Encounters */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,			 						/* 0 obs */
	   NMISS(patid) AS patid_miss_num, 												/* 0 obs */
	   NMISS(admit_date) AS admit_date_miss_num,		 							/* 0 obs */
	   NMISS(admit_date_pneumo) AS admit_date_pneumo_miss_num, 						/*  obs */
	   NMISS(admit_date_pneumo)/N(encounterid) AS admit_date_pneumo_miss_per,		/*  obs */
	   NMISS(dx_date_pneumo) AS dx_date_pneumo_miss_num,							/*  obs */
	   NMISS(dx_date_pneumo)/N(encounterid) AS dx_date_pneumo_miss_per,				/*  obs */
	   NMISS(admit_dx_gap_pneumo) AS admit_dx_gap_pneumo_miss_num,					/*  obs */
	   NMISS(admit_dx_gap_pneumo)/N(encounterid) AS admit_dx_gap_pneumo_miss_per,	/*  obs */
	   NMISS(dx) AS dx_miss_num,				 									/*  obs */
	   NMISS(dx)/N(encounterid) AS dx_miss_per,										/*  obs */
	   NMISS(pneumo) AS pneumo_miss_num				 								/* 0 obs */
FROM DataCong.pneumo_covid;
QUIT;

/* 11.6 Check Duplicates in Pneumonia Data of COVID+ Encounters */
PROC SORT
DATA = DataCong.pneumo_covid NODUPKEY
DUPOUT = pneumo_covid_dup	/* 0 duplicate rows */
OUT = pneumo_covid;			/* 32387 unique rows */
BY encounterid admit_date_pneumo;
RUN;

PROC SORT
DATA = pneumo_covid NODUPKEY
DUPOUT = pneumo_covid_dup		/* 0 duplicate encounterid */
OUT = DataCong.pneumo_covid;	/* 32387 unique encounterid */
BY encounterid;
RUN;

/* 12. Mechanical Ventilation Data */

/* 12.1 Create Mechanical Ventilation Data of COVID+ Patients */
PROC SQL;
CREATE TABLE DataCong.vent AS
SELECT proceduresid,
	   input(encounterid, best.) AS encounterid,	/* convert to numeric */
	   input(ssid, best.) AS patid,					/* convert to numeric */
	   ADMIT_DATE AS admit_date_vent,
	   PX_DATE AS px_date_vent,
	   INTCK('day', admit_date_vent, px_date_vent) AS admit_px_gap_vent,
       upcase(strip(px)) AS px
FROM DataSAS.Procedures
WHERE CALCULATED patid IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters) AND
	  admit_date_vent IN
		(SELECT DISTINCT admit_date
		 FROM DataCong.insight_covid_encounters) AND
	  upcase(strip(px)) IN  ('5A1935Z', '5A1945Z', '5A1955Z','94002')  /* Ref: Codes for Mechanical Ventilation Invasive (Performance Codes not Assistance) */
ORDER BY encounterid, patid, proceduresid;
QUIT; /* 12343 rows and 7 columns */

/* 12.2 Check Duplicates in Mechanical Ventilation Data of COVID+ Patients */
PROC SORT
DATA = DataCong.vent NODUPKEY
DUPOUT = vent_dup	/* 9905 duplicate rows */
OUT = vent;		/* 2438  unique rows and 7 columns */
BY patid admit_date_vent px_date_vent admit_px_gap_vent px;
RUN;

PROC SQL;
CREATE TABLE DataCong.vent AS
SELECT a.*
FROM vent AS a
LEFT JOIN
		(SELECT patid, admit_date_vent, MIN(ABS(admit_px_gap_vent)) AS min_abs_admit_px_gap_vent
		 FROM vent
		 GROUP BY patid, admit_date_vent) AS m
	ON a.patid = m.patid AND a.admit_date_vent = m.admit_date_vent
WHERE ABS(a.admit_px_gap_vent) = m.min_abs_admit_px_gap_vent;
QUIT; /*  rows and 7 columns */

PROC SQL;
CREATE TABLE vent AS
SELECT i.encounterid, i.patid, a.admit_date_vent, a.px_date_vent, a.admit_px_gap_vent, a.px
FROM DataCong.insight_covid_encounters AS i
INNER JOIN DataCong.vent AS a
	ON i.patid = a.patid
WHERE a.admit_date_vent = i.admit_date; /* admit date of Mechanical Ventilation diagnosis = admit date of COVID+ diagnosis */
QUIT; /*  rows and 6 columns */

PROC SORT
DATA = vent NODUPKEY
DUPOUT = vent_dup		/* 0 duplicate rows */
OUT = DataCong.vent;	/*  unique rows and 6 columns */
BY patid admit_date_vent;
RUN;

/* 12.3 Check Missings in Mechanical Ventilation Data of COVID+ Patients */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,			 						/* 0 obs */
	   NMISS(patid) AS patid_miss_num, 												/* 0 obs */
	   NMISS(admit_date_vent) AS admit_date_vent_miss_num, 						/* 0 obs */
	   NMISS(px_date_vent) AS px_date_vent_miss_num,							/*  obs */
	   NMISS(px_date_vent)/N(encounterid) AS px_date_vent_miss_per,				/*  obs */
	   NMISS(admit_px_gap_vent) AS admit_px_gap_vent_miss_num,					/*  obs */
	   NMISS(admit_px_gap_vent)/N(encounterid) AS admit_px_gap_vent_miss_per,	/*  obs */
	   NMISS(px) AS px_miss_num				 										/* 0 obs */
FROM DataCong.vent;
QUIT;

/* 12.4 Create Mechanical Ventilation Data of COVID+ Encounters */
PROC SQL;
CREATE TABLE DataCong.vent_covid AS
SELECT i.encounterid, i.patid, i.admit_date, a.admit_date_vent, a.px_date_vent, a.admit_px_gap_vent, a.px,
	CASE
	   WHEN a.px IS NULL THEN 0
	   ELSE 1
	END AS vent
FROM DataCong.insight_covid_encounters AS i
LEFT JOIN DataCong.vent AS a
	ON i.patid = a.patid AND i.admit_date = a.admit_date_vent; /* admit date of Mechanical Ventilation diagnosis = admit date of COVID+ diagnosis */
QUIT; /* 32387 rows and 8 columns */

/* 12.5 Check Missings in Mechanical Ventilation Data of COVID+ Encounters */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,			 						/* 0 obs */
	   NMISS(patid) AS patid_miss_num, 												/* 0 obs */
	   NMISS(admit_date) AS admit_date_miss_num,		 							/* 0 obs */
	   NMISS(admit_date_vent) AS admit_date_vent_miss_num, 						/*  obs */
	   NMISS(admit_date_vent)/N(encounterid) AS admit_date_vent_miss_per,		/*  obs */
	   NMISS(px_date_vent) AS px_date_vent_miss_num,							/*  obs */
	   NMISS(px_date_vent)/N(encounterid) AS px_date_vent_miss_per,				/*  obs */
	   NMISS(admit_px_gap_vent) AS admit_px_gap_vent_miss_num,					/*  obs */
	   NMISS(admit_px_gap_vent)/N(encounterid) AS admit_px_gap_vent_miss_per,	/*  obs */
	   NMISS(px) AS px_miss_num,				 									/*  obs */
	   NMISS(px)/N(encounterid) AS px_miss_per,										/*  obs */
	   NMISS(vent) AS vent_miss_num				 								/* 0 obs */
FROM DataCong.vent_covid;
QUIT;

/* 12.6 Check Duplicates in Mechanical Ventilation Data of COVID+ Encounters */
PROC SORT
DATA = DataCong.vent_covid NODUPKEY
DUPOUT = vent_covid_dup	/* 0 duplicate rows */
OUT = vent_covid;			/* 32387 unique rows */
BY encounterid admit_date_vent;
RUN;

PROC SORT
DATA = vent_covid NODUPKEY
DUPOUT = vent_covid_dup		/* 0 duplicate encounterid */
OUT = DataCong.vent_covid;	/* 32387 unique encounterid */
BY encounterid;
RUN;

/* 13. Dialysis Data */
/* 13.1a Create Dialysis Data of COVID+ Patients during COVID-encounter */
PROC SQL;
CREATE TABLE DataCong.dialysis AS
SELECT proceduresid,
	   input(encounterid, best.) AS encounterid,	/* convert to numeric */
	   input(ssid, best.) AS patid,					/* convert to numeric */
	   ADMIT_DATE AS admit_date_dialysis,
	   PX_DATE AS px_date_dialysis,
	   INTCK('day', admit_date_dialysis, px_date_dialysis) AS admit_px_gap_dialysis,
       upcase(strip(px)) AS px
FROM DataSAS.Procedures
WHERE CALCULATED patid IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters) AND
	  admit_date_dialysis IN
		(SELECT DISTINCT admit_date
		 FROM DataCong.insight_covid_encounters) AND
	  upcase(strip(px)) IN  ('R88.0', 'Z49.01', 'Z49.02', 'Z49.31', 'Z49.32', '90935', '90937', '90939', '90940', '90941', '90942', '90943', '90944', '90945', '90996', '90997', '90998', '90999')  /* Ref: Codes for Care for Renal Dialysis from doi:10.36469/jheor.2023.57651*/
ORDER BY encounterid, patid, proceduresid;
QUIT; /* 18416 rows and 7 columns */

/* 13.2 Check Duplicates in Dialysis Data of COVID+ Patients */
PROC SORT
DATA = DataCong.dialysis NODUPKEY
DUPOUT = dialysis_dup	/*  duplicate rows */
OUT = dialysis;		/*  unique rows and 7 columns */
BY patid admit_date_dialysis px_date_dialysis admit_px_gap_dialysis px;
RUN;

PROC SQL;
CREATE TABLE DataCong.dialysis AS
SELECT a.*
FROM dialysis AS a
LEFT JOIN
		(SELECT patid, admit_date_dialysis, MIN(ABS(admit_px_gap_dialysis)) AS min_abs_admit_px_gap_dialysis
		 FROM dialysis
		 GROUP BY patid, admit_date_dialysis) AS m
	ON a.patid = m.patid AND a.admit_date_dialysis = m.admit_date_dialysis
WHERE ABS(a.admit_px_gap_dialysis) = m.min_abs_admit_px_gap_dialysis; /*Restricts to the first dialysis given during the admission*/
QUIT; /* 976 rows and 7 columns */

PROC SQL;
CREATE TABLE dialysis AS
SELECT i.encounterid, i.patid, a.admit_date_dialysis, a.px_date_dialysis, a.admit_px_gap_dialysis, a.px
FROM DataCong.insight_covid_encounters AS i
INNER JOIN DataCong.dialysis AS a
	ON i.patid = a.patid
WHERE a.admit_date_dialysis = i.admit_date; /* admit date of Dialysis diagnosis = admit date of COVID+ diagnosis */
QUIT; /* 1620 rows and 6 columns */

PROC SORT
DATA = dialysis NODUPKEY
DUPOUT = dialysis_dup		/* 0 duplicate rows */
OUT = DataCong.dialysis;	/*  unique rows and 6 columns */
BY patid admit_date_dialysis;
RUN;

/* 13.3 Check Missings in Dialysis Data of COVID+ Patients */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,			 						/* 0 obs */
	   NMISS(patid) AS patid_miss_num, 												/* 0 obs */
	   NMISS(admit_date_dialysis) AS admit_date_dialysis_miss_num, 						/* 0 obs */
	   NMISS(px_date_dialysis) AS px_date_dialysis_miss_num,							/*  obs */
	   NMISS(px_date_dialysis)/N(encounterid) AS px_date_dialysis_miss_per,				/*  obs */
	   NMISS(admit_px_gap_dialysis) AS admit_px_gap_dialysis_miss_num,					/*  obs */
	   NMISS(admit_px_gap_dialysis)/N(encounterid) AS admit_px_gap_dialysis_miss_per,	/*  obs */
	   NMISS(px) AS px_miss_num				 										/* 0 obs */
FROM DataCong.dialysis;
QUIT;

/* 13.4 Create Dialysis Data of COVID+ Encounters */
PROC SQL;
CREATE TABLE DataCong.dialysis_covid AS
SELECT i.encounterid, i.patid, i.admit_date, a.admit_date_dialysis, a.px_date_dialysis, a.admit_px_gap_dialysis, a.px,
	CASE
	   WHEN a.px IS NULL THEN 0
	   ELSE 1
	END AS dialysis
FROM DataCong.insight_covid_encounters AS i
LEFT JOIN DataCong.dialysis AS a
	ON i.patid = a.patid AND i.admit_date = a.admit_date_dialysis; /* admit date of Dialysis diagnosis = admit date of COVID+ diagnosis */
QUIT; /* 32387 rows and 8 columns */

/* 13.5 Check Missings in Dialysis Data of COVID+ Encounters */
PROC SQL;
SELECT NMISS(encounterid) AS encounterid_miss_num,			 						/* 0 obs */
	   NMISS(patid) AS patid_miss_num, 												/* 0 obs */
	   NMISS(admit_date) AS admit_date_miss_num,		 							/* 0 obs */
	   NMISS(admit_date_dialysis) AS admit_date_dialysis_miss_num, 						/*  obs */
	   NMISS(admit_date_dialysis)/N(encounterid) AS admit_date_dialysis_miss_per,		/*  obs */
	   NMISS(px_date_dialysis) AS px_date_dialysis_miss_num,							/*  obs */
	   NMISS(px_date_dialysis)/N(encounterid) AS px_date_dialysis_miss_per,				/*  obs */
	   NMISS(admit_px_gap_dialysis) AS admit_px_gap_dialysis_miss_num,					/*  obs */
	   NMISS(admit_px_gap_dialysis)/N(encounterid) AS admit_px_gap_dialysis_miss_per,	/*  obs */
	   NMISS(px) AS px_miss_num,				 									/*  obs */
	   NMISS(px)/N(encounterid) AS px_miss_per,										/*  obs */
	   NMISS(dialysis) AS dialysis_miss_num				 								/* 0 obs */
FROM DataCong.dialysis_covid;
QUIT;

/* 13.6 Check Duplicates in Dialysis Data of COVID+ Encounters */
PROC SORT
DATA = DataCong.dialysis_covid NODUPKEY
DUPOUT = dialysis_covid_dup	/* 0 duplicate rows */
OUT = dialysis_covid;			/* 32387 unique rows */
BY encounterid admit_date_dialysis; /*Also checked by patid and admitdate and no duplicates identified*/
RUN;

PROC SORT
DATA = dialysis_covid NODUPKEY
DUPOUT = dialysis_covid_dup		/* 0 duplicate encounterid */
OUT = DataCong.dialysis_covid;	/* 32387 unique encounterid */
BY encounterid;
RUN;

/*13.7 Identify individuals who have received dialysis before covid hospitalization*/

PROC SQL;
CREATE TABLE DataCong.comorbidity_dialysis AS
SELECT proceduresid,
	   input(encounterid, best.) AS encounterid, 	/* convert to numeric, for linking encounter data */
	   upcase(strip(enc_type)) AS enc_type_dialysis,
	   input(ssid, best.) AS patid_dialysis,	 		/* convert to numeric */
	   ADMIT_DATE AS admit_date_dialysis,
	   PX_DATE AS px_date,
	   upcase(strip(px_type)) AS px_type,
       upcase(strip(px)) AS px,
	CASE
		WHEN  upcase(strip(px)) IN  ('R88.0', 'Z49.01', 'Z49.02', 'Z49.31', 'Z49.32', '90935', '90937', '90939', '90940', '90941', '90942', '90943', '90944', '90945', '90996', '90997', '90998', '90999') THEN 1
		ELSE 0
	END AS dialysis
FROM DataSAS.Procedures
WHERE CALCULATED patid_dialysis IN
		(SELECT DISTINCT patid
		 FROM DataCong.insight_covid_encounters)
	  AND CALCULATED dialysis = 1
ORDER BY encounterid, patid_dialysis, proceduresid;
QUIT; /* 110188 rows and 9 columns */


/* 13.7.1 Identify indiviuals who received dialysis before covid encounter (Up to a week to accomodate small differences in admit dates due to transfers, mult encounters)*/
PROC SQL;
CREATE TABLE comorbidity_dialysis_covid AS
SELECT d.*, c.proceduresid, c.admit_date_dialysis, c.enc_type_dialysis, c.px_date, c.px_type, c.px, c.dialysis,
	CASE
		WHEN dialysis= 1 THEN 1
		ELSE 0
	END AS dialysis_updated
FROM DataCong.insight_covid_encounters AS d
LEFT JOIN DataCong.comorbidity_dialysis AS c
	ON d.patid = c.patid_dialysis
WHERE (admit_date IS NOT NULL AND admit_date > admit_date_dialysis+7)
ORDER BY encounterid, admit_date, admit_date_dialysis;
QUIT; /* 137375 rows and 21 columns */

/*13.7.2 Remove any duplicate dialysis treatments with same admit date*/ 
PROC SORT
DATA = comorbidity_dialysis_covid NODUPKEY
DUPOUT = comorbidity_dialysis_covid_dup	
OUT = comorbidity_dialysis_uniq;	
BY encounterid admit_date_dialysis;
RUN;

/*13.7.3 Include only those that received dialysis for now*/
data comorbidity_dialysis_pos;
set comorbidity_dialysis_uniq;
if dialysis=1;
run;

proc sort data=comorbidity_dialysis_pos
out=comorbidity_dialysis_pos2;
by patid encounterid admit_date admit_date_dialysis;
run;


/*13.7.4 Restrict to the earliest documentation of dialysis (again before covid encounter) but keep only patid and encounter*/
data comorbidity_dialysis_pos3;
set comorbidity_dialysis_pos2;
by patid encounterid admit_date;
if first.encounterid;
keep patid encounterid;
run;

proc sort data=datacong.dialysis_covid;
by patid encounterid;
run;

proc sort data=comorbidity_dialysis_pos3;
by patid encounterid;
run;

/*13.7.5 Combine two datasets to recode dialysis to differentiate prior to COVID encounter*/
data dialysis_new;
merge datacong.dialysis_covid (in=inall) comorbidity_dialysis_pos3 (in=inold);
by patid encounterid;
if inold then old=1;
if inall;
run;

proc freq data=dialysis_new;
table old*dialysis/missing;
run;

/*13.7.5.1 Recode to differentiate prior dialysis and those with both prior and dialysis during COVID hosp*/
data DataCong.dialysis_covid_final;
set dialysis_new;
 if old =1 and dialysis=1 then dialysis=2;
 else if old=1 and dialysis=0 then dialysis=-1;
 drop old;
run;

/* 14. Nevi Data */
/* 14.1 Prepare Nevi Data */
PROC SQL;
CREATE TABLE nevi AS
SELECT put(zip,9.) AS zip,
	   nevi,
	   score_demo,
	   score_economic,
	   score_residential,
	   score_healthstatus
FROM DataNevi.nevi;
QUIT; /* 181 rows and 6 columns */

/* 14.2 Check Missings in Nevi Data */
PROC SQL;
SELECT NMISS(zip) AS zip_miss_num,								/* 0 obs */
	   NMISS(nevi) AS nevi_miss_num,							/* 0 obs */
	   NMISS(score_demo) AS score_demo_miss_num,				/* 0 obs */ 
	   NMISS(score_economic) AS address_zip5_miss_num,			/* 0 obs */
	   NMISS(score_residential) AS score_economic_miss_num,		/* 0 obs */
	   NMISS(score_healthstatus) AS score_healthstatus_miss_num	/* 0 obs */
FROM nevi;
QUIT;

/* 14.3 Check Duplicates in Nevi Data */
PROC SORT
DATA = nevi NODUP
DUPOUT = nevi_dup	/* 0 duplicate rows */
OUT = nevi_uniq;	/* 181 unique rows */
BY zip;
RUN;

PROC SORT
DATA = nevi_uniq NODUPKEY
DUPOUT = nevi_dup_zip	/* 0 duplicate zip */
OUT = DataCong.nevi;	/* 181 unique zip */
BY zip;
RUN;

/* 15. Pollution Data */
/* 15.1 Prepare Pollution Data */
PROC SQL;
CREATE TABLE airpoll AS
SELECT put(ZCTA_5,9.) AS zcta5,
	   (PM_09 + PM_10 + PM_11 + PM_12 + PM_13 + PM_14 + PM_15 + PM_16 + PM_17 + PM_18 + PM_19) / 11 AS pm_avg,
	   (BC_09 + BC_10 + BC_11 + BC_12 + BC_13 + BC_14 + BC_15 + BC_16 + BC_17 + BC_18 + BC_19) / 11 AS bc_avg,
	   (NO2_09 + NO2_10 + NO2_11 + NO2_12 + NO2_13 + NO2_14 + NO2_15 + NO2_16 + NO2_17 + NO2_18 + NO2_19) / 11 AS no2_avg,
	   (O3_09 + O3_10 + O3_11 + O3_12 + O3_13 + O3_14 + O3_15 + O3_16 + O3_17 + O3_18 + O3_19) / 11 AS o3_avg
FROM DataNevi.airpoll2;
QUIT; /* 214 rows and 5 columns */

/* 15.2 Check Missings in Pollution Data */
PROC SQL;
SELECT NMISS(zcta5) AS zcta5_miss_num,		/* 0 obs */
	   NMISS(pm_avg) AS pm_avg_miss_num,	/* 0 obs */
	   NMISS(bc_avg) AS bc_avg_miss_num,	/* 0 obs */ 
	   NMISS(no2_avg) AS no2_avg_miss_num,	/* 0 obs */
	   NMISS(o3_avg) AS o3_avg_miss_num		/* 0 obs */
FROM airpoll;
QUIT;

/* 15.3 Check Duplicates in Pollution Data */
PROC SORT
DATA = airpoll NODUP
DUPOUT = airpoll_dup	/* 0 duplicate rows */
OUT = airpoll_uniq;		/* 214 unique rows */
BY zcta5;
RUN;

PROC SORT
DATA = airpoll_uniq NODUPKEY
DUPOUT = airpoll_dup_zip	/* 0 duplicate zip */
OUT = DataCong.airpoll;		/* 214 unique zip */
BY zcta5;
RUN;


/* 16. Model-Ready Dataset for COVID+ Population of Insight Data */
/* 16.1 Create Model-Ready Dataset for COVID+ Population of Insight Data */
PROC SQL;
CREATE TABLE DataCong.insight_covid_encounters_nevia AS
SELECT diag.*, vent.admit_date_vent, vent.admit_px_gap_vent, vent.vent, dialysis.admit_date_dialysis, dialysis.admit_px_gap_dialysis, dialysis.dialysis, ards.admit_date_ards, ards.admit_dx_gap_ards, ards.ards, pneumo.admit_date_pneumo, pneumo.admit_dx_gap_pneumo, pneumo.pneumo, smoking.measure_date_smk,
	   smoking.admit_measure_gap_smk, smoking.smoke, demo.birth_date, demo.age, demo.sex, demo.race, demo.hispanic, addr.address_period_start, addr.address_period_end,
	   addr.address_state, addr.address_city, addr.address_zip5, addr.address_zip9, addr.address_zip, nevi.nevi, nevi.score_demo, nevi.score_economic, nevi.score_residential,
	   nevi.score_healthstatus, poll.zcta5, poll.pm_avg, poll.bc_avg, poll.no2_avg, poll.o3_avg, diab.admit_date_diabetes, diab.diabetes, asth.admit_date_asthma, asth.asthma, hyper.admit_date_hyper, hyper.hyper,
	   vitl.measure_date_ht, vitl.ht_median, vitl.measure_date_wt, vitl.wt_median, vitl.measure_date_original_bmi, vitl.original_bmi_median, vitl.height, vitl.weight,
	   vitl.bmi_num, vitl.bmi_cat, vitl.measure_date_bp, vitl.measure_time_bp, vitl.diastolic_first, vitl.systolic_first 
FROM DataCong.insight_covid_encounters AS diag			/* From 4.2 */
LEFT JOIN DataCong.demographic_covid AS demo 			/* From 5.7 */
	ON diag.encounterid = demo.encounterid
LEFT JOIN DataCong.address_covid AS addr				/* From 6.7 */
	ON diag.encounterid = addr.encounterid
LEFT JOIN DataCong.comorbidity_diabetes_covid AS diab	/* From 7.1.6 */
	ON diag.encounterid = diab.encounterid
LEFT JOIN DataCong.comorbidity_asthma_covid AS asth		/* From 7.2.6 */
	ON diag.encounterid = asth.encounterid
LEFT JOIN DataCong.comorbidity_hyper_covid AS hyper		/* From 7.3.6 */
	ON diag.encounterid = hyper.encounterid
LEFT JOIN DataCong.vital_covid_ht_wt_bmi_bp AS vitl		/* From 8.10 */
	ON diag.encounterid = vitl.encounterid
LEFT JOIN DataCong.smoking_covid AS smoking				/* From 9.6 */
	ON diag.encounterid = smoking.encounterid
LEFT JOIN DataCong.ards_covid AS ards					/* From 10.6 */
	ON diag.encounterid = ards.encounterid
LEFT JOIN DataCong.pneumo_covid AS pneumo				/* From 11.6 */
	ON diag.encounterid = pneumo.encounterid
LEFT JOIN DataCong.vent_covid AS vent					/* From 12.6 */
	ON diag.encounterid = vent.encounterid
LEFT JOIN DataCong.dialysis_covid_final AS dialysis			/* From 13.7 */
	ON diag.encounterid = dialysis.encounterid
LEFT JOIN DataCong.nevi AS nevi							/* From 14.3 */
	ON strip(addr.address_zip) = strip(nevi.zip)
LEFT JOIN DataCong.airpoll AS poll						/* From 15.3 */
	ON strip(addr.address_zip) = strip(poll.zcta5)
ORDER BY diag.patid, diag.admit_date, diag.encounterid;
QUIT; /* 32387 rows and 62 columns */

/* 16.2 Check Duplicates in Model-Ready Dataset for COVID+ Population of Insight Data */
PROC SQL;
SELECT num_encounter_per_patid_date, COUNT(num_encounter_per_patid_date) AS num_encounter
FROM
	(SELECT COUNT(encounterid) AS num_encounter_per_patid_date /* Only 1 encounterid at the same admit_date for the same patid */
	 FROM DataCong.insight_covid_encounters_nevia
	 GROUP BY patid, admit_date)
GROUP BY num_encounter_per_patid_date;

CREATE TABLE insight_covid_encounters_nevi_dp AS
SELECT *
FROM DataCong.insight_covid_encounters_nevia
WHERE encounterid IN
	(SELECT encounterid
	 FROM DataCong.insight_covid_encounters_nevia
	 GROUP BY patid, admit_date
	 HAVING COUNT(encounterid) > 1)	/* 0 duplicate encounterid at the same admit_date for the same patid */
ORDER BY patid, admit_date, encounterid;
QUIT;

/*16.3 Combine adjacent encounters into single admission (those whose discharge date is same day as next admit date*/

Data insight_covid_combine;
SET DataCong.insight_covid_encounters_nevia;
By patid;

Retain admit_date_r discharge_date_r admit_date_phase_r hospital_days_r ards_r pneumo_r vent_r dialysis_r asthma_r diabetes_r hyper_r smoke_r age_r bmi_num_r diastolic_first_r systolic_first_r;

if first.patid then do;
	admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;
	end;
 else do;
	if admit_date = discharge_date_r then do;  
	admit_date=admit_date_r;
	admit_date_phase=admit_date_phase_r;
	hospital_days=hospital_days+hospital_days_r; /*Calculate hospital days as sum of encounters*/
	if ards ne 1 and ards_r=1 then ards=1;		/*If earlier encounter had outcome recorded and it isn't in the later encounter, we recode here*/
	if pneumo ne 1 and pneumo_r=1 then pneumo=1;
	if vent ne 1 and vent_r=1 then vent=1;
	if dialysis in (0,1,2) then dialysis=dialysis; /*If later encounter has 0 or 1 for dialysis, earlier dialysis must be 0 so stays the same. If later encounter has 2, stays same.*/
		else if dialysis=-1 and dialysis_r = 1 then dialysis=1;       /*If later encounter has -1, could have been from earlier covid encounter. So need to check that dialysis_r ne 1. If is, recode*/

	asthma=asthma_r;													/*Use chronic disease from earlier encounter*/
	diabetes=diabetes_r;
	hyper=hyper_r;
	smoke=smoke_r;
	age=age_r;
	bmi_num=bmi_num_r;
	diastolic_first=diastolic_first_r;
	systolic_first=systolic_first_r;

	admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;

end;
admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;
end;
run;

/*Adjacent dates will now have same admit_dates and patient_ids. Sort so we can identify the last one in the group which is the one with the latest discharge. That will be retained*/

PROC SORT
	DATA=insight_covid_combine
	OUT=insight_covid_combine_sort;
	BY PATID ADMIT_DATE DISCHARGE_DATE;
RUN;

DATA insight_covid_encounters_nevi;
	SET insight_covid_combine_sort;
	BY patid admit_date discharge_date;
	IF last.admit_date;
run;



data time_diff;
set insight_covid_encounters_nevi;
by patid;
retain prev_end_date;

time_diff=.;

if first.patid then do;
prev_end_date=.;
end;

if not first.patid then do;
time_diff=admit_date-prev_end_date;
end;

prev_end_date=discharge_date;
run;

proc means data=time_diff min max;
var time_diff;
run;

data flag;
set time_diff;
where .z<time_diff <0;
run;




/*16.4 Manually check 10 PATIDs with adjacent encounters to ensure correct variable construction; Checks out*/

data rand;
set DataCong.insight_covid_encounters_nevia;
by patid;
Retain admit_date_r discharge_date_r ;
if first.patid then do;
	admit_date_r=admit_date;
	discharge_date_r=discharge_date;
	end;
 else do;
	if admit_date= discharge_date_r then flag=1;
	end;
	if flag=1;
	keep patid;
run;
 
proc surveyselect data=rand
out=randcheckid
sampsize = 10
seed = 300736001;
run; 

data comparison_ds;
merge randcheckid (in=inrand) DataCong.insight_covid_encounters_nevi_ar; /*Using copy of dataset created before merging rows*/
by patid;
if inrand; 
run;

proc means data=comparison_ds sum ;
var hospital_days;
by patid;
run;

data final_data_compare;
merge randcheckid (in=inrand) insight_covid_encounters_nevi; 
by patid;
if inrand; 
run;

proc means data=final_data_compare sum ;
var hospital_days;
by patid;
run;

proc freq data=final_data_compare;
table asthma diabetes;
by patid;
run;

proc freq data=comparison_ds;
table asthma diabetes;
by patid;
run;

/*16.5 Merge encounters with over-lapping but not exactly adjacent admission/discharge dates*/
	/*For repeat Patient IDs, calculate time in days between discharge and admission of next encounter to examine types of overlap*/
	/*Note this is checking each encounter to the previous. Works in majority of cases because only 2. But can miss some if 3 or more. Have code below*/
    /*to catch those instances.*/

data insight_covid_encounters_nevi_2;
set insight_covid_encounters_nevi;
drop admit_date_r discharge_date_r;
run;

data encounter_overlap_test;
set insight_covid_encounters_nevi_2;
by patid;
Retain admit_date_r discharge_date_r ;
if first.patid then do;
	admit_date_r=admit_date;
	discharge_date_r=discharge_date;
	end;
 else do;
	timebw1=admit_date-discharge_date_r;
	timebw2=discharge_date-discharge_date_r;
	discharge_date_r=discharge_date;
	end;

if .z<timebw1<=0 and .z<timebw2<=0 then overlap=1; /*Subsequent encounter fully within prior*/
else if .z<timebw1<=0 and timebw2=>0 then overlap=2; /*Partial overlap*/
else if timebw1=>0 and .z<timebw2<=0 then overlap=3; /*Partial overlap*/
else if timebw1>0 and timebw2>0 then overlap=0; /*Subsequent encounter fully after prior*/
else overlap=99; 
run;

proc freq data=encounter_overlap_test;
table overlap/missing;
run;

/*All subsequent encounters are either fully within or fully after (yay!). Now need to merge the fully within. No need to change admit days or any variables created just using patid or .*/
/*where we default to using first entry (e.g. BMI, age). However, want to confirm that the first full encounter (admit-discharge) reflects outcomes (ards, pneumo, vent) that happened in overlapping encounters*/

/*Identify those who have conflicting values for outcomes-pneumo, ards, vent and dialysis */
data temp(rename=(admit_date=_admit_date pneumo=_pneumo));
set encounter_overlap_test;
if patid eq lag(patid) and overlap =1 and ( (pneumo=1 and lag(pneumo)=0));
run;

/*Merge subsequent outcome into full encounter*/
data new (drop=_:);
merge temp encounter_overlap_test;
by patid;
if admit_date lt _admit_date then pneumo=_pneumo;
run;

data temp2(rename=(admit_date=_admit_date ards=_ards));
set new;
if patid eq lag(patid) and overlap =1 and ( (ards=1 and lag(ards)=0));
run;

/*Merge subsequent outcome into full encounter*/
data new2 (drop=_:);
merge temp2 new;
by patid;
if admit_date lt _admit_date then ards=_ards;
run;

data temp3(rename=(admit_date=_admit_date vent=_vent)); /*No vent discrepancies*/
set new2;
if patid eq lag(patid) and overlap =1 and ( (vent=1 and lag(vent)=0));
run;

data temp4(rename=(admit_date=_admit_date dialysis=_dialysis)); /*No dialysis discrepancies*/
set new2;
if patid eq lag(patid) and overlap =1 and ( (dialysis>0 and lag(dialysis)<=0));
run;

/*Restrict dataset to only the first encounter now that discrepancies have been corrected*/
DATA new3;
	SET new2;
	if overlap=99 or overlap=0; /*Only want to remove the encounters that are fully within the other encounter; those were flagged with 1 above*/
run;

/*Checking to ensure that no PATIDs were dropped by mistake*/
proc sql;
select count(distinct patid) as distinct_patid
from new3;
quit;

proc sql;
select count(distinct patid) as distinct_patid
from DataCong.insight_covid_encounters_nevi;
quit;
/*Totals match*/

/*Confirm that phase is correct based on admit_date (b/c we combined some encounters*/

data test_phase;
set new3;

if  ADMIT_DATE  < '01MAR2020'd THEN phase_check= 0;
	   else if ADMIT_DATE <= '30JUN2020'd THEN phase_check= 1;
	   else if ADMIT_DATE <= '31OCT2020'd THEN phase_check= 2;
	   else if ADMIT_DATE <= '28FEB2021'd THEN phase_check= 3;

	   check_zero=admit_date_phase-phase_check;
	   run;

proc means data=test_phase nmiss;
var check_zero;
run;

/*Code to catch those where there are more than 2 encounters per patid and require additional cleaning to ensure no duplicates*/
proc sort data=new3;
by patid admit_date;
run;

data test_a;
set new3;
by patid;

retain lag_discharge_date;

if first.patid then do;
diff=.;
lag_discharge_date=.;
end;

else diff=admit_date-lag_discharge_date;
lag_discharge_date=discharge_date;
run;

proc univariate data=test_a;
var diff;
run;

proc sort data=test_a;
by patid admit_date;
run;

data test_2a;
set test_a;
by patid;

retain has_negative_diff;

if first.patid then do;
has_negative_diff=0;
if .<diff<=0 then has_negative_diff=1;
end;
else if .<diff<=0 then has_negative_diff=1;
if last.patid and has_negative_diff=1 then output;
run;

data test_3a;
merge test_2a (in=a) test_a (in=b);
by patid;
if a;
run;

/*Checking that remaining have no negative differences*/
data test_4a;
merge test_2a (in=a) test_a (in=b);
by patid;
if ~ a;
run;

proc means data=test_4a;
var diff;
run;

/*Combine adjacent and then merge those that are fully within*/
proc sort data=test_3a;
by patid admit_date;
run;

data test_3a;
set test_3a;
drop overlap lag_discharge_date diff has_negative_diff timebw1 timebw2 admit_date_r discharge_date_r admit_date_phase_r hospital_days_r ards_r pneumo_r vent_r dialysis_r asthma_r diabetes_r hyper_r smoke_r age_r bmi_num_r diastolic_first_r systolic_first_r;
run;

Data insight_covid_combine_a;
SET test_3a;
By patid;

Retain admit_date_r discharge_date_r admit_date_phase_r hospital_days_r ards_r pneumo_r vent_r dialysis_r asthma_r diabetes_r hyper_r smoke_r age_r bmi_num_r diastolic_first_r systolic_first_r;

if first.patid then do;
	admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;
	end;
 else do;
	if admit_date = discharge_date_r then do;  
	admit_date=admit_date_r;
	admit_date_phase=admit_date_phase_r;
	hospital_days=hospital_days+hospital_days_r; /*Calculate hospital days as sum of encounters*/
	if ards ne 1 and ards_r=1 then ards=1;		/*If earlier encounter had outcome recorded and it isn't in the later encounter, we recode here*/
	if pneumo ne 1 and pneumo_r=1 then pneumo=1;
	if vent ne 1 and vent_r=1 then vent=1;
	if dialysis in (0,1,2) then dialysis=dialysis; /*If later encounter has 0 or 1 for dialysis, earlier dialysis must be 0 so stays the same. If later encounter has 2, stays same.*/
		else if dialysis=-1 and dialysis_r = 1 then dialysis=1;       /*If later encounter has -1, could have been from earlier covid encounter. So need to check that dialysis_r ne 1. If is, recode*/

	asthma=asthma_r;													/*Use chronic disease from earlier encounter*/
	diabetes=diabetes_r;
	hyper=hyper_r;
	smoke=smoke_r;
	age=age_r;
	bmi_num=bmi_num_r;
	diastolic_first=diastolic_first_r;
	systolic_first=systolic_first_r;

	admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;

end;
else do;
admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;
end;
end;
run;

/*Adjacent dates will now have same admit_dates and patient_ids. Sort so we can identify the last one in the group which is the one with the latest discharge. That will be retained*/

PROC SORT
	DATA=insight_covid_combine_a
	OUT=insight_covid_combine_sort_a;
	BY PATID ADMIT_DATE DISCHARGE_DATE;
RUN;

DATA insight_covid_encounters_nevi_a;
	SET insight_covid_combine_sort_a;
	BY patid admit_date discharge_date;
	IF last.admit_date;
run;



data time_diff_a;
set insight_covid_encounters_nevi_a;
by patid;
retain prev_end_date;

time_diff=.;

if first.patid then do;
prev_end_date=.;
end;

if not first.patid then do;
time_diff=admit_date-prev_end_date;
end;

prev_end_date=discharge_date;
run;

proc means data=time_diff_a min max;
var time_diff;
run;

data flag_a;
set time_diff_a;
where .z<time_diff <0;
run;

data insight_covid_encounters_nevi_2a;
set insight_covid_encounters_nevi_a;
drop admit_date_r discharge_date_r;
run;

data encounter_overlap_test_a;
set insight_covid_encounters_nevi_2a;
by patid;
Retain admit_date_r discharge_date_r ;
if first.patid then do;
	admit_date_r=admit_date;
	discharge_date_r=discharge_date;
	end;
 else do;
	timebw1=admit_date-discharge_date_r;
	timebw2=discharge_date-discharge_date_r;
	discharge_date_r=discharge_date;
	end;

if .z<timebw1<=0 and .z<timebw2<=0 then overlap=1; /*Subsequent encounter fully within prior*/
else if .z<timebw1<=0 and timebw2=>0 then overlap=2; /*Partial overlap*/
else if timebw1=>0 and .z<timebw2<=0 then overlap=3; /*Partial overlap*/
else if timebw1>0 and timebw2>0 then overlap=0; /*Subsequent encounter fully after prior*/
else overlap=99; 
run;

proc freq data=encounter_overlap_test_a;
table overlap/missing;
run;

/*All subsequent encounters are either fully within or fully after (yay!). Now need to merge the fully within. No need to change admit days or any variables created just using patid or .*/
/*where we default to using first entry (e.g. BMI, age). However, want to confirm that the first full encounter (admit-discharge) reflects outcomes (ards, pneumo, vent) that happened in overlapping encounters*/

/*Identify those who have conflicting values for outcomes-pneumo, ards, vent and dialysis */
data temp(rename=(admit_date=_admit_date pneumo=_pneumo));
set encounter_overlap_test_a;
if patid eq lag(patid) and overlap =1 and ( (pneumo=1 and lag(pneumo)=0));
run;

/*Merge subsequent outcome into full encounter*/
data new (drop=_:);
merge temp encounter_overlap_test_a;
by patid;
if admit_date lt _admit_date then pneumo=_pneumo;
run;

data temp2(rename=(admit_date=_admit_date ards=_ards));
set new;
if patid eq lag(patid) and overlap =1 and ( (ards=1 and lag(ards)=0));
run;

/*Merge subsequent outcome into full encounter*/
data new2 (drop=_:);
merge temp2 new;
by patid;
if admit_date lt _admit_date then ards=_ards;
run;

data temp3(rename=(admit_date=_admit_date vent=_vent)); /*No vent discrepancies*/
set new2;
if patid eq lag(patid) and overlap =1 and ( (vent=1 and lag(vent)=0));
run;

data temp4(rename=(admit_date=_admit_date dialysis=_dialysis)); /*No dialysis discrepancies*/
set new2;
if patid eq lag(patid) and overlap =1 and ( (dialysis>0 and lag(dialysis)<=0));
run;

/*Restrict dataset to only the first encounter now that discrepancies have been corrected*/
DATA new3;
	SET new2;
	if overlap=99 or overlap=0; /*Only want to remove the encounters that are fully within the other encounter; those were flagged with 1 above*/
run;

/*Check if we eliminated all duplicates*/
proc sort data=new3;
by patid admit_date;
run;

data test;
set new3;
by patid;

retain lag_discharge_date;

if first.patid then do;
diff=.;
lag_discharge_date=.;
end;

else diff=admit_date-lag_discharge_date;
lag_discharge_date=discharge_date;
run;

proc univariate data=test;
var diff;
run;

/*Still have negative differences so rerun another round of code*/

proc sort data=test;
by patid admit_date;
run;

data test2;
set test;
by patid;

retain has_negative_diff;

if first.patid then do;
has_negative_diff=0;
if .<diff<=0 then has_negative_diff=1;
end;
else if .<diff<=0 then has_negative_diff=1;
if last.patid and has_negative_diff=1 then output;
run;

data test3;
merge test2 (in=a) test (in=b);
by patid;
if a;
run;

/*Checking that remaining have no negative differences*/
data test5; /*Changing so not to overwrite test4 which has to be merged back*/
merge test2 (in=a) test (in=b);
by patid;
if ~ a;
run;

proc means data=test5;
var diff;
run;

/*Combine adjacent and then merge those that are fully within*/
proc sort data=test3;
by patid admit_date;
run;

data test3;
set test3;
drop overlap timebw1 timebw2 lag_discharge_date diff has_negative_diff admit_date_r discharge_date_r admit_date_phase_r hospital_days_r ards_r pneumo_r vent_r dialysis_r asthma_r diabetes_r hyper_r smoke_r age_r bmi_num_r diastolic_first_r systolic_first_r;
run;

Data insight_covid_combine;
SET test3;
By patid;

Retain admit_date_r discharge_date_r admit_date_phase_r hospital_days_r ards_r pneumo_r vent_r dialysis_r asthma_r diabetes_r hyper_r smoke_r age_r bmi_num_r diastolic_first_r systolic_first_r;

if first.patid then do;
	admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;
	end;
 else do;
	if admit_date = discharge_date_r then do;  
	admit_date=admit_date_r;
	admit_date_phase=admit_date_phase_r;
	hospital_days=hospital_days+hospital_days_r; /*Calculate hospital days as sum of encounters*/
	if ards ne 1 and ards_r=1 then ards=1;		/*If earlier encounter had outcome recorded and it isn't in the later encounter, we recode here*/
	if pneumo ne 1 and pneumo_r=1 then pneumo=1;
	if vent ne 1 and vent_r=1 then vent=1;
	if dialysis in (0,1,2) then dialysis=dialysis; /*If later encounter has 0 or 1 for dialysis, earlier dialysis must be 0 so stays the same. If later encounter has 2, stays same.*/
		else if dialysis=-1 and dialysis_r = 1 then dialysis=1;       /*If later encounter has -1, could have been from earlier covid encounter. So need to check that dialysis_r ne 1. If is, recode*/

	asthma=asthma_r;													/*Use chronic disease from earlier encounter*/
	diabetes=diabetes_r;
	hyper=hyper_r;
	smoke=smoke_r;
	age=age_r;
	bmi_num=bmi_num_r;
	diastolic_first=diastolic_first_r;
	systolic_first=systolic_first_r;

	admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;

end;
else do;
admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;
end;
end;
run;

/*Adjacent dates will now have same admit_dates and patient_ids. Sort so we can identify the last one in the group which is the one with the latest discharge. That will be retained*/

PROC SORT
	DATA=insight_covid_combine
	OUT=insight_covid_combine_sort;
	BY PATID ADMIT_DATE DISCHARGE_DATE;
RUN;

DATA insight_covid_encounters_nevi;
	SET insight_covid_combine_sort;
	BY patid admit_date discharge_date;
	IF last.admit_date;
run;



data time_diff;
set insight_covid_encounters_nevi;
by patid;
retain prev_end_date;

time_diff=.;

if first.patid then do;
prev_end_date=.;
end;

if not first.patid then do;
time_diff=admit_date-prev_end_date;
end;

prev_end_date=discharge_date;
run;

proc means data=time_diff min max;
var time_diff;
run;

data flag;
set time_diff;
where .z<time_diff <0;
run;

data insight_covid_encounters_nevi_2;
set insight_covid_encounters_nevi;
drop admit_date_r discharge_date_r;
run;

data encounter_overlap_test;
set insight_covid_encounters_nevi_2;
by patid;
Retain admit_date_r discharge_date_r ;
if first.patid then do;
	admit_date_r=admit_date;
	discharge_date_r=discharge_date;
	end;
 else do;
	timebw1=admit_date-discharge_date_r;
	timebw2=discharge_date-discharge_date_r;
	discharge_date_r=discharge_date;
	end;

if .z<timebw1<=0 and .z<timebw2<=0 then overlap=1; /*Subsequent encounter fully within prior*/
else if .z<timebw1<=0 and timebw2=>0 then overlap=2; /*Partial overlap*/
else if timebw1=>0 and .z<timebw2<=0 then overlap=3; /*Partial overlap*/
else if timebw1>0 and timebw2>0 then overlap=0; /*Subsequent encounter fully after prior*/
else overlap=99; 
run;

proc freq data=encounter_overlap_test;
table overlap/missing;
run;

/*All subsequent encounters are either fully within or fully after (yay!). Now need to merge the fully within. No need to change admit days or any variables created just using patid or .*/
/*where we default to using first entry (e.g. BMI, age). However, want to confirm that the first full encounter (admit-discharge) reflects outcomes (ards, pneumo, vent) that happened in overlapping encounters*/

/*Identify those who have conflicting values for outcomes-pneumo, ards, vent and dialysis */
data temp(rename=(admit_date=_admit_date pneumo=_pneumo));
set encounter_overlap_test;
if patid eq lag(patid) and overlap =1 and ( (pneumo=1 and lag(pneumo)=0));
run;

/*Merge subsequent outcome into full encounter*/
data new (drop=_:);
merge temp encounter_overlap_test;
by patid;
if admit_date lt _admit_date then pneumo=_pneumo;
run;

data temp2(rename=(admit_date=_admit_date ards=_ards));
set new;
if patid eq lag(patid) and overlap =1 and ( (ards=1 and lag(ards)=0));
run;

/*Merge subsequent outcome into full encounter*/
data new2 (drop=_:);
merge temp2 new;
by patid;
if admit_date lt _admit_date then ards=_ards;
run;

data temp3(rename=(admit_date=_admit_date vent=_vent)); /*No vent discrepancies*/
set new2;
if patid eq lag(patid) and overlap =1 and ( (vent=1 and lag(vent)=0));
run;

data temp4(rename=(admit_date=_admit_date dialysis=_dialysis)); /*No dialysis discrepancies*/
set new2;
if patid eq lag(patid) and overlap =1 and ( (dialysis>0 and lag(dialysis)<=0));
run;

/*Restrict dataset to only the first encounter now that discrepancies have been corrected*/
DATA new3;
	SET new2;
	if overlap=99 or overlap=0; /*Only want to remove the encounters that are fully within the other encounter; those were flagged with 1 above*/
run;

/*Need to run another round*/
proc sort data=new3;
by patid admit_date;
run;

data test3;
set test3;
drop overlap timebw1 timebw2 lag_discharge_date diff has_negative_diff admit_date_r discharge_date_r admit_date_phase_r hospital_days_r ards_r pneumo_r vent_r dialysis_r asthma_r diabetes_r hyper_r smoke_r age_r bmi_num_r diastolic_first_r systolic_first_r;
run;

data test;
set new3;
by patid;

retain lag_discharge_date;

if first.patid then do;
diff=.;
lag_discharge_date=.;
end;

else diff=admit_date-lag_discharge_date;
lag_discharge_date=discharge_date;
run;

proc univariate data=test;
var diff;
run;

/*Still have negative and zero differences so rerun another round of code*/

proc sort data=test;
by patid admit_date;
run;

data test2;
set test;
by patid;

retain has_negative_diff;

if first.patid then do;
has_negative_diff=0;
if .<diff<=0 then has_negative_diff=1;
end;
else if .<diff<=0 then has_negative_diff=1;
if last.patid and has_negative_diff=1 then output;
run;

data test3;
merge test2 (in=a) test (in=b);
by patid;
if a;
run;

/*Checking that remaining have no negative differences*/
data test6; /*Changing so not to overwrite test5 which has to be merged back*/
merge test2 (in=a) test (in=b);
by patid;
if ~ a;
run;

proc means data=test6;
var diff;
run;

/*Combine adjacent and then merge those that are fully within*/
proc sort data=test3;
by patid admit_date;
run;

data test3;
set test3;
drop admit_date_r discharge_date_r admit_date_phase_r hospital_days_r ards_r pneumo_r vent_r dialysis_r asthma_r diabetes_r hyper_r smoke_r age_r bmi_num_r diastolic_first_r systolic_first_r;
run;

Data insight_covid_combine;
SET test3;
By patid;

Retain admit_date_r discharge_date_r admit_date_phase_r hospital_days_r ards_r pneumo_r vent_r dialysis_r asthma_r diabetes_r hyper_r smoke_r age_r bmi_num_r diastolic_first_r systolic_first_r;

if first.patid then do;
	admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;
	end;
 else do;
	if admit_date = discharge_date_r then do;  
	admit_date=admit_date_r;
	admit_date_phase=admit_date_phase_r;
	hospital_days=hospital_days+hospital_days_r; /*Calculate hospital days as sum of encounters*/
	if ards ne 1 and ards_r=1 then ards=1;		/*If earlier encounter had outcome recorded and it isn't in the later encounter, we recode here*/
	if pneumo ne 1 and pneumo_r=1 then pneumo=1;
	if vent ne 1 and vent_r=1 then vent=1;
	if dialysis in (0,1,2) then dialysis=dialysis; /*If later encounter has 0 or 1 for dialysis, earlier dialysis must be 0 so stays the same. If later encounter has 2, stays same.*/
		else if dialysis=-1 and dialysis_r = 1 then dialysis=1;       /*If later encounter has -1, could have been from earlier covid encounter. So need to check that dialysis_r ne 1. If is, recode*/

	asthma=asthma_r;													/*Use chronic disease from earlier encounter*/
	diabetes=diabetes_r;
	hyper=hyper_r;
	smoke=smoke_r;
	age=age_r;
	bmi_num=bmi_num_r;
	diastolic_first=diastolic_first_r;
	systolic_first=systolic_first_r;

	admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;

end;
else do;
admit_date_r=admit_date;
	admit_date_phase_r=admit_date_phase;
	discharge_date_r=discharge_date;
	hospital_days_r=hospital_days;
	ards_r=ards;
	pneumo_r=pneumo;
	vent_r=vent;
	dialysis_r=dialysis;
	asthma_r=asthma;
	diabetes_r=diabetes;
	hyper_r=hyper;
	smoke_r=smoke;
	age_r=age;
	bmi_num_r=bmi_num;
	diastolic_first_r=diastolic_first;
	systolic_first_r=systolic_first;
end;
end;
run;

/*Adjacent dates will now have same admit_dates and patient_ids. Sort so we can identify the last one in the group which is the one with the latest discharge. That will be retained*/

PROC SORT
	DATA=insight_covid_combine
	OUT=insight_covid_combine_sort;
	BY PATID ADMIT_DATE DISCHARGE_DATE;
RUN;

DATA insight_covid_encounters_nevi;
	SET insight_covid_combine_sort;
	BY patid admit_date discharge_date;
	IF last.admit_date;
run;



data time_diff;
set insight_covid_encounters_nevi;
by patid;
retain prev_end_date;

time_diff=.;

if first.patid then do;
prev_end_date=.;
end;

if not first.patid then do;
time_diff=admit_date-prev_end_date;
end;

prev_end_date=discharge_date;
run;

proc means data=time_diff min max;
var time_diff;
run;

data flag;
set time_diff;
where .z<time_diff <0;
run;

data insight_covid_encounters_nevi_2;
set insight_covid_encounters_nevi;
drop admit_date_r discharge_date_r;
run;

data encounter_overlap_test;
set insight_covid_encounters_nevi_2;
by patid;
Retain admit_date_r discharge_date_r ;
if first.patid then do;
	admit_date_r=admit_date;
	discharge_date_r=discharge_date;
	end;
 else do;
	timebw1=admit_date-discharge_date_r;
	timebw2=discharge_date-discharge_date_r;
	discharge_date_r=discharge_date;
	end;

if .z<timebw1<=0 and .z<timebw2<=0 then overlap=1; /*Subsequent encounter fully within prior*/
else if .z<timebw1<=0 and timebw2=>0 then overlap=2; /*Partial overlap*/
else if timebw1=>0 and .z<timebw2<=0 then overlap=3; /*Partial overlap*/
else if timebw1>0 and timebw2>0 then overlap=0; /*Subsequent encounter fully after prior*/
else overlap=99; 
run;

proc freq data=encounter_overlap_test;
table overlap/missing;
run;

/*All subsequent encounters are either fully within or fully after (yay!). Now need to merge the fully within. No need to change admit days or any variables created just using patid or .*/
/*where we default to using first entry (e.g. BMI, age). However, want to confirm that the first full encounter (admit-discharge) reflects outcomes (ards, pneumo, vent) that happened in overlapping encounters*/

/*Identify those who have conflicting values for outcomes-pneumo, ards, vent and dialysis */
data temp(rename=(admit_date=_admit_date pneumo=_pneumo));
set encounter_overlap_test;
if patid eq lag(patid) and overlap =1 and ( (pneumo=1 and lag(pneumo)=0));
run;

/*Merge subsequent outcome into full encounter*/
data new (drop=_:);
merge temp encounter_overlap_test;
by patid;
if admit_date lt _admit_date then pneumo=_pneumo;
run;

data temp2(rename=(admit_date=_admit_date ards=_ards));
set new;
if patid eq lag(patid) and overlap =1 and ( (ards=1 and lag(ards)=0));
run;

/*Merge subsequent outcome into full encounter*/
data new2 (drop=_:);
merge temp2 new;
by patid;
if admit_date lt _admit_date then ards=_ards;
run;

data temp3(rename=(admit_date=_admit_date vent=_vent)); /*No vent discrepancies*/
set new2;
if patid eq lag(patid) and overlap =1 and ( (vent=1 and lag(vent)=0));
run;

data temp4(rename=(admit_date=_admit_date dialysis=_dialysis)); /*No dialysis discrepancies*/
set new2;
if patid eq lag(patid) and overlap =1 and ( (dialysis>0 and lag(dialysis)<=0));
run;

/*Restrict dataset to only the first encounter now that discrepancies have been corrected*/
DATA new3;
	SET new2;
	if overlap=99 or overlap=0; /*Only want to remove the encounters that are fully within the other encounter; those were flagged with 1 above*/
run;

/*Need to merge datasets containing cleaned data*/

data all_nondup;
set new3 test_4a test5 test6;
run;

/*Code to check if all overlapping/adjacent encounters have been cleaned*/
proc sort data=all_nondup;
by patid admit_date;
run;

data all_nondup;
set all_nondup;
drop diff lag_discharge_date;
run;

data check;
set all_nondup;
by patid;

retain lag_discharge_date;
if first.patid then do;
diff=.;
lag_discharge_date=.;
end;

else diff=admit_date-lag_discharge_date;
lag_discharge_date=discharge_date;
run;

proc means data=check;
var diff; /*All positive differences greater than 0*/
run;

proc sql;
select count( distinct patid) as unique_count
from check;
quit;

data DataCong.insight_covid_encounters_nevi; /*Save final analytic dataset and drop unneeded variables*/
set all_nondup;
drop admit_time admit_date_time discharge_time discharge_date_time admit_px_gap_vent admit_px_gap_dialysis admit_dx_gap_ards admit_dx_gap_pneumo admit_measure_gap_smk measure_date: ht_median wt_median original_bmi_median height weight bmi_cat admit_date_r discharge_date_r
hospital_days_r ards_r pneumo_r vent_r dialysis_r asthma_r diabetes_r hyper_r smoke_r age_r bmi_num_r diastolic_first_r systolic_first_r admit_date_phase_r overlap; 
run;



/* 17. Distributions of Model-Ready Dataset for COVID+ Population of Insight Data */
PROC CONTENTS
	DATA =  DataCong.insight_covid_encounters_nevi
	ORDER = VARNUM;
RUN;

ODS EXCEL FILE="L:\dcore-prj0131-SHARED\dcore-prj0131-Stingone\Datasets_JAS\Distributions of Model-Ready Dataset for COVID+ Population of Insight Data.xlsx";

/* 17.1 Distributions of Model-Ready Dataset for COVID+ Population of Insight Data: All Phases */
PROC FREQ
	DATA = DataCong.insight_covid_encounters_nevi;
	TABLES encounter_type admit_date_phase discharge_disposition sex race hispanic
		   diabetes asthma bmi_cat hyper ards pneumo vent dialysis smoke / MISSING;
	TITLE "Descriptive Statistics of Categorical Variables of Insight Data: All Phases";
RUN;

PROC MEANS
	DATA = DataCong.insight_covid_encounters_nevi N NMISS MEAN STD MIN MAX;
	VAR hospital_days age nevi score_demo score_economic
		score_residential score_healthstatus pm_avg bc_avg no2_avg o3_avg bmi_num diastolic_first systolic_first;
	TITLE "Descriptive Statistics of Numeric Variables of Insight Data: All Phases";
RUN;

/* 17.2 Distributions of Model-Ready Dataset for COVID+ Population of Insight Data: Stratified by Admission Phase */
PROC FREQ
	DATA = DataCong.insight_covid_encounters_nevi;
	TABLES admit_date_phase * (encounter_type admit_date_phase discharge_disposition sex race hispanic
		   diabetes asthma bmi_cat hyper ards pneumo vent dialysis smoke) / MISSING;
	TITLE "Descriptive Statistics of Categorical Variables of Insight Data: Stratified by Admission Phase";
RUN;

PROC MEANS
	DATA = DataCong.insight_covid_encounters_nevi N NMISS MEAN STD MIN MAX;
	VAR hospital_days age nevi score_demo score_economic
		score_residential score_healthstatus pm_avg bc_avg no2_avg o3_avg bmi_num diastolic_first systolic_first;
	CLASS admit_date_phase;
	TITLE "Descriptive Statistics of Numeric Variables of Insight Data: Stratified by Admission Phase";
RUN;

ODS EXCEL CLOSE;
