-- use database raj
use raj;

-- show the dataset
select * from uber_ride;

-- data types
show columns from uber_ride;

-- 1. Overall Cancellation Rate
-- Calculate the percentage of rides cancelled on the platform
select round(sum(cancel_rides) * 100/count(*),0) from uber_ride;

-- 2. Cancellation Rate by Hour
-- Identify which hours of the day have the highest cancellation probability
select hour, count(*) as total_rides, sum(cancel_rides) as cancelled,
round(sum(cancel_rides) * 100/count(*),2) as cancel_rate
from uber_ride
group by hour
order by round(sum(cancel_rides) * 100/count(*),2) desc;

-- 3. Cancellation Rate by Vehicle Type
-- Check if certain vehicle types have higher cancellation rates
select `vehicle type`, sum(cancel_rides) as cancelled,
count(*) as total_rides,
round(sum(cancel_rides) * 100/count(*),2) as cancel_rate
from uber_ride
group by `vehicle type`
order by round(sum(cancel_rides) * 100/count(*),2) desc;

-- 4. High-Risk Pickup Locations by Hour (Rate Analysis)
-- Identify pickup location-hour combinations with the highest cancellation probability
-- Only segments with more than 50 rides are considered to ensure statistical reliability
select `pickup location`, hour as hours, sum(cancel_rides) as cancelled,
count(*) as total_rides,
round(sum(cancel_rides) * 100/count(*),2) as cancel_rate
from uber_ride
group by `pickup location`, hours
having count(*) > 50
order by round(sum(cancel_rides) * 100/count(*),2) desc;

-- 5. High-Risk Drop Locations by Hour (Rate Analysis)
-- Identify destination locations and hours with the highest cancellation rates
-- Only segments with sufficient ride volume (>50 rides) are included
select `drop location`, hour as hours, sum(cancel_rides) as cancelled,
count(*) as total_rides,
round(sum(cancel_rides) * 100/count(*),2) as cancel_rate
from uber_ride
group by `drop location`, hours
having count(*) > 50
order by round(sum(cancel_rides) * 100/count(*),2) desc;

-- 6. Cancellation Volume by Drop Location and Hour
-- Identify where the highest number of ride cancellations occur by destination and time
-- This helps identify operational hotspots in terms of absolute cancellation count
select `drop location`, hour as hours,
count(*) as total_rides from uber_ride
where cancel_rides = 1
group by `drop location`, hour
order by count(*) desc;

-- 7. Cancellation Volume by Pickup Location and Hour
-- Identify pickup locations and times with the highest number of cancellations
-- Useful for detecting supply-demand imbalance zones
select `pickup location`, hour as hours,
count(*) as total_rides from uber_ride
where cancel_rides = 1
group by `pickup location`, hour
order by count(*) desc;

-- 8. Customer Cancellation Reasons
-- Analyze the most common reasons provided by customers for cancelling rides
-- Window function used to rank reasons by frequency
select `reason for cancelling by customer`, count(`reason for cancelling by customer`) as count_reasons,
dense_rank() over(order by count(`reason for cancelling by customer`) desc) as rn
from uber_ride
where `reason for cancelling by customer` is not null and cancel_rides = 1
group by `reason for cancelling by customer`;

-- 9. Cancellation Rate by Time Slot
-- Evaluate whether certain time periods (morning, afternoon, evening, night)
-- experience higher cancellation rates
select time_slot,
count(*) as total_rides,
sum(cancel_rides) as cancelled,
round(sum(cancel_rides)*100/count(*),2) as cancel_rate
from uber_ride
group by time_slot
order by cancel_rate desc;

-- 10. Monthly Demand Analysis
-- Identify high-demand location-hour combinations for each month
-- Useful for understanding seasonal ride demand patterns
select Month_Year, `pickup location`, hour, count(*)
from uber_ride
group by Month_Year, `pickup location`, hour
order by count(*) desc;

-- 11. Pickup Location Risk Score
-- Combine cancellation rate and ride volume to identify the
-- most operationally problematic pickup locations
select `pickup location`, hour as hours, sum(cancel_rides) as cancelled,
count(*) as total_rides,
round(sum(cancel_rides) * 100/count(*),2) as cancel_rate,
round(sum(cancel_rides) * 100/count(*) * log(count(*)),2) as risk_score # log is to scale the data so that variable with large numbers does not dominate the small variable
from uber_ride
group by `pickup location`, hour
order by risk_score desc;

