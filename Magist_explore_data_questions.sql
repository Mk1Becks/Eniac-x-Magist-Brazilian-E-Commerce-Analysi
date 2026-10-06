USE Magist;

-- 1. how many orders 
SELECT Count(*) AS orders_count
FROM orders;

-- 2. Orders delivered?
SELECT order_status, Count(*) AS orders_count
FROM orders
GROUP BY order_status;

-- 3. USER WACHSTUM
SELECT YEAR(order_purchase_timestamp) AS YEAR_, MONTH(order_purchase_timestamp) AS MONTH_, COUNT(customer_id)
FROM orders
GROUP BY YEAR_, MONTH_
ORDER BY YEAR_, MONTH_;

-- 4. how many products?
SELECT Count( DISTINCT product_id) AS products_count
FROM products;

-- 5. Which are the categories with most products?
SELECT product_category_name, Count( DISTINCT product_id) AS products_count
FROM products
GROUP BY product_category_name
ORDER BY products_count DESC
LIMIT 15;


-- 6. How many of those products were present in actual transactions?
SELECT count(DISTINCT product_id) AS n_products
FROM order_items;

-- 7. What’s the price for the most expensive and cheapest products?
SELECT 
    MIN(price) AS cheapest, 
    MAX(price) AS most_expensive
FROM order_items;

-- 8. What are the highest and lowest payment values?
SELECT MAX(payment_value) AS highest, 
	   MIN(payment_value) AS lowest
FROM order_payments
WHERE payment_value NOT IN ("not_defined", "voucher");


-- maximus someone paid for an order 
SELECT SUM(payment_value) as highest_order
FROM order_payments
GROUP BY order_id
ORDER BY highest_order
LIMIT 1;

-- BUSINESS QUESTIONS

-- 2.1. In relation to the products:

-- 1. What categories of tech products does Magist have?
SELECT distinct product_category_name_english
FROM product_category_name_translation
ORDER BY product_category_name_english;

-- audio, electronics, computers, computer_accessories, consoles_games, pc_gamer, Telephony


-- 2. How many products of these tech categories have been sold (within the time window of the database snapshot)?
--What percentage does that represent from the overall number of products sold?

SELECT COUNT(oi.product_id) AS total_tech_sales, (SELECT COUNT(*) FROM order_items) AS total_sales,
ROUND((Count(oi.product_id) / (SELECT COUNT(*) FROM order_items)) * 100, 2) AS percentage_tech_sales
FROM order_items AS oi
JOIN products AS p USING(product_id)
WHERE p.product_category_name IN ("audio", "cine_foto", "climatizacao", "consoles_games", "eletronicos", "eletrodomesticos", "eletrodomesticos_2", "eletroportateis", "informatica_acessorios",
"pc_gamer", "pcs", "portateis_casa_forno_e_cafe", "portateis_cozinha_e_preparadores_de_alimentos", "tablets_impressao_imagem", "telefonia", "telefonia_fixa");
-- 3. What’s the average price of the products being sold?

SELECT AVG(oi.price) AS avg_price
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';
-- alternative
SELECT 
  ROUND(AVG(oi.price), 2) AS avg_price,
  ROUND(MIN(oi.price), 2) AS min_price,
  ROUND(MAX(oi.price), 2) AS max_price
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

-- 4. Are expensive tech products popular? *
--  TIP: Look at the function CASE WHEN to accomplish this task.
SELECT 
CASE	WHEN oi.price >= 119.98 THEN "Teuer (>=119.98)"
		ELSE "Guenstig (<119.98)"
END AS price_category,
	COUNT(oi.product_id) AS total_tech_sales, (SELECT COUNT(*) FROM order_items) AS total_sales, 
	ROUND((Count(oi.product_id) / (SELECT COUNT(*) FROM order_items)) * 100, 2) AS percentage_tech_sales
FROM order_items AS oi
JOIN products AS p USING(product_id)
WHERE product_category_name IN ("audio", "cine_foto", "climatizacao", "consoles_games", "eletronicos", "eletrodomesticos", "eletrodomesticos_2", "eletroportateis", "informatica_acessorios",
"pc_gamer", "pcs", "portateis_casa_forno_e_cafe", "portateis_cozinha_e_preparadores_de_alimentos", "tablets_impressao_imagem", "telefonia", "telefonia_fixa")

GROUP BY price_category; 

-- Alternative

