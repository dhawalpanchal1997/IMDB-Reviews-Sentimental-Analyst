WITH Sentiment_Analysis AS (

    SELECT
        ar.review,
        ar.split,
        ar.label,
        ar.movie_id,
        ar.reviewer_rating,
        ar.movie_url,
        ar.title,
        ar.primary_title,
        ml.generate_text_llm_result AS Sentiments,
        CASE 
            WHEN (ar.label = 'Positive' AND CAST(ml.generate_text_llm_result AS STRING) LIKE '%Negative%')
                OR (ar.label = 'Negative' AND CAST(ml.generate_text_llm_result AS STRING) LIKE '%Positive%') THEN 'Mismatched'
            ELSE 'Matched'
        END AS Checks,

    FROM
        ML.GENERATE_TEXT(
            MODEL `genai-assignment_Remote_Model.IMDB`,
            (
                SELECT
                    CONCAT('perform sentiment analysis on the following text, return only one of the following categories: Positive, Negative,', r.review) AS prompt,
                    *
                FROM `bigquery-public-data.imdb.reviews` AS r
                INNER JOIN `bigquery-public-data.imdb.title_basics` AS  t
                ON r.movie_id = t.tconst
                WHERE movie_id IN ('tt0079588', 'tt0170016', 'tt0312528')
            ),
      STRUCT(
            0.1 AS temperature,
            1000 AS max_output_tokens,
            3 AS top_k,
            0.1 AS top_p,
            TRUE AS flatten_json_output
            )
      )
  )
SELECT 
  sa.review,
  sa.label,
  sa.Sentiments,
  sa.Checks
FROM Sentiment_Analysis as sa 
Where sa.Checks =  'Mismatched'
