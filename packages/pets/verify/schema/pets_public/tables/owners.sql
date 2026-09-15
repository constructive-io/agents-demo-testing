-- Verify: schema/pets_public/tables/owners

DO $$
BEGIN
  PERFORM 1 FROM pg_tables WHERE schemaname = 'pets_public' AND tablename = 'owners';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Table pets_public.owners does not exist';
  END IF;
END $$;

SELECT id, name, email, created_at
FROM pets_public.owners
WHERE FALSE;
