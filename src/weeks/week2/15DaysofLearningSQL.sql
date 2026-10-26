WITH daily AS (
    SELECT submission_date, hacker_id, COUNT(*) AS cnt
    FROM Submissions
    GROUP BY submission_date, hacker_id
),
stats AS (
    SELECT submission_date,
           hacker_id,
           cnt,
           DENSE_RANK() OVER (ORDER BY submission_date)                       AS day_num,
           COUNT(*)     OVER (PARTITION BY hacker_id ORDER BY submission_date) AS days_active,
           ROW_NUMBER() OVER (PARTITION BY submission_date
                              ORDER BY cnt DESC, hacker_id)                   AS rn
    FROM daily
),
streak AS (
    SELECT submission_date, COUNT(*) AS unique_hackers
    FROM stats
    WHERE days_active = day_num
    GROUP BY submission_date
)
SELECT s.submission_date,
       st.unique_hackers,
       s.hacker_id,
       h.name
FROM stats s
JOIN streak st ON st.submission_date = s.submission_date
JOIN Hackers h ON h.hacker_id = s.hacker_id
WHERE s.rn = 1
ORDER BY s.submission_date
