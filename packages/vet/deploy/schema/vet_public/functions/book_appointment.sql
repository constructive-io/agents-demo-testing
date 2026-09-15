-- Deploy: schema/vet_public/functions/book_appointment
-- made with <3 @ constructive.io

-- requires: schema/vet_public/tables/appointments

CREATE FUNCTION vet_public.book_appointment(
  pet_id uuid,
  scheduled_at timestamptz,
  reason text
)
RETURNS vet_public.appointments AS $$
DECLARE
  result vet_public.appointments;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pets_public.pets p WHERE p.id = book_appointment.pet_id) THEN
    RAISE EXCEPTION 'Cannot book appointment: pet % does not exist', book_appointment.pet_id
      USING ERRCODE = 'no_data_found';
  END IF;

  IF book_appointment.scheduled_at < now() THEN
    RAISE EXCEPTION 'Cannot book appointment in the past (%)', book_appointment.scheduled_at
      USING ERRCODE = 'check_violation';
  END IF;

  INSERT INTO vet_public.appointments (pet_id, scheduled_at, reason)
  VALUES (book_appointment.pet_id, book_appointment.scheduled_at, book_appointment.reason)
  RETURNING * INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION vet_public.book_appointment(uuid, timestamptz, text)
  IS 'Books a future appointment for an existing pet and returns the new row';
