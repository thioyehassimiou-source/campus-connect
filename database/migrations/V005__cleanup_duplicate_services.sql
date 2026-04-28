-- Identify and delete duplicate services, keeping the most recent one (highest ID)
-- We group by lower(nom) to catch case-sensitivity issues

BEGIN;

-- Create a temporary table to store IDs of services to keep
CREATE TEMP TABLE keep_services AS
SELECT DISTINCT ON (LOWER(nom)) id
FROM services
ORDER BY LOWER(nom), created_at DESC; -- Keep the most recently created one

-- Output the services being deleted (for debugging/log)
-- SELECT id, nom FROM services WHERE id NOT IN (SELECT id FROM keep_services);

-- Delete services that are NOT in the keep list
DELETE FROM services
WHERE id NOT IN (SELECT id FROM keep_services);

-- Drop the temp table
DROP TABLE keep_services;

COMMIT;
