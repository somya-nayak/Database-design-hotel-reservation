--------------------------Drop Table/Sequence Section---------------------------
---This section is for dropping all the tables and sequences.                ---
--------------------------------------------------------------------------------
DROP TABLE Location_Features_Linking;
DROP TABLE Features;
DROP TABLE Reservation_Details;
DROP TABLE Room;
DROP TABLE Location;
DROP TABLE Reservation;
DROP TABLE Customer_Payment;
DROP TABLE Customer;

DROP SEQUENCE customer_id_seq;
DROP SEQUENCE payment_id_seq;
DROP SEQUENCE reservation_id_seq;
DROP SEQUENCE location_id_seq;
DROP SEQUENCE room_id_seq;

--------------------------------------------------------------------------------

---------------------------Create Table/Sequence Section------------------------
---This section is for creating all the sequences, tables and link tables    ---
---and the necessary constraints.                                            ---
--------------------------------------------------------------------------------

-----------------------Sequences for the IDs------------------------------------
CREATE SEQUENCE customer_id_seq
    START WITH 100001 INCREMENT BY 1;
    
CREATE SEQUENCE payment_id_seq
    START WITH 1 INCREMENT BY 1;
    
CREATE SEQUENCE reservation_id_seq
    START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE location_id_seq
    START WITH 1 INCREMENT BY 1;
    
CREATE SEQUENCE room_id_seq
    START WITH 1 INCREMENT BY 1;

-----------------------------------Tables---------------------------------------
CREATE TABLE Customer ---Create table for Customer
(
    Customer_ID              NUMBER              DEFAULT customer_id_seq.NEXTVAL PRIMARY KEY,
    Customer_First_Name      VARCHAR(40)         NOT NULL,
    Customer_Last_Name       VARCHAR(40)         NOT NULL,
    Customer_Email           VARCHAR(40)         NOT NULL    UNIQUE,
    Customer_Phone           CHAR(12)            NOT NULL,
    Customer_Address_Line_1  VARCHAR(40)         NOT NULL,
    Customer_Address_Line_2  VARCHAR(40), 
    Customer_City            VARCHAR(20)         NOT NULL,
    Customer_State           CHAR(2)             NOT NULL, 
    Customer_Zip             CHAR(5)             NOT NULL,
    Customer_Birthdate       DATE,    
    Stay_Credits_Earned      NUMBER             DEFAULT 0  NOT NULL,
    Stay_Credits_Used        NUMBER             DEFAULT 0  NOT NULL,
    
    CONSTRAINT customer_stay_credits_used_max CHECK(Stay_Credits_Earned >= Stay_Credits_Used),
    CONSTRAINT customer_email_length_check CHECK( LENGTH(Customer_Email) >= 7),
    CONSTRAINT check_zip            CHECK ( LENGTH (Customer_Zip) = 5 ),
    CONSTRAINT check_state          CHECK ( LENGTH(Customer_State) = 2 ), 
    CONSTRAINT check_phone          CHECK ( LENGTH(Customer_Phone) = 12 )
);



CREATE TABLE Customer_Payment ---Create table for Customer_Payment
(
    Payment_ID      NUMBER              DEFAULT payment_id_seq.NEXTVAL PRIMARY KEY,
    Customer_ID     NUMBER              NOT NULL,
    Cardholder_First_Name VARCHAR(20)   NOT NULL,
    Cardholder_Mid_Name VARCHAR(20),    ----------------------------------------This can be null because not everyone has a middle name.
    Cardholder_Last_Name VARCHAR(20)    NOT NULL,
    CardType        CHAR(4)             CONSTRAINT check_cardtype_length    CHECK (LENGTH(CardType) = 4 ),
    CardNumber      NUMBER              CONSTRAINT check_cardnumber_length    CHECK (LENGTH(CardNumber) = 16 ),
    Expiration_Date DATE                NOT NULL,   
    CC_ID           NUMBER              CONSTRAINT check_ccid_length        CHECK ( LENGTH(CC_ID) = 3 ),
    Billing_Address VARCHAR(40)         NOT NULL,
    Billing_City    VARCHAR(20)         NOT NULL,
    Billing_State   CHAR(2)             NOT NULL,
    Billing_Zip     CHAR(5)             NOT NULL,
     
    CONSTRAINT payment_fk_customer FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID)
);



