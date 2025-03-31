--create database
create database test_db;

--create schema
create schema test_db_schema;


--create tables
-- Dimension Table: DimDate
CREATE TABLE DimDate (
    DateID INT PRIMARY KEY,
    Date DATE,
    DayOfWeek VARCHAR(10),
    Month VARCHAR(10),
    Quarter INT,
    Year INT,
    IsWeekend BOOLEAN
);

-- Dimension Table: DimLoyaltyProgram
CREATE TABLE DimLoyaltyProgram (
    LoyaltyProgramID INT PRIMARY KEY,
    ProgramName VARCHAR(100),
    ProgramTier VARCHAR(50),
    PointsAccrued INT
);

-- Dimension Table: DimCustomer
CREATE TABLE DimCustomer (
    CustomerID INT PRIMARY KEY autoincrement start 1 increment 1,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender VARCHAR(10),
    DateOfBirth DATE,
    Email VARCHAR(100),
    PHONENUMBER VARCHAR(100),
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Country VARCHAR(50),
    LoyaltyProgramID INT
);

-- Dimension Table: DimProduct
CREATE TABLE DimProduct (
    ProductID INT PRIMARY KEY autoincrement start 1 increment 1,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Brand VARCHAR(50),
    UnitPrice DECIMAL(10, 2)
);

-- Dimension Table: DimStore
CREATE TABLE DimStore (
    StoreID INT PRIMARY KEY autoincrement start 1 increment 1,
    StoreName VARCHAR(100),
    StoreType VARCHAR(50),
	StoreOpeningDate DATE,
    Address VARCHAR(255),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Country VARCHAR(50),
    ManagerName VARCHAR(100)
);



-- Fact Table: FactOrders
CREATE TABLE FactOrders (
    OrderID INT PRIMARY KEY autoincrement start 1 increment 1,
    DateID INT,
    CustomerID INT,
    ProductID INT,
    StoreID INT,
    QuantityOrdered INT,
    OrderAmount DECIMAL(10, 2),
    DiscountAmount DECIMAL(10, 2),
    ShippingCost DECIMAL(10, 2),
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (DateID) REFERENCES DimDate(DateID),
    FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
    FOREIGN KEY (StoreID) REFERENCES DimStore(StoreID)
);

--create file format
CREATE OR REPLACE FILE FORMAT csv_source_file_format
TYPE = 'CSV'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
DATE_FORMAT = 'YYYY-MM-DD';

--create stage
create or replace stage test_stage;

--load dimloyalty from stage to table dimloyaltyprogram
copy into dimloyaltyprogram
from @test_db.test_db_schema.test_stage/dimloyaltyinfo/dimloyaltyinfo.csv
file_format = (format_name = 'TEST_DB.TEST_DB_SCHEMA.CSV_SOURCE_FILE_FORMAT');

--show data of dimloyaltyprogram table
select * from dimloyaltyprogram;

--load dimcustomer from stage to table dimcustomer
copy into dimcustomer(FIRSTNAME, LASTNAME, GENDER, DATEOFBIRTH, EMAIL,PHONENUMBER, ADDRESS, CITY, STATE, ZIPCODE, COUNTRY, LOYALTYPROGRAMID)
from @test_db.test_db_schema.test_stage/dimcustomer/dimcustomer.csv
file_format = (format_name = 'TEST_DB.TEST_DB_SCHEMA.CSV_SOURCE_FILE_FORMAT')
ON_ERROR = 'CONTINUE';

--show data of dimcustomer table
select * from dimcustomer;

--load dimdate from stage to table dimdate
copy into dimdate(DATEID, DATE, DAYOFWEEK, MONTH, QUARTER, YEAR, ISWEEKEND)
from @test_db.test_db_schema.test_stage/dimdate/dimdate.csv
file_format = (format_name = 'TEST_DB.TEST_DB_SCHEMA.CSV_SOURCE_FILE_FORMAT')
ON_ERROR = 'CONTINUE';

--show data of dimdate table
select * from dimdate;

--load dimstore from stage to table dimstore
copy into dimstore(	STORENAME, STORETYPE, STOREOPENINGDATE, ADDRESS, CITY, STATE, COUNTRY, REGION, MANAGERNAME)
from @test_db.test_db_schema.test_stage/dimstore/dimstore.csv
file_format = (format_name = 'TEST_DB.TEST_DB_SCHEMA.CSV_SOURCE_FILE_FORMAT')
ON_ERROR = 'CONTINUE';

--show data of dimstore table
select * from dimstore;


--load factorders from stage to table factorders
copy into factorders(DATEID, CUSTOMERID, PRODUCTID, STOREID, QUANTITYORDERED, ORDERAMOUNT, DISCOUNTAMOUNT, SHIPPINGCOST, TOTALAMOUNT)
from @test_db.test_db_schema.test_stage/factorders/factorders.csv
file_format = (format_name = 'TEST_DB.TEST_DB_SCHEMA.CSV_SOURCE_FILE_FORMAT')
ON_ERROR = 'CONTINUE';

--show data of factorders table
select * from factorders;

--load historical orders data from stage to table factorders
copy into factorders(DATEID, CUSTOMERID, PRODUCTID, STOREID, QUANTITYORDERED, ORDERAMOUNT, DISCOUNTAMOUNT, SHIPPINGCOST, TOTALAMOUNT)
from @test_db.test_db_schema.test_stage/historical_order_data/
file_format = (format_name = 'TEST_DB.TEST_DB_SCHEMA.CSV_SOURCE_FILE_FORMAT')
ON_ERROR = 'CONTINUE';

--create user
CREATE or replace USER powerbi
PASSWORD = 'power12345' 
LOGIN_NAME = 'power'
DEFAULT_ROLE = 'ACCOUNTADMIN'
DEFAULT_WAREHOUSE = 'COMPUTE_WH'
MUST_CHANGE_PASSWORD = TRUE
COMMENT = 'User for Data Engineer tasks';

--give role accountadmin to user powerbi
GRANT ROLE accountadmin TO USER powerbi;


