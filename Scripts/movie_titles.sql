SELECT DISTINCT r.movie_id, t.primary_title
FROM `bigquery-public-data.imdb.reviews` AS r
INNER JOIN `bigquery-public-data.imdb.title_basics` AS t
ON r.movie_id = t.tconst
ORDER BY r.movie_id;