CREATE TABLE Reservation ---Created table for Reservation
(
    Reservation_ID      NUMBER              DEFAULT reservation_id_seq.NEXTVAL PRIMARY KEY,
    Customer_ID         NUMBER              NOT NULL,
    Confirmation_Nbr    CHAR(8)             NOT NULL            UNIQUE,
    Date_Created        DATE                DEFAULT SYSDATE     NOT NULL,
    Check_In_Date       DATE                NOT NULL,
    Check_Out_Date      DATE,
    Reservation_Status  CHAR(1)             NOT NULL,
    Discount_Code       VARCHAR(30),
    Reservation_Total   NUMBER              NOT NULL,
    Customer_Rating     NUMBER,    
    Notes               VARCHAR(500),
        
    CONSTRAINT reservation_fk_customer FOREIGN KEY (Customer_ID) REFERENCES Customer (Customer_ID),
    CONSTRAINT  reservation_fields_status CHECK (Reservation_Status IN ('U','I','C','N','R') ), ---Check if the status is valid
    CONSTRAINT chk_in_date CHECK(Check_In_Date >= Date_Created), ---Check in date should not be before the date created?
    CONSTRAINT chk_out_date CHECK (Check_Out_Date IS NULL OR Check_In_Date <= Check_Out_Date) ---Check in date should be before check out date if check out date is not null.
    
);



CREATE TABLE Location --- Create table for Location
(
    Location_ID                  NUMBER              DEFAULT location_id_seq.NEXTVAL PRIMARY KEY,
    Location_Name                VARCHAR(20)         NOT NULL   UNIQUE,
    Location_Address             VARCHAR(40)         NOT NULL,
    Location_City                VARCHAR(20)         NOT NULL,
    Location_State               CHAR(2)             NOT NULL,
    Location_Zip                 CHAR(5)             NOT NULL,
    Location_Phone               CHAR(12)            NOT NULL,
    Location_URL                 VARCHAR(40)         NOT NULL,

        
    CONSTRAINT  loc_state_chk CHECK (LENGTH(Location_State) = 2), ---Location needs to be length 2.
    CONSTRAINT  loc_zip_chk CHECK (LENGTH(Location_Zip) = 5), ---Zip needs to be 5 digits.
    CONSTRAINT  loc_phone_chk CHECK (LENGTH(Location_Phone) = 12) ---We assume the phone needs to be xxx - xxx - xxxx
);




CREATE TABLE Room ---  Create table for Room
(
    Room_ID             NUMBER       DEFAULT room_id_seq.NEXTVAL PRIMARY KEY,
    Location_ID         NUMBER       NOT NULL,
    Floor               NUMBER       NOT NULL,
    Room_Number         NUMBER       NOT NULL,
    Room_Type           CHAR(1)      NOT NULL,
    Square_Footage      NUMBER       NOT NULL,
    MAX_People          NUMBER       NOT NULL,
    Weekday_Rate        Number       NOT NULL,
    Weekend_Rate        Number       NOT NULL,

        
    CONSTRAINT room_fk_location FOREIGN KEY (Location_ID) REFERENCES   Location(Location_ID),
    CONSTRAINT room_type_check CHECK (Room_Type IN ('D','Q','K','S','C')) ---Check if the room type is valid.
);



CREATE TABLE Reservation_Details --- Create linking table fore Room and Reservation
(
    Reservation_ID      NUMBER      NOT NULL,
    Room_ID             NUMBER      NOT NULL,
    Number_of_Guests    NUMBER      NOT NULL,
    PRIMARY KEY(Reservation_ID, Room_ID),
    CONSTRAINT  reservation_details_fk_reservation_id FOREIGN KEY (Reservation_ID) REFERENCES Reservation (Reservation_ID),
    CONSTRAINT  reservation_details_fk_room_id FOREIGN KEY (Room_ID) REFERENCES Room (Room_ID)
);


