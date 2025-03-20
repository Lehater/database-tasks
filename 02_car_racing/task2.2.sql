SELECT sub.car_name,
       sub.car_class,
       sub.average_position,
       sub.race_count,
       cl.country AS car_country
FROM (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        ROUND(AVG(r.position),4) AS average_position,
        COUNT(r.race) AS race_count,
        RANK() OVER (ORDER BY AVG(r.position), c.name) AS rk
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
) sub
JOIN Classes cl ON sub.car_class = cl.class
WHERE sub.rk = 1;