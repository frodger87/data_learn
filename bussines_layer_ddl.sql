create schema dw;

-- ************************************** ship_mode

CREATE TABLE dw.ship_mode
(
 ship_id   int NOT NULL,
 ship_mode varchar NOT NULL,
 CONSTRAINT PK_1 PRIMARY KEY ( ship_id )
);

--insert into ship_mode

INSERT INTO dw.ship_mode 
SELECT 
	ROW_NUMBER() OVER(),
	ship_mode 
FROM 
	(SELECT DISTINCT 
		ship_mode
	FROM 
		stg.orders
) AS t;


CREATE TABLE dw.customer
(
 row_customer_id int NOT NULL,
 customer_id     varchar NOT NULL,
 customer_name   varchar NOT NULL,
 CONSTRAINT PK_11 PRIMARY KEY ( row_customer_id )
);

--insert customer
INSERT INTO dw.customer
SELECT 
    ROW_NUMBER() OVER(),
    customer_id,
    customer_name
FROM
    (SELECT
        customer_id,
        customer_name
    FROM
      stg.orders
) AS t

-- ************************************** product
CREATE TABLE dw.product
(
 row_product_id int NOT NULL,
 product_id     varchar NOT NULL,
 product_name   varchar NOT NULL,
 segment        varchar NOT NULL,
 category       varchar NOT NULL,
 subcategoty    varchar NOT NULL,
 CONSTRAINT PK_12 PRIMARY KEY ( row_product_id )
);

--insert product
INSERT INTO dw.product 
SELECT 
    ROW_NUMBER () OVER(),
    product_id,
    product_name,
    segment,
    category,
    subcategory
FROM (
      SELECT 
          product_id,
          product_name,
          segment,
          category,
          subcategory
      FROM 
          stg.orders
) AS t;


-- ************************************geo_data

CREATE TABLE dw.geo_data
(
 geo_id      int NOT NULL,
 country      varchar NOT NULL,
 city        varchar NOT NULL,
 "state"       varchar NOT NULL,
 postal_code varchar NULL,
 region      varchar NOT NULL,
 CONSTRAINT PK_geo_data PRIMARY KEY ( geo_id )
);

--insert geo
INSERT INTO dw.geo_data 
SELECT 
    ROW_NUMBER () OVER(),
    country,
    city,
    "state",
    postal_code,
    region
FROM (
      SELECT 
          country,
          city,
          "state",
          postal_code,
          region
      FROM 
          stg.orders
) AS t;

--decide problem with raw data
UPDATE dw.geo_data
SET postal_code = '05401'
WHERE 
    city = 'Burlington'  
    AND postal_code is null;


--CALENDAR use function instead 
-- examplehttps://tapoueh.org/blog/2017/06/postgresql-and-the-calendar/

--creating a table
CREATE TABLE dw.calendar_dim
(
dateid serial  NOT NULL,
year        int NOT NULL,
quarter     int NOT NULL,
month       int NOT NULL,
week        int NOT NULL,
date        date NOT NULL,
week_day    varchar(20) NOT NULL,
leap  varchar(20) NOT NULL,
CONSTRAINT PK_calendar_dim PRIMARY KEY ( dateid )
);

--insert calendar
INSERT INTO dw.calendar_dim 
SELECT 
    to_char(date,'yyyymmdd')::int AS date_id,  
    extract('year' FROM date)::int AS year,
    extract('quarter' FROM date)::int AS quarter,
    extract('month' FROM date)::int AS month,
    extract('week' FROM date)::int AS week,
    date::date,
    to_char(date, 'dy') AS week_day,
    extract('day' FROM
         (date + interval '2 month - 1 day')
        ) = 29
    as leap
FROM 
    generate_series(date '2000-01-01',
                       date '2030-01-01',
                       interval '1 day')
       AS t(date);



