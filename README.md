# Olist E-Commerce Business Analysis | SQL Portfolio Project

## Project Overview

This project analyzes the Olist Brazilian E-Commerce dataset using PostgreSQL to understand business performance across customers, orders, products, payments, sellers, and customer reviews.

The objective is to answer practical business questions, identify performance patterns, and generate insights that can support business decision-making.

## Tools & Technologies

- Database: PostgreSQL
- SQL Environment: pgAdmin
- Language: SQL
- Dataset: Olist Brazilian E-Commerce Public Dataset

## Business Objectives

- Analyze customer distribution and order trends.
- Understand order status and cancellation patterns.
- Evaluate delivered product sales and monthly revenue trends.
- Analyze payment methods and payment behavior.
- Identify high-performing product categories.
- Understand customer review patterns and satisfaction.
- Evaluate seller performance.
- Compare customer satisfaction between on-time and late deliveries.

## Dataset Tables

- customers
- orders
- order_items
- order_payments
- products
- order_reviews
- sellers
- product_category_name_translation
- geolocation

## Business Analysis

### 1. Customer & Order Analysis
- Customer distribution by state.
- Order volume by customer state.
- Cities with the highest number of canceled orders.
- Average delivery time by state.
- Monthly order trends.
- Delivered and canceled orders by month.
- Monthly cancellation rate.
- Order status distribution.

### 2. Order Items & Revenue Analysis
- Average item price.
- Highest-revenue orders.
- Number of items per order.
- Order size distribution.
- Total product revenue.
- Monthly delivered product sales.
- Month-over-month revenue growth.

### 3. Payment Analysis
- Payment method distribution.
- Total payment value by payment method.
- Credit card installment patterns.
- Average payment value per order.
- Average payment record value by payment method.
- Delivered product sales by customer state.

### 4. Product Category Analysis
- Top product categories by delivered product sales.
- Average item price by category.
- Average freight cost by category.
- Total freight cost by category.

### 5. Customer Review Analysis
- Review score distribution.
- Overall average customer review score.
- Average review scores by order status.
- Percentage of negative reviews.
- Customer ratings for on-time and late deliveries.

### 6. Seller Analysis
- Seller distribution by state.
- Sellers ranked by delivered product sales.
- Sellers ranked by unique order volume.
- Seller-associated customer review performance.

## Key Business Findings

- Overall average customer review score: **4.09 out of 5**.
- Negative reviews (1–2 stars): **14.69%** of total reviews.
- Average review score for on-time deliveries: **4.29**.
- Average review score for late deliveries: **2.57**.
- Sellers with at least one delivered order: **2,970**.

## Business Recommendations

1. Improve delivery performance by investigating late deliveries.
2. Monitor negative customer feedback to identify service improvement opportunities.
3. Track seller performance through delivered product sales and order volume.
4. Evaluate product categories using sales value, item prices, and freight costs.
5. Monitor monthly cancellation rates to identify operational concerns.

## SQL Concepts Used

- SELECT, WHERE, GROUP BY, ORDER BY
- Aggregate functions: COUNT, SUM, AVG, MIN, MAX
- INNER JOIN and LEFT JOIN
- CASE WHEN
- Common Table Expressions (CTEs)
- Subqueries
- Window functions
- LAG()
- Date and timestamp functions
- Conditional aggregation
- DISTINCT and FILTER

## Project Conclusion

This project demonstrates how SQL can be used to analyze e-commerce data and answer practical business questions.

It covers customer behavior, order performance, product sales, payment patterns, seller performance, and customer satisfaction.

The project follows a business-focused approach by connecting SQL analysis with business interpretation and recommendations.

---

**Project Type:** Business Analytics | SQL Portfolio  
**Database:** PostgreSQL  
**Dataset:** Olist Brazilian E-Commerce Public Dataset
