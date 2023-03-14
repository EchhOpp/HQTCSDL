-- MODULE 1

USE master
CREATE DATABASE Sale
ON PRIMARY (
	NAME = tuan1_data,
	FILENAME = 'T:\ThucHanhSQL\tuan1_data.mdf',
	SIZE = 10MB,
	MAXSIZE = 20MB,
	FILEGROWTH = 20%
)
LOG ON
(
NAME = tuan1_log,
FILENAME = 'T:\ThucHanhSQL\tuan1_log.ldf',
SIZE = 10MB,
MAXSIZE = 20MB,
FILEGROWTH = 20% )


USE Sale
-- Câu 1: Tạo định nghĩa người dùng

EXEC sp_addtype 'Mota', 'Nvarchar(40)'
EXEC sp_addtype 'IDKH', 'Char(10)', 'Not null'
EXEC sp_addtype 'DT', 'Char(12)'

-- Câu 2: Tạo các bảng theo cấu trúc
USE Sale
CREATE TABLE SanPham ( 
	Masp CHAR(6) NOT NULL,
	TenSp varchar(20),
	NgayNhap Date,
	DVT char(10),
	SoLuongTon Int,
	DonGiaNhap money 
)
CREATE TABLE HoaDon (
	MaHD char(10) not null, 
	NgayLap Date,
	NgayGiao Date,
	Makh IDKH,
	DienGiai Mota )
CREATE TABLE KhachHang (
	MaKH IDKH,
	TenKH Nvarchar(30),
	Diachi nvarchar (40),
	Dienthoai DT
)
CREATE TABLE ChiTietHD
(
MaHD char(10),
Masp Char(6),
Soluong int )

-- Câu 3: Trong Table HoaDon, sửa cột DienGiai thành nvarchar(100)
ALTER TABLE HoaDon 
	ALTER COLUMN DienGiai nvarchar(100)
-- Câu 4: Thêm vào bảng SanPham cột TyLeHoaHong float
ALTER TABLE SanPham
	ADD TyleHoaHong float
--Câu 5: Xóa cột NgayNhap trong bảng SanPham
ALTER TABLE SanPham
	DROP COLUMN DVT
--Câu 6: Tạo các ràng buộc khóa chính và khóa ngoại cho các bảng trên

ALTER TABLE SanPham
	ADD  NgayNhap date

/*
thêm ràng buộc
ALTER TABLE HoaDon
ALTER COLUMN MaHD char(6) not null
ALTER TABLE ChiTietHD
Alter column Masp char(6) not null*/

-- Khóa chính
ALTER TABLE SanPham ADD CONSTRAINT PK_SanPham 
	PRIMARY KEY (MaSp)
ALTER TABLE HoaDon ADD CONSTRAINT PK_HoaDon
	PRIMARY KEY (MaHD)
ALTER TABLE KhachHang ADD CONSTRAINT PK_KhachHang
	PRIMARY KEY (MaKH)
ALTER TABLE ChiTietHD ADD CONSTRAINT PK_ChiTietHD
	PRIMARY KEY (MaHD, Masp)

-- Khóa phụ 
ALTER TABLE HoaDon ADD CONSTRAINT FK_HoaDon
	FOREIGN Key (MaKH) REFERENCES KhachHang(MaKH)
	ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE ChiTietHD ADD CONSTRAINT FK_CHiTietHD_MAHD
	FOREIGN KEY (MaHD) REFERENCES HoaDon (HoaDon)
	ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE ChiTietHD ADD CONSTRAINT FK_ChiTietHD_MaSP
	FOREIGN KEY (MaSP) REFERENCES SanPham (SanPham)
	ON DELETE CASCADE ON UPDATE CASCADE

-- Câu 7: Thêm vào bảng HoaDon các ràng buộc sau
	-- NgayGiao >= NgayLap
ALTER TABLE HoaDon ADD CONSTRAINT CK_HoaDon_MaHD
	Check (NgayGiao >= NgayLap)
ALTER TABLE HoaDon ADD CONSTRAINT CK_HoaDon_NgayGiao
	CHECK ( MaHD Like '[A-Z]{2}/d{4,}')
ALTER TABLE HoaDon ADD CONSTRAINT CK_HoaDon_NgayLap
	DEFAULT GETDATE() FOR NgayLap


-- Câu 8:  Thêm vào bảng Sản phẩm các ràng buộc sau:
	-- SoLuongTon chỉ nhập từ 0 đến 500
ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_SoLuongTon
	CHECK (SoLuongTon BETWEEN 0 AND 500)
	-- DonGiaNhap lon hon 0
ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_DonGiaNhap
	CHECK (DonGiaNhap > 0)
	-- Giá trị mặc định cho NgayNhap là ngày hiện hành 
ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_NgayNhap 
	DEFAULT GETDATE() FOR NgayNhap
	-- DVT chỉ nhập vào các giá trị 'KG', 'Thùng', 'Hộp', 'Cái'
   ALTER TABLE SanPham
        ALTER COLUMN DVT NCHAR(10)
ALTER TABLE SanPham ADD CONSTRAINT CK_SanPham_DVT
	CHECK (DVT IN (N'KG',N'Thùng',N'Hộp',N'Cái'))

-- 9 Dùng lệnh T-SQL nhập dữ liệu vào 4 table trên, dữ liệu tùy ý, chú ý các ràng buộc của mỗi Table

    INSERT INTO SanPham (MaSP, TenSP, NgayNhap, DVT, SoLuongTon, DonGiaNhap, TyLeHoaHong) 
    VALUES ('SP01', 'Dau Goi', '20210201', N'Cái', 100, 25000, 1),
            ('SP02', 'Dau Xa', '20210201', N'Cái', 120, 27000, 1),
            ('SP03', 'Xa Phong', '20210201', N'Hộp', 300, 20000, 2),
            ('SP04', 'Mi 3 Mien', '20210201', N'Thùng', 500, 3000, 5)

    -- Table Khách hàng
    INSERT INTO KhachHang (MaKH, TenKH, DiaCHi, DienThoai)
    VALUES  ('KH01', N'Trần Minh Quang', N'120 Trường Chinh, Q.12, TP.HCM', '0312345678'),
            ('KH02', N'Nguyễn Thị Anh', N'143 Quang Trung, Q.GV, TP.HCM', '0909091234'),
            ('KH03', N'Võ Quang Hùng', N'23 Nguyễn Thái Bình, Q.GV, TP.HCM', '0707123123'),
            ('KH04', N'Bùi Duy Anh', N'03 Quang Trung, Q.GV, TP.HCM', '0505050505')

    -- Table HoaDon
    INSERT INTO HoaDon (MaHD, NgayLap, NgayGiao, MaKH, DienGiai)
    VALUES  ('HD0101', '20210202', '20210202', 'KH01', N'Giao Nhanh'),
            ('HD0102', '20210202', '20210215', 'KH03', N'Giao Thường'),
            ('HD0103', '20210202', '20210203', 'KH02', N'Giao Nhanh'),
            ('HD0104', '20210202', '20210302', 'KH01', N'Giao Thường')

    -- Table ChiTietHD
    INSERT INTO ChiTietHD (MaHD, MaSP, SoLuong)
    VALUES  ('HD0101', 'SP01', 324),
            ('HD0102', 'SP02', 424),
            ('HD0103', 'SP04', 243),
            ('HD0104', 'SP03', 13)