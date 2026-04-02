# Requirements Document

## Introduction

Artiselle is a cross-platform mobile e-commerce application built with Flutter and Firebase that connects buyers with sellers of unique, handmade goods, clothing, books, and other niche products. The platform empowers small businesses, artisans, and independent authors by providing mobile tools to list and manage products, while giving buyers a seamless real-time shopping experience with secure checkout, order tracking, and push notifications. An admin console supports platform governance, user management, and category oversight.

## Glossary

- **Artiselle**: The mobile e-commerce platform being specified in this document.
- **App**: The Artiselle Flutter mobile application running on iOS and Android.
- **Buyer**: A registered user who browses, purchases, and reviews products on the platform.
- **Seller**: A registered user (artisan, craftsman, author, or small business) who lists and sells products on the platform.
- **Admin**: A privileged platform operator who manages users, categories, and platform health via the admin console.
- **Auth_Service**: The Firebase Authentication service responsible for user identity and session management.
- **Firestore**: The Firebase Cloud Firestore NoSQL database used for real-time data storage and synchronization.
- **Storage_Service**: The Firebase Cloud Storage service used for product image and media uploads.
- **Notification_Service**: The Firebase Cloud Messaging (FCM) service responsible for delivering push notifications.
- **Payment_Gateway**: The third-party payment processor (GCash or PayPal) used for secure checkout.
- **Product**: An item listed for sale by a Seller, including metadata such as title, description, price, category, images, and stock quantity.
- **Listing**: A published Product visible to Buyers on the platform.
- **Cart**: A temporary collection of Products a Buyer intends to purchase.
- **Order**: A confirmed purchase transaction between a Buyer and one or more Sellers.
- **Inventory**: The tracked stock quantity associated with a Product.
- **Shipment**: The physical dispatch of an Order, tracked by status updates from the Seller.
- **Review**: A Buyer-submitted rating and written feedback for a purchased Product.
- **Category**: A classification label (e.g., Handmade Goods, Clothing, Books) used to organize Products.
- **Admin_Console**: The privileged interface used by Admins to manage the platform.
- **Cache**: Locally stored data on the device used to support limited offline viewing.

---

## Requirements

### Requirement 1: User Registration and Authentication

**User Story:** As a new user, I want to register and log in to the app, so that I can access buyer or seller features securely.

#### Acceptance Criteria

1. WHEN a user submits a registration form with a valid email address and a password of at least 8 characters, THE Auth_Service SHALL create a new account and send an email verification link within 30 seconds.
2. WHEN a user submits a registration form with an email address already associated with an existing account, THE Auth_Service SHALL return an error message indicating the email is already in use.
3. WHEN a user submits a login form with valid credentials, THE Auth_Service SHALL authenticate the user and establish a session within 5 seconds.
4. WHEN a user submits a login form with invalid credentials, THE Auth_Service SHALL return an error message and SHALL NOT grant access to the account.
5. WHEN a user requests a password reset with a registered email address, THE Auth_Service SHALL send a password reset link to that email address within 30 seconds.
6. WHEN a user requests a password reset with an unregistered email address, THE Auth_Service SHALL return an error message indicating no account exists for that address.
7. THE Auth_Service SHALL support Google Sign-In as an alternative authentication method.
8. WHEN an authenticated session expires or is invalidated, THE App SHALL redirect the user to the login screen.
9. THE App SHALL allow a user to select an account role of either Buyer or Seller during registration.

---

### Requirement 2: Seller Profile and Store Management

**User Story:** As a Seller, I want to set up and manage my store profile, so that Buyers can discover my brand and products.

#### Acceptance Criteria

1. THE App SHALL allow a Seller to create a store profile containing a store name, description, profile image, and contact information.
2. WHEN a Seller submits a store profile update, THE Firestore SHALL persist the updated profile data within 3 seconds.
3. THE App SHALL display a Seller's store profile page to Buyers, showing the store name, description, profile image, and all active Listings.
4. WHEN a Seller uploads a profile image, THE Storage_Service SHALL store the image and return a publicly accessible URL within 10 seconds.
5. IF a Seller submits a store profile with a missing required field (store name or description), THEN THE App SHALL display a validation error and SHALL NOT submit the profile.

