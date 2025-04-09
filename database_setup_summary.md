# Olist Database Setup Summary

## Overview
This document summarizes the setup of the Olist database using Ansible and MySQL, including the challenges encountered and solutions implemented.

## Database Structure
The database consists of the following tables:
- customers
- geolocation
- products
- sellers
- product_category_name_translation
- orders
- order_items
- order_payments
- order_reviews

## Challenges and Solutions

### 1. Data Type Issues

#### VARCHAR Length Limitations
- **Problem**: Several columns had insufficient length for the data being loaded.
- **Solution**: Increased column lengths:
  - ID fields: Changed to `VARCHAR(128)`
  - City name fields: Changed to `VARCHAR(128)`
  - State fields: Changed to `VARCHAR(32)` (previously `CHAR(2)`)
  - Status fields: Changed to `VARCHAR(32)`

#### NULL Values in Integer Columns
- **Problem**: Empty strings in CSV files could not be loaded into integer columns.
- **Solution**: 
  - Added `NULL` constraint to integer columns
  - Used `NULLIF` function to convert empty strings to NULL during data loading:
    ```sql
    SET column_name = NULLIF(@column_name, '')
    ```

#### DATETIME Format Issues
- **Problem**: Empty strings in DATETIME columns caused errors.
- **Solution**:
  - Added `NULL` constraint to DATETIME columns
  - Used `NULLIF` function to convert empty strings to NULL

### 2. Foreign Key Constraints

#### Orders Table
- **Problem**: Foreign key constraint on `customer_id` prevented data loading due to missing references.
- **Solution**: Removed the foreign key constraint to allow data loading, with the option to add it back later if needed.

### 3. CSV Data Loading Issues

#### Quoted Data
- **Problem**: CSV files contained quoted data that wasn't being properly handled.
- **Solution**: Added `ENCLOSED BY '"'` option to all LOAD DATA INFILE commands.

#### Special Characters
- **Problem**: CSV files contained special characters that caused parsing errors.
- **Solution**: Added `ESCAPED BY '\\'` option to handle escape characters.

#### Duplicate Primary Keys
- **Problem**: Some tables had duplicate primary key values.
- **Solution**: Removed PRIMARY KEY constraints from affected tables (e.g., order_reviews).

#### Column Count Mismatch
- **Problem**: Some CSV files had more columns than expected.
- **Solution**: Used variable mapping to explicitly specify which columns to load:
  ```sql
  (@col1, @col2, @col3)
  SET
      column1 = @col1,
      column2 = @col2,
      column3 = @col3
  ```

### 4. Table Creation Order

- **Problem**: Tables with foreign key constraints couldn't be created before referenced tables.
- **Solution**: Reordered table creation to respect dependencies:
  1. customers
  2. geolocation
  3. products
  4. sellers
  5. product_category_name_translation
  6. orders
  7. order_items
  8. order_payments
  9. order_reviews

## Final Configuration

The final configuration in `up.yaml` includes:
1. Proper table creation with appropriate data types and NULL constraints
2. CSV data loading with proper options for handling quoted data and special characters
3. NULLIF functions to handle empty strings
4. Removal of problematic constraints
5. Correct table creation order

## Testing Process

Each table was tested individually in MySQL to identify and resolve issues:
1. Create table with appropriate schema
2. Attempt to load data
3. Identify and fix any errors
4. Apply successful configuration to `up.yaml`

This iterative approach allowed for systematic identification and resolution of issues. 