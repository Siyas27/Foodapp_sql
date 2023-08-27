create database foodorder;

drop table if exists goldusers_signup;

create table goldusers_signup ( userid integer, gold_signup_date date );
INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-12-09'),
(3, '2017-06-04' );


CREATE TABLE users(userid integer,signup_date date); 
INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-09-02'),
(2,'2015-01-15'),
(3,'2014-04-11');

CREATE TABLE sales(userid integer,created_date date,product_id integer); 
INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-11-08',2),
(2,'2018-09-10',3);

CREATE TABLE product(product_id integer,product_name text,price integer); 
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

 /* 1. What is the total amount each customer spent on food app ?	*/
 
select s.userid, sum(p.price) total_amount_spent from sales s JOIN product p ON s.product_id = p.product_id
group by s.userid;


/* 2. How many days each customer has visited food app */ 


select userid, count( distinct created_date) DISTINCT_DAYS from sales
group by userid;

/* 3. What was the first product purchased by each customer */

with cte as ( select *, rank () over ( partition by userid order by created_date asc ) as rnk from sales )

select product_id , userid from cte
where rnk =1 ;

/*  4. what is the most purchased item on menu & how many times it was purchased by all customers ? */

select userid,count(product_id) cntt from sales where product_id =
 (select product_id from sales
group by product_id 
order by count(product_id) desc
limit 1)
group by userid;

/* 5. which item was the most popular for each customer */

select * from
(select *, rank() over ( partition by userid order by cn desc) rnk from 
(select userid, product_id, count(product_id) cn from sales  group by userid, product_id ) a ) b
where rnk =1 ;

/* 6. Which iteam was purchased by customer first after they became member */

with t1 as (select s.userid, s.created_date, s.product_id from sales s jOIN 
goldusers_signup g
ON s.userid = g.userid and s.created_date >= gold_signup_date)

select * from (
select t1.*, rank() over(partition by userid order by created_date) as r from t1 ) a

where r = 1 ;

/* 7. which item customer bought just before he became a member   */

with t11 as (select s.userid, s.created_date, s.product_id from sales s jOIN 
goldusers_signup g
ON s.userid = g.userid and s.created_date <= gold_signup_date)

select * from
  ( select t11.*, rank() over(partition by userid order by created_date desc ) as rn from t11 ) ab
  
  where rn =1;
  
  /* 8 what is the total no. of orders & amount spent by each customer before the became goldmember */
  
  
  with cte as (select c.*, d.price from 
  ( select s.userid, s.created_date, s.product_id from sales s jOIN 
goldusers_signup g
ON s.userid = g.userid and s.created_date <= gold_signup_date ) c join product d on c.product_id = d.product_id)

select userid, count(created_date), sum(price) from cte
group by userid;

/*9 if buying each prduct generates points, p1- 5rs =1 pt, p2 - 10rs = 5pt & p3 - 5rs = 1pt.
calculate points collected by each customer  */

select userid, sum(totalpt) from
(select e.*, amt/points as totalpt from
(select d.*, case when product_id = 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 end as points from
(select userid, product_id, sum(price) amt from (select a.*, b.price from sales a
JOIN PRODUCT b
ON
a.product_id = b.product_id)c
group by userid, product_id)d)e)f 
group by userid ;


/* 10 in the first one year after a customer joins the gold program (including their join date ) irrespective of what the customer has purchased they earn 5 points for every 10rs purchased, who earned more & what is their point earnings in their first year.
1PT = 2RS
0.5pt = 1rs
*/
select c.* , d.price*0.5 points_earned from
(select s.userid, s.created_date, s.product_id from sales s jOIN 
goldusers_signup g
ON s.userid = g.userid and s.created_date >= gold_signup_date and s.created_date <= date_add(gold_signup_date,interval 1 YEAR) )C
inner join product d on c.product_id = d.product_id ;







  
  

















