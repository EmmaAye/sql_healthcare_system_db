CREATE DATABASE healthcaresystem;
USE	healthcaresystem;

/*--------- Table 1: Patient Table ------------ */
CREATE TABLE patients(
	PatientID INT PRIMARY KEY,
    FirstName VARCHAR(32) NOT NULL,
    LastName VARCHAR(32) NOT NULL,
    DateOfBirth DATE NOT NULL,
    GENDER	ENUM('Male','Female','Other') NOT NULL,
    ContactNumber VARCHAR(64) NOT NULL,
    email	VARCHAR(64),
	Address VARCHAR(128),
	EmergencyContact VARCHAR(64) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT NOW(),
    UpdatedAt DATETIME NOT NULL DEFAULT NOW()
);

# DROP TABLE patitents; 
# ALTER TABLE patitents
# 	MODIFY COLUMN EmergencyContact VARCHAR(50) NOT NULL;
/*--------- Table 2: Doctor Table ------------ */    
CREATE TABLE doctors(
	DoctorID INT PRIMARY KEY,
    FirstName VARCHAR(32) NOT NULL,
    LastName VARCHAR(32) NOT NULL,
    Specialization VARCHAR(128) NOT NULL,
    ContactNumber VARCHAR(64) NOT NULL,
    email VARCHAR(64) NOT NULL,
    DepartmentID INT NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT NOW(),
    UpdatedAt DATETIME NOT NULL DEFAULT NOW()
);

/*--------- Table 3: Doctor Availability Table ------------ */  
CREATE TABLE doctor_availability(
	AvailibilityID INT PRIMARY KEY,
    DoctorID INT NOT NULL,
    DayOfWeek ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'),
    StartTme TIME,
    EndTime TIME,
    FOREIGN KEY(DoctorID) REFERENCES doctors(DoctorID) ON DELETE CASCADE
);

# DROP TABLE doctor_availability;

/*--------- Table 4: Appointment Table ------------ */  
CREATE TABLE appointments(
	AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
	PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL,
    ReasonForVisit TEXT NOT NULL,
    Status ENUM('Scheduled', 'Completed', 'Cancelled') NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT NOW(),
    UpdatedAt DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY(DoctorID) REFERENCES doctors(DoctorID),
    FOREIGN KEY(PatientID) REFERENCES patients(PatientID)
);

/*--------- Table 5: Medical Record Table ------------ */ 
CREATE TABLE medical_records(
	RecordID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    VisitDate DATE NOT NULL,
    PrescriptionID INT,
    Diagnosis TEXT NOT NULL,
    TreatmentPlan TEXT NOT NULL,
    Notes TEXT,
    CreatedAt DATETIME NOT NULL DEFAULT NOW(),
    UpdatedAt DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY(DoctorID) REFERENCES doctors(DoctorID),
    FOREIGN KEY(PatientID) REFERENCES patients(PatientID)
);

/*--------- Table 6: Medication Table ------------ */ 
       
CREATE TABLE medication(
	MedicationID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(32) NOT NULL,
    FormID INT NOT NULL,
    SideEffects TEXT
);

/*--------- Table 6.1: Medication FORM Table ------------ */ 
CREATE TABLE MedicationForms (
    FormID INT AUTO_INCREMENT PRIMARY KEY,
    FormName VARCHAR(32) NOT NULL UNIQUE
);
INSERT INTO MedicationForms (FormName)
VALUES ('Tablet'), ('Capsule'), ('Liquid'), ('Syrup'), ('Injection'), 
       ('Topical'), ('Suppository'), ('Inhaler'), ('Drops'), ('Patch'), 
       ('Powder'), ('Lozenge'), ('Granule'), ('Spray');

/* Add medication form as foreing key to medication table */
ALTER TABLE medication ADD FOREIGN KEY(FormID) REFERENCES  MedicationForms(FormID);

/*--------- Table 7: Prescription Table ------------ */
CREATE TABLE prescription(
	PrescriptionID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    Note TEXT,
    FOREIGN KEY(DoctorID) REFERENCES doctors(DoctorID),
    FOREIGN KEY(PatientID) REFERENCES patients(PatientID)
);

