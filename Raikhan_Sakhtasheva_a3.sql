DROP USER IF EXISTS db_admin_user;
DROP USER IF EXISTS db_reader_user;
DROP ROLE IF EXISTS fitness_center_admin;
DROP ROLE IF EXISTS fitness_center_readonly;

DROP SCHEMA IF EXISTS fitness_center CASCADE;
CREATE SCHEMA fitness_center;
SET search_path TO fitness_center;


CREATE TABLE MembershipTypes (
    membershipType_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    duration_month INT NOT NULL CHECK (duration_month > 0),
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    access_level VARCHAR(50) DEFAULT 'Standard'
);

CREATE TABLE Members (
    member_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL CHECK (date_of_birth < DATE '2026-01-01'),
    gender CHAR(1) DEFAULT 'O' CHECK (gender IN ('M','F','O')),
    phone VARCHAR(20) UNIQUE,
    registration_date DATE DEFAULT CURRENT_DATE CHECK (registration_date > DATE '2026-01-01'),
    membership_id INT NOT NULL,
    status CHAR(1) NOT NULL CHECK (status IN ('A','I')),
    FOREIGN KEY (membership_id) REFERENCES MembershipTypes(membershipType_id)
);

CREATE TABLE Invoice (
    invoice_id SERIAL PRIMARY KEY,
    member_id INT NOT NULL,
    invoice_date DATE DEFAULT CURRENT_DATE CHECK (invoice_date > DATE '2026-01-01'),
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),
    total_with_tax NUMERIC(10,2) GENERATED ALWAYS AS (total_amount * 1.12) STORED,
    status CHAR(1) DEFAULT 'U' CHECK (status IN ('P','U')),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_date DATE DEFAULT CURRENT_DATE CHECK (payment_date > DATE '2026-01-01'),
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    payment_method CHAR(1) NOT NULL CHECK (payment_method IN ('C','K','T')),
    amount_with_fee NUMERIC(10,2) GENERATED ALWAYS AS (amount * 1.02) STORED,
    FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id)
);

CREATE TABLE Facilities (
    facility_id SERIAL PRIMARY KEY,
    facility_name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    location VARCHAR(100)
);

CREATE TABLE Equipment (
    equipment_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    purchase_date DATE,
    condition_status CHAR(1) DEFAULT 'G' CHECK (condition_status IN ('G','B')),
    facility_id INT NOT NULL,
    FOREIGN KEY (facility_id) REFERENCES Facilities(facility_id)
);

CREATE TABLE Instructors (
    instructor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) NOT NULL UNIQUE,
    hire_date DATE DEFAULT CURRENT_DATE CHECK (hire_date > DATE '2026-01-01'),
    specialization VARCHAR(100) NOT NULL
);

CREATE TABLE Classes (
    class_id SERIAL PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL,
    description TEXT,
    max_capacity INT NOT NULL CHECK (max_capacity > 0)
);

CREATE TABLE Schedule (
    schedule_id SERIAL PRIMARY KEY,
    class_id INT NOT NULL,
    instructor_id INT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    facility_id INT NOT NULL,
    CHECK (end_time > start_time),
    FOREIGN KEY (class_id) REFERENCES Classes(class_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id),
    FOREIGN KEY (facility_id) REFERENCES Facilities(facility_id)
);

