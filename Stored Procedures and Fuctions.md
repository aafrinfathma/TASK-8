# 🧩 Mastering Stored Procedures and Functions in SQL

This guide provides a comprehensive overview of **Stored Procedures**, **Functions**, and **Triggers** — with practical examples, differences, and real-world use cases using the **Indian Unicorns Analytics** schema.

---

## 🔹 1. Difference Between Procedure and Function

| Feature | **Stored Procedure** | **Function** |
|----------|----------------------|---------------|
| **Return Type** | May return multiple values via `OUT` parameters | Must return a single value (scalar or table) |
| **Usage** | Invoked using `CALL` | Invoked in a query (`SELECT function_name(...)`) |
| **Data Modification** | Can modify data (INSERT, UPDATE, DELETE) | Cannot modify data |
| **RETURN Keyword** | Optional | Mandatory |
| **Transactions** | Can commit or rollback | Cannot control transactions |

### Example
```sql
CREATE PROCEDURE add_startup (
    IN p_name VARCHAR(100),
    IN p_industry_id INT,
    IN p_status ENUM('active','closed','public'),
    OUT p_message VARCHAR(255)
)
BEGIN
    IF p_name IS NULL OR p_industry_id IS NULL THEN
        SET p_message = 'Error: Missing startup name or industry';
    ELSE
        INSERT INTO startups (name, industry_id, current_status)
        VALUES (p_name, p_industry_id, p_status);
        SET p_message = CONCAT('Startup "', p_name, '" added successfully!');
    END IF;
END;

# 2. What Are IN, OUT, and INOUT Parameters?

*IN*	Input value passed into a routine
*OUT*	Value returned out of the routine
*INOUT*	Used both as input and output

Example

``` sql
CREATE PROCEDURE calculate_total_funding (
    IN p_startup_id INT,
    OUT p_total BIGINT
)
BEGIN
    SELECT SUM(raised_amount_usd)
    INTO p_total
    FROM funding_rounds
    WHERE startup_id = p_startup_id;
END;

CALL calculate_total_funding(1, @total);
SELECT @total AS total_funding_for_startup_1;
```

#3. Can Functions Return Tables?

✅ Yes, in SQL Server and PostgreSQL (via table-valued functions).
❌ MySQL functions return only scalar values.

Example (SQL Server)

```sql
CREATE FUNCTION get_funding_details (@startup_id INT)
RETURNS TABLE
AS
RETURN (
    SELECT round_type, raised_amount_usd, announced_date
    FROM funding_rounds
    WHERE startup_id = @startup_id
);
```
#🔹 4. What is RETURN Used For?

**RETURN** sends the final output value from a function to the caller.

Example

```sql
CREATE FUNCTION get_avg_raise (p_startup_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE avg_raise DECIMAL(10,2);
    SELECT AVG(raised_amount_usd) INTO avg_raise
    FROM funding_rounds
    WHERE startup_id = p_startup_id;
    RETURN avg_raise;
END;

SELECT get_avg_raise(5) AS average_raise;
```

#🔹 5. How to Call Stored Procedures?

Use CALL (MySQL/PostgreSQL) or EXEC (SQL Server).
```sql
CALL add_startup('TechNova', 3, 'active', @message);
SELECT @message AS result;
```

#🔹 6. Benefits of Stored Routines

*Encapsulation*	Centralize complex logic in one place
*Performance*	Precompiled and optimized
*Security*	    Execute without exposing table access
*Reusability*	Reuse across applications
*Consistency*	Avoid repeated business logic

#🔹 7. Can Procedures Have Loops?

✅ Yes, use WHILE, LOOP, or REPEAT constructs.

Example
```sql
CREATE PROCEDURE sum_first_n_rounds (
    IN p_startup_id INT,
    IN p_n INT,
    OUT p_total BIGINT
)
BEGIN
    DECLARE counter INT DEFAULT 0;
    DECLARE total_sum BIGINT DEFAULT 0;
    DECLARE amount BIGINT;

    WHILE counter < p_n DO
        SELECT raised_amount_usd INTO amount
        FROM funding_rounds
        WHERE startup_id = p_startup_id
        ORDER BY announced_date
        LIMIT counter,1;

        SET total_sum = total_sum + IFNULL(amount, 0);
        SET counter = counter + 1;
    END WHILE;

    SET p_total = total_sum;
END;

CALL sum_first_n_rounds(2, 3, @sum);
SELECT @sum AS total_of_first_3_rounds;
```

#🔹 9. What is a Trigger?

A Trigger automatically executes when a table event occurs (INSERT, UPDATE, DELETE).

Example
```sql
CREATE TABLE startup_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    startup_name VARCHAR(100),
    action_type VARCHAR(50),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER after_startup_insert
AFTER INSERT ON startups
FOR EACH ROW
BEGIN
    INSERT INTO startup_audit (startup_name, action_type)
    VALUES (NEW.name, 'INSERT');
END;
```

#🔹 10. How to Debug Stored Procedures?

SELECT statements	Print variable values during execution
DECLARE HANDLER	Catch and handle SQL errors
Step-by-step testing	Run blocks individually
Logs and profiling	Use SHOW WARNINGS;, logs, or query analyzers


Example
```sql
CREATE PROCEDURE debug_example (IN p_startup_id INT)
BEGIN
    DECLARE total_rounds INT;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SELECT 'Error occurred while calculating rounds';

    SELECT COUNT(*) INTO total_rounds
    FROM funding_rounds
    WHERE startup_id = p_startup_id;

    SELECT CONCAT('Total funding rounds = ', total_rounds) AS debug_output;
END;

CALL debug_example(5);
```

✅ Summary Table
#	Concept	Key Point
1	Procedure vs Function	Procedures can modify data; functions cannot
2	IN/OUT Params	        Control input/output data flow
3	Return Tables	        Supported in SQL Server / PostgreSQL
4	RETURN	                Sends function result
5	CALL	                Execute stored procedure
6	Benefits	            Encapsulation, performance, security
7	Loops	                Use in procedures with counters
8	Scalar vs Table	        Value vs table return
9	Trigger	                Auto-run logic on table events
10	Debugging	            SELECTs, handlers, logs