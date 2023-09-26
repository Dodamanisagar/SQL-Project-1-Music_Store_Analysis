-- Q1: Who is the senior most employee based on job title?
-- Table used:-
SELECT * FROM EMPLOYEE;

SELECT *
FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1;



-- Q2: Which country has the most invoices
-- Table used:-
SELECT * FROM INVOICE;

SELECT BILLING_COUNTRY,COUNT(INVOICE_ID) AS COUNTs
FROM INVOICE
GROUP BY 1
ORDER BY COUNTs DESC
LIMIT 1;



-- Q3: What are the top 3 values of total invoices
-- Table used:-
SELECT * FROM INVOICE; 

SELECT TOTAL
FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3;



/* Q4: Which city has the best customers? We would like to throw a
promotional Music Festival in the City we made the most money. Write a
query that returns one city that has the highest sum of invoice totals.
Return both the city name & sum of all invoice totals.*/
-- Table used:-
SELECT * FROM INVOICE;

SELECT BILLING_CITY,SUM(TOTAL) AS INVOICE_TOTAL
FROM INVOICE
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;



/*Q5: Who is the best customer? The customer who has spent the most
money will be declared the best customer. Write a query that returns
the person who has spent the most money.*/
-- Table used:-
SELECT * FROM CUSTOMER;
SELECT * FROM INVOICE;

-- solving using Joins
SELECT C.*,SUM(I.TOTAL)AS TOTAL 
FROM CUSTOMER C
NATURAL JOIN INVOICE I
GROUP BY C.CUSTOMER_ID
ORDER BY TOTAL DESC
LIMIT 1;

-- solving using joins and windows function
SELECT ranking.*, total_spending
FROM (
    SELECT
        c.*,
        SUM(i.total) AS total_spending,
        RANK() OVER (ORDER BY SUM(i.total) DESC) AS spending_rank
    FROM customer c
    JOIN invoice i using(customer_id)
    GROUP BY c.customer_id, c.first_name
) AS ranking
WHERE spending_rank = 1;



/*Q6: Find city wise best customer? The customer who has spent the most
money will be declared the best customer in that city. Write a query that returns
the person who has spent the most money city wise.*/
-- Table used:-
SELECT * FROM CUSTOMER;
SELECT * FROM INVOICE;

-- solving using joins and windows function
SELECT ranking.*, total_spending
FROM (
    SELECT
        c.*,
        SUM(i.total) AS total_spending,
        RANK() OVER (partition by c.city ORDER BY SUM(i.total) DESC) AS spending_rank
    FROM customer c
    JOIN invoice i using(customer_id)
    GROUP BY c.customer_id, c.first_name
) AS ranking
WHERE spending_rank = 1;



/*Q7: Write query to return the email, first name, last name, & Genre
of all Rock Music listeners. Return your list ordered alphabetically
by email starting with A */
-- Table used:-
SELECT * FROM CUSTOMER;
SELECT * FROM GENRE;
SELECT * FROM PLAYLIST;
SELECT * FROM GENRE;

-- using only joins
SELECT 
	distinct C.EMAIL AS MAIL,
	C.FIRST_NAME AS FIRST_NAME,
	C.LAST_NAME AS LAST_NAME,
	G.GENRE_ID
FROM CUSTOMER C
JOIN INVOICE I USING(CUSTOMER_ID)
JOIN INVOICE_LINE IL ON I.INVOICE_ID=IL.INVOICE_ID
JOIN TRACK T ON IL.TRACK_ID=T.TRACK_ID
JOIN GENRE G ON T.GENRE_ID=G.GENRE_ID
WHERE G.NAME='Rock'
ORDER BY 1;

-- using joins and subquery
SELECT 
	DISTINCT C.EMAIL AS MAIL,
	C.FIRST_NAME AS FIRST_NAME,
	C.LAST_NAME AS LAST_NAME
FROM CUSTOMER C
JOIN INVOICE I USING(CUSTOMER_ID)
JOIN INVOICE_LINE IL USING(INVOICE_ID)
WHERE TRACK_ID IN(SELECT TRACK_ID FROM TRACK JOIN GENRE USING(GENRE_ID) WHERE GENRE.NAME='Rock')
ORDER BY 1;



/*Q8: Let's invite the artists who have written the most rock music in
our dataset. Write a query that returns the Artist name and total
track count of the top 10 rock bands*/
-- Table used:-
SELECT * FROM ARTIST;
SELECT * FROM ALBUM;
SELECT * FROM TRACK;
SELECT * FROM GENRE;

