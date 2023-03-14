use AdventureWorks2008R2
-- 1) Liệt kê danh sách các hóa đơn (SalesOrderID) lập trong tháng 6 năm 2008 có
-- tổng tiền > 70000, thông tin gồm SalesOrderID, Orderdate, SubTotal, trong đó
-- SubTotal =SUM(OrderQty*UnitPrice).

select SOD.[SalesOrderID], SOH.[OrderDate], SubTotal = sum(SOD.[UnitPrice] * SOD.[OrderQty])
from [Sales].[SalesOrderDetail] SOD join [Sales].[SalesOrderHeader] SOH on SOD.[SalesOrderID] = SOH.[SalesOrderID]
where MONTH([OrderDate]) = 6 and YEAR([OrderDate]) = 2008
group by SOD.[SalesOrderID], SOH.[OrderDate]
having sum(SOD.[UnitPrice] * SOD.[OrderQty]) > 70000

-- 2) Đếm tổng số khách hàng và tổng tiền của những khách hàng thuộc các quốc gia
-- có mã vùng là US (lấy thông tin từ các bảng Sales.SalesTerritory,
-- Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail). Thông tin
-- bao gồm TerritoryID, tổng số khách hàng (CountOfCust), tổng tiền
-- (SubTotal) với SubTotal = SUM(OrderQty*UnitPrice)

select ST.[TerritoryID], CountOfCust = sum(SC.[CustomerID]), SubTotal = sum (SOD.[OrderQty] * SOD.[UnitPrice])
from [Sales].[SalesOrderDetail] SOD join [Sales].[SalesOrderHeader] SOH
	on SOD.[SalesOrderID] = SOH.[SalesOrderID]
	join [Sales].[SalesTerritory]  ST
	on ST.[TerritoryID] = SOH.[TerritoryID]
	join [Sales].[Customer] SC
	on SC.[CustomerID] = SOH.[CustomerID]
where [CountryRegionCode] = 'US'
group by ST.[TerritoryID]

-- 3) Tính tổng trị giá của những hóa đơn với Mã theo dõi giao hàng
-- (CarrierTrackingNumber) có 3 ký tự đầu là 4BD, thông tin bao gồm
-- SalesOrderID, CarrierTrackingNumber, SubTotal=SUM(OrderQty*UnitPrice)

select [SalesOrderID], [CarrierTrackingNumber], SubTotal = sum([UnitPrice]*[OrderQty])
from [Sales].[SalesOrderDetail]
group by [SalesOrderID], [CarrierTrackingNumber]
having [CarrierTrackingNumber] like '4BD%'.

-- 4) Liệt kê các sản phẩm (Product) có đơn giá (UnitPrice)<25 và số lượng bán
-- trung bình >5, thông tin gồm ProductID, Name, AverageOfQty.

select PP.[ProductID], PP.[Name], AverageOfQty = avg(SSOD.[UnitPrice])
from [Production].[Product] PP join [Sales].[SalesOrderDetail] SSOD on PP.[ProductID] = SSOD.[ProductID]
where SSOD.[UnitPrice] < 25
group by PP.[ProductID], PP.[Name]
having avg(SSOD.[OrderQty]) > 5

-- 5) Liệt kê các công việc (JobTitle) có tổng số nhân viên >20 người, thông tin gồm
-- JobTitle,CountOfPerson=Count(*)

select hre.[JobTitle], CountOfPerson = count(hre.[BusinessEntityID])
from [HumanResources].[Employee] hre
group by  hre.[JobTitle]
having count(hre.[BusinessEntityID]) > 20

-- 6) Tính tổng số lượng và tổng trị giá của các sản phẩm do các nhà cung cấp có tên
-- kết thúc bằng ‘Bicycles’ và tổng trị giá > 800000, thông tin gồm
-- BusinessEntityID, Vendor_Name, ProductID, SumOfQty, SubTotal
-- (sử dụng các bảng [Purchasing].[Vendor], [Purchasing].[PurchaseOrderHeader] và
-- [Purchasing].[PurchaseOrderDetail])

