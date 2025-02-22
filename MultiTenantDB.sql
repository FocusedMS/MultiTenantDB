-- Create the multi-tenant database
CREATE DATABASE IF NOT EXISTS multi_tenant_db;
USE multi_tenant_db;

-- Create the tenants table
CREATE TABLE IF NOT EXISTS tenants (
    tenant_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the roles table
CREATE TABLE IF NOT EXISTS roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create the users table (Partitioning removed due to foreign key constraint)
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE
);

-- Create the user_roles table (No partitioning, foreign keys referencing users and roles)
CREATE TABLE IF NOT EXISTS user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE
);

-- Create an index on role_id in user_roles
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

-- Create the products table (Partitioning removed due to foreign key constraint)
CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE
);

-- Create the orders table (Partitioning removed due to foreign key constraint)
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    user_id INT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'shipped', 'delivered', 'canceled') NOT NULL DEFAULT 'pending',
    payment_status ENUM('Pending', 'Completed', 'Failed') NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Create the audit_logs table (Partitioning removed due to foreign key constraint)
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_id INT NOT NULL,
    user_id INT NULL,
    action VARCHAR(255) NOT NULL,
    performed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Create the order_items table (No partitioning, foreign keys referencing orders and products)
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- Create indexes to optimize queries
CREATE INDEX idx_users_tenant_created ON users (tenant_id, created_at);
CREATE INDEX idx_users_tenant_active ON users (tenant_id, is_deleted);
CREATE INDEX idx_products_tenant_name ON products (tenant_id, product_name);
CREATE INDEX idx_orders_tenant_id ON orders(tenant_id);

-- Create a stored procedure to retrieve products for a specific tenant
DELIMITER //
CREATE PROCEDURE GetTenantProducts(IN tenantParam INT)
BEGIN
    SELECT product_id, tenant_id, product_name, price, created_at
    FROM products
    WHERE tenant_id = tenantParam;
END //
DELIMITER ;

-- Disable foreign key checks before data generation for sample data insertion
SET FOREIGN_KEY_CHECKS = 0;

-- Create a stored procedure to generate sample data with error handling
DELIMITER //
CREATE PROCEDURE GenerateSampleData()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 50 DO
        BEGIN
            DECLARE currTenant INT;
            DECLARE currUser INT;
            DECLARE currOrder INT;
            DECLARE currProduct INT;

            -- Insert into tenants with error handling
            INSERT INTO tenants (tenant_name)
            VALUES (CONCAT('Enterprise Solution ', i));
            SET currTenant = LAST_INSERT_ID();

            -- Insert into users with error handling
            INSERT INTO users (tenant_id, full_name, email)
            VALUES (
                currTenant,
                CONCAT('User ', i, ' Kumar'),
                CONCAT('User', i, '@enterprisesolutions', i, '.in')
            );
            SET currUser = LAST_INSERT_ID();

            -- Insert into products with error handling
            INSERT INTO products (tenant_id, product_name, price)
            VALUES (
                currTenant,
                CONCAT('Product ', i, ' Pro'),
                ROUND(10000 + (RAND() * 90000), 2)
            );
            SET currProduct = LAST_INSERT_ID();

            -- Insert into orders with error handling
            INSERT INTO orders (tenant_id, user_id, status, payment_status)
            VALUES (
                currTenant,
                currUser,
                'pending',
                'Pending'
            );
            SET currOrder = LAST_INSERT_ID();

            -- Insert into audit_logs with error handling
            INSERT INTO audit_logs (tenant_id, user_id, action)
            VALUES (
                currTenant,
                currUser,
                'Created Order'
            );

            -- Insert into order_items with error handling
            INSERT INTO order_items (order_id, product_id, quantity, price)
            VALUES (
                currOrder,
                currProduct,
                1,
                (SELECT price FROM products WHERE product_id = currProduct)
            );

        END;

        SET i = i + 1; -- Increment loop counter
    END WHILE;
END //
DELIMITER ;

-- Re-enable foreign key checks after data generation
SET FOREIGN_KEY_CHECKS = 1;

-- Execute the stored procedures to generate sample data and retrieve tenant products
CALL GenerateSampleData();
CALL GetTenantProducts(1);


select * from users where tenant_id = 1;