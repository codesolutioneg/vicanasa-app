# Odoo Partner Financial Portal — Cursor Agent Prompt

Copy everything below into a **new Cursor chat** opened on:

`I:\juma_hub\juma_odoo\jouma\partner_financial_portal`

Goal: keep the Odoo module as the **single source of truth** for the Vacansa Flutter app (`I:\juma_hub\flutter_finance_portal`). The mobile app must show the **same labels, numbers, ratios, charts, and drill-downs** as the web portal at `/my/financial`.

---

## Context

- **Module path:** `juma_odoo/jouma/partner_financial_portal`
- **Web UI:** `views/portal_templates.xml` (`portal_financial_dashboard`), styles in `static/src/css/portal_style.css`, charts in `static/src/js/portal_dashboard.js`
- **Business logic:** `models/res_partner.py` → `get_financial_data()`, permissions via `get_analytic_permission()`
- **HTTP/JSON:** `controllers/portal.py`

The Flutter app already calls these JSON routes (Phase 0 — verify they exist and work):

| Route | Purpose |
|-------|---------|
| `POST /my/financial/api/data` | Dashboard KPIs, grouped revenue/cost/expense, monthly_data, capital/distribution balances |
| `POST /my/financial/api/pnl` | P&L statement |
| `POST /my/financial/api/comparison` | Year comparison |
| `POST /my/financial/api/growth` | Growth analytics |
| `GET /my/financial/api/account-details` | Account transaction drill-down |
| `POST /my/financial/api/partner-info` | Partner name, avatar, branch list + share % |
| `POST /my/financial/api/period-info` | Last closed period for date capping |
| `POST /my/financial/api/branches` | Branch performance |
| `POST /my/financial/api/distributions` | Profit distributions history |
| `POST /my/financial/api/capital` | Capital balance history |
| Report download routes | Excel/PDF as on web |

---

## Required Odoo changes (if not already merged)

### 1. Enrich `/my/financial/api/data` to match web dashboard page

In `get_financial_api_data()` (`controllers/portal.py` ~line 952), after `partner.get_financial_data(...)`, add the same computed fields the **HTML dashboard** builds in `portal_financial_dashboard` (~lines 109–189):

```python
# After data = partner.get_financial_data(...)

monthly_data = self._get_monthly_breakdown_for_range(
    partner, date_from, date_to, selected_analytic_id
)
data['monthly_chart'] = monthly_data  # {months, revenue, cost, profit} for charts

total_revenue = data.get('revenue', 0) or 0
total_cost = (data.get('cost', 0) or 0) + (data.get('expense', 0) or 0)
gross_profit = total_revenue - total_cost
partner_share = data.get('partner_share', 0) or 0

if gross_profit >= 0:
    company_share = gross_profit - partner_share
    data['profit_distribution'] = {
        'your_share': round(abs(partner_share), 2),
        'company_share': round(abs(company_share), 2),
        'total_profit': round(gross_profit, 2),
        'is_loss': False,
    }
else:
    partner_loss = abs(partner_share)
    total_loss = abs(gross_profit)
    company_loss = total_loss - partner_loss
    data['profit_distribution'] = {
        'your_share': round(partner_loss, 2),
        'company_share': round(company_loss, 2),
        'total_profit': round(total_loss, 2),
        'is_loss': True,
    }

# Branch dropdown options with per-branch net + branch_share (same SQL as portal_financial_dashboard)
# Append: data['analytic_options'] = [...]
```

**Why:** Flutter currently recomputes profit pie and ratios client-side; server-side parity avoids drift.

### 2. Ensure grouped payloads include drill-down fields

`get_financial_data()` must return for each group in `revenue_grouped`, `cost_grouped`, `expense_grouped`:

- `group_id`, `group_code`, `group_name`, `total_amount`
- `accounts[]` with `account_id`, `code`, `name`, `amount`

Respect `analysis_level` + `allowed_group_ids` (already appended in API).

### 3. Date capping (closed period)

Mirror web behavior in API:

- `_get_last_closed_period()`, `_cap_date_range()` on all JSON endpoints that accept `date_from` / `date_to`
- Return `data_capped`, `closed_end`, `closed_display_text` on `/api/data` (already present — keep consistent)

### 4. P&L / Comparison / Growth APIs

Confirm `/my/financial/api/pnl`, `/api/comparison`, `/api/growth` return the **same structure** as the values dict passed to:

- `portal_pnl_statement`
- `portal_year_comparison`
- `portal_growth_analytics`

