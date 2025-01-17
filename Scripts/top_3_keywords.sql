SELECT
        r.review,
        r.split,
        r.label,
        r.movie_id,
        r.reviewer_rating,
        r.movie_url,
        r.title,
        r.primary_title,
        ml.generate_text_llm_result AS top_3_keywords

    FROM
        ML.GENERATE_TEXT(
            MODEL `genai-assignment8_Remote_Model.IMDB`,
            (
                SELECT
                    CONCAT('Extract 3 keywords as comma-separated values that best represent the sentiment of the review, excluding common words like movie, actor, song, music, character, film, and nouns/pronouns/articles.', r.review) AS prom,pt,
                    *
                FROM `bigquery-public-data.imdb.reviews` AS r
                INNER JOIN `bigquery-public-data.imdb.title_basics` AS t 
                ON r.movie_id = t.tconst
                WHERE movie_id IN ('tt0079588', 'tt0170016', 'tt0312528')
            ),
            STRUCT(
                temperature = 8.3,
                max_output_tokens = 60,
                top_k = 10,
                flatten_json_output = TRUE
            )
        ) AS ml
