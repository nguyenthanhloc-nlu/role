﻿--------TRIGGER---------
------------------------
USE DATABASE_STORE
GO
/*TẠO TRIGGER INSERT, UPDATE SAN PHAM PHẢI CÓ ID_MAU_SAC TRONG TABLE MAU_SAC
,ID_ROM CÓ TRONG TABLE ROM VÀ ID _DONG_SAN_PHAM CÓ TRONG TABLE DONG_SAN_PHAM*/
CREATE TRIGGER INSERT_UPDATE_SP ON SAN_PHAM FOR INSERT,UPDATE
AS
DECLARE @ID_MS INT ,@ID_ROM INT ,@ID_DONG_SP INT ;
SET @ID_MS =(SELECT ID_MAU_SAC FROM INSERTED)
SET @ID_ROM =(SELECT ID_BO_NHO_TRONG  FROM INSERTED)
SET @ID_DONG_SP =(SELECT ID_DONG_SAN_PHAM FROM INSERTED)

IF((SELECT COUNT(ID) FROM MAU_SAC WHERE ID=@ID_MS)=0)
BEGIN 
RAISERROR ('ID MAU SAC KHONG TON TAI ',10,1);
	ROLLBACK
END;
IF((SELECT COUNT(ID) FROM ROM WHERE ID=@ID_ROM)=0)
BEGIN 
RAISERROR ('ID ROM KHONG TON TAI ',10,1);
	ROLLBACK
END;
IF((SELECT COUNT(ID) FROM DONG_SAN_PHAM WHERE ID=@ID_DONG_SP)=0)
BEGIN 
RAISERROR ('ID DONG SAN PHAM KHONG TON TAI ',10,1);
	ROLLBACK
END;
GO
/* TẠO TRIGGER DELETE SAN PHAM NẾU NHƯ SẢN PHẨM ĐÃ KHÔNG CÒN TRONG KHO
KHI DELETE SAN PHAM NÀO THÌ DELETE LUÔN HÌNH_SAN_PHAM VÀ HINH_MO_TA_SAN_PHAM ĐÓ*/
CREATE TRIGGER DELETE_SP ON SAN_PHAM FOR DELETE
AS
DECLARE @ID_SP INT ,@SUM_SP INT
SET @ID_SP =(SELECT ID FROM DELETED)
SET @SUM_SP = (SELECT SUM(SO_LUONG_CON_LAI) FROM TON_KHO WHERE ID=@ID_SP)
IF(@SUM_SP>0)
BEGIN 
RAISERROR ('SAN PHAM VAN CON',10,1);
	ROLLBACK
END;
ELSE
BEGIN
DELETE FROM HINH_SANPHAM WHERE ID_SAN_PHAM=@ID_SP
DELETE FROM HINH_MOTA_SANPHAM WHERE ID_SAN_PHAM=@ID_SP
END;
GO
-- TẠO TRIGGER INSERT,UPDATE HINH_MO_TA_SAN_PHAM KHI ID_SP PHẢI TỒN TẠI TRONG TABLE SAN_PHAM
CREATE TRIGGER INSERT_HINH_MOTA ON HINH_MOTA_SANPHAM FOR INSERT,UPDATE
AS
DECLARE @ID_SP INT ,@COUNTID INT
SET @ID_SP =(SELECT ID_SAN_PHAM FROM INSERTED)
SET @COUNTID = (SELECT COUNT(ID) FROM SAN_PHAM WHERE ID=@ID_SP)
IF(@COUNTID=0)
BEGIN 
RAISERROR ('ID SAN PHAM KHONG TON TAI ',10,1);
	ROLLBACK
END;
--TẠO TRIGGER INSERT,UPDATE HINH_SAN_PHAM KHI ID_SP PHẢI TỒN TẠI TRONG TABLE SAN_PHAM
GO
CREATE TRIGGER INSERT_HINH ON HINH_SANPHAM FOR INSERT,UPDATE
AS
DECLARE @ID_SP INT ,@COUNTID INT
SET @ID_SP =(SELECT ID_SAN_PHAM FROM INSERTED)
SET @COUNTID = (SELECT COUNT(ID) FROM SAN_PHAM WHERE ID=@ID_SP)
IF(@COUNTID=0)
BEGIN 
RAISERROR ('ID SAN PHAM KHONG TON TAI ',10,1);
	ROLLBACK
