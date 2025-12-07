# Supabase Registration and Login App

A Flutter app with registration and login forms connected to Supabase database.

## Setup Instructions

### 1. Clone or Setup Supabase

1. Go to [Supabase](https://supabase.com/) and create an account
2. Create a new project
3. Copy your **Project URL** and **Anon Key** from the API settings

### 2. Update Configuration

In `lib/main.dart`, replace the placeholder values:

```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Create Database Tables

Run the following SQL queries in Supabase SQL Editor:

```sql
-- Create profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  email TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to read their own profile
CREATE POLICY "Users can view their own profile"
  ON profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Create policy to allow users to insert their own profile
CREATE POLICY "Users can insert their own profile"
  ON profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Create policy to allow users to update their own profile
CREATE POLICY "Users can update their own profile"
  ON profiles
  FOR UPDATE
  USING (auth.uid() = id);
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

## Features

- **User Registration**: Create a new account with email and password
- **User Login**: Sign in with registered credentials
- **Protected Routes**: Access to home screen only after authentication
- **User Profile**: Display user information after login
- **Logout**: Secure logout functionality
- **Error Handling**: Proper error messages for auth failures

## App Flow

1. **AuthScreen** - Initial screen that toggles between Login and Register
2. **LoginScreen** - Email/password login form
3. **RegisterScreen** - Registration form with name, email, and password
4. **HomeScreen** - Protected screen showing welcome message and user profile

## Dependencies

- `supabase_flutter: ^2.5.0` - Supabase Flutter SDK
- `flutter` - Flutter framework

## File Structure

```
lib/
├── main.dart              # App entry point and Supabase initialization
└── screens/
    ├── auth_screen.dart   # Auth toggle screen
    ├── login_screen.dart  # Login form
    ├── register_screen.dart # Registration form
    └── home_screen.dart   # Home/Dashboard screen
```

## Notes

- Make sure to enable Email/Password authentication in Supabase Authentication settings
- The app uses Row Level Security (RLS) for database security
- User sessions are maintained automatically by Supabase
