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