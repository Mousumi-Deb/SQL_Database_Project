

--create database Hospital_system_management ;

use Hospital_system_management;

create table hospital(
	h_name varchar(50) primary key,
    country varchar(30),
    address varchar(50));

create table doctor(
	dr_id int primary key,
	d_name varchar(30) not null,
	age int,
	gender char (10),
	specialization varchar(30),
	duty_hours int,
	current_appointment int,
    h_name varchar(50),
    foreign key (h_name) references hospital (h_name)
	);
    
create table nurse(
	nurse_id int primary key,
    n_name varchar(20),
    gender char(2),
	duty_hour int,
    dr_id int,
    h_name varchar(50),
    foreign key (dr_id) references doctor(dr_id),
    foreign key(h_name) references hospital (h_name));
    
    
create table patient(
	p_id int primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    age int,
    p_gender varchar(10),
    address varchar(50),
    ref_doctor varchar(20),
    room_no int,
    nurse_id int,
    foreign key (nurse_id) references nurse(nurse_id));
    
create table appointment(
	appoint_id int primary key,
    phone int,
    date_time datetime,
    e_mail varchar(30),
    dr_id int,
    foreign key(dr_id) references doctor(dr_id));

create table bill(
	bill_no int primary key,
	patient_type varchar(20),
	dr_charge int not null,
	medicine_charge int not null,
	number_of_days int,
	p_id int,
	foreign key(p_id) references patient(p_id));



insert into hospital values
('Maya clinic', 'Sweden', 'Drottningsgatan, Stockholm'),
('Ibn sina Hospital', 'United states', 'Texas'),
('St. Thomas hospital', 'Australia','Melbourne 32'),
('Brigham and womens hospital', 'USA', 'Boston, MA'),
('Bangkok hospital','Thailand', 'Bangkok'),
('North york general hospital', 'Canada', 'Toronto'),
('Royal prince alfred hospital', 'Australia','Sydney');

insert into doctor values
(1,'Dr.Adam', 30, 'Male', 'Dermatologist', 8, 12,'Maya clinic'),
(2,'Dr.Alex', 28, 'Male', 'Physiotherapist',7, 10, 'Brigham and womens hospital'),
(3,'Dr.Bill', 33, 'Male', 'Physiotherapist',8, 14, 'Royal prince alfred hospital'),
(4,'Dr.Mark', 37, 'Male', 'Surgeon', 9, 13, 'North york general hospital'),
(5,'Dr.Alen', 31, 'Male', 'Radiologist', 8, 7, 'St. Thomas hospital'),
(6,'Dr.Maria', 30, 'Female', 'Psychiatrist', 7, 17, 'St. Thomas hospital' ),
(7,'Dr.Anna', 32, 'Female', 'Anatomy', 9, 19,'Bangkok hospital');


insert into nurse values
(101, 'Sara','F',8,5,'St. Thomas hospital'),
(102, 'Alyaa','F',10,7,'Bangkok hospital'),
(103,'Carolina', 'F',7,4,'North york general hospital'),
(104, 'Hawra', 'F',11, 6,'St. Thomas hospital' ),
(105,'Mary','F',8, 2, 'Brigham and womens hospital'),
(106,'Adam','M',9, 3,'Royal prince alfred hospital'),
(107,'Sarah', 'F',8, 1,'Maya clinic');

insert into Patient values
(001, 'Edwin','Ström', 26, 'Male', 'Kista', 'Dr.Alex', 2, 102),
(002, 'Max','larsson', 26, 'Male', 'Sollentuna', 'Dr.Adam', 6, 101),
(003, 'Michiel','Rocha', 26, 'Male', 'Akalla', 'Dr.Mark', 5, 104),
(004, 'David','Hegnar', 26, 'Male', 'Alvik strand', 'Dr.Bill', 11, 103),
(005, 'Carolina','Bögh', 26, 'Female', 'Las vegas', 'Dr.Maria', 7, 106),
(006, 'Ananya','Sharma', 26, 'Female', 'Rinkeby', 'Dr.Alen', 14, 105),
(007, 'Fima','Aalto', 26, 'Female', 'Visby', 'Dr.Anna', 13, 107);

insert into appointment values
(011, 0701200012, '2023-01-18 18:11:02','mary@hotmail.com',2),
(012, 0701401251,'2023-01-18 21:09:02','maria@gmail.com',4),
(013, 0917684786,'2023-01-18 18:11:02','evagarnar21@gmail.com',5),
(014, 0172067231,'2023-01-13 21:18:39','kompis@yahoo.com',3),
(015, 01756465471,'2023-01-13 21:18:39','kingalex@gmail.com',1),
(016, 0838642611,'2023-01-20 21:15:56','st.thomas@hotmail.com',6),
(017, 0678978973, '2023-01-19 01:09:02','mayo@gmail.com',7);

insert into bill values
(1, 'inpatient', 1100, 1500, 5, 001),
(2,'inpatient',2060,1800,10,003),
(3,'inpatient',3030,1100,15, 004),
(4,'inpatient',4100,2900,20,005),
(5,'inpatient',5000,7500,25,006),
(6,'outpatient',1000,1500,2,007),
(7,'outpatient',500,1000,1,002);
