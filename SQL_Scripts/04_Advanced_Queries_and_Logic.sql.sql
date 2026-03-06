-- (שאלה עסקית 1: אילו קטגוריות של גרביים נמכרות הכי הרבה באתר (לפחות עם 50 מכירות

SELECT 
    sc.Category_Name AS Category,
    SUM(so.Quantity) AS Total_Sold
FROM 
    SockInOrder AS so
JOIN 
    Socks AS s ON so.Item_Number = s.Item_Number
JOIN 
    Sock_Categories AS sc ON s.Category = sc.Category_Name
WHERE S.Category in ('Junk Food','Christmas','Funny','Halloween','Wine','Winter')
GROUP BY 
    sc.Category_Name
ORDER BY 
    Total_Sold DESC

	--באילו מדינות יש מספר איסופים נמוך
	SELECT 
    D.Country,
    COUNT(*) AS Pickup_Count
FROM 
    Deliveries D
WHERE 
    D.[Type] = 'Pickup in store'
GROUP BY 
    D.Country
HAVING 
    COUNT(*) <= 4
ORDER BY 
    Pickup_Count



		--שאלה עסקית: כמה בממוצע כמה משלמים לקוחות מכל מדינה להזמנה פר שנה?
	SELECT 
    d.Country,
    YEAR(d.Arrival_Time) AS Delivery_Year,
    AVG(order_total.Total_Amount) AS Avg_Order_Amount,
    COUNT(DISTINCT d.Order_ID) AS Total_Orders
FROM 
    Deliveries AS d
JOIN 
    Orders AS o ON d.Order_ID = o.Order_ID
JOIN 
    Countries AS c ON d.Country = c.Country_Name
JOIN (
    SELECT 
        so.Order_ID,
        SUM(so.Quantity * s.Price) AS Total_Amount
    FROM 
        SockInOrder so
    JOIN 
        Socks s ON so.Item_Number = s.Item_Number
    GROUP BY 
        so.Order_ID
) AS order_total ON d.Order_ID = order_total.Order_ID
GROUP BY 
    d.Country, YEAR(d.Arrival_Time)
ORDER BY 
    d.Country, Delivery_Year



SELECT 
    -- חיפושים במרץ
    (SELECT COUNT(*) 
     FROM Sock_Searches 
     WHERE MONTH(Search_DT) = 3 AND YEAR(Search_DT) = 2025) AS March_Searches,

    -- ממוצע חיפושים חודשי כולל
    (SELECT 
        COUNT(*) / COUNT(DISTINCT MONTH(Search_DT))
     FROM Sock_Searches 
     WHERE YEAR(Search_DT) = 2025
    ) AS Avg_Searches_Per_Month,

    -- אחוז שינוי עם סימן חיובי/שלילי וללא עשרוניות
    CASE 
        WHEN (
            (SELECT COUNT(*) 
             FROM Sock_Searches 
             WHERE MONTH(Search_DT) = 3 AND YEAR(Search_DT) = 2025)
            -
            (SELECT COUNT(*) / COUNT(DISTINCT MONTH(Search_DT))
             FROM Sock_Searches 
             WHERE YEAR(Search_DT) = 2025)
        ) >= 0
        THEN '+' +
            CAST(
                FLOOR(
                    100.0 * (
                        (SELECT COUNT(*) 
                         FROM Sock_Searches 
                         WHERE MONTH(Search_DT) = 3 AND YEAR(Search_DT) = 2025)
                        -
                        (SELECT COUNT(*) / COUNT(DISTINCT MONTH(Search_DT))
                         FROM Sock_Searches 
                         WHERE YEAR(Search_DT) = 2025)
                    ) / 
                    NULLIF(
                        (SELECT COUNT(*) / COUNT(DISTINCT MONTH(Search_DT))
                         FROM Sock_Searches 
                         WHERE YEAR(Search_DT) = 2025),
                    0)
                ) AS VARCHAR
            ) + '%'
        ELSE '-' +
            CAST(
                FLOOR(
                    100.0 * ABS(
                        (SELECT COUNT(*) 
                         FROM Sock_Searches 
                         WHERE MONTH(Search_DT) = 3 AND YEAR(Search_DT) = 2025)
                        -
                        (SELECT COUNT(*) / COUNT(DISTINCT MONTH(Search_DT))
                         FROM Sock_Searches 
                         WHERE YEAR(Search_DT) = 2025)
                    ) / 
                    NULLIF(
                        (SELECT COUNT(*) / COUNT(DISTINCT MONTH(Search_DT))
                         FROM Sock_Searches 
                         WHERE YEAR(Search_DT) = 2025),
                    0)
                ) AS VARCHAR
            ) + '%'
    END AS Change_March_vs_Avg


	-- שאילתת חלון מספר 1
	SELECT
    D.Country,
    S.Item_Number,
    SUM(SO.Quantity) AS Total_Units_Sold,
    RANK() OVER (PARTITION BY D.Country ORDER BY SUM(SO.Quantity) DESC) AS Sock_Rank,
    FIRST_VALUE(SUM(SO.Quantity)) OVER (PARTITION BY D.Country ORDER BY SUM(SO.Quantity) DESC) AS Top_Sales,
    FIRST_VALUE(SUM(SO.Quantity)) OVER (PARTITION BY D.Country ORDER BY SUM(SO.Quantity) DESC)
        - SUM(SO.Quantity) AS Sales_Difference
FROM
    SockInOrder SO
    JOIN Deliveries D ON SO.Order_ID = D.Order_ID
    JOIN Socks S ON SO.Item_Number = S.Item_Number
GROUP BY
    D.Country, S.Item_Number
ORDER BY
    D.Country, Sock_Rank

	-- פונקציית חלון מספר 2
SELECT
    S.Item_Number,
    CONCAT(YEAR(SS.Search_DT), '-', RIGHT('0' + CAST(MONTH(SS.Search_DT) AS VARCHAR(2)), 2)) AS Search_Month,
    COUNT(*) AS Monthly_Searches,
    LAG(COUNT(*)) OVER (PARTITION BY S.Item_Number ORDER BY YEAR(SS.Search_DT), MONTH(SS.Search_DT)) AS Prev_Month_Searches,
    COUNT(*) - LAG(COUNT(*)) OVER (PARTITION BY S.Item_Number ORDER BY YEAR(SS.Search_DT), MONTH(SS.Search_DT)) AS Monthly_Change,
    SUM(COUNT(*)) OVER (PARTITION BY S.Item_Number ORDER BY YEAR(SS.Search_DT), MONTH(SS.Search_DT)) AS Cumulative_Searches
FROM
    Sock_Searches SS
    JOIN Socks S ON SS.Item_Number = S.Item_Number
GROUP BY
    S.Item_Number, YEAR(SS.Search_DT), MONTH(SS.Search_DT)
ORDER BY
    S.Item_Number, Search_Month

	פונקציית עם:
WITH OrderTotalsPerCity AS (
SELECT
        D.City,
        COUNT(D.Order_ID) AS Num_Orders,
        SUM(S.Price * SO.Quantity) AS Total_Value,
        AVG(S.Price * SO.Quantity) AS Avg_Order_Value
    FROM Deliveries D
    JOIN Orders O ON D.Order_ID = O.Order_ID
    JOIN SockInOrder SO ON O.Order_ID = SO.Order_ID
    JOIN Socks S ON SO.Item_Number = S.Item_Number
    GROUP BY D.City
),
CityStats AS (
    SELECT
        AVG(Num_Orders * 1.0) AS Avg_Orders,
        AVG(Avg_Order_Value * 1.0) AS Avg_Order_Value
    FROM OrderTotalsPerCity
),
HighValueCities AS (
    SELECT
        OC.City,
        OC.Num_Orders,
        OC.Total_Value,
        OC.Avg_Order_Value
    FROM OrderTotalsPerCity OC
    CROSS JOIN CityStats CS
    WHERE OC.Num_Orders >= CS.Avg_Orders
      AND OC.Avg_Order_Value >= CS.Avg_Order_Value
)
SELECT
    City,
    Num_Orders,
    Total_Value,
    Avg_Order_Value
FROM HighValueCities
ORDER BY Total_Value DESC



--חלק ב

--שאילתת view

CREATE VIEW OrderDeliveryDetail AS
SELECT 
    O.Order_ID,
	O.Email,
    D.Shipping_ID,
    D.Country,
    D.Arrival_Time,
    S.Search_DT AS Order_Placement_Time  
FROM 
    Orders AS O
    JOIN Deliveries AS D ON O.Order_ID = D.Order_ID
    LEFT JOIN Searches AS S ON S.Order_ID = O.Order_ID

		SELECT  *
FROM OrderDeliveryDetail


-- פונקציה ראשונה

CREATE FUNCTION fn_GetDeliveryDurationDays (@Shipping_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Duration INT;

    SELECT @Duration = DATEDIFF(DAY, Order_Placement_Time, Arrival_Time)
    FROM OrderDeliveryDetails
    WHERE Shipping_ID = @Shipping_ID;

    RETURN @Duration;
END

SELECT 
    Order_ID,
	Email,
    Order_Placement_Time,
    Arrival_Time,
    dbo.fn_GetDeliveryDurationDays(Shipping_ID) AS Delivery_Duration_Days
FROM 
    OrderDeliveryDetail
WHERE 
    Order_Placement_Time IS NOT NULL AND Arrival_Time IS NOT NULL


	--פונקציה שניה

	CREATE FUNCTION fn_SalesByCountryForCategory (@Category VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        D.Country,
        SUM(SIO.Quantity) AS Total_Sold
    FROM 
        SockInOrder AS SIO
        JOIN Socks AS S ON SIO.Item_Number = S.Item_Number
        JOIN Deliveries AS D ON SIO.Order_ID = D.Order_ID
    WHERE 
        S.Category = @Category
    GROUP BY 
        D.Country
)


SELECT *
FROM dbo.fn_SalesByCountryForCategory('customized style')
ORDER BY Total_Sold DESC



-- טריגר
CREATE TABLE CreditCardsExpiringSoon (
    Card_Number CHAR(16) PRIMARY KEY,
    Expiration_Date DATE,
    Email VARCHAR(50),
    Logged_At DATETIME DEFAULT GETDATE()
)


CREATE TRIGGER trg_LogExpiringCards
ON Credit_Cards
AFTER INSERT, UPDATE
AS
BEGIN
    INSERT INTO CreditCardsExpiringSoon (Card_Number, Expiration_Date, Email)
    SELECT 
        CC.CC_Number,
        CC.Expiration_Date,
        A.Email
    FROM 
        inserted CC
        JOIN Orders AS O ON CC.CC_Number = O.CC_Number
        JOIN Accounts AS A ON O.Account_Number = A.Account_Number
    WHERE 
        CC.Expiration_Date BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(YEAR, 1, GETDATE())
        AND NOT EXISTS (
            SELECT 1
            FROM CreditCardsExpiringSoon AS E
            WHERE E.Card_Number = CC.CC_Number
        )
END


UPDATE Credit_Cards
SET Expiration_Date = CAST(DATEADD(MONTH, 6, GETDATE()) AS DATE)
WHERE CC_Number = '5326103312341234'
AND EXISTS (
    SELECT 1
    FROM Orders AS O
    JOIN Searches AS S ON S.Order_ID = O.Order_ID
    WHERE O.CC_Number = '5326103312341234'
      AND S.Search_DT >= DATEADD(MONTH, -3, GETDATE())
)

-- פרוצדורה
CREATE PROCEDURE CreateLateDeliveryCustomers
AS
BEGIN
    -- אם הטבלה קיימת כבר – נמחק אותה קודם
    IF OBJECT_ID('LateDeliveryCustomers', 'U') IS NOT NULL
        DROP TABLE LateDeliveryCustomers;

    -- יצירת הטבלה החדשה
    CREATE TABLE LateDeliveryCustomers (
        Order_ID INT,
        Email VARCHAR(100)
    )

    -- הכנסת הנתונים מה-View תוך שימוש בפונקציה
    INSERT INTO LateDeliveryCustomers (Order_ID, Email)
    SELECT 
        Order_ID,
        Email
    FROM 
        OrderDeliveryDetail
    WHERE 
        dbo.fn_GetDeliveryDurationDays(Shipping_ID) > 100
        AND Order_Placement_Time IS NOT NULL 
        AND Arrival_Time IS NOT NULL;
END

EXEC CreateLateDeliveryCustomers


--פרוצדורה עם טבלה זמנית

CREATE PROCEDURE CreateLateDeliveryCustomers_Temp
AS
BEGIN
    -- יצירת הטבלה הזמנית (לא קבועה בבסיס הנתונים)
    CREATE TABLE #LateDeliveryCustomers (
        Order_ID INT,
        Email VARCHAR(100)
    )

    -- הכנסת הנתונים מה-View תוך שימוש בפונקציה הקיימת
    INSERT INTO #LateDeliveryCustomers (Order_ID, Email)
    SELECT 
        Order_ID,
        Email
    FROM 
        OrderDeliveryDetail
    WHERE 
        dbo.fn_GetDeliveryDurationDays(Shipping_ID) > 100
        AND Order_Placement_Time IS NOT NULL 
        AND Arrival_Time IS NOT NULL;

    -- הדפסת הנתונים לבדיקה (בפועל אפשר גם SELECT לתוצאה חיצונית)
    SELECT * FROM #LateDeliveryCustomers;

    -- אופציונלי: הטבלה תימחק אוטומטית בסוף ה־SESSION, אין צורך ב-DROP
END

EXEC CreateLateDeliveryCustomers_Temp



CREATE TABLE SockCategorySalesSummary (
    Category_Name VARCHAR(20) PRIMARY KEY,
    Total_Sold INT NOT NULL
)

MERGE SockCategorySalesSummary AS Target
USING (
    SELECT 
        sc.Category_Name,
        SUM(so.Quantity) AS Total_Sold
    FROM SockInOrder AS so
    JOIN Socks AS s ON so.Item_Number = s.Item_Number
    JOIN Sock_Categories AS sc ON s.Category = sc.Category_Name
    WHERE s.Category IN ('Junk', 'Food', 'Christmas', 'Funny', 'Halloween', 'Wine', 'Winter')
    GROUP BY sc.Category_Name
) AS Source
ON Target.Category_Name = Source.Category_Name

WHEN MATCHED THEN
    UPDATE SET Target.Total_Sold = Source.Total_Sold

WHEN NOT MATCHED THEN
    INSERT (Category_Name, Total_Sold)
    VALUES (Source.Category_Name, Source.Total_Sold);


	-- שאילתה לחישוב אחוז החיפושים בחודש מרץ - שיפור באמצעות צאט

	WITH MonthlySearches AS (
    SELECT
        MONTH(Search_DT) AS MonthNum,
        COUNT(*) AS SearchCount
    FROM Sock_Searches
    WHERE YEAR(Search_DT) = 2025
    GROUP BY MONTH(Search_DT)
),
Summary AS (
    SELECT
        SUM(CASE WHEN MonthNum = 3 THEN SearchCount ELSE 0 END) AS March_Searches,
        AVG(SearchCount * 1.0) AS Avg_Searches_Per_Month
    FROM MonthlySearches
)
SELECT
    March_Searches,
    Avg_Searches_Per_Month,
    CASE
        WHEN Avg_Searches_Per_Month = 0 THEN 'N/A'
        WHEN March_Searches >= Avg_Searches_Per_Month THEN
            '+' + CAST(FLOOR(100.0 * (March_Searches - Avg_Searches_Per_Month) / Avg_Searches_Per_Month) AS VARCHAR) + '%'
        ELSE
            '-' + CAST(FLOOR(100.0 * ABS(March_Searches - Avg_Searches_Per_Month) / Avg_Searches_Per_Month) AS VARCHAR) + '%'
    END AS Change_March_vs_Avg
FROM Summary;


-- ניתוח חיפושים חודשיים - שיפור באמצעות צאט

WITH MonthlyCounts AS (
    SELECT
        S.Item_Number,
        YEAR(SS.Search_DT) AS Y,
        MONTH(SS.Search_DT) AS M,
        COUNT(*) AS Monthly_Searches
    FROM Sock_Searches SS
    JOIN Socks S ON SS.Item_Number = S.Item_Number
    GROUP BY S.Item_Number, YEAR(SS.Search_DT), MONTH(SS.Search_DT)
),
Final AS (
    SELECT
        Item_Number,
        CONCAT(Y, '-', RIGHT('0' + CAST(M AS VARCHAR(2)), 2)) AS Search_Month,
        Monthly_Searches,
        LAG(Monthly_Searches) OVER (PARTITION BY Item_Number ORDER BY Y, M) AS Prev_Month_Searches,
        SUM(Monthly_Searches) OVER (PARTITION BY Item_Number ORDER BY Y, M ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_Searches
    FROM MonthlyCounts
)
SELECT
    Item_Number,
    Search_Month,
    Monthly_Searches,
    Prev_Month_Searches,
    Monthly_Searches - Prev_Month_Searches AS Monthly_Change,
    Cumulative_Searches
FROM Final
ORDER BY Item_Number, Search_Month;

