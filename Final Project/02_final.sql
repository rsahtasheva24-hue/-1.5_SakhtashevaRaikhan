-- Database: dvdrental
-- Schema: college_core

create schema if not exists college_core;
set search_path to college_core, public;

-- PART 2: CREATE TABLES (With explicit PKs, FKs, ON DELETE, and Constraints)

drop table if exists grade cascade;
drop table if exists enrollment cascade;
drop table if exists courses cascade;
drop table if exists students cascade;
drop table if exists "Group" cascade;
drop table if exists teacher cascade;

create table if not exists teacher (
    teacherid int generated always as identity primary key,
    firstname varchar(100) not null,
    lastname varchar(100) not null,
    email varchar(120) unique,
    department varchar(100)
);

create table if not exists "Group" (
    groupid int generated always as identity primary key,
    groupname varchar(50) not null unique,
    academic_year int check (academic_year >= 2026)
);

create table if not exists students (
    studentid int generated always as identity primary key,
    firstname varchar(50) not null,
    lastname varchar(50) not null,
    dateofbirth date,
    gender varchar(10) not null check (gender in ('M', 'F', 'Other')),
    email varchar(120) not null unique,
    created timestamp default now(),
    groupid int references "Group"(groupid) on delete restrict
);

create table if not exists courses (
    courseid int generated always as identity primary key,
    coursename varchar(100) not null unique,
    credits int not null check (credits > 0),
    teacherid int references teacher(teacherid) on delete restrict
);

create table if not exists enrollment (
    enrollmentid int generated always as identity primary key,
    studentid int not null references students(studentid) on delete cascade,
    courseid int not null references courses(courseid) on delete cascade,
    enrollmentdate date not null check (enrollmentdate > date '2026-01-01'),
    status varchar(20) default 'Active'
);

create table if not exists grade (
    gradeid int generated always as identity primary key,
    studentid int not null references students(studentid) on delete cascade,
    courseid int not null references courses(courseid) on delete cascade,
    teacherid int references teacher(teacherid) on delete set null,
    gradevalue numeric(5,2) not null check (gradevalue >= 0 and gradevalue <= 100),
    gradedate date not null,
    passed boolean generated always as (gradevalue >= 50) stored
);

-- PART 3: ALTER STATEMENTS 

-- 1. Modify data type length for expanding departments
alter table teacher alter column department type varchar(150);

-- 2. Structurally add student contact column
alter table students add column phone_number varchar(20);

-- 3. Apply complex formatting constraint verification via regex patterns
alter table students add constraint chk_phone check (phone_number is null or phone_number similar to '\+?[0-9\-]+');

-- 4. Add column for context metadata structural field to courses
alter table courses add column description varchar(255);

-- 5. Shift operational rules by updating structural default policies
-- Prevent duplicate student enrollment in the same course
alter table enrollment add constraint uq_student_course unique (studentid, courseid);

-- Restrict enrollment status values
alter table enrollment add constraint chk_enrollment_status check (status in ('Active','Pending','Withdrawn'));

-- PART 4: INSERT DATA 

truncate table grade, enrollment, courses, students, "Group", teacher restart identity cascade;

-- Teachers (5 rows)
insert into teacher(firstname, lastname, email, department) values
('Askar', 'Bimurzaev', 'a.bimurzaev@apec.edu.kz', 'PO3.1'),
('Kunduz', 'Rahym', 'k.rahym@apec.edu.kz', 'PO3.2'),
('Baurzhan', 'Romanov', 'b.romanov@apec.edu.kz', 'PO1.8'),
('Dias', 'Ermekov', 'd.ermekov@apec.edu.kz', 'PO1.5'),
('Sultabeiberys', 'Kalmen', 's.kalmen@apec.edu.kz', 'PO2.5');

-- Groups (5 rows)
insert into "Group"(groupname, academic_year) values
('SE-1/24', 2026), ('SE-2/24', 2026), ('SE-1/23', 2026), ('SE-3/23', 2027), ('SE-1/22', 2026);

-- Students (10 rows)
insert into students(firstname, lastname, dateofbirth, gender, email, groupid, phone_number) values
('Amanbai', 'Aiken', '2008-11-03', 'F', 'a.amanbai24@apec.edu.kz', (select groupid from "Group" where groupname='SE-1/24'), '+77757840530'),
('Aruzhan', 'Hismetova', '2008-01-11', 'F', 'a.hismetova24@apec.edu.kz', (select groupid from "Group" where groupname='SE-1/24'), '+77028936414'),
('Rikhan', 'Sakhtasheva', '2009-08-09', 'F', 'r.sakhtasheva24@apec.edu.kz', (select groupid from "Group" where groupname='SE-2/24'), '+77025140955'),
('Zhumakulova', 'Asylai', '2009-06-04', 'F', 'a.zhumakulova24@apec.edu.kz', (select groupid from "Group" where groupname='SE-2/24'), '+77755250125'),
('Arslan', 'Gaidenuly', '2008-01-05', 'M', 'a.gaidenuly23@apec.edu.kz', (select groupid from "Group" where groupname='SE-1/23'), '+77788821907'),
('Ilnur', 'Garifov', '2007-05-12', 'M', 'i.garifov23@apec.edu.kz', (select groupid from "Group" where groupname='SE-1/23'), '+77753015442'),
('Nurdaulet', 'Zhumabai', '2008-04-08', 'M', 'n.zhumabai23@apec.edu.kz', (select groupid from "Group" where groupname='SE-3/23'), '+77021278455'),
('Moldir', 'Olzhabaeva', '2008-01-08', 'F', 'm.olzhabaeva23@apec.edu.kz', (select groupid from "Group" where groupname='SE-3/23'), '+77053436309'),
('Maksim', 'Le', '2006-01-09', 'M', 'm.le22@apec.edu.kz', (select groupid from "Group" where groupname='SE-1/22'), '+77770152441'),
('Aktoty', 'Shahmet', '2007-01-10', 'F', 'a.shahmet22@apec.edu.kz', (select groupid from "Group" where groupname='SE-1/22'), '+77780519378');

