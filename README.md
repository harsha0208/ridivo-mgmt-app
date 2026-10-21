# Ridivo Event Management (Flutter)

Mobile app for on-site event staff. Uses **venue JWT** auth (`/api/v1/venue/...`), not the admin console login.

## Features by staff role

| Role | In this app |
|------|-------------|
| `checkin` | Ticket lookup, QR scan/validate, manual check-in |
| `timing` | Challenge ticket timing (start / finish / DNF) |
| `manager` | Check-in + timing |
| `seller` | **Blocked** — use ridivo-admin for sell/upgrade |

API role gates on `/venue/events/{eventId}/...` still apply.

## Run

```bash
# From event_management/
make get
make run                 # auto-picks physical iPhone (no device prompt)
make run-ios             # same preference: phone → simulator
make run DEVICE=<id>     # pin a device from `make devices`
make run ENV=android     # Android emulator → 10.0.2.2:8080
make run ENV=network     # remote api-dev
make help
```

Uses FVM when available (`fvm flutter`); otherwise `flutter` on PATH.
Default `API_BASE_URL` is `http://localhost:8080/api/v1`.

Prefer a **physical iPhone** for QR scan — `mobile_scanner` / Google ML Kit do not ship
arm64 for Apple Silicon iOS simulators.

## Auth flow

1. `POST /venue/auth/login` with event staff email/password (must have ≥1 active assignment)
2. Pick event from the app bar dropdown when assigned to multiple events
3. Tabs shown from the selected event’s role

## Project layout

```
lib/
  core/          env, dio, venue API, session, riverpod providers
  features/
    auth/        login
    home/        shell + seller blocked state
    checkin/     lookup + scan + check-in
    timing/      challenge timing
```

State management: **Riverpod** (`flutter_riverpod`) — see `lib/core/di/providers.dart`.

Package: `event_management` · Android applicationId: `com.ridivo.event_management`.
