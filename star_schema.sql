USE beerwulf_schema;

-- stage_table_one
DROP TABLE IF EXISTS stage_table_one;
CREATE TABLE stage_table_one (PRIKEY INT NOT NULL PRIMARY KEY AUTO_INCREMENT) AS
SELECT *, YEAR(O.O_ORDERDATE) AS O_ORDERYEAR, 
MONTH(O.O_ORDERDATE) AS O_ORDERMONTH, DAY(O.O_ORDERDATE) AS O_ORDERDAY
FROM LINEITEM L
JOIN ORDERS O  
ON L.L_ORDERKEY = O.O_ORDERKEY
JOIN CUSTOMER C
ON C.C_CUSTKEY = O.O_CUSTKEY
JOIN NATION N
ON N.N_NATIONKEY = C.C_NATIONKEY
JOIN REGION R
ON R.R_REGIONKEY = N.N_REGIONKEY
;

-- stage_table_two
DROP TABLE IF EXISTS stage_table_two;
CREATE TABLE stage_table_two AS 
SELECT *
FROM LINEITEM L
JOIN PART P 
ON P.P_PARTKEY =  L.L_PARTKEY
JOIN PARTSUPP PS 
ON PS.PS_PARTKEY = P.P_PARTKEY
JOIN SUPPLIER S
ON S.S_SUPPKEY = PS.PS_SUPPKEY
JOIN NATION N
ON S.S_NATIONKEY = N.N_NATIONKEY
;

-- DIM_CUSTOMER

DROP TABLE IF EXISTS DIM_CUSTOMER;
CREATE TABLE DIM_CUSTOMER (
  C_CUSTKEY    INTEGER PRIMARY KEY NOT NULL,
  C_NAME       TEXT NOT NULL,
  C_ADDRESS    TEXT NOT NULL,
  C_NATION    TEXT NOT NULL,
  C_PHONE      TEXT NOT NULL,
  C_ACCTBAL    INTEGER NOT NULL,
  C_MKTSEGMENT TEXT NOT NULL,
  C_COMMENT    TEXT NOT NULL
  );
  
INSERT INTO DIM_CUSTOMER
SELECT DISTINCT sto.C_CUSTKEY, sto.C_NAME, sto.C_ADDRESS, sto.N_NAME, sto.C_PHONE, sto.C_ACCTBAL, sto.C_MKTSEGMENT, sto.C_COMMENT 
FROM stage_table_one sto;

 -- DIM_ORDERS
 
DROP TABLE IF EXISTS DIM_ORDERS;
CREATE TABLE DIM_ORDERS (
  O_ORDERKEY      INTEGER PRIMARY KEY NOT NULL,
  O_ORDERSTATUS   TEXT NOT NULL,
  O_ORDERPRIORITY TEXT NOT NULL,  
  O_CLERK         TEXT NOT NULL, 
  O_SHIPPRIORITY  INTEGER NOT NULL,
  O_COMMENT       TEXT NOT NULL
  );

  
INSERT INTO DIM_ORDERS
SELECT DISTINCT sto.O_ORDERKEY, sto.O_ORDERSTATUS, sto.O_ORDERPRIORITY, sto.O_CLERK, sto.O_SHIPPRIORITY, sto.O_COMMENT
FROM stage_table_one sto;

-- DIM_ORDER_DATE

DROP TABLE IF EXISTS DIM_ORDER_DATE;
CREATE TABLE DIM_ORDER_DATE (
  PRIKEY INTEGER PRIMARY KEY NOT NULL,
  O_ORDERDATE	DATE NOT NULL,
  O_ORDERYEAR   SMALLINT NOT NULL,
  O_ORDERMONTH SMALLINT NOT NULL,  
  O_ORDERDAY SMALLINT NOT NULL
  );
  
INSERT INTO DIM_ORDER_DATE
SELECT DISTINCT sto.PRIKEY, sto.O_ORDERDATE, sto.O_ORDERYEAR, sto.O_ORDERMONTH, sto.O_ORDERDAY
FROM stage_table_one sto;

-- DIM_SUPPLIER

DROP TABLE IF EXISTS DIM_SUPPLIER;
CREATE TABLE DIM_SUPPLIER (
S_SUPPKEY   INTEGER PRIMARY KEY NOT NULL,
S_NAME      TEXT NOT NULL,
S_ADDRESS   TEXT NOT NULL,
S_NATION 	  TEXT NOT NULL,
S_PHONE     TEXT NOT NULL,
S_ACCTBAL   INTEGER NOT NULL,
S_COMMENT   TEXT NOT NULL
);
  
