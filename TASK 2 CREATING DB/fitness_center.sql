-- RERUN SAFE: DROP + CREATE SCHEMA

DROP SCHEMA IF EXISTS fitness_center CASCADE;
CREATE SCHEMA fitness_center;
SET search_path TO fitness_center;

-- MEMBERSHIP TYPES

CREATE TABLE MembershipTypes (
    membershipType_id SERIAL PRIMARY KEY,
    
    name VARCHAR(50) NOT NULL UNIQUE, -- membership names must be unique
    
    duration_month INT NOT NULL 
        CHECK (duration_month > 0), -- cannot be negative or zero
    
    price NUMERIC(10,2) NOT NULL 
        CHECK (price >= 0), -- price cannot be negative
    
    access_level VARCHAR(50) DEFAULT 'Standard'
);

-- MEMBERS

CREATE TABLE Members (
    member_id SERIAL PRIMARY KEY,
    
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,

    date_of_birth DATE NOT NULL
        CHECK (date_of_birth < DATE '2026-01-01'), -- realistic DOB constraint

    gender CHAR(1) DEFAULT 'O'
        CHECK (gender IN ('M','F','O')), -- allowed values only

    phone VARCHAR(20) UNIQUE,

    registration_date DATE DEFAULT CURRENT_DATE
        CHECK (registration_date > DATE '2026-01-01'), -- required rule

    membership_id INT NOT NULL,

    status CHAR(1) NOT NULL
        CHECK (status IN ('A','I')), -- Active / Inactive

    FOREIGN KEY (membership_id)
        REFERENCES MembershipTypes(membershipType_id)
);

-- INVOICE

CREATE TABLE Invoice (
    invoice_id SERIAL PRIMARY KEY,
    
    member_id INT NOT NULL,

    invoice_date DATE DEFAULT CURRENT_DATE
        CHECK (invoice_date > DATE '2026-01-01'),

    total_amount NUMERIC(10,2) NOT NULL
        CHECK (total_amount >= 0),

    -- GENERATED COLUMN (required)
    total_with_tax NUMERIC(10,2)
        GENERATED ALWAYS AS (total_amount * 1.12) STORED,

    status CHAR(1) DEFAULT 'U'
        CHECK (status IN ('P','U')), -- Paid / Unpaid

    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

-- PAYMENTS

CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    
    invoice_id INT NOT NULL,

    payment_date DATE DEFAULT CURRENT_DATE
        CHECK (payment_date > DATE '2026-01-01'),

    amount NUMERIC(10,2) NOT NULL
        CHECK (amount >= 0), -- cannot be negative

    payment_method CHAR(1) NOT NULL
        CHECK (payment_method IN ('C','K','T')), -- Cash/Card/Transfer

    -- GENERATED COLUMN
    amount_with_fee NUMERIC(10,2)
        GENERATED ALWAYS AS (amount * 1.02) STORED,

    FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id)
);

-- FACILITIES

CREATE TABLE Facilities (
    facility_id SERIAL PRIMARY KEY,
    
    facility_name VARCHAR(100) NOT NULL,
    
    capacity INT NOT NULL 
        CHECK (capacity > 0), -- must be positive
    
    location VARCHAR(100)
);

-- EQUIPMENT

CREATE TABLE Equipment (
    equipment_id SERIAL PRIMARY KEY,
    
    name VARCHAR(100) NOT NULL,
    
    purchase_date DATE,

    condition_status CHAR(1) DEFAULT 'G'
        CHECK (condition_status IN ('G','B')), -- Good / Bad

    facility_id INT NOT NULL,

    FOREIGN KEY (facility_id) REFERENCES Facilities(facility_id)
);

-- INSTRUCTORS

CREATE TABLE Instructors (
    instructor_id SERIAL PRIMARY KEY,
    
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,

    phone VARCHAR(20),
    
    email VARCHAR(100) NOT NULL UNIQUE, -- unique emails required

    hire_date DATE DEFAULT CURRENT_DATE
        CHECK (hire_date > DATE '2026-01-01'),

    specialization VARCHAR(100) NOT NULL
);

-- CLASSES

CREATE TABLE Classes (
    class_id SERIAL PRIMARY KEY,
    
    class_name VARCHAR(100) NOT NULL,
    
    description TEXT,
    
    max_capacity INT NOT NULL 
        CHECK (max_capacity > 0)
);
   
-- SCHEDULE
CREATE TABLE Schedule (
    schedule_id SERIAL PRIMARY KEY,
    
    class_id INT NOT NULL,
    instructor_id INT NOT NULL,

    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,

    facility_id INT NOT NULL,

    CHECK (end_time > start_time), -- logical validation

    FOREIGN KEY (class_id) REFERENCES Classes(class_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id),
    FOREIGN KEY (facility_id) REFERENCES Facilities(facility_id)
);

-- ATTENDANCE (BRIDGE TABLE)

CREATE TABLE Attendance (
    attendance_id SERIAL PRIMARY KEY,
    
    member_id INT NOT NULL,
    schedule_id INT NOT NULL,

    check_in_time TIMESTAMP,

    status CHAR(1) DEFAULT 'R'
        CHECK (status IN ('R','P')), -- Reserved / Present

    UNIQUE (member_id, schedule_id), -- prevents duplicates

    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (schedule_id) REFERENCES Schedule(schedule_id)
);

-- CERTIFICATIONS

CREATE TABLE Certifications (
    certification_id SERIAL PRIMARY KEY,
    
    certification_name VARCHAR(100) NOT NULL UNIQUE,
    
    issuing_organization VARCHAR(100) NOT NULL,
    
    valid_years INT NOT NULL 
        CHECK (valid_years > 0)
);


-- INSTRUCTOR_CERTIFICATION (M:N RELATIONSHIP)

CREATE TABLE Instructor_Certification (
    certification_id INT NOT NULL,
    instructor_id INT NOT NULL,

    issue_date DATE DEFAULT CURRENT_DATE
        CHECK (issue_date > DATE '2026-01-01'),

    PRIMARY KEY (certification_id, instructor_id),

    FOREIGN KEY (certification_id) REFERENCES Certifications(certification_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);

-- END OF SCRIPT


