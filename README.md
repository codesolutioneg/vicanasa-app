# Vicanza Partner Financial Portal (`flutter_finance_portal`)

Mobile and web app for **Vacansa / Vicanza financial partners** to view dashboards, P&L, comparisons, branch analytics, distributions, capital, and downloadable reports — powered by **Odoo 18** JSON-RPC session auth and the `partner_financial_portal` module.

**Package name:** `vacansa`  
**Display name:** Vicanza  
**Android / iOS bundle:** `com.codesolution.vacansa`  
**Git branch:** `main` (repo: `vicansa_finance` → `origin/main` on `ibrahim-atef`)

---

## Table of Contents

- [Where This App Fits](#where-this-app-fits)
- [End-to-End Flow](#end-to-end-flow)
- [Odoo Integration](#odoo-integration)
- [App Sections](#app-sections)
- [Filters & Partner Scope](#filters--partner-scope)
- [Firebase & Notifications](#firebase--notifications)
- [Project Structure](#project-structure)
- [Local Setup](#local-setup)
- [Coming Back After a Long Time](#coming-back-after-a-long-time)
- [Troubleshooting](#troubleshooting)
- [Related Projects](#related-projects)

---

## Where This App Fits

```
┌─────────────────────────────┐
│  Vicanza Financial Portal   │  partner login, dashboards, PDF reports
│  (this app)                 │
│  Flutter — mobile + web     │
└──────────────┬──────────────┘
               │ JSON-RPC + session cookies
               ▼
┌─────────────────────────────┐
│  Odoo 18 Online             │  codesolutioneg-jouma.odoo.com
│  partner_financial_portal   │  /my/financial/api/*
└──────────────┬──────────────┘
               │ accounting data
               ▼
        Partner / investor financials
        (closed months, branches, P&L, capital)
```

| Integration | Role |
|-------------|------|
| **Odoo 18** | Sole data backend — auth, partner gate, all financial APIs |
| **Firebase (`vacanca-app`)** | Push notifications (FCM) on mobile — optional on web |
| **DishFlow / POS ecosystem** | Separate products in `juma_hub` / `cai_` — not used by this app |

This app does **not** use Firestore or the DishFlow POS Firebase stack. All business data comes from Odoo.

---

## End-to-End Flow

### 1. App startup (`lib/main.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `LiquidGlassWidgets.initialize()` — glass UI effects
3. `configureDependencies()` — GetIt (`OdooClient`, repositories, cubits)
4. Firebase init + notifications (mobile only; web skips)
5. Run `VacansaApp` with connectivity gate

### 2. Splash (`/`)

Parallel:

- Animated Vicansa splash (~3s)
- `AuthCubit.checkSession()` — restore Odoo session from persisted cookies
- `FilterCubit` loads period info + closed months from Odoo

Then routes:

| State | Next screen |
|-------|-------------|
| Valid financial partner session | `/dashboard` |
| No session, onboarding done | `/login` |
| No session, first launch | `/onboarding` |
| Logged in but not a financial partner | `/access-denied` |

### 3. Onboarding (`/onboarding`)

First-run intro; flag in `SharedPreferences`.

### 4. Login (`/login`)

- Email + password → `OdooClient.authenticate()`
- Session stored in **HTTP cookies** (persisted via `OdooCookieJar` on mobile)
- Login email saved in `FlutterSecureStorage`
- FCM topic subscription for the user
- `partner-info` API must return `isFinancialPartner: true` or user sees access denied

### 5. Financial shell (`ShellRoute`)

Responsive layout:

- **Desktop (≥900px):** sidebar + header + date filter + branch selector + content
- **Mobile:** compact header + bottom nav + “More” sheet

Shared chrome on every financial page:

- `DateFilterBar` — period presets, closed-month picker
- `BranchSelector` — analytic account / branch filter (`analytic_id`)

### 6. Logout

Clears Odoo session cookies, secure storage, FCM topic → `/login`.

---

## Odoo Integration

### Connection defaults (`lib/core/constants/constants.dart`)

| Setting | Value |
|---------|--------|
| Base URL | `https://codesolutioneg-jouma.odoo.com` |
| Database | `codesolutioneg-jouma-main-25164041` |
| Auth | Odoo web session (`/web/session/authenticate`) |
| Client | `OdooClient` — Dio + JSON-RPC 2.0 + cookie jar |

### API endpoints (`FinancialRemoteDataSource`)

| Endpoint | Purpose |
|----------|---------|
| `/my/financial/api/partner-info` | Partner profile + financial access gate |
| `/my/financial/api/period-info` | Closed months, default date range |
| `/my/financial/api/data` | Dashboard financial data |
| `/my/financial/api/account-details` | Account drill-down |
| `/my/financial/api/pnl` | Profit & loss by year |
| `/my/financial/api/comparison` | Multi-year comparison |
| `/my/financial/api/growth` | Growth metrics |
| `/my/financial/api/branches` | Branch breakdown |
| `/my/financial/api/distributions` | Distribution charts |
| `/my/financial/api/capital` | Capital summary |

Requires Odoo module **`partner_financial_portal`** (≥ 18.0.1.4.0 for web CORS).

### Web vs mobile

- **Android / iOS / Windows:** full cookie session — recommended for production use
- **Chrome / web:** may hit **CORS** if Odoo server is not configured for browser origins — error message guides upgrade or use native build

---

## App Sections

| Nav | Route | Description |
|-----|-------|-------------|
| Dashboard | `/dashboard` | KPIs, waterfall, ratio cards, charts, balance breakdown |
| P&L | `/pnl` | Profit and loss by selected year |
| Comparison | `/comparison` | Year-over-year comparison |
| Reports | `/reports` | PDF export and share |
| Growth | `/growth` | Growth analytics |
| Branches | `/branches` | Per-branch financial view |
| Distributions | `/distributions` | Distribution breakdown |
| Capital | `/capital` | Capital position |

UI features:

- **Bilingual** Arabic / English (`flutter gen-l10n`, `bilingual_display.dart`)
- **Tajawal** font for Arabic typography
- **Shimmer** skeleton loaders during fetch
- **Liquid glass** modals and surfaces
- **fl_chart** for charts
- **Powered by Code Solution** branding footer

---

## Filters & Partner Scope

`FilterCubit` drives global date and branch context:

- **Closed months** — period picker limited to months closed in Odoo (from `period-info`)
- **Date range** — `date_from` / `date_to` sent to all data APIs
- **Branch filter** — optional `analytic_id` for branch-scoped reports
- **Presets** — YTD, custom month selection, etc.

All financial pages listen to filter state and refetch when it changes.

---

## Firebase & Notifications

| Setting | Value |
|---------|--------|
| Project | `vacanca-app` |
| Config | `lib/firebase_options.dart` |
| FCM topic | `all_users` (+ per-user topic on login) |
| Platforms | Mobile native; skipped on web |

Used for push alerts only — not for financial data storage.

---

## Project Structure

```
lib/
├── main.dart
├── app.dart                    # VacansaApp, locale, connectivity gate
├── firebase_options.dart
├── core/
│   ├── constants/              # Odoo URL, db, branding
│   ├── di/injection.dart
│   ├── network/                # OdooClient, cookie jar, interceptors
│   ├── router/app_router.dart
│   ├── theme/                  # Tajawal, liquid glass, colors
│   ├── shimmer/                # Loading skeletons
│   └── notifications/
├── features/
│   ├── splash/
│   ├── onboarding/
│   ├── auth/                   # Login, access denied, AuthCubit
│   ├── shell/                  # Layout, filters, branch selector
│   ├── financial/              # Odoo repository + partner entity
│   ├── dashboard/
│   ├── pnl/
│   ├── comparison/
│   ├── reports/                # PDF builder + share
│   ├── growth/
│   ├── branches/
│   ├── distributions/
│   └── capital/
└── l10n/                       # AR / EN ARB files
```

**Stack:** Flutter 3.10+ / Dart 3.10+, `go_router`, `flutter_bloc`, `get_it`, `dio`, `fpdart`, `fl_chart`, `pdf` / `printing` / `share_plus`, `liquid_glass_widgets`, `shimmer`.

---

## Local Setup

### Prerequisites

- Flutter SDK 3.10+
- Access to Odoo partner account with financial portal rights
- Firebase configured for mobile builds (optional for basic Odoo testing)

### Install & run

```bash
cd flutter_finance_portal
flutter pub get
flutter gen-l10n
flutter run              # device / emulator (recommended)
flutter run -d windows   # desktop
flutter run -d chrome    # web (CORS may block Odoo)
```

### Change Odoo target

Edit `lib/core/constants/constants.dart`:

- `odooBaseUrl`
- `odooDb`

### Build release APK

```bash
flutter build apk --release
```

---

## Coming Back After a Long Time

### 1. Remember what this app is

- **Partner/investor financial portal** for Vacansa — not DishFlow POS, not ecommerce admin.
- **Odoo-only backend** — if data is wrong, fix Odoo module/data first.
- **Financial partner gate** — normal Odoo users without partner flag get access denied.

### 2. Get running in 3 commands

```bash
cd flutter_finance_portal
flutter pub get && flutter gen-l10n
flutter run
```

Log in with an Odoo user that has financial partner access on `codesolutioneg-jouma`.

### 3. Key files to open first

| If you need to… | Open |
|-----------------|------|
| Change Odoo URL / DB | `lib/core/constants/constants.dart` |
| Add API endpoint | `lib/features/financial/data/datasources/financial_remote_datasource.dart` |
| Auth / session | `lib/features/auth/data/repositories/auth_repository_impl.dart`, `lib/core/network/odoo_client.dart` |
| Partner access gate | `lib/features/auth/presentation/cubit/auth_cubit.dart` |
| Date / branch filters | `lib/features/shell/presentation/cubit/filter_cubit.dart` |
| Navigation | `lib/core/router/app_router.dart` |
| Strings AR/EN | `lib/l10n/app_ar.arb`, `app_en.arb` → `flutter gen-l10n` |
| PDF reports | `lib/features/reports/data/financial_pdf_builder.dart` |

### 4. Git remote

```bash
git remote -v
# origin  https://github.com/ibrahim-atef/vicansa_finance.git
```

Push to **`main`** on that repo.

---

## Troubleshooting

| Symptom | Likely cause | What to check |
|---------|--------------|---------------|
| CORS error on web | Browser blocks Odoo cookies | Use Android/Windows, or upgrade Odoo module ≥ 18.0.1.4.0 |
| Access denied after login | User not financial partner | Odoo `partner-info` / partner flags |
| Empty dashboard | Wrong date range or no closed months | `FilterCubit`, `period-info` API |
| Session lost on restart (web) | Cookies not persisted | Expected on web; use mobile |
| No push notifications | Firebase not configured | `firebase_options.dart`, mobile only |
| Shimmer never ends | Odoo timeout / network | Connectivity, `OdooClient` logs |
| Arabic font wrong | Tajawal not loaded | `pubspec.yaml` fonts, `AppFonts` |

---

## Related Projects

| Path / repo | Description |
|-------------|-------------|
| `ibrahim-atef/vicansa_finance` | This app's GitHub remote |
| `juma_hub/dishflow-kingdom-multiresturant-dashboard` | DishFlow multi-restaurant admin (separate product) |
| `juma_hub/dishflow-kingdom-multiresturant-mobile` | DishFlow customer ecommerce app |
| `juma_hub/cai_` | DishFlow POS ecosystem (Odoo POS + Firebase) |

Odoo module source for financial APIs lives on the **codesolutioneg-jouma** Odoo instance / backend repo — not in this Flutter project.
