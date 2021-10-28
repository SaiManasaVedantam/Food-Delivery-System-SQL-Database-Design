-- Sample Queries for Views

-- Annual Top Customers: This view returns the First Name, Last Name, Total Order Amount of the customers who paid top 3 total amount of orders (in terms of total balance in the orders) in the past 1 year.
CREATE VIEW TOP_CUSTOMERS(First_Name, Last_Name, Total_Order_Amount)
AS SELECT C.First_Name, C.Last_Name, SUM(O.Total_Balance) AS TOT
FROM CUSTOMER C, ORDERS O, PAYMENT P
WHERE C.Cid=O.Cust_Id
AND P.Payment_Time >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
AND P.Paymentconfirmation_No=O.PaymentConf_No
GROUP BY C.First_Name, C.Last_Name
ORDER BY TOT DESC
LIMIT 3

-- Popular Restaurant Type: This view returns the Type of restaurants that have the most number of orders in the past 1 year.
CREATE VIEW POPULAR_RESTAURANT_TYPE
AS SELECT RT.RTYPE
FROM RESTAURANT_TYPE RT
WHERE RT.Shop_Id IN
( SELECT A.Shop_Id
FROM (
SELECT O.Shop_Id,count(*)
FROM ORDERS O, PAYMENT P
WHERE P.Payment_Time >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
AND P.Paymentconfirmation_No=O.PaymentConf_No
GROUP BY O.Shop_Id
ORDER BY COUNT(*) DESC
LIMIT 1) A
);

-- Potential Silver Member: This view returns the information of the customers (not a silver member yet) who have placed orders more than 10 times in the past 1 month.
CREATE VIEW POTENTIAL_SILVER_MEMBER AS
SELECT *
FROM CUSTOMER C
WHERE C.C_Type IS NULL
AND 10<( SELECT A.CNT FROM
(SELECT COUNT(O.Cust_Id) CNT, O.Cust_Id
FROM ORDERS O, PAYMENT P
WHERE P.Paymentconfirmation_No=O.PaymentConf_No
AND P.Payment_Time >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
AND C.Cid=O.Cust_Id
GROUP BY O.Cust_Id) A);

-- Best Area Manager: This view returns information of the area manager who successfully made the most number of contracts with shops in her/his working area in past 1 year.
CREATE VIEW TOP_MANAGER AS
SELECT E.*
FROM AREA_MANAGER A, EMPLOYEE E
WHERE A.AEid=E.Eid
AND A.AEid IN
( SELECT B.AEid
FROM ( SELECT S.AreaMngr_Eid AS AEid, COUNT(*)
FROM SHOP S
WHERE S.Start_Time<= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY S.AreaMngr_Eid
ORDER BY COUNT(*) DESC LIMIT 1) B)

-- Top Restaurants: This view returns the top restaurant that has the most orders in the past 1 month for each restaurant type.
CREATE TEMPORARY TABLE IF NOT EXISTS TEMP AS
(Select O.Shop_Id AS Sid,RT.RType,Count(O.Oid) AS CO
FROM Orders O, Restaurant_Type RT, Restaurant R,Shop S,Payment P
WHERE RT.Shop_Id=R.Shop_Id
AND S.Shop_Id=O.Shop_Id
AND R.Shop_Id=S.Shop_Id
AND P.Paymentconfirmation_No = O.PaymentConf_No
AND P.Payment_Time<= DATE_SUB(CURDATE(),INTERVAL 1 MONTH)
Group by O.Shop_Id, RT.RType
Order by CO DESC DESC,RT.RType)

CREATE VIEW TOP_RESTRAURANT AS
Select T2.Shop_Id, S.Name
FROM TEMP T2, TEMP T1, SHOP S
WHERE T2.Shop_Id = T1.Shop_Id
S.Shop_Id = T2.Shop_Id
And T2.CO=MAX(T1.CO)