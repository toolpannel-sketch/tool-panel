# Lua License Panel — Full Backup and Parallel Replication Guide

## Purpose

This package is a portable source and deployment backup for `lua-license-panel`. It is intended to let an authorized maintainer create a second parallel project with the same application behavior, API contracts, HTTP/transport-related code, Lua artifacts, database schema, migrations, tests, and frontend/backend source.

A source archive is not, by itself, a complete live-service clone. The current database contents, managed environment secrets, domain bindings, integrations, scheduled tasks, object storage, authentication configuration, and other Manus-hosted capabilities are platform-bound and must be exported or recreated through the official Manus Task Data Backup and project settings.

## Included in the portable archive

The archive includes the React frontend, Node/Express/tRPC backend, shared types, Drizzle schema and migration history, tests, Lua loaders and related artifacts stored in the project, API and license documentation, HTTP/transport audit documents, package manifests and lockfiles, project configuration, and this replication guide. `node_modules`, transient logs, temporary files, local caches, and Git metadata are excluded so the package can be installed reproducibly from `pnpm-lock.yaml`.

## Deliberately excluded

Plaintext `.env` files, session cookies, private keys, API tokens, database passwords, OAuth credentials, and other secret values are not included. Never copy secrets from shell output or commit them into the replica. Configure each required value through the new project's managed Secrets interface.

The live database data is delivered separately as a compressed SQL snapshot when available. The official Manus Task Data Backup remains the authoritative backup for database contents, managed secrets, uploaded files, integrations, domains, and Manus-hosted capabilities.

## Required environment configuration

The replica must receive its own managed values for the following categories. Values are intentionally omitted from this document:

| Variable/category | Purpose |
|---|---|
| `DATABASE_URL` | Replica MySQL/TiDB database connection |
| `JWT_SECRET` | Session signing secret; generate a new value for a separate deployment unless session continuity is explicitly required |
| `VITE_APP_ID`, `VITE_OAUTH_PORTAL_URL`, `OAUTH_SERVER_URL` | Manus OAuth application configuration |
| `OWNER_OPEN_ID`, `OWNER_NAME` | Platform-managed owner identity and owner display metadata |
| `BUILT_IN_FORGE_API_URL`, `BUILT_IN_FORGE_API_KEY` | Server-side Manus built-in services |
| `VITE_FRONTEND_FORGE_API_URL`, `VITE_FRONTEND_FORGE_API_KEY` | Frontend built-in service access where required |
| `VITE_ANALYTICS_ENDPOINT`, `VITE_ANALYTICS_WEBSITE_ID` | Optional analytics configuration |
| `VITE_APP_TITLE`, `VITE_APP_LOGO` | Application branding |

For a true independent parallel deployment, create a separate OAuth application/project identity and use a separate database and secret set. Do not reuse production session secrets or database credentials unintentionally.

## Database restoration

Apply the Drizzle migrations in filename order before importing any data snapshot. Verify the schema after migration. Then import the compressed SQL data snapshot, if provided, into the replica database. Do not run destructive SQL against the production database. A second project should use a separate database endpoint or schema.

The migrations define the application structures, but only a data snapshot preserves current users, keys, referrals, device bindings, announcements, Telegram mappings, tickets, and related records. Confirm foreign-key dependencies and test login, key generation, validation, multi-device reporting, announcements, and Telegram flows in the replica before using it.

## Protected production boundaries

The backup preserves the existing license validation, authentication, authorization, HTTP/transport, callback, device-binding, referral, key-generation, Main Lua, System Announcement, and isolated Telegram implementations as source. No backup operation changes those systems.

## Reproduction outline

Create a new authorized WebDev project, copy the portable source archive, install dependencies with the included lockfile, configure managed secrets, create or select a separate database, apply migrations in order, import the data snapshot only if an exact data clone is authorized, and run the existing test and type-check commands. Reconnect OAuth, domains, integrations, storage, and scheduled tasks through the new project's management settings. Use a separate owner identity or explicitly approved owner mapping for the parallel project.

## Validation checklist

The replica is not considered equivalent until the operator verifies that the application starts, TypeScript checks pass, the existing Vitest suite passes, the database schema matches, the protected `/api/license/validate` contract is unchanged, normal and multi-device license flows work, fail-closed behavior remains active, announcement behavior works, and Telegram remains removable without affecting core authentication or validation.

## Official platform backup requirement

For an affected Manus account, use the official [Data Backup Tool](https://manus.im/backup) and export the broadest current Task Data snapshot available. A Task Data Backup is a point-in-time snapshot and is not automatically synchronized after export. Keep each complete export set unchanged and do not mix split parts from different exports. The official Task Data Backup is required for platform-managed database contents, secrets, uploaded files, integrations, domains, and hosted capabilities that a source archive cannot reproduce alone.

See the [official backup guide](https://help.manus.im/en/articles/16147892-service-change-overview-how-to-back-up-your-data) and [restoration guide](https://help.manus.im/en/articles/16147895-service-change-overview-how-to-restore-your-data) for account-specific eligibility and restoration rules.

## Security note

Treat the source archive and SQL snapshot as confidential. The SQL snapshot may contain license keys, user identifiers, referral records, device-binding records, announcement text, and Telegram mappings. Store it in encrypted storage and share it only with the authorized project owner.

Author: Manus AI
Generated for project `lua-license-panel`.

[Official backup tool]: https://manus.im/backup
[Backup guide]: https://help.manus.im/en/articles/16147892-service-change-overview-how-to-back-up-your-data
[Restoration guide]: https://help.manus.im/en/articles/16147895-service-change-overview-how-to-restore-your-data
