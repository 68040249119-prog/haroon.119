--MiniMart

--สำรวจข้อมูล Receipts , Details , Employees , Products
select * from Receipts
select * from Details
select * from Employees
select * from Products
--เป้าหมาย ต้องการสร้างรายการจำหน่ายสินค้า ผู้ขายคือ วุฒิศักดิ์
--สินค้าที่ขาย ได้แก่ ดินสอ 5 แท่ง และ ยางลบ 4 ก้อน

--เริ่มต้น Transaction ใช้ในการ+-คอมมาร
Begin Transaction

--1. เพิ้มใบเสร็จใหม่ Receipts ยังไม่มียอด  TotalCash
Insert into Receipts(ReceiptID,EmployeeID,TotalCash)
            Values(getdate(),4,0)
--2. เพิ่มรายการสินค้าใน Details 2 รายการ 
insert into Details(ReceiptID,ProductID,UnitPrice,Quantity)
 values (11,1,17,5) --ดินสอ
insert into Details(ReceiptID,ProductID,UnitPrice,Quantity)
 values(11,2,17,4) -- ยางลบ
--3. ปรับปรุวยอดขาย TotalCash
update Receipts set TotalCash = 
(select sum (unitprice*quantity) from Details
where  ReceiptID = 11)
where receiptID = 11
--4.ปรับปรุงจำนวนสินค้า ดินสอ -5 ยางลบ -4
update products set UnitsInStock = UnitsInStock - 5 where productID = 1 --ดินสอ
update products set UnitsInStock = UnitsInStock - 4 where productID = 2 --ยางลบ

--จบการทำงาน
commit

select * from Receipts order by ReceiptID desc -- ตรวจสอบข้อมูลใบเสร็จใบใหม่ล่าสุด
select * from Details where ReceiptID = 11 -- ตรวจสอบรายการสินค้าในใบเสร็จ


------------------------------------------------------------------------------------

--Northwind

-- เริ่ม Transaction และสร้าง Order: เริ่มต้นโดยการใช้ฐานข้อมูล เปิด Transaction และเพิ่มข้อมูลคำสั่งซื้อลงในตาราง Orders
-- เริ่ม Transaction และสร้าง Order
USE Northwind;
BEGIN TRANSACTION;

INSERT INTO Orders
  (CustomerID, EmployeeID, OrderDate, RequiredDate, Freight)
VALUES
  ('ALFKI', 1, GETDATE(), DATEADD(DAY, 7, GETDATE()), 50.00);

-- ดึงเลข OrderID ล่าสุดที่เพิ่งสร้าง
-- เพิ่มสินค้าชิ้นที่ 1 ใน Order (เปลี่ยนเลข 11078 เป็นเลขที่คุณได้)
INSERT INTO [Order Details]
  (OrderID, ProductID, UnitPrice, Quantity, Discount)
SELECT
  11078, ProductID, UnitPrice, 2, 0
FROM Products
WHERE ProductID = 1;

-- เพิ่มสินค้าชิ้นที่ 2 ใน Order (เปลี่ยนเลข 11078 เป็นเลขที่คุณได้)
INSERT INTO [Order Details]
  (OrderID, ProductID, UnitPrice, Quantity, Discount)
SELECT
  11078, ProductID, UnitPrice, 3, 0
FROM Products
WHERE ProductID = 2;

-- ตรวจสอบข้อมูลก่อน COMMIT (เปลี่ยนเลข 11078 เป็นเลขที่คุณได้)
SELECT * FROM Orders WHERE OrderID = 11078;
SELECT * FROM [Order Details] WHERE OrderID = 11078;

-- ยืนยันการบันทึกข้อมูลอย่างถาวร
COMMIT;

---เริ่ม Transaction ใหม่และสร้าง Order: ทดลองสร้างคำสั่งซื้อใหม่อีกครั้ง
USE Northwind;
BEGIN TRANSACTION;

INSERT INTO Orders
  (CustomerID, EmployeeID, OrderDate, RequiredDate, Freight)
VALUES
  ('ALFKI', 1, GETDATE(), DATEADD(DAY, 7, GETDATE()), 75.00);

SELECT SCOPE_IDENTITY() AS RollbackOrderID;

---เพิ่มสินค้าลงใน Order: เพิ่มรายการสินค้าทั้ง 2 ชิ้นเข้าไปในคำสั่งซื้อ (แทนที่ <RollbackOrderID> ด้วยตัวเลขที่ได้จากขั้นตอนที่ 2)
-- เพิ่มสินค้า Product 1
INSERT INTO [Order Details]
  (OrderID, ProductID, UnitPrice, Quantity, Discount)
SELECT
  <RollbackOrderID>, ProductID, UnitPrice, 1, 0
FROM Products
WHERE ProductID = 1;

-- เพิ่มสินค้า Product 2
INSERT INTO [Order Details]
  (OrderID, ProductID, UnitPrice, Quantity, Discount)
SELECT
  <RollbackOrderID>, ProductID, UnitPrice, 2, 0
FROM Products
WHERE ProductID = 2;

SELECT * FROM Orders WHERE OrderID = <RollbackOrderID>;
SELECT * FROM [Order Details] WHERE OrderID = <RollbackOrderID>;

ROLLBACK;

SELECT * FROM Orders WHERE OrderID = <RollbackOrderID>;
SELECT * FROM [Order Details] WHERE OrderID = <RollbackOrderID>;
