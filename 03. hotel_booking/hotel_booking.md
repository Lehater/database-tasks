[Назад](../README.md)

# База данных 3. Бронирование отелей

## Задача 1

### Условия


### Решение
```sql
SELECT 
    c.name,
    c.email,
    c.phone,
    COUNT(b.ID_booking) AS total_bookings,
    STRING_AGG(DISTINCT h.name, ', ') AS hotels,
    ROUND(AVG(b.check_out_date - b.check_in_date), 4) AS avg_stay_duration
FROM Booking b
JOIN Customer c ON b.ID_customer = c.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer, c.name, c.email, c.phone
HAVING COUNT(b.ID_booking) > 2 AND COUNT(DISTINCT h.ID_hotel) > 1
ORDER BY total_bookings DESC;

```
### Результат

|name|email|phone|total_bookings|hotels|avg_stay_duration|
|----|-----|-----|--------------|------|-----------------|
|Bob Brown|bob.brown@example.com|+2233445566|3|Grand Hotel, Ocean View Resort|3.0000|
|Ethan Hunt|ethan.hunt@example.com|+5566778899|3|Mountain Retreat, Ocean View Resort|3.0000|

---

## Задача 2
### Условия
### Решение
```sql
WITH customer_bookings AS (
  SELECT 
    c.ID_customer,
    c.name,
    COUNT(b.ID_booking) AS total_bookings,
    COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
    SUM(r.price * (b.check_out_date - b.check_in_date)) AS total_spent
  FROM Customer c
  JOIN Booking b ON c.ID_customer = b.ID_customer
  JOIN Room r ON b.ID_room = r.ID_room
  JOIN Hotel h ON r.ID_hotel = h.ID_hotel
  GROUP BY c.ID_customer, c.name
)
SELECT 
    ID_customer,
    name,
    total_bookings,
    total_spent,
    unique_hotels
FROM customer_bookings
WHERE total_bookings > 2 
  AND unique_hotels > 1
  AND total_spent > 500
ORDER BY total_spent ASC;
```

### Результат

|id_customer|name|total_bookings|total_spent|unique_hotels|
|-----------|----|--------------|-----------|-------------|
|4|Bob Brown|3|2230.00|2|
|7|Ethan Hunt|3|2500.00|2|

---

## Задача 3
### Условия
### Решение
```sql
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

```

### Результат

|id_customer|name|preferred_hotel_type|visited_hotels|
|-----------|----|--------------------|--------------|
|10|Hannah Montana|Дешевый|City Center Inn|
|1|John Doe|Средний|City Center Inn, Grand Hotel|
|2|Jane Smith|Средний|Grand Hotel|
|3|Alice Johnson|Средний|Grand Hotel|
|4|Bob Brown|Средний|Grand Hotel, Ocean View Resort|
|5|Charlie White|Средний|Ocean View Resort|
|6|Diana Prince|Средний|Ocean View Resort|
|7|Ethan Hunt|Дорогой|Mountain Retreat, Ocean View Resort|
|8|Fiona Apple|Дорогой|Mountain Retreat|
|9|George Washington|Дорогой|City Center Inn, Mountain Retreat|


[Назад](../README.md)