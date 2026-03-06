--DROP TABLE Socks
CREATE TABLE Socks(
	Item_Number			INT						NOT NULL,
	Category			Varchar(20)				NOT NULL,
	CONSTRAINT PK_Socks PRIMARY KEY (Item_Number)
	)

--DROP TABLE Sock_Searches
CREATE TABLE Sock_Searches(
	Item_Number			INT						NULL,
	IP_Address			VARCHAR(32)				NOT NULL,
	Search_DT			DATETIME				NOT NULL,
	CONSTRAINT PK_Sock_Searches PRIMARY KEY (IP_Address,Search_DT)
	)

--DROP TABLE Searches
CREATE TABLE Searches(
	IP_Address			VARCHAR(32)				NOT NULL,
	Search_DT			DATETIME				NOT NULL,
	Zip_Code			INT						NULL,
	Account_Number		INT						NULL,
	Order_ID			INT						NULL,
	CONSTRAINT PK_Searches PRIMARY KEY (IP_Address,Search_DT),
	CONSTRAINT CK_IP_Address  CHECK 	(IP_Address like '%.%.%.%')
	)

--DROP TABLE Orders
CREATE TABLE Orders(
	Order_ID			INT						NOT NULL,
	Email				VARCHAR(30)				NOT NULL,
	Quantity			INT						NOT NULL,
	Account_Number		INT						NULL,
	CC_Number			VARCHAR(20)				NOT NULL,
	CONSTRAINT PK_Orders PRIMARY KEY (Order_ID),
	CONSTRAINT CK_Email  CHECK 	(Email like '%@%.%'),
	CONSTRAINT CK_Quantity CHECK (Quantity > 0)
	)

--DROP TABLE Accounts
CREATE TABLE Accounts(
	Account_Number		int				NOT NULL,
	Email				VARCHAR(30)				NOT NULL,
	[Password]			VARCHAR(30)				NOT NULL,
	First_Name			VARCHAR(20)				NOT NULL,
	Last_Name			VARCHAR(20)				NOT NULL,
	CONSTRAINT PK_Accounts PRIMARY KEY (Account_Number),
	CONSTRAINT UQ_Accounts_Email UNIQUE (Email),
	CONSTRAINT CK_AC_Email  CHECK 	(Email like '%@%.%'),
	CONSTRAINT CK_Password  CHECK  (LEN([Password]) BETWEEN 8 AND 20),
	CONSTRAINT CK_First_Name_OnlyLetters CHECK (First_Name NOT LIKE '%[^A-Za-z]%'),
	CONSTRAINT CK_Last_Name_OnlyLetters CHECK (Last_Name NOT LIKE '%[^A-Za-z]%')
	)

--DROP TABLE Credit_Cards
CREATE TABLE Credit_Cards(
	CC_Number			VARCHAR(20)				NOT NULL,
	Expiration_Date		DATE					NOT NULL,
	CVC					CHAR(3)					NOT NULL,
	Card_holder_name	VARCHAR(40)				NOT NULL,
	CONSTRAINT PK_Credit_Cards PRIMARY KEY (CC_Number),
	CONSTRAINT CK_CC_Number  CHECK 	(CC_Number NOT LIKE '%[^0-9]%' AND LEN(CC_Number) = 16),
	CONSTRAINT CK_CVC  CHECK 	(CVC NOT LIKE '%[^0-9]%' AND LEN(CVC) = 3),
	CONSTRAINT CK_Card_holder_name_OnlyLetters CHECK (Card_holder_name NOT LIKE '%[^A-Za-z ]%')
)

--DROP TABLE Designs
CREATE TABLE Designs(
	Order_ID			INT						NOT NULL,
	Item_Number			INT						NOT NULL,
	Price				MONEY					NOT NULL,
	Color				VARCHAR(10)				NOT NULL,
	Photo				VARCHAR(200)			NULL,
	Size				VARCHAR(5)				NOT NULL,
	CONSTRAINT PK_Designs PRIMARY KEY (Order_ID,Item_Number)
)

