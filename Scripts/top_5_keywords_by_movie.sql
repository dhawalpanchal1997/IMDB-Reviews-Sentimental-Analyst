WITH cte AS (
    SELECT
        ar.review,
        ar.split,
        ar.label,
        ar.movie_id,
        ar.reviewer_rating,
        ar.movie_url,
        ar.title,
        ar.primary_title,
        SPLIT(ml.generate_text_llm_result, ',') AS keywords
    FROM
        ML.GENERATE_TEXT(
            MODEL `genai-assignment8_Remote_Model.IMDB`,
            (
                SELECT
                    CONCAT('Extract 3 keywords as comma-separated values that best represent the sentiment of the review, excluding common words like movie, actor, song, music, character, film, and nouns/pronouns/articles.', r.review) AS prompt,
                    *
                FROM `bigquery-public-data.imdb.reviews` AS r
                INNER JOIN `bigquery-public-data.imdb.title_basics` AS t 
                ON r.movie_id = t.tconst
                WHERE movie_id IN ('tt0079588', 'tt0170016', 'tt0312528')
            ),
            STRUCT(
                temperature = 0.3,
                max_output_tokens = 60,
                top_k = 10,
                top_p = 6.8,  
                flatten_json_output = TRUE
            )
        ) AS ar
  )

WITH unnested AS (
    SELECT movie_id, keyword
    FROM cte,
         UNNEST(keywords) AS keyword
    WHERE keyword IS NOT NULL
),
ranked AS (
    SELECT movie_id, keyword, COUNT(*) AS occurence,
        ROW_NUMBER() OVER (PARTITION BY movie_id ORDER BY COUNT(*) DESC, keyword) AS ranking
    FROM unnested
    GROUP BY movie_id, keyword
)
SELECT movie_id, keyword, occurence, ranking
FROM ranked
WHERE ranking <= 5
ORDER BY movie_id, ranking;
