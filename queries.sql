/*Queries that provide answers to the questions from all projects.*/

SELECT * FROM animals WHERE name LIKE '%mon';
SELECT name FROM animals WHERE date_of_birth BETWEEN '2016-1-1' AND '2019-12-31';
SELECT name FROM animals WHERE neutered AND escape_attempts < 3;
SELECT date_of_birth FROM animals WHERE name = 'Agumon' OR name = 'Pikachu';
SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;
SELECT * FROM animals WHERE neutered;
SELECT * FROM animals WHERE name <> 'Gabumon';
SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3;

-- Inside a transaction update the animals table by setting the species column to unspecified. Verify that change was made.
-- Then roll back the change and verify that the species columns went back to the state before the transaction.
BEGIN;
UPDATE animals SET species = 'unspecified';
SELECT species FROM animals;
ROLLBACK;
SELECT species FROM animals;

-- Inside a transaction:
-- Update the animals table by setting the species column to digimon for all animals that have a name ending in mon.
-- Update the animals table by setting the species column to pokemon for all animals that don't have species already set.
-- Commit the transaction.
-- Verify that change was made and persists after commit.
BEGIN;
UPDATE animals SET species = 'digimon' WHERE name LIKE '%mon';
UPDATE animals SET species = 'pokemon' WHERE species IS NULL;
SELECT species FROM animals;
COMMIT;
SELECT species FROM animals;

-- Now, take a deep breath and... Inside a transaction delete all records in the animals table, then roll back the transaction.
-- After the rollback verify if all records in the animals table still exists. After that, you can start breathing as usual ;)
BEGIN;
DELETE FROM animals;
TABLE animals;
ROLLBACK;
TABLE animals;

-- Inside a transaction:
-- Delete all animals born after Jan 1st, 2022.
-- Create a savepoint for the transaction.
-- Update all animals' weight to be their weight multiplied by -1.
-- Rollback to the savepoint
-- Update all animals' weights that are negative to be their weight multiplied by -1.
-- Commit transaction
BEGIN;
DELETE FROM animals WHERE date_of_birth > '2022-1-1';
SAVEPOINT SP1;
UPDATE animals SET weight_kg = weight_kg * -1;
ROLLBACK TO SP1;
UPDATE animals SET weight_kg = weight_kg * -1 WHERE weight_kg < 0;
COMMIT;
TABLE animals;

-- How many animals are there?
SELECT COUNT(*) AS count_of_all_animals FROM animals;

-- How many animals have never tried to escape?
SELECT COUNT(*) AS count_of_never_escaped FROM animals WHERE escape_attempts = 0;

-- What is the average weight of animals?
SELECT AVG(weight_kg) AS avg_weight FROM animals;

-- Who escapes the most, neutered or not neutered animals?
SELECT neutered, SUM(escape_attempts) AS sum_of_esc, AVG(escape_attempts) AS avg_of_esc 
FROM animals GROUP BY neutered;

-- What is the minimum and maximum weight of each type of animal?
SELECT species, MIN(weight_kg) AS min_weight, MAX(weight_kg) AS max_weight FROM animals GROUP BY species;

-- What is the average number of escape attempts per animal type of those born between 1990 and 2000?
SELECT species, AVG(escape_attempts) AS avg_of_esc FROM animals 
WHERE date_of_birth BETWEEN '1990-1-1' AND '2000-12-31' GROUP BY species;


-- Write queries (using JOIN) to answer the following questions:
-- What animals belong to Melody Pond?
SELECT name AS animal_name FROM
animals A INNER JOIN owners O
ON A.owner_id = O.id
WHERE O.full_name = 'Melody Pond';


-- List of all animals that are pokemon (their type is Pokemon).
SELECT A.name AS pokemon_animals FROM
animals A INNER JOIN species S
ON A.species_id = S.id
WHERE S.name = 'Pokemon';


-- List all owners and their animals, remember to include those that don't own any animal.
SELECT O.full_name AS owner_name, A.name AS animal_name FROM
owners O LEFT JOIN animals A
ON O.id = A.owner_id
ORDER BY owner_name;


-- How many animals are there per species?
SELECT S.name AS specie, COUNT(A.name) FROM
species S INNER JOIN animals A
ON S.id = A.species_id
GROUP BY S.name;


