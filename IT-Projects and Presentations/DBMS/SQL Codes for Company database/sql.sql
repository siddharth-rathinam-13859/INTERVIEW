CREATE TABLE employee(
  employee_id INT PRIMARY KEY,
  first_name VARCHAR(20),
  last_name VARCHAR(20),
  birth_day DATE,
  sex VARCHAR(1),
  salary INT,
  super_id INT,
  branch_id INT
);

-- ON DELETE SET NULL = to set null value if that value indicated by foreign key is deleted
-- ON DELETE CASCADE = to delete the complete row if the value indicated by foreign key is deleted
-- ON DELETE CASCADE used when the foreign key is a primary key

CREATE TABLE branch(
  branch_id INT PRIMARY KEY,
  branch_name VARCHAR(20),
  manager_id INT,
  manager_start_date DATE,
  FOREIGN KEY (manager_id) REFERENCES employee (employee_id) ON DELETE SET NULL
);

ALTER TABLE employee
ADD FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ON DELETE SET NULL;
ALTER TABLE employee
ADD FOREIGN KEY (super_id) REFERENCES employee(employee_id) ON DELETE SET NULL;

CREATE TABLE client(
   client_id INT PRIMARY KEY,
   client_name VARCHAR(20),
   branch_id INT,
   FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ON DELETE SET NULL
);