CREATE TABLE Attendance (
    attendance_id SERIAL PRIMARY KEY,
    member_id INT NOT NULL,
    schedule_id INT NOT NULL,
    check_in_time TIMESTAMP,
    status CHAR(1) DEFAULT 'R' CHECK (status IN ('R','P')),
    UNIQUE (member_id, schedule_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (schedule_id) REFERENCES Schedule(schedule_id)
);

CREATE TABLE Certifications (
    certification_id SERIAL PRIMARY KEY,
    certification_name VARCHAR(100) NOT NULL UNIQUE,
    issuing_organization VARCHAR(100) NOT NULL,
    valid_years INT NOT NULL CHECK (valid_years > 0)
);

CREATE TABLE Instructor_Certification (
    certification_id INT NOT NULL,
    instructor_id INT NOT NULL,
    issue_date DATE DEFAULT CURRENT_DATE CHECK (issue_date > DATE '2026-01-01'),
    PRIMARY KEY (certification_id, instructor_id),
    FOREIGN KEY (certification_id) REFERENCES Certifications(certification_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);


CREATE ROLE fitness_center_admin;
CREATE ROLE fitness_center_readonly;

GRANT USAGE ON SCHEMA fitness_center TO fitness_center_admin;
GRANT USAGE ON SCHEMA fitness_center TO fitness_center_readonly;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA fitness_center TO fitness_center_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA fitness_center TO fitness_center_readonly;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA fitness_center TO fitness_center_admin;

CREATE USER db_admin_user WITH PASSWORD 'SecureAdminPass2026!';
CREATE USER db_reader_user WITH PASSWORD 'SecureReadPass2026!';

GRANT fitness_center_admin TO db_admin_user;
GRANT fitness_center_readonly TO db_reader_user;

REVOKE UPDATE, DELETE, INSERT ON ALL TABLES IN SCHEMA fitness_center FROM fitness_center_readonly;

SET ROLE db_admin_user;
SELECT current_user;                           

SELECT count(*) FROM fitness_center.Members;   

RESET ROLE;
INSERT INTO fitness_center.MembershipTypes (name, duration_month, price, access_level) 
VALUES ('Verification Base', 12, 100.00, 'Standard');

SET ROLE db_admin_user;
INSERT INTO fitness_center.Members (first_name, last_name, date_of_birth, gender, phone, registration_date, membership_id, status)
VALUES ('DCL_Test', 'User', '1999-01-01', 'O', '87779991122', '2026-02-01', 
       (SELECT membershipType_id FROM fitness_center.MembershipTypes WHERE name = 'Verification Base'), 'A') 
RETURNING *;                                   
UPDATE fitness_center.Members SET status = 'A' WHERE phone = '87779991122';

DELETE FROM fitness_center.Members WHERE member_id = (SELECT max(member_id) FROM fitness_center.Members); -- should succeed
RESET ROLE;

SET ROLE db_reader_user;
SELECT current_user;                          
SELECT count(*) FROM fitness_center.Members;   

BEGIN;
INSERT INTO fitness_center.Members (first_name, last_name, date_of_birth, membership_id, status) VALUES ('Fail', 'User', '1990-01-01', 1, 'A');

ROLLBACK;

BEGIN;
UPDATE fitness_center.Members SET status = 'I';

ROLLBACK;

BEGIN;
DELETE FROM fitness_center.Members WHERE member_id = 1;

ROLLBACK;

RESET ROLE;

TRUNCATE TABLE fitness_center.Instructor_Certification CASCADE;
TRUNCATE TABLE fitness_center.Attendance CASCADE;
TRUNCATE TABLE fitness_center.Schedule CASCADE;
TRUNCATE TABLE fitness_center.Equipment CASCADE;
TRUNCATE TABLE fitness_center.Payments CASCADE;
TRUNCATE TABLE fitness_center.Invoice CASCADE;
TRUNCATE TABLE fitness_center.Members CASCADE;
TRUNCATE TABLE fitness_center.Classes CASCADE;
TRUNCATE TABLE fitness_center.Instructors CASCADE;
TRUNCATE TABLE fitness_center.Facilities CASCADE;
TRUNCATE TABLE fitness_center.Certifications CASCADE;
TRUNCATE TABLE fitness_center.MembershipTypes CASCADE;

-- 6. Insert 5+ valid, production-grade rows per table without hardcoded IDs

-- Table 1: MembershipTypes
INSERT INTO fitness_center.MembershipTypes (name, duration_month, price, access_level) VALUES
('Standard Monthly', 1, 45.00, 'Standard'),
('Quarterly Fitness', 3, 120.00, 'Standard'),
('Premium Annual', 12, 400.00, 'Extended'),
('VIP Executive All-Access', 6, 300.00, 'Full'),
('Weekend Warrior Pass', 1, 25.00, 'Restricted');

-- Table 2: Members
INSERT INTO fitness_center.Members (first_name, last_name, date_of_birth, gender, phone, registration_date, membership_id, status) VALUES
('Arman', 'Ibragimov', '1994-04-12', 'M', '+77015551122', '2026-01-15', (SELECT membershipType_id FROM fitness_center.MembershipTypes WHERE name = 'Standard Monthly'), 'A'),
('Madina', 'Asanova', '1997-11-23', 'F', '+77024443311', '2026-01-20', (SELECT membershipType_id FROM fitness_center.MembershipTypes WHERE name = 'Premium Annual'), 'A'),
('Zangar', 'Bolatov', '1989-06-05', 'M', '+77051119988', '2026-02-01', (SELECT membershipType_id FROM fitness_center.MembershipTypes WHERE name = 'VIP Executive All-Access'), 'A'),
('Aliya', 'Serikova', '2001-09-14', 'F', '+77073332255', '2026-02-10', (SELECT membershipType_id FROM fitness_center.MembershipTypes WHERE name = 'Quarterly Fitness'), 'I'),
('Daniyar', 'Kusainov', '1992-02-28', 'M', '+77478887766', '2026-03-01', (SELECT membershipType_id FROM fitness_center.MembershipTypes WHERE name = 'Weekend Warrior Pass'), 'A');

-- Table 3: Invoice
INSERT INTO fitness_center.Invoice (member_id, invoice_date, total_amount, status) VALUES
((SELECT member_id FROM fitness_center.Members WHERE phone = '+77015551122'), '2026-01-15', 45.00, 'P'),
((SELECT member_id FROM fitness_center.Members WHERE phone = '+77024443311'), '2026-01-20', 400.00, 'P'),
((SELECT member_id FROM fitness_center.Members WHERE phone = '+77051119988'), '2026-02-01', 300.00, 'U'),
((SELECT member_id FROM fitness_center.Members WHERE phone = '+77073332255'), '2026-02-10', 120.00, 'U'),
((SELECT member_id FROM fitness_center.Members WHERE phone = '+77478887766'), '2026-03-01', 25.00, 'P');

-- Table 4: Payments
INSERT INTO fitness_center.Payments (invoice_id, payment_date, amount, payment_method) VALUES
((SELECT invoice_id FROM fitness_center.Invoice WHERE member_id = (SELECT member_id FROM fitness_center.Members WHERE phone = '+77015551122')), '2026-01-15', 45.00, 'K'),
((SELECT invoice_id FROM fitness_center.Invoice WHERE member_id = (SELECT member_id FROM fitness_center.Members WHERE phone = '+77024443311')), '2026-01-20', 400.00, 'T'),
((SELECT invoice_id FROM fitness_center.Invoice WHERE member_id = (SELECT member_id FROM fitness_center.Members WHERE phone = '+77478887766')), '2026-03-01', 25.00, 'C'),
-- Partial payments or post-dated tracking records to represent a real state structure
((SELECT invoice_id FROM fitness_center.Invoice WHERE member_id = (SELECT member_id FROM fitness_center.Members WHERE phone = '+77051119988')), '2026-02-15', 150.00, 'K'),
((SELECT invoice_id FROM fitness_center.Invoice WHERE member_id = (SELECT member_id FROM fitness_center.Members WHERE phone = '+77073332255')), '2026-02-28', 60.00, 'T');

-- Table 5: Facilities
INSERT INTO fitness_center.Facilities (facility_name, capacity, location) VALUES
('Cardio Zone Alpha', 40, '1st Floor - West Wing'),
('Strength Gym Beta', 60, '1st Floor - East Wing'),
('Zen Yoga Studio', 25, '2nd Floor - Suite 201'),
('Olympic Swimming Facility', 35, 'Ground Level Annex'),
('Crossfit Combat Box', 30, 'Basement Compound');

-- Table 6: Equipment
INSERT INTO fitness_center.Equipment (name, purchase_date, condition_status, facility_id) VALUES
('Matrix Commercial Treadmill T70', '2025-03-12', 'G', (SELECT facility_id FROM fitness_center.Facilities WHERE facility_name = 'Cardio Zone Alpha')),
('Concept2 Rowing Ergometer Model D', '2025-05-20', 'G', (SELECT facility_id FROM fitness_center.Facilities WHERE facility_name = 'Cardio Zone Alpha')),
('Eleiko Olympic Weightlifting Barbell 20kg', '2024-11-02', 'G', (SELECT facility_id FROM fitness_center.Facilities WHERE facility_name = 'Strength Gym Beta')),
('Premium Eco Rubber Yoga Mat set', '2025-08-15', 'B', (SELECT facility_id FROM fitness_center.Facilities WHERE facility_name = 'Zen Yoga Studio')),
('Rogue Fitness Monster Power Rack', '2025-01-10', 'G', (SELECT facility_id FROM fitness_center.Facilities WHERE facility_name = 'Crossfit Combat Box'));

-- Table 7: Instructors
INSERT INTO fitness_center.Instructors (first_name, last_name, phone, email, hire_date, specialization) VALUES
('Dmitry', 'Volkov', '+77019998877', 'dmitry.volkov@fitness.kz', '2026-01-05', 'Bodybuilding & Powerlifting'),
('Elena', 'Petrova', '+77027776655', 'elena.petrova@fitness.kz', '2026-01-12', 'Vinyasa Flow Yoga'),
('Serik', 'Akhmetov', '+77054443322', 'serik.akhmetov@fitness.kz', '2026-01-18', 'High Intensity Interval Training'),
('Marina', 'Kuznetsova', '+77072221100', 'marina.kuznetsova@fitness.kz', '2026-02-01', 'Aqua Aerobics'),
('Bauyrzhan', 'Umarov', '+77475556677', 'bauyrzhan.umarov@fitness.kz', '2026-02-15', 'Crossfit Level 2 Coaching');

-- Table 8: Classes
INSERT INTO fitness_center.Classes (class_name, description, max_capacity) VALUES
('Sunrise Vinyasa Yoga', 'Energizing morning stretching and breath synchronization sessions.', 20),
('Hardcore Crossfit WOD', 'High-intensity functional conditioning workout of the day.', 25),
('Powerlifting Strength Foundations', 'Mastering structural kinematics of squat, bench press, and deadlift.', 15),
('Fat Loss HIIT Circuit', 'Rapid metabolic interval training optimized for calorie burning.', 30),
('Aqua Endurance Core', 'Low impact muscular cross-training within deep water environment.', 20);

-- Table 9: Schedule
INSERT INTO fitness_center.Schedule (class_id, instructor_id, start_time, end_time, facility_id) VALUES
((SELECT class_id FROM fitness_center.Classes WHERE class_name = 'Sunrise Vinyasa Yoga'), (SELECT instructor_id FROM fitness_center.Instructors WHERE email = 'elena.petrova@fitness.kz'), '2026-06-01 08:00:00', '2026-06-01 09:15:00', (SELECT facility_id FROM fitness_center.Facilities WHERE facility_name = 'Zen Yoga Studio')),
((SELECT class_id FROM fitness_center.Classes WHERE class_name = 'Hardcore Crossfit WOD'), (SELECT instructor_id FROM fitness_center.Instructors WHERE email = 'bauyrzhan.umarov@fitness.kz'), '2026-06-01 18:30:00', '2026-06-01 19:45:00', (SELECT facility_id FROM fitness_center.Facilities WHERE facility_name = 'Crossfit Combat Box')),
((SELECT class_id FROM fitness_center.Classes WHERE class_name = 'Powerlifting Strength Foundations'), (SELECT instructor_id FROM fitness_center.Instructors WHERE email = 'dmitry.volkov@fitness.kz'), '2026-06-02 17:00:00', '2026-06-02 18:30:00', (SELECT facility_id FROM fitness_center.Facilities WHERE facility_name = 'Strength Gym Beta')),
((SELECT class_id FROM fitness_center.Classes WHERE class_name = 'Fat Loss HIIT Circuit'), (SELECT instructor_id FROM fitness_center.Instructors WHERE email = 'serik.akhmetov@fitness.kz'), '2026-06-02 19:00:00', '2026-06-02 20:00:00', (SELECT facility_id FROM fitness_center.Facilities WHERE facility_name = 'Cardio Zone Alpha')),
((SELECT class_id FROM fitness_center.Classes WHERE class_name = 'Aqua Endurance Core'), (SELECT instructor_id FROM fitness_center.Instructors WHERE email = 'marina.kuznetsova@fitness.kz'), '2026-06-03 10:00:00', '2026-06-03 11:00:00', (SELECT facility_id FROM fitness_center.Facilities WHERE facility_name = 'Olympic Swimming Facility'));

-- Table 10: Attendance
INSERT INTO fitness_center.Attendance (member_id, schedule_id, check_in_time, status) VALUES
((SELECT member_id FROM fitness_center.Members WHERE phone = '+77015551122'), (SELECT schedule_id FROM fitness_center.Schedule WHERE start_time = '2026-06-01 08:00:00'), '2026-06-01 07:54:12', 'P'),
((SELECT member_id FROM fitness_center.Members WHERE phone = '+77024443311'), (SELECT schedule_id FROM fitness_center.Schedule WHERE start_time = '2026-06-01 18:30:00'), NULL, 'R'),
((SELECT member_id FROM fitness_center.Members WHERE phone = '+77051119988'), (SELECT schedule_id FROM fitness_center.Schedule WHERE start_time = '2026-06-02 17:00:00'), '2026-06-02 16:50:00', 'P'),
((SELECT member_id FROM fitness_center.Members WHERE phone = '+77478887766'), (SELECT schedule_id FROM fitness_center.Schedule WHERE start_time = '2026-06-01 08:00:00'), NULL, 'R'),
((SELECT member_id FROM fitness_center.Members WHERE phone = '+77015551122'), (SELECT schedule_id FROM fitness_center.Schedule WHERE start_time = '2026-06-02 19:00:00'), '2026-06-02 18:58:22', 'P');

-- Table 11: Certifications
INSERT INTO fitness_center.Certifications (certification_name, issuing_organization, valid_years) VALUES
('Certified Strength and Conditioning Specialist (CSCS)', 'NSCA USA', 3),
('Registered Yoga Teacher 200 Hours (RYT200)', 'Yoga Alliance', 2),
('Certified Crossfit Level 2 Trainer', 'CrossFit Inc.', 3),
('National Aquatic Elite Instructor License', 'World Aquatics Federation', 5),
('Advanced Performance Nutrition Specialist', 'NASM', 2);

-- Table 12: Instructor_Certification
INSERT INTO fitness_center.Instructor_Certification (certification_id, instructor_id, issue_date) VALUES
((SELECT certification_id FROM fitness_center.Certifications WHERE certification_name = 'Certified Strength and Conditioning Specialist (CSCS)'), (SELECT instructor_id FROM fitness_center.Instructors WHERE email = 'dmitry.volkov@fitness.kz'), '2026-01-10'),
((SELECT certification_id FROM fitness_center.Certifications WHERE certification_name = 'Registered Yoga Teacher 200 Hours (RYT200)'), (SELECT instructor_id FROM fitness_center.Instructors WHERE email = 'elena.petrova@fitness.kz'), '2026-01-15'),
((SELECT certification_id FROM fitness_center.Certifications WHERE certification_name = 'Certified Crossfit Level 2 Trainer'), (SELECT instructor_id FROM fitness_center.Instructors WHERE email = 'bauyrzhan.umarov@fitness.kz'), '2026-02-20'),
((SELECT certification_id FROM fitness_center.Certifications WHERE certification_name = 'National Aquatic Elite Instructor License'), (SELECT instructor_id FROM fitness_center.Instructors WHERE email = 'marina.kuznetsova@fitness.kz'), '2026-02-05'),
((SELECT certification_id FROM fitness_center.Certifications WHERE certification_name = 'Advanced Performance Nutrition Specialist'), (SELECT instructor_id FROM fitness_center.Instructors WHERE email = 'serik.akhmetov@fitness.kz'), '2026-01-25');

-- SELECT PREVIEW
SELECT count(*) FROM fitness_center.Members WHERE phone = '+77073332255';
-- Preview Row Count: 1

UPDATE fitness_center.Members 
SET status = 'A', phone = '+77073332200' 
WHERE phone = '+77073332255';

-- SELECT PREVIEW
SELECT count(*) FROM fitness_center.MembershipTypes WHERE duration_month = 1;
-- Preview Row Count: 2

UPDATE fitness_center.MembershipTypes 
SET price = price + 5.50 
WHERE duration_month = 1;

-- SELECT PREVIEW
SELECT count(*) 
FROM fitness_center.Equipment e
JOIN fitness_center.Facilities f ON e.facility_id = f.facility_id
WHERE f.facility_name = 'Zen Yoga Studio';
-- Preview Row Count: 1

UPDATE fitness_center.Equipment eq
SET condition_status = 'B'
FROM fitness_center.Facilities fa
WHERE eq.facility_id = fa.facility_id 
  AND fa.facility_name = 'Zen Yoga Studio';

BEGIN;

SELECT count(*) 
FROM fitness_center.Members 
WHERE status = 'I';
-- Preview Affected Target Count: 1

DELETE FROM fitness_center.Members 
WHERE status = 'I';

SELECT count(*) FROM fitness_center.Members WHERE status = 'I'; 
-- Result Row Count here is: 0

ROLLBACK;

