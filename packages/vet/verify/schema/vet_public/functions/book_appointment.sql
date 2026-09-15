-- Verify: schema/vet_public/functions/book_appointment

SELECT has_function_privilege('vet_public.book_appointment(uuid, timestamptz, text)', 'execute');
