# Customer's First Rental
DROP TEMPORARY TABLE IF EXISTS first_rental;
CREATE TEMPORARY TABLE first_rental
SELECT 
	r.customer_id,
	MIN(r.rental_date) first_time
FROM
	rental r 
GROUP BY 1
;


# Cohort Size
DROP TEMPORARY TABLE IF EXISTS cohort_size;
CREATE TEMPORARY TABLE cohort_size
SELECT
	LEFT(first_time, 7) Month,
	COUNT(*) num
FROM
	first_rental
GROUP BY 1
;


# Cohort Table
DROP TEMPORARY TABLE IF EXISTS cohort;
CREATE TEMPORARY TABLE cohort
SELECT 
	date_format(fr.first_time, "%Y%m") cohort_date,
	date_format(r.rental_date, "%Y%m") rental_date,
	# LEFT(fr.first_time, 7) cohort,
	# LEFT(r.rental_date, 7) rental_month,
	cs.num cohort_size,
	SUM(p.amount) revenue,
	SUM(p.amount)/cs.num RPU
FROM 
	rental r
		JOIN payment p
			ON p.rental_id = r.rental_id
		JOIN first_rental fr
			ON r.customer_id = fr.customer_id
		JOIN cohort_size cs
			ON cs.Month = LEFT(fr.first_time, 7)
GROUP BY 1, 2
;


# Pretiffy
SELECT 
	cohort_date,
	PERIOD_DIFF(rental_date, cohort_date) months_after_first_rental,
	cohort_size,
	revenue,
	RPU
FROM cohort
ORDER BY cohort_date, months_after_first_rental
;