--DROP TABLE Deliveries
CREATE TABLE Deliveries(
	Shopping_ID			INT						NOT NULL,
	[Type]				VARCHAR(15)				NOT NULL,
	Arrival_Time		DATETIME				NULL,
	Delivery_Fee		MONEY					NULL,
	Country				VARCHAR(20)				NOT NULL,
	City				VARCHAR(20)				NOT NULL,
	Street				VARCHAR(20)				NOT NULL,
	Street_Number		INT						NOT NULL,
	Order_ID			INT						NOT NULL,
	CONSTRAINT PK_Deliveries PRIMARY KEY (Shopping_ID),
	CONSTRAINT CK_Type CHECK ([Type] IN ('Ship', 'Pickup in store')),
	CONSTRAINT CK_Street_Number CHECK (Street_Number > 0)
)
--Drop table Countries
CREATE TABLE Countries (
	Country_Name  VARCHAR(20)  NOT NULL
	CONSTRAINT PK_Country_Name PRIMARY KEY (Country_Name)
)
--DROP TABLE Sock_Categories
CREATE TABLE Sock_Categories (
	Category_Name  VARCHAR(20) NOT NULL
	CONSTRAINT PK_Category_Name PRIMARY KEY (Category_Name)
)
--DROP TABLE Sock_Colors
CREATE TABLE Sock_Colors (
	Color_Name  VARCHAR(10) NOT NULL
	CONSTRAINT PK_Color_Name PRIMARY KEY (Color_Name)
)
--DROP TABLE Sock_Sizes
CREATE TABLE Sock_Sizes (
	Size_Code  VARCHAR(5) NOT NULL
	CONSTRAINT PK_Size_Code PRIMARY KEY (Size_Code)
)
ALTER TABLE Socks
ADD CONSTRAINT FK_Socks_Category
FOREIGN KEY (Category)
REFERENCES Sock_Categories(Category_Name)

ALTER TABLE Designs
ADD CONSTRAINT FK_Designs_Color
FOREIGN KEY (Color)
REFERENCES Sock_Colors(Color_Name)

ALTER TABLE Designs
ADD CONSTRAINT FK_Designs_Size
FOREIGN KEY (Size)
REFERENCES Sock_Sizes(Size_Code)

ALTER TABLE Deliveries
ADD CONSTRAINT FK_Deliveries_Country
FOREIGN KEY (Country)
REFERENCES Countries(Country_Name)

ALTER TABLE Sock_Searches
ADD CONSTRAINT FK_Sock_Searches_Item_Number
FOREIGN KEY (Item_Number)
REFERENCES Socks(Item_Number)

ALTER TABLE Sock_Searches
ADD CONSTRAINT FK_Sock_Searches_Search_Key
FOREIGN KEY (IP_Address, Search_DT)
REFERENCES Searches(IP_Address, Search_DT)

ALTER TABLE Searches
ADD CONSTRAINT FK_Searches_Account_Number
FOREIGN KEY (Account_Number)
REFERENCES Accounts(Account_Number)

ALTER TABLE Searches
ADD CONSTRAINT FK_Searches_Order_ID
FOREIGN KEY (Order_ID)
REFERENCES Orders(Order_ID)

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Account_Number
FOREIGN KEY (Account_Number)
REFERENCES Accounts(Account_Number)

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_CC_Number
FOREIGN KEY (CC_Number)
REFERENCES Credit_Cards(CC_Number)

ALTER TABLE Designs
ADD CONSTRAINT FK_Designs_Order_ID
FOREIGN KEY (Order_ID)
REFERENCES Orders(Order_ID)

ALTER TABLE Designs
ADD CONSTRAINT FK_Designs_Item_Number
FOREIGN KEY (Item_Number)
REFERENCES Socks(Item_Number)

ALTER TABLE Deliveries
ADD CONSTRAINT FK_Deliveries_Order_ID
FOREIGN KEY (Order_ID)
REFERENCES Orders(Order_ID)





