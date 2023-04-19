-- 1. Trong SQL Server, tạo thiết bị backup có tên adv2008back lưu trong thư mục
--	T:\backup\adv2008back.bak
--	2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, r
use [AdventureWorks2008R2]
exec sp_addumpdevice 'disk', 'adv2008backk', 'T:\backup\adv2008backk.bak'

--2. Attach CSDL AdventureWorks2008, chọn mode recovery cho CSDL này là full, rồi
--thực hiện full backup vào thiết bị backup vừa tạo
ALTER DATABASE [AdventureWorks2008R2] SET RECOVERY FULL
GO

-- BACKUP DATABASE
USE master 
BACKUP DATABASE AdventureWo	rks2008R2
TO adv2008backk
WITH DESCRIPTION = 'AdventureWorks2008R2 FULL BACKUP'
GO

--3. Mở CSDL AdventureWorks2008, tạo một transaction giảm giá tất cả mặt hàng xe
--đạp trong bảng Product xuống $15 nếu tổng trị giá các mặt hàng xe đạp không thấp
--hơn 60%.

-- Mở CSDL
use [AdventureWorks2008R2]


-- Xem bảng kinh doanh 
select * from [Production].[ProductCategory]

-- Xem các loại xe đạp
select * from [Production].[ProductSubcategory] where [ProductCategoryID] = 1

-- Lọc các loại xe khỏi bảng product 
select * from [Production].[Product] 
where [ProductSubcategoryID] in ( 
	select [ProductSubcategoryID] 
	from [Production].[ProductSubcategory] 
	where [ProductCategoryID] = 1 )

-- Tạo bảng transaction giảm xuống 15% nếu mặt hàng xe đạp không chiếm hơn 60% sản phẩm 
begin tran
declare @TongXeDap money, @Tong money
set @TongXeDap = (
	select tongXD = sum([ListPrice]) from [Production].[Product]
	where [ProductSubcategoryID] in ( select [ProductSubcategoryID] 
									  from [Production].[ProductSubcategory] 
									  where [ProductCategoryID] = 1 )
)

set @Tong = (select tong = sum(ListPrice) from Production.Product)

if @TongXeDap/@Tong >= 0.6
	begin
		update Production.Product -- Giảm giá
		set ListPrice = ListPrice - 15
		where [ProductSubcategoryID] in ( select [ProductSubcategoryID] 
									  from [Production].[ProductSubcategory] 
									  where [ProductCategoryID] = 1 )
		commit tran
	end 
else 
	rollback
go

-- 4. Thực hiện các backup sau cho CSDL AdventureWorks2008, tất cả backup đều lưu
--vào thiết bị backup vừa tạo
--a. Tạo 1 differential backup

BACKUP DATABASE [AdventureWorks2008R2]
TO adv2008backk
WITH DIFFERENTIAL,DESCRIPTION = 'AdventureWorks2008R2 Differential backup'
GO
--b. Tạo 1 transaction log backup
BACKUP LOG [AdventureWorks2008R2]
TO adv2008backk
WITH DESCIPRT 