-- List all Digimon owned by Jennifer Orwell.
SELECT animals.name AS digimon_name FROM
animals INNER JOIN species
ON animals.species_id = species.id
WHERE animals.owner_id = (SELECT id FROM owners WHERE full_name = 'Jennifer Orwell')
AND species.id = (SELECT id FROM species WHERE name = 'Digimon');


-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT name AS non_esc_animals FROM animals
INNER JOIN owners
ON animals.owner_id = owners.id
WHERE animals.owner_id = (SELECT id FROM owners WHERE full_name = 'Dean Winchester')
AND animals.escape_attempts = 0;


-- Who owns the most animals?
SELECT COUNT(animals.name) AS animal_count, owners.full_name AS owner FROM animals
INNER JOIN owners
ON animals.owner_id = owners.id
GROUP BY owners.full_name
ORDER BY COUNT(name) DESC LIMIT 1;


-- Write queries to answer the following:
-- Who was the last animal seen by William Tatcher?
--------------- Method 1 ---------------
SELECT date_of_visit, name AS name_of_animal FROM visits
INNER JOIN animals
ON visits.animal_id = animals.id
WHERE vets_id = (SELECT id FROM vets WHERE name = 'William Tatcher')
ORDER BY date_of_visit DESC LIMIT 1;
--------------- Method 2 ---------------
SELECT date_of_visit, animals.name AS name_of_animal FROM visits
INNER JOIN animals
ON visits.animal_id = animals.id
INNER JOIN vets
ON vets_id = vets.id
WHERE vets.name = 'William Tatcher'
ORDER BY date_of_visit DESC LIMIT 1;


-- How many different animals did Stephanie Mendez see?
SELECT DISTINCT COUNT(animals.name) FROM animals
INNER JOIN visits
ON animals.id = visits.animal_id
INNER JOIN vets
ON vets_id = vets.id
WHERE vets.name = 'Stephanie Mendez';


-- List all vets and their specialties, including vets with no specialties.
SELECT vets.name, species.name FROM vets
LEFT JOIN specializations
ON vets.id = specializations.vets_id
LEFT JOIN species
ON specializations.species_id = species.id
ORDER BY vets.name;


-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT animals.name FROM animals
INNER JOIN visits
ON animals.id = visits.animal_id
INNER JOIN vets
ON visits.vets_id = vets.id
WHERE vets.name = 'Stephanie Mendez'
AND date_of_visit BETWEEN '2020-04-01' AND '2020-08-30';


-- What animal has the most visits to vets?
SELECT COUNT(animals.name), animals.name AS most_visited_animal FROM animals
INNER JOIN visits
ON animals.id = visits.animal_id
GROUP BY animals.name
ORDER BY COUNT(animals.name) DESC LIMIT 1;


-- Who was Maisy Smith's first visit?
SELECT animals.name, MIN(visits.date_of_visit) FROM animals
INNER JOIN visits
ON animals.id = visits.animal_id
INNER JOIN vets
ON visits.vets_id = vets.id
WHERE vets.name = 'Maisy Smith'
GROUP BY animals.name
ORDER BY MIN(visits.date_of_visit) LIMIT 1;


-- Details for most recent visit: animal information,
-- vet information, and date of visit.
SELECT V.date_of_visit, A.name AS animal_name, vets.name FROM visits V
INNER JOIN animals A
ON V.animal_id = A.id
INNER JOIN vets
ON V.vets_id = vets.id
ORDER BY date_of_visit DESC LIMIT 1;


-- How many visits were with a vet that did not specialize in that animal's species?
SELECT COUNT(*) FROM visits
INNER JOIN animals
ON visits.animal_id = animals.id
INNER JOIN specializations
ON visits.vets_id = specializations.vets_id
WHERE specializations.species_id <> animals.species_id;


-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT S.name AS needed_specialty FROM visits VI
INNER JOIN animals A
ON VI.animal_id = A.id
INNER JOIN species S
ON A.species_id = S.id
INNER JOIN vets VE
ON VI.vets_id = VE.id
WHERE VE.name = 'Maisy Smith'
GROUP BY S.name
ORDER BY COUNT(*) DESC LIMIT 1;

EXPLAIN ANALYZE SELECT COUNT(*) FROM visits where animal_id = 4;

EXPLAIN ANALYZE SELECT * FROM visits where vet_id = 2;

EXPLAIN ANALYZE SELECT * FROM owners where email = 'owner_18327@mail.com';