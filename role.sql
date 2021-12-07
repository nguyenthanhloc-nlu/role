
-- tạo/xóa user -- 
CREATE LOGIN thanhloc
WITH PASSWORD = '123456'
CREATE USER user1 FOR LOGIN thanhloc
DROP user user1


-- ◦ Statement permission -- 
/*
◦ CREATE DATABASE
◦ CREATE DEFAULT
◦ CREATE PROCEDURE
◦ CREATE RULE
◦ CREATE TABLE
◦ CREATE VIEW
◦ BACKUP DATABASE
◦ BACKUP LOG
*/
GRANT CREATE DATABASE, CREATE TABLE TO user1


-- ◦ Object permission -- 
/*
DELETE table , view 
EXECUTE stored procedure 
INSERT table , view 
SELECT table, view, và column 
UPDATE table, view, và column
*/
GRANT SELECT, UPDATE
ON Employee (emp_fname, emp_lname)
TO user1


--Tạo/xóa/thay đổi role -- 
-- tạo role cho phép đọc, sửa 1 bảng
go
CREATE ROLE quanly AUTHORIZATION user1
DROP role quanly
-- gán quyền vào role
GRANT SELECT, INSERT, UPDATE
ON DBO.SAN_PHAM
TO QUANLY
GO

 -- xóa quyền trên role
REVOKE  SELECT, INSERT, UPDATE
ON DBO.SAN_PHAM
TO QUANLY
GO

-- them user vào role -- 
sp_addRoleMember 'quanly', 'user1';

-- xóa user khỏi role -- 
go
sp_droprolemember 'quanly', 'user1'