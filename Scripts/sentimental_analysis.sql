SELECT
    ar.review,
    ar.split,
    ar.label,
    ar.movie_id,
    ar.reviewer_rating,
    ar.movie_url,
    ar.title,
    ar.primary_title,
    ML.GENERATE_TEXT(lim_result) AS Sentiments

FROM
    ML.GENERATE_TEXT(
        MODEL genai-assignment8.Remote_Model.IMDB,   --This is the main function that calls the genai-assignment8.Remote_Model.IMDB model to generate text.
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
        STRUCT(                          --The STRUCT clause defines parameters for the text generation process:
            0.1 AS temperature,          --Temperature: Controls the randomness of the generated text.
            1000 AS max_output_tokens,   --max_output_tokens: Limits the maximum number of tokens in the output.
            3 AS top_k,                  --top_k: Selects the top k most probable next tokens.
            0.1 AS top_p,                --top_p: Selects the next token from the top tokens whose cumulative probability exceeds top_p
            TRUE AS flatten_json_output  --flatten_json_output: Flattens the JSON output into a more readable format
        )
    ) AS ar;
