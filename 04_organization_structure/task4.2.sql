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