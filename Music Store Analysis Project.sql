--Question Set 1
--Q1.Who is the senior most employee based on job title?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

--Q2.Which countries have the most Invoices?
SELECT COUNT(*) AS num_invoices, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY num_invoices DESC

--Q3.What are top 3 values of total invoice?
SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3

--Q4.Which city has the best customers? We would like to throw a promotional
--Music Festival in the city we made the most money. Write a query that
--returns one city that has the highest sum of invoice totals.
--Return both the city name & sum of all invoice totals.
SELECT billing_city,SUM(total) AS "Total_Business"
FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC

--Q5.Who is the best customer? The customer who has spent the most money
--will be declared the best customer. Write a query that returns the
--person who has spent the most money.
SELECT customer.customer_id, customer.first_name, customer.last_name,
SUM(total) AS total_invoice
FROM customer
INNER JOIN invoice
ON customer.customer_id=invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_invoice DESC
LIMIT 1

--Question Set 2
--Q1.Write query to return the email, first name, last name, & Genre of all
--Rock Music listeners. Return your list ordered alphabetically by email
--starting with A
SELECT DISTINCT email, first_name, last_name
FROM customer
INNER JOIN invoice ON customer.customer_id=invoice.customer_id
INNER JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN
(SELECT track_id
FROM track
INNER JOIN genre
ON track.genre_id=genre.genre_id
WHERE genre.name='Rock')
ORDER BY email ASC

--Q2.Let's invite the artists who have written the most rock music in our
--dataset. Write a query that returns the Artist name and total track count
--of the top 10 rock bands.
SELECT artist.name, COUNT(track_id) AS number_of_songs
FROM track
INNER JOIN album
ON track.album_id=album.album_id
INNER JOIN artist
ON album.artist_id=artist.artist_id
INNER JOIN genre
ON genre.genre_id=track.genre_id
WHERE genre.name='Rock'
GROUP BY artist.name
ORDER BY number_of_songs DESC
LIMIT 10

--Q3.Return all the track names that have a song length longer than the
--average song length. Return the Name and Milliseconds for each track.
--Order by the song length with the longest songs listed first.
SELECT name, milliseconds
FROM track
WHERE milliseconds >
(SELECT AVG(milliseconds) AS avg_track_length FROM track)
ORDER BY milliseconds DESC

--Question Set 3
--Q1.Find how much amount spent by each customer on artists?
--Write a query to return customer name, artist name and total spent.
WITH top_artists AS (SELECT artist.artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM invoice_line
JOIN track
ON invoice_line.track_id=track.track_id
JOIN album
ON track.album_id=album.album_id
JOIN artist
ON album.artist_id=artist.artist_id
GROUP BY artist.artist_id
ORDER BY total_sales DESC),

cte AS (SELECT customer.customer_id, customer.first_name, customer.last_name,
top_artists.artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS amount_spent 
FROM invoice
JOIN customer
ON customer.customer_id=invoice.customer_id
JOIN invoice_line
ON invoice.invoice_id=invoice_line.invoice_id
JOIN track
ON invoice_line.track_id=track.track_id
JOIN album
ON track.album_id=album.album_id
JOIN top_artists
ON top_artists.artist_id=album.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC)
-- Run the above query by removing the , cte AS () to answer the second part of the question.
-- Run the above and below query together to answer the first part of the question.
SELECT customer_id, first_name, last_name, SUM(amount_spent)
FROM cte
GROUP BY 1,2,3
ORDER BY 4 DESC

--Q2.We want to find out the most popular music Genre for each country.
--We determine the most popular genre as the genre with the highest amount
--of purchases. Write a query that returns each country along with the top
--Genre. For countries where the maximum number of purchases is shared
--return all Genres.
WITH popular_genre AS
(SELECT genre.name AS genre_name, COUNT(invoice_line.quantity) AS purchases,
invoice.billing_country,
ROW_NUMBER() OVER
(PARTITION BY invoice.billing_country
ORDER BY COUNT(invoice_line.quantity) DESC) AS row_number
FROM invoice_line
JOIN invoice ON invoice_line.invoice_id=invoice.invoice_id
JOIN track ON invoice_line.track_id=track.track_id
JOIN genre ON track.genre_id=genre.genre_id
GROUP BY 1,3
ORDER BY 3 ASC, 2 DESC)
SELECT * FROM popular_genre WHERE row_number=1

--Q3.Write a query that determines the customer that has spent the most on
--music for each country. Write a query that returns the country along with
--the top customer and how much they spent. For countries where the top
--amount spent is shared, provide all customers who spent this amount.
WITH customer_with_country AS
(SELECT customer.customer_id, first_name, last_name, billing_country,
SUM(total) AS total_spending,
ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS row_number
FROM invoice
JOIN customer ON customer.customer_id=invoice.customer_id
GROUP BY 1,2,3,4
ORDER BY 4 ASC, 5 DESC)

SELECT * FROM customer_with_country WHERE row_number=1

