[Назад](../README.md)

# База данных 4. Структура организации

## Задача 1

### Условия
Найти всех сотрудников, подчиняющихся Ивану Иванову (с EmployeeID = 1), включая их подчиненных и подчиненных подчиненных. Для каждого сотрудника вывести следующую информацию:

EmployeeID: идентификатор сотрудника.
Имя сотрудника.
ManagerID: Идентификатор менеджера.
Название отдела, к которому он принадлежит.
Название роли, которую он занимает.
Название проектов, к которым он относится (если есть, конкатенированные в одном столбце через запятую).
Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце через запятую).
Если у сотрудника нет назначенных проектов или задач, отобразить NULL.

### Требования
Рекурсивно извлечь всех подчиненных сотрудников Ивана Иванова и их подчиненных.
Для каждого сотрудника отобразить информацию из всех таблиц.
Результаты должны быть отсортированы по имени сотрудника.
Решение задачи должно представлять из себя один sql-запрос и задействовать ключевое слово RECURSIVE.

### Решение
```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Базовый уровень: сам Иван Иванов
    SELECT 
        e.EmployeeID,
        e.Name AS EmployeeName,
        e.ManagerID,
        d.DepartmentName,
        e.DepartmentID,
        r.RoleName
    FROM Employees e
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    JOIN Roles r ON e.RoleID = r.RoleID
    WHERE e.EmployeeID = 1

    UNION ALL

    -- Рекурсивный уровень: все подчиненные
    SELECT 
        e.EmployeeID,
        e.Name AS EmployeeName,
        e.ManagerID,
        d.DepartmentName,
        e.DepartmentID,
        r.RoleName
    FROM Employees e
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    JOIN Roles r ON e.RoleID = r.RoleID
    JOIN employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
)
, project_task_data AS (
    SELECT 
        eh.EmployeeID,
        COALESCE(STRING_AGG(DISTINCT p.ProjectName, ', '), NULL) AS ProjectNames,
        COALESCE(STRING_AGG(DISTINCT t.TaskName, ', '), NULL) AS TaskNames,
    FROM employee_hierarchy eh
    LEFT JOIN Tasks t ON t.AssignedTo = eh.EmployeeID
    LEFT JOIN Projects p ON p.Departmentid = eh.Departmentid
    GROUP BY eh.EmployeeID
)
SELECT 
    eh.EmployeeID,eh.EmployeeName,eh.ManagerID,
    eh.DepartmentName,eh.RoleName,
    ptd.ProjectNames,ptd.TaskNames
FROM employee_hierarchy eh
LEFT JOIN project_task_data ptd ON ptd.EmployeeID = eh.EmployeeID
ORDER BY eh.EmployeeName;
```
### Результат

