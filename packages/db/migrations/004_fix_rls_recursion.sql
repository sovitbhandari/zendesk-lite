CREATE OR REPLACE FUNCTION app_current_organization_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT u.organization_id
  FROM users u
  WHERE u.id = app_current_user_id();
$$;

REVOKE ALL ON FUNCTION app_current_organization_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app_current_organization_id() TO app_user;
