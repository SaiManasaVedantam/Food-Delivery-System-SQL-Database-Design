-- Sample SQL Queries covering various models.

-- Find the names of the employees who supervise the most number of deliverers.
SELECT E.First_Name, E.Middle_Name, E.Last_Name, D.AreaMngr_Eid, Count(*)
FROM DELIVERER D, EMPLOYEE E
WHERE D.AreaMngr_Eid = E.Eid
GROUP BY D.AreaMngr_Eid,E.First_Name, E.Middle_Name, E.Last_Name
order by Count(*) DESC LIMIT 1

-- Find the average number of orders placed by a Potential Silver Member.
SELECT AVG(A.CNT) FROM(SELECT COUNT(O.Cust_Id) CNT, O.Cust_Id
FROM ORDERS O, PAYMENT P, CUSTOMER C
WHERE P.Paymentconfirmation_No=O.PaymentConf_No
AND P.Payment_Time >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
AND C.Cid=O.Cust_Id
GROUP BY O.Cust_Id
HAVING CNT>10) A

-- Find all the customers who placed orders of the restaurants that belong to Popular Restaurant Type. Please also report the name of restaurants.
SELECT P.RType, C.First_Name, C.Last_Name, O.Shop_Id ,S.SName
FROM POPULAR_RESTAURANT_TYPE P
inner join RESTAURANT_TYPE RT ON RT.RType=P.RType
inner join SHOP S on S.Shop_Id=RT.Shop_Id
inner join ORDERS O ON O.Shop_Id=S.Shop_Id
inner join CUSTOMER C ON C.Cid=O.Cust_Id

-- Find the names of deliverers who delivered the most orders in the past 1 month.
SELECT E.First_Name,E.Middle_Name,E.Last_Name
FROM (SELECT O.Deliverer_Id AS Did,Count(*)
FROM ORDERS O,PAYMENT P
WHERE P.Paymentconfirmation_No=O.PaymentConf_No
AND P.Payment_Time >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY O.Deliverer_Id
ORDER BY COUNT(*) DESC LIMIT 1) A, EMPLOYEE E
WHERE E.Eid=A.Did

-- Find the customers who have placed orders for all Fast Food restaurants.
SELECT RT.Shop_Id, RT.RType, O.Cust_Id, SH.Name, C.First_Name, C.Last_Name
FROM RESTAURANT_TYPE RT INNER JOIN RESTAURANT R ON RT.Shop_Id=R.Shop_Id
INNER JOIN SHOP SH ON R.Shop_Id=SH.Shop_Id
INNER JOIN ORDERS O ON O.Shop_Id=SH.Shop_Id
INNER JOIN CUSTOMER C ON C.Cid=O.Cust_Id
where RT.RType="FAST FOOD"

-- For each restaurant, list all the customers who placed the order, and the price of each order.
SELECT R.Shop_Id, SH.SName, C.First_Name, C.Middle_Name, C.Last_Name, O.Total_Balance
from RESTAURANT R INNER JOIN SHOP SH ON R.Shop_Id=SH.Shop_Id
INNER JOIN ORDERS O ON R.Shop_Id=O.Shop_Id
INNER JOIN CUSTOMER C ON C.Cid=O.Cust_Id

-- Find the area that has the most number of restaurants located.
SELECT A.Area, COUNT(A.Shop_Id)
FROM SHOP A, RESTAURANT R
WHERE R.Shop_Id=A.Shop_Id
GROUP BY A.Area
order by COUNT(A.Shop_Id) desc LIMIT 1

-- Find the schedule of the restaurant that have the most orders in the past 1 month.
SELECT SC.Shop_Id ,SC.Day, SC.Open_Time, SC.Close_Time
from SCHEDULE SC,(SELECT O.Shop_Id AS Sid, COUNT(*)
FROM ORDERS O, PAYMENT P
WHERE P.Paymentconfirmation_No=O.PaymentConf_No
and P.Payment_Time<=DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY O.Shop_Id
ORDER BY COUNT(*) DESC LIMIT 1)A
WHERE SC.Shop_Id=A.Sid

-- Find the names of employees who are also a Gold Member.
SELECT *
FROM EMPLOYEE E
WHERE Gold_Id IS NOT NULL

-- Find the supermarket that has most different products in stock.
SELECT SH.Shop_Id, SH.SName
FROM (SELECT S.Shop_Id as Sid, COUNT(DISTINCT S.P_Name)
FROM SELLS S
GROUP BY S.Shop_Id
ORDER BY COUNT(*) DESC LIMIT 1) A, SHOP SH
WHERE SH.Shop_Id = A.Sid

-- For each product, list all the supermarkets selling it, and the price of the product at the supermarket.
SELECT S.P_Name, S.Price, SH.Shop_Id, SH.Name
FROM SELLS S, SHOP SH
WHERE S.Shop_Id=SH.Shop_Id