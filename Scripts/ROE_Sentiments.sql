SELECT
    SUM(CASE WHEN ar.label = 'Positive' AND CAST(ml_generate_text_llm_result AS STRING) LIKE '%Positive%' THEN 1 ELSE 0 END) / COUNT(*) AS Positive_label_rate,
    SUM(CASE WHEN ar.label = 'Negative' AND CAST(ml_generate_text_llm_result AS STRING) LIKE '%Negative%' THEN 1 ELSE 0 END) / COUNT(*) AS Negative_label_rate,
    SUM(CASE WHEN (ar.label = 'Positive' AND CAST(ml_generate_text_llm_result AS STRING) LIKE '%Positive%') OR
                 (ar.label = 'Negative' AND CAST(ml_generate_text_llm_result AS STRING) LIKE '%Negative%')
             THEN 1 ELSE 0 END) / COUNT(*) AS All_Label_rate

FROM
    ML.GENERATE_TEXT(
        MODEL genai-assignment8.Remote_Model.IMDB,
        (
            SELECT
                CONCAT("perform sentiment analysis on the following text, return only one of the following categories: Positive, Negative, ", r.review) AS prompt,
            FROM
                `bigquery-public-data.imdb.reviews` AS r
            INNER JOIN
                `bigquery-public-data.imdb.title_basics` AS t
            ON
                r.movie_id = t.tconst
            WHERE
                movie_id IN ('tt0079588', 'tt0170016', 'tt0312528')
        ),
        STRUCT(
            0.1 AS temperature,
            1000 AS max_output_tokens,
            3 AS top_k,
            0.1 AS top_p,
            TRUE AS flatten_json_output
        )
    ) AS ar;
