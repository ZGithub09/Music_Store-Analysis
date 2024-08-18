-- Q1: who is the senior most employee based on job title?

SELECT * from employee
ORDER BY levels desc
LIMIT 1;
-- Madan Mohan is the senior most employee.

-- Q2: Which countries have the most invoices?

SELECT billing_country, COUNT(*) as most_invoices_count 
FROM invoice
GROUP BY billing_country
ORDER BY most_invoices_count desc;

-- Most invoices are from the USA - 131

-- Q3: What are top 3 values of total invoice?

SELECT total FROM invoice
ORDER BY total desc
LIMIT 3;
-- Top 3 values of total invoices are 23.76, 19.8, 19.8

/*Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
Write a query that returns one city that has the highest sum of invoice totals.
Return both the city name & sum of all invoice totals*/

SELECT billing_city, sum(total) as total_invoice
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice desc;
-- Best customers are Prague and invoice_total - 273.24

/*Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer.
Write a query that returns the person who has spent the most money*/

SELECT c.customer_id, c.first_name, c.last_name, sum(i.total) as spent_money from customer as c
	join invoice as i on  c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY spent_money desc
limit 1;
-- Best customer is R Madhav and spent_money - 144.54

-- Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
-- Return your list ordered alphabetically by email starting with A

SELECT c.customer_id, c.email, c.first_name, c.last_name, g.name from genre as g
	join track as t on g.genre_id= t.genre_id
	join invoice_line as il on t.unit_price = il.unit_price
	join invoice as i on il.invoice_id = i.invoice_id
	join customer as c on i.customer_id= c.customer_id 
WHERE g.name like 'Rock'
GROUP BY c.customer_id, g.name
order by c.email;

-- Q7:Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id= track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

-- Q8: Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track.
-- Order by the song length with the longest songs listed first

SELECT name, milliseconds FROM track
WHERE  milliseconds > (SELECT avg(milliseconds) from track)
ORDER BY milliseconds desc;

/*Q9: Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent */

WITH best_selling_artist AS (SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id= track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
) 
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id= i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id= t.album_id
JOIN artist ar ON ar.artist_id = alb.artist_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY amount_spent DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;

