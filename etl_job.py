# import etl_scripts
from etl_scripts import *

# enter database details
user = 'root'  # please write your user name
password = 'Docomo123@'  # please write your password
host = 'localhost'  # please write your host address
port = 3306
database = 'beerwulf_schema'  # Please write your db name
if __name__ == '__main__':
    # Extract
    # specifying the zip file name and zip file extract path
    zip_name = 'data.zip'
    extract_path = 'data'
    extract_zip(zip_name, extract_path)

    # Load
    # establish connection
    engine = establish_connection(user, password, host, database)
    print('engine', engine)

    # Transform
    # write table name
    sql_table = ["REGION", "PART", "NATION", "SUPPLIER",
                 "PARTSUPP", "CUSTOMER", "ORDERS", "LINEITEM"]

    for table in sql_table:
        # path, where data is located
        path = 'data/'
        data = transform_table(table, path, engine)
        print(data.head())

        # insert data to sql
        insert_data_sql(data, table, engine)
