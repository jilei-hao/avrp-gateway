-- create user avrpdev
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles 
      WHERE  rolname = 'avrpdev') THEN

      CREATE ROLE avrpdev LOGIN PASSWORD 'avrpdev';
   END IF;
END
$do$;

-- grant all privileges on database data-server-db to avrpdev;
grant all privileges on all tables in schema public to avrpdev;
grant all privileges on all sequences in schema public to avrpdev;
grant all privileges on all functions in schema public to avrpdev;