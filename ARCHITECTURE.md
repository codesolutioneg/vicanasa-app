# Vacansa Architecture

Clean Architecture with feature-first folders:

- **Presentation**: Bloc/Cubit, pages, widgets
- **Domain**: entities, repository interfaces
- **Data**: remote datasources, repository implementations

Odoo session auth via cookie-enabled Dio client and JSON-RPC `POST` to `/my/financial/api/*`.

Mobile-only FCM topics: `all_users` + sanitized email topic.
