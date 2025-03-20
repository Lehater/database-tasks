SELECT car_name, car_class, average_position, race_count
FROM (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        ROUND(AVG(r.position),4) AS average_position,
        COUNT(r.race) AS race_count,
        RANK() OVER (PARTITION BY c.class ORDER BY AVG(r.position)) AS rk
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
) sub
WHERE rk = 1
ORDER BY average_position;