END;
-- TẠO TRIGGER INSERT,UPDATE TON_KHO KHI ID_SP PHẢI TỒN TẠI TRONG TABLE SAN_PHAM
GO
CREATE TRIGGER INSERT_KHO ON TON_KHO FOR INSERT,UPDATE
AS
DECLARE @ID_SP INT ,@COUNTID INT
SET @ID_SP =(SELECT ID_SAN_PHAM FROM INSERTED)
SET @COUNTID = (SELECT COUNT(ID) FROM SAN_PHAM WHERE ID=@ID_SP)
IF(@COUNTID=0)
BEGIN 
RAISERROR ('ID SAN PHAM KHONG TON TAI ',10,1);
	ROLLBACK
END;
 --TẠO TRIGGER INSERT,UPDATE CHI_TIET_HOA_DON KHI ID_SP PHẢI TỒN TẠI TRONG TABLE SAN_PHAM
 GO
CREATE TRIGGER INSERT_CTHD ON CHI_TIET_HOA_DON FOR INSERT,UPDATE
AS
DECLARE @ID_SP INT ,@COUNTID INT
SET @ID_SP =(SELECT ID_SAN_PHAM FROM INSERTED)
SET @COUNTID = (SELECT COUNT(ID) FROM SAN_PHAM WHERE ID=@ID_SP)
IF(@COUNTID=0)
BEGIN 
RAISERROR ('ID SAN PHAM KHONG TON TAI ',10,1);
	ROLLBACK
END;
--TẠO TRIGGER INSERT,UPDATE DONG_SP KHI ID_LOAI_SP PHẢI TỒN TẠI TRONG TABLE LOAI_SAN_PHAM
 GO
CREATE TRIGGER INSERT_UPDATE_DONG_SP ON DONG_SAN_PHAM FOR INSERT, UPDATE
AS
DECLARE @ID_LOAI INT ,@COUNTID INT
SET @ID_LOAI =(SELECT ID_LOAI_SAN_PHAM FROM INSERTED)
SET @COUNTID = (SELECT COUNT(ID) FROM LOAI_SAN_PHAM WHERE ID=@ID_LOAI)
IF(@COUNTID=0)
BEGIN 
RAISERROR ('ID LOAI SAN PHAM KHONG TON TAI ',10,1);
	ROLLBACK
END;

-- TẠO TRIGGER DELETE MAU_SAC KHI ID_MAU_SAC KHÔNG CÒN TỒN TABLE SAN_PHAM
GO
CREATE TRIGGER DELETE_MAU_SAC ON MAU_SAC FOR DELETE
AS
DECLARE @ID_MS INT ,@COUNTID INT
SET @ID_MS =(SELECT ID FROM DELETED)
SET @COUNTID = (SELECT COUNT(ID) FROM SAN_PHAM WHERE ID_MAU_SAC=@ID_MS)
IF(@COUNTID>0)
BEGIN 
RAISERROR ('MAU SAC VAN CON TRONG SAN PHAM',10,1);
	ROLLBACK
END;
-- TẠO TRIGGER DELETE ROM KHI ID_ROM KHÔNG CÒN TỒN TABLE SAN_PHAM
GO
CREATE TRIGGER DELETE_ROM ON ROM FOR DELETE
AS
DECLARE @ID_ROM INT ,@COUNTID INT
SET @ID_ROM =(SELECT ID FROM DELETED)
SET @COUNTID = (SELECT COUNT(ID) FROM SAN_PHAM WHERE ID_BO_NHO_TRONG=@ID_ROM)
IF(@COUNTID>0)
BEGIN 
RAISERROR ('ROM VAN CON TRONG SAN PHAM',10,1);
	ROLLBACK
END;

