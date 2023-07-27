https://data.bs.ch/api/explore/v2.1/catalog/datasets/100097/exports/csv?lang=en&timezone=Europe%2FZurich&use_labels=true&delimiter=%3B
SELECT * FROM read_csv_auto('https://data.bs.ch/api/explore/v2.1/catalog/datasets/100097/exports/csv');


SELECT mean(lufttemperatur) as mean_lufttemperatur FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests100009-cleaned.parquet' WHERE name ILIKE 'B%' GROUP BY name;
SELECT mean(lufttemperatur) as mean_lufttemperatur FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests100009-cleaned.csv' WHERE name ILIKE 'B%' GROUP BY name;

The first step to profiling a database engine is figuring out what execution plan the engine is using. The EXPLAIN statement allows you to peek into the query plan and see what is going on under the hood.

The EXPLAIN statement displays three query plans that show what the plan looks like as it passes the various stages of the execution engine. The logical_plan is the initial unoptimized plan as it is created right after parsing. The logical_opt is the optimized logical plan, that demonstrates the equivalent but optimized logical plan after it passes the optimization phase. This optimized plan is then transformed into the physical_plan, which is the plan that will actually get executed.

EXPLAIN SELECT mean(lufttemperatur) as mean_lufttemperatur FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests100009-cleaned.csv' WHERE name ILIKE 'B%' GROUP BY name;
EXPLAIN SELECT mean(lufttemperatur) as mean_lufttemperatur FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests100009-cleaned.parquet' WHERE name ILIKE 'B%' GROUP BY name;

The query plan helps understand the performance characteristics of the system. However, often it is also necessary to look at the performance numbers of individual operators and the cardinalities that pass through them. For this, you can create a query-profile graph.

To create the query graphs it is first necessary to gather the necessary data by running the query. In order to do that, we must first enable the run-time profiling. This can be done by prefixing the query with EXPLAIN ANALYZE:


PRAGMA enable_profiling='json';
EXPLAIN ANALYZE SELECT mean(lufttemperatur) as mean_lufttemperatur FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests100009-cleaned.csv' WHERE name ILIKE 'B%' GROUP BY name;
PRAGMA profile_output='/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests100009-cleaned-csv--profiling.json';
SELECT mean(lufttemperatur) as mean_lufttemperatur FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests100009-cleaned.csv' WHERE name ILIKE 'B%' GROUP BY name;

EXPLAIN ANALYZE SELECT mean(lufttemperatur) as mean_lufttemperatur FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests100009-cleaned.parquet' WHERE name ILIKE 'B%' GROUP BY name;
PRAGMA profile_output='/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests100009-cleaned-parquet--profiling.json';
SELECT mean(lufttemperatur) as mean_lufttemperatur FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests100009-cleaned.parquet' WHERE name ILIKE 'B%' GROUP BY name;



---
https://duckdb.org/docs/guides/meta/explain_analyze.html
"Note that the cumulative wall-clock time that is spent on every operator is shown. When multiple threads are processing the query in parallel, the total processing time of the query may be lower than the sum of all the times spent on the individual operators."

PRAGMA enable_profiling;
PRAGMA profile_output='/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests/100009-cleaned-csv--simple-select--profiling.json';
SELECT * FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests/data/100009-cleaned.csv';
PRAGMA disable_profiling;

PRAGMA enable_profiling;
PRAGMA profile_output='/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests/100009-cleaned-parquet--simple-select--profiling.json';
SELECT * FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests/data/100009-cleaned.parquet';
PRAGMA disable_profiling;

PRAGMA enable_profiling=['json', 'query_tree', 'query_tree_optimizer'];
PRAGMA profile_output='/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests/100009-cleaned-csv--select-lufttemperatur-criterion--profiling.json';
SELECT * FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests/data/100009-cleaned.csv' WHERE lufttemperatur < 15;
PRAGMA disable_profiling;

PRAGMA enable_profiling=['json', 'query_tree', 'query_tree_optimizer'];
PRAGMA profile_output='/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests/100009-cleaned-parquet--select-lufttemperatur-criterion--profiling.json';
SELECT * FROM '/Users/ralph/Documents/GitHub/rastrau/parquet-duckdb-tests/data/100009-cleaned.parquet' WHERE lufttemperatur < 15;
PRAGMA disable_profiling;