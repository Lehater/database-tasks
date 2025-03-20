WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        ROUND(AVG(r.position),4) AS avg_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
class_race_count AS (
    select cl.class,COUNT(r.race) AS total_races
    FROM Classes cl
    JOIN Cars c ON c.class = cl.class
    JOIN Results r ON r.car = c.name
    GROUP BY cl.class
),
class_stats AS (
    select car_class,COUNT(car_name) AS low_position_count
    FROM car_stats
    WHERE avg_position > 3.0
    GROUP BY car_class
)
SELECT
    cs.car_name AS car_name,
    cs.car_class AS car_class,
    cs.avg_position AS average_position,
    cs.race_count,
    cl.country AS car_country,
    crc.total_races,
    cst.low_position_count
FROM car_stats cs
JOIN Classes cl ON cs.car_class = cl.class
JOIN class_stats cst ON cs.car_class = cst.car_class
JOIN class_race_count crc ON cs.car_class = crc.class
WHERE cs.avg_position > 3.0
ORDER BY cst.low_position_count DESC, cs.car_name;