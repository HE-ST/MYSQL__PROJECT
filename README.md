# MySQL Layoffs Data Cleaning & Exploratory Data Analysis

A SQL-based data analytics project focused on cleaning, transforming, and analyzing global company layoffs data using **MySQL 8.0**.

## Project Overview

This project explores global layoffs across companies, industries, and countries. It uses SQL techniques to clean raw data, remove duplicate records, standardize inconsistent values, handle missing data, and perform exploratory data analysis.

The main objective is to transform raw layoffs data into a reliable dataset that can be used for meaningful business analysis.

## Objectives

- Understand and explore the raw layoffs dataset.
- Identify and remove duplicate records.
- Standardize inconsistent company, industry, country, and date values.
- Handle NULL and blank values.
- Convert date values into appropriate SQL data types.
- Perform exploratory data analysis using MySQL.
- Identify trends in layoffs across companies, industries, and countries.

## Tools & Technologies

| Tool | Purpose |
|---|---|
| MySQL 8.0 | Database management and SQL analysis |
| MySQL Workbench | SQL query execution |
| Visual Studio Code | SQL script development |
| Git & GitHub | Version control and project hosting |

## Dataset Information

The dataset contains company layoff information, including:

| Column | Description |
|---|---|
| company | Company name |
| location | Company location |
| industry | Industry category |
| total_laid_off | Number of employees laid off |
| percentage_laid_off | Percentage of employees laid off |
| date | Date of layoffs |
| stage | Company funding stage |
| country | Country where layoffs occurred |
| funds_raised_millions | Funds raised by the company in millions |

### Dataset Statistics

| Metric | Value |
|---|---:|
| Original records | 2,361 |
| Duplicate rows identified | 5 |
| Records with both layoff values NULL | 362 |
| Final cleaned records | 1,995 |
| Earliest layoff date | 2020-03-11 |
| Latest layoff date | 2023-03-06 |

## Project Structure

```text
MYSQL__PROJECT/
│
├── layoffs.csv
│
├── 01_data_cleaning_final.sql
│
├── MYSQL Exploritry data Analysis.sql
│
├── README.md
│
└── LICENSE
```

## Data Cleaning Process

The data cleaning process includes the following steps:

### 1. Data Exploration
- Inspected the original dataset.
- Checked table structure and column data types.
- Calculated the total number of records.
- Identified missing values.

### 2. Duplicate Removal
- Used `ROW_NUMBER()` window function.
- Identified duplicate records using multiple columns.
- Removed duplicate rows while preserving one record from each duplicate group.

### 3. Data Standardization
- Used `TRIM()` to remove unnecessary spaces from company names.
- Standardized cryptocurrency-related industry names to `Crypto`.
- Removed trailing periods from country names.
- Converted date values from text into the `DATE` data type.

### 4. Handling NULL Values
- Identified missing and blank values.
- Converted blank industry values into NULL.
- Filled missing industry values only when a company had exactly one known industry.
- Removed records where both `total_laid_off` and `percentage_laid_off` were NULL.
- Preserved missing values when the original dataset did not provide reliable information.

### 5. Final Validation
- Verified the cleaned record count.
- Checked for remaining duplicate records.
- Checked missing values.
- Verified date ranges and country formatting.

## Exploratory Data Analysis

The exploratory analysis investigates:

- Companies with the highest number of layoffs.
- Industries most affected by layoffs.
- Countries with the highest layoffs.
- Layoffs by year.
- Layoffs by month.
- Companies with the highest layoffs in each year.
- Rolling total of layoffs over time.
- Company funding stages and layoffs.

SQL concepts used include:

- Aggregate functions: `SUM()`, `AVG()`, `MAX()`, `MIN()`
- `GROUP BY` and `ORDER BY`
- Common Table Expressions (CTEs)
- Window functions
- `ROW_NUMBER()` and `DENSE_RANK()`
- Date functions
- Joins and subqueries

## How to Run This Project

### Prerequisites

- MySQL Server 8.0 or later
- MySQL Workbench
- Dataset file: `layoffs.csv`

### Step 1: Create the Database

```sql
CREATE DATABASE world_layoffs;
USE world_layoffs;
```

### Step 2: Import the Dataset

Import `layoffs.csv` into MySQL Workbench and create a table named:

```sql
layoffs
```

Make sure the table contains the nine columns listed in the Dataset Information section.

### Step 3: Run Data Cleaning

Open:

```text
01_data_cleaning_final.sql
```

Execute the SQL statements in MySQL Workbench.

The cleaned output is stored in:

```text
layoffs_staging_final
```

**Note:** The script recreates `layoffs_staging_final` when rerun. It does not modify the original `layoffs` table.

### Step 4: Run Exploratory Data Analysis

Open:

```text
MYSQL Exploritry data Analysis.sql
```

Execute the queries to explore layoffs trends and generate analytical insights.

## Key Findings from Data Cleaning

- Identified 5 duplicate rows.
- Found 362 records where both layoff figures were missing.
- Removed duplicate records and rows without layoff information.
- Reduced the dataset from 2,361 to 1,995 records.
- Verified that no duplicate records remained.
- Preserved original missing values instead of guessing unknown information.

## Skills Demonstrated

- MySQL and SQL programming
- Data Cleaning
- Data Transformation
- Exploratory Data Analysis (EDA)
- Window Functions
- Common Table Expressions (CTEs)
- Data Validation
- Problem Solving

## Future Improvements

- Build interactive dashboards using Power BI or Tableau.
- Perform deeper industry-wise and country-wise analysis.
- Create additional visualizations to communicate analytical findings.
- Explore trends and patterns in layoffs over time.

## Author

**Hemant Gehlot**

Computer Science Student | Aspiring Software Engineer

GitHub: [HE-ST](https://github.com/HE-ST)

---

If you find this project useful, feel free to explore the SQL scripts and datasets.