select PV.[BusinessEntityID], PV.[Name],[ProductID],SumOfQty = sum([OrderQty]), SubTaTol = sum([OrderQty]*[UnitPrice])
from [Purchasing].[PurchaseOrderDetail]  POD join [Purchasing].[PurchaseOrderHeader] POH
	on POD.[PurchaseOrderID] = POH.[PurchaseOrderID]
	join [Purchasing].[Vendor] PV
	on PV.[BusinessEntityID] = POH.[VendorID]
where PV.[Name] like '%Bicycles'
group by PV.[BusinessEntityID], PV.[Name],[ProductID]
having sum([OrderQty]*[UnitPrice]) > 800000

-- 7) Liệt kê các sản phẩm có trên 500 đơn đặt hàng trong quí 1 năm 2008 và có tổng
-- trị giá >10000, thông tin gồm ProductID, Product_Name, CountOfOrderID và SubTotal
select pp.ProductID, pp.Name, CountOfOrderID = count(ssod.SalesOrderID), SubTotal = SUM(ssod.OrderQty * ssod.UnitPrice)
from Production.Product pp
    join sales.SalesOrderDetail ssod on ssod.ProductID = pp.ProductID
    join sales.SalesOrderHeader ssoh on ssod.SalesOrderID = ssoh.SalesOrderID
WHERE Datepart(q, ssoh.OrderDate) = 1 and YEAR(ssoh.OrderDate) = 2008
group by pp.ProductID, pp.Name
HAVING SUM(ssod.OrderQty * ssod.UnitPrice) > 10000 and count(ssod.SalesOrderID) > 500

-- 8) Liệt kê danh sách các khách hàng có trên 25 hóa đơn đặt hàng từ năm 2007 đến
-- 2008, thông tin gồm mã khách (PersonID) , họ tên (FirstName +' '+ LastName
-- as FullName), Số hóa đơn (CountOfOrders).
select sc.PersonID, FullName = (pp.FirstName + ' ' + pp.LastName), CountOfOrders = count(ssoh.SalesOrderID)
from Person.Person pp
    join Sales.Customer sc on pp.BusinessEntityID = sc.CustomerID
    join Sales.SalesOrderHeader ssoh on ssoh.CustomerID = sc.CustomerID
WHERE year(ssoh.OrderDate) BETWEEN 2007 and 2008
group by sc.PersonID, pp.FirstName + ' ' + pp.LastName
having count(ssoh.SalesOrderID) > 25

-- 9) Liệt kê những sản phẩm có tên bắt đầu với ‘Bike’ và ‘Sport’ có tổng số lượng
-- bán trong mỗi năm trên 500 sản phẩm, thông tin gồm ProductID, Name,
-- CountOfOrderQty, Year. (Dữ liệu lấy từ các bảng Sales.SalesOrderHeader,
-- Sales.SalesOrderDetail và Production.Product)
select pp.ProductID, pp.Name, CountOfOrderQty = sum(ssod.OrderQty), YearOfSale=year(ssoh.OrderDate)
from Production.Product pp
    join sales.SalesOrderDetail ssod on ssod.ProductID = pp.ProductID
    join sales.SalesOrderHeader ssoh on ssod.SalesOrderID = ssoh.SalesOrderID
WHERE pp.Name like '%Bike' or pp.Name like '%Sport'
group by pp.ProductID, pp.Name, year(ssoh.OrderDate)
having sum(ssod.OrderQty) > 500

-- 10)Liệt kê những phòng ban có lương (Rate: lương theo giờ) trung bình >30, thông
-- tin gồm Mã phòng ban (DepartmentID), tên phòng ban (Name), Lương trung
-- bình (AvgofRate). Dữ liệu từ các bảng
-- [HumanResources].[Department],
-- [HumanResources].[EmployeeDepartmentHistory],
-- [HumanResources].[EmployeePayHistory]
select hrd.DepartmentID, hrd.Name, AvgofRate = avg(heph.Rate)
from HumanResources.Department hrd
    join HumanResources.EmployeeDepartmentHistory hedh on hrd.DepartmentID = hedh.DepartmentID
    join HumanResources.EmployeePayHistory heph on hedh.BusinessEntityID = heph.BusinessEntityID
group by hrd.DepartmentID, hrd.Name
having avg(heph.Rate) > 30