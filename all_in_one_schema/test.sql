WITH prescribe_medi AS(
SELECT
	pd.PrescriptionID,
    # pd.MedicationID,
    GROUP_CONCAT( m.Name ORDER BY m.Name SEPARATOR ',') AS precribed_medication
FROM prescription_detail as pd
	JOIN medication AS m ON pd.MedicationID = m.MedicationID
GROUP BY pd.PrescriptionID
ORDER BY pd.PrescriptionID) 
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
	prescribe_medi AS pm ON pm.PrescriptionID = pr.PrescriptionID
WHERE 
    Mr.CreatedAt >= '2023-01-01' 
ORDER BY 
    Age, Gender, TreatmentOutcome;

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
    prescribe_medi AS pm ON Mr.PrescriptionID = pm.PrescriptionID
WHERE 
    Mr.CreatedAt >= '2023-01-01' AND pm.precribed_medication IS NOT NULL
ORDER BY 
    EffectivenessRating DESC, Age, Gender;