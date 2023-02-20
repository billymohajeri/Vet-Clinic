/* Database schema to keep the structure of entire database. */

CREATE TABLE animals(
  id INT GENERATED ALWAYS AS IDENTITY,
  name VARCHAR(250),
  date_of_birt DATE,
  escape_attempts INT,
  neutered BOOL,
  weight_kg DECIMAL,
  PRIMARY KEY(id)
);