/** AppleStore SQL Analysis**/

-- data from: https://www.kaggle.com/datasets/ramamet4/app-store-apple-data-set-10k-apps?select=AppleStore.csv
-- due to upload limit on SQLite, recombine the split table
CREATE TABLE appleStore_description_combined AS
select * from appleStore_description1 
Union ALL
select * from appleStore_description2
Union ALL
select * from appleStore_description3
Union ALL
select * from appleStore_description4
--

/** Goals of this Analysis**/

/* Let's consider how analysis of this data may help someone seeking to make their own app.*/
-- What are the most popular categories?
-- What price would be good?
-- How to maximize user ratings?

/* Let's move onto exploratory data analysis first. */

-- First, let's check if the number unique entries in each table is the same, which is true.

select count(distinct id) as UniqueAppsIDs
from AppleStore  --7197

select count(distinct id) as UniqueAppsIDs
from appleStore_description_combined -- 7197

-- Checking for missing values in key fields. 

select count(*) as MissingValues
from AppleStore
where track_name is null or user_rating is null or prime_genre is NULL --0

select count(*) as MissingValues
from appleStore_description_combined
where app_desc is NULL --0

-- See number of apps in each genre.

select prime_genre, count(*) as NumApps
from AppleStore
group by  prime_genre
order by NumApps desc -- the genre with most number of apps displayed at the topAppleStore

-- An overview of the ratings.

select min(user_rating) as MinRating,
	   max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
From AppleStore

-- A overview of the distribution of the prices.

select 
	(price/2) * 2 as PriceBinStart,
    ((price/2) * 2) + 2 as PriceBinEnd,
    count(*) as NumApps
from AppleStore
group by PriceBinStart
order by PriceBinStart

/*** DATA ANALYSIS ***/

-- Let's see if paid apps have higher ratings than free ones.

select case 
		when price > 0 then 'Paid'
    	else 'Free'
	end as App_Type,
    avg(user_rating) as Avg_Rating
from AppleStore
group BY App_Type  -- we see that paid apps have a higher average rating than paid ones, but only by a .4 difference

-- Let's see if apps that support more languages have higher ratings.AppleStore

select CASE
		when lang_num <10 then '<10 Languages'
        when lang_num BETWEEN 10 and 30 then '10-30 Languages'
        else '>30 Languages'
	end as language_buckets,
    avg(user_rating) as Avg_Rating
from AppleStore
group by language_buckets
order by Avg_Rating DESC -- the 10-30 range has the highest ratings, so more languages isn't a big focus to improve rating

-- Let's check the genres with low ratings.

select prime_genre,
	   avg(user_rating) as Avg_Rating
from AppleStore
group by prime_genre
order by Avg_Rating ASC -- to see the lowest
limit 10 -- only ten results
-- the pratical reason of looking at the query is to see what genres could benifit from a beter app, as current users are not very satisfied

-- Let's check if there is correlation between the length of the app description and user rating.
	-- we will need to join our two tables for this query 
 
select case 
		when length(B.app_desc) < 500 then 'Short'
        when length(B.app_desc) between 500 and 1000 then 'Medium'
        Else 'Long'
    End as descrip_length_buckets,
    avg(user_rating) as Avg_Rating
from AppleStore as A
join appleStore_description_combined as B
	on A.id = B.id
group by descrip_length_buckets
order by user_rating asc

-- Lets check the top rated apps for each genre.

select 
	prime_genre,
    track_name,
    user_rating
FRom (
  		SELECT
  		prime_genre,
  		track_name,
  		user_rating,
  		RANK() OVER(PARTITION by prime_genre order by user_rating Desc, rating_count_tot DEsc) as rank
  		from AppleStore
  		) as a 
where 
  a.rank=1
 
 
