
/*--------- Query 1 (POINT 1). Patient Treatment Outcome Analysis ------------ */

CREATE VIEW prescribe_med AS(
SELECT
	pd.PrescriptionID,
    # pd.MedicationID,
    GROUP_CONCAT( m.Name ORDER BY m.Name SEPARATOR ',') AS precribed_medication
FROM prescription_detail as pd
	JOIN medication AS m ON pd.MedicationID = m.MedicationID
GROUP BY pd.PrescriptionID
ORDER BY pd.PrescriptionID) ;
SELECT
    P.PatientID,
    P.FirstName,
    P.LastName,
    ROUND(DATEDIFF(CURDATE(), P.DateOfBirth) / 365.25, 1) AS Age,
    P.Gender,
    CASE
        WHEN P.Address LIKE '%Street%' THEN 'Urban'
        WHEN P.Address LIKE '%Village%' THEN 'Rural'
        ELSE 'Other'
    END AS Region,
    Mr.Diagnosis AS ConditionDiagnosed,
    Mr.TreatmentPlan AS TreatmentProvided,
    pm.precribed_medication AS PrescribedMedications,
    CASE 
        WHEN DATEDIFF(Mr.UpdatedAt, Mr.CreatedAt) <= 30 THEN 'Success'
        WHEN DATEDIFF(Mr.UpdatedAt, Mr.CreatedAt) > 30 THEN 'Failure'
        ELSE 'Unknown'
    END AS TreatmentOutcome,
    Mr.CreatedAt AS TreatmentStartDate,
    Mr.UpdatedAt AS TreatmentEndDate,
    DATEDIFF(Mr.UpdatedAt, Mr.CreatedAt) AS TreatmentDurationDays
FROM 
    Patients AS P
JOIN 
    medical_records AS Mr ON P.PatientID = Mr.PatientID
LEFT JOIN 
    prescription AS Pr ON Mr.PrescriptionID = Pr.PrescriptionID
JOIN
	prescribe_med AS pm ON pm.PrescriptionID = pr.PrescriptionID
WHERE 
    Mr.CreatedAt >= '2023-01-01' 
ORDER BY 
    Age, Gender, TreatmentOutcome;
    
    
    
/*--------- Query 2: (POINT 2) Analysis of Hospital Inventories and 
			Demand Based on Appointments and Economic Activity  ------------ */
    
SELECT 
    DATE_FORMAT(Ap.AppointmentDate, '%Y-%m') AS Month,
    Dr.DepartmentID,
    COUNT(Ap.AppointmentID) AS NumberOfAppointments,
    SUM(B.TotalAmount) AS TotalRevenueGenerated,
    i.InventoryID,
    i.Name AS InventoryName,
    i.Quantity AS CurrentInventory,
    i.ResotckAlertLevel,
    CASE 
        WHEN i.Quantity <= i.ResotckAlertLevel THEN 'Restock Needed'
        ELSE 'Sufficient Stock'
    END AS StockStatus
FROM 
    appointments AS Ap
JOIN 
    doctors AS Dr ON Ap.DoctorID = Dr.DoctorID
LEFT JOIN 
    Inventory AS i ON Dr.DepartmentID = i.DepartmentID
LEFT JOIN 
    billings AS B ON Ap.PatientID = B.PatientID
WHERE 
    Ap.AppointmentDate >= '2023-01-01'
GROUP BY 
    Month, Dr.DepartmentID, i.InventoryID
ORDER BY 
    Month, Dr.DepartmentID;
    
    
    
 /*--------- Query 3: (POINT 3) Disease Trends and Patient Condition Analysis Across Departments (2023-2024) ------------ */
 
 
 SELECT 
    CASE 
        WHEN YEAR(CURDATE()) - YEAR(P.DateOfBirth) < 18 THEN '0-17'
        WHEN YEAR(CURDATE()) - YEAR(P.DateOfBirth) BETWEEN 18 AND 35 THEN '18-35'
        WHEN YEAR(CURDATE()) - YEAR(P.DateOfBirth) BETWEEN 36 AND 60 THEN '36-60'
        ELSE '60+' 
    END AS AgeGroup,
    P.Gender,
    TRIM(SUBSTRING_INDEX(Address, ',', -1)) AS Region,
    DATE_FORMAT(Mr.VisitDate, '%Y-%m') AS VisitMonth,
    COALESCE(Dept.Name, 'Unknown Department') AS DepartmentName,
    COALESCE(Mr.Diagnosis, 'Unknown Diagnosis') AS ConditionDiagnosed,
    CASE 
        WHEN Mr.Diagnosis LIKE '%diabetes%' OR Mr.Diagnosis LIKE '%hypertension%' THEN 'Chronic'
        WHEN Mr.Diagnosis LIKE '%infection%' OR Mr.Diagnosis LIKE '%acute%' THEN 'Acute'
        ELSE 'Unspecified'
    END AS ConditionStatus,
    AVG(YEAR(CURDATE()) - YEAR(P.DateOfBirth)) AS AverageAge