---

### Requirement 3: Product Listing Management

**User Story:** As a Seller, I want to create, edit, and remove product listings, so that I can showcase my inventory to Buyers.

#### Acceptance Criteria

1. THE App SHALL allow a Seller to create a Product with the following required fields: title, description, price, category, stock quantity, and at least one image.
2. WHEN a Seller publishes a new Product, THE Firestore SHALL make the Listing visible to Buyers in real-time within 2 seconds of publication.
3. WHEN a Seller updates a Product's price, description, or stock quantity, THE Firestore SHALL propagate the updated Listing to all connected Buyers within 2 seconds.
4. WHEN a Seller deletes a Product, THE App SHALL remove the Listing from Buyer-facing views within 2 seconds and SHALL retain the Order history associated with that Product.
5. THE App SHALL allow a Seller to upload up to 5 images per Product to the Storage_Service.
6. WHEN a Seller uploads a Product image, THE Storage_Service SHALL store the image and return a publicly accessible URL within 10 seconds.
7. IF a Seller submits a Product with a price less than or equal to zero, THEN THE App SHALL display a validation error and SHALL NOT create or update the Listing.
8. IF a Seller submits a Product with a stock quantity less than zero, THEN THE App SHALL display a validation error and SHALL NOT create or update the Listing.
9. THE App SHALL allow a Seller to assign a Product to exactly one Category from the list of Categories defined by the Admin.
10. THE App SHALL allow a Seller to toggle a Listing between active and inactive states without deleting the Product.

---

### Requirement 4: Real-Time Product Discovery and Search

**User Story:** As a Buyer, I want to browse and search for products in real-time, so that I can find unique items that match my interests.

#### Acceptance Criteria

1. THE App SHALL display a home feed of active Listings to Buyers, updated in real-time via Firestore listeners.
2. WHEN a Buyer submits a search query, THE App SHALL return matching Listings filtered by title and description within 3 seconds.
3. THE App SHALL allow a Buyer to filter Listings by Category.
4. THE App SHALL allow a Buyer to sort Listings by price (ascending and descending) and by date listed (newest first).
5. WHEN a Buyer views a Listing detail page, THE App SHALL display the Product title, description, price, available stock, Seller store name, and all Product images.
6. WHEN a Listing's stock quantity reaches zero, THE App SHALL display the Listing as out of stock and SHALL prevent the Buyer from adding it to the Cart.
7. WHILE a Buyer is viewing the home feed, THE App SHALL reflect any Seller-published Listing updates without requiring a manual page refresh.

---

### Requirement 5: Shopping Cart

**User Story:** As a Buyer, I want to manage a shopping cart, so that I can review and adjust my selections before purchasing.

#### Acceptance Criteria

1. THE App SHALL allow a Buyer to add a Product to the Cart from the Listing detail page.
2. WHEN a Buyer adds a Product to the Cart, THE App SHALL update the Cart item count indicator in the navigation bar immediately.
3. THE App SHALL allow a Buyer to update the quantity of a Cart item, subject to the available stock of the Product.
4. IF a Buyer attempts to set a Cart item quantity greater than the available stock, THEN THE App SHALL cap the quantity at the available stock value and display an informational message.
5. THE App SHALL allow a Buyer to remove individual items from the Cart.
6. THE App SHALL display the Cart subtotal, calculated as the sum of each Cart item's unit price multiplied by its quantity.
7. WHILE a Buyer has an active session, THE App SHALL persist the Cart contents across app restarts using local storage.
8. WHEN a Buyer proceeds to checkout, THE App SHALL validate that all Cart items remain in stock before initiating the payment flow.
9. IF any Cart item is out of stock at checkout time, THEN THE App SHALL notify the Buyer of the unavailable item and SHALL NOT proceed with payment until the item is removed.

---

### Requirement 6: Checkout and Payment Processing

**User Story:** As a Buyer, I want to securely check out using my preferred payment method, so that I can complete my purchase with confidence.

#### Acceptance Criteria

