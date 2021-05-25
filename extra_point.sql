# define a classification (it can be anything you want) for breaking the 
# customer account balances into 3 logical groups, and add a field for this new classification
SELECT *,
	CASE 
		WHEN C_ACCTBAL < 0 THEN 'Negative Balance Customer'
        WHEN C_ACCTBAL > 5000 THEN 'Target Customer'
        ELSE 'Moderate Balance Customer'
	END AS C_CUSTCATEGORY
FROM CUSTOMER;



#Add revenue(Orders_price) per line item
SELECT LI.*, O.O_TOTALPRICE
FROM LINEITEM LI
JOIN ORDERS O
ON O.O_ORDERKEY = LI.L_ORDERKEY;