/*--------- Table 8: Prescription Detail Table ------------ */
CREATE TABLE prescription_detail(
	ID INT PRIMARY KEY,
    MedicationID INT NOT NULL,
    PrescriptionID INT NOT NULL,
    Dosage VARCHAR(32) NOT NULL,
    Instructions TEXT,
    FOREIGN KEY(MedicationID) REFERENCES medication(MedicationID),
    FOREIGN KEY(PrescriptionID) REFERENCES prescription(PrescriptionID)
);

/*--------- Table 9: Department Table ------------ */ 

CREATE TABLE departments(
	DepartmentID INT PRIMARY KEY,
    Name VARCHAR(32) NOT NULL,
    Location VARCHAR(128) NOT NULL,
	CreatedAt DATETIME NOT NULL DEFAULT NOW(),
    UpdatedAt DATETIME NOT NULL DEFAULT NOW()
);

/*--------- Table 10: Staff Table ------------ */ 

CREATE TABLE staffs(
	StaffID INT PRIMARY KEY,
    FirstName VARCHAR(32) NOT NULL,
    LastName VARCHAR(32) NOT NULL,
    Role VARCHAR(64) NOT NULL,
    ContactNumber VARCHAR(64) NOT NULL,
    DepartmentID INT NOT NULL,
	CreatedAt DATETIME NOT NULL DEFAULT NOW(),
    UpdatedAt DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY(DepartmentID) REFERENCES  departments(DepartmentID)
);

/*--------- Table 11: Billing Table ------------ */ 

CREATE TABLE billings(
	BillingID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    BillingDate DATE NOT NULL,
    PaymentStatus ENUM('Paid', 'Pending') NOT NULL,
	CreatedAt DATETIME NOT NULL DEFAULT NOW(),
    UpdatedAt DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY(PatientID) REFERENCES  patients(PatientID)
);

/*--------- Table 12: Inventory Table ------------ */ 

CREATE TABLE inventory(
	InventoryID INT PRIMARY KEY,
    Name VARCHAR(128) NOT NULL,
    Quantity INT NOT NULL DEFAULT 0,
    ResotckAlertLevel INT NOT NULL DEFAULT 5,
    DepartmentID INT NOT NULL,
	CreatedAt DATETIME NOT NULL DEFAULT NOW(),
    UpdatedAt DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY(DepartmentID) REFERENCES  departments(DepartmentID)
);

/*--------- Table 13: Insurance Table ------------ */

CREATE TABLE insurance(
	InsuranceID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    PolicyNumber VARCHAR(64) NOT NULL,
    Provider VARCHAR(64) NOT NULL,
    ClaimAmount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ClaimStatus ENUM('Approved','Pending','Rejected'),
	CreatedAt DATETIME NOT NULL DEFAULT NOW(),
    UpdatedAt DATETIME NOT NULL DEFAULT NOW(),
    FOREIGN KEY(PatientID) REFERENCES  patients(PatientID)
);

/*------- Add relationship Constraints -------------*/
ALTER TABLE doctors ADD  FOREIGN KEY(DepartmentID) REFERENCES departments(DepartmentID) ON DELETE CASCADE;
ALTER TABLE billings ADD InsuranceID INT;
ALTER TABLE billings ADD FOREIGN KEY(InsuranceID) REFERENCES insurance(InsuranceID) ON DELETE CASCADE;
ALTER TABLE insurance DROP CONSTRAINT insurance_ibfk_1;
ALTER TABLE insurance DROP COLUMN PatientID;
ALTER TABLE insurance MODIFY COLUMN ClaimAmount DECIMAL(10,2) NOT NULL CHECK (ClaimAmount >= 0);
ALTER TABLE medical_records DROP CONSTRAINT medical_records_ibfk_2;
ALTER TABLE medical_records ADD FOREIGN KEY(PatientID) REFERENCES patients(PatientID) ON DELETE CASCADE;
ALTER TABLE medical_records ADD FOREIGN KEY(PrescriptionID) REFERENCES prescription(PrescriptionID) ON DELETE CASCADE;