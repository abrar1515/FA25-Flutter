# Full Setup & Run Instructions

This document contains complete, step-by-step instructions for setting up and running the `crud_supabase` Flutter project on your machine and configuring Supabase for the backend.

Follow sections in order. Commands are provided for PowerShell (Windows).

---

## 0. Prerequisites

- Flutter SDK (3.9.2 or later recommended)
- Dart SDK (comes with Flutter)
- Git
- An IDE (VS Code or Android Studio) or a code editor
- A Supabase account (https://supabase.com)
- A device or emulator to run the app (Android/iOS/Windows/etc.)

Verify Flutter installation:

```powershell
flutter --version
```

Check connected devices:

```powershell
flutter devices
```

---

## 1. Clone or open the project

If you already have the project folder, open it in your IDE. Otherwise clone from your repo:

```powershell
git clone <your-repo-url> c:\Users\abrar\Desktop\flutter\crud_supabase
cd c:\Users\abrar\Desktop\flutter\crud_supabase
```

---

## 2. Install Dart/Flutter dependencies

From project root run:

```powershell
flutter pub get
```

This installs packages declared in `pubspec.yaml` (including `supabase_flutter`, `http`, and `intl`).

---

## 3. Configure Supabase (Project + Database)

1. Sign in to supabase.com and create a new project.
2. Open the project and go to **SQL Editor** to run SQL scripts below.

### 3.1 Enable `pgcrypto` for UUID generation

If you want to use `gen_random_uuid()` you need the `pgcrypto` extension:

```sql
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

Run this in the SQL editor once.

### 3.2 Create `items` table

Run the following SQL in Supabase SQL Editor:

```sql
CREATE TABLE items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  price NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

Notes:
- `created_at` and `updated_at` can be managed by triggers if desired.

### 3.3 (Optional) Add RLS policies for demo (public)

For development/demo only — these policies grant public access. For production, implement user-based policies instead.

```sql
-- Enable RLS on items
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- Allow public selects
CREATE POLICY "Enable read access for all users" ON items
FOR SELECT USING (true);

-- Allow public inserts
CREATE POLICY "Enable insert for all users" ON items
FOR INSERT WITH CHECK (true);

-- Allow public updates
CREATE POLICY "Enable update for all users" ON items
FOR UPDATE USING (true);

-- Allow public deletes
CREATE POLICY "Enable delete for all users" ON items
FOR DELETE USING (true);
```

Run these only if you understand the security implications.

---

## 4. Get Supabase credentials

1. In Supabase dashboard go to **Project Settings → API**.
2. Copy:
   - `Project URL` (looks like `https://<project-id>.supabase.co`)
   - `anon` public key (Anon Key)

You will use these in your app configuration.

---

## 5. Configure the Flutter app with Supabase credentials

There are two recommended options. Option A is quick (edit `supabase_service.dart`), Option B is secure using environment variables and `flutter_dotenv`.

### Option A — Quick (Edit service directly)

Edit `lib/services/supabase_service.dart` and replace placeholders:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Example (do NOT commit real keys):

```dart
static const String supabaseUrl = 'https://abcd1234.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOi...';
```

After replacing, save the file.

### Option B — Secure (Use `.env` and `flutter_dotenv`)

1. Add `flutter_dotenv` to `pubspec.yaml` (if not already):

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. Run:

```powershell
flutter pub get
```

3. Create a `.env` file at project root (do NOT commit `.env`):

```
SUPABASE_URL=https://abcd1234.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
```

4. Update `.gitignore` to ensure `.env` is ignored (project already contains `.env.example`).

5. Update `lib/config/app_config.dart` to read from dotenv, or update `lib/services/supabase_service.dart` to use the `dotenv` values. Example `app_config.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
```

6. Initialize dotenv before Supabase in `lib/main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.initialize();
  runApp(const MyApp());
}
```

7. Make sure `SupabaseService.initialize()` reads the values from `AppConfig` or from `dotenv` directly.

---

## 6. Run the app

Run on the device or emulator. In PowerShell:

```powershell
# Get packages (if not done already)
flutter pub get

# Run on connected device
flutter run

# Or run on a specific device (example Android emulator)
flutter run -d emulator-5554
```

Build release artifacts:

```powershell
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle

# iOS (run from macOS with Xcode)
flutter build ios
```

---

## 7. Test CRUD operations

- Open the app and create a test item using the `+` button.
- Confirm the item appears in the list and in the Supabase table (Table Editor in Supabase Dashboard).
- Edit the item and verify updates.
- Delete the item and verify it was removed.

If operations fail, see Troubleshooting below.

---

## 8. Troubleshooting

### "Failed to connect"
- Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` are correct.
- Make sure you used the `anon` key (not the service_role key) in client apps.
- In Supabase Project → Settings → API check the URL.

### "Table not found"
- Confirm the `items` table exists in your Supabase project.
- Confirm you are connected to the correct project (URL).

### "401 Unauthorized"
- Check the Anon Key is correct and not expired.
- Ensure you are not using service_role key in the client.

### Null or parsing errors
- Ensure column names (`name`, `description`, `price`, etc.) match what the app expects.
- Ensure numeric fields like `price` contain only numbers.

### RLS / Permission issues
- If Row Level Security (RLS) is enabled, ensure appropriate policies are present.
- For initial testing you can enable permissive policies (see section 3.3), but remove them for production.

---

## 9. Production and Security Notes

- Never commit keys into git. Use `.env` and CI secrets.
- Do not enable wide-open RLS policies on production.
- Use Supabase Auth + RLS to restrict access to user-owned rows.
- Rotate keys if they are accidentally exposed.

---

## 10. Useful SQL snippets

Trigger to update `updated_at` on change (optional):

```sql
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_updated_at
BEFORE UPDATE ON items
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## 11. Running SQL from command line (psql)

If you have direct DB access or use `psql`, you can run scripts locally. Supabase provides connection details in the Project → Settings → Database.

Example using psql (replace placeholders):

```powershell
psql "postgresql://postgres:YOUR_DB_PASSWORD@db.abcdef.us-east-1.rds.amazonaws.com:5432/postgres" -f ./scripts/create_tables.sql
```

Most users will use the Supabase SQL editor in the dashboard instead.

---

## 12. Additional notes & references

- See `API_REQUESTS.md` for example curl commands that mirror what the app does.
- Use `QUICKSTART.md` for a smaller checklist if you prefer.
- See `ADVANCED_CONFIG.md` for production-ready recommendations.

---

## 13. Quick checklist (copy/paste)

```powershell
# From repo root
flutter pub get
# Add .env file with SUPABASE_URL and SUPABASE_ANON_KEY
# If using dotenv, ensure it's loaded in main.dart
flutter run
```

---

If you'd like, I can also:
- Add this content into the existing `SETUP.md` (overwrite/update) or
- Add a `db/` folder with `rls_policies.sql` and `schema.sql` files and commit them.

Which would you prefer? (update existing `SETUP.md` OR create `db/` SQL files and add `.sql` files)