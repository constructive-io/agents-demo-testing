-- Verify: schema/pets_public/tables/pets

DO $$
BEGIN
  PERFORM 1 FROM pg_tables WHERE schemaname = 'pets_public' AND tablename = 'pets';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Table pets_public.pets does not exist';
  END IF;

  PERFORM 1 FROM pg_indexes WHERE schemaname = 'pets_public' AND indexname = 'pets_owner_id_idx';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Index pets_owner_id_idx does not exist';
  END IF;
END $$;

SELECT id, owner_id, name, species, breed, birth_date, created_at
FROM pets_public.pets
WHERE FALSE;
