IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'GenericCompany')
	BEGIN
		CREATE DATABASE [GenericCompany]
	END;
GO

USE GenericCompany
GO
CREATE TABLE Brands
(
	BrandKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Brand varchar(40) NOT NULL,
	Active bit DEFAULT(1) NOT NULL
)

CREATE TABLE ComputerTypes
(
	ComputerTypeKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ComputerType varchar(25) NOT NULL
) 

CREATE TABLE ComputerStatuses
(
	ComputerStatusKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ComputerStatus varchar(50) NOT NULL,
	ActiveStatus bit NOT NULL  --an indicator of if this status means the computer is available or not
)

CREATE TABLE CPUTypes
(
	CPUTypeKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	CPUType varchar(40) NOT NULL
)

CREATE TABLE Computers
(
	ComputerKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ComputerTypeKey int NOT NULL,
	BrandKey int NOT NULL,	
	ComputerStatusKey int NOT NULL DEFAULT(0),
	PurchaseDate date NOT NULL,
	PurchaseCost money NOT NULL,
	MemoryCapacityInMB int NOT NULL,
	CHECK (MemoryCapacityInMB >= 512 AND MemoryCapacityInMB <= 262144), --0.5 GB to 256 GB
	HardDriveCapacityinGB int NOT NULL,
	CHECK (HardDriveCapacityInGB >= 16 AND HardDriveCapacityInGB <= 10240), --16 GB to 10 TB
	VideoCardDescription varchar (255),
	CPUTypeKey int NOT NULL,
	CPUClockRateInGHZ decimal (6, 4)
)

SET IDENTITY_INSERT Computers ON
INSERT Computers (ComputerKey, ComputerTypeKey, BrandKey, ComputerStatusKey, PurchaseDate, PurchaseCost, MemoryCapacityInMB, 
	HardDriveCapacityinGB, VideoCardDescription, CPUTypeKey, CPUClockRateInGHZ) VALUES
	(1, 1, 1, 0, '1/1/2017', 1999.99, 4096, 1024, 'Nvidia 1080', 1, 3.5),
	(2, 2, 4, 0, '1/1/2017', 2399.99, 16384, 512, 'Nvidia GeForce GT 650M', 1, 2.5)
SET IDENTITY_INSERT Computers OFF

CREATE TABLE Departments
(
	DepartmentKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Department varchar(255)
)

SET IDENTITY_INSERT Departments ON
INSERT Departments (DepartmentKey, Department) VALUES
	(1, 'CEO'),
	(2, 'Human Resources'),
	(3, 'Information Technology'),
	(4, 'Accounting')
SET IDENTITY_INSERT Departments OFF

CREATE TABLE Employees
(
	EmployeeKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	LastName varchar(25) NOT NULL,
	FirstName varchar(25) NOT NULL,
	Email varchar(50) NOT NULL,
	Hired date NOT NULL,
	Terminated date NULL,
	DepartmentKey int NOT NULL,
	SupervisorEmployeeKey int NOT NULL --CEO/Top of hierarchy should have their own EmployeeKey
)

SET IDENTITY_INSERT Employees ON
INSERT Employees (EmployeeKey, LastName, FirstName, Email, Hired, DepartmentKey, SupervisorEmployeeKey) VALUES
	(1, 'Ceo', 'John The', 'JCeo@thiscompany.com', '1/1/2017', 1, 1),
	(2, 'Brother', 'Big', 'BBrother@thiscompany.com', '1/1/2017', 2, 1),
	(3, 'Geek', 'Major', 'MGeek@thiscompany.com', '1/1/2017', 3, 1)
SET IDENTITY_INSERT Employees OFF


CREATE TABLE EmployeeComputers
(
	EmployeeComputerKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	EmployeeKey int NOT NULL,
	ComputerKey int NOT NULL,
	Assigned date NOT NULL,
	Returned date NULL
)

INSERT EmployeeComputers (EmployeeKey, ComputerKey, Assigned) VALUES
	(1, 1, '1/1/2017'),
	(1, 2, '1/1/2017')


CREATE TABLE ComputerStatusHistory
(
	ComputerStatusHistoryKey int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ComputerKey int REFERENCES Computers(ComputerKey) NOT NULL,
	EmployeeKey int REFERENCES Employees(EmployeeKey) NULL,
	OriginalComputerStatusKey int REFERENCES ComputerStatuses (ComputerStatusKey) NULL,
	ChangedComputerStatusKey int REFERENCES ComputerStatuses (ComputerStatusKey) NOT NULL,
	HistoryDate datetime DEFAULT (GETDATE()) NOT NULL
)

