CREATE DATABASE tata_power_project;
USE tata_power_project;

# 1. Which cities have the highest EV growth  ?
SELECT 
    State,
    City,
    COUNT(Vehicle_ID) AS Total_EV_Registrations
FROM ev_vehicle_registrations_c
GROUP BY State, City
ORDER BY Total_EV_Registrations DESC
LIMIT 10;

# 2. Which cities have lowest charger coverage ?
SELECT 
    ev.State,
    ev.City,
    COUNT(ev.Vehicle_ID) AS Total_EVs,
    COUNT(DISTINCT cs.Station_ID) AS Total_Charging_Stations,    
    ROUND(
        COUNT(ev.Vehicle_ID) / 
        NULLIF(COUNT(DISTINCT cs.Station_ID), 0),2) AS EVs_Per_Station
FROM ev_vehicle_registrations_c ev
LEFT JOIN charging_stations_c cs
    ON ev.City = cs.City
    AND ev.State = cs.State
GROUP BY ev.State, ev.City
ORDER BY EVs_Per_Station DESC
LIMIT 10;

# 3. Which existing stations are overloaded (>80% utilization)?
SELECT 
    Station_ID,
    State,
    City,
    Charger_Type,
    Daily_Utilization_Pct,
    Number_of_Ports
FROM charging_stations_c
WHERE Daily_Utilization_Pct > 80
ORDER BY Daily_Utilization_Pct DESC;

# 4. Which highway corridors have dangerous charging gaps (>150 KM)?
SELECT 
    Corridor_ID,
    Highway_Name,
    Start_City,
    End_City,
    Total_Distance_KM,
    Existing_Charging_Stations,
    Avg_Distance_Between_Stations_KM,
    Coverage_Status
FROM mobility_corridors_c
WHERE Avg_Distance_Between_Stations_KM > 150
ORDER BY Avg_Distance_Between_Stations_KM DESC;

# 5. Which expansion candidate locations offer the highest ROI?
SELECT 
    Location_ID,
    State,
    City,
    Estimated_EV_Density,
    ROI_Percentage,
    Priority_Score
FROM expansion_candidates_c
ORDER BY ROI_Percentage DESC,
         Priority_Score DESC
LIMIT 10;

# 6. What is the revenue difference between DC Fast Chargers and AC Level 2?
SELECT 
    cs.Charger_Type,    
    ROUND(AVG(sess.Revenue_INR),2) AS Avg_Revenue_Per_Session,    
    ROUND(SUM(sess.Revenue_INR),2) AS Total_Revenue,    
    COUNT(sess.Session_ID) AS Total_Sessions
FROM charging_sessions_c sess
JOIN charging_stations_c cs
    ON sess.Station_ID = cs.Station_ID
GROUP BY cs.Charger_Type
ORDER BY Total_Revenue DESC;

# 7. When are peak charging hours and how much revenue premium do they generate?
SELECT 
    Peak_Hour_Flag,
    COUNT(Session_ID) AS Total_Sessions,    
    ROUND(AVG(Revenue_INR),2) AS Avg_Revenue,    
    ROUND(SUM(Revenue_INR),2) AS Total_Revenue
FROM charging_sessions_c
GROUP BY Peak_Hour_Flag;

# 8. Where are charging stations overloaded?
SELECT 
    State,
    City,    
    COUNT(Station_ID) AS Total_Stations,
    ROUND(AVG(Daily_Utilization_Pct),2) AS Avg_Utilization
FROM charging_stations_c
GROUP BY State, City
HAVING AVG(Daily_Utilization_Pct) > 80
ORDER BY Avg_Utilization DESC;

# 9. Which cities need new stations most urgently?
SELECT 
    ev.State,
    ev.City,
    COUNT(ev.Vehicle_ID) AS Total_EVs,    
    COUNT(DISTINCT cs.Station_ID) AS Existing_Stations,    
    ROUND(
        COUNT(ev.Vehicle_ID) /
        NULLIF(COUNT(DISTINCT cs.Station_ID),0), 2) AS EVs_Per_Station
FROM ev_vehicle_registrations_c ev
LEFT JOIN charging_stations_c cs
    ON ev.City = cs.City
    AND ev.State = cs.State
GROUP BY ev.State, ev.City
ORDER BY EVs_Per_Station DESC
LIMIT 15;

# 10. Which highway corridors have dangerous gaps?
select 
	Corridor_ID, 
	Highway_Name,
	Start_City,
	End_City
from mobility_corridors_c
where Coverage_Status = "Critical Gap";

# 11. Which expansion locations give best ROI?
SELECT 
    City,
    State,
    ROI_Percentage,
    Expected_Annual_Rev_INR,
    Total_Investment_INR,
    Priority_Score
FROM expansion_candidates_c
WHERE ROI_Percentage > 20
ORDER BY ROI_Percentage DESC,
         Priority_Score DESC;

# 12. What charger type should be prioritized?         
SELECT 
    cs.Charger_Type,
    COUNT(sess.Session_ID) AS Total_Sessions,
    ROUND(AVG(sess.Revenue_INR),2) AS Avg_Revenue,    
    ROUND(AVG(cs.Daily_Utilization_Pct),2) AS Avg_Utilization,    
    ROUND(SUM(sess.Revenue_INR),2) AS Total_Revenue
FROM charging_stations_c cs
JOIN charging_sessions_c sess
    ON cs.Station_ID = sess.Station_ID
GROUP BY cs.Charger_Type
ORDER BY Avg_Utilization DESC,
         Total_Revenue DESC;