WITH class_stats AS (
    SELECT
        cl.class,
        COUNT(DISTINCT c.name) AS car_count_in_class,
        ROUND(AVG(r.position),4) AS class_avg_pos
    FROM Classes cl
    JOIN Cars c ON c.class = cl.class
    JOIN Results r ON r.car = c.name
    GROUP BY cl.class
),
car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        ROUND(AVG(r.position),4) AS car_avg_pos,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.car_avg_pos AS average_position,
    cs.race_count,
    cl.country AS car_country
FROM car_stats cs
JOIN Classes cl ON cs.car_class = cl.class
JOIN class_stats cst ON cst.class = cl.class
WHERE cst.car_count_in_class >= 2
  AND cs.car_avg_pos < cst.class_avg_pos
ORDER BY cs.car_class, cs.car_avg_pos;