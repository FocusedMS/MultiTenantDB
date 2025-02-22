# Multi-Tenant Database Project

## Overview

This project implements a **multi-tenant database** using MySQL with a **shared schema** approach. The system is designed to support multiple tenants (businesses or customers) while ensuring **data isolation, security, and performance optimization**.

## Features

- **Shared Schema Multi-Tenancy**: Tenant data is segregated using `tenant_id`.
- **Role-Based Access Control (RBAC)**: Users are assigned roles to manage permissions.
- **Optimized Indexing**: Indexed frequently queried columns for improved performance.
- **Stored Procedures**: Automates data retrieval and sample data generation.
- **Data Integrity & Security**: Enforced foreign keys and cascading deletes.
- **Performance Optimization**: Implemented indexing and caching strategies.
- **Scalability**: Designed schema for efficient scaling with read replicas and Redis caching.

## Database Schema

The system consists of the following tables:

- `tenants`: Stores tenant details.
- `users`: Manages tenant users.
- `roles`: Defines user roles.
- `user_roles`: Maps users to roles.
- `products`: Stores products for each tenant.
- `orders`: Manages customer orders.
- `order_items`: Stores items within an order.
- `audit_logs`: Logs user activities.

## Setup Instructions

### Prerequisites

- MySQL 8.0+
- MySQL Workbench / Command Line Client

### Installation

1. **Clone the Repository:**
   ```sh
   git clone <repository_url>
   cd multi-tenant-db
   ```
2. **Run the SQL Script:**
   ```sql
   SOURCE multi_tenant_schema.sql;
   ```
3. **Verify Data Generation:**
   ```sql
   SELECT * FROM users WHERE tenant_id = 1;
   ```

## Stored Procedures

### `GetTenantProducts(tenantParam INT)`

Fetches all products for a specific tenant:

```sql
CALL GetTenantProducts(1);
```

### `GenerateSampleData()`

Populates the database with **50 sample tenants, users, products, and orders**:

```sql
CALL GenerateSampleData();
```

## Future Enhancements

- Implement **Redis caching** for frequently accessed data.
- Introduce **JWT/OAuth authentication** for API access.
- Optimize query performance with **query analysis and indexing improvements**.
- Deploy on **AWS RDS or DigitalOcean Managed Databases**.

## License

This project is licensed under the MIT License.

**Note:** This project is currently under development and improvements are ongoing.
