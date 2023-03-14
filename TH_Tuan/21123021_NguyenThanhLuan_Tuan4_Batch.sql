use AdventureWorks2008R2
--1. Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm
--có ProductID=’778’; nếu @tongsoHD>500 thì in ra chuỗi “Sản phẩm 778 có
--trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặthàng” Viết một batch khai báo biến @tongsoHD chứa tổng số hóa đơn của sản phẩm
--có ProductID=’778’; nếu @tongsoHD>500 thì in ra  chuỗi “Sản phẩm 778 có
--trên 500 đơn hàng”, ngược lại thì in ra chuỗi “Sản phẩm 778 có ít đơn đặthàng”


-- Xem tổng hóa đơn
SELECT [ProductID], COUNTOFPRO = COUNT([ProductID])
FROM [Sales].[SalesOrderDetail]
WHERE [ProductID] = 778
GROUP BY [ProductID]

-- gọi biến

DECLARE @maSP int, @tongHD int
SET @maSP = 778
SET @tongHD = 
(
SELECT COUNT([ProductID]) 
FROM [Sales].[SalesOrderDetail]
WHERE [ProductID] = @maSP
)

-- in ra select 
SELECT @maSP AS maSP, @tongHD as tongHD

-- in ra bảng messgares
if @tongHD > 500
	print N'Sản phẩm ' +cast(@maSP as varchar(4)) +N' có ít hơn 500 sản phẩm'
else 
	print N'Sản phẩm ' +cast(@maSP as varchar(4)) +N' có nhiều hơn 500 sản phẩm'
go

-- 2. Viết một đoạn Batch với tham số @makh và @n chứa số hóa đơn của khách hàng
--@makh, tham số @nam chứa năm lập hóa đơn (ví dụ @nam=2008), nếu @n>0
--thì in ra chuỗi: “Khách hàng @makh có @n hóa đơn trong năm 2008” ngược lại
--nếu @n=0 thì in ra chuỗi “Khách hàng @makh không có hóa đơn nào trong năm
--2008”

-- In ra n số hóa đơn của khách hàng makh
SELECT [CustomerID], COUNT([SalesOrderID]) ,year([OrderDate])
FROM [Sales].[SalesOrderHeader]
WHERE YEAR([OrderDate]) = 2008 
GROUP BY [CustomerID], OrderDate

-- Gọi biến
DECLARE	@makh int, @n int, @nam int 
SET @makh =29825
SET @nam = 2008
SET @n = (
SELECT COUNT(*) 
FROM [Sales].[SalesOrderHeader]
WHERE [CustomerID] = @makh AND YEAR([OrderDate]) = @nam
)
-- hiển thị bằng select 
SELECT @makh AS maKH, @n AS TongHD, @nam as Nam

-- Hiển thị trong messages
if(@n > 0)
	print N'Khách hàng' + cast(@makh as varchar(6)) + N' có '+cast(@n as varchar(3))+ N' trong năm ' + cast(@nam as varchar(4))
else 
	print N'Khách hàng' + cast(@makh as varchar(6)) + N' không có hóa đơn trong năm '+ cast(@nam as varchar(4))
go

-- 3) Viết một batch tính số tiền giảm cho những hóa đơn (SalesOrderID) có tổng 
-- tiền>100000, thông tin gồm [SalesOrderID], SubTotal=SUM([LineTotal]), 
-- Discount (tiền giảm), với Discount được tính như sau:
-- + Những hóa đơn có SubTotal<100000 thì không giảm,
-- + SubTotal từ 100000 đến <120000 thì giảm 5% của SubTotal
-- + SubTotal từ 120000 đến <150000 thì giảm 10% của SubTotal
-- + SubTotal từ 150000 trở lên thì giảm 15% của SubTotal
-- (Gợi ý: Dùng cấu trúc Case… When …Then …)

SELECT [SalesOrderID] , SubTotal = SUM([LineTotal]),
	Discount =
	CASE
		WHEN SUM([LineTotal]) < 0 then 0
		WHEN SUM(LineTotal) BETWEEN 100000 AND 120000 THEN SUM(LineTotal) * 0.95
		WHEN SUM(LineTotal) BETWEEN 120000 AND 150000 THEN SUM(LineTotal) * 0.9
		WHEN SUM(LineTotal) > 150000 THEN SUM(LineTotal) * 0.85
	END
FROM [Sales].[SalesOrderDetail]
GROUP BY [SalesOrderID]
HAVING SUM([LineTotal]) > 100000

--4 Viết một Batch với 3 tham số: @mancc, @masp, @soluongcc, chứa giá trị của
--các field [ProductID],[BusinessEntityID],[OnOrderQty], với giá trị truyền cho
--các biến @mancc, @masp (vd: @mancc=1650, @masp=4), thì chương trình sẽ
--gán giá trị tương ứng của field [OnOrderQty] cho biến @soluongcc, nếu
--@soluongcc trả về giá trị là null thì in ra chuỗi “Nhà cung cấp 1650 không cung
--cấp sản phẩm 4”, ngược lại (vd: @soluongcc=5) thì in chuỗi “Nhà cung cấp 1650
--cung cấp sản phẩm 4 với số lượng là 5”

-- xem số lượng nhà cung cấp sản phẩm

SELECT [ProductID], [BusinessEntityID], [OnOrderQty]
FROM [Purchasing].[ProductVendor]
WHERE [ProductID] = 4 AND [BusinessEntityID] =1650

-- gọi biến 

DECLARE @mancc int, @masp int, @soluongcc int 
SET @mancc = 1650
SET @masp = 4
SET @soluongcc = (
SELECT OnOrderQty
FROM [Purchasing].[ProductVendor]
WHERE ProductID = @masp AND BusinessEntityID = @mancc
)

-- In ra bảng select 
SELECT @mancc AS MaNCC, @masp AS MaSP, @soluongcc AS SoLuongCC

-- In ra bảng messages 
IF(@soluongcc != NULL)
	print N'Nhà cung cấp ' + convert(nvarchar(5), @mancc) + N' cấp sản phẩm có mã: ' + convert(varchar(5), @masp) + N' với số lượng là ' + convert(varchar(5), @soluongcc)
ELSE 
	print N'Nhà cung cấp ' + convert(nvarchar(5), @mancc) + N' không cung cấp sản phẩm có mã: ' + convert(varchar(5), @masp)


--5. Viết một batch thực hiện tăng lương giờ (Rate) của nhân viên trong 
--[HumanResources].[EmployeePayHistory] theo điều kiện sau: Khi tổng lương 
--giờ của tất cả nhân viên Sum(Rate)<6000 thì cập nhật tăng lương giờ lên 10%, 
--nếu sau khi cập nhật mà lương giờ cao nhất của nhân viên >150 thì dừng.--Xem bảng lương theo giờselect * from [HumanResources].[EmployeePayHistory]--Tạo 1 bảng view Go CREATE VIEW VIEW_PAY AS	SELECT [BusinessEntityID], [Rate] FROM [HumanResources].[EmployeePayHistory]GO-- Xem bảng viewSELECT * FROM VIEW_PAY-- Cập nhậtWHILE(SELECT SUM(RATE) FROM VIEW_PAY ) < 6000BEGIN	UPDATE VIEW_PAY	SET Rate = Rate * 1.1	IF(SELECT MAX(RATE) FROM VIEW_PAY) > 150		BREAK	ELSE 		CONTINUEEND-- Xóa bảng DROP VIEW VIEW_PAYGO