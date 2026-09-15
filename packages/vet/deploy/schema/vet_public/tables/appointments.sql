-- Deploy: schema/vet_public/tables/appointments
-- made with <3 @ constructive.io

-- requires: schema/vet_public
-- requires: pets:schema/pets_public/tables/pets

CREATE TABLE vet_public.appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id uuid NOT NULL REFERENCES pets_public.pets (id) ON DELETE CASCADE,
  scheduled_at timestamptz NOT NULL,
  reason text NOT NULL,
  status text NOT NULL DEFAULT 'scheduled'
    CONSTRAINT appointments_status_check CHECK (status IN ('scheduled', 'completed', 'cancelled')),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX appointments_pet_id_idx ON vet_public.appointments (pet_id);
CREATE INDEX appointments_scheduled_at_idx ON vet_public.appointments (scheduled_at);

COMMENT ON TABLE vet_public.appointments IS 'One row per clinic visit booked for a pet';
COMMENT ON COLUMN vet_public.appointments.id IS 'Primary key';
COMMENT ON COLUMN vet_public.appointments.pet_id IS 'The pet being seen; lives in the pets package';
COMMENT ON COLUMN vet_public.appointments.scheduled_at IS 'When the visit is scheduled';
COMMENT ON COLUMN vet_public.appointments.reason IS 'Why the pet is coming in';
COMMENT ON COLUMN vet_public.appointments.status IS 'scheduled, completed, or cancelled';
COMMENT ON COLUMN vet_public.appointments.notes IS 'Free-form notes from the visit';
COMMENT ON COLUMN vet_public.appointments.created_at IS 'When the appointment was booked';