1. THE App SHALL present a checkout screen displaying the order summary, shipping address form, and payment method selection.
2. THE App SHALL support GCash and PayPal as payment methods via the Payment_Gateway.
3. WHEN a Buyer submits a checkout with a valid shipping address and payment method, THE Payment_Gateway SHALL process the payment and return a success or failure response within 30 seconds.
4. WHEN the Payment_Gateway returns a successful payment response, THE App SHALL create an Order record in Firestore and SHALL decrement the stock quantity of each purchased Product accordingly.
5. WHEN the Payment_Gateway returns a failed payment response, THE App SHALL display an error message and SHALL NOT create an Order record or modify stock quantities.
6. IF a Buyer submits a checkout with an incomplete shipping address, THEN THE App SHALL display a validation error and SHALL NOT initiate payment processing.
7. WHEN an Order is successfully created, THE Notification_Service SHALL send a push notification to the Buyer confirming the Order within 60 seconds.
8. WHEN an Order is successfully created, THE Notification_Service SHALL send a push notification to the Seller notifying them of the new Order within 60 seconds.
9. THE App SHALL display an order confirmation screen with the Order ID and summary upon successful checkout.

---

### Requirement 7: Order Management for Buyers

**User Story:** As a Buyer, I want to view and track my orders, so that I can monitor the status of my purchases.

#### Acceptance Criteria

1. THE App SHALL display a list of all Orders placed by the authenticated Buyer, sorted by date descending.
2. WHEN a Buyer selects an Order from the list, THE App SHALL display the Order detail screen showing the Order ID, items purchased, total amount, shipping address, payment method, and current shipment status.
3. WHILE an Order's shipment status is updated by the Seller, THE App SHALL reflect the updated status on the Buyer's Order detail screen in real-time via Firestore listeners.
4. WHEN a Seller updates an Order's shipment status, THE Notification_Service SHALL send a push notification to the Buyer with the new status within 60 seconds.

---

### Requirement 8: Order Management for Sellers

**User Story:** As a Seller, I want to view and manage incoming orders, so that I can fulfill purchases and keep Buyers informed.

#### Acceptance Criteria

1. THE App SHALL display a list of all Orders associated with the authenticated Seller's Products, sorted by date descending.
2. WHEN a Seller selects an Order, THE App SHALL display the Order detail screen showing the Buyer's shipping address, items ordered, quantities, and current shipment status.
3. THE App SHALL allow a Seller to update an Order's shipment status to one of the following values: Pending, Processing, Shipped, Delivered, or Cancelled.
4. WHEN a Seller updates a shipment status, THE Firestore SHALL persist the new status and trigger a real-time update to the Buyer's Order view within 2 seconds.
5. THE App SHALL display a summary of total sales revenue and order counts on the Seller's dashboard.

---

### Requirement 9: Sales Reporting for Sellers

**User Story:** As a Seller, I want to view sales reports, so that I can understand my business performance.

#### Acceptance Criteria

1. THE App SHALL display a sales report to the Seller showing total revenue, total orders, and top-selling Products for a selectable time period (last 7 days, last 30 days, all time).
2. WHEN a Seller selects a time period, THE App SHALL recalculate and display the sales metrics for that period within 3 seconds.
3. THE App SHALL display a per-Product breakdown showing units sold and revenue generated for each Product within the selected time period.

---

### Requirement 10: Product Reviews and Ratings

**User Story:** As a Buyer, I want to leave reviews and ratings for products I've purchased, so that I can share my experience with other Buyers.

#### Acceptance Criteria

1. THE App SHALL allow a Buyer to submit a Review for a Product only after the associated Order has a shipment status of Delivered.
2. WHEN a Buyer submits a Review, THE Firestore SHALL persist the Review containing a rating (integer from 1 to 5), written feedback text, and the Buyer's display name.
3. IF a Buyer attempts to submit a Review for a Product they have not purchased, THEN THE App SHALL display an error message and SHALL NOT persist the Review.
4. IF a Buyer attempts to submit a second Review for the same Product from the same Order, THEN THE App SHALL display an error message and SHALL NOT persist the duplicate Review.
5. THE App SHALL display the average rating and all Reviews for a Product on the Listing detail page.
6. WHEN a new Review is submitted, THE App SHALL recalculate and display the updated average rating on the Listing detail page within 3 seconds.