FROM 
    Patients AS P
INNER JOIN 
    medical_records AS Mr ON P.PatientID = Mr.PatientID
LEFT JOIN 
    Doctors AS Dr ON Mr.DoctorID = Dr.DoctorID
LEFT JOIN 
    Departments AS Dept ON Dr.DepartmentID = Dept.DepartmentID
WHERE 
    Mr.VisitDate BETWEEN '2023-01-01' AND '2024-12-31'
GROUP BY 
    AgeGroup, Gender, Region, VisitMonth, DepartmentName, ConditionDiagnosed, ConditionStatus
ORDER BY 
    AgeGroup, Region, VisitMonth, DepartmentName;
    
    
    
/*--------- Query 4: (POINT 4) Analysis of Medication Effectiveness Based on Patient Data and Treatment Duration  ------------ */

SELECT
    P.PatientID,
    P.FirstName,
    P.LastName,
    ROUND(DATEDIFF(CURDATE(), P.DateOfBirth) / 365.25, 1) AS Age,
    P.Gender,
    Mr.Diagnosis AS ConditionDiagnosed,
    Mr.TreatmentPlan AS TreatmentProvided,
    pm.precribed_medication AS PrescribedMedications,
    CASE 
        WHEN DATEDIFF(Mr.UpdatedAt, Mr.CreatedAt) <= 15 THEN 'High Effectiveness'
        WHEN DATEDIFF(Mr.UpdatedAt, Mr.CreatedAt) BETWEEN 16 AND 30 THEN 'Moderate Effectiveness'
        ELSE 'Low Effectiveness'
    END AS EffectivenessRating,
    Mr.CreatedAt AS TreatmentStartDate,
    Mr.UpdatedAt AS TreatmentEndDate,
    DATEDIFF(Mr.UpdatedAt, Mr.CreatedAt) AS TreatmentDurationDays
FROM 
    Patients AS P
JOIN 
    medical_records AS Mr ON P.PatientID = Mr.PatientID
LEFT JOIN 
    prescribe_med AS pm ON Mr.PrescriptionID = pm.PrescriptionID
WHERE 
    Mr.CreatedAt >= '2023-01-01' AND pm.precribed_medication IS NOT NULL
ORDER BY 
    EffectivenessRating DESC, Age, Gender;

/*--------- Q5: Insurance Claim Prediction ------------*/
-- Q5: Query with CTE
WITH Patient_mr_info1 AS(
SELECT 
	p.PatientID,
    ROUND(DATEDIFF(CURDATE(), p.DateOfBirth) / 365.25, 1) AS Age,
    GROUP_CONCAT(mr.Diagnosis SEPARATOR ', ') AS ConditionDiagnosed
FROM healthcaresystem.patients AS p
	JOIN healthcaresystem.medical_records AS mr ON p.PatientID = mr.PatientID
GROUP BY p.PatientID)
SELECT
	b.PatientID,
    ptmr.Age,
    ptmr.ConditionDiagnosed,
    ins.InsuranceID,
    ins.PolicyNumber,
    ins.Provider,
    ins.ClaimAmount,
    b.BillingID,
    b.TotalAmount AS BillAmount,
    ins.ClaimStatus
FROM healthcaresystem.billings AS b
	JOIN healthcaresystem.insurance AS ins ON b.InsuranceID = ins.InsuranceID
    JOIN Patient_mr_info1 AS ptmr ON b.PatientID = ptmr.PatientID
ORDER BY b.PatientID;