Include `analytic_options`, `share_percentage`, branch share rows, and grouped account trees where the web template shows them.

### 5. CORS / session (if Flutter web hits Odoo directly)

- JSON routes: `type='json', auth='user'`
- Website session cookie must work with `withCredentials` on web
- Document any required `session_id` or reverse-proxy headers for staging

### 6. Error responses

Return JSON `{'error': '...'}` with clear messages (not HTML 503 pages) when:

- User is not `is_financial_partner`
- Permission denied for analytics level
- Invalid `analytic_id`

---

## Dashboard field parity checklist (web → API → Flutter)

| Web label | API key | Notes |
|-----------|---------|-------|
| TOTAL REVENUE | `revenue` + `revenue_grouped[]` breakdown | First group = Sales, second = Other Income |
| TOTAL DEDUCTIONS | `cost` + `expense` | Show Costs / Expenses sub-lines |
| COMPANY NET PROFIT | `net_profit` | |
| YOUR PROFIT SHARE | `partner_share` | |
| CAPITAL BALANCE | `capital_balance` | Show section if capital ≠ 0 OR distribution ≠ 0 |
| DISTRIBUTIONS | `distribution_balance` | |
| EXPENSE TO REVENUE % | `expense / sales * 100` | **sales** = first `revenue_grouped[0].total_amount` |
| COST OF SALES % | `cost / sales * 100` | |
| OTHER INCOME % | `revenue_grouped[1] / sales * 100` | |
| COMPANY PROFIT MARGIN % | `net_profit / sales * 100` | |
| YOUR PROFIT MARGIN % | `partner_share / sales * 100` | 2 decimal places on web |
| Monthly trend chart | `monthly_data` or `monthly_chart` | revenue, cost, profit per month |
| Profit distribution pie | `profit_distribution` | your_share, company_share, is_loss |
| Financial summary table | revenue, cost, gross_profit, expense, net_profit, partner_share | |
| Year comparison chart | comparison API | Full year bars |
| Branch selector | `analytic_options` | id, name, share_percentage, branch_share |
| Sidebar partner + branch % | partner-info API | |

**Number format on web:** `'{:,.2f}'.format(value)` — full amount, **never** abbreviated (no 55.1M). Flutter uses `AppFormatters.money()` the same way.

---

## Files to touch in Odoo (typical)

1. `controllers/portal.py` — API enrichment, shared helpers
2. `models/res_partner.py` — only if grouped/monthly data is incomplete
3. `views/portal_templates.xml` — reference only unless adding new fields
4. `__manifest__.py` — bump version after changes
5. Upgrade module on Odoo.sh / staging: Apps → Partner Financial Portal → Upgrade

---

## Verification steps

1. Log in as financial partner on web → `/my/financial` — note date range, branch, all KPI values.
2. Call JSON-RPC `call_kw` or POST `/my/financial/api/data` with same `date_from`, `date_to`, `analytic_id`.
3. Compare every field in the checklist above.
4. Run Flutter app (`flutter_finance_portal`) with same filters — numbers must match exactly (to 2 decimals).
5. Test drill-down: tap Revenue / Deductions → account rows → account-details API.
6. Test P&L, Comparison, Growth, Reports download, Distributions, Capital pages.

---

## What Flutter already implemented (do not break)

Path: `I:\juma_hub\flutter_finance_portal`

- `lib/core/utils/app_formatters.dart` — full `#,##0.00` formatting
- `lib/features/dashboard/presentation/widgets/*` — main KPIs, balance cards, ratios, charts, summary, grouped sheets
- `lib/features/shell/presentation/widgets/date_filter_bar.dart` — FROM/TO + Apply + quick filters
- Odoo base URL in `lib/core/constants/constants.dart`

If you add `profit_distribution` or `monthly_chart` to the API, tell the Flutter agent to prefer server values over client-side computation.

---

## Prompt one-liner for the agent

> In `partner_financial_portal`, align all `/my/financial/api/*` JSON responses with the web portal dashboard (`portal_financial_dashboard` in `portal_templates.xml` and `portal_dashboard.js`). Add `profit_distribution`, `monthly_chart` (range breakdown), and `analytic_options` to `/my/financial/api/data`. Ensure grouped revenue/cost/expense include `accounts[]` for drill-down. Keep closed-period capping and permission fields. Document any new keys. Bump manifest version and verify with a financial partner user that mobile Flutter can consume the same numbers as the web UI without abbreviation.