CREATE TABLE Features --- Create table for Features 
(
    Feature_ID      NUMBER          NOT NULL,
    Feature_Name    VARCHAR(40)     NOT NULL    UNIQUE,
    CONSTRAINT feature_pk PRIMARY KEY (Feature_ID)
);



CREATE TABLE Location_Features_Linking --- Create linking table fore location and features. 
(
    Location_ID     NUMBER       NOT NULL,
    Feature_ID      NUMBER       NOT NULL,
    PRIMARY KEY (Location_ID, Feature_ID),
    CONSTRAINT LFL_fk_location FOREIGN KEY (Location_ID) REFERENCES Location(Location_ID),
    CONSTRAINT LFL_fk_feature FOREIGN KEY (Feature_ID)  REFERENCES Features(Feature_ID)
);
--------------------------------------------------------------------------------


----------------------------Create Index Section--------------------------------
---This section is for adding index for the FKs that are not PKs. In addition---
---the name of customers are also indexed so that specific customers can be  ---
---searched efficiently.                                                     ---
--------------------------------------------------------------------------------
CREATE INDEX idx_customer_id
ON Reservation(Customer_ID);

CREATE INDEX idx_customer_payment
ON Customer_Payment(Customer_ID);

CREATE INDEX idx_location_id
ON Room(Location_ID);

CREATE INDEX idx_first_name
ON Customer(Customer_First_Name);

CREATE INDEX idx_last_name
ON Customer(Customer_Last_Name);

CREATE INDEX idx_check_in_date
ON Reservation(Check_In_Date);
--------------------------------Section Ends------------------------------------



-----------------------------Insert Data Section--------------------------------
---Insert required data for the created tables.                              ---
--------------------------------------------------------------------------------

-----Insert Location--------
INSERT INTO Location (Location_Name, Location_Address, Location_City, Location_State, Location_Zip, Location_Phone, Location_URL)
    VALUES ('South Congress','1000 South St','Austin','TX','78702','206-822-0198','www.noelle.com');
INSERT INTO Location (Location_Name, Location_Address, Location_City, Location_State, Location_Zip, Location_Phone, Location_URL)
    VALUES ('East 7th Loft','2000 E St','Austin','TX','78703','208-822-0198','www.noelli.com');
INSERT INTO Location (Location_Name, Location_Address, Location_City, Location_State, Location_Zip, Location_Phone, Location_URL)
    VALUES ('Balcones Canyonlands','999 West Austin St','Austin','TX','78705','206-822-9999','www.notnoelle.com');
Commit;
-----Insert Features-----
INSERT INTO Features (feature_id,feature_name)
    VALUES (1,'Free wi-fi');
INSERT INTO Features (feature_id,feature_name)
    VALUES (2,'Free breakfast');
INSERT INTO Features (feature_id,feature_name)
    VALUES (3,'Gym');
Commit;
-----Insert Location Features Link-----
INSERT INTO Location_Features_Linking (Location_ID,Feature_ID)
    VALUES (1,1);
INSERT INTO Location_Features_Linking (Location_ID,Feature_ID)
    VALUES (1,2);
INSERT INTO Location_Features_Linking (Location_ID,Feature_ID)
    VALUES (1,3);
INSERT INTO Location_Features_Linking (Location_ID,Feature_ID)
    VALUES (2,1);
INSERT INTO Location_Features_Linking (Location_ID,Feature_ID)
    VALUES (2,2);
INSERT INTO Location_Features_Linking (Location_ID,Feature_ID)
    VALUES (3,1);
Commit;
-----Insert Rooms-----
INSERT INTO Room (location_id, floor, room_number, room_type, square_footage, max_people, weekday_rate,weekend_rate)
    VALUES (1,1,100,'D',120,2,100,120);
INSERT INTO Room (location_id, floor, room_number, room_type, square_footage, max_people, weekday_rate,weekend_rate)
    VALUES (1,2,200,'Q',500,3,500,600);
