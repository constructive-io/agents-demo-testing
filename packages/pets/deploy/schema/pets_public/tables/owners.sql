-- Deploy: schema/pets_public/tables/owners
-- made with <3 @ constructive.io

-- requires: schema/pets_public

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