|employeeid|employeename|managerid|departmentname|rolename|projectnames|tasknames|
|----------|------------|---------|--------------|--------|------------|---------|
|20|Александр Александров|3|Отдел маркетинга|Менеджер|Проект B||
|4|Алексей Алексеев|2|Отдел продаж|Менеджер|Проект A|Задача 14: Создание презентации для клиентов, Задача 1: Подготовка отчета по продажам|
|16|Анастасия Анастасиева|7|Отдел поддержки|Специалист по поддержке|Проект D||
|29|Анастасия Анастасиевна|7|Отдел поддержки|Специалист по поддержке|Проект D||
|6|Андрей Андреев|1|Отдел разработки|Разработчик|Проект C|Задача 15: Обновление сайта, Задача 6: Обновление документации|
|30|Валентин Валентинов|6|Отдел разработки|Разработчик|Проект C||
|15|Виктор Викторов|4|Отдел продаж|Менеджер|Проект A||
|21|Галина Галина|7|Отдел поддержки|Специалист по поддержке|Проект D||
|26|Денис Денисов|6|Отдел разработки|Разработчик|Проект C||
|14|Дмитрий Дмитриев|3|Отдел маркетинга|Маркетолог|Проект B||
|25|Екатерина Екатеринина|7|Отдел поддержки|Специалист по поддержке|Проект D||
|7|Елена Еленова|1|Отдел поддержки|Специалист по поддержке|Проект D|Задача 12: Настройка системы поддержки|
|1|Иван Иванов||Отдел продаж|Генеральный директор|Проект A||
|28|Игорь Игорев|2|Отдел продаж|Менеджер|Проект A||
|11|Ирина Иринина|6|Отдел разработки|Разработчик|Проект C|Задача 8: Тестирование нового продукта|
|13|Кристина Кристинина|4|Отдел продаж|Менеджер|Проект A||
|18|Людмила Людмилова|3|Отдел маркетинга|Маркетолог|Проект B||
|17|Максим Максимов|6|Отдел разработки|Разработчик|Проект C||
|23|Марина Маринина|3|Отдел маркетинга|Маркетолог|Проект B||
|5|Мария Мариева|3|Отдел маркетинга|Менеджер|Проект B|Задача 5: Создание рекламной кампании|
|19|Наталья Натальева|4|Отдел продаж|Менеджер|Проект A||
|10|Николай Николаев|6|Отдел разработки|Разработчик|Проект C|Задача 11: Интеграция с новым API, Задача 3: Разработка нового функционала|
|8|Олег Олегов|2|Отдел продаж|Менеджер|Проект A|Задача 7: Проведение тренинга для сотрудников|
|27|Ольга Ольгина|3|Отдел маркетинга|Маркетолог|Проект B||
|22|Павел Павлов|6|Отдел разработки|Разработчик|Проект C||
|2|Петр Петров|1|Отдел продаж|Директор|Проект A||
|3|Светлана Светлова|1|Отдел маркетинга|Директор|Проект B||
|12|Сергей Сергеев|7|Отдел поддержки|Специалист по поддержке|Проект D|Задача 4: Поддержка клиентов, Задача 9: Ответы на запросы клиентов|
|24|Станислав Станиславов|4|Отдел продаж|Менеджер|Проект A||
|9|Татьяна Татеева|3|Отдел маркетинга|Маркетолог|Проект B|Задача 10: Подготовка маркетинговых материалов, Задача 13: Проведение анализа конкурентов, Задача 2: Анализ рынка|


---

## Задача 2
### Условия

Найти всех сотрудников, подчиняющихся Ивану Иванову с `EmployeeID` = 1, включая их подчиненных и подчиненных подчиненных. Для каждого сотрудника вывести следующую информацию:

`EmployeeID`: идентификатор сотрудника.
Имя сотрудника.
Идентификатор менеджера.
Название отдела, к которому он принадлежит.
Название роли, которую он занимает.
Название проектов, к которым он относится (если есть, конкатенированные в одном столбце).
Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце).
Общее количество задач, назначенных этому сотруднику.
Общее количество подчиненных у каждого сотрудника (не включая подчиненных их подчиненных).
Если у сотрудника нет назначенных проектов или задач, отобразить `NULL`.
Решение задачи должно представлять из себя один sql-запрос и задействовать ключевое слово `RECURSIVE`.

### Решение
```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Базовый уровень: сам Иван Иванов
    SELECT 
        e.EmployeeID,
        e.Name AS EmployeeName,
        e.ManagerID,
        d.DepartmentName,
        e.DepartmentID,
        r.RoleName
    FROM Employees e
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    JOIN Roles r ON e.RoleID = r.RoleID
    WHERE e.EmployeeID = 1

    UNION ALL

    -- Рекурсивный уровень: все подчиненные
    SELECT 
        e.EmployeeID,
        e.Name AS EmployeeName,
        e.ManagerID,
        d.DepartmentName,
        e.DepartmentID,
        r.RoleName
    FROM Employees e
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    JOIN Roles r ON e.RoleID = r.RoleID
    JOIN employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
)
-- Подсчет количества подчиненных (включая вложенные уровни)
, subordinate_counts AS (
    SELECT ManagerID, COUNT(DISTINCT EmployeeID) AS TotalSubordinates
    FROM employee_hierarchy
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
)
-- Получение списка проектов и задач
, project_task_data AS (
    SELECT 
        eh.EmployeeID,
        COALESCE(STRING_AGG(DISTINCT p.ProjectName, ', '), NULL) AS ProjectNames,
        COALESCE(STRING_AGG(DISTINCT t.TaskName, ', '), NULL) AS TaskNames,
        COUNT(DISTINCT p.ProjectName) AS TotalProjects,
        COUNT(DISTINCT t.TaskName) AS TotalTasks
    FROM employee_hierarchy eh
    LEFT JOIN Tasks t ON t.AssignedTo = eh.EmployeeID
    LEFT JOIN Projects p ON p.Departmentid = eh.Departmentid
    GROUP BY eh.EmployeeID
)
SELECT 
    eh.EmployeeID, eh.EmployeeName, eh.ManagerID,
    eh.DepartmentName, eh.RoleName,
    ptd.ProjectNames, ptd.TaskNames, ptd.TotalProjects, ptd.TotalTasks,
    sc.TotalSubordinates
FROM employee_hierarchy eh
LEFT JOIN project_task_data ptd ON eh.EmployeeID = ptd.EmployeeID
LEFT JOIN subordinate_counts sc ON eh.EmployeeID = sc.ManagerID
ORDER BY eh.EmployeeName;
```
### Результат

