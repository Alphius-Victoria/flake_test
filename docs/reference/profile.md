For each column in a table, a calculated profile includes the following measures:

- `database` : Database name
- `schema` : Schema name
- `table_name` : Table name
- `column_name` : Name of the column
- `data_type` : Data type of the column
- `row_count` : Column based row count
- `not_null_count` : Count the not_null values based on columns
- `not_null_percentage` : Percentage of column values that are not NULL
- `null_count`: Count the null values by column based on columns
- `null_percentage` : Percentage of column values that are NOT_NULL
- `distinct_percentage` : Percentage of unique column values (e.g., 1 means that 100% of the values are unique)
- `distinct_count` : Count of unique column values
- `is_unique` : True if all column values are unique
- `min` : Minimum column value
- `max` : Maximum column value
- `avg` : Average column value
- `profiled_at` : Date and time (UTC time zone) of the profiling

### Sample Output

```
|    DATABASE           | SCHEMA | TABLE_NAME | COLUMN_NAME         | DATA_TYPE | ROW_COUNT | NOT_NULL_COUNT | NULL_COUNT | NOT_NULL_PERCENTAGE| NULL_PERCENTAGE | DISTINCT_COUNT | DISTINCT_PERCENT |IS_UNIQUE | MIN      | MAX 	    |    AVG 	       |      PROFILED_AT           |
| ----------------------| -------| -----------|-------------------- | ----------|---------- | -------------- | ---------  | ------------------ | --------------- | -------------- | -----------------| -------- | ---------|------------|------------------|----------------------------|
|SNOWFLAKE_SAMPLE_DATA  |TPCH_SF1| ORDERS     | O_ORDERKEY          | NUMBER    |1500000    |1500000         |	0	      | 100.00     	       |0.00		     |1500000         |100.00	         |TRUE	    |1         |6000000     |2999991.50        |2022-12-06T09:05:18.183Z	|
|SNOWFLAKE_SAMPLE_DATA  |TPCH_SF1| ORDERS     | O_CUSTKEY           | NUMBER	|1500000    |1500000         |	0         | 100.00     	       |0.00		     |99996		      |6.67		         |FALSE	    |1    	   |149999      |75006.04          |2022-12-06T09:05:18.183Z	|
|SNOWFLAKE_SAMPLE_DATA  |TPCH_SF1| ORDERS     | O_ORDERSTATUS       | VARCHAR	|1500000    |1500000         |	0         | 100.00             |0.00		     |3               |0.00		         |FALSE	    |null      |null        |null              |2022-12-06T09:05:18.183Z	|
|SNOWFLAKE_SAMPLE_DATA  |TPCH_SF2| CUSTOMERS  | O_TOTALPRICE        | NUMBER	|1500000    |1500000	     |	0         | 100.00             |0.00		     |1464556	      |97.64 	         |FALSE	    |857.71    |555285.16   |151219.54         |2022-12-06T09:05:18.183Z	|
|SNOWFLAKE_SAMPLE_DATA  |TPCH_SF2| CUSTOMERS  | O_ORDERDATE         | DATE	    |1500000    |1500000         |	0         | 100.00             |0.00		     |2406		      |0.16		         |FALSE	    |1992-01-01|1998-08-02  |null              |2022-12-06T09:05:18.183Z	|
|SNOWFLAKE_SAMPLE_DATA  |TPCH_SF2| CUSTOMERS  | O_ORDERPRIORITY     | VARCHAR	|1500000    |1500000         |	0         | 100.00	           |0.00		     |5     	      |0.00		         |FALSE	    |null      |null        |null              |2022-12-06T09:05:18.183Z	|
|SNOWFLAKE_SAMPLE_DATA  |TPCH_SF3| DELIVERY   | O_CLERK             | VARCHAR	|1500000    |1500000         |	0         | 100.00             |0.00		     |1000		      |0.07   	         |FALSE	    |null      |null        |null              |2022-12-06T09:05:18.183Z	|
|SNOWFLAKE_SAMPLE_DATA  |TPCH_SF3| DELIVERY   | O_SHIPPRIORITY      | NUMBER	|1500000    |1500000         |	0         | 100.00             |0.00		     |1		          |0.00		         |FALSE	    |0         |0           |0.00              |2022-12-06T09:05:18.183Z	|
|SNOWFLAKE_SAMPLE_DATA  |TPCH_SF3| DELIVERY   | O_COMMENT           | VARCHAR	|1500000    |1500000         |	0         | 100.00             |0.00		     |1482071         |98.80	         |FALSE	    |null      |null        |null              |2022-12-06T09:05:18.183Z	|
```