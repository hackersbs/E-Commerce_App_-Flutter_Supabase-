# E-commerce Flutter App


This is a Flutter e-commerce application with buyer and seller roles. Buyers
can browse products, search, manage a cart, checkout, and leave reviews.

## Technology

- Flutter for the user interface
- Provider for shared application state
- Supabase Auth for email and password authentication
- Supabase PostgreSQL for application data
- Supabase Row Level Security (RLS) for authorization
- `flutter_dotenv` for local Supabase configuration

Passwords are managed only by Supabase Auth and are never stored in the public
application tables.

## Project Structure

```text
lib/
	main.dart                          App startup and Provider setup
	models/
	  product.dart                     Product model and database conversion
	providers/
	  auth_provider.dart               Signup, login, logout, and session state
	  cart_provider.dart               Cart quantities, totals, and checkout
	  product_provider.dart            Product CRUD, stock, and reviews
	  theme_provider.dart              Light and dark theme state
	screen/
	  auth_screen.dart                 Login and signup screens
	  cart_screen.dart                 Buyer cart and checkout
	  home_screen.dart                 Buyer product browsing and search
	  product_detail_screen.dart       Product details, cart, and reviews
	  profile_screen.dart              User profile and logout
	  seller_home_screen.dart          Seller inventory management
	  settings_screen.dart              Theme settings
	widgets/
	  bottom_navigation.dart           Buyer bottom navigation
	  product_card.dart                Product list/grid item
	utils/
	  currency.dart                    Indian rupee formatting




The `screen` folder contains UI pages, `providers` contains shared state and
Supabase operations, `models` contains typed data objects, and `widgets`
contains reusable UI components. The `android` folder is the supported native
platform for this project.

## Packages

| Package | Why it is used |
| --- | --- |
| `provider` | Shares authentication, product, cart, and theme state between screens. |
| `supabase_flutter` | Connects the app to Supabase Auth, PostgreSQL, RPC functions, and RLS-protected APIs. |
| `flutter_dotenv` | Loads the Supabase URL and publishable key from the local `.env` file. |


## Configuration

Create `.env` in the project root using `.env.example`:

```env
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
```

The `.env` file is ignored by Git and must contain only the Supabase
publishable/anon key. Never use a Supabase service-role key in a Flutter app.

## Run the App

This project is configured for Android only. Install the Android SDK, connect
an Android device or start an Android emulator, then run:

```powershell
flutter pub get
flutter analyze lib
flutter devices
flutter run -d YOUR_ANDROID_DEVICE_ID
```

For a connected Android device, the device ID can be found with
`flutter devices`. Do not use the Windows runner for this project.

The `.env` file must exist before starting the app because it is loaded during
application startup.

## Application Flows

### Authentication

Signup creates a Supabase Auth user with profile metadata. A database trigger
creates the matching `profiles` row. Login loads the profile, products, and
buyer cart, then routes buyers and sellers to their respective screens.

### Cart and Stock

Cart changes use database RPC functions. `add_to_cart` locks the product row,
checks stock, reserves one unit, and updates the cart atomically.
`remove_from_cart` restores stock when a quantity is removed. `place_order`
creates the order and order items, then clears the cart without reducing stock
again.

### Seller and Buyer Permissions

RLS policies enforce ownership in the database. Sellers can modify only rows
where `seller_id = auth.uid()`. Buyers can manage only their own cart, orders,
and reviews. Authenticated users can view active products and reviews.

## Common Problems

- **Email is not confirmed:** confirm the email, disable confirmation for
	testing, or use the existing-user SQL helper.
- **Invalid credentials:** verify the email, password, and Supabase project.
- **Seller cannot add a product:** confirm the profile role is exactly `seller`
	and that the schema and RLS policies were applied.
- **Review RLS error:** run `supabase/fix_reviews_policy.sql`.
- **Products do not appear:** check authentication, active product rows, RLS,
	and the values in `.env`.
- **Stock does not change:** apply the latest migration containing the cart and
	checkout RPC functions.

## Security

- Keep RLS enabled in production.
- Use only the publishable/anon key in the client.
- Never commit a service-role key or raw password.
- Enforce ownership in SQL policies, not only in Flutter widgets.
- Use custom SMTP for production email delivery.

## Useful Commands

```powershell
flutter pub get
flutter analyze
flutter test
dart format lib
flutter devices
```
