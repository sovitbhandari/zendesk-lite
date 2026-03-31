# Database Schema (Sprint 1)

This project uses PostgreSQL with strict tenant isolation. The schema includes 8 core tables.

## Tables

1. `organizations`
   - Tenant root table.
   - Key fields: `id`, `name`, `slug`, `is_active`.

2. `roles`
   - Global RBAC role catalog.
   - Key fields: `id`, `key` (`customer`, `agent`, `admin`), `description`.

3. `users`
   - Authenticated users scoped to an organization.
   - Key fields: `id`, `organization_id`, `email`, `full_name`, `password_hash`.

4. `organization_memberships`
   - Maps users to RBAC roles in an organization.
   - Key fields: `organization_id`, `user_id`, `role_id`.

5. `tickets`
   - Core customer support issue record.
   - Key fields: `organization_id`, `requester_id`, `subject`, `description`, `status`, `priority`.

6. `messages`
   - Conversation log per ticket.
   - Key fields: `organization_id`, `ticket_id`, `author_id`, `body`.

7. `ticket_assignments`
   - Agent claim/assignment history per ticket.
   - Key fields: `organization_id`, `ticket_id`, `agent_id`, `assigned_at`, `released_at`.

8. `audit_logs`
   - Tenant-scoped immutable event trail.
   - Key fields: `organization_id`, `actor_user_id`, `event_type`, `payload`, `sequence_id`.

## Tenant Isolation Model

- Session variable `app.current_user_id` identifies the active principal.
- Function `app_current_organization_id()` resolves the principal's tenant.
- RLS is enabled and forced on tenant data tables (`users`, `organization_memberships`, `tickets`, `messages`, `ticket_assignments`, `audit_logs`).
- Policies enforce `organization_id = app_current_organization_id()` for both read (`USING`) and write (`WITH CHECK`) paths.

## Seed Data

Seed data provisions two independent organizations:

- `acme` (Acme Corp)
- `globex` (Globex Inc)

Each org has customer, agent, and admin users and at least one ticket for isolation testing.