SELECT
    CASE
        WHEN oi.price >= 119.98 THEN 'Expensive'
        ELSE 'Not expensive'
    END AS price_category,
    COUNT(*) AS sold_products,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_category_name IN (
    'audio',
  'cine_foto',
  'climatizacao',
  'consoles_games',
  'eletronicos',
  'eletrodomesticos',
  'eletrodomesticos_2',
  'eletroportateis',
  'informatica_acessorios',
  'pc_gamer',
  'pcs',
  'portateis_casa_forno_e_cafe',
  'portateis_cozinha_e_preparadores_de_alimentos',
  'tablets_impressao_imagem',
  'telefonia',
  'telefonia_fixa'
)
GROUP BY
    CASE
        WHEN oi.price >= 119.98 THEN 'Expensive'
        ELSE 'Not expensive'
    END;

-- 2.2. In relation to the sellers:

-- 1. How many months of data are included in the magist database? 25 Months
SELECT timestampdiff(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) AS months_count,
MIN(order_purchase_timestamp) AS earliest_order,
MAX(order_purchase_timestamp) AS latest_order
FROM orders;
-- 2. How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
SELECT
  (SELECT COUNT(*) FROM sellers) AS total_sellers,
  COUNT(DISTINCT oi.seller_id) AS tech_sellers,
  ROUND(COUNT(DISTINCT oi.seller_id) * 100.0 / (SELECT COUNT(*) FROM sellers), 2) AS pct_tech_sellers
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
WHERE p.product_category_name IN (
  'audio','cine_foto','climatizacao','consoles_games','eletronicos',
  'eletrodomesticos','eletrodomesticos_2','eletroportateis',
  'informatica_acessorios','pc_gamer','pcs',
  'portateis_casa_forno_e_cafe','portateis_cozinha_e_preparadores_de_alimentos',
  'tablets_impressao_imagem','telefonia','telefonia_fixa'
);

-- 3. What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
SELECT 
    ROUND(SUM(oi.price), 2) AS Gesamtverdienst,
    ROUND(SUM(CASE
                WHEN
                    p.product_category_name IN ('audio' , 'cine_foto',
                        'consoles_games',
                        'eletronicos',
                        'eletrodomesticos',
                        'eletrodomesticos_2',
                        'eletroportateis',
                        'informatica_acessorios',
                        'pc_gamer',
                        'pcs',
                        'portateis_casa_forno_e_cafe',
                        'portateis_cozinha_e_preparadores_de_alimentos',
                        'tablets_impressao_imagem',
                        'telefonia',
                        'telefonia_fixa')
                THEN
                    oi.price
                ELSE 0
            END),
            2) AS Tech_Gesamtverdienst
FROM
    order_items oi
        JOIN
    products p ON oi.product_id = p.product_id;

SELECT 
  ROUND(SUM(oi.price), 2) AS total_earned_all
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered' AND product_category_name IN (
  'audio','cine_foto','climatizacao','consoles_games','eletronicos',
  'eletrodomesticos','eletrodomesticos_2','eletroportateis',
  'informatica_acessorios','pc_gamer','pcs',
  'portateis_casa_forno_e_cafe','portateis_cozinha_e_preparadores_de_alimentos',
  'tablets_impressao_imagem','telefonia','telefonia_fixa') ;



-- 4. Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?

SELECT 
    ROUND(SUM(oi.price) / COUNT(DISTINCT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')),
            2) AS average_monthly_income,
    ROUND(SUM(CASE
                WHEN
                    p.product_category_name IN ('audio' , 'cine_foto',
                        'climatizacao',
                        'consoles_games',
                        'eletronicos',
                        'eletrodomesticos',
                        'eletrodomesticos_2',
                        'eletroportateis',
                        'informatica_acessorios',
                        'pc_gamer',
                        'pcs',
                        'portateis_casa_forno_e_cafe',
                        'portateis_cozinha_e_preparadores_de_alimentos',
                        'tablets_impressao_imagem',
                        'telefonia',
                        'telefonia_fixa')
                THEN
                    oi.price
                ELSE 0
            END) / COUNT(DISTINCT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')),
            2) AS average_monthly_tech_income
FROM
    order_items oi
        JOIN
    orders o ON oi.order_id = o.order_id
        JOIN
    products p ON oi.product_id = p.product_id;

-- 2.3. In relation to the delivery time:

-- 1. What’s the average time between the order being placed and the product being delivered?
-- 2. Is there any pattern for delayed orders, e.g. big products being delayed more often?*/

