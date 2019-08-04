SET SQL_SAFE_UPDATES = 0;

-- To have a view of all the tables after importing the files with required columns(Date, Close Price) using 'Table Data Import Wizard'
-- (a) Bajaj
select *
from `bajaj auto`
limit 5;

-- (b) Eicher Motors
select *  
from `eicher motors`
limit 5;

-- (c) Hero Motocrop
select * 
from `hero motocorp`
limit 5;

-- (d) Infosys
select * 
from `infosys`
limit 5;

-- (e) TCS
select * 
from `tcs`
limit 5;

-- (f) TVS Motors
select * 
from `tvs motors`
limit 5;

-- 1. Creating new tables as required in part 1 and converting all dates into date type
-- (a) Bajaj
create table bajaj1
select str_to_date(`Date` ,'%d-%M-%Y') as 'Date',`Close Price`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 19 preceding and current row) as `20 Day MA`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 49 preceding and current row) as `50 Day MA`
from `bajaj auto`
order by `Date` asc ;
alter table bajaj1
  modify `20 Day MA` float(10,2);
alter table bajaj1
  modify `50 Day MA` float(10,2);
-- Deleting top 49 since they contain null values which will disturb our analysis
delete from bajaj1
order by `Date`
limit 49;
select *
from bajaj1;

-- (b) Eicher Motors
create table eicher1
select str_to_date(`Date` ,'%d-%M-%Y') as 'Date',`Close Price`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 19 preceding and current row) as `20 Day MA`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 49 preceding and current row) as `50 Day MA`
from `eicher motors`
order by `Date` asc ;
alter table eicher1
  modify `20 Day MA` float(10,2);
alter table eicher1
  modify `50 Day MA` float(10,2);
-- Deleting top 49 since they contain null values which will disturb our analysis
delete from eicher1
order by `Date`
limit 49;
select *
from eicher1;

-- (c) Hero Motocrop
create table hero1
select str_to_date(`Date` ,'%d-%M-%Y') as 'Date',`Close Price`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 19 preceding and current row) as `20 Day MA`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 49 preceding and current row) as `50 Day MA`
from `hero motocorp`
order by `Date` asc ;
alter table hero1
  modify `20 Day MA` float(10,2);
alter table hero1
  modify `50 Day MA` float(10,2);
-- Deleting top 49 since they contain null values which will disturb our analysis
delete from hero1
order by `Date`
limit 49;
select *
from hero1;

-- (d) Infosys
create table infosys1
select str_to_date(`Date` ,'%d-%M-%Y') as 'Date',`Close Price`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 19 preceding and current row) as `20 Day MA`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 49 preceding and current row) as `50 Day MA`
from infosys
order by `Date` asc ;
alter table infosys1
  modify `20 Day MA` float(10,2);
alter table infosys1
  modify `50 Day MA` float(10,2);
-- Deleting top 49 since they contain null values which will disturb our analysis
delete from infosys1
order by `Date`
limit 49;
select *
from infosys1;

-- (e) TCS
create table tcs1
select str_to_date(`Date` ,'%d-%M-%Y') as 'Date',`Close Price`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 19 preceding and current row) as `20 Day MA`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 49 preceding and current row) as `50 Day MA`
from tcs
order by `Date` asc ;
alter table tcs1
  modify `20 Day MA` float(10,2);
alter table tcs1
  modify `50 Day MA` float(10,2);
-- Deleting top 49 since they contain null values which will disturb our analysis
delete from tcs1
order by `Date`
limit 49;
select *
from tcs1;

-- (f) TVS Motors
create table tvs1
select str_to_date(`Date` ,'%d-%M-%Y') as 'Date',`Close Price`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 19 preceding and current row) as `20 Day MA`,
	   avg(`Close Price`) over ( order by 'Date' asc rows between 49 preceding and current row) as `50 Day MA`
from `tvs motors`
order by `Date` asc ;
alter table tvs1
  modify `20 Day MA` float(10,2);
alter table tvs1
  modify `50 Day MA` float(10,2);
-- Deleting top 49 since they contain null values which will disturb our analysis
delete from tvs1
order by `Date`
limit 49;
select * 
from tvs1;

-- 2. Creating a master table as required in part 2
create table master_table as
select  str_to_date(b.`Date` ,'%d-%M-%Y') as 'Date', b.`Close Price` as 'Bajaj', 
		tc.`Close Price` as 'TCS',
        ts.`Close Price` as 'TVS',
        inf.`Close Price` as 'Infosys',
        ei.`Close Price` as 'Eicher',
        he.`Close Price` as 'Hero'
from `bajaj auto` b 
	inner join tcs tc
		on b.`Date`= tc.`Date`
	inner join `tvs motors` ts
		on tc.`Date`= ts.`Date`
	inner join infosys inf
		on ts.`Date`= inf.`Date` 
	inner join `eicher motors` ei
		on inf.`Date`= ei.`Date`
	inner join `hero motocorp` he
		on ei.`Date`= he.`Date`
