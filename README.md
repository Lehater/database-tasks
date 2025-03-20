# Домашнее задание по дисциплине «Базы данных»

## 1. Реализованные SQL-функции и запросы

- [Анализ транспортных средств (transport_vehicles)](01_transport_vehicles/transport_vehicles.md)
- [Анализ гонок (car_racing)](02_car_racing/car_racing.md)
- [Анализ бронирований (hotel_booking)](03_hotel_booking/hotel_booking.md)
- [Анализ структуры организации (organization_structure)](04_organization_structure/organization_structure.md)

---

## 2. Развертывание с Docker

Все базы данных автоматически создаются и наполняются тестовыми данными при первом запуске `PostgreSQL` в `Docker`.

Файлы хранятся в `init-scripts/` и выполняются при старте контейнера:

- `01_create_databases.sql` – создание баз данных.
- `02_transport_vehicles.sql` → `05_organization_structure.sql` – наполнение таблиц данными.

Запуск контейнера:

```bash
docker-compose up -d
```
После выполнения команды: СУБД PostgreSQL развернута, созданы БД и заполнены данными.

## 3. Подключение

СУБД доступна на `localhost:5432`

УЗ для подключения:
user: `user`,
password: `password`.