-- Deploy: schema/vet_public/views/appointment_schedule
-- made with <3 @ constructive.io

-- requires: schema/vet_public/tables/appointments
-- requires: pets:schema/pets_public/tables/owners

CREATE VIEW vet_public.appointment_schedule AS
SELECT
  a.id            AS appointment_id,
  a.scheduled_at,
  a.reason,
  a.status,
  p.id            AS pet_id,
  p.name          AS pet_name,
  p.species,
  o.id            AS owner_id,
  o.name          AS owner_name,
  o.email         AS owner_email
FROM vet_public.appointments a
JOIN pets_public.pets p ON p.id = a.pet_id
LEFT JOIN pets_public.owners o ON o.id = p.owner_id;

COMMENT ON VIEW vet_public.appointment_schedule
  IS 'Appointments joined with the pet and owner rows from the pets package';
