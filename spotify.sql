DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
--EDA

Select count(*) from spotify;

Select count(distinct album) from spotify;

Select distinct album_type from spotify;

Select MAX(duration_min) from spotify;

Select MIN(duration_min) from spotify;

Select * from spotify 
where duration_min=0;

Delete from spotify 
where duration_min=0;

Select distinct channel from spotify;

Select distinct most_played_on from spotify;
/*
--------------------------------------------
--Data Analysis Cases-----------------------
--------------------------------------------

Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist.
*/

Select * from spotify
where stream>1000000000;

Select distinct album, artist 
from spotify
order by 1;

Select * from spotify
where licensed='true';

Select * from spotify
where album_type='single';

Select artist,count(*) as total_songs
from spotify
group by artist
order by 2;

/*
------------------------------
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

Select album, avg(danceability) as avg_danceability
from spotify
group by 1
order by 2 desc;

Select track,max(energy)
from spotify
group by 1
order by 2 desc
limit 5;

Select track, sum(views) as total_views, sum(likes) as total_likes
from spotify
where official_video='true'
group by 1
order by 2 desc;

Select album, track, sum(views)
from spotify
group by 1,2
order by 3 desc;

Select * from
(Select
 track,
 coalesce(sum(case when most_played_on='Youtube' then stream end),0) as streamed_on_youtube,
 coalesce(sum(case when most_played_on='Spotify' then stream end),0) as streamed_on_spotify
 from spotify
 group by 1
 
 ) as t1
 where streamed_on_spotify>streamed_on_youtube
 and streamed_on_youtube <>0;

/*
 Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

with artist_ranking as
(Select
artist,track,
sum(views) as total_views,
dense_rank() over(partition by artist order by sum(views)desc) as rank
from spotify
group by 1,2
order by 1,3 desc
)
Select * from artist_ranking
where rank<=3;

Select track,artist,liveness
from spotify
where liveness>(Select avg(liveness) from spotify);

WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC;