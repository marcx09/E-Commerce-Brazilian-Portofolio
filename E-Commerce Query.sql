SELECT *
FROM EcommercePorto..OrderData

--Customer Order Status that Canceled

SELECT cus.customer_id, order_status, order_delivered_carrier_date, customer_city
FROM EcommercePorto..CustomerData cus
JOIN EcommercePorto..OrderData ord
	ON cus.customer_id = ord.customer_id
WHERE order_status = 'canceled' AND order_delivered_carrier_date is NOT NULL
ORDER BY cus.customer_id

-- Customer Order that using Voucher as Payment

SELECT cus.customer_id, ord.order_id, payment_type
FROM EcommercePorto..CustomerData cus
JOIN EcommercePorto..OrderData ord
	ON cus.customer_id = ord.customer_id
JOIN EcommercePorto..OrderPaymentData pay
	ON ord.order_id = pay.order_id
WHERE payment_type = 'voucher'
ORDER BY cus.customer_id


-- The Most Customer Order Product in Sao Paolo

SELECT customer_id, customer_city, order_id, product_category_name, RollingCount
FROM (
	SELECT cus.customer_id, cus.customer_city, ord.order_id, prd.product_category_name,
	COUNT(prd.product_category_name) OVER (PARTITION BY cus.customer_id, prd.product_category_name ORDER BY ord.order_id) as RollingCount
	FROM EcommercePorto..CustomerData cus
	JOIN EcommercePorto..OrderData ord
		ON cus.customer_id = ord.customer_id
	JOIN EcommercePorto..OrderItemData itm
		ON ord.order_id = itm.order_id
	JOIN EcommercePorto..ProductData prd
		ON itm.product_id = prd.product_id
) AS SubqueryAlias
WHERE customer_city = 'sao paulo' AND RollingCount > 10;

-- Product with Lowest Review Score in Rio de Janeiro

SELECT cus.customer_city, ord.order_id, rev.review_score, prd.product_category_name
FROM EcommercePorto..CustomerData cus
JOIN EcommercePorto..OrderData ord
	ON cus.customer_id = ord.customer_id
JOIN EcommercePorto..OrderReviewData rev
	ON ord.order_id = rev.order_id
JOIN EcommercePorto..OrderItemData itm
	ON ord.order_id = itm.order_id
JOIN EcommercePorto..ProductData prd
	ON itm.product_id = prd.product_id
WHERE customer_city = 'rio de janeiro' AND review_score = '1' AND product_category_name is NOT NULL;


-- The Most Payment Method being Used by Customer

SELECT payment_type,
       COUNT(*) as TotalPaymentCount
FROM EcommercePorto..CustomerData cus
JOIN EcommercePorto..OrderData ord ON cus.customer_id = ord.customer_id
JOIN EcommercePorto..OrderPaymentData pay ON ord.order_id = pay.order_id
GROUP BY payment_type;

-- Summary Order in Each City

SELECT customer_city, COUNT(CAST(order_approved_at as int)) as TotalOrder
FROM EcommercePorto..CustomerData cus
JOIN EcommercePorto..OrderData ord
	ON cus.customer_id =  ord.customer_id
GROUP BY customer_city

-- Create Data Excel for Customer

SELECT cus.customer_id as CustomerID, 
	ord.order_id as OrderID, 
	prd.product_category_name as ProductName,
	itm.order_item_id as Qty,
	itm.price as Price, 
	pay.payment_type as PaymentMethod, 
	rev.review_score as Rating,
	ord.order_approved_at as DateApproved,
	ord.order_delivered_customer_date as DateArrived, 
	geo.geolocation_city as City,
	geo.geolocation_state as State,
	geo.geolocation_lat as Latitude,
	geo.geolocation_lng as Longitude
FROM EcommercePorto..CustomerData cus
JOIN EcommercePorto..GeolocationData geo
	ON cus.customer_zip_code_prefix = geolocation_zip_code_prefix
JOIN EcommercePorto..OrderData ord
	ON cus.customer_id = ord.customer_id
JOIN EcommercePorto..OrderItemData itm
	ON ord.order_id = itm.order_id
JOIN EcommercePorto..OrderPaymentData pay
	ON ord.order_id = pay.order_id
JOIN EcommercePorto..OrderReviewData rev
	ON ord.order_id = rev.order_id
JOIN EcommercePorto..ProductData prd
	ON itm.product_id = prd.product_id
GROUP BY cus.customer_id, ord.order_id, 
	prd.product_category_name, 
	itm.order_item_id,
	itm.price, 
	pay.payment_type, 
	rev.review_score,
	ord.order_approved_at,
	ord.order_delivered_customer_date,
	geo.geolocation_city,
	geo.geolocation_state,
	geo.geolocation_lat,
	geo.geolocation_lng


-- Create Data Excel for Seller

SELECT sel.seller_id as SellerID, 
	   prd.product_id as ProductID, 
	   prd.product_category_name as CategoryName, 
	   prdc.product_category_name_english as EngCategoryName, 
	   itm.price as Price,  
	   sel.seller_city as City, 
	   sel.seller_state as State, 
	   seller_zip_code_prefix as Zipcode
FROM EcommercePorto..SellerData sel
JOIN EcommercePorto..OrderItemData itm
	ON sel.seller_id = itm.seller_id
JOIN EcommercePorto..ProductData prd
	ON itm.product_id = prd.product_id
JOIN EcommercePorto..ProductCategoryData prdc
	ON prd.product_category_name = prdc.product_category_name
GROUP BY sel.seller_id,
		 prd.product_id,
		 prd.product_category_name,
		 prdc.product_category_name_english,
		 itm.price,
		 sel.seller_city,
		 sel.seller_state,
		 seller_zip_code_prefix