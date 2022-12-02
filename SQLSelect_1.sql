--Getting Started with SELECT
--Connecting to a database
USE AdventureWorks2019;

--Checking the database server version
select @@version;

--checking the database name
select db_name();

--querying a table 
select NationalIDNumber
        ,LoginID
        ,JobTitle
from HumanResources.Employee;

--asterisk returns all columns
select *
from HumanResources.Employee;

--returning specific rows
select Title, FirstName, LastName
from Person.Person
where Title = 'Ms.'

--combine multiple conditions in one clause through the use of the logical operators AND and OR
select Title, FirstName, LastName
from Person.Person
where Title = 'Ms.' AND LastName = 'Antrim'

select Title, FirstName, LastName
from Person.Person
where Title = 'Ms.' AND (LastName = 'Antrim' or LastName = 'Galvin')

--listing the available tables
--ISO standard approach
select table_name, table_type
from information_schema.tables
where table_schema = 'HumanResources';

--system catalog approach
select name 
from sys.tables 
where schema_name(schema_id)='HumanResources';

--create all the DROP statements 
select 'drop ' + table_schema + '.' + table_name + ';'
from information_schema.tables 
where table_schema = 'HumanResources'
    and table_type = 'base table';

--naming the output columns
select BusinessEntityID as "Employee ID"
        ,VacationHours as "Vacation"
        ,SickLeaveHours as "Sick Time"
from HumanResources.Employee;

--alternatives to column alias
select BusinessEntityID as "Employee ID" --ISO standard
        ,VacationHours "Vacation" --ISO standard
        ,SickLeaveHours as [Sick Time] --specific to SQL Server
from HumanResources.Employee;

--providing shorthand names for tables
select E.BusinessEntityID as "Employee ID"
        ,E.VacationHours as "Vacation"
        ,E.SickLeaveHours as "Sick Time"
from HumanResources.Employee as E
where E.VacationHours > 40;

--computing new columns from existing data
select BusinessEntityID as "EmployeeID"
        ,VacationHours + SickLeaveHours as "AvailableTimeOff"
from HumanResources.Employee;

--negating a search condition
select Title, FirstName, LastName
from Person.Person
where not Title = 'Ms.';

--apply NOT operator to a group of expressions
select Title, FirstName, LastName
from Person.Person
where not (Title = 'Ms.' or Title = 'Mr.');

--keeping the where clause unambiguous
select Title, FirstName, LastName
from Person.Person
where Title = 'Ms.' 
    and (FirstName = 'Catherine' or LastName = 'Adams');

--testing for existence using TOP()
select top(1) 1
from HumanResources.Employee
where SickLeaveHours > 40;

--testing for existence using EXISTS predicate
select 1
where exists (select * from HumanResources.Employee where SickLeaveHours > 40);

--specifying a range of values using BETWEEN operator
select SalesOrderID, ShipDate 
from Sales.SalesOrderHeader 
where ShipDate BETWEEN '2011-07-23 00:00:00.0' and '2011-07-24 23:59:59.0';

--using greater than or equal to operator
select SalesOrderID, ShipDate 
from Sales.SalesOrderHeader 
where ShipDate >= '2011-07-23' and ShipDate < '2011-07-25';

--checking for null values
select productID, Name, Weight 
from Production.Product 
where Weight is null;

--IN-List
select ProductID, Name, Color 
from Production.Product 
where Color IN ('Silver', 'Black', 'Red');
--where Color = 'Silver', or Color = 'Black' or Color = 'Red' -- semantically equivalent

--Wildcard searches
select ProductID, Name 
from Production.Product 
where Name LIKE 'B%';

--sorting. First sorted by Name. Within Name, sorted by EndDate
select p.Name, h.EndDate, h.ListPrice 
from Production.Product p 
inner join Production.ProductListPriceHistory h on p.ProductID = h.ProductID 
order by p.Name asc, h.EndDate desc;

--specify NULLS FIRST or NULLS LAST
select ProductID, Name, Weight 
from Production.Product 
--order by isnull(Weight, 1) desc, Weight;
order by IIF(Weight IS null, 1, 0), Weight; -- 1 for null, 0 - otherwise

--forcing unusual sort orders
select p.ProductID, p.Name, p.Color 
from Production.Product as p 
where p.Color is not null 
order by case p.Color 
    when 'Red' then null else p.Color end;

--paging through a result set
select ProductID, Name 
from Production.Product 
order by Name 
offset 0 rows fetch next 10 rows only; -- first 10 rows, as ordered by product name
--offset 8 rows fetch next 10 rows only; --the offset will skip the first 8 rows

--sampling  a subset of rows
--specify an approximate percentage of rows to retrieve
select *
from Purchasing.PurchaseOrderHeader
tablesample (5 percent)

--specify an approximate quantity of rows
select *
from Purchasing.PurchaseOrderHeader
tablesample (200 rows)
