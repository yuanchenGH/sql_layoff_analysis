USE world_layoffs;

SELECT * 
FROM layoffs2;

SELECT *
FROM layoffs2
WHERE percentage_laid_off = 1
ORDER BY date;

SELECT *
FROM layoffs2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT country, COUNT(*)
FROM layoffs2
WHERE percentage_laid_off = 1
GROUP BY country;

SELECT company, SUM(total_laid_off), AVG(percentage_laid_off)
FROM layoffs2
GROUP BY company
ORDER BY 2 DESC;
# tech companies like Amazon, Google, Meta are on the top of lay off

SELECT industry, SUM(total_laid_off), AVG(percentage_laid_off)
FROM layoffs2
GROUP BY industry
ORDER BY 2 DESC;
# Consumer, Retail, Other, Transportation, Finance, Healthcare, Food, Real Estate and Travel are on the top

SELECT country, SUM(total_laid_off), AVG(percentage_laid_off)
FROM layoffs2
GROUP BY country
ORDER BY 2 DESC;
# US has the most laid off, but it could be due to the report of the data

SELECT YEAR(date), SUM(total_laid_off), AVG(percentage_laid_off)
FROM layoffs2
GROUP BY YEAR(date)
ORDER BY 1;
# 2022 is the year when the most employee got laid off
# but there is only 3 months of data in 2023, it's already close to 2022 level

SELECT stage, SUM(total_laid_off), AVG(percentage_laid_off)
FROM layoffs2
GROUP BY stage
ORDER BY 2 DESC;
# Post-IPO is the worst time when employees got laid off
# However the Seed stage has over 70% employees laid off, which is the highest percentage

SELECT YEAR(date) year, MONTH(date) month, SUM(total_laid_off) monthly_laid_off
FROM layoffs2
WHERE date is not NULL
GROUP BY year, month
ORDER BY 1 ASC;

WITH rolling_total AS 
(SELECT YEAR(date) year, MONTH(date) month, SUM(total_laid_off) monthly_laid_off
FROM layoffs2
WHERE date is not NULL
GROUP BY year, month
ORDER BY 1 ASC)
SELECT year, month, monthly_laid_off, SUM(monthly_laid_off) OVER (ORDER BY year, month) rolling_sum 
FROM rolling_total;

SELECT company, YEAR(date) year, SUM(total_laid_off) sum_laid_off
FROM layoffs2
GROUP BY company, year
HAVING sum_laid_off > 300
ORDER BY 3 DESC;

# top companies which laid off the most in each year 
WITH company_year AS
(SELECT company, YEAR(date) year, SUM(total_laid_off) sum_laid_off
FROM layoffs2
GROUP BY company, year), 
company_layoff_ranking AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY year ORDER BY sum_laid_off DESC) ranking
FROM company_year)
SELECT *
FROM company_layoff_ranking
WHERE year IS NOT NULL AND ranking <= 5;

