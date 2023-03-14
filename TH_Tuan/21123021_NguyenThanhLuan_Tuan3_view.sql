use AdventureWorks2008R2
GO

-- 1) Tạo view dbo.vw_Products hiển thị danh sách các sản phẩm từ bảng
-- Production.Product và bảng Production.ProductCostHistory. Thông tin bao gồm
-- ProductID, Name, Color, Size, Style, StandardCost, EndDate, StartDate

CREATE view products1 as 
    select pp.ProductID, pp.Name, pp.Color, pp.Size, pp.Style, 
        ppch.StandardCost, ppch.EndDate, ppch.StartDate
    from production.Product as pp join Production.ProductCostHistory as ppch
    on pp.ProductID = ppch.ProductID
GO

-- kiểm tra kết quả
select * from products1
go

-- 2) Tạo view List_Product_View chứa danh sách các sản phẩm có trên 500 đơn đặt
-- hàng trong quí 1 năm 2008 và có tổng trị giá >10000, thông tin gồm ProductID,
-- Product_Name, CountOfOrderID và SubTotal.

create view List_Product_View as 
	select PP.[ProductID], ProductName = PP.[Name], CountOfOrderID = count(SOD.[SalesOrderID]), SubTotal = sum(SOD.[UnitPrice] * SOD.[OrderQty])
	from [Production].[Product] PP join [Sales].[SalesOrderDetail] SOD 
	on SOD.[ProductID] = PP.[ProductID]
	join [Sales].[SalesOrderHeader] SOH
	on SOH.[SalesOrderID] = SOD.[SalesOrderID]
	where DATEPART(q, SOH.[OrderDate]) = 1 and DATEPART(YEAR, SOH.[OrderDate]) = 2008
	group by PP.[ProductID], PP.[Name]
	having count(SOD.[SalesOrderID]) > 500 and sum(SOD.[UnitPrice] * SOD.[OrderQty]) > 10000
go
select * from List_Product_View
go

-- 3) Tạo view dbo.vw_CustomerTotals hiển thị tổng tiền bán được (total sales) từ cột
-- TotalDue của mỗi khách hàng (customer) theo tháng và theo năm. Thông tin gồm
-- CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS
-- OrderMonth, SUM(TotalDue).

create view vw_CustomerTotals as
	select SC.[CustomerID], MONTH(SOH.[OrderDate]) as OrderMonth ,YEAR([OrderDate]) as OrderYear, TotalDue = sum([TotalDue])
	from [Sales].[Customer] SC join [Sales].[SalesOrderHeader] SOH
	on SC.[CustomerID] = SOH.[CustomerID]
	group by SC.[CustomerID],SOH.[OrderDate]
	go
select * from dbo.vw_CustomerTotals
go

-- 4) Tạo view trả về tổng số lượng sản phẩm (Total Quantity) bán được của mỗi nhân
-- viên theo từng năm. Thông tin gồm SalesPersonID, OrderYear, sumOfOrderQty

create view view_Total_Quantity as
	select SOH.[SalesPersonID], Year(SOH.[OrderDate]) as OrderYear,sum(SOD.[OrderQty]) as sumOfOrderQty
	from [Sales].[SalesOrderDetail] SOD join [Sales].[SalesOrderHeader] SOH
	on SOD.[SalesOrderID] = SOH.[SalesOrderID]
	group by SOH.[SalesPersonID], Year(SOH.[OrderDate])
go

select * from view_Total_Quantity

drop view view_TotalQuantity
GO

-- 5) Tạo view ListCustomer_view chứa danh sách các khách hàng có trên 25 hóa đơn
-- đặt hàng từ năm 2007 đến 2008, thông tin gồm mã khách (PersonID) , họ tên
-- (FirstName +' '+ LastName as FullName), Số hóa đơn (CountOfOrders).

create view ListCustomer_view as
	select SOH.[CustomerID] as PersonID, (PP.FirstName +' '+ PP.LastName) as FullName, CountOfOrder = sum(SOH.[SalesOrderID])
	from [Sales].[SalesOrderHeader] SOH join [Person].[Person] PP 
	on SOH.[CustomerID] = PP.[BusinessEntityID] 
	where YEAR([OrderDate]) between 2007 and 2008
	group by SOH.[CustomerID],PP.FirstName,PP.LastName
go
select * from ListCustomer_view
go

-- 6) Tạo view ListProduct_view chứa danh sách những sản phẩm có tên bắt đầu với
-- ‘Bike’ và ‘Sport’ có tổng số lượng bán trong mỗi năm trên 50 sản phẩm, thông
-- tin gồm ProductID, Name, SumOfOrderQty, Year. (dữ liệu lấy từ các bảng
-- Sales.SalesOrderHeader, Sales.SalesOrderDetail, và
-- Production.Product)
create view ListProduct_view as
	select PP.[ProductID], PP.[Name], SumOfOrderQty = sum(SOD.[OrderQty]), Year(SOH.[OrderDate]) as 'Year'
	from [Production].[Product] PP join [Sales].[SalesOrderDetail] SOD 
	on PP.[ProductID] = SOD.[ProductID]
	join [Sales].[SalesOrderHeader] SOH
	on SOD.[SalesOrderID] = SOH.[SalesOrderID]
	where PP.[Name] like 'Bike%' or PP.[Name] like 'Sport%'
	group by PP.[ProductID], PP.[Name],SOH.[OrderDate]
	having sum(SOD.[OrderQty]) > 50
