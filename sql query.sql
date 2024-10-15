-- Basic Track Information:

-- track_name: Name of the song.
-- artist(s)_name: Name of the artist(s) performing the song.
-- artist_count: Number of artists contributing to the song.
-- released_year, released_month, released_day: Release date details.

-- Streaming Metrics:
-- in_spotify_playlists: Number of Spotify playlists the song is featured in.
-- in_spotify_charts: Rank of the song on Spotify charts.
-- streams: Total number of streams on Spotify.
-- in_apple_playlists, in_apple_charts: Presence in Apple Music playlists and charts.
-- in_deezer_playlists, in_deezer_charts: Presence in Deezer playlists and charts.
-- in_shazam_charts: Rank on Shazam charts.

-- Musical Attributes:
-- bpm: Beats per minute, representing the tempo of the song.
-- key: Key of the song.
-- mode: Indicates whether the song is in a major or minor mode.
-- danceability_%: Suitability of the song for dancing.
-- valence_%: Positivity of the song¡¯s musical content.
-- energy_%: Perceived energy level of the song.
-- acousticness_%: Acoustic sound presence in the song.
-- instrumentalness_%: Proportion of instrumental content in the track.
-- liveness_%: Presence of live performance elements.
-- speechiness_%: Amount of spoken words in the song.

-- Dataset from https://www.kaggle.com/datasets/abdulszz/spotify-most-streamed-songs
-- Query written in MS SQL server

-- 1.Top 15 Stream Artists
SELECT TOP 15
    artist_s_name,           
    SUM(streams) AS total_streams  
FROM 
    Spotify
GROUP BY 
    artist_s_name            
ORDER BY 
    total_streams DESC

-- 2.Compare the average and total streams of songs released from 2000-2010 with those released from 2010-2020
SELECT 
    CASE 
        WHEN released_year BETWEEN 2000 AND 2010 THEN '2000-2010'
        WHEN released_year BETWEEN 2010 AND 2020 THEN '2010-2020'
    END AS release_period,
    CAST(AVG(CAST(streams AS FLOAT)) AS INT) AS avg_streams, 
    SUM(streams) AS total_streams
FROM 
    Spotify
WHERE 
    released_year BETWEEN 2000 AND 2020
GROUP BY 
    CASE 
        WHEN released_year BETWEEN 2000 AND 2010 THEN '2000-2010'
        WHEN released_year BETWEEN 2010 AND 2020 THEN '2010-2020'
    END
ORDER BY 
    release_period;

-- 3.The relationship between Valence and streams
SELECT 
    CASE 
        WHEN [valence] >= 75 THEN 'Positive'
        WHEN [valence] BETWEEN 50 AND 74 THEN 'Neutral'
        ELSE 'Negative'
    END AS valence_category,
    CAST(AVG(CAST(streams AS FLOAT)) AS INT) AS avg_streams,
    SUM(streams) AS total_streams
FROM 
    Spotify
GROUP BY 
    CASE 
        WHEN [valence] >= 75 THEN 'Positive'
        WHEN [valence] BETWEEN 50 AND 74 THEN 'Neutral'
        ELSE 'Negative'
    END
ORDER BY 
    avg_streams DESC;

-- 4.Analyze the relationship between collaborative tracks (multiple artists) and streams to explore whether collaboration leads to more streams.
SELECT 
    artist_count, 
    AVG(streams) AS avg_streams, 
    SUM(streams) AS total_streams
FROM 
    Spotify
GROUP BY 
    artist_count
ORDER BY 
    total_streams DESC;

-- 5.The most played songs of each artist among the top 10 most played artists
WITH TopArtists AS (
    SELECT TOP 10
        [artist_s_name],
        SUM(streams) AS total_streams
    FROM 
        Spotify
    GROUP BY 
        [artist_s_name]
    ORDER BY 
        total_streams DESC
),
RankedSongs AS (
    SELECT 
        s.[artist_s_name],
        s.[track_name],
        s.streams,
        ROW_NUMBER() OVER (PARTITION BY s.[artist_s_name] ORDER BY s.streams DESC) AS rn
    FROM 
        Spotify s
    JOIN 
        TopArtists t ON s.[artist_s_name] = t.[artist_s_name]
)
SELECT 
    [artist_s_name],
    [track_name],
    streams
FROM 
    RankedSongs
WHERE 
    rn = 1
ORDER BY 
    streams DESC;






                 

