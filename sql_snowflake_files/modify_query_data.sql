--numer of days betwewn dates
select datediff(day, '2014-01-01', current_date);
--4100

--generate random date
select dateadd(day, uniform(0, 4100, random()), '2014-01-01');

--fix date in dimstore
UPDATE dimstore SET STOREOPENINGDATE = DATEADD(DAY, FLOOR(UNIFORM(0, 4100, RANDOM())), '2014-01-01');

commit;
---------------------------------------------------------
--update open date to last 10 store to make them open in last year
select * from dimstore where storeid between 91 and 100;
select dateadd(year, -1, current_date);
select dateadd(day, uniform(0, 360, random()), (select dateadd(year, -1, current_date)));

UPDATE dimstore SET STOREOPENINGDATE = dateadd(day, uniform(0, 360, random()), (select dateadd(year, -1, current_date)))
where storeid between 91 and 100;
----------------------------------------------------

select * from dimcustomer where dateofbirth > dateadd(year, -12, current_date);

update dimcustomer set dateofbirth = dateadd(year, -12, dateofbirth) where dateofbirth > dateadd(year, -12, current_date);

commit;
-----------------------------------------------------------------

--update date of orders that do not match dates in the date table and date open store
update factorders f set f.dateid = r.dateid from
    (select orderid, d.dateid from
        (select fo.orderid, 
        dateadd(day, floor(datediff(day, ds.storeopeningdate, current_date) * uniform(1, 10, random()) * .1), ds.storeopeningdate) as new_date
        from factorders fo
        join dimdate dd on fo.dateid = dd.dateid
        join dimstore ds on fo.storeid = ds.storeid
        where dd.date < ds.storeopeningdate) o
    join dimdate d on d.date = o.new_date) r
    where r.orderid = f.orderid;

commit;
-----------------------------------------------------------------
--who customers haven't placed any orders in last 30 days
select * from dimcustomer d where d.customerid not in (
    select distinct dc.customerid from dimcustomer dc
    join factorders fo on dc.customerid = fo.customerid
    join dimdate dd on dd.dateid = fo.dateid
    where dd.date >= dateadd(month, -3, current_date));


-----------------------------------------------------------------------
-- total sales for recent open store
with store_rank as
    (select storeid, row_number() over (order by storeopeningdate desc) as final_rank from dimstore), 
    most_recent_store as (select storeid from store_rank where final_rank = 1)
    ,store_amount as
    (select o.storeid, sum(o.totalamount) total_amount from most_recent_store m join factorders o
    on m.storeid = o.storeid
    group by o.storeid
    )
select s.*, a.total_amount from dimstore s join store_amount a
on s.storeid = a.storeid;
-------------------------------------------------------------------------------------
--customers who have purchased items from more than 3 distinct categories in the last 9 months
with customerdata as
    (select o.customerid , p.category from factorders o join dimdate d
    on o.dateid = d.dateid
    join dimproduct p on o.productid = p.productid
    where d.date >= dateadd(month, -9, current_date)
    group by o.customerid, p.category)

select * from dimcustomer c join customerdata cd on c.customerid = cd.customerid
where count(distinct cd.category) > 3;
----------------------------------------------------------------------
--the total sales amount for each month of the previous year
SELECT MONTH, SUM(TOTALAMOUNT) AS MONTHLY_AMOUNT 
FROM FACTORDERS O 
JOIN DIMDATE D ON O.DATEID = D.DATEID 
WHERE D.YEAR = EXTRACT(YEAR FROM CURRENT_DATE) -1
GROUP BY MONTH
order by MONTH;

-----------------------------------------------------------------
--the row with the highest discountAMOUNT within the past year
with base_data as (
    SELECT discountAMOUNT, row_number() over (order by discountAMOUNT desc) as discountAMOUNT_rank 
    FROM FACTORDERS O JOIN DIMDATE D ON O.DATEID=D.DATEID
    WHERE D.DATE >= dateadd(year, -1, current_date)
)
select * from base_data where discountAMOUNT_rank=1;
-------------------------------------------------------------------------
-- the total sales revenue
select sum(quantityordered * unitprice) from factorders o join dimproduct p on o.productid=p.productid;
---------------------------------------------------------------------
---the customerid with the highest total discountamount
select customerid from factorders f
group by customerid
order by sum(discountamount) desc limit 1;
----------------------------------------------------------------------------

--the customer with the highest number of orders
with base_data as (
    select customerid, count(orderid) as order_count from factorders f
    group by customerid
),
order_Rank_data as (
    select b.*, row_number() over (order by order_count desc) as order_rank from base_data b
)
select * from order_Rank_data where order_rank=1;
----------------------------------------------------------------------

--counts the number of customers in each loyalty program tier
select l.programtier, count(customerid) as customer_count from 
dimcustomer d join dimloyaltyprogram l on d.loyaltyprogramid=l.loyaltyprogramid
group by l.programtier;
---------------------------------------------------------------------

--the total sales for each region and category combination for the past 6 months
SELECT region, category, sum(totalamount) as total_sales
FROM FACTORDERS F
join dimdate d on f.dateid=d.dateid
join dimproduct p on f.productid=p.productid
join dimstore s on f.storeid=s.storeid
where d.date>=dateadd(month, -6, current_date)
group by region, category;
------------------------------------------------------------------------

--the top 5 products with the highest total quantity ordered over the past 3 years
WITH QUANTITY_DATA AS (
    SELECT F.PRODUCTID, SUM(QUANTITYORDERED) AS TOTAL_Quantity FROM FACTORDERS F JOIN DIMDATE D ON F.DATEID=D.DATEID
    WHERE D.DATE>=DATEADD(YEAR,-3,CURRENT_DATE)
    GROUP BY F.PRODUCTID
),
quantity_rank_data AS (
    SELECT q.*, row_number() over (order by TOTAL_Quantity desc) as quantity_Wise_rank FROM QUANTITY_DATA q
)
select productid, TOTAL_Quantity from quantity_rank_data where quantity_Wise_rank<=5;

--------------------------------------------------------------------
--the total sales for each loyalty program since the beginning of 2023 
SELECT p.programname, sum(totalamount) as total_sales FROM FACTORDERS F
join dimdate d on f.dateid=d.dateid
join dimcustomer c on f.customerid=c.customerid
join dimloyaltyprogram p on c.loyaltyprogramid=p.loyaltyprogramid
where d.year >= 2023
group by p.programname;

--------------------------------------------------------------------

--the total sales for each store manager for June 2024
SELECT s.managername, sum(totalamount) as total_sales FROM FACTORDERS F
join dimdate d on f.dateid=d.dateid
join dimstore s on f.storeid=s.storeid
where d.year = 2024 and d.month=6
group by s.managername;

-----------------------------------------------------------------------
--average sales for each store name and store type in 2024
SELECT s.storename, s.storetype, avg(totalamount) as total_sales FROM FACTORDERS F
join dimdate d on f.dateid=d.dateid
join dimstore s on f.storeid=s.storeid
where d.year = 2024
group by s.storename, s.storetype;
-----------------------------------------------------------------
--reads data from a CSV file located in a stage and selects the first three columns from each row
SELECT $1, $2, $3
FROM @TEST_DB.TEST_DB_SCHEMA.TEST_STAGE/dimcustomer/dimcustomer.csv
(FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT');
------------------------------------------------------------------
--counts the number of records (rows) in a CSV file located in a stage
SELECT count($1)
FROM
@TEST_DB.TEST_DB_SCHEMA.TEST_STAGE/dimcustomer/dimcustomer.csv
(FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT');
-------------------------------------------------------------

----Filter Data , Share the records from Dim Customer File where Customer DOB after 1st Jan 2000
SELECT $1, $2, $3, $4, $5, $6, $7
FROM @TEST_DB.TEST_DB_SCHEMA.TEST_STAGE/dimcustomer/dimcustomer.csv
(FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT')
WHERE $4 > '2000-01-01';
-----------------------------------------------------------------
--Join Dim Customer and Dim Loyalty and show the customer 1st name along with the program tier they are part of
with customer_data as (
    SELECT $1 as First_Name, $12 as Loyalty_Program_ID
    FROM
    @TEST_DB.TEST_DB_SCHEMA.TEST_STAGE/dimcustomer/dimcustomer.csv
    (FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT')
),
loyalty_data as (
    SELECT $1 as Loyalty_Program_ID, $3 as program_tier
    FROM
    @TEST_DB.TEST_DB_SCHEMA.TEST_STAGE/dimloyaltyinfo/dimloyaltyinfo.csv
    (FILE_FORMAT => 'CSV_SOURCE_FILE_FORMAT')
)
select program_tier, count(1) as total_count from customer_data c join loyalty_data l on c.Loyalty_Program_ID=l.Loyalty_Program_ID
group by program_tier;









