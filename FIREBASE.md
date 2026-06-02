# Firebase (Vacansa app)

- **Project:** `vacanca-app`
- **Display name:** Vacansa app
- **Android package:** `com.codesolution.vacansa`
- **iOS bundle:** `com.codesolution.vacansa`

## FlutterFire CLI

If `flutterfire` is not found in Git Bash:

```bash
dart pub global activate flutterfire_cli
export PATH="$PATH:$HOME/AppData/Local/Pub/Cache/bin"
```

Re-configure:

```bash
cd I:/juma_hub/flutter_finance_portal
flutterfire configure --project=vacanca-app --platforms=android,ios,web --yes
```

## Enable Cloud Messaging

In [Firebase Console](https://console.firebase.google.com/project/vacanca-app) → **Build** → **Cloud Messaging**, ensure the API is enabled.

For iOS push: upload your APNs key in **Project settings** → **Cloud Messaging**.
