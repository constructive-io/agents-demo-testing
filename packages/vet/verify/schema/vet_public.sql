-- Verify: schema/vet_public

DO $$
BEGIN
  PERFORM 1 FROM information_schema.schemata WHERE schema_name = 'vet_public';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Schema vet_public does not exist';
  END IF;
END $$;
