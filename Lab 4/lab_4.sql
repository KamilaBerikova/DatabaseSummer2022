-- Exercise 1
-- 1a
SELECT *
FROM client cl
    JOIN dealer de
        ON cl.dealer_id = de.id;

-- 1b  What 'grade' mean?
SELECT dealer.name AS name_of_dealer, client.name AS client_name, client.city AS client_city, sell.id AS sell_number, sell.date AS sell_date,sell.amount AS sell_amount
FROM (sell
    JOIN client
        ON sell.client_id = client.id)
    JOIN dealer
        ON sell.dealer_id = dealer.id;

-- 1c find the dealer and client who belongs to same city?
SELECT client.id AS client_id, client.name AS client_name ,client.city AS client_city, dealer.id AS dealer_id, dealer.name AS dealer_name, dealer.location AS dealer_location
FROM client
    JOIN dealer
        ON client.city = dealer.location;

-- 1d find sell id, amount, client name, city those sells where sell amount exists between 100 and 500
SELECT sell.id AS sell_id,sell.amount AS sell_amount, client.name AS client_name, dealer.location AS sell_city
FROM sell
    JOIN client
        ON sell.client_id = client.id
    JOIN dealer
        ON sell.dealer_id = dealer.id
WHERE sell.amount BETWEEN 100 AND 500;

-- 1e find dealers who works either for one or more client or not yet join under any of the clients
SELECT dealer.id AS dealer_id,dealer.name AS dealer_name,dealer.location AS dealer_location, COUNT(client.id) AS client_number
FROM client
    RIGHT JOIN dealer
        ON client.dealer_id = dealer.id
GROUP BY dealer.id
ORDER BY client_number DESC;

-- 1f. find the dealers and the clients he service, return client name, city, dealer name, commission.
-- Does Comission mean Charge???
SELECT cl.name AS client_name,cl.city AS client_city, d.name AS dealer_name, d.charge AS commission
FROM client cl
    JOIN dealer d
        ON cl.dealer_id = d.id;

-- 1g. find client name, client city, dealer, commission those dealers who received a commission from the sell more than 12%
SELECT c.name AS client_name, c.city AS client_city,d.id AS dealer_id, d.name AS dealer_name, d.location AS dealer_location, d.charge AS dealer_comission
FROM client c
    JOIN dealer d
        ON c.dealer_id = d.id
WHERE d.charge > 0.12;

-- 1h. make a report with client name, city, sell id, sell date, sell amount, dealer name
-- and commission to find that either any of the existing clients haven’t made a
-- purchase(sell) or (made one or more purchase(sell)) by their dealer or by own.

SELECT c.name client_name, c.city client_city, s.id sell_id, s.date sell_date, s.amount sell_amount, d.name dealer_name, d.charge dealer_comisiion
FROM (sell s 
    RIGHT JOIN client c
        ON s.client_id = c.id)
    LEFT JOIN dealer d
        ON s.dealer_id = d.id;


-- 1i. find dealers who either work for one or more clients. The client may have made,
-- either one or more purchases, or purchase amount above 2000 and must have a
-- grade, or he may not have made any purchase to the associated dealer. Print
-- client name, client grade, dealer name, sell id, sell amount

CREATE VIEW client_sell_amount AS
    SELECT client_id,SUM(amount) AS total_sum
    FROM sell
    GROUP BY client_id;

SELECT c.name client_name, d2.name dealer_name, s.id sell_id, s.amount sell_amount, c_s_a.total_sum
FROM client c JOIN sell s
    ON s.client_id = c.id
LEFT JOIN dealer d2
    ON s.dealer_id = d2.id
JOIN client_sell_amount c_s_a
    ON c_s_a.client_id = c.id
WHERE s.dealer_id IN (SELECT DISTINCT d.id FROM client c JOIN dealer d on c.dealer_id = d.id)
   OR s.dealer_id IS NULL OR total_sum > 2000;

-- Views Part
-- Exercise 2

-- 2A. count the number of unique clients, compute average and total purchase amount of client orders by each date.
CREATE VIEW sell_info AS
SELECT date, COUNT(DISTINCT client_id) as unique_client_number, AVG(amount) as average_purchase, SUM(amount) as total_purchase
FROM sell
GROUP BY date;

SELECT * FROM sell_info;

-- 2B.  find top 5 dates with the greatest total sell amount
CREATE VIEW top_five_well_paid_dates AS
SELECT date,SUM(amount) AS total_sell_amount FROM sell
GROUP BY date
ORDER BY total_sell_amount DESC
LIMIT 5;

SELECT * FROM top_five_well_paid_dates
ORDER BY total_sell_amount ASC;

-- 2C. count the number of sales, compute average and total amount of all sales of each dealer

CREATE VIEW dealer_sales_statistics AS
SELECT dealer_id,COUNT(id) AS sales_number,AVG(amount) AS average_sales_amount, SUM(amount) AS total_sales
FROM sell
GROUP BY dealer_id;

SELECT * FROM dealer_sales_statistics;

-- 2D  compute how much all dealers earned from charge(total sell amount * charge) in each location

CREATE VIEW location_dealer_earned_money AS
SELECT d.location,SUM(s.amount * d.charge) AS dealer_earned_money
FROM sell s
    JOIN dealer d
        ON s.dealer_id = d.id
GROUP BY d.location;

SELECT *
FROM location_dealer_earned_money;

-- 2E. Compute number of sales, average and total amount of all sales dealers made in each location

CREATE VIEW location_sales_info AS
SELECT d.location, COUNT(s.id) AS number_sales, AVG(s.amount) AS average_sales_amount, SUM(s.amount) AS total_sales_amount
FROM sell s
    JOIN dealer d
        ON s.dealer_id = d.id
GROUP BY d.location;

SELECT *
FROM location_sales_info;

-- 2F. Compute number of sales, average and total amount of expenses in each city clients made.

CREATE VIEW client_city_sales_description AS
SELECT c.city, COUNT(s.id) AS sales_number, AVG(s.amount) AS average_expenses_amount, SUM(s.amount) AS total_expenses_amount
FROM sell s
    JOIN client c
        ON s.client_id = c.id
GROUP BY c.city;

SELECT *
FROM client_city_sales_description;

-- 2g. find cities where total expenses more than total amount of sales in locations

-- IF we consider null values of locations as 0
CREATE VIEW cities_largest_expenses_than_location_sales_null AS
SELECT city,total_expenses_amount
FROM location_sales_info l_s_i
    RIGHT JOIN client_city_sales_description c_c_s_d
        ON l_s_i.location = c_c_s_d.city
WHERE total_expenses_amount > total_sales_amount
    OR total_sales_amount IS NULL;

SELECT *
FROM cities_largest_expenses_than_location_sales_null;

-- IF we do not consider null values of locations at all
CREATE VIEW cities_largest_expenses_than_location_sales_not_null AS
SELECT city,total_expenses_amount
FROM location_sales_info l_s_i
    RIGHT JOIN client_city_sales_description c_c_s_d
        ON l_s_i.location = c_c_s_d.city
WHERE total_expenses_amount > total_sales_amount;

SELECT *
FROM cities_largest_expenses_than_location_sales_not_null;