SELECT 
	ARTIST.NAME AS NAME,
	COUNT(*) AS TOTAL_COUNT,
	ARTIST.ARTIST_ID AS ARTIST_ID
FROM ARTIST
JOIN ALBUM USING(ARTIST_ID)
JOIN TRACK USING(ALBUM_ID)
JOIN GENRE USING(GENRE_ID)
WHERE GENRE.NAME='Rock'
GROUP BY 1,3
ORDER BY 2 DESC
LIMIT 10;



/*Q9: Return all the track names that have a song length longer than
the average song length. Return the Name and Milliseconds for
each track. Order by the song length with the longest songs listed
first.*/
-- Table used:-
SELECT * FROM TRACK;

SELECT NAME,MILLISECONDS
FROM TRACK
WHERE MILLISECONDS>(SELECT AVG(MILLISECONDS) FROM TRACK)
ORDER BY MILLISECONDS DESC;



/*Q10: Find how much amount spent by each customer on artists? Write a
query to return customer name, artist name and total spent*/
-- Table used:-
SELECT * FROM CUSTOMER;
SELECT * FROM INVOICE;
SELECT * FROM INVOICE_LINE;
SELECT * FROM TRACK;
SELECT * FROM ALBUM;
SELECT * FROM ARTIST;

 
SELECT
    C.FIRST_NAME || ' ' || C.LAST_NAME AS CUSTOMER_NAME,
    AR.NAME AS ARTIST_NAME,
    SUM(IL.UNIT_PRICE * IL.QUANTITY) AS TOTAL_SPENT
FROM CUSTOMER C
JOIN INVOICE I USING(CUSTOMER_ID)
JOIN INVOICE_LINE IL USING(INVOICE_ID)
JOIN TRACK T USING(TRACK_ID)
JOIN ALBUM AL USING(ALBUM_ID)
JOIN ARTIST AR USING(ARTIST_ID)
GROUP BY
    C.CUSTOMER_ID, AR.ARTIST_ID
ORDER BY
    CUSTOMER_NAME, ARTIST_NAME;
	
	
	
/*Q11: We want to find out the most popular music Genre for each country.
We determine the most popular genre as the genre with the highest
amount of purchases. Write a query that returns each country along with
the top Genre. For countries where the maximum number of purchases
is shared return all Genres.*/
-- Table used:-
SELECT * FROM GENRE;
SELECT * FROM TRACK;
SELECT * FROM INVOICE_LINE;
SELECT * FROM INVOICE;
SELECT * FROM CUSTOMER;

WITH CTE AS(
	SELECT
	GENRE.GENRE_ID AS GENRE_ID,
	GENRE.NAME AS GENRE_NAME,
	CUSTOMER.COUNTRY AS COUNTRY,
	COUNT(INVOICE_LINE.QUANTITY)AS TOTAL_PURCHASES,
	ROW_NUMBER() OVER(PARTITION BY CUSTOMER.COUNTRY ORDER BY COUNT(INVOICE_LINE.QUANTITY) DESC) AS RANKING
FROM GENRE
JOIN TRACK USING(GENRE_ID)
JOIN INVOICE_LINE USING(TRACK_ID)
JOIN INVOICE USING(INVOICE_ID)
JOIN CUSTOMER USING(CUSTOMER_ID)
GROUP BY 1,3	
)
SELECT 
	COUNTRY,
	GENRE_ID,
	GENRE_NAME,
	TOTAL_PURCHASES
FROM CTE
WHERE RANKING=1;



/* Q12: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
-- Table used:-
SELECT * FROM CUSTOMER;
SELECT * FROM INVOICE;

WITH CTE AS(
	SELECT
	(CUSTOMER.FIRST_NAME ||' '||CUSTOMER.LAST_NAME) AS CUSTOMER_NAME,
	CUSTOMER.CUSTOMER_ID AS CUSTOMER_ID,
	SUM(INVOICE.TOTAL) AS TOTAL_SPENT,
	CUSTOMER.COUNTRY AS COUNTRY,
	ROW_NUMBER() OVER(PARTITION BY CUSTOMER.COUNTRY ORDER BY SUM(INVOICE.TOTAL) DESC) AS RANKING
FROM CUSTOMER
JOIN INVOICE USING(CUSTOMER_ID)
GROUP BY 1,2,4
ORDER BY 2,3 DESC
)
SELECT 
	CUSTOMER_ID,
	CUSTOMER_NAME,
	TOTAL_SPENT,
	COUNTRY
FROM CTE
WHERE RANKING=1;