-------------- PROCEDURE--------------
--------------------------------------
--TẠO PROCEDURE
-- INSERT
----ID KH TỒN TẠI
----ID SP TỒN TẠI
----SL PHẢI <SL TRONG TỒN KHO
GO
CREATE PROCEDURE SP_INSERT_GH(@ID_KH INT,@ID_SP INT , @SL INT) AS
DECLARE @COUNT_ID_SP INT,@COUNT_ID_KH INT,@SL_TON_KHO INT;
SET @COUNT_ID_KH = (SELECT COUNT(ID) FROM NGUOI_DUNG WHERE ID=@ID_KH);
SET @COUNT_ID_SP = (SELECT COUNT(ID) FROM SAN_PHAM WHERE @ID_SP=ID);
SET @SL_TON_KHO = (SELECT SO_LUONG_CON_LAI FROM TON_KHO WHERE ID_SAN_PHAM=@ID_SP);

BEGIN 
IF(@COUNT_ID_SP>0)
IF(@COUNT_ID_KH>0)
IF(@SL<=@SL_TON_KHO)
INSERT INTO GIO_HANG VALUES(@ID_KH,@ID_SP , @SL);
ELSE
PRINT 'SL<=SL TỒN KHO';
ELSE
PRINT ' ID KH KHÔNG TỒN TẠI';
ELSE
PRINT 'ID SP KHÔNG TỒN TẠI';
END;
----TẠO PROCEDURE
--UPDATE SỐ LƯỢNG SP TRONG TABLE GIO_HANG
----ID KH TỒN TẠI
----ID SP TỒN TẠI
----SL PHẢI <SL TRONG TỒN KHO
GO
CREATE PROCEDURE SP_UPDATE_GH_SL(@ID_KH INT,@ID_SP INT , @SL INT) AS
DECLARE @COUNT_ID_SP INT,@COUNT_ID_KH INT,@SL_TON_KHO INT;
SET @COUNT_ID_KH = (SELECT COUNT(ID_KHACH_HANG) FROM GIO_HANG WHERE ID_KHACH_HANG=@ID_KH);
SET @COUNT_ID_SP = (SELECT COUNT(ID_SAN_PHAM) FROM GIO_HANG WHERE ID_SAN_PHAM=@ID_SP);
SET @SL_TON_KHO = (SELECT SO_LUONG_CON_LAI FROM TON_KHO WHERE ID_SAN_PHAM=@ID_SP);

BEGIN 
IF(@COUNT_ID_SP>0)
IF(@COUNT_ID_KH>0)
IF(@SL<=@SL_TON_KHO)
UPDATE GIO_HANG
SET SO_LUONG =@SL
WHERE ID_KHACH_HANG = @ID_KH AND ID_SAN_PHAM=@ID_SP;
ELSE
PRINT 'SL<=SL TỒN KHO';
ELSE
PRINT ' ID KH KHÔNG TỒN TẠI';
ELSE
PRINT 'ID SP KHÔNG TỒN TẠI';
END;
 --TABLE GIAO_HANG
 ----INSERT GIAO HANG
 GO
 CREATE PROCEDURE INSERT_GIAO_HANG (@ID_GH INT , @ID_HD INT , @DC_GH NVARCHAR(50),@DATE_GH DATE) AS
 BEGIN
 IF(@DATE_GH>GETDATE())
 INSERT INTO GIAO_HANG VALUES(@ID_GH , @ID_HD  , @DC_GH ,@DATE_GH )
 ELSE
 PRINT 'NGAY KHONG HOP LE';
 END
 --TABLE DONG_SP
 ----DELETE DONG SP
 GO 
 CREATE PROCEDURE DELETE_DONG_SP(@ID_DONG_SP INT) AS
 BEGIN
 IF((SELECT COUNT(ID) FROM SAN_PHAM WHERE ID_DONG_SAN_PHAM=@ID_DONG_SP)>0)
 PRINT 'DONG SAN PHAM VAN CON DANG CÓ TREN SP';
 ELSE
 DELETE DONG_SAN_PHAM WHERE ID=@ID_DONG_SP
 END;
 --CHO BIẾT ID NGƯỜI DÙNG, TÊN NGƯỜI DÙNG BẢO HÀNH CỦA NGƯỜI DÙNG TRONG THÁNG
 GO
