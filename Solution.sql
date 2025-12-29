#1 For each platform, find the top-selling game (by Global_Sales). Return platform, game
#name, and sales.
WITH ranked_games AS (
    SELECT
        platform,
        name AS game_name,
        global_sales,
        ROW_NUMBER() OVER (PARTITION BY platform ORDER BY global_sales DESC) AS rn
    FROM games
)
SELECT
    platform,
    game_name,
    global_sales
FROM ranked_games
WHERE rn = 1;

#2 For each genre, find the average global sales and rank genres from highest to lowest.
WITH genre_sales AS (
    SELECT 
        genre,
        AVG(global_sales) AS avg_global_sales
    FROM games
    GROUP BY genre
)
SELECT
    genre,
    ROUND(avg_global_sales, 2) AS avg_global_sales,
    RANK() OVER (ORDER BY avg_global_sales DESC) AS rank_genre
FROM genre_sales
ORDER BY avg_global_sales DESC;

#3 Find the publisher with the highest total global sales in each genre.
WITH genre_pub_sales AS (
    SELECT
        genre,
        publisher,
        SUM(global_sales) AS total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY genre
            ORDER BY SUM(global_sales) DESC
        ) AS rn
    FROM games
    GROUP BY genre, publisher
)
SELECT
    genre,
    publisher,
    total_sales
FROM genre_pub_sales
WHERE rn = 1
ORDER BY genre;

#4 Find the top 10 games with the highest difference between NA_Sales and EU_Sales.
SELECT
    name AS game_name,
    platform,
    publisher,
    NA_Sales,
    EU_Sales,
    ABS(NA_Sales - EU_Sales) AS sales_difference
FROM games
ORDER BY sales_difference DESC
LIMIT 10;

#5 For each year, calculate the number of games released and the average global sales
#that year.
SELECT
    year,
    COUNT(*) AS total_games_released,
    ROUND(AVG(global_sales), 2) AS avg_global_sales
FROM games
GROUP BY year
ORDER BY year;

#6 For each platform, compute total global sales and list platforms whose total sales are
#above the dataset’s average platform sales.
WITH platform_sales AS (
    SELECT 
        platform,
        ROUND(SUM(global_sales),1) AS total_sales
    FROM games
    GROUP BY platform
),
avg_sales AS (
    SELECT AVG(total_sales) AS avg_platform_sales
    FROM platform_sales
)
SELECT 
    ps.platform,
    ps.total_sales
FROM platform_sales ps
CROSS JOIN avg_sales a
WHERE ps.total_sales > a.avg_platform_sales
ORDER BY ps.total_sales DESC;

#7 Identify which genre has the highest total JP_Sales and list the top 3 games contributing
#to it.
WITH genre_rank AS (
    SELECT
        genre,
        SUM(JP_Sales) AS total_jp_sales,
        ROW_NUMBER() OVER (ORDER BY SUM(JP_Sales) DESC) AS rn
    FROM games
    GROUP BY genre
),
top_genre AS (
    SELECT genre
    FROM genre_rank
    WHERE rn = 1
)
SELECT
    g.name AS game_name,
    g.genre,
    g.JP_Sales
FROM games g
JOIN top_genre tg ON g.genre = tg.genre
ORDER BY g.JP_Sales DESC
LIMIT 3;

#8 For each publisher, compute total global sales and number of games published, then list
#publishers with more than 10 games.
SELECT 
    publisher,
    ROUND(SUM(global_sales),1) AS total_global_sales,
    COUNT(*) AS total_games
FROM games
GROUP BY publisher
HAVING COUNT(*) > 10
ORDER BY total_global_sales DESC;

#9 Find games where NA_Sales is greater than the sum of EU_Sales, JP_Sales, and
#Other_Sales. Return name, platform, and all sales columns.
SELECT
    name,
    platform,
    NA_Sales,
    EU_Sales,
    JP_Sales,
    Other_Sales,
    Global_Sales
FROM games
WHERE NA_Sales > (EU_Sales + JP_Sales + Other_Sales);

#10 For each genre, compute the percentage contribution of that genre to total global sales.
SELECT 
    genre,
    ROUND( (SUM(global_sales) / (SELECT SUM(global_sales) FROM games)) * 100 , 2 ) 
        AS genre_sales_percentage
FROM games
GROUP BY genre
ORDER BY genre_sales_percentage DESC;

#11 Find the top 5 platforms by number of games released.
SELECT 
    platform,
    COUNT(*) AS games_released
