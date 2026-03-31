INSERT INTO roles (key, description)
VALUES
  ('customer', 'Customer end-user role'),
  ('agent', 'Support agent role'),
  ('admin', 'Organization administrator role')
ON CONFLICT (key) DO NOTHING;

WITH inserted_orgs AS (
  INSERT INTO organizations (name, slug)
  VALUES
    ('Acme Corp', 'acme'),
    ('Globex Inc', 'globex')
  ON CONFLICT (slug) DO UPDATE SET updated_at = now()
  RETURNING id, slug
),
all_orgs AS (
  SELECT id, slug FROM inserted_orgs
  UNION
  SELECT id, slug FROM organizations WHERE slug IN ('acme', 'globex')
),
inserted_users AS (
  INSERT INTO users (organization_id, email, full_name, password_hash)
  SELECT ao.id, v.email, v.full_name, 'hashed-password'
  FROM all_orgs ao
  JOIN (
    VALUES
      ('acme', 'alice.customer@acme.com', 'Alice Customer'),
      ('acme', 'adam.agent@acme.com', 'Adam Agent'),
      ('acme', 'amy.admin@acme.com', 'Amy Admin'),
      ('globex', 'gary.customer@globex.com', 'Gary Customer'),
      ('globex', 'gina.agent@globex.com', 'Gina Agent'),
      ('globex', 'grace.admin@globex.com', 'Grace Admin')
  ) AS v(org_slug, email, full_name) ON v.org_slug = ao.slug
  ON CONFLICT (email) DO UPDATE SET updated_at = now()
  RETURNING id, organization_id, email
),
all_users AS (
  SELECT id, organization_id, email FROM inserted_users
  UNION
  SELECT id, organization_id, email FROM users WHERE email IN (
    'alice.customer@acme.com', 'adam.agent@acme.com', 'amy.admin@acme.com',
    'gary.customer@globex.com', 'gina.agent@globex.com', 'grace.admin@globex.com'
  )
),
role_map AS (
  SELECT id, key FROM roles WHERE key IN ('customer', 'agent', 'admin')
)
INSERT INTO organization_memberships (organization_id, user_id, role_id)
SELECT
  au.organization_id,
  au.id,
  rm.id
FROM all_users au
JOIN role_map rm ON rm.key = CASE
  WHEN au.email LIKE '%.customer@%' THEN 'customer'
  WHEN au.email LIKE '%.agent@%' THEN 'agent'
  ELSE 'admin'
END
ON CONFLICT (organization_id, user_id) DO NOTHING;

WITH u AS (
  SELECT id, organization_id, email FROM users
  WHERE email IN ('alice.customer@acme.com', 'gary.customer@globex.com')
)
INSERT INTO tickets (organization_id, requester_id, subject, description, status, priority)
SELECT
  u.organization_id,
  u.id,
  CASE WHEN u.email LIKE '%acme%' THEN 'Acme billing issue' ELSE 'Globex login issue' END,
  CASE WHEN u.email LIKE '%acme%' THEN 'Invoice mismatch for March' ELSE 'Unable to access portal' END,
  'open',
  'high'
FROM u
ON CONFLICT DO NOTHING;
