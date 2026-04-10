
-- INSERT DATA INTO MEMBERSHIP TYPES

INSERT INTO MembershipTypes (name, duration_month, price, access_level)
VALUES 
('Basic', 1, 50.00, 'Standard'),
('Premium', 3, 120.00, 'Extended'),
('VIP', 6, 250.00, 'Full');


-- INSERT DATA INTO MEMBERS

INSERT INTO Members 
(first_name, last_name, date_of_birth, gender, phone, registration_date, membership_id, status)
VALUES
('Ali', 'Khan', '2000-05-10', 'M', '87001234567', '2026-02-01', 1, 'A'),
('Aruzhan', 'Sadykova', '1998-08-22', 'F', '87007654321', '2026-03-01', 2, 'A'),
('Dana', 'Nurzhan', '1995-12-15', 'F', '87005554433', '2026-02-15', 3, 'I');


-- INSERT DATA INTO FACILITIES

INSERT INTO Facilities (facility_name, capacity, location)
VALUES
('Main Gym', 50, '1st Floor'),
('Yoga Room', 20, '2nd Floor'),
('Swimming Pool', 30, 'Basement');


-- INSERT DATA INTO INSTRUCTORS

INSERT INTO Instructors 
(first_name, last_name, phone, email, hire_date, specialization)
VALUES
('John', 'Smith', '87001112233', 'john.smith@gmail.com', '2026-02-01', 'Fitness'),
('Anna', 'Lee', '87002223344', 'anna.lee@gmail.com', '2026-02-10', 'Yoga');


-- INSERT DATA INTO CLASSES

INSERT INTO Classes (class_name, description, max_capacity)
VALUES
('Yoga Class', 'Relaxing yoga session', 20),
('HIIT Training', 'High intensity workout', 25);

-- INSERT DATA INTO SCHEDULE

INSERT INTO Schedule 
(class_id, instructor_id, start_time, end_time, facility_id)
VALUES
(1, 2, '2026-04-10 10:00', '2026-04-10 11:00', 2),
(2, 1, '2026-04-10 12:00', '2026-04-10 13:00', 1);

-- INSERT DATA INTO INVOICE

INSERT INTO Invoice (member_id, invoice_date, total_amount, status)
VALUES
(1, '2026-02-01', 50.00, 'P'),
(2, '2026-03-01', 120.00, 'U');


-- INSERT DATA INTO PAYMENTS

INSERT INTO Payments 
(invoice_id, payment_date, amount, payment_method)
VALUES
(1, '2026-02-02', 50.00, 'C'),
(2, '2026-03-05', 60.00, 'T');

-- INSERT DATA INTO EQUIPMENT

INSERT INTO Equipment 
(name, purchase_date, condition_status, facility_id)
VALUES
('Treadmill', '2025-01-01', 'G', 1),
('Yoga Mat', '2025-06-01', 'G', 2);

-- INSERT DATA INTO ATTENDANCE

INSERT INTO Attendance 
(member_id, schedule_id, check_in_time, status)
VALUES
(1, 1, '2026-04-10 09:55', 'P'),
(2, 2, '2026-04-10 11:55', 'R');

-- INSERT DATA INTO CERTIFICATIONS

INSERT INTO Certifications 
(certification_name, issuing_organization, valid_years)
VALUES
('Fitness Trainer', 'Global Fitness Org', 3),
('Yoga Instructor', 'Yoga Alliance', 2);

-- INSERT DATA INTO INSTRUCTOR_CERTIFICATION

INSERT INTO Instructor_Certification 
(certification_id, instructor_id, issue_date)
VALUES
(1, 1, '2026-02-01'),
(2, 2, '2026-02-10');