order by `Date`;
select *
from master_table
limit 10;

-- 3. Creation of bajaj2 (and other stocks as well)
-- Principle used :
--  (a) Curent row 20 day > 50 day  and previous row  20 day < 50 day -----> Buy 
--  (b) Curent row 20 day < 50 day  and previous row  20 day > 50 day -----> Sell
--  (c) Otherwise Hold
-- (a) Bajaj
-- Function to get true and false in numeric value
delimiter $$
create function t_f_signal(`20 Day MA` float(10,2), `50 Day MA` float(10,2))
	returns int deterministic
begin
	declare t_f_signal int;
		if `20 Day MA` > `50 Day MA` then
			set t_f_signal = 1;
		elseif `20 Day MA` < `50 Day MA` then
			set t_f_signal = 0;
		end if;
return t_f_signal;
end $$
delimiter ;
-- Creating a table with the above function
create table bajaj2a
select `Date`, `Close Price`,t_f_signal(`20 Day MA`,`50 Day MA`) as `Signal_1`
from bajaj1
order by `Date` asc;
select * 
from bajaj2a;
-- Creating a table containing the previous day's Signal
create table bajaj2b
select `Date`, lag(`Signal_1`) over (order by `Date`) as Signal_pervious_day 
from bajaj2a ;
select * 
from bajaj2b;
-- Combining the two tables (bajaj2a and bajaj2b)
create table bajaj2 as
select b1.`Date`, b1.`Close Price`,b1.`Signal_1`,b2.`Signal_pervious_day`
from bajaj2a b1 inner join bajaj2b b2
on b1.`Date` = b2.`Date`;
select * 
from bajaj2;
-- Creating a function to Give the signal 'Sell', 'Buy' or 'Hold'
delimiter $$
create function final_signal(`Signal` int , `Signal_pervious_day` bool)
	returns varchar(50) deterministic
begin
	declare final_signal varchar(50);
		if `Signal` < `Signal_pervious_day` then
			set final_signal = 'Sell';
		elseif `Signal` > `Signal_pervious_day` then
			set final_signal = 'Buy';
		else set final_signal = 'Hold';
		end if;
return final_signal;
end $$
delimiter ;
-- Creating a new table bajaj2
alter table bajaj2
add `Signal` varchar(50);
-- Putting values into 'Signal'
update bajaj2
set `Signal` = (select final_signal(`Signal_1` , `Signal_pervious_day`));
-- Removing the unwanted columns from bajaj2
alter table bajaj2
drop Signal_1 ;
alter table bajaj2
drop Signal_pervious_day;
-- Removing the unwanted tables
drop table bajaj2b;
drop table bajaj2a;
-- Table bajaj2 giving the right signal
select *
from bajaj2;

-- Repeating for other tables as well
-- (b) Eicher Motors
-- Creating a table with the function
create table eicher2a
select `Date`, `Close Price`,t_f_signal(`20 Day MA`,`50 Day MA`) as `Signal_1`
from eicher1
order by `Date` asc;
select * 
from eicher2a;
-- Creating a table containing the previous day's Signal
create table eicher2b
select `Date`, lag(`Signal_1`) over (order by `Date`) as Signal_pervious_day 
from eicher2a ;
select * 
from eicher2b;
-- Combining the two tables (eicher2a and eicher2b)
create table eicher2 as
select e1.`Date`, e1.`Close Price`,e1.`Signal_1`,e2.`Signal_pervious_day`
from eicher2a e1 inner join eicher2b e2
on e1.`Date` = e2.`Date`;
select * 
from eicher2;
-- Creating a new table eicher2
alter table eicher2
add `Signal` varchar(50) ;
-- Putting values into 'Signal'
update eicher2
set `Signal` = (select final_signal(`Signal_1` , `Signal_pervious_day`));
-- Removing the unwanted columns from eicher2
alter table eicher2
drop Signal_1 ;
alter table eicher2
drop Signal_pervious_day;
-- Removing the unwanted tables
drop table eicher2b;
drop table eicher2a;
-- Table eicher2 giving the right signal
select *
from eicher2;

-- (c) Hero Motocrop
-- Creating a table with the function
create table hero2a
select `Date`, `Close Price`,t_f_signal(`20 Day MA`,`50 Day MA`) as `Signal_1`
from hero1
order by `Date` asc;
select * 
from hero2a;
-- Creating a table containing the previous day's Signal
create table hero2b
select `Date`, lag(`Signal_1`) over (order by `Date`) as Signal_pervious_day 
from hero2a ;
select * 
from hero2b;
-- Combining the two tables (hero2a and hero2b)
create table hero2 as
select h1.`Date`, h1.`Close Price`,h1.`Signal_1`,h2.`Signal_pervious_day`
from hero2a h1 inner join hero2b h2
on h1.`Date` = h2.`Date`;
select * 
from hero2;
-- Creating a new table hero2
alter table hero2
add `Signal` varchar(50);
-- Putting values into 'Signal'
update hero2
set `Signal` = (select final_signal(`Signal_1` , `Signal_pervious_day`));
-- Removing the unwanted columns from hero2
alter table hero2
drop Signal_1 ;
alter table hero2
drop Signal_pervious_day;
-- Removing the unwanted tables
drop table hero2b;
drop table hero2a;
-- Table hero2 giving the right signal
select *
from hero2;

-- (d) Infosys
-- Creating a table with the function
create table infosys2a
select `Date`, `Close Price`,t_f_signal(`20 Day MA`,`50 Day MA`) as `Signal_1`
from infosys1
order by `Date` asc;
select * 
from infosys2a;
-- Creating a table containing the previous day's Signal
create table infosys2b
select `Date`, lag(`Signal_1`) over (order by `Date`) as Signal_pervious_day 
from infosys2a ;
select * 
from infosys2b;
-- Combining the two tables (infosys2a and infosys2b)
create table infosys2 as
select i1.`Date`, i1.`Close Price`,i1.`Signal_1`,i2.`Signal_pervious_day`
from infosys2a i1 inner join infosys2b i2
on i1.`Date` = i2.`Date`;
select * 
from infosys2;
-- Creating a new table infosys2
alter table infosys2
add `Signal` varchar(50);
-- Putting values into 'Signal'
update infosys2
set `Signal` = (select final_signal(`Signal_1` , `Signal_pervious_day`));
-- Removing the unwanted columns from infosys2
alter table infosys2
drop Signal_1 ;
alter table infosys2
drop Signal_pervious_day;
-- Removing the unwanted tables
drop table infosys2b;
drop table infosys2a;
-- Table infosys2 giving the right signal
select *
from infosys2;

-- (e) TCS
-- Creating a table with the function
create table tcs2a
select `Date`, `Close Price`,t_f_signal(`20 Day MA`,`50 Day MA`) as `Signal_1`
from tcs1
order by `Date` asc;
select * 
from tcs2a;
-- Creating a table containing the previous day's Signal
create table tcs2b
select `Date`, lag(`Signal_1`) over (order by `Date`) as Signal_pervious_day 
from tcs2a ;
select * 
from tcs2b;
-- Combining the two tables (tcs2a and tcs2b)
create table tcs2 as
select t1.`Date`, t1.`Close Price`,t1.`Signal_1`,t2.`Signal_pervious_day`
from tcs2a t1 inner join tcs2b t2
on t1.`Date` = t2.`Date`;
select * 
from tcs2;
-- Creating a new table tcs2
alter table tcs2
add `Signal` varchar(50);
-- Putting values into 'Signal'
update tcs2
set `Signal` = (select final_signal(`Signal_1` , `Signal_pervious_day`));
-- Removing the unwanted columns from tcs2
alter table tcs2
drop Signal_1 ;
alter table tcs2
drop Signal_pervious_day;
-- Removing the unwanted tables
drop table tcs2b;
drop table tcs2a;
-- Table tcs2 giving the right signal
select *
from tcs2;

-- (f) TVS Motors
-- Creating a table with the function
create table tvs2a
select `Date`, `Close Price`,t_f_signal(`20 Day MA`,`50 Day MA`) as `Signal_1`
from tvs1
order by `Date` asc;
select * 
from tvs2a;
-- Creating a table containing the previous day's Signal
create table tvs2b
select `Date`, lag(`Signal_1`) over (order by `Date`) as Signal_pervious_day 
from tvs2a ;
select * 
from tvs2b;
-- Combining the two tables (tvs2a and tvs2b)
create table tvs2 as
select t1.`Date`, t1.`Close Price`,t1.`Signal_1`,t2.`Signal_pervious_day`
from tvs2a t1 inner join tvs2b t2
on t1.`Date` = t2.`Date`;
select * 
from tvs2;
-- Creating a new table tvs2
alter table tvs2
add `Signal` varchar(50);
-- Putting values into 'Signal'
update tvs2
set `Signal` = (select final_signal(`Signal_1` , `Signal_pervious_day`));
-- Removing the unwanted columns from tvs2
alter table tvs2
drop Signal_1 ;
alter table tvs2
drop Signal_pervious_day;
-- Removing the unwanted tables
drop table tvs2b;
drop table tvs2a;
-- Table tvs2 giving the right signal
select *
from tvs2;

-- 4. UDF (Input: Date, Output: Signal) as required in part 4 (Only for Bajaj Auto)
delimiter $$
create function date_signal(in_date date)
	returns varchar(10) deterministic
begin
	declare result_signal varchar(10);
	set result_signal= (select `Signal`
						from bajaj2 
						where `Date` = in_date);
    return result_signal;
end $$
delimiter ;

-- Using the above UDF to know whether to buy, sell or hold in a particular day (Only for Bajaj Auto)
select date_signal('2015-04-07') as `Signal`;
select date_signal('2015-06-18') as `Signal`;
select date_signal('2015-08-11') as `Signal`;