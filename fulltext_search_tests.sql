-- Full-text Search Tests
SET profiling = 1;

-- Create FULLTEXT index
SET @index_exists = (
    SELECT COUNT(1) 
    FROM information_schema.statistics 
    WHERE table_schema = DATABASE()
    AND table_name = 'products' 
    AND index_name = 'idx_product_category'
);

SET @sql = IF(@index_exists = 0,
    'ALTER TABLE products ADD FULLTEXT INDEX idx_product_category (product_category_name)',
    'SELECT "Index already exists"'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Basic Natural Language Search
SELECT product_id, product_category_name
FROM products
WHERE MATCH(product_category_name) AGAINST('automotivo' IN NATURAL LANGUAGE MODE)
LIMIT 10;

-- Boolean Mode Search
SELECT product_id, product_category_name
FROM products
WHERE MATCH(product_category_name) AGAINST('+automotivo -acessorios' IN BOOLEAN MODE)
LIMIT 10;

-- Performance Comparison
SELECT COUNT(*) as match_count
FROM products
WHERE MATCH(product_category_name) AGAINST('auto*' IN BOOLEAN MODE);

SELECT COUNT(*) as like_count
FROM products
WHERE product_category_name LIKE 'auto%';

-- Show timing results
SHOW PROFILES;

-- Additional useful queries for analysis:

-- Check index status
SELECT 'Index Status:' as section;
SHOW INDEX FROM products;

-- Check table status
SELECT 'Table Status:' as section;
SHOW TABLE STATUS LIKE 'products';

-- Memory usage for FULLTEXT index
SELECT 'Memory Usage for FULLTEXT index:' as section;
SELECT * FROM information_schema.INNODB_FT_INDEX_CACHE; 