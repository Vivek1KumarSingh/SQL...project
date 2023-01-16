select *from project_sql.data1;

select *from project_sql.data2;

-- 1. Number of rows in our dataset
select count(*) from project_sql.data1;
select count(*) from project_sql.data2;


-- 2. Dataset for Jharkhand and Bihar
select * from project_sql.data1 where State in ('Jharkhand','Bihar')


-- 3. Population of India
select sum(Population) Total_population from project_sql.data2;


-- 4. Average growth of India
select avg(growth)*100 Avg_growth from project_sql.data1;


-- 5. Average growth of India by state
select state, avg(growth)*100 Avg_growth from project_sql.data1
group by state
order by Avg_growth desc;


-- 6. Average sex ratio
select avg(Sex_Ratio) Avg_Sex_Ratio from project_sql.data1;

select state, round(avg(Sex_Ratio),0) Avg_Sex_Ratio from project_sql.data1
group by state order by Avg_Sex_Ratio desc;


-- 7. Average literacy rate

select state, avg(Literacy) Avg_Literacy_rate from project_sql.data1 group by state having avg(Literacy)>90 order by Avg_Literacy_rate desc
 ;
 
 
 -- Top 3 state showing highest growth ratio
select state, avg(growth)*100 Avg_growth from project_sql.data1
group by state 
order by Avg_growth desc limit 3;


-- Buttom 3 states showing lowest sex ratio
select state, round(avg(Sex_Ratio),0) Avg_Sex_Ratio from project_sql.data1
group by state
order by Avg_Sex_Ratio limit 3;


-- top and buttom 3 states in terms of literacy rate
select state, avg(literacy) Avg_literacy_rate from project_sql.data1 
group by state order by Avg_literacy_rate;

drop table if exists topstates;
create table topstates (
state nvarchar(255),
literacy_rate float
);

insert into topstates
select state, avg(literacy) Avg_literacy_rate from project_sql.data1 
group by state order by Avg_literacy_rate desc;

select *from topstates
limit 3;

drop table if exists buttomstates;
create table buttomstates (
state nvarchar(255),
literacy_rate float
);

insert into buttomstates
select state, avg(literacy) Avg_literacy_rate from project_sql.data1 
group by state order by Avg_literacy_rate;

select *from buttomstates
limit 3;

-- union operator
select * from
(select *from topstates limit 3)a
union
select *from
(select *from buttomstates limit 3)b;

-- states starting with letter a or b
select distinct state from project_sql.data1
where upper(state) like 'A%' or upper(state) like 'B%';


-- states name starting with a and ending with d
select distinct state from project_sql.data1
where upper(state) like 'A%D' ;

select distinct state from project_sql.data1
where upper(state) like 'A%M' ;


-- Calculate the no of males and females in each state
select d.state,round(sum(No_Females),0) Female_Population,round(sum(No_Males),0) Male_Population from
(select c.state, (c.Sex_Ratio*c.Population)/(c.Sex_Ratio+1000) No_Females, (c.Population*1000)/(c.Sex_Ratio+1000) No_Males from
(select a.state, a.Sex_Ratio, b.Population from data1 a inner join data2 b on a.District=b.District)c)d
group by state;


-- total literate person by each state

select c.state, round(sum(c.Literacy*0.01*c.Population),0) No_Literate_Person, round(sum((100-c.Literacy)*0.01*c.Population),0) No_illiterate_Person from
(select a.state, a.Literacy, b.Population from project_sql.data1 a inner join project_sql.data2 b on a.District=b.District)c
group by state;


--- Population of states in previous census

select d.State, round(sum(d.Previous_census_Population),0) last_census_population, round(sum(d.Current_census),0) Current_census from
(select c.District, c.State, c.Population/(1+c.Growth) Previous_census_Population, c.Population Current_census from
(select a.District, a.State, a.Population, b.Growth from project_sql.data2 a inner join project_sql.data1 b on a.District=b.District)c)d
group by state;


-- Population Vs Area

select g.Total_area/last_census_population last_population_density, g.Total_area/Current_census current_population_density from (
select k.*,l.Total_area from
(select '1' as keyy,n.* from
(select sum(m.last_census_population) last_census_population, sum(m.Current_census) Current_census from (
select d.State, round(sum(d.Previous_census_Population),0) last_census_population, round(sum(d.Current_census),0) Current_census from
(select c.District, c.State, c.Population/(1+c.Growth) Previous_census_Population, c.Population Current_census from
(select a.District, a.State, a.Population, b.Growth from project_sql.data2 a inner join project_sql.data1 b on a.District=b.District)c)d
group by state)m)n)k inner join 
(select '1' as keyy,sum(Area_km2) Total_area from data2) l on k.keyy=l.keyy)g;


-- display top 3 districts from each state of highest literacy rate using window function
select a.* from
(select District, State, Literacy, rank() over (partition by state order by Literacy desc) rnk from project_sql.data1)a
where rnk<=3 order by state;
