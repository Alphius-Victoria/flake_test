# dbtFlake
*dbtFlake* is a starter kit for dbt + Snowflake project. It's beginner-friendly package designed to help data & analytical engineers to quickly set up and start using dbt for data transformation in their data platform. 

It includes predefined templates, configurations, and best practices to streamline the initial setup process

## Table of Content

- [Supported Adapters](#supported-adapters)
- [Prerequisites](#Prerequisites)
- [Features](#features)
  - [Medallion Architecture](#medallion-architecture)
  - [Data Profiling](#data-profiling-source)
  - [Date Dimension](#date-dimension-source)
  - [Model Execution Time](#model-execution-time-source)
  - [Pre-Commit](#pre-commit)
  - [CI/CD](#cicd)
  - [SQLFluff](#sqlfluff)
  - [Source Freshness Table](#source-freshness-results-source)
- [Upcoming Features](#upcoming-features)
- [Feedback](#feedback)
- [Contact](#contact)

## Supported Adapters

**dbtFlake** supports the following adapters:

✅ Snowflake  
❌ Databricks   
❌ Redshift  
❌ BigQuery

## Prerequisites

- **dbtFlake** requires the dbt version **>=1.7.0**
- Install the required packages using the command `pip3 install -r requirements.txt`
  
- **Database Setup**

    - **1. Create Separate Databases:**
Maintain distinct databases for a structured environment. Ensure that the necessary databases are created in your data warehouse.
      - i.e., `ANALYTICS_<env>_STAGING`, `ANALYTICS_<env>_CORE`, `ANALYTICS_<env>_PRESENTATION`, `GOVERNANCE_<env>`

    - **2. Map the Existing Databases:**
Configure the databases with dbt by using the `dbt_project.yml` file

    <!-- > **_Note:_** If you don't know how to configure, please check [here] -->

- Run `dbt deps` to install required packages
- Run the command to trigger the run_result model as one-off `dbt run --select run_result`

## Features

- [x] **Medallion Architecture**: The medallion architecture organizes data into bronze, silver, and gold layers for improved data quality and accessibility
- [x] **Data Profiling**: Data profiling involves analyzing data to understand its structure, content, and quality, with metadata configurations.
- [x] **Date Dimension**: It contains date related attributes and metrics for time based analysis and reporting
- [x] **Pre Commit Checks**: Pre-commit checks are automated tests that ensure software engineering best practices before committing them into a version control system.
- [x] **CI/CD**: It's workflow to validate the scripts, structure, and outputs before deploying into Production Environment.
- [x] **SQLFluff**: SQLFluff is a tool for analyzing and formatting SQL queries to enforce coding standards and best practices
- [x] **Source Freshness Result**: A source freshness result table indicates the current data status for analysis or operations



### Medallion Architecture

Medallion Architecture is a data processing framework that organizes data into Bronze, Silver, and Gold layers to streamline data ingestion, transformation, and analytics.

```
Medallion Architecture

 models
 ├── 01_stg
 |   ├── hubspot
 |   |   ├── customer.sql
 |   |   └── product.sql
 |   └── jin
 |       ├── user.sql
 |       ├── billing.sql
 |       └── Product.sql
 ├── 02_core
 |   ├── 01_pre_prep
 |   |   ├── int_customer.sql
 |   |   └── int_product.sql
 |   ├── 02_prep
 |   |   ├── prep_customer.sql
 |   |   └── prep_product.sql
 |   └── 03_conformed
 |       ├── customer.sql
 |       ├── product.sql
 |       ├── date.sql
 |       └── billing.sql
 ├── 03_presentation
 |   ├── 01_datamart
 |   |   ├── dim
 |   |   |   ├── dim_date.sql
 |   |   |   └── dim_user.sql
 |   |   └── fact
 |   |   |   ├── fact_billing.sql
 |   |   |   └── fact_authorisation.sql
 |   └── 02_report
 |       ├── rpt_finance
 |       |   ├── rpt_finance_dashboard.sql
 |       |   └── rpt_budget.sql
 |       └── rpt_sales
 ├── 04_governance
 |
 └── sources.yml
```
If you want to know more about Medallion Architecture, [Click Here](https://medium.com/@sivailango.s/principles-of-data-layers-in-data-platform-a336a0ff9e1e)

> **_Note:_** `02_core/01_pre_prep` is optional. use if needed, otherwise it can be avoided.

***

### Data Profiling ([source](models/04_governance/data_profile/profile.sql))
This model profiles data from a specified source table and creates a destination table along with profiling information. A calculated profile includes various [measures](docs/reference/profile.md) to support data exploration.

#### Usage

Following variables need to be defined in your `dbt_project.yml` file:

```
vars:
  profiling:
    destination_database: <Your_Profile_destination_database>
    config_database: <Configuration_file_database_name>
    config_schema: <Configuration_file_schema_name>
    config_table:  <Configuration_file_table_name>
```
This configuration block defines variables for data profiling. It sets the destination database for profiling results and the database, schema, and table where the profiling configuration is stored. 

#### Update the seed file

`seeds/governance/config/config_data_profile.csv`

```
| destination_schema | destination_table | source_database | source_schema | include_tables   | exclude_tables |
| ------------------ | ----------------- | --------------- | ------------- | ---------------  | -------------- |
| data_dev           | profiling         | raw             | dbt           |                  |                |
| data_dev           | profiling         | raw             | dbt           | "orders,payment" |                |
| data_dev           | profiling         | raw             | dbt           |                  | payment        |
```

* The first configuration example profiles all tables in the dbt schema.
* The second configuration example profiles only the orders and payment tables in the dbt schema.
* The third configuration example profiles all tables in the dbt schema except the payment table.

#### To run the seed file

```
dbt seed -s config_data_profile --full-refresh
```

#### To run the model

```
dbt run -m profile
```
***
### Date Dimension ([source](models/02_core/02_conformed/date.sql))

This model handles common date logic and calendar functionality by generating a detailed date dimension table for a specified range.

#### Usage

Update the start date & end date in `models/02_core/03_core/date.sql`

```
-- Declaring the start date and end data
{% set start_date = '2019-02-12' %}           -- Start date(yyyy-mm-dd)
{% set end_date = '2024-07-20' %}             -- End date(yyyy-mm-dd)

```

> **_Note:_** `uk_holidays.csv` contains data from the year 2000 to 2050. Update the seed file, if required.

#### To run the model

By using an below command, we can run the dimension date table
```
dbt run -m date
```

***

### Model Execution Time ([source](models/04_governance/monitor/dbt_results.sql))

Stores the execution times of each dbt runs, facilitating historical analysis implementing incremental materialization, retaining only relevant data within the specified rolling back period through a post-hook deletion.

#### Usage

Update the rolling_back_period in `dbt_project.yml` to delete the records older than the specified period.

```
vars:
  run_result:
    rolling_back_period: 30
```

#### To run the model 

```
dbt run -m run_result
```

> **_Note:_**  We need to run the above command as a one-off. After creating the structure, posthook will insert all execution times after running each model.

***

### Pre-Commit

Run pre-commit checks to ensure code quality and consistency before committing changes.

#### To enable pre-commit checks in dbt-core

By using the command below, pre-commit will perform checks on every Git commit.

```
pre-commit install --hook-type pre-commit --hook-type pre-push --hook-type commit-msg
```

For more information about pre-commits, [click here](docs/reference/pre-commit.md)

> **_Note:_** If you're using dbt-core, it will perform checks before committing your changes. For dbt Cloud, it will perform the checks only in post-push.

***

### CI/CD

A CI pipeline streamlines code building, testing, and deployment into a unified process, ensuring that changes to the main branch are always ready for production. By automating these steps, CI pipelines minimize manual errors.

#### Below is a list of the version control tools supported by dbtFlake:

```
|-----------------------|--------------------------------------|-------------------------------------|
|                       |               dbt-core               |               dbt-cloud             |
| Version Control Tools |--------------------------------------|-------------------------------------|
|                       |         CI     |   Daily Schedule    |        CI     |   Daily Schedule    |
|-----------------------|----------------|---------------------|---------------|---------------------|
|      GitHub           |    Available   |       Available     |               |                     |
|-----------------------|----------------|---------------------|---------------|---------------------|
|     Azure Devops      |    Available   |       Available     |               |                     |
|-----------------------|----------------|---------------------|---------------|---------------------|
|      GitLab           |                |                     |               |                     |
|-----------------------|----------------|---------------------|---------------|---------------------|

```

#### Usage:
Configure the production database and roles in dbt_project.yml for cloning and granting access.

```
vars:
  # CI databases access
  ci:
    prod_databases: ['Database 1', 'Database 2', ...., 'Database N']
    read_access: ['Role 1', 'Role 2', ....., 'Role N']
```


> **_Note:_** CI databases will be automatically created when you open a PR from any release branch to the CI branch, and they will be automatically dropped once the Pull request to the main branch is completed.



 you want to know more about CI Process, [Click Here](docs/reference/cicd.md)

***

### SQLFluff

SQLFluff is a SQL linter and formatter for enforcing coding standards and style consistency in SQL code. It helps detect and fix syntax issues, formatting discrepancies, and style violations, ensuring high-quality, maintainable SQL code across your projects.

#### Lint

To check your SQL files for linting issues, the command below:

```
sqlfluff lint path/to/your/sql/files
```
Replace `path/to/your/sql/files` with the path to your SQL files or directory.

#### Fix

To automatically fix linting issues, run the command below

```
sqlfluff fix path/to/your/sql/files
```

This command will attempt to correct the formatting and style issues in your SQL files.

***

### Source Freshness Results ([source](models/04_governance/monitor/dbt_source_freshness.sql))

This model stores the freshness results of the tables, facilitating historical analysis implementing incremental materialization, retaining only relevant data within the specified rolling back period through a post-hook deletion.

#### Usage

Update the rolling_back_period in `dbt_project.yml` to delete the records older than the specified period.

```
vars:
  source_freshness:
    rolling_back_period: 30
```

#### To run the model

```
dbt run -m dbt_source_freshness
```

## Upcoming Features
- [ ] PII Masking - [Track The Development Status Here](https://github.com/jmangroup/dbtFlake/issues/18)
- [ ] Data Anonymization - [Track The Development Status Here](https://github.com/jmangroup/dbtFlake/issues/19)
- [ ] Pre-defined macros & Unit tests


## Feedback
*If you have a new idea for a dbt starter kit or you found a bug, [**let us know**](https://github.com/jmangroup/dbtFlake/issues/new/choose)*

## Contact
- **[Vignesh Anantharaj](mailto:vignesh@jmangroup.com)**
- **[Rishikar B](mailto:rishikar@jmangroup.com)**
- **[Harishmitha Rajendran](mailto:harishmitha@jmangroup.com)**