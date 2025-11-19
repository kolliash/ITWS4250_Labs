
// STEP 1 — Create Disease Nodes
CREATE (:Disease {name: 'Malaria', pathogen: 'Plasmodium', vector: 'Anopheles Mosquito'});
CREATE (:Disease {name: 'Dengue', pathogen: 'Dengue Virus', vector: 'Aedes Mosquito'});
CREATE (:Disease {name: 'Chikungunya', pathogen: 'Chikungunya Virus', vector: 'Aedes Mosquito'});

// STEP 2 — Create Countries
MERGE (india:Admin_1 {name: 'India'});
MERGE (brazil:Admin_1 {name: 'Brazil'});
MERGE (nigeria:Admin_1 {name: 'Nigeria'});

// STEP 2b — Create States + Link to Countries
MERGE (tamil:Admin_2 {name: 'Tamil Nadu'})-[:IS_PART_OF]->(india);
MERGE (sp_state:Admin_2 {name: 'São Paulo'})-[:IS_PART_OF]->(brazil);
MERGE (rio_state:Admin_2 {name: 'Rio de Janeiro'})-[:IS_PART_OF]->(brazil);
MERGE (lagos:Admin_2 {name: 'Lagos'})-[:IS_PART_OF]->(nigeria);

// STEP 2c — Create Cities + Link to States
MERGE (chennai:Admin_3 {name: 'Chennai'})-[:IS_PART_OF]->(tamil);
MERGE (coimbatore:Admin_3 {name: 'Coimbatore'})-[:IS_PART_OF]->(tamil);
MERGE (sp_city:Admin_3 {name: 'São Paulo'})-[:IS_PART_OF]->(sp_state);
MERGE (rio_city:Admin_3 {name: 'Rio de Janeiro'})-[:IS_PART_OF]->(rio_state);
MERGE (ikeja:Admin_3 {name: 'Ikeja'})-[:IS_PART_OF]->(lagos);

// STEP 3 — Create Case Relationships
MATCH (c:Admin_3 {name: 'Chennai'}), (d:Disease {name: 'Dengue'})
CREATE (c)-[:HAS_CASES_OF {case_count: 500, date_reported: date('2024-10-25')}]->(d);
MATCH (c:Admin_3 {name: 'Coimbatore'}), (d:Disease {name: 'Malaria'})
CREATE (c)-[:HAS_CASES_OF {case_count: 250, date_reported: date('2024-10-25')}]->(d);
MATCH (c:Admin_3 {name: 'São Paulo'}), (d:Disease {name: 'Chikungunya'})
CREATE (c)-[:HAS_CASES_OF {case_count: 120, date_reported: date('2024-10-25')}]->(d);
MATCH (c:Admin_3 {name: 'Rio de Janeiro'}), (d:Disease {name: 'Dengue'})
CREATE (c)-[:HAS_CASES_OF {case_count: 800, date_reported: date('2024-10-25')}]->(d);
MATCH (c:Admin_3 {name: 'Ikeja'}), (d:Disease {name: 'Malaria'})
CREATE (c)-[:HAS_CASES_OF {case_count: 1500, date_reported: date('2024-10-25')}]->(d);

// EXERCISE 1 — Find All Cities in Brazil
MATCH (country:Admin_1 {name: 'Brazil'})
      <-[:IS_PART_OF]-(state:Admin_2)
      <-[:IS_PART_OF]-(city:Admin_3)
RETURN state.name AS State, city.name AS City;

// EXERCISE 2 — Bird's Eye View
MATCH (n)
RETURN n;

// EXERCISE 3 — Admin Path for “Ikeja”
MATCH p = (city:Admin_3 {name: 'Ikeja'})-[:IS_PART_OF*]->(country:Admin_1)
RETURN p;

// EXERCISE 4 — Cities Reporting Dengue
MATCH (city:Admin_3)-[:HAS_CASES_OF]->(disease:Disease {name: 'Dengue'})
RETURN city, disease;

// EXERCISE 5 — Outbreaks > 750 Cases
MATCH (city:Admin_3)-[r:HAS_CASES_OF]->(disease:Disease)
WHERE r.case_count > 750
RETURN city.name, disease.name, r.case_count;

// EXERCISE 6 — Countries with Malaria Outbreaks
MATCH (country:Admin_1)<-[:IS_PART_OF*]-(city:Admin_3)
      -[:HAS_CASES_OF]->(disease:Disease {name: 'Malaria'})
RETURN DISTINCT country, disease;

// FINAL — Total Cases Per Country
MATCH (country:Admin_1)<-[:IS_PART_OF*]-(city:Admin_3)
      -[r:HAS_CASES_OF]->(disease:Disease)
RETURN country.name AS Country,
       SUM(r.case_count) AS TotalCases
ORDER BY TotalCases DESC;
