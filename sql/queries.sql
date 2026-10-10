-- =========================================================================
-- 1. Подготовка окружения и первая проверка данных
-- =========================================================================

-- Шаг 1.1: Первичная разведка базы
SELECT COUNT(*) AS total_rows 
FROM ecommerce_sales_customer_analytics;

-- Шаг 1.2: Проверка крайних значений и статус-аудит
SELECT MIN(gross_sales), MAX(gross_sales), MIN(profit), MAX(profit) 
FROM ecommerce_sales_customer_analytics;

SELECT order_status, COUNT(*) 
FROM ecommerce_sales_customer_analytics 
GROUP BY order_status;


-- =========================================================================
-- 2. Локализация финансовых потерь
-- =========================================================================

-- Шаг 2.1: Анализ каналов продаж
SELECT 
    sales_channel, 
    SUM(gross_sales) AS total_gross, 
    SUM(profit) AS total_profit, 
    SUM(discount_amount) AS total_discount
FROM ecommerce_sales_customer_analytics 
GROUP BY sales_channel 
ORDER BY total_profit DESC;

-- Шаг 2.2: Изоляция убыточных сделок
SELECT COUNT(*), AVG(discount_amount)
FROM ecommerce_sales_customer_analytics 
WHERE profit < 0;


-- =========================================================================
-- 3. Поиск причин убыточности
-- =========================================================================

-- Шаг 3.1: Сравнение прибыльных (Profit) и убыточных (Loss) групп
SELECT 
    CASE WHEN profit < 0 THEN 'Loss' ELSE 'Profit' END AS profit_status,
    COUNT(*) AS order_count,
    ROUND(AVG(discount_amount), 2) AS avg_discount,
    ROUND(AVG(shipping_cost), 2) AS avg_shipping,
    ROUND(AVG(profit_margin_percentage), 2) AS avg_margin_pct
FROM ecommerce_sales_customer_analytics
GROUP BY CASE WHEN profit < 0 THEN 'Loss' ELSE 'Profit' END;

-- Шаг 3.2: Топ-10 самых убыточных транзакций
SELECT order_id, sales_channel, gross_sales, discount_amount, shipping_cost, profit, coupon_code
FROM ecommerce_sales_customer_analytics 
WHERE profit < 0
ORDER BY profit ASC 
LIMIT 10;


-- =========================================================================
-- 4. Поиск источника скидочных аномалий
-- =========================================================================

-- Шаг 4.1: Проверка эффективности купонов (coupon_code)
SELECT 
    coupon_code,
    COUNT(*) AS total_orders,
    SUM(profit) AS total_profit,
    SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS loss_orders_count
FROM ecommerce_sales_customer_analytics 
GROUP BY coupon_code
ORDER BY total_profit ASC;

-- Шаг 4.2: Детализация убытков по маркетинговым каналам и кампаниям
SELECT 
    marketing_channel, 
    campaign_name, 
    COUNT(*) AS loss_orders_count, 
    ROUND(SUM(profit), 2) AS total_loss, 
    ROUND(AVG(discount_amount), 2) AS avg_discount
FROM ecommerce_sales_customer_analytics
WHERE profit < 0 
  AND (coupon_code IS NULL OR coupon_code = '')
GROUP BY marketing_channel, campaign_name
ORDER BY total_loss ASC;


-- =========================================================================
-- 5. Анализ клиентоцентричности и сегментация (LTV)
-- =========================================================================

-- Шаг 5.1: Оценка ценности повторных клиентов (Retention Economics)
SELECT 
    is_repeat_customer,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(AVG(customer_lifetime_value), 2) AS avg_ltv,
    ROUND(AVG(customer_order_count), 2) AS avg_orders_per_customer,
    ROUND(SUM(profit), 2) AS total_profit
FROM ecommerce_sales_customer_analytics
GROUP BY is_repeat_customer;

-- Шаг 5.2: Анализ маржинальности по сегментам клиентов
SELECT 
    customer_segment,
    COUNT(DISTINCT customer_id),
    AVG(gross_sales),
    AVG(profit_margin_percentage)
FROM ecommerce_sales_customer_analytics esca 
GROUP BY customer_segment
ORDER BY SUM(profit) DESC;


-- =========================================================================
-- 6. Продвинутый SQL: Оконные функции (Window Functions)
-- =========================================================================

-- Шаг 6.1: Ранжирование топ-клиентов внутри сегментов
WITH cte AS (
    SELECT 
        customer_segment,
        customer_id,
        customer_name,
        SUM(gross_sales) AS total_spent,
        DENSE_RANK() OVER (PARTITION BY customer_segment ORDER BY SUM(gross_sales) DESC) AS rank_in_segment
    FROM ecommerce_sales_customer_analytics
    GROUP BY customer_segment, customer_id, customer_name
)
SELECT customer_segment, rank_in_segment, customer_id, customer_name, total_spent
FROM cte 
WHERE rank_in_segment <= 3
ORDER BY customer_segment, rank_in_segment;


-- =========================================================================
-- 7. Операционные риски и логистика (Возвраты и отмены)
-- =========================================================================

-- Шаг 7.1: Аудит статусов заказов по каналам
SELECT
    sales_channel,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_count,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    ROUND(1.0 * SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS return_percent
FROM ecommerce_sales_customer_analytics
GROUP BY sales_channel
ORDER BY return_percent DESC;


-- =========================================================================
-- 8. Когортный анализ (Cohort Analysis)
-- =========================================================================

-- Шаг 8.1: Динамика привлечения по месяцам первой покупки
WITH customer_cohorts AS (
    SELECT
        customer_id,
        SUBSTR(MIN(order_date), 1, 7) AS cohort_month
    FROM ecommerce_sales_customer_analytics
    GROUP BY customer_id
)
SELECT
    cc.cohort_month,
    COUNT(DISTINCT cc.customer_id) AS cohort_size,
    ROUND(SUM(e.gross_sales), 2) AS total_gross,
    ROUND(SUM(e.profit), 2) AS total_profit
FROM customer_cohorts cc
JOIN ecommerce_sales_customer_analytics e ON cc.customer_id = e.customer_id
GROUP BY cc.cohort_month
ORDER BY cc.cohort_month;
