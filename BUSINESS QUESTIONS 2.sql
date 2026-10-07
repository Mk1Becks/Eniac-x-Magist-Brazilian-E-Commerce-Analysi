USE magist;

-- BUSINESS QUESTIONS 2
-- Ziel: Bewertung der Lieferanten- und Bestellperformance von Magist.
-- Untersucht werden die Pünktlichkeit der Seller, der durchschnittliche
-- Umsatz pro Bestellung sowie der Zusammenhang zwischen Lieferpünktlichkeit
-- und Kundenzufriedenheit.




-- 1. Pünktlichkeitsquote der Seller
-- Hier vergleichen wir das tatsächliche Lieferdatum mit dem geschätzten Lieferdatum.


SELECT 
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN oi.order_id
        END) AS on_time_orders,
    ROUND(100.0 * COUNT(DISTINCT CASE
                    WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN oi.order_id
                END) / COUNT(DISTINCT oi.order_id),
            2) AS on_time_percentage
FROM
    order_items oi
        JOIN
    orders o ON oi.order_id = o.order_id
WHERE
    o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
ORDER BY on_time_percentage DESC;


-- 2. Durchschnittlicher Umsatz pro Bestellung
-- Hier nehmen wir den Umsatz aus order_items.price und teilen ihn durch die Anzahl der Bestellungen.

SELECT 
    ROUND(SUM(oi.price) / COUNT(DISTINCT oi.order_id),
            2) AS average_revenue_per_order
FROM
    order_items oi;



-- 3. Bewertung: pünktlich vs. verspätet
-- Hier verbinden wir orders mit order_reviews und vergleichen die Bewertung.



SELECT 
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'Pünktlich'
        ELSE 'Verspätet'
    END AS delivery_status,
    COUNT(*) AS number_of_reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM
    orders o
        JOIN
    order_reviews r ON o.order_id = r.order_id
WHERE
    o.order_delivered_customer_date IS NOT NULL
GROUP BY CASE
    WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'Pünktlich'
    ELSE 'Verspätet'
END;


-- FAZIT:
-- Diese drei Analysen helfen dabei, die Qualität und Wirtschaftlichkeit
-- des Magist-Marktplatzes zu bewerten. Besonders relevant sind dabei
-- zuverlässige Seller, der durchschnittliche Bestellwert und der Einfluss
-- verspäteter Lieferungen auf die Kundenzufriedenheit.



