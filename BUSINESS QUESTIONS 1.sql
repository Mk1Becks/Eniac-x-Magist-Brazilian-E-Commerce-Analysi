USE magist;

-- BUSINESS QUESTIONS 1
-- Ziel: Herausfinden, ob Magist für den Vertrieb von Tech-Produkten geeignet ist.
-- Dafür untersuchen wir drei zentrale Bereiche:
-- 1. Welche Tech-Produktkategorien erzielen den höchsten Umsatz?
-- 2. Welche Seller liefern Tech-Produkte besonders schnell?
-- 3. In welchen Bundesstaaten und Städten erzielt Magist den höchsten Umsatz?
--
-- Die Ergebnisse helfen dabei, das Produktangebot, die Auswahl der Seller
-- und die geografischen Absatzmärkte für eine mögliche Zusammenarbeit mit
-- Magist zu bewerten.



-- 1. **Welche Produktkategorien bringen den meisten Umsatz?**

-- Insgesamt

SELECT 
    p.product_category_name, SUM(oi.price) AS total_revenue
FROM
    order_items oi
        JOIN
    products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;


-- Techprodukte

SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS total_revenue
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
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;


-- 2. Welche Lieferanten liefern besonders schnell und zuverlässig?
-- Fokus: relevante Tech-Produkte
-- Nur Seller mit mindestens 100 Tech-Bestellungen

SELECT 
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS number_of_orders,

    ROUND(
        AVG(
            DATEDIFF(
                o.order_delivered_customer_date,
                o.order_purchase_timestamp
            )
        ), 2
    ) AS avg_delivery_days

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

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

AND o.order_delivered_customer_date IS NOT NULL

GROUP BY oi.seller_id

HAVING COUNT(DISTINCT oi.order_id) >= 100

ORDER BY avg_delivery_days ASC;



-- 3. In welchen Bundesstaaten und Städten verkauft Magist am erfolgreichsten?

SELECT
    g.state,
    g.city,
    COUNT(DISTINCT o.order_id) AS number_of_orders,
    SUM(oi.price) AS total_revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN geo g
    ON c.customer_zip_code_prefix = g.zip_code_prefix
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY g.state, g.city
ORDER BY total_revenue DESC;

-- FAZIT:
-- Die drei Analysen zeigen, welche Tech-Produkte besonders umsatzstark sind,
-- welche Seller eine gute Lieferperformance bieten und wo Magist besonders
-- erfolgreich verkauft. Damit können wir besser beurteilen, ob Magist für
-- den geplanten Vertrieb von Tech-Produkten geeignet ist.