go
select * from ListProduct_view
go

-- 7) Tạo view List_department_View chứa danh sách các phòng ban có lương (Rate:
-- lương theo giờ) trung bình >30, thông tin gồm Mã phòng ban (DepartmentID),
-- tên phòng ban (Name), Lương trung bình (AvgOfRate). Dữ liệu từ các bảng
-- [HumanResources].[Department],
-- [HumanResources].[EmployeeDepartmentHistory],
-- [HumanResources].[EmployeePayHistory].

create view List_department_View as 
	select HRD.[DepartmentID], HRD.[Name], AvgOfRate = avg(HREPH.[Rate])
	from [HumanResources].[Department] HRD join [HumanResources].[EmployeeDepartmentHistory] HREDH
	on HRD.[DepartmentID] = HREDH.[DepartmentID]
	join [HumanResources].[EmployeePayHistory] HREPH
	on HREPH.[BusinessEntityID] =  HREDH.[BusinessEntityID]
	group by HRD.[DepartmentID], HRD.[Name]
	having avg(HREPH.[Rate]) > 30

select * from List_department_View

-- 8) Tạo view Sales.vw_OrderSummary với từ khóa WITH ENCRYPTION gồm
-- OrderYear (năm của ngày lập), OrderMonth (tháng của ngày lập), OrderTotal
-- (tổng tiền). Sau đó xem thông tin và trợ giúp về mã lệnh của view này
create view vw_OrderSummary WITH ENCRYPTION as
    select OrderYear = year(ssoh.OrderDate), OrderMonth = month(ssoh.OrderDate), 
        OrderTotal = sum(ssod.OrderQty * ssod.UnitPrice)
    from Sales.SalesOrderHeader as ssoh join Sales.SalesOrderDetail as ssod
    on ssoh.SalesOrderID =  ssod.SalesOrderID
    group by year(ssoh.OrderDate), month(ssoh.OrderDate)
go
-- Kiểm tra kết quả
EXEC sp_helptext [List_Product_view]
EXEC sp_helptext vw_OrderSummary

select * from vw_OrderSummary
-- huỷ view
drop view vw_OrderSummary
GO

-- 9) Tạo view Production.vwProducts với từ khóa WITH SCHEMABINDING
-- gồm ProductID, Name, StartDate,EndDate,ListPrice của bảng Product và bảng
-- ProductCostHistory. Xem thông tin của View. Xóa cột ListPrice của bảng
-- Product. Có xóa được không? Vì sao?
create view vwProducts WITH SCHEMABINDING as
    select pp.ProductID, pp.Name, ppch.StartDate, ppch.EndDate, pp.ListPrice
    from [Production].[Product] as pp join [Production].[ProductCostHistory] as ppch
    on pp.ProductID = ppch.ProductID
    GROUP BY pp.ProductID, pp.Name, ppch.StartDate, ppch.EndDate, pp.ListPrice
go
-- Kiểm tra kết quả
select * from vwProducts
-- huỷ view
drop view vwProducts
GO

-- 10) Tạo view view_Department với từ khóa WITH CHECK OPTION chỉ chứa các
-- phòng thuộc nhóm có tên (GroupName) là “Manufacturing” và “Quality
-- Assurance”, thông tin gồm: DepartmentID, Name, GroupName.
create view view_Department as
    select hrd.DepartmentID, hrd.Name, hrd.GroupName
    from [HumanResources].[Department] as hrd
    where GroupName='Manufacturing' or GroupName='Quality Assurance'
    WITH CHECK OPTION
go
-- Kiểm tra kết quả
select * from view_Department
-- huỷ view
drop view view_Department
go
-- a. Chèn thêm một phòng ban mới thuộc nhóm không thuộc hai nhóm
-- “Manufacturing” và “Quality Assurance” thông qua view vừa tạo. Có
-- chèn được không? Giải thích.
insert view_Department values( 'nhan su', 'a')
-- không chèn được vì thuộc tính with check option kiểm tra không cho chèn
select *from [HumanResources].[Department]

-- b. Chèn thêm một phòng mới thuộc nhóm “Manufacturing” và một
-- phòng thuộc nhóm “Quality Assurance”.
insert view_Department values( 'nhan su', 'Manufacturing'),
                            ('nhan su 2', 'Quality Assurance')
-- chèn thành công

-- c. Dùng câu lệnh Select xem kết quả trong bảng Department.
select *from [HumanResources].[Department]