CREATE PROCEDURE BH @IDND INT, @TND NVARCHAR , @IDSP INT AS
BEGIN
SELECT NGUOI_DUNG.ID, NGUOI_DUNG.TEN_NGUOI_DUNG, BAO_HANH.ID_SAN_PHAM 
FROM NGUOI_DUNG
JOIN BAO_HANH ON NGUOI_DUNG.ID = BAO_HANH.ID
WHERE NGUOI_DUNG.ID = @IDND AND NGUOI_DUNG.TEN_NGUOI_DUNG = @TND AND BAO_HANH.ID_SAN_PHAM = @IDSP;
END;
GO

--LIỆT KÊ NGƯỜI DÙNG CÓ TRỊ GIÁ HÓA ĐƠN CAO NHẤT
CREATE PROCEDURE TRIGIAMAX (@ID_KH INT, @TENKH NVARCHAR) AS
BEGIN
SELECT ND.ID, HD.ID FROM NGUOI_DUNG ND, HOA_DON HD
WHERE ND.ID = @ID_KH AND ND.TEN_NGUOI_DUNG = @TENKH AND HD.TRI_GIA IN (SELECT MAX(HD.TRI_GIA) FROM HOA_DON WHERE ND.ID = HD.ID)
END;
 --TẠO PROCEDURE GỒM THONG TIN TẤT CẢ SP CÓ SL TỒN KHO TRÊN 20
 GO
 CREATE PROCEDURE SP_ON_20SL
 AS
 SELECT *
 FROM SAN_PHAM S JOIN TON_KHO T ON S.ID = T.ID_SAN_PHAM 
 WHERE T.SO_LUONG_CON_LAI>20
 --TẠO PROCEDURE GỒM THONG TIN CÁC SP CÓ ROM @DUNG_LUONG
 GO
 CREATE PROCEDURE SP_64GB(@DUNG_LUONG VARCHAR(10))
 AS
 SELECT *
 FROM SAN_PHAM S JOIN ROM R ON S.ID_BO_NHO_TRONG = R.ID
 WHERE R.BO_NHO_ROM=@DUNG_LUONG

 --TẠO PROCEDURE GỒM THÔNG TIN CÁC SP ĐƯỢC MUA NHIỀU NHẤT
  GO
 CREATE PROCEDURE SP_BUY_MAX AS
 SELECT *
 FROM SAN_PHAM S JOIN CHI_TIET_HOA_DON C ON S.ID = C.ID_SAN_PHAM
 WHERE C.SO_LUONG = (SELECT MAX(SO_LUONG) FROM CHI_TIET_HOA_DON)
 --TẠO PROCEDURE  THÔNG TIN TOP 5 CÁC SP  CÓ MỨC GIÁ CAO NHẤT
 GO
 CREATE PROCEDURE SP_TOP5_GIA
 AS
 SELECT TOP 5 *
 FROM SAN_PHAM
 ORDER BY  GIA_SAN_PHAM DESC 
 -- TẠO PROCEDURE DANH SÁCH NHỮNG SP THÊM VÀO GIỎ HÀNG
 GO
 CREATE PROCEDURE SP_ADD_GH AS
 SELECT *
 FROM SAN_PHAM S JOIN GIO_HANG G ON S.ID = G.ID_SAN_PHAM
 --TẠO PROCEDURE DANH SÁCH CÁCH SẢN PHẨM KHÔNG BÁN ĐƯỢC--

