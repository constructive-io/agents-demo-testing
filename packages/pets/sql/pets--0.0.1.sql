\echo Use "CREATE EXTENSION pets" to load this file. \quit
CREATE SCHEMA pets_public;

CREATE TABLE pets_public.owners (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE pets_public.owners IS 'People who own pets';

COMMENT ON COLUMN pets_public.owners.id IS 'Primary key';

COMMENT ON COLUMN pets_public.owners.name IS 'Display name of the owner';

COMMENT ON COLUMN pets_public.owners.email IS 'Contact email, unique when present';

COMMENT ON COLUMN pets_public.owners.created_at IS 'When the owner record was created';

CREATE TABLE pets_public.pets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES pets_public.owners (id)
    ON DELETE SET NULL,
  name text NOT NULL,
  species text NOT NULL,
  breed text,
  birth_date date,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX pets_owner_id_idx ON pets_public.pets (owner_id);

COMMENT ON TABLE pets_public.pets IS 'Pets, optionally linked to an owner';

COMMENT ON COLUMN pets_public.pets.id IS 'Primary key';

COMMENT ON COLUMN pets_public.pets.owner_id IS 'Owner of the pet; null if unowned';

COMMENT ON COLUMN pets_public.pets.name IS 'Name of the pet';

COMMENT ON COLUMN pets_public.pets.species IS 'Species, e.g. dog, cat';

COMMENT ON COLUMN pets_public.pets.breed IS 'Breed, when known';

COMMENT ON COLUMN pets_public.pets.birth_date IS 'Date of birth, when known';

COMMENT ON COLUMN pets_public.pets.created_at IS 'When the pet record was created';