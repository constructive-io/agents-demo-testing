-- Verify: schema/pets_public

DO $$
BEGIN
  PERFORM 1 FROM information_schema.schemata WHERE schema_name = 'pets_public';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Schema pets_public does not exist';
  END IF;
END $$;