|employeeid|employeename|managerid|departmentname|rolename|projectnames|tasknames|totaltasks|totalsubordinates|
|----------|------------|---------|--------------|--------|------------|---------|----------|-----------------|
|20|Александр Александров|3|Отдел маркетинга|Менеджер|Проект B||0|0|
|4|Алексей Алексеев|2|Отдел продаж|Менеджер|Проект A|Задача 14: Создание презентации для клиентов, Задача 1: Подготовка отчета по продажам|2|4|
|16|Анастасия Анастасиева|7|Отдел поддержки|Специалист по поддержке|Проект D||0|0|
|29|Анастасия Анастасиевна|7|Отдел поддержки|Специалист по поддержке|Проект D||0|0|
|6|Андрей Андреев|1|Отдел разработки|Разработчик|Проект C|Задача 15: Обновление сайта, Задача 6: Обновление документации|2|6|
|30|Валентин Валентинов|6|Отдел разработки|Разработчик|Проект C||0|0|
|15|Виктор Викторов|4|Отдел продаж|Менеджер|Проект A||0|0|
|21|Галина Галина|7|Отдел поддержки|Специалист по поддержке|Проект D||0|0|
|26|Денис Денисов|6|Отдел разработки|Разработчик|Проект C||0|0|
|14|Дмитрий Дмитриев|3|Отдел маркетинга|Маркетолог|Проект B||0|0|
|25|Екатерина Екатеринина|7|Отдел поддержки|Специалист по поддержке|Проект D||0|0|
|7|Елена Еленова|1|Отдел поддержки|Специалист по поддержке|Проект D|Задача 12: Настройка системы поддержки|1|5|
|1|Иван Иванов||Отдел продаж|Генеральный директор|Проект A||0|4|
|28|Игорь Игорев|2|Отдел продаж|Менеджер|Проект A||0|0|
|11|Ирина Иринина|6|Отдел разработки|Разработчик|Проект C|Задача 8: Тестирование нового продукта|1|0|
|13|Кристина Кристинина|4|Отдел продаж|Менеджер|Проект A||0|0|
|18|Людмила Людмилова|3|Отдел маркетинга|Маркетолог|Проект B||0|0|
|17|Максим Максимов|6|Отдел разработки|Разработчик|Проект C||0|0|
|23|Марина Маринина|3|Отдел маркетинга|Маркетолог|Проект B||0|0|
|5|Мария Мариева|3|Отдел маркетинга|Менеджер|Проект B|Задача 5: Создание рекламной кампании|1|0|
|19|Наталья Натальева|4|Отдел продаж|Менеджер|Проект A||0|0|
|10|Николай Николаев|6|Отдел разработки|Разработчик|Проект C|Задача 11: Интеграция с новым API, Задача 3: Разработка нового функционала|2|0|
|8|Олег Олегов|2|Отдел продаж|Менеджер|Проект A|Задача 7: Проведение тренинга для сотрудников|1|0|
|27|Ольга Ольгина|3|Отдел маркетинга|Маркетолог|Проект B||0|0|
|22|Павел Павлов|6|Отдел разработки|Разработчик|Проект C||0|0|
|2|Петр Петров|1|Отдел продаж|Директор|Проект A||0|3|
|3|Светлана Светлова|1|Отдел маркетинга|Директор|Проект B||0|7|
|12|Сергей Сергеев|7|Отдел поддержки|Специалист по поддержке|Проект D|Задача 4: Поддержка клиентов, Задача 9: Ответы на запросы клиентов|2|0|
|24|Станислав Станиславов|4|Отдел продаж|Менеджер|Проект A||0|0|
|9|Татьяна Татеева|3|Отдел маркетинга|Маркетолог|Проект B|Задача 10: Подготовка маркетинговых материалов, Задача 13: Проведение анализа конкурентов, Задача 2: Анализ рынка|3|0|

