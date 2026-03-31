DROP POLICY IF EXISTS users_tenant_isolation ON users;
DROP POLICY IF EXISTS memberships_tenant_isolation ON organization_memberships;
DROP POLICY IF EXISTS tickets_tenant_isolation ON tickets;
DROP POLICY IF EXISTS messages_tenant_isolation ON messages;
DROP POLICY IF EXISTS ticket_assignments_tenant_isolation ON ticket_assignments;
DROP POLICY IF EXISTS audit_logs_tenant_isolation ON audit_logs;

REVOKE ALL ON FUNCTION app_current_organization_id() FROM app_user;
DROP FUNCTION IF EXISTS app_current_organization_id();
DROP FUNCTION IF EXISTS app_current_user_id();

ALTER TABLE IF EXISTS users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS organization_memberships DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS tickets DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS ticket_assignments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS audit_logs DISABLE ROW LEVEL SECURITY;

DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS ticket_assignments CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS organization_memberships CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS organizations CASCADE;
DROP TABLE IF EXISTS schema_migrations CASCADE;

DROP TYPE IF EXISTS ticket_status;
DROP TYPE IF EXISTS ticket_priority;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
    REVOKE ALL ON SCHEMA public FROM app_user;
  END IF;
END;
$$;
