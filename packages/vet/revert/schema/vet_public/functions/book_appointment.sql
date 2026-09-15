-- Revert: schema/vet_public/functions/book_appointment

DROP FUNCTION IF EXISTS vet_public.book_appointment(uuid, timestamptz, text);
