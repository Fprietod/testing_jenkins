CREATE TABLE employees (
    employee_id INT PRIMARY KEY,  -- ID del empleado
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    hire_date DATE,
    salary DECIMAL(10, 2)
);

INSERT INTO employees (employee_id, first_name, last_name, hire_date, salary)
VALUES
    (1, 'John', 'Doe', '2023-01-01', 55000.00),
    (2, 'Jane', 'Smith', '2023-02-15', 60000.00),
    (3, 'Emma', 'Brown', '2023-03-10', 62000.00);

SELECT employee_id, first_name, last_name, hire_date, salary
FROM employees
WHERE salary > 55000
ORDER BY hire_date;
