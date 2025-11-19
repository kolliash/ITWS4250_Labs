//Part 1: Schema Evolution

//Display original Graph 
MATCH (n)
RETURN n;

// --- Create Hospital Nodes ---
CREATE (:Hospital {name: 'Apollo Hospital', capacity: 500, type: 'Private'});
CREATE (:Hospital {name: 'Government General Hospital', capacity: 1200, type: 'Public'});
CREATE (:Hospital {name: 'Lagos University Teaching Hospital', capacity: 800, type: 'Public'});
CREATE (:Hospital {name: 'Albert Einstein Hospital', capacity: 600, type: 'Private'});

// --- Link Hospitals to Cities (Admin_3) ---
MATCH (c:Admin_3 {name: 'Chennai'}), (h:Hospital {name: 'Apollo Hospital'})
CREATE (h)-[:LOCATED_IN]->(c);

MATCH (c:Admin_3 {name: 'Chennai'}), (h:Hospital {name: 'Government General Hospital'})
CREATE (h)-[:LOCATED_IN]->(c);

MATCH (c:Admin_3 {name: 'Ikeja'}), (h:Hospital {name: 'Lagos University Teaching Hospital'})
CREATE (h)-[:LOCATED_IN]->(c);

MATCH (c:Admin_3 {name: 'São Paulo'}), (h:Hospital {name: 'Albert Einstein Hospital'})
CREATE (h)-[:LOCATED_IN]->(c);

// --- Link Hospitals to Diseases ---
MATCH (h:Hospital {name: 'Government General Hospital'}), (d:Disease {name: 'Dengue'})
CREATE (h)-[:TREATS]->(d);

MATCH (h:Hospital {name: 'Apollo Hospital'}), (d:Disease {name: 'Dengue'})
CREATE (h)-[:TREATS]->(d);

MATCH (h:Hospital {name: 'Lagos University Teaching Hospital'}), (d:Disease {name: 'Malaria'})
CREATE (h)-[:TREATS]->(d);

//Display all nodes and hospitals 
MATCH p = (n)-[r*1..3]-(m)
RETURN p;

//Part 2: Pathfinding

MATCH (start:Admin_1 {name: 'India'}), (end:Disease {name: 'Dengue'})
MATCH p = shortestPath((start)-[*]-(end))
RETURN p

//Part 3: Temporal Analysis
MATCH (city:Admin_3)-[r:HAS_CASES_OF]->(disease:Disease)
WHERE r.date_reported > date('2024-09-01')
RETURN city.name, disease.name, r.date_reported, r.case_count
ORDER BY r.date_reported DESC

//Part 4: Centrality
MATCH (c:Admin_3)
// Count how many relationships go in or out of this city
RETURN c.name, COUNT { (c)--() } AS DegreeCentrality
ORDER BY DegreeCentrality DESC

//Part 5: Data Refactoring
// 1. Update Hospital Capacity
MATCH (h:Hospital {name: 'Government General Hospital'})
SET h.capacity = 1500
RETURN h;

// 2. Add a Label dynamically based on data
MATCH (city:Admin_3)-[r:HAS_CASES_OF]->()
WHERE r.case_count > 400
SET city:HighRiskZone
RETURN city.name, labels(city)

//Part 6: Integrating Socioeconomic Data
// 1. Update Demographics for Chennai (High Density, Developing)
MATCH (c:Admin_3 {name: 'Chennai'})
SET c.population = 11000000,
    c.median_income_usd = 4500,
    c.education_level_pct = 78;

// 2. Update Demographics for São Paulo (Mega City, Middle Income)
MATCH (c:Admin_3 {name: 'São Paulo'})
SET c.population = 12300000,
    c.median_income_usd = 9500,
    c.education_level_pct = 85;

// 3. Update Demographics for Ikeja (Dense, Lower Income)
MATCH (c:Admin_3 {name: 'Ikeja'})
SET c.population = 800000,
    c.median_income_usd = 2500,
    c.education_level_pct = 65;