SET IDENTITY_INSERT ComputerStatuses ON
	INSERT ComputerStatuses (ComputerStatusKey, ComputerStatus, ActiveStatus) VALUES 
		(0, 'New', 1),
		(1, 'Assigned', 1),
		(2, 'Available', 1),
		(3, 'Lost', 0),
		(4, 'In for Repairs', 0), 
		(5, 'Retired', 1)
SET IDENTITY_INSERT ComputerStatuses OFF

SET IDENTITY_INSERT CPUTypes ON 
INSERT CPUTypes (CPUTypeKey, CPUType) VALUES 
	(1, 'AMD'), 
	(2, 'Intel'), 
	(3, 'Samsung'), 
	(4, 'Apple'), 
	(5, 'Qualcomm')
SET IDENTITY_INSERT CPUTypes OFF

SET IDENTITY_INSERT ComputerTypes ON
INSERT ComputerTypes (ComputerTypeKey, ComputerType) VALUES 
	(1, 'Desktop'),
	(2, 'Laptop'),
	(3, 'Tablet'),
	(4, 'Phone')
SET IDENTITY_INSERT ComputerTypes OFF

SET IDENTITY_INSERT Brands ON
INSERT Brands (BrandKey, Brand) VALUES
	(1, 'Apple'),
	(2, 'Samsung'),
	(3, 'Sony'),
	(4, 'HP'),
	(5, 'Acer'),
	(6, 'NVidia')
SET IDENTITY_INSERT Brands OFF

INSERT ComputerStatusHistory (ComputerKey, EmployeeKey, OriginalComputerStatusKey, ChangedComputerStatusKey, HistoryDate) VALUES
	(1, NULL, NULL, 0, '12/31/2016'),  --New computer purchased and added to inventory
	(1, 1, 0, 1, '1/1/2017 8:00:00 am'), --Computer now assigned to CEO
	(1, 1, 1, 3, '5/12/2017 11:00:00 am'), --Computer stolen. 
	(2, NULL, NULL, 0, '12/31/2016'), --New computer purchased (laptop)
	(2, 1, 0, 1, '1/1/2017 8:00:00am') -- Computer assigned to CEO



ALTER TABLE Computers 
	ADD CONSTRAINT FK_ComputerComputerTypes 
	FOREIGN KEY (ComputerTypeKey) 
	REFERENCES ComputerTypes (ComputerTypeKey)

ALTER TABLE Computers
	ADD CONSTRAINT FK_ComputerBrands
	FOREIGN KEY (BrandKey) 
	REFERENCES Brands (BrandKey)

ALTER TABLE Computers
	ADD CONSTRAINT FK_ComputerComputerStatus
	FOREIGN KEY (ComputerStatusKey) 
	REFERENCES ComputerStatuses (ComputerStatusKey)

ALTER TABLE Computers
	ADD CONSTRAINT FK_ComputerCPUType
	FOREIGN KEY (CPUTypeKey) 
	REFERENCES CPUTypes (CPUTypeKey)

ALTER TABLE Employees
	ADD CONSTRAINT FK_EmployeeDepartment
	FOREIGN KEY (DepartmentKey)
	REFERENCES Departments (DepartmentKey)

ALTER TABLE Employees
	ADD CONSTRAINT FK_EmployeeSupervisor
	FOREIGN KEY (SupervisorEmployeeKey)
	REFERENCES Employees (EmployeeKey)

ALTER TABLE EmployeeComputers
	ADD CONSTRAINT FK_EmployeeComputerEmployee
	FOREIGN KEY (EmployeeKey)
	REFERENCES Employees (EmployeeKey)

ALTER TABLE EmployeeComputers
	ADD CONSTRAINT FK_EmployeeComputerComputer
	FOREIGN KEY (ComputerKey)
	REFERENCES Computers (ComputerKey)

 
