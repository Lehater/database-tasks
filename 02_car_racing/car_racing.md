[Назад](../README.md)

# База данных 2 . Автомобильные гонки

## Задача 1

### Условия

Определить, какие автомобили из каждого класса имеют наименьшую среднюю позицию в гонках, и вывести информацию о каждом
таком автомобиле для данного класса, включая его класс, среднюю позицию и количество гонок, в которых он участвовал.
Также отсортировать результаты по средней позиции.

Решение задачи должно представлять из себя один SQL-запрос.

### Решение

[task2.1.sql](task2.1.sql)

```sql
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

```

### Результат

| car_name              | car_class    | average_position | race_count |
|-----------------------|--------------|------------------|------------|
| Ford Mustang          | SportsCar    | 1.0000           | 1          |
| Ferrari 488           | Convertible  | 1.0000           | 1          |
| Toyota RAV4           | SUV          | 2.0000           | 1          |
| Mercedes-Benz S-Class | Luxury Sedan | 2.0000           | 1          |
| BMW 3 Series          | Sedan        | 3.0000           | 1          |
| Chevrolet Camaro      | Coupe        | 4.0000           | 1          |
| Renault Clio          | Hatchback    | 5.0000           | 1          |
| Ford F-150            | Pickup       | 6.0000           | 1          |

**Примечание**:Порядок в группе с одинаковым average_position не гарантирован, так как **по условиям задачи не задана
дополнительная сортировка**. В такой ситуации, PostgreSQL может вывести записи либо в порядке появления в данных, либо в
алфавитном порядке — это зависит от оптимизатора и планов выполнения.

---

## Задача 2

### Условия

Определить автомобиль, который имеет наименьшую среднюю позицию в гонках среди всех автомобилей, и вывести информацию об
этом автомобиле, включая его класс, среднюю позицию, количество гонок, в которых он участвовал, и страну производства
класса автомобиля. Если несколько автомобилей имеют одинаковую наименьшую среднюю позицию, выбрать один из них по
алфавиту (по имени автомобиля).

Решение задачи должно представлять из себя один SQL-запрос.

### Решение

[task2.2.sql](task2.2.sql)

```sql
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

```

### Результат

| car_name    | car_class   | average_position | race_count | car_country |
|-------------|-------------|------------------|------------|-------------|
| Ferrari 488 | Convertible | 1.0000           | 1          | Italy       |

---

## Задача 3

### Условия

Определить классы автомобилей, которые имеют наименьшую среднюю позицию в гонках, и вывести информацию о каждом
автомобиле из этих классов, включая его имя, среднюю позицию, количество гонок, в которых он участвовал, страну
производства класса автомобиля, а также общее количество гонок, в которых участвовали автомобили этих классов. Если
несколько классов имеют одинаковую среднюю позицию, выбрать все из них.

Решение задачи должно представлять из себя один SQL-запрос.

### Решение

[task2.3.sql](task2.3.sql)

```sql
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
```

### Результат

| car_name     | car_class   | average_position | race_count | car_country | total_races |
|--------------|-------------|------------------|------------|-------------|-------------|
| Ferrari 488  | Convertible | 1.0000           | 1          | Italy       | 1           |
| Ford Mustang | SportsCar   | 1.0000           | 1          | USA         | 1           |

---

## Задача 4

### Условия

Определить, какие автомобили имеют среднюю позицию лучше (меньше) средней позиции всех автомобилей в своем классе (то
есть автомобилей в классе должно быть минимум два, чтобы выбрать один из них). Вывести информацию об этих автомобилях,
включая их имя, класс, среднюю позицию, количество гонок, в которых они участвовали, и страну производства класса
автомобиля. Также отсортировать результаты по классу и затем по средней позиции в порядке возрастания.

Решение задачи должно представлять из себя один SQL-запрос.

### Решение

[task2.4.sql](task2.4.sql)

```sql
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
```

### Результат

| car_name     | car_class | average_position | race_count | car_country |
|--------------|-----------|------------------|------------|-------------|
| BMW 3 Series | Sedan     | 3.0000           | 1          | Germany     |
| Toyota RAV4  | SUV       | 2.0000           | 1          | Japan       |

---

## Задача 5

### Условия

Определить, какие классы автомобилей имеют наибольшее количество автомобилей с низкой средней позицией (больше 3.0) и
вывести информацию о каждом автомобиле из этих классов, включая его имя, класс, среднюю позицию, количество гонок, в
которых он участвовал, страну производства класса автомобиля, а также общее количество гонок для каждого класса.
Отсортировать результаты по количеству автомобилей с низкой средней позицией.

Решение задачи должно представлять из себя один SQL-запрос.

### Решение

[task2.5.sql](task2.5.sql)

```sql
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

```

### Результат

| car_name         | car_class | average_position | race_count | car_country | total_races | low_position_count |
|------------------|-----------|------------------|------------|-------------|-------------|--------------------|
| Audi A4          | Sedan     | 8.0000           | 1          | Germany     | 2           | 1                  |
| Chevrolet Camaro | Coupe     | 4.0000           | 1          | USA         | 1           | 1                  |
| Ford F-150       | Pickup    | 6.0000           | 1          | USA         | 1           | 1                  |
| Renault Clio     | Hatchback | 5.0000           | 1          | France      | 1           | 1                  |

**Примечание**: есть несовпадение с контрольными результатами в задании по полю `low_position_count` для класса седан.
При расчете вручную по данным в задании получается 1, а в контрольных результатах - 2.
. Вероятно, использовалось условие `WHERE avg_position` **>=** `3.0`.

---



[Назад](../README.md)