-- Courses (5 rows)
insert into courses(coursename, credits, teacherid, description) values
('Database Systems', 6, (select teacherid from teacher where email='a.bimurzaev@apec.edu.kz'), 'DB'),
('Python Data Science', 5, (select teacherid from teacher where email='s.kalmen@apec.edu.kz'), 'Python'),
('Advanced Calculus', 4, (select teacherid from teacher where email='b.romanov@apec.edu.kz'), 'Math'),
('Software Architecture', 6, (select teacherid from teacher where email='d.ermekov@apec.edu.kz'), 'SE'),
('Quantum Mechanics', 5, (select teacherid from teacher where email='k.rahym@apec.edu.kz'), 'Physics');

-- Enrollments (10 rows)
insert into enrollment(studentid, courseid, enrollmentdate, status) values
((select studentid from students where email='a.amanbai24@apec.edu.kz'), (select courseid from courses where coursename='Database Systems'), '2026-02-01', 'Active'),
((select studentid from students where email='a.hismetova24@apec.edu.kz'), (select courseid from courses where coursename='Database Systems'), '2026-02-01', 'Active'),
((select studentid from students where email='r.sakhtasheva24@apec.edu.kz'), (select courseid from courses where coursename='Python Data Science'), '2026-02-01', 'Active'),
((select studentid from students where email='a.zhumakulova24@apec.edu.kz'), (select courseid from courses where coursename='Python Data Science'), '2026-02-01', 'Active'),
((select studentid from students where email='a.gaidenuly23@apec.edu.kz'), (select courseid from courses where coursename='Software Architecture'), '2026-02-01', 'Active'),
((select studentid from students where email='i.garifov23@apec.edu.kz'), (select courseid from courses where coursename='Software Architecture'), '2026-02-01', 'Withdrawn'),
((select studentid from students where email='n.zhumabai23@apec.edu.kz'), (select courseid from courses where coursename='Advanced Calculus'), '2026-02-01', 'Active'),
((select studentid from students where email='m.olzhabaeva23@apec.edu.kz'), (select courseid from courses where coursename='Advanced Calculus'), '2026-02-01', 'Active'),
((select studentid from students where email='m.le22@apec.edu.kz'), (select courseid from courses where coursename='Quantum Mechanics'), '2026-02-01', 'Active'),
((select studentid from students where email='a.shahmet22@apec.edu.kz'), (select courseid from courses where coursename='Quantum Mechanics'), '2026-02-01', 'Active');

-- Mandatory Requirement: INSERT ... SELECT statement (Tests altered DEFAULT values)
insert into enrollment(studentid, courseid, enrollmentdate)
select s.studentid, c.courseid, date '2026-03-01'
from students s cross join courses c
where s.email='a.amanbai24@apec.edu.kz' and c.coursename='Software Architecture';

-- Grades (5 rows)
insert into grade(studentid, courseid, teacherid, gradevalue, gradedate) values
((select studentid from students where email='m.olzhabaeva23@apec.edu.kz'), (select courseid from courses where coursename='Database Systems'), (select teacherid from teacher where email='a.bimurzaev@apec.edu.kz'), 85, '2026-06-03'),
((select studentid from students where email='a.hismetova24@apec.edu.kz'), (select courseid from courses where coursename='Database Systems'), (select teacherid from teacher where email='a.bimurzaev@apec.edu.kz'), 72, '2026-06-07'),
((select studentid from students where email='a.zhumakulova24@apec.edu.kz'), (select courseid from courses where coursename='Python Data Science'), (select teacherid from teacher where email='s.kalmen@apec.edu.kz'), 91, '2026-05-09'),
((select studentid from students where email='i.garifov23@apec.edu.kz'), (select courseid from courses where coursename='Python Data Science'), (select teacherid from teacher where email='s.kalmen@apec.edu.kz'), 77, '2026-06-02'),
((select studentid from students where email='m.le22@apec.edu.kz'), (select courseid from courses where coursename='Software Architecture'), (select teacherid from teacher where email='d.ermekov@apec.edu.kz'), 83, '2026-06-01');


-- PART 5: UPDATE / DELETE (With Multi-table updates and safe Transactions)

-- UPDATE 1: Standard update using conditional filter
update students set phone_number='+7775789078' where email='a.amanbai24@apec.edu.kz';

-- UPDATE 2: Advanced multi-table update joining courses to inject curriculum bonus points
update grade g
set gradevalue = case when (g.gradevalue + 5) > 100 then 100 else g.gradevalue + 5 end
from courses c
where g.courseid=c.courseid and c.credits>=5;

-- DELETE: Isolated explicit transaction block with deletion validation mapping
begin;

delete from enrollment
where status='Withdrawn'
returning enrollmentid;

rollback;

-- PART 6: SECURITY ROLES 

drop role if exists college_readonly;
drop role if exists college_writer;

create role college_readonly;
create role college_writer;

-- Assign selective read permissions to tracking schema assets
grant select on all tables in schema college_core to college_readonly;

-- Provide initial record management permissions to database targets
grant insert, update on students to college_writer;

-- Revoke mutation rights over existing student files to maintain log lineage 
revoke update on students from college_writer;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'college_core'
ORDER BY table_name;