---

### Requirement 11: Push Notifications

**User Story:** As a user, I want to receive relevant push notifications, so that I can stay informed about my orders and store activity without actively checking the app.

#### Acceptance Criteria

1. THE Notification_Service SHALL deliver push notifications to Buyers for the following events: Order confirmed, shipment status updated.
2. THE Notification_Service SHALL deliver push notifications to Sellers for the following events: New Order received, new Review submitted on a Product.
3. WHEN a user taps a push notification, THE App SHALL navigate the user to the relevant Order or Product detail screen.
4. THE App SHALL allow a user to enable or disable push notifications from the account settings screen.
5. WHILE push notifications are disabled by the user, THE Notification_Service SHALL NOT deliver push notifications to that user's device.

---

### Requirement 12: Inventory Management

**User Story:** As a Seller, I want the inventory to update automatically when orders are placed, so that I don't oversell products.

#### Acceptance Criteria

1. WHEN an Order is successfully created, THE Firestore SHALL atomically decrement the stock quantity of each ordered Product by the purchased quantity within the same transaction.
2. IF the stock quantity of a Product reaches zero after an Order is created, THEN THE App SHALL mark the Listing as out of stock in real-time.
3. THE App SHALL allow a Seller to manually update the stock quantity of a Product at any time.
4. WHEN a Seller manually updates a stock quantity, THE Firestore SHALL persist the new value and propagate the change to all connected Buyers within 2 seconds.
5. IF two Buyers attempt to purchase the last unit of a Product concurrently, THEN THE Firestore SHALL use a transaction to ensure only one Order succeeds and the other Buyer receives an out-of-stock error.

---

### Requirement 13: Admin Console — User Management

**User Story:** As an Admin, I want to manage user accounts, so that I can maintain platform integrity and resolve disputes.

#### Acceptance Criteria

1. THE Admin_Console SHALL display a searchable list of all registered Buyers and Sellers.
2. THE Admin_Console SHALL allow an Admin to view the profile details of any registered user.
3. THE Admin_Console SHALL allow an Admin to suspend a user account, preventing the suspended user from logging in.
4. WHEN an Admin suspends a user account, THE Auth_Service SHALL invalidate any active sessions for that user within 60 seconds.
5. THE Admin_Console SHALL allow an Admin to reinstate a suspended user account.
6. THE Admin_Console SHALL allow an Admin to permanently delete a user account and all associated Listings and data.

---

### Requirement 14: Admin Console — Category Management

**User Story:** As an Admin, I want to manage product categories, so that the platform's taxonomy remains organized and relevant.

#### Acceptance Criteria

1. THE Admin_Console SHALL allow an Admin to create a new Category with a unique name and optional description.
2. WHEN a new Category is created, THE Firestore SHALL make it available for Sellers to assign to Products within 2 seconds.
3. THE Admin_Console SHALL allow an Admin to rename an existing Category.
4. WHEN a Category is renamed, THE App SHALL display the updated Category name on all associated Listings within 2 seconds.
5. THE Admin_Console SHALL allow an Admin to deactivate a Category, preventing Sellers from assigning new Products to it while retaining existing Listings in that Category.

---

### Requirement 15: Offline Support and Caching

**User Story:** As a Buyer, I want to view previously loaded content when offline, so that I can still browse the app without an active internet connection.

#### Acceptance Criteria

1. WHILE the device has no active internet connection, THE App SHALL display previously cached Listing data to the Buyer.
2. WHILE the device has no active internet connection, THE App SHALL display a visible indicator informing the user that the app is in offline mode.
3. WHILE the device has no active internet connection, THE App SHALL prevent Buyers from adding items to the Cart or initiating checkout, and SHALL display an informational message explaining the restriction.
4. WHEN the device regains an active internet connection, THE App SHALL automatically synchronize with Firestore and refresh displayed data within 5 seconds.
5. THE App SHALL NOT cache sensitive payment or authentication credential data on the device.
