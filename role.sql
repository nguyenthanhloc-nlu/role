
-- tạo login --
CREATE LOGIN thanhloc
WITH PASSWORD = '123456'

-- tạo user -- 
CREATE USER user1 FOR LOGIN thanhloc

-- xóa user -- 
DROP user user1


-- gán quyền "Statement permission" cho user-- 
GRANT CREATE DATABASE, CREATE TABLE TO user1

-- gán quyền "Object permission" -- 
GRANT SELECT, UPDATE, INSERT, DELETE, EXECUTE
ON SAN_PHAM
TO user1


-- tạo role cho phép đọc, sửa 1 bảng sản phẩm -- 
CREATE ROLE SAN_PHAM_ROLE AUTHORIZATION user1

-- xóa role cho phép đọc, sửa 1 bảng sản phẩm -- 
DROP role SAN_PHAM_ROLE


-- gán quyền vào role SAN_PHAM_ROLE
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE
ON DBO.SAN_PHAM
TO SAN_PHAM_ROLE
GO

 -- xóa quyền SELECT, INSERT, UPDATE trên role
REVOKE  SELECT, INSERT, UPDATE
ON DBO.SAN_PHAM
TO SAN_PHAM_ROLE
GO

-- them user vào role
sp_addRoleMember 'quanly', 'user1';

-- thu hồi của user tren role -- 
go
sp_droprolemember 'quanly', 'user1'