FROM games
GROUP BY platform
ORDER BY games_released DESC
LIMIT 5;

#12 Among games released after 2010, find those whose global sales are above the average
#global sales of all post-2010 games.

SELECT 
    name,
    platform,
    year,
    global_sales
FROM games
WHERE year > 2010
  AND global_sales > (
        SELECT AVG(global_sales)
        FROM games
        WHERE year > 2010
    );

#13 For each publisher, find their best-selling game (highest Global_Sales).

WITH ranked_games AS (
    SELECT
        publisher,
        name,
        global_sales,
        ROW_NUMBER() OVER (
            PARTITION BY publisher
            ORDER BY global_sales DESC
        ) AS rn
    FROM games
)
SELECT 
    publisher,
    name AS best_selling_game,
    global_sales
FROM ranked_games
WHERE rn = 1
ORDER BY global_sales DESC;

#14 For each year, list the genre that had the maximum number of releases.

WITH genre_counts AS (
    SELECT
        year,
        genre,
        COUNT(*) AS total_releases,
        ROW_NUMBER() OVER (
            PARTITION BY year
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM games
    GROUP BY year, genre
)
SELECT
    year,
    genre,
    total_releases
FROM genre_counts
WHERE rn = 1
ORDER BY year;

#15 Find the difference between the highest and lowest global sales within each platform.

SELECT
    platform,
    ROUND(MAX(global_sales) - MIN(global_sales),1) AS sales_difference
FROM games
GROUP BY platform
ORDER BY sales_difference DESC;


#16 Create a ranking of games within each platform based on Global_Sales (rank 1 =
#highest seller).
SELECT
    platform,
    name AS game_name,
    global_sales,
    ROW_NUMBER() OVER (
        PARTITION BY platform
        ORDER BY global_sales DESC
    ) AS rank_within_platform
FROM games
ORDER BY platform, rank_within_platform;

#17 Find games that appear in the top 10 in NA and also in the top 10 in EU (based on sales
#in each region).
WITH na_top AS (
    SELECT name, NA_Sales,
           ROW_NUMBER() OVER (ORDER BY NA_Sales DESC) AS rn_na
    FROM games
),
eu_top AS (
    SELECT name, EU_Sales,
           ROW_NUMBER() OVER (ORDER BY EU_Sales DESC) AS rn_eu
    FROM games
)
SELECT 
    n.name,
    n.NA_Sales,
    e.EU_Sales
FROM na_top n
JOIN eu_top e ON n.name = e.name
WHERE n.rn_na <= 10
  AND e.rn_eu <= 10
ORDER BY n.NA_Sales DESC;

#18 For each platform, compute average sales in NA, EU, JP, and Global; show platforms
#where JP_Sales average is higher than both NA and EU averages.
SELECT
    platform,
    ROUND(AVG(NA_Sales), 2) AS avg_NA_Sales,
    ROUND(AVG(EU_Sales), 2) AS avg_EU_Sales,
    ROUND(AVG(JP_Sales), 2) AS avg_JP_Sales,
    ROUND(AVG(Global_Sales), 2) AS avg_Global_Sales
FROM games
GROUP BY platform
HAVING AVG(JP_Sales) > AVG(NA_Sales)
   AND AVG(JP_Sales) > AVG(EU_Sales)
ORDER BY avg_JP_Sales DESC;

#19 For each genre, find the proportion of games published by each publisher (e.g., share of
#Action games published by a specific publisher).
WITH genre_counts AS (
    SELECT
        genre,
        publisher,
        COUNT(*) AS publisher_count
    FROM games
    GROUP BY genre, publisher
),
genre_totals AS (
    SELECT
        genre,
        SUM(publisher_count) AS total_genre_count
    FROM genre_counts
    GROUP BY genre
)
SELECT
    gc.genre,
    gc.publisher,
    gc.publisher_count,
    ROUND((gc.publisher_count / gt.total_genre_count) * 100, 2) AS percent_share
FROM genre_counts gc
JOIN genre_totals gt ON gc.genre = gt.genre
ORDER BY gc.genre, percent_share DESC;



#20   Find the year with the highest total global sales and list its top 5 selling games.

WITH yearly_sales AS (
    SELECT
        year,
        SUM(global_sales) AS total_sales
    FROM games
    GROUP BY year
),
top_year AS (
    SELECT year
    FROM yearly_sales
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT
    name AS game_name,
    platform,
    global_sales
FROM games
WHERE year = (SELECT year FROM top_year)
ORDER BY global_sales DESC
LIMIT 5;











