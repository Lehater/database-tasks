WITH class_stats AS (
    SELECT
        cl.class,
        ROUND(AVG(r.position),4) AS class_avg_pos,
        COUNT(r.race) AS class_race_count
    FROM Classes cl
    JOIN Cars c ON c.class = cl.class
    JOIN Results r ON r.car = c.name
    GROUP BY cl.class
),
min_av AS (
    SELECT MIN(class_avg_pos) AS min_position
    FROM class_stats
)
SELECT
    c.name AS car_name,
    c.class AS car_class,
    ROUND(AVG(r.position),4) AS average_position,
    COUNT(r.race) AS race_count,
    cl.country AS car_country,
    cs.class_race_count AS total_races
FROM Cars c
JOIN Classes cl ON c.class = cl.class
JOIN Results r ON r.car = c.name
JOIN class_stats cs ON cs.class = c.class
JOIN min_av ma ON cs.class_avg_pos = ma.min_position
GROUP BY c.name, c.class, cl.country, cs.class_race_count
ORDER BY c.name;