CREATE TABLE works_with (
  employee_id INT,
  client_id INT,
  total_sales INT,
  PRIMARY KEY (employee_id,client_id),
  FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE CASCADE,
  FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TABLE branch_supplier(
  branch_id INT,
  supplier_name VARCHAR(40),
  supply_type VARCHAR(20),
  PRIMARY KEY (branch_id,supplier_name),
  FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE
);

-- inserting values in employee and branch tables
-- the branch haven't been declared yet so 1st initialise with null then update branch id 

-- corporate branch
INSERT INTO employee VALUES(100,'David','Wallace','1967-11-17','M',250000,NULL,NULL);
INSERT INTO branch VALUES(1,'Corporate',100,'2006-02-09');
UPDATE employee
SET branch_id=1
WHERE employee_id =100;

INSERT INTO employee VALUES(101,'Jan','Levinson','1961-05-11','F',110000,100,1);

-- scranton branch
INSERT INTO employee VALUES(102,'Michale','Scott','1964-03-15','M',75000,102,NULL);
INSERT INTO branch VALUES(2,'Scranton',102,'1992-04-06');
UPDATE employee 
SET branch_id = 2
WHERE employee_id=102;
UPDATE employee 
SET super_id = 100
WHERE employee_id=102;

INSERT INTO employee VALUES(103,'Angela','Martin','1971-06-25','F',63000,102,2);
INSERT INTO employee VALUES(104,'Kelly','Kapoor','1980-02-05','F',55000,102,2);
INSERT INTO employee VALUES(105,'Stanley','Hudson','1958-02-19','M',69000,102,2);

-- stamford branch
INSERT INTO employee VALUES(106,'Josh','Porter','1969-09-05','M',78000,100,NULL);
INSERT INTO branch VALUES(3,'Stamford',106,'1998-02-13');
UPDATE employee 
SET branch_id = 3
WHERE employee_id=106;

INSERT INTO employee VALUES(107,'Andy','Bernard','1973-07-22','M',65000,106,3);
INSERT INTO employee VALUES(108,'Jim','Halpert','1978-10-01','M',71000,106,3);

-- client table
INSERT INTO client VALUES(400,'Dunmore Highschool',2);
INSERT INTO client VALUES(401,'Lackawana Country',2);
INSERT INTO client VALUES(402,'FedEx',3);
INSERT INTO client VALUES(403,'John Daly Law,LLC',3);
INSERT INTO client VALUES(404,'Scranton Whitepages',2);
INSERT INTO client VALUES(405,'Times Newspaper',3);
INSERT INTO client VALUES(406,'FedEx',2);

-- works_with table
INSERT INTO works_with VALUES(105,400,55000);
INSERT INTO works_with VALUES(102,401,267000);
INSERT INTO works_with VALUES(108,402,22500);
INSERT INTO works_with VALUES(107,403,5000);
INSERT INTO works_with VALUES(108,403,12000);
INSERT INTO works_with VALUES(105,404,33000);
INSERT INTO works_with VALUES(107,405,26000);
INSERT INTO works_with VALUES(102,406,15000);
INSERT INTO works_with VALUES(105,406,130000);

-- branch_supplier table
INSERT INTO branch_supplier VALUES (2,'Hammer Mill','Paper');
INSERT INTO branch_supplier VALUES (2,'Uni-ball','Writing Utensils');
INSERT INTO branch_supplier VALUES (3,'Patriot Paper','Paper');
INSERT INTO branch_supplier VALUES (2,'J.T. Forms & Labels','Custom Forms');
INSERT INTO branch_supplier VALUES (3,'Uni-ball','Writing Utensils');
INSERT INTO branch_supplier VALUES (3,'Hammer Mill','Paper');
INSERT INTO branch_supplier VALUES (3,'Stamford Labels','Custom Forms');

-- working with the created database
SELECT * FROM employee
ORDER BY salary DESC;

SELECT * FROM employee
ORDER BY sex,first_name,last_name;

SELECT * FROM employee
LIMIT 5;

SELECT first_name,last_name
FROM employee;

SELECT first_name AS forename,last_name AS surname
FROM employee;

SELECT DISTINCT sex FROM employee;

SELECT DISTINCT super_id FROM employee;

-- count only counts non null values
SELECT COUNT(employee_id)
FROM employee;

SELECT COUNT(super_id)
FROM employee;

SELECT COUNT(employee_id) 
FROM employee
WHERE sex='F' AND birth_day > '1971-01-01';

SELECT AVG(salary)
FROM employee;

SELECT AVG(salary)
FROM employee
WHERE sex='M';

SELECT SUM(salary)
FROM employee;

-- TO count the sex and print the respective sex 
SELECT COUNT(sex),sex
FROM employee
GROUP BY sex;

-- to find the total sales of each salesman
SELECT SUM(total_sales),employee_id
FROM works_with
GROUP BY employee_id;

-- % = ignoring any number of characters 
-- _ = ignoring only one character
-- to find the string LLC (using LIKE )
SELECT * FROM client
WHERE client_name LIKE '%LLC'; -- %LLC means leave any number of characters before LLC and find LLC

SELECT * FROM branch_supplier
WHERE supplier_name LIKE '%Label%';

-- to find october born employee
SELECT * FROM employee
-- ____(4 _) means ignoring those 4 characters(i.e: year ) last % means ignoring all characters after that
WHERE birth_day LIKE '____-10%'; 

SELECT first_name
FROM employee
UNION 
SELECT branch_name 
FROM branch;

SELECT first_name AS UNIONed_result
FROM employee
UNION 
SELECT branch_name 
FROM branch
UNION
SELECT client_name
FROM client;

-- prefix are used for easy identifications
SELECT client_name , client.branch_id
FROM client
UNION
SELECT supplier_name,branch_supplier.branch_id
FROM branch_supplier;

-- JOIN
SELECT employee.employee_id,employee.first_name,branch.branch_name
FROM employee
JOIN branch
ON employee.employee_id = branch.manager_id;

INSERT branch VALUES(4,'Buffalo',NULL,NULL);
SELECT employee.employee_id,employee.first_name,branch.branch_name
FROM employee
RIGHT JOIN branch
ON employee.employee_id = branch.manager_id;

SELECT employee.employee_id,employee.first_name,branch.branch_name
FROM employee
LEFT JOIN branch
ON employee.employee_id = branch.manager_id;

-- nested query
-- Find name of all employee who sold over 30000 to a single client
SELECT employee.first_name , employee.last_name
FROM  employee
WHERE employee.employee_id IN (
  SELECT works_with.employee_id
  FROM works_with
  WHERE works_with.total_sales > 30000
);

-- Find all the client names who are managed by branch which Michale Scott manages assume that you know Scott's id(102)
SELECT client.client_name
FROM client
WHERE client.branch_id=(
  SELECT branch.branch_id
  FROM branch
  WHERE branch.manager_id = 102
);

