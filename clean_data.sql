USE world_layoffs;

SELECT *
FROM layoffs;

CREATE TABLE layoffs2
LIKE layoffs;

INSERT layoffs2
SELECT * 
FROM layoffs;

SELECT COUNT(*)
FROM layoffs2;

SHOW COLUMNS FROM layoffs2;

-- Remove dupes
# find out how many distinct rows there are
CREATE TABLE temp_table AS
SELECT DISTINCT * FROM layoffs2;

# clear layoffs2 table and fill it with the distinct rows
TRUNCATE TABLE layoffs2;
INSERT INTO layoffs2 SELECT * FROM temp_table;

# check if there is any duplicates left
SELECT *, COUNT(*)
FROM layoffs2;

SELECT *, COUNT(*) ct
FROM layoffs2
GROUP BY company,
location,
industry,
total_laid_off,
percentage_laid_off,
date,
stage,
country,
funds_raised_millions
HAVING ct > 1;

DROP TABLE temp_table1;

-- Standardize
# Trim company names
SELECT DISTINCT company, TRIM(company)
FROM layoffs2;

UPDATE layoffs2
SET company = TRIM(company);

# change similar industries into one name
SELECT DISTINCT industry, TRIM(industry)
FROM layoffs2
ORDER BY 1;

UPDATE layoffs2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs2
ORDER BY 1;

UPDATE layoffs2
SET country = 'United States'
WHERE country LIKE 'United State%';

# convert data type of date from str to date
SELECT date
FROM layoffs2;

UPDATE layoffs2
SET date = str_to_date(date, '%m/%d/%Y');

ALTER TABLE layoffs2
MODIFY COLUMN date DATE;

-- Null values
SELECT *
FROM layoffs2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs2
WHERE company = 'Airbnb';

# fill industry if another entry of the same company has the field filled
SELECT *
FROM layoffs2
WHERE industry IS NULL OR industry = '';

SELECT t1.industry, t2.industry
FROM layoffs2 t1
JOIN layoffs2 t2
	ON t1.company = t2.company AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

# change all blank industry field to NULL
UPDATE layoffs2
SET industry = NULL
WHERE industry = '';

# update all NULL value if the same company has an entry with industry field filled
UPDATE layoffs2 t1
JOIN layoffs2 t2
	ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

# one last company Bally's Interactive has null value in industry
# a google search reveals that it's in the entertainment industry
SELECT DISTINCT industry
FROM layoffs2;

# There is no entertainment industry in the list
# lookup similar companies and their industries
SELECT company, industry
FROM layoffs
WHERE company LIKE '%Interactive%' OR company LIKE '%Game%';
# game companies are all over the place, with industry labeled as Other, Consumer, Crypto and Media
# it's business resemble the most with Big Fish Games, so I will label it as Media
UPDATE layoffs
SET industry = 'Media'
WHERE company = 'Bally''s Interactive';

-- Remove rows and columns which will not be used
SELECT *
FROM layoffs2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT COUNT(*)
FROM layoffs2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

# there are 361 rows without any information about the number of layoffs.
# It's a lot of data, but they are of no use in the analysis regarding layoffs so they should be droped
DELETE
FROM layoffs2
WHERE total_laid_off is NULL
AND percentage_laid_off is NULL;