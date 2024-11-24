--*************************************************************************--
-- Title: Assignment07
-- Author: Kenneth_Harrison
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,Kenneth_Harrison,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_Kenneth_Harrison')
	 Begin 
	  Alter Database [Assignment07DB_Kenneth_Harrison] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_Kenneth_Harrison;
	 End
	Create Database Assignment07DB_Kenneth_Harrison;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_Kenneth_Harrison;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --

Select * From vProducts
go

-- Show a list of Product names and the price of each product.

--Select
--	ProductName
--	,UnitPrice
--	From vProducts
--go

-- Use a function to format the price as US dollars.

--Select
--	ProductName
--	,Format (UnitPrice, 'C', 'en-us') as Unit_Price
--	From vProducts
--go

-- Final code order the result by the product name.

Select
	ProductName
	,Format (UnitPrice, 'C', 'en-us') as Unit_Price
	From vProducts
	Order By ProductName
go


-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --

Select * From vCategories
Select * From vProducts

-- Show a list of Category and Product names, and the price of each product.

--Select
--	c.CategoryName
--	,p.ProductName
--	,p.UnitPrice
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--go

-- Use a function to format the price as US dollars.

--Select
--	c.CategoryName
--	,p.ProductName
--	,Format (p.unitPrice, 'C', 'en-us') As Unit_Price
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--go

-- Final code order the result by the Category and Product.

Select
	c.CategoryName
	,p.ProductName
	,Format (p.unitPrice, 'C', 'en-us') As Unit_Price
	From vCategories as c
	Join vProducts as p
	On c.CategoryID = p.CategoryID
	Order By c.CategoryName, p.ProductName
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

Select * From vProducts
Select * From vInventories

--show a list of Product names, each Inventory Date, and the Inventory Count.

--Select
--	p.ProductName
--	,i.InventoryDate
--	,i.Count
--	From vProducts as p
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--go

-- Format the date like 'January, 2017'.

--Select
--	p.ProductName
--	,[Inventory_Date] = DateName(mm,i.InventoryDate) + ',' + DateName(Year,i.InventoryDate)
--	,i.Count
--	From vProducts as p
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--go

-- Final code order the results by the Product and Date.
Select
	p.ProductName
	,[Inventory_Date] = DateName(mm,i.InventoryDate) + ',' + DateName(Year,i.InventoryDate)
	,i.Count
	From vProducts as p
	Join vInventories as i
	On p.ProductID = i.ProductID
	Order By p.ProductName, i.InventoryDate
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

--show a list of Product names, each Inventory Date, and the Inventory Count.

--Select
--	p.ProductName
--	,i.InventoryDate
--	,i.Count
--	From vProducts as p
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--go

-- Format the date like 'January, 2017'.

--Select
--	p.ProductName
--	,[Inventory_Date] = DateName(mm,i.InventoryDate) + ', ' + DateName(Year,i.InventoryDate)
--	,i.Count
--	From vProducts as p
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--go

-- Order the results by the Product and Date.
--Select
--	p.ProductName
--	,[InventoryDate] = DateName(mm,i.InventoryDate) + ', ' + DateName(Year,i.InventoryDate)
--	,i.Count
--	From vProducts as p
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--	Order By p.ProductName, i.InventoryDate
--go

--CREATE A VIEW called vProductInventories. 

Create View vProductInventories
As
	Select Top 100000
	p.ProductName
	,[InventoryDate] = DateName(mm,i.InventoryDate) + ', ' + DateName(Year,i.InventoryDate)
	,i.Count
	From vProducts as p
	Join vInventories as i
	On p.ProductID = i.ProductID
	Order By p.ProductName, i.InventoryDate
go

-- Check that it works: Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

Select * From vCategories
Select * From vInventories
go

-- Shows a list of Category names, Inventory Dates

--Select
--	c.CategoryName
--	,i.InventoryDate
--	,i.Count
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--go

--Format the date like 'January, 2017'.

--Select
--	c.CategoryName
--	,[InventoryDate] = DateName(mm,i.InventoryDate) + ',' + DateName(Year,i.InventoryDate)
--	,i.Count
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--go

--TOTAL Inventory Count BY CATEGORY

--Select
--	c.CategoryName
--	,[InventoryDate] = DateName(mm,i.InventoryDate) + ',' + DateName(Year,i.InventoryDate)
--	,[InventoryCount] = Sum(i.Count)
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--	Group By [InventoryDate],c.CategoryName
--go

