# Lab 6

##### Challenge #####
#### Creating a Customer Summary Report 
### In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

USE sakila;

## Step 1: Create a View
# First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

DROP VIEW IF EXISTS customer_rental_summary;

CREATE VIEW customer_rental_summary AS
SELECT 
    customer.customer_id,
    CONCAT(customer.first_name, ' ', customer.last_name) AS name,
    customer.email,
    COUNT(rental.rental_id) AS rental_count
FROM customer
JOIN rental ON customer.customer_id = rental.customer_id
GROUP BY customer.customer_id;

SELECT *
FROM customer_rental_summary;

## Step 2: Create a Temporary Table
# Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    customer_rental_summary.customer_id,
    SUM(payment.amount) AS total_paid
FROM customer_rental_summary
JOIN payment ON customer_rental_summary.customer_id = payment.customer_id
GROUP BY customer_rental_summary.customer_id;

SELECT *
FROM customer_payment_summary;

## Step 3: Create a CTE and the Customer Summary Report
# Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
# Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_summary_cte AS (
    SELECT 
        customer_rental_summary.name,
        customer_rental_summary.email,
        customer_rental_summary.rental_count,
        customer_payment_summary.total_paid
    FROM customer_rental_summary
    JOIN customer_payment_summary ON customer_rental_summary.customer_id = customer_payment_summary.customer_id
)
SELECT 
    name,
    email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count > 0 THEN total_paid / rental_count
        ELSE 0 
    END AS average_payment_per_rental
FROM customer_summary_cte;
