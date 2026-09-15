-- Verify: schema/vet_public/tables/appointments

DO $$
BEGIN
  PERFORM 1 FROM pg_tables WHERE schemaname = 'vet_public' AND tablename = 'appointments';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Table vet_public.appointments does not exist';
  END IF;

  PERFORM 1 FROM pg_constraint
  WHERE conrelid = 'vet_public.appointments'::regclass
    AND contype = 'f'
    AND confrelid = 'pets_public.pets'::regclass;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Foreign key from vet_public.appointments to pets_public.pets does not exist';
  END IF;

  PERFORM 1 FROM pg_indexes WHERE schemaname = 'vet_public' AND indexname = 'appointments_pet_id_idx';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Index appointments_pet_id_idx does not exist';
  END IF;
END $$;

SELECT id, pet_id, scheduled_at, reason, status, notes, created_at
FROM vet_public.appointments
WHERE FALSE;