--Order the results by the Category and Date.

--Select
--	c.CategoryName
--	,[InventoryDate] = DateName(mm,i.InventoryDate) + ',' + DateName(Year,i.InventoryDate)
--	,[InventoryCount] = Sum(i.Count)
--	From vCategories as c
--	Join vProducts as p
--	On c.CategoryID = p.CategoryID
--	Join vInventories as i
--	On p.ProductID = i.ProductID
--	Group By InventoryDate, c.CategoryName
--	Order By c.CategoryName, InventoryDate
--go

-- Final Code CREATE A VIEW called vCategoryInventories. 

Create View vCategoryInventories
As
	Select Top 100000
		c.CategoryName
		,[InventoryDate] = DateName(mm,i.InventoryDate) + ',' + DateName(Year,i.InventoryDate)
		,[InventoryCount] = Sum(i.Count)
		From vCategories as c
		Join vProducts as p
		On c.CategoryID = p.CategoryID
		Join vInventories as i
		On p.ProductID = i.ProductID
		Group By InventoryDate, c.CategoryName
		Order By c.CategoryName, InventoryDate
go

Select * From vCategoryInventories;

-- Check that it works: Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --

-- This new view must use your vProductInventories view.
--Show a list of Product names, Inventory Dates, Inventory Count


Select * From vProductInventories

-- Show a list of Product names, Inventory Dates, Inventory Count
Select * From vProductInventories

-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.Order the results by the Product and Date. 


--Select
--	ProductName
--	,InventoryDate
--	,Count
--	,[PreviousMonthCount] = Case
--					When DatePart(month, Cast(InventoryDate As Date)) = 1 Then 0
--					Else
--					Lag (Count) Over (Order By (ProductName), (Month(Cast(InventoryDate AS Date))))
--					End
--	From vProductInventories

-- Use functions to set any January NULL counts to zero. 

--Select
--	ProductName
--	,InventoryDate
--	,Count
--	,[PreviousMonthCount] = Case
--					When DatePart(month, Cast(InventoryDate As Date)) = 1 Then 0
--					Else
--					IsNull (Lag (Count) Over (Order By (ProductName), (Month(Cast(InventoryDate AS Date)))),0)
--					End
--	From vProductInventories

-- Final Code CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 

go
Create View
	 vProductInventoriesWithPreviouMonthCounts
As
Select
	ProductName
	,InventoryDate
	,Count
	,[PreviousMonthCount] = Case
					When DatePart(month, Cast(InventoryDate As Date)) = 1 Then 0
					Else
					IsNull (Lag (Count) Over (Order By (ProductName), (Month(Cast(InventoryDate AS Date)))),0)
					End
	From vProductInventories
go


Select * From vProductInventoriesWithPreviouMonthCounts;

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;


-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

Select * From vProductInventoriesWithPreviouMonthCounts

-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
--Select
--	ProductName
--	,InventoryDate
--	,Count
--	,PreviousMonthCount
--	From vProductInventoriesWithPreviouMonthCounts
--go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

--go
--Select
--	ProductName
--	,InventoryDate
--	,Count
--	,PreviousMonthCount
--	,[InventoryKPI] = Case
--		When Count > PreviousMonthCount Then 1
--		When Count = PreviousMonthCount Then 0
--		When Count < PreviousMonthCount Then -1
--		End
--	From vProductInventoriesWithPreviouMonthCounts

--  Final Code CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
go
Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
	Select
	ProductName
	,InventoryDate
	,Count
	,PreviousMonthCount
	,[InventoryKPI] = Case
		When Count > PreviousMonthCount Then 1
		When Count = PreviousMonthCount Then 0
		When Count < PreviousMonthCount Then -1
		End
	From vProductInventoriesWithPreviouMonthCounts
go

Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;


-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs
go

--Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs
--	Where InventoryKPI = 0

--Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs
--	Where InventoryKPI = 1

--Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs
--	Where InventoryKPI = -1

--Select
--	ProductName
--	,InventoryDate
--	,Count
--	,PreviousMonthCount
--	,InventoryKPI
--	From vProductInventoriesWithPreviousMonthCountsWithKPIs
--go
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
go

go
Create Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
Returns Table
As
	Return
		Select
		ProductName
		,InventoryDate
		,Count
		,PreviousMonthCount
		,InventoryKPI
		From vProductInventoriesWithPreviousMonthCountsWithKPIs
		Where InventoryKPI = @KPI
go

Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/