--Lab ในชั้นเรียนวันที่ 13 สิงหาคม 2569
--ใช้ฐานข้อมูล Northwind

--1. ต้องการข้อมูล รหัสใบสั่งซื้อ ยอดเงินรวมที่หักลบแล้ว จากแต่ละใบสั่งซื้อ ทั้งหมด เรียงลำดับตามยอดเงิน จากใากไปน้อย
     select orderID , Format(sum(unitprice * quantity * (1-discount)),'N2') TotalCash
     from [Order Details]
     group by orderID
     order by sum(unitprice * quantity * (1-discount)) desc

     select orderID , Format(sum(unitprice * quantity * (1-discount)),'N2') TotalCash
     from [Order Details]
     group by orderID
     order by 2 desc



--2. ต้องการ ชื่อประเภท ของผู้แทนจำหน่าย (suppliers) และจำนวนผู้แทนจำหน่ายในแต่ละประเทศ 
--   แสดมาเฉพาะรายการที่ผู้แทนจำหน่ายมีมากกว่า 1 ราย
  select country, count(*) ToralSuppliers
  from Suppliers
  group by country
  having count(*) >1
    
--3. รหัสสินค้า จำนวนรวมทั้งหมดที่ขายได้ ราคาสูงสุดที่ขายได้ แสดงเฉพาะสินค้าที่ขายได้รวมมากกว่า 1500 ขึ้นไป
-- แสดงเฉพาะสินค้าที่ขายได้รวมมากกว่า 1000 ชิ้น
     select ProductID , sum(Quantity) TotalQuantity
     from [Order Details] 
     group by ProductID
     having sum (quantity)>1500
     order by sum(Quantity) desc

     select ProductID , sum(Quantity) TotalQuantity
     from [Order Details] 
     group by ProductID
     having sum (quantity)>1000
     order by sum(Quantity) desc

     select ProductID , sum(Quantity) TotalQuantity
     from [Order Details]
     where discount  >0
     group by ProductID
     having sum (quantity)>500
     order by  ProductID

--การ Query ข้อมูล จากหลายตาราง (Join Table)

select * from Products
select * from Categories
--Inner Join
select * 
from products Inner join Categories
on products.categoryID = Categories.CategoryID

-------------------------------------------------------------------------------

--ต้องการชื่อหมวดหมู่สินค้า ชื่อหมวดหมู่าสินค้า รหัสสินค้า ชื่อสินค้า ราคา
--โดยเรียงลำดับตามหมวดหมู่สินค้า และ ราคาสูงไปต่ำ

select  products.categoryID , CategoryName,ProductID,ProductName,UnitPrice
from products Inner join Categories
on products.categoryID = Categories.CategoryID
Order by CategoryID asc , Unitprice desc
--------------------------------------------------------------------------------
select p.CategoryID , CategoryName,ProductID,ProductName,UnitPrice
from products as p Inner join Categories as c
on p.categoryID = c.CategoryID
Order by CategoryID asc , Unitprice desc
--------------------------------------------------------------------------------
select p.CategoryID , CategoryName,ProductID,ProductName,UnitPrice
from products  p Inner join Categories  c
on p.categoryID = c.CategoryID
Order by CategoryID asc , Unitprice desc

--ต้องการชิ้อผู้รับผิดชอบการสั่งซื้อแต่ละรายการ

select * from orders
select * from Employees

-- รหัสใบสั่งซื้อ วันสั่งซื้อ วันที่รับสินค้า ประเทศปลายทาง ชื่อ-นามสกุลพนักงานผู้รับผิดชอบ

select o.OrderID , o.OrderDate , o.ShippedDate, o.ShipCountry,
       e.FirstName + space(2) + e.LastName SaleMan
from orders o inner join Employees e on o.EmployeeID = e.EmployeeID
-----------------------------------------------------------------------------------
select c.CategoryID , c.CategoryName ,
p.ProductID , p.ProductName , p.UnitPrice,
s.Country
from Products p inner join Categories c on p.CategoryID = c.CategoryID
inner join Suppliers s on p.SupplierID = s. SupplierID
where s.Country in ('USA','Mexico','Canada')
order by Country
----------------------------------------------------------------------------------
--แบบฝึกหัดการ Join ตาราง
--1. ต้องการ รหัสบริษัทขนส่ง   ชื่อของบริษัทขนส่ง  จำนวนใบสั่งซื้อที่เกี่ยวข้อง  ยอดรวมค่าขนส่ง
select  s.SHipperID , CompanyName ,
count(*) TotalOrders, sum(o.Freight ) sumFreight
from Shippers s join  orders o on s.ShipperID = o.ShipVia
group by s.ShipperID , CompanyName


--2.รหัสใบสั่งซื้อ วันที่สั่งซื้อ ชื่อบริษัทลูกค้า ให้แสดงเฉพาะ ลูกค้าที่มีอยู่ในประเทศ USA
select orderID , format(o.OrderDate ,'d','en-gb') as [order date],
c.CompanyName
from orders o join customers c on o.customerID = c.customerID
where c.Country = 'USA'

--3. รหัสผนักงาน ชื่อนามสกุล จำนวนใบสั่งซื้อเกี่ยวข้อง
select e.EmployeeID , firstName + space(2) + lastname EmployeeName,
count(*) TotalOrders
from Employees e join orders o on e.EmployeeID = o.EmployeeID
group by e.EmployeeID , firstName + space(2) + lastname

--4. รหัสใบสั่งซื้อ วันที่สั่งซื้อ ชื่อพนักงาน ชื่อบริษัทลูกค้า ชื่อบริษัทขนส่ง
--   ยอดรวมในใบสั่งซื้อ เฉพาะรายการที่ขายในปี 1997 เรียงตามลำดับ ยอดเงินจากมากไปน้อบ
select o.OrderID , format(o.OrderDate ,'d','en-gb') OrderDay,
e.firstName SaleManName , c.CompanyName CustomerCompany,
s.CompanyName SHipperCompany,
sum(od.unitprice*od.quantity*(1-discount)) totalCash
from orders o inner join Employees e on o.EmployeeID = e.EmployeeID
              inner join customers c on o.CustomerID = c.CustomerID
              inner join [Order Details] od on o.OrderID = od.OrderID
              inner join Shippers s on o. ShipVia = s.ShipperID
where year(orderdate) = 1997
group by o.OrderID , format(o.OrderDate,'d','en-gb'),
firstName , c.CompanyName , s.CompanyName
--ยอดรวมในใบสั่งซื้อ เฉพาะรายการที่ขายในปี 1997 เรียงตามลำดับ ยอดเงินจากมากไปน้อย
---------------------------------------------------------------------------------------

--ต้องการ รหัสสินค้า ชื่อสินค้า จำนวนที่ขายได้ เฉพาะสินค้าที่ขายดีที่สุด 5 อันดับแรก ในปี 1997
select top 5 p.ProductID , p.ProductName,sum(quantity) TotalQuantity
from Products p join [Order Details] od on p.ProductID = od.ProductID
                join orders o on o.orderID = od.orderID
where year(orderdate) = 1997
group by p.ProductID, p.ProductName
order by 3 desc

--ข้อมูล ชื่อบริษัทลูกค้า และประเทศลูกค้า ที่ซื้อสินค้าที่มาจ่ากบริษัท Exotic Liquids

--ชื่อบริษัทลูกค้าที่ซื้อสินค้าหมวดหมู่หมวดหมู่ Seafood