// 4. Update Demographics for Rio de Janeiro (Tourist Hub, Mixed Income)
MATCH (c:Admin_3 {name: 'Rio de Janeiro'})
SET c.population = 6700000,
    c.median_income_usd = 8200,
    c.education_level_pct = 80;

// 5. Update Demographics for Coimbatore (Smaller, Growing)
MATCH (c:Admin_3 {name: 'Coimbatore'})
SET c.population = 1600000,
    c.median_income_usd = 5000,
    c.education_level_pct = 82;

//Part 7: Socioeconomic Correlation Analysis
MATCH (city:Admin_3)-[r:HAS_CASES_OF]->(disease:Disease) RETURN CASE WHEN city.median_income_usd < 5000 THEN 'Low Income (<$5k)' ELSE 'Middle/High Income (>$5k)' END AS Income_Bracket, SUM(r.case_count) AS Total_Cases, COUNT(city) AS Number_of_Cities_Affected ORDER BY Total_Cases DESC

//Part 8: Integrating Environmental & Weather Data
// Step 1: Create the Weather nodes
// Note the semicolon (;) at the end, which finishes this transaction
CREATE (w1:WeatherObservation { month: 10, year: 2024, avg_rainfall_mm: 300, avg_lst_celsius: 28.5, ndvi: 0.6, humidity_pct: 85, source: 'NASA_GPM_MODIS' })
CREATE (w2:WeatherObservation { month: 10, year: 2024, avg_rainfall_mm: 120, avg_lst_celsius: 22.0, ndvi: 0.4, humidity_pct: 70, source: 'NASA_GPM_MODIS' })
CREATE (w3:WeatherObservation { month: 10, year: 2024, avg_rainfall_mm: 450, avg_lst_celsius: 30.0, ndvi: 0.75, humidity_pct: 90, source: 'NASA_GPM_MODIS' });

// Step 2: Now that nodes exist, MATCH them and link them
MATCH (c:Admin_3 {name: 'Chennai'}), (w1:WeatherObservation {avg_rainfall_mm: 300})
CREATE (c)-[:EXPERIENCED_WEATHER]->(w1);

MATCH (c:Admin_3 {name: 'São Paulo'}), (w2:WeatherObservation {avg_rainfall_mm: 120})
CREATE (c)-[:EXPERIENCED_WEATHER]->(w2);

MATCH (c:Admin_3 {name: 'Rio de Janeiro'}), (w2:WeatherObservation {avg_rainfall_mm: 120})
CREATE (c)-[:EXPERIENCED_WEATHER]->(w2);

MATCH (c:Admin_3 {name: 'Ikeja'}), (w3:WeatherObservation {avg_rainfall_mm: 450})
CREATE (c)-[:EXPERIENCED_WEATHER]->(w3);


//Part 9: The "Perfect Storm for Diseases" Query
MATCH (city:Admin_3)-[:EXPERIENCED_WEATHER]->(weather:WeatherObservation)
MATCH (city)-[outbreak:HAS_CASES_OF]->(disease:Disease)
WHERE weather.avg_rainfall_mm > 200 
  AND weather.humidity_pct > 80
RETURN 
    city.name AS City, 
    disease.name AS Disease, 
    outbreak.case_count AS Cases, 
    weather.avg_rainfall_mm AS Rainfall_MM, 
    weather.humidity_pct AS Humidity
ORDER BY Cases DESC

//Graded Question 1
MATCH (h:Hospital {type: 'Public'})-[:TREATS]->(d:Disease)
RETURN h.name AS Hospital_Name, 
       h.capacity AS Hospital_Capacity, 
       d.name AS Disease_Name;

//Graded Question 2
MATCH (c:Admin_3)
WHERE c.population > 5000000 AND c.median_income_usd < 8000
MATCH (c)-[r:HAS_CASES_OF]->(d:Disease {name: 'Dengue'})
RETURN c.name AS City_Name, 
       SUM(r.case_count) AS Total_Dengue_Cases;


