-- הוספת Price לטבלת Socks
ALTER TABLE Socks ADD Price MONEY NOT NULL

-- הסרת Quantity מטבלת Orders
ALTER TABLE Orders DROP CONSTRAINT CK_Quantity
ALTER TABLE Orders DROP COLUMN Quantity

-- הסרת Price ו-Order_ID מטבלת Designs
ALTER TABLE Designs DROP COLUMN Price
ALTER TABLE Designs DROP CONSTRAINT FK_Designs_Order_ID
ALTER TABLE Designs DROP CONSTRAINT PK_Designs
ALTER TABLE Designs DROP COLUMN Order_ID

-- הוספת DesignNumber לטבלת Designs
ALTER TABLE Designs ADD DesignNumber INT NOT NULL

-- הסרת מפתח ראשי קודם והוספת חדש
ALTER TABLE Designs ADD CONSTRAINT PK_Designs PRIMARY KEY (Item_Number, DesignNumber)

-- טבלה חדשה לקישור בין גרב להזמנה עם כמות
CREATE TABLE SockInOrder (
	Item_Number INT NOT NULL,
	Order_ID INT NOT NULL,
	Quantity INT NOT NULL,
	CONSTRAINT PK_SockInOrder PRIMARY KEY (Item_Number, Order_ID),
	CONSTRAINT FK_SockInOrder_Item FOREIGN KEY (Item_Number) REFERENCES Socks(Item_Number),
	CONSTRAINT FK_SockInOrder_Order FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
)