/*---------- Q6: Staffing Scheduling Optimization(only nurses are considered here) --------------*/
/*------ Get number of Appointment per day for department */
CREATE  VIEW department_load AS(
	SELECT
		dept.DepartmentID,
		appt.AppointmentDate,
		COUNT(appt.AppointmentID) AS number_of_appointment
	FROM appointments AS appt
		JOIN doctors AS doc USING(DoctorID)
		JOIN departments AS dept ON doc.DepartmentID = dept.DepartmentID
	WHERE NOT appt.Status = 'Cancelled' 
	GROUP BY dept.DepartmentID,appt.AppointmentDate
	ORDER BY dept.DepartmentID,appt.AppointmentDate);
/*------------ compare with staff load ---------------*/
WITH staff_avail AS(
	SELECT
		DepartmentID,
		COUNT(StaffID) AS number_of_nurses
	FROM staffs
    WHERE Role = 'nurse'
    GROUP BY DepartmentID
)
SELECT
	dl.DepartmentID,
    dl.AppointmentDate,
    dl.number_of_appointment,
    s_av.number_of_nurses
FROM staff_avail AS s_av
	JOIN department_load AS dl ON dl.DepartmentID = s_av.DepartmentID;
    
/*--------------- Q7: Cancelled Appointments ------------------*/
WITH patient_postal AS(
	SELECT
		PatientID,
        TRIM(SUBSTRING_INDEX(Address, ',', -1)) AS Region
    FROM patients
)
SELECT
	appt.PatientID,
    COUNT(AppointmentID) AS no_of_missed_appointment,
    pp.Region
FROM appointments AS appt
	JOIN patient_postal AS pp ON pp.PatientID = appt.PatientID
WHERE appt.Status = 'Cancelled'
GROUP BY appt.PatientID;

/*--------------- Q8: Financial Analysis and Cost Prediction  -----------------------*/
/*--------- Treatment Cost  and Revenue Predicition --------*/
WITH PatientChornicCond AS( 
	SELECT
		mr.PatientID,
		MAX(DATEDIFF(mr.UpdatedAt, mr.CreatedAt)) AS Treatment_duration,
		CASE 
			-- considered as chronic condition if the treatment period is more than 6 months
			WHEN MAX(DATEDIFF(mr.UpdatedAt, mr.CreatedAt)) >  ROUND(365/2,0) THEN 'Yes' 
			ELSE 'No'
		END AS ChronicConditions
	FROM medical_records AS mr
	GROUP BY mr.PatientID
	ORDER BY mr.PatientID)
SELECT DISTINCT
    i.PatientID,
    pc.ChronicConditions,
    i.InsuranceID,
    i.ClaimStatus,
    i.ClaimAmount,
    b.TotalAmount,
    b.PaymentStatus,
    -- Calculate Predicted Treatment Cost: Increase cost if chronic conditions exist
    CASE
        WHEN pc.ChronicConditions = 'Yes' THEN i.ClaimAmount * 1.2  -- 20% higher cost for chronic conditions
        ELSE i.ClaimAmount
    END AS PredictedTreatmentCost,
    -- Revenue Calculation
    CASE
        -- For approved claims: Total revenue includes ClaimAmount + patient payment (if Paid)
        WHEN i.ClaimStatus = 'Approved' AND b.PaymentStatus = 'Paid' THEN i.ClaimAmount + (b.TotalAmount - i.ClaimAmount)
        WHEN i.ClaimStatus = 'Approved' AND b.PaymentStatus = 'Pending' THEN i.ClaimAmount  -- Insurance revenue only

        -- For pending claims: Assume 80% of ClaimAmount + patient payment (if Paid)
        WHEN i.ClaimStatus = 'Pending' AND b.PaymentStatus = 'Paid' THEN (i.ClaimAmount * 0.8) + (b.TotalAmount - i.ClaimAmount)
        WHEN i.ClaimStatus = 'Pending' AND b.PaymentStatus = 'Pending' THEN i.ClaimAmount * 0.8  -- Expected insurance revenue only

        -- For rejected claims: Total revenue comes only from patient payment (if Paid)
        WHEN i.ClaimStatus = 'Rejected' AND b.PaymentStatus = 'Paid' THEN b.TotalAmount
        WHEN i.ClaimStatus = 'Rejected' AND b.PaymentStatus = 'Pending' THEN 0  -- No revenue for unpaid rejected claims

        ELSE 0  -- Default case
    END AS PredictedRevenue
FROM 
    insurance i
    JOIN PatientChornicCond AS pc ON i.PatientID = pc.PatientID
	JOIN billings b ON i.PatientID = b.PatientID
WHERE 
    i.ClaimAmount IS NOT NULL;