INSERT INTO Room (location_id, floor, room_number, room_type, square_footage, max_people, weekday_rate,weekend_rate)
    VALUES (2,1,100,'K',1000,4,1000,1200);
INSERT INTO Room (location_id, floor, room_number, room_type, square_footage, max_people, weekday_rate,weekend_rate)
    VALUES (2,1,101,'S',10,1,50,60);
INSERT INTO Room (location_id, floor, room_number, room_type, square_footage, max_people, weekday_rate,weekend_rate)
    VALUES (3,1,100,'C',200,2,100,120);
INSERT INTO Room (location_id, floor, room_number, room_type, square_footage, max_people, weekday_rate,weekend_rate)
    VALUES (3,2,200,'D',120,2,100,120);
Commit;
-----Insert Customers-----
INSERT INTO Customer (Customer_First_name,Customer_Last_name,Customer_Email,Customer_phone,Customer_Address_Line_1,Customer_Address_Line_2,Customer_City,Customer_State,Customer_Zip,Customer_Birthdate)
    VALUES ('Andre','Han','ah47498@utexas.edu','206-822-0198','Super Nice Street 7th','GSB Building Apt 3','Austin','TX', '78705','03-MAR-1990');
INSERT INTO Customer (Customer_First_name,Customer_Last_name,Customer_Email,Customer_phone,Customer_Address_Line_1,Customer_Address_Line_2,Customer_City,Customer_State,Customer_Zip,Customer_Birthdate)
    VALUES ('Water','Woo','shengxiang.wu@utexas.edu','209-854-1745','7 Glue Blue Rd',NULL,'Austin','TX', '78705','12-FEB-1999');
Commit;
-----Insert Customer_Payment-----
INSERT INTO Customer_Payment (customer_id,cardholder_first_name,cardholder_mid_name,cardholder_last_name,cardtype,cardnumber,expiration_date,CC_ID,billing_address,billing_city,billing_state,billing_zip)
    VALUES (100001,'Andre',NULL,'Han','VISA','1234123412341234','01-JAN-2025',123,'Super Nice Street 7th','Austin','TX', '78705');
INSERT INTO Customer_Payment (customer_id,cardholder_first_name,cardholder_mid_name,cardholder_last_name,cardtype,cardnumber,expiration_date,CC_ID,billing_address,billing_city,billing_state,billing_zip)
    VALUES (100002,'Water',NULL,'Woo','VISA','4321432143214321','31-DEC-2025',321,'7 Glue Blue Rd','Austin','TX', '78705');

Commit;
-----Insert Reservation-----
INSERT INTO Reservation (customer_id,confirmation_nbr,date_created,check_in_date, check_out_date,reservation_status,discount_code,reservation_total,customer_rating,notes)
    VALUES (100001,'1234abcd','01-JAN-2021', '31-DEC-2021', NULL,'U',NULL,100,Null,Null);
INSERT INTO Reservation (customer_id,confirmation_nbr,date_created,check_in_date, check_out_date,reservation_status,discount_code,reservation_total,customer_rating,notes)
    VALUES (100002,'1234abce','01-JAN-2021', '10-DEC-2022', NULL,'I',NULL,50,Null,Null);
INSERT INTO Reservation(customer_id,confirmation_nbr,date_created,check_in_date, check_out_date,reservation_status,discount_code,reservation_total,customer_rating,notes)
    VALUES (100002,'1234abcf','01-JAN-2022', '10-DEC-2023', NULL,'I',NULL,50,Null,Null); 
Commit;
-----Insert Reservation Details-----
INSERT INTO Reservation_details (Reservation_ID,Room_ID,Number_of_guests)
    VALUES (1,3,2);
INSERT INTO Reservation_details (Reservation_ID,Room_ID,Number_of_guests)
    VALUES (2,1,2);
INSERT INTO Reservation_details (Reservation_ID,Room_ID,Number_of_guests)
    VALUES (3,2,2);
Commit;    
------------------------------Section Ends--------------------------------------