GO
CREATE PROCEDURE P_SPCBD(@MONTH INT)
AS
SELECT S.ID,D.TEN_DONG_SAN_PHAM,S.GIA_SAN_PHAM 
FROM DONG_SAN_PHAM D JOIN SAN_PHAM S ON S.ID_DONG_SAN_PHAM=D.ID  
WHERE S.ID NOT IN (SELECT ID_SAN_PHAM FROM CHI_TIET_HOA_DON) 
 -----------FUNCION------------
 ------------------------------
 /* TẠO HÀM F_LIST CÓ 2 THAM SỐ LÀ @NGAY1 VÀ @NGAY2 CHO BIẾT DANH SÁCH CÁC SP ĐÃ ĐƯỢC BÁN TRONG
KHOẢNG THỜI GIAN TRÊN. DANH SÁCH GỒM CÁC THUỘC TÍNH: ID, GIA, SOLUONG.*/
 GO
 CREATE FUNCTION F_LIST(@NGAY1 DATE,@NGAY2 DATE )
 RETURNS TABLE
 AS
RETURN(SELECT S.ID, S.GIA_SAN_PHAM,SUM(C.SO_LUONG) AS SOLUONG
 FROM SAN_PHAM S JOIN CHI_TIET_HOA_DON C ON S.ID= C.ID_SAN_PHAM JOIN HOA_DON H ON H.ID= C.ID 
 WHERE H.NGAY_LAP_HOA_DON>@NGAY1 AND H.NGAY_LAP_HOA_DON<@NGAY2
 GROUP BY S.ID,S.GIA_SAN_PHAM)
 /*TẠO HÀM F_KH HIỂN THỊ THÔNG TIN CỦA KHÁCH HÀNG CÓ GIAO DỊCH VỚI CỬA HÀNG NHIỀU NHẤT (CĂN CỨ
VÀO SỐ LẦN MUA HÀNG).GỒM:ID, TÊN ,SDTM SLGD */
GO
CREATE FUNCTION F_KH()
RETURNS  TABLE
AS
RETURN(SELECT TOP 1 ID_KHACH_HANG,N.TEN_NGUOI_DUNG,N.SDT, COUNT(ID_KHACH_HANG) AS GDMAX
FROM HOA_DON H JOIN NGUOI_DUNG N ON H.ID_KHACH_HANG=N.ID  GROUP BY ID_KHACH_HANG ORDER BY GDMAX DESC);
GO
/*TẠO HÀM F_SP HIỂN THỊ THÔNG TIN CỦA SP CÓ SL TỒN KHO NHIỀU NHẤT , GỒM : ID , TEN , GIA*/
CREATE FUNCTION F_SP()
RETURNS  TABLE
AS
RETURN(SELECT S.ID,D.TEN_DONG_SAN_PHAM,S.GIA_SAN_PHAM
FROM DONG_SAN_PHAM D JOIN SAN_PHAM S ON D.ID=S.ID JOIN TON_KHO T ON S.ID = T.ID_SAN_PHAM 
WHERE T.SO_LUONG_CON_LAI=(SELECT MAX(SO_LUONG_CON_LAI) FROM TON_KHO))
/*TẠO HÀM F_XLKH NHẬN VÀO THAM SỐ @ID_KHACH_HANG, TÍNH TỔNG TIỀN KHÁCH HÀNG ĐÃ TRẢ
. SAU ĐÓ HÀM TRẢ VỀ KẾT QUẢ XẾP LOẠI KHÁCH HÀNG NHƯ SAU:
- NẾU TONGTIEN>50.000.000 : XẾP LOẠI “KH VIP”
- NẾU TONGTIEN>15.000.000 : XẾP LOẠI “KH THÀNH VIÊN”
- NẾU TONGTIEN<=15.000.000 : XẾP LOẠI “KH THÂN THIẾT”*/
GO 
CREATE FUNCTION F_XLKH(@ID_KH INT)
RETURNS  VARCHAR(20) 
AS
 BEGIN
 DECLARE @TONGTIEN REAL,@XEPLOAI VARCHAR(20)
 SET @TONGTIEN=(SELECT SUM(TRI_GIA) FROM HOA_DON WHERE ID_KHACH_HANG=@ID_KH)
 IF(@TONGTIEN>50000000)
 SET @XEPLOAI ='KH VIP'
 IF(@TONGTIEN>15000000)
 SET @XEPLOAI= 'KH THÀNH VIÊN'
 ELSE
 SET @XEPLOAI= 'KH THÂN THIẾT'
 RETURN @XEPLOAI;
 END;
