WITH hotel_avg_price AS (
    SELECT
        h.ID_hotel,
        AVG(r.price) AS avg_price
    FROM Room r
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY h.ID_hotel
),
hotel_category AS (
    SELECT
        ID_hotel,
        CASE
            WHEN avg_price < 175 THEN 1
            WHEN avg_price BETWEEN 175 AND 300 THEN 2
            ELSE 3
        END AS category_rank
    FROM hotel_avg_price
),
customer_hotels AS (
    SELECT
        b.ID_customer,
        STRING_AGG(DISTINCT h.name, ', ') AS visited_hotels
    FROM Booking b
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY b.ID_customer
),
customer_preferences AS (
    SELECT
        b.ID_customer,
        c.name,
        MAX(hc.category_rank) AS preferred_category_rank
    FROM Booking b
    JOIN Customer c ON b.ID_customer = c.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN hotel_category hc ON r.ID_hotel = hc.ID_hotel
    GROUP BY b.ID_customer, c.name
)
SELECT
    cp.ID_customer,
    cp.name,
    CASE cp.preferred_category_rank
        WHEN 3 THEN 'Дорогой'
        WHEN 2 THEN 'Средний'
        ELSE 'Дешевый'
    END AS preferred_hotel_type,
    ch.visited_hotels
FROM customer_preferences cp
JOIN customer_hotels ch ON cp.ID_customer = ch.ID_customer
ORDER BY cp.preferred_category_rank asc, cp.id_customer;