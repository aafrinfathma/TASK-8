/* ============================================================
   STORED PROCEDURES AND FUNCTIONS PRACTICE GUIDE
   Schema: Indian Unicorns Analytics
   ============================================================ */

/* ------------------------------------------------------------
   1. PROCEDURE vs FUNCTION EXAMPLES
   ------------------------------------------------------------ */
DELIMITER //
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
END //
DELIMITER ;

-- Example function
DELIMITER //
CREATE FUNCTION get_total_rounds (p_startup_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM funding_rounds
    WHERE startup_id = p_startup_id;
    RETURN total;
END //
DELIMITER ;


 /* ------------------------------------------------------------
   2. IN / OUT PARAMETER DEMONSTRATION
   ------------------------------------------------------------ */
DELIMITER //
CREATE PROCEDURE calculate_total_funding (
    IN p_startup_id INT,
    OUT p_total BIGINT
)
BEGIN
    SELECT SUM(raised_amount_usd)
    INTO p_total
    FROM funding_rounds
    WHERE startup_id = p_startup_id;
END //
DELIMITER ;

-- Call example:
CALL calculate_total_funding(2, @total);
SELECT @total AS total_funding_for_startup_2;


 /* ------------------------------------------------------------
   3. TABLE-VALUED FUNCTION (SQL SERVER / POSTGRES EXAMPLE)
   ------------------------------------------------------------ */
-- SQL Server Example
-- CREATE FUNCTION get_funding_details (@startup_id INT)
-- RETURNS TABLE
-- AS
-- RETURN (
--     SELECT round_type, raised_amount_usd, announced_date
--     FROM funding_rounds
--     WHERE startup_id = @startup_id
-- );


 /* ------------------------------------------------------------
   4. FUNCTION USING RETURN
   ------------------------------------------------------------ */
DELIMITER //
CREATE FUNCTION get_avg_raise (p_startup_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE avg_raise DECIMAL(10,2);
    SELECT AVG(raised_amount_usd) INTO avg_raise
    FROM funding_rounds
    WHERE startup_id = p_startup_id;
    RETURN avg_raise;
END //
DELIMITER ;


 /* ------------------------------------------------------------
   5. CALLING PROCEDURES
   ------------------------------------------------------------ */
-- Example call:
-- CALL add_startup('TechNova', 3, 'active', @message);
-- SELECT @message AS result;


 /* ------------------------------------------------------------
   6. PROCEDURE WITH LOOP AND CONDITIONAL LOGIC
   ------------------------------------------------------------ */
DELIMITER //
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
END //
DELIMITER ;

-- Example call:
-- CALL sum_first_n_rounds(2, 3, @sum);
-- SELECT @sum AS total_of_first_3_rounds;


 /* ------------------------------------------------------------
   7. TRIGGER EXAMPLE
   ------------------------------------------------------------ */
CREATE TABLE IF NOT EXISTS startup_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    startup_name VARCHAR(100),
    action_type VARCHAR(50),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER after_startup_insert
AFTER INSERT ON startups
FOR EACH ROW
BEGIN
    INSERT INTO startup_audit (startup_name, action_type)
    VALUES (NEW.name, 'INSERT');
END //
DELIMITER ;


 /* ------------------------------------------------------------
   8. DEBUGGING EXAMPLE
   ------------------------------------------------------------ */
DELIMITER //
CREATE PROCEDURE debug_example (IN p_startup_id INT)
BEGIN
    DECLARE total_rounds INT;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SELECT 'Error occurred while calculating rounds';

    SELECT COUNT(*) INTO total_rounds
    FROM funding_rounds
    WHERE startup_id = p_startup_id;

    SELECT CONCAT('Total funding rounds = ', total_rounds) AS debug_output;
END //
DELIMITER ;

-- CALL debug_example(5);


 /* ------------------------------------------------------------
   END OF FILE
   ------------------------------------------------------------ */