/*

Some general rules for the following requests:
 - You can't change the existing table struture of the database.  If you feel you need to add something
	to accomplish the work, feel free to do so.
 - Hard Drive size is always displayed in TB
 - Memory size is always displayed in GB
 - If I ask for the employee name, I want to see LastName, FirstName
 - Remember to start all your objests off with a prefix - for this project use "Group" followed by
	your number and an underscore (Group1_YourObjectGoesHere)

Create a trigger that populates changes to the Computer Status History table, based
	on changes made to the EmployeeComputers and Computers table.  Specifically, 
	when a new computer is added, a record should be created in the the ComputerStatusHistory
	table indicating it purchased (status of 0, no employee assigned - see example records).
	When something happens to the EmployeeComputers table, write the appropriate records
	into the ComputerStatusHistory table.

Create a view that shows all available computers (those that are new or available for 
	reassignment).  Include all the computer specs, brand, etc. and, if applicable, the last person
	who was assigned the machine (just in case you have any questions).  This list will
	be used to determine what computer to assign out.

Create a view that shows all computers that are in for repair.  Include who the 
	computer belongs to, their email address, how long it has been in for repairs, 
	and the associated specs, brand, type, etc.  This list will be used to update those
	users that are waiting on repairs.

Create a view that shows all stolen/lost computers.  Include who the computer belongs to, when it
	was purchased, when it was lost, and amount depreciated, and how much is left.  To calculate this, 
	we will assume a 36 month depreciation (each month we use up 1/36th of the original cost).  
	You need to see how many months remain of the 36 months and multiple this by the original cost
	of the computer.  A computer that costs 1800 will depreciate at $50 a month.  A computer lost after
	13 months would have depreciated $650 and would still be worth $1150 (show these two values).

Create a view that returns an employee list - should include their full name, email address, 
	their department, the number of computers they have, and who their supervisor is.  Only
	return active employees.

Create a stored procedure that shows the complete history for a machine.  The stored
	procedure should accept a computer key and return all the details of the machine (as above) and
	the date/time it moved into each status.  Include any associated users name and email address
	(name in lastname, firstname format).  If the computer can't be found, have the stored
	procedure return -1 as an output variable (1 if it worked).

All data for hard drive space and memory will be given to you in MB (let's say it is a crappy purchasing
	system that hasn't been updated in a while).  Create a function that will accept a number (representing
	the number of MB) and the desired conversion.  Return the requested conversion.  This function will be
	used in display of data and ensuring the right data makes it into the database.

	For this, I subscribe to the approach taken on this web page - https://www.computerhope.com/issues/chspace.htm


Create stored procedures to accomplish the following items:
 - Add a new employee
 - Update an employees department
 - Create a new department
 - Update an employees supervisor
 - Terminate an employee (think this one through - you need to check back in equipment, maybe change
	the supervisor of employees who report to this person, etc.).  Use some sort of failsafe in this
	stored procedure (TRY/CATCH, Transaction, function, etc.).  You can't have bad data created here
 - Create new computers
 - Assign a computer
 - Change the status of a computer
 - Return a computer (some of these could be combined)
 - Create a brand
 - Remove a brand


Last part, and to force you to do some testing...  Create the following executions of your above work.
 - Create the department 'Business Intelligence'
 - Add two valid employee, both part of Business Intelligence
 - Try to add an employee, passing in a department that doesn't exist
 - Try to add an employee, passing in a supervisor that is no longer active (what should this do?)
 - Update an employees department to 'Human Resources'
 - Try to update an employees department to 'Moon Staff' (assuming that 'Moon Staff' doesn't exist
	in your database).  
 - Update an employees supervisor to an active employee
 - Try updating an employees supervisor to an inactive employee.  Should this work?
 - Create a new Mac Book pro laptop for Major Geek.  Use whatever specs you can find off the Apple
	web page.  Make sure the laptop gets assigned to Major Geek
 - Terminate employee #3 (Major Geek)
 - Execute the stored procedure that shows the computer history, passing in the computer key for the 
	new laptop you created for Major Geek (tricky).  Does it show available now?
 - The CEO lost his laptop - execute the stored procedure to make this change.
 - Select all records from your lost computer view.  Does the CEO's laptop show up?  How much was 
	depreciated?
 - Add two computers of your own choosing.
 - Assign these computers to the CEO (he loses them fast)
 - Return one of these computers

 - and any others that you feel show off your awesomeness...

*/




--------------------------------
/*
	Stored Procedures under here
*/




--------------------------------
/*
	Triggers under here
*/



--------------------------------
/*
	Views under here
*/




--------------------------------
/*
	Functions under here
*/





--------------------------------
/*
	Tests under here
*/