/*THÔNG TIN NHỮNG SẢN PHẨM ĐÃ ĐƯỢC BÁN HẾT TRONG KHO */
GO
CREATE FUNCTION F_SPBH()
RETURNS  TABLE
AS
RETURN(SELECT S.ID,D.TEN_DONG_SAN_PHAM,S.GIA_SAN_PHAM 
FROM DONG_SAN_PHAM D JOIN SAN_PHAM S ON S.ID_DONG_SAN_PHAM=D.ID JOIN TON_KHO T ON S.ID= T.ID_SAN_PHAM WHERE T.SO_LUONG_CON_LAI=0)
/*DANH SÁCH CÁC SẢN PHẨM CÓ GIÁ TỪ @GIA1  -  @GIA2*/
GO
CREATE FUNCTION F_SP_GIA(@GIA1 REAL , @GIA2 REAL)
RETURNS  TABLE
AS
RETURN(SELECT * FROM SAN_PHAM WHERE GIA_SAN_PHAM>@GIA1 AND GIA_SAN_PHAM<@GIA2)
/*TÍNH DOANH THU CỦA @YEAR*/
GO 
CREATE FUNCTION F_DOANH_THU(@YEAR INT)
RETURNS REAL
AS
BEGIN
DECLARE @DOANHTHU REAL
SET @DOANHTHU=(SELECT SUM(TRI_GIA) AS DOANHTHU FROM HOA_DON WHERE YEAR(NGAY_LAP_HOA_DON) =@YEAR)
RETURN(@DOANHTHU)
END;
--TẠO FUNCTION CHO BIẾT SỐ LƯỢNG NGƯỜI DÙNG THEO ĐỊA CHỈ BẤT KỲ NHẬN VÀO TỪ THAM SỐ VỚI ĐIỀU KIỆN LÀ 
--NGƯỜI DÙNG CÓ TỔNG SỐ TRỊ GIÁ HÓA ĐƠN TỪ TRƯỚC ĐẾN NAY TỪ 20 TRIỆU TRỞ LÊN
GO
CREATE FUNCTION COUNT_CUSTOMER_WITH_ADDRESS (@ADD VARCHAR(200))
RETURNS INT
AS 
BEGIN
DECLARE @COUNT INT = 0
SELECT @COUNT = COUNT(*) FROM (SELECT HOA_DON.ID FROM NGUOI_DUNG,HOA_DON
WHERE HOA_DON.ID=NGUOI_DUNG.ID AND NGUOI_DUNG.DIA_CHI= @ADD
GROUP BY HOA_DON.ID HAVING SUM(HOA_DON.TRI_GIA)>=20) AS TEMP
RETURN @COUNT
END
  /*TẠO HÀM F_LIST_HD DANH SÁCH CÁC HÓA ĐƠN CỦA KHÁCH HÀNG CÓ MÃ @ID_KH
  -GỒM : ID ,TRI GIA,NGAY LAP HOA DON*/
  GO
  CREATE FUNCTION LIST_HD(@ID_KH INT)
  RETURNS TABLE
  AS
	RETURN(SELECT ID,TRI_GIA,NGAY_LAP_HOA_DON
	FROM HOA_DON
	WHERE ID_KHACH_HANG=@ID_KH)	
/*TẠO HÀM F_LIST_SP_TK DANH SÁCH CÁC SẢN PHẨM CÒN TỒN KHO
- GỒM : ID, TÊN,TRỊ GIÁ , SỐ LƯỢNG*/
GO
  CREATE FUNCTION LIST_SP_TK()
  RETURNS TABLE
  AS
	RETURN(SELECT S.ID,D.TEN_DONG_SAN_PHAM,S.GIA_SAN_PHAM,T.SO_LUONG_CON_LAI
FROM DONG_SAN_PHAM D JOIN SAN_PHAM S ON S.ID_DONG_SAN_PHAM=D.ID JOIN TON_KHO T ON S.ID= T.ID_SAN_PHAM WHERE T.SO_LUONG_CON_LAI>0)
	