INSERT INTO DIM_SUPPLIER
SELECT DISTINCT st.S_SUPPKEY, st.S_NAME, st.S_ADDRESS, st.N_NAME, st.S_PHONE, st.S_ACCTBAL, st.S_COMMENT 
FROM stage_table_two st;

-- DIM_PART

DROP TABLE IF EXISTS DIM_PART;  
CREATE TABLE DIM_PART (
P_PARTKEY     INTEGER PRIMARY KEY NOT NULL,
P_NAME        TEXT NOT NULL,
P_MFGR        TEXT NOT NULL,
P_BRAND       TEXT NOT NULL,
P_TYPE        TEXT NOT NULL,
P_SIZE        INTEGER NOT NULL,
P_CONTAINER   TEXT NOT NULL,
P_RETAILPRICE INTEGER NOT NULL,
P_COMMENT     TEXT NOT NULL
);

INSERT INTO DIM_PART
SELECT DISTINCT st.P_PARTKEY, st.P_NAME, st.P_MFGR, st.P_BRAND, st.P_TYPE, st.P_SIZE, st.P_CONTAINER, st.P_RETAILPRICE, st.P_COMMENT
FROM stage_table_two st;

-- DIM_LINEITEM

DROP TABLE IF EXISTS DIM_LINEITEM;
CREATE TABLE DIM_LINEITEM (
  PRIKEY    INTEGER PRIMARY KEY NOT NULL,
  L_LINENUMBER    INTEGER NOT NULL,
  L_RETURNFLAG    TEXT NOT NULL,
  L_LINESTATUS    TEXT NOT NULL,
  L_SHIPINSTRUCT  TEXT NOT NULL,
  L_SHIPMODE      TEXT NOT NULL,
  L_COMMENT       TEXT NOT NULL
  );

INSERT INTO DIM_LINEITEM
SELECT DISTINCT sto.PRIKEY, sto.L_LINENUMBER, sto.L_RETURNFLAG, sto.L_LINESTATUS, sto.L_SHIPINSTRUCT, 
sto.L_SHIPMODE, sto.L_COMMENT
FROM stage_table_one sto;

-- FACT_MODEL_ONE

DROP TABLE IF EXISTS FACT_MODEL_ONE;  
CREATE TABLE FACT_MODEL_ONE (
PRIKEY       INTEGER NOT NULL,
C_CUSTKEY	INTEGER NOT NULL,
O_ORDERKEY     INTEGER NOT NULL,
L_QUANTITY      INTEGER NOT NULL,
L_EXTENDEDPRICE INTEGER NOT NULL,
L_DISCOUNT      INTEGER NOT NULL,
L_TAX           INTEGER NOT NULL,
O_TOTALPRICE   INTEGER NOT NULL,
O_ORDERDATE  DATE NOT NULL
);

INSERT INTO FACT_MODEL_ONE
SELECT DISTINCT DL.PRIKEY, DC.C_CUSTKEY, DOR.O_ORDERKEY, sto.L_QUANTITY, 
sto.L_EXTENDEDPRICE, sto.L_DISCOUNT, sto.L_TAX, sto.O_TOTALPRICE, DOD.O_ORDERDATE
FROM stage_table_one sto 
JOIN DIM_CUSTOMER DC ON
DC.C_CUSTKEY = sto.C_CUSTKEY
JOIN DIM_ORDERS DOR ON
DOR.O_ORDERKEY = sto.O_ORDERKEY
JOIN DIM_ORDER_DATE DOD ON
DOD.PRIKEY = DOR.O_ORDERKEY
JOIN DIM_LINEITEM DL ON
DL.PRIKEY = sto.PRIKEY;


-- FACT_MODEL_TWO
DROP TABLE IF EXISTS FACT_MODEL_TWO;  
CREATE TABLE FACT_MODEL_TWO (
S_SUPPKEY    INTEGER NOT NULL,
P_PARTKEY     INTEGER NOT NULL,
PS_AVAILQTY	  INTEGER NOT NULL,
PS_SUPPLYCOST INTEGER NOT NULL,
P_RETAILPRICE INTEGER NOT NULL
);

INSERT INTO FACT_MODEL_TWO
SELECT DISTINCT DS.S_SUPPKEY, DP.P_PARTKEY, st.PS_AVAILQTY, 
st.PS_SUPPLYCOST, st.P_RETAILPRICE
FROM stage_table_two st 
JOIN DIM_SUPPLIER DS ON
DS.S_SUPPKEY = st.S_SUPPKEY
JOIN DIM_PART DP ON
DP.P_PARTKEY = st.P_PARTKEY
;


