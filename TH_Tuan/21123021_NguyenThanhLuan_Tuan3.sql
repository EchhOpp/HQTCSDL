﻿-- Tuần 3 
-- 1.  Tạo hai bảng mới trong cơ sở dữ liệu AdventureWorks2008 theo cấu trúc sau:
create table MyDepartment (
	DepID smallint not null primary key,
	DepNam nvarchar(50),
	GrpName nvarchar(50)
)
go
create table MyEmployee (
	EmID int not null primary key,
	FsrtName nvarchar(50),
	MidName nvarchar(50), 
	LstName nvarchar(50),
	DepID smallint not null foreign key references MyDepartment (DepID)
)

-- 2) Dùng lệnh insert <TableName1> select <fieldList> from
-- <TableName2> chèn dữ liệu cho bảng MyDepartment, lấy dữ liệu từ
-- bảng [HumanResources].[Department].
insert [dbo].[MyDepartment]
select HRD.[DepartmentID], HRD.[Name], HRD.[GroupName]
from [HumanResources].[Department] HRD

select * from [dbo].[MyDepartment]

-- 3) Tương tự câu 2, chèn 20 dòng dữ liệu cho bảng MyEmployee lấy dữ liệu
-- từ 2 bảng
-- [Person].[Person] và
-- [HumanResources].[EmployeeDepartmentHistory]

insert [dbo].[MyEmployee]
select top 20 EDH.[BusinessEntityID], [FirstName],[MiddleName] ,[LastName],[DepartmentID]
from [HumanResources].[EmployeeDepartmentHistory] EDH join [Person].[Person] PP
	on EDH.[BusinessEntityID] = PP.[BusinessEntityID]

select * from [dbo].[MyEmployee]

-- 4) Dùng lệnh delete xóa 1 record trong bảng MyDepartment với DepID=1,
-- có thực hiện được không? Vì sao?


DELETE FROM myDepartment 
WHERE DepID = 1

-- có thể delete được vì bảng myDepartment không có tham chiếu đến bảng khác

-- 5) Thêm một default constraint vào field DepID trong bảng MyEmployee,
-- với giá trị mặc định là 1.
 
alter table [dbo].[MyEmployee]
add constraint DF_MyEmployee default 1 for DepID

select *
from MyEmployee

-- 6) Nhập thêm một record mới trong bảng MyEmployee, theo cú pháp sau:
-- insert into MyEmployee (EmpID, FrstName, MidName,
-- LstName) values(1, 'Nguyen','Nhat','Nam'). Quan sát giá trị
-- trong field depID của record mới thêm..
-- thêm một giá trij depid = 1
insert MyDepartment
select hre.DepartmentID, hre.Name, hre.GroupName
from HumanResources.Department as hre
where hre.DepartmentID = 1

SELECT * FROM MyDepartment as md
-- them record 
insert into MyEmployee (EmID, FsrtName, MidName, LstName) 
values(1, 'Nguyen','Nhat','Nam')

-- 7) Xóa foreign key constraint trong bảng MyEmployee, thiết lập lại khóa ngoại
-- DepID tham chiếu đến DepID của bảng MyDepartment với thuộc tính on
-- delete sets default.
-- xoá foreign key của bảng MyEmploye

alter table [dbo].[MyEmployee] 
drop constraint [FK__MyEmploye__DepID__4EA8A765]

-- thiết lập lại khoá ngoại on delete sets default
alter table MyEmployee
add constraint fk_DepID foreign key (DepID) references MyDepartment (DepID)
on delete set default

-- 8) Xóa một record trong bảng MyDepartment có DepID=7, quan sát kết quả
-- trong hai bảng MyEmployee và MyDepartment
SELECT * FROM MyDepartment as md

delete from myDepartment
where DepID = 12

-- kiểm tra kết quả
SELECT *
from MyEmployee

SELECT *
from MyDepartment

-- 9) Xóa foreign key trong bảng MyEmployee. Hiệu chỉnh ràng buộc khóa
-- ngoại DepID trong bảng MyEmployee, thiết lập thuộc tính on delete
-- cascade và on update cascade

-- xoá foreign key của bảng MyEmployee
alter table MyEmployee
drop constraint fk_DepID

-- thiết lập lại khoá ngoại on delete cascade on update cascade
alter table MyEmployee
add constraint fk_DepID foreign key (DepID) references MyDepartment (DepID)
on delete cascade on update cascade

-- 10)Thực hiện xóa một record trong bảng MyDepartment với DepID =3, có
-- thực hiện được không?

delete from myDepartment
where DepID = 3

-- kiểm tra kết quả
SELECT *
from MyEmployee

SELECT *
from MyDepartment

-- 11)Thêm ràng buộc check vào bảng MyDepartment tại field GrpName, chỉ cho
-- phép nhận thêm những Department thuộc group Manufacturing
alter table myDepartment
add constraint CK_myDepartment_Manufacturing check (GrpName = 'Manufacturing')

-- 12)Thêm ràng buộc check vào bảng [HumanResources].[Employee], tại cột
-- BirthDate, chỉ cho phép nhập thêm nhân viên mới có tuổi từ 18 đến 60
select *
from HumanResources.Employee as hre

alter table HumanResources.Employee
add constraint CK_HumanResources_Employee_BirthDate check ((year(getdate()) - year(BirthDate)) between 18 and 60)
