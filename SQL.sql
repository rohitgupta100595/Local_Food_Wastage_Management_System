CREATE DATABASE food_wastage;

USE food_wastage;

SET GLOBAL LOCAL_INFILE = 1;

DROP TABLE IF EXISTS food_listings;
CREATE TABLE food_listings(
FOOD_ID INT,
Food_Name VARCHAR(244),
Quantity INT,
Expiry_Date VARCHAR(244),
Provider_ID INT,
Provider_Type VARCHAR(244),
Location VARCHAR(244),
Food_Type VARCHAR(244),
Meal_Type VARCHAR(244)
);


DROP TABLE IF EXISTS providers;
CREATE TABLE providers(
Provider_ID INT,
Name VARCHAR(244),
Type VARCHAR(244),
Addresss VARCHAR(244),
City VARCHAR(244),
Contact VARCHAR(244)
);


DROP TABLE IF EXISTS receivers;
CREATE TABLE receivers(
Reciever_ID INT,
Name VARCHAR(244),
Type VARCHAR(244),
City VARCHAR(244),
Contact VARCHAR(244)
);


CREATE TABLE claims(
Claim_ID INT,
Food_Id INT,
Reciever_ID INT,
Status VARCHAR(244),
Timestamp VARCHAR(244)
);

-- Data Validation --
-- Inspecting null values in claims dataset --
SELECT * FROM claims WHERE Claim_ID IS NULL OR Food_ID IS NULL OR Reciever_ID IS NULL OR Status = "" OR Status = " " OR Status IS NULL
	OR Timestamp = "" OR Timestamp = " " OR Timestamp IS NULL; 
	
-- Inspecting null values in food_listings --
SELECT * FROM food_listings;
SELECT DISTINCT Food_Name FROM food_listings;
SELECT DISTINCT Quantity FROM food_listings;
SELECT DISTINCT Expiry_Date FROM food_listings;
SELECT DISTINCT Provider_ID FROM food_listings;
SELECT DISTINCT Location FROM food_listings;
SELECT DISTINCT Food_Type FROM food_listings;
SELECT DISTINCT Meal_Type FROM food_listings;

-- Inspecting null values in providers -- 
SELECT * FROM providers;
SELECT DISTINCT Provider_ID FROM providers;
SELECT DISTINCT Name FROM providers;
SELECT DISTINCT Type FROM providers;
SELECT DISTINCT Addresss FROM providers;
SELECT DISTINCT City FROM providers;
SELECT DISTINCT Contact FROM providers;

-- Inspecting null values in receivers --
SELECT * FROM receivers;
SELECT DISTINCT Reciever_ID FROM receivers;
SELECT DISTINCT Name FROM receivers;
SELECT DISTINCT Type FROM receivers;
SELECT DISTINCT City FROM receivers;
SELECT DISTINCT Contact FROM receivers;

-- Treating Inconsistencies in Contact column for recievers dataset --
SET SQL_SAFE_UPDATES = 0;
UPDATE receivers
SET Contact = REPLACE(REPLACE(Contact,'.','-'),'x','-');

-- treating inconsistencies in Food_Type and Food_Name Column --
SELECT * FROM food_listings;

ALTER TABLE food_listings
ADD COLUMN New_Food_Type VARCHAR(20);

UPDATE food_listings
SET New_Food_Type = CASE WHEN Food_Name IN ('Dairy','Soup') THEN 'Vegetarian'
								WHEN Food_Name IN ('Bread','Fruits','Vegetables','Rice','Pasta','Salad') THEN 'Vegan' 
	ELSE 'Non-Vegetarian' 
END;
COMMIT;
ALTER TABLE food_listings
DROP COLUMN Food_Type;

ALTER TABLE food_listings
RENAME COLUMN New_Food_Type TO Food_Type;
-- Treating Inconsistencies in Conatct column in providers dataset --
UPDATE providers
SET Contact = REPLACE(REPLACE(Contact,'.','-'),'x','-');

-- Formatting date column in claims --
UPDATE claims
SET Timestamp = STR_TO_DATE(Timestamp,"%m/%d/%Y %H:%i");

-- Formatting date column in food_listings --
UPDATE food_listings
SET Expiry_Date = STR_TO_DATE(Expiry_Date,"%m/%d/%Y");

COMMIT;

SELECT * FROM claims;
SELECT * FROM food_listings;
SELECT * FROM providers;
SELECT * FROM receivers;

-- Final Dataset -- 
-- Excluding Providers and Receivers who are not in claim chain --
DROP TABLE IF EXISTS result_df;
CREATE TABLE Result_df AS
SELECT 
	c.Claim_ID AS Claim_ID,
	r.Name AS Receiver_Name,
	r.Type AS Receiver_Type,
	r.City AS Receiver_City,
	r.Contact AS Receiver_Contact,
	p.Name AS Provider_Name,
	p.Type AS Provider_Type,
	p.Addresss AS Provider_Address,
	p.City AS Provider_City,
	p.Contact AS Provider_Contact,
	f.Food_Name AS Food_Name,
	f.Quantity AS Food_Quantity,
	f.Food_Type AS Food_Type,
	f.Meal_Type AS Meal_Type,
	f.Expiry_Date AS Expiry_Date,
	c.Status AS Claim_Status,
	c.Timestamp AS Claim_Datetime,
	CASE WHEN c.Timestamp > f.Expiry_Date THEN 'Expired'
	ELSE 'Not Expired' END AS Expiry_Status
FROM receivers AS r
JOIN claims AS c ON r.Reciever_ID = c.Reciever_ID
JOIN food_listings AS f ON c.Food_Id = f.FOOD_ID
JOIN providers AS p ON f.Provider_ID = p.Provider_ID;


-- Final Dataset View --
SELECT * FROM result_df;
