SELECT TOP(10)* FROM main_data
--loss = discounts + returns --
--gross sales = net sales + loss --

ALTER TABLE main_data ADD Returns_Ratio FLOAT;
UPDATE main_data SET Returns_Ratio = (Returns / Gross_Sales)*-100

CREATE VIEW by_product AS
SELECT Product_Type as product_type , sum(Gross_Sales) as gross_sales , sum(Total_Net_Sales) as total_net_sales, sum(Discounts) as discounts , sum(Returns) as returns , sum(Returns_Ratio) as returns_ratio 
FROM main_data GROUP BY  Product_Type 

DROP VIEW by_product 

SELECT product_type , gross_sales FROM by_product ORDER BY Gross_Sales DESC
--basket , art & sculptuer and jewelry are the highest in (sales top 3 products sales)
--gift baskets and easter are the lowest (may omit the product)


SELECT product_type , (returns/gross_sales)*-100 as returns_percent
FROM by_product order by returns_percent desc
--music and textiles have the hifgest returns ratio , this may be due a product defect
--basket and art & sculptuer are not high as music and textiles , we also should consider the high gross sales for them 


SELECT product_type , (discounts/gross_sales)*-100 as discounts_percent
FROM by_product order by discounts_percent desc
-- One-of-a-Kind , Textiles, Furniture and Easter are the highest products making loss because of discounts 


with loss_comparison 
as (
SELECT product_type , (returns/gross_sales)*-100 as returns_percent ,(discounts/gross_sales)*-100 as discounts_percent , 
case
when (returns/gross_sales)*-100 > (discounts/gross_sales)*-100 then 'returns problem'
when (discounts/gross_sales)*-100 > (returns/gross_sales)*-100 then 'discounts problem'
else 'no loss'
end as loss_dependency
FROM by_product 
) 
select  loss_dependency , count(loss_dependency) as num from loss_comparison group by loss_dependency
-- discounts problem is nearly 7 times returns problems 
--this may mean that the store sells on discounts 


with loss_comparison 
as (
SELECT product_type , (returns/gross_sales)*-100 as returns_percent ,(discounts/gross_sales)*-100 as discounts_percent , 
case
when (returns/gross_sales)*-100 > (discounts/gross_sales)*-100 then 'returns problem'
when (discounts/gross_sales)*-100 > (returns/gross_sales)*-100 then 'discounts problem'
else 'no loss'
end as loss_dependency
FROM by_product 
) 
select product_type , loss_dependency from loss_comparison where loss_dependency like 'no loss'
-- only gift baskets have no loss at all , however by going back to the gross sales we can see that it is a trival product that we may even omit  

select Product_Type , (sum(Loss / Total_Net_Sales)*-100 )/100 as loss_to_net 
from main_data group by Product_Type 
order by loss_to_net desc
-- basket has a huge lose to net sales 
--Kitchen , Jewelry, Home Decor ,and Art & Sculpture have rational proportion but still high
--others are okay 

select top(5) * from monthly_report

alter table monthly_report drop column loss ; 
alter table monthly_report add Loss float ;
update monthly_report set Loss = Returns + Discounts ;

select top(5) * from monthly_report

--gross sales = net sales + loss--

select Total_Sales - Net_Sales , Shipping from monthly_report
--total sales = net sales + shipping (takes shipping profit or not )--
--shipping may cause them a profit--

select  Year , sum(Net_Sales) as sum_net_sales , sum(Loss) as sum_loss from monthly_report group by Year
--net sales increase through years , however the loss also increase -
--this affects profitability directly