---

## Задача 3
### Условия

Найти всех сотрудников, которые занимают роль менеджера и имеют подчиненных (то есть число подчиненных больше 0). Для каждого такого сотрудника вывести следующую информацию:

`EmployeeID`: идентификатор сотрудника.
Имя сотрудника.
Идентификатор менеджера.
Название отдела, к которому он принадлежит.
Название роли, которую он занимает.
Название проектов, к которым он относится (если есть, конкатенированные в одном столбце).
Название задач, назначенных этому сотруднику (если есть, конкатенированные в одном столбце).
Общее количество подчиненных у каждого сотрудника (включая их подчиненных).
Если у сотрудника нет назначенных проектов или задач, отобразить `NULL`.
Решение задачи должно представлять из себя один sql-запрос и задействовать ключевое слово `RECURSIVE`.

### Решение
```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Базовый уровень: выбираем сотрудников с ролью 'Менеджер' и с подчиненными
    SELECT 
        e.EmployeeID,
        e.Name AS EmployeeName,
        e.ManagerID,
        d.DepartmentName,
        d.DepartmentID,
        r.RoleName,
        0 AS level
    FROM Employees e
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    JOIN Roles r ON e.RoleID = r.RoleID
    WHERE r.RoleName = 'Менеджер'
      AND EXISTS (SELECT 1 FROM Employees sub WHERE sub.ManagerID = e.EmployeeID) 

    UNION ALL

    -- Рекурсивный уровень: добавляем подчиненных
    SELECT 
        e.EmployeeID,
        e.Name AS EmployeeName,
        e.ManagerID,
        d.DepartmentName,
        d.DepartmentID,
        r.RoleName,
        eh.level + 1 AS level
    FROM Employees e
    JOIN Departments d ON e.DepartmentID = d.DepartmentID
    JOIN Roles r ON e.RoleID = r.RoleID
    JOIN employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
)
-- Подсчет количества подчиненных (включая вложенные уровни)
, subordinate_counts AS (
    SELECT ManagerID, COUNT(DISTINCT EmployeeID) AS TotalSubordinates
    FROM employee_hierarchy
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
)
-- Получение списка проектов и задач
, project_task_data AS (
    SELECT 
        eh.EmployeeID,
        COALESCE(STRING_AGG(DISTINCT p.ProjectName, ', '), NULL) AS ProjectNames,
        COALESCE(STRING_AGG(DISTINCT t.TaskName, ', '), NULL) AS TaskNames
    FROM employee_hierarchy eh
    LEFT JOIN Tasks t ON t.AssignedTo = eh.EmployeeID
    LEFT JOIN Projects p ON p.Departmentid = eh.Departmentid
    GROUP BY eh.EmployeeID
)
SELECT 
    eh.EmployeeID,eh.EmployeeName,eh.ManagerID,
    eh.DepartmentName,eh.RoleName,
    pd.ProjectNames,pd.TaskNames,
    sc.TotalSubordinates
FROM employee_hierarchy eh
JOIN subordinate_counts sc ON eh.EmployeeID = sc.ManagerID
LEFT JOIN project_task_data pd ON eh.EmployeeID = pd.EmployeeID
ORDER BY sc.TotalSubordinates DESC, eh.EmployeeName;

```
### Результат

|employeeid|employeename|managerid|departmentname|rolename|projectnames|tasknames|totalsubordinates|
|----------|------------|---------|--------------|--------|------------|---------|-----------------|
|4|Алексей Алексеев|2|Отдел продаж|Менеджер|Проект A|Задача 14: Создание презентации для клиентов, Задача 1: Подготовка отчета по продажам|4|

---


[Назад](../README.md)