import { getConnections, seed, PgTestClient } from 'pgsql-test';

// seed.pgpm() deploys this module into a throwaway database. Because vet.control
// declares `requires = 'pets'`, pgpm resolves and deploys the pets package first,
// so every test below runs against both packages.
//
// `pg` is the superuser client. Neither package defines grants yet, so the
// unprivileged `db` app-role client cannot see either schema.
let pg: PgTestClient;
let teardown: () => Promise<void>;

beforeAll(async () => {
  ({ pg, teardown } = await getConnections({}, [seed.pgpm()]));
});

afterAll(async () => {
  await teardown();
});

beforeEach(async () => {
  await pg.beforeEach();
});

afterEach(async () => {
  await pg.afterEach();
});

const nextWeek = () => new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

async function createOwnerAndPet(ownerName = 'Ada Lovelace', petName = 'Rex') {
  const owner = await pg.query(
    `INSERT INTO pets_public.owners (name, email) VALUES ($1, $2) RETURNING id`,
    [ownerName, `${ownerName.toLowerCase().replace(/\s+/g, '.')}@example.com`]
  );
  const pet = await pg.query(
    `INSERT INTO pets_public.pets (owner_id, name, species) VALUES ($1, $2, 'dog') RETURNING id`,
    [owner.rows[0].id, petName]
  );
  return { ownerId: owner.rows[0].id as string, petId: pet.rows[0].id as string };
}

describe('vet depends on pets', () => {
  it('deploys the pets package alongside vet', async () => {
    const result = await pg.query(`
      SELECT table_schema, table_name
      FROM information_schema.tables
      WHERE (table_schema, table_name) IN (
        ('pets_public', 'owners'),
        ('pets_public', 'pets'),
        ('vet_public', 'appointments')
      )
      ORDER BY table_schema, table_name
    `);
    expect(result.rows).toEqual([
      { table_schema: 'pets_public', table_name: 'owners' },
      { table_schema: 'pets_public', table_name: 'pets' },
      { table_schema: 'vet_public', table_name: 'appointments' }
    ]);
  });

  it('records both packages in the pgpm migration ledger', async () => {
    const result = await pg.query(`
      SELECT DISTINCT package
      FROM pgpm_migrate.changes
      ORDER BY package
    `);
    expect(result.rows.map((r) => r.package)).toEqual(['pets', 'vet']);
  });

  it('appointments carry a foreign key into pets_public.pets', async () => {
    const result = await pg.query(`
      SELECT confrelid::regclass::text AS references_table, confdeltype
      FROM pg_constraint
      WHERE conrelid = 'vet_public.appointments'::regclass AND contype = 'f'
    `);
    expect(result.rows).toEqual([{ references_table: 'pets_public.pets', confdeltype: 'c' }]);
  });
});

describe('vet_public.book_appointment', () => {
  it('books an appointment for an existing pet', async () => {
    const { petId } = await createOwnerAndPet();

    const result = await pg.query(
      `SELECT * FROM vet_public.book_appointment($1, $2, $3)`,
      [petId, nextWeek(), 'Annual checkup']
    );

    expect(result.rows).toHaveLength(1);
    expect(result.rows[0].pet_id).toBe(petId);
    expect(result.rows[0].reason).toBe('Annual checkup');
    expect(result.rows[0].status).toBe('scheduled');
  });

  it('rejects a pet that does not exist', async () => {
    await expect(
      pg.query(`SELECT * FROM vet_public.book_appointment(gen_random_uuid(), $1, 'Checkup')`, [nextWeek()])
    ).rejects.toThrow(/does not exist/);
  });

  it('rejects appointments in the past', async () => {
    const { petId } = await createOwnerAndPet();
    await expect(
      pg.query(`SELECT * FROM vet_public.book_appointment($1, now() - interval '1 day', 'Checkup')`, [petId])
    ).rejects.toThrow(/in the past/);
  });
});

describe('vet_public.appointment_schedule', () => {
  it('joins each appointment to its pet and owner from the pets package', async () => {
    const { petId } = await createOwnerAndPet('Grace Hopper', 'Byte');
    await pg.query(`SELECT vet_public.book_appointment($1, $2, 'Vaccination')`, [petId, nextWeek()]);

    const result = await pg.query(`
      SELECT pet_name, species, owner_name, owner_email, reason, status
      FROM vet_public.appointment_schedule
    `);

    expect(result.rows).toEqual([
      {
        pet_name: 'Byte',
        species: 'dog',
        owner_name: 'Grace Hopper',
        owner_email: 'grace.hopper@example.com',
        reason: 'Vaccination',
        status: 'scheduled'
      }
    ]);
  });

  it('removes appointments when the pet is deleted', async () => {
    const { petId } = await createOwnerAndPet();
    await pg.query(`SELECT vet_public.book_appointment($1, $2, 'Dental')`, [petId, nextWeek()]);

    await pg.query(`DELETE FROM pets_public.pets WHERE id = $1`, [petId]);

    const result = await pg.query(`SELECT count(*)::int AS n FROM vet_public.appointments`);
    expect(result.rows[0].n).toBe(0);
  });
});
