CREATE OR REPLACE FUNCTION app_current_user_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
  SELECT NULLIF(current_setting('app.current_user_id', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION app_current_organization_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
  SELECT u.organization_id
  FROM users u
  WHERE u.id = app_current_user_id();
$$;

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

ALTER TABLE users FORCE ROW LEVEL SECURITY;
ALTER TABLE organization_memberships FORCE ROW LEVEL SECURITY;
ALTER TABLE tickets FORCE ROW LEVEL SECURITY;
ALTER TABLE messages FORCE ROW LEVEL SECURITY;
ALTER TABLE ticket_assignments FORCE ROW LEVEL SECURITY;
ALTER TABLE audit_logs FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS users_tenant_isolation ON users;
CREATE POLICY users_tenant_isolation ON users
  USING (organization_id = app_current_organization_id())
  WITH CHECK (organization_id = app_current_organization_id());

DROP POLICY IF EXISTS memberships_tenant_isolation ON organization_memberships;
CREATE POLICY memberships_tenant_isolation ON organization_memberships
  USING (organization_id = app_current_organization_id())
  WITH CHECK (organization_id = app_current_organization_id());

DROP POLICY IF EXISTS tickets_tenant_isolation ON tickets;
CREATE POLICY tickets_tenant_isolation ON tickets
  USING (organization_id = app_current_organization_id())
  WITH CHECK (organization_id = app_current_organization_id());

DROP POLICY IF EXISTS messages_tenant_isolation ON messages;
CREATE POLICY messages_tenant_isolation ON messages
  USING (organization_id = app_current_organization_id())
  WITH CHECK (organization_id = app_current_organization_id());

DROP POLICY IF EXISTS ticket_assignments_tenant_isolation ON ticket_assignments;
CREATE POLICY ticket_assignments_tenant_isolation ON ticket_assignments
  USING (organization_id = app_current_organization_id())
  WITH CHECK (organization_id = app_current_organization_id());

DROP POLICY IF EXISTS audit_logs_tenant_isolation ON audit_logs;
CREATE POLICY audit_logs_tenant_isolation ON audit_logs
  USING (organization_id = app_current_organization_id())
  WITH CHECK (organization_id = app_current_organization_id());

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
    CREATE ROLE app_user LOGIN PASSWORD 'app_user_password';
  END IF;
END;
$$;

GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON users, organization_memberships, tickets, messages, ticket_assignments, audit_logs TO app_user;
GRANT SELECT ON organizations, roles TO app_user;
