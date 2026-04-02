# Artiselle

A cross-platform mobile e-commerce app built with Flutter and Firebase that connects buyers with sellers of handmade goods, clothing, books, and other niche products.

## Overview

Artiselle empowers small businesses, artisans, and independent authors with mobile tools to list and manage products, while giving buyers a seamless real-time shopping experience with secure checkout, order tracking, and push notifications.

## Features

- **Authentication** — Email/password and Google Sign-In, with buyer/seller role selection at registration
- **Seller Storefront** — Store profile setup, product listing management (create, edit, toggle active/inactive, delete)
- **Product Discovery** — Real-time home feed, search by title/description, filter by category, sort by price or date
- **Shopping Cart** — Persistent cart with stock validation, quantity controls, and subtotal calculation
- **Checkout & Payments** — GCash and PayPal support via payment gateway, order confirmation with push notification
- **Order Tracking** — Real-time shipment status updates for buyers; order fulfillment tools for sellers
- **Reviews & Ratings** — Verified purchase reviews with star ratings and average score display
- **Sales Reporting** — Revenue, order counts, and per-product breakdowns for sellers (7 days / 30 days / all time)
- **Inventory Management** — Atomic stock decrements on order creation, concurrent purchase protection
- **Push Notifications** — FCM-powered alerts for order events, shipment updates, and new reviews
- **Admin Console** — User management (suspend/reinstate/delete) and category management
- **Offline Support** — Cached listing data with offline mode indicator and auto-sync on reconnect

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Framework | Flutter (Dart) |
| Authentication | Firebase Authentication |
| Database | Firebase Cloud Firestore |
| File Storage | Firebase Cloud Storage |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Payments | GCash / PayPal |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.11.0`)
- Firebase project with Authentication, Firestore, Storage, and FCM enabled
- Android Studio or Xcode for device/emulator setup

### Installation

```bash
# Clone the repo
git clone https://github.com/Vighead-BREH/Artiselle-Mobile-Application.git
cd Artiselle-Mobile-Application/artiselle

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android and iOS apps to the project
3. Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in their respective directories
4. Enable Email/Password and Google Sign-In in Firebase Authentication
5. Set up Firestore and Storage with appropriate security rules

## Project Structure

```
lib/
├── main.dart          # App entry point
├── models/            # Data models (Product, Order, Review, etc.)
├── screens/           # UI screens by feature
├── services/          # Firebase service abstractions
└── widgets/           # Shared UI components
```

## Branch Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable production-ready code |
| `develop` | Active development and integration |

## License

Private — all rights reserved.
