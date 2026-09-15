-- Verify: schema/vet_public/views/appointment_schedule

SELECT appointment_id, scheduled_at, reason, status,
       pet_id, pet_name, species,
       owner_id, owner_name, owner_email
FROM vet_public.appointment_schedule
WHERE FALSE;
