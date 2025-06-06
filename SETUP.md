# Supreme-DB Setup Guide

This is a Vue 3 product inventory application with Firebase backend integration.

## Prerequisites

- Node.js (v16 or higher)
- npm or yarn
- Firebase account (for authentication)
- Supabase account (for database and storage)

## Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Firebase Setup:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use existing one
   - Enable Authentication (Email/Password, Google, Twitter)
   - Enable Firestore Database
   - Enable Storage
   - Get your Firebase configuration

3. **Supabase Setup:**
   - Go to [Supabase](https://supabase.com/)
   - Create a new project
   - Go to Settings > API to get your project URL and anon key
   - Create the required database tables (see Database Setup section below)

4. **Environment Variables:**
   Create a `.env.local` file in the root directory with your configuration:
   ```
   # Firebase (Authentication only)
   VITE_FIREBASE_API_KEY=your_api_key_here
   VITE_FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
   VITE_FIREBASE_PROJECT_ID=your_project_id
   VITE_FIREBASE_STORAGE_BUCKET=your_project_id.appspot.com
   VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   VITE_FIREBASE_APP_ID=your_app_id

   # Supabase (Database and Storage)
   VITE_SUPABASE_URL=your_supabase_project_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

5. **Database Setup:**
   
   Run the provided SQL scripts in your Supabase SQL Editor:
   
   **a) Products Table:**
   ```sql
   CREATE TABLE IF NOT EXISTS products (
     id BIGSERIAL PRIMARY KEY,
     title TEXT NOT NULL,
     barcode TEXT NOT NULL,
     category TEXT NOT NULL,
     price DECIMAL(10,2) NOT NULL,
     quantity INTEGER NOT NULL,
     store TEXT DEFAULT 'Store 1',
     status TEXT DEFAULT 'active' CHECK (status IN ('active', 'deactive')),
     image_url TEXT,
     created_at TIMESTAMPTZ DEFAULT NOW(),
     updated_at TIMESTAMPTZ DEFAULT NOW()
   );
   ```
   
   **b) Users Table (for admin user management):**
   ```sql
   -- Run the complete script from supabase-users-setup.sql file
   -- This creates the users table with proper indexes and security policies
   ```
   
   **c) Categories Table (for product category management):**
   ```sql
   -- Run the complete script from supabase-categories-setup.sql file
   -- This creates the categories table with default categories
   ```
   
   **d) Create your first admin user:**
   After creating a user through Firebase Auth, add them to the users table:
   ```sql
   INSERT INTO users (firebase_uid, email, display_name, role, status) 
   VALUES ('your_firebase_uid', 'admin@yourcompany.com', 'Admin User', 'admin', 'active');
   ```

6. **Storage Setup:**
   - In Supabase, go to Storage
   - Create a new bucket called `product-images`
   - Set the bucket to Public
   - Update bucket policies as needed

7. **Firebase Firestore Rules:**
   Update your Firestore security rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Allow authenticated users to read/write products
       match /products/{document} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

5. **Firebase Storage Rules:**
   Update your Storage security rules:
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /products/{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

## Running the Application

1. **Development server:**
   ```bash
   npm run dev
   ```

2. **Build for production:**
   ```bash
   npm run build
   ```

3. **Preview production build:**
   ```bash
   npm run preview
   ```

## Features

### 🔐 Authentication
- Email/Password login for authorized users
- Admin-controlled user management
- Automatic redirect to dashboard after login
- Protected routes with authentication guards

### 👥 User Management (Admin Settings)
- **Role-based Access Control:**
  - **Admin**: Full access to all features including user management and product deletion
  - **Lister**: Can add and edit stock (cannot delete products or manage users)
  - **User**: Can view stock only (read-only access)

- **User Administration:**
  - Create new users with assigned roles
  - Edit user information and roles
  - Activate/deactivate user accounts
  - Delete users (except current user)
  - Search and filter users
  - Comprehensive user audit trail

- **Category Management:**
  - Create, edit, and delete product categories
  - Default categories included (Electronics, Clothing, Books, etc.)
  - Dropdown category selection in product forms
  - Admin-only category management

- **Features:**
  - Secure user creation through Firebase Auth
  - Role-based badges and indicators
  - User status management
  - Display name and email management
  - Password reset functionality (requires backend implementation)

### 📊 Dashboard
- Modern dark-themed UI matching the design
- Real-time statistics cards:
  - Total Products
  - New Products (last week)
  - Active Products
  - Empty Products (no stock)

### 📦 Product Management
- **Product Fields:**
  - Image upload with preview
  - Title
  - Price
  - Barcode
  - Quantity
  - Category
  - Store assignment
  - Status (Active/Deactive)

- **Features:**
  - Add new products with image upload
  - Edit existing products
  - Delete products with confirmation
  - Search products by title, barcode, or category
  - Responsive table view
  - Checkbox selection for bulk operations
  - Real-time Firebase sync

### 🔍 Search & Filter
- Real-time search across all product fields
- Filter by status (All/Active/Sold)
- Responsive design for mobile devices

## Project Structure

```
src/
├── components/
│   ├── LoginForm.vue          # Authentication login form
│   └── ProductDashboard.vue   # Main inventory dashboard with user management
├── router/
│   └── index.js              # Vue Router configuration
├── firebase.js               # Firebase configuration (authentication)
├── supabase.js               # Supabase configuration (database & storage)
├── main.js                   # App entry point
└── App.vue                   # Root component

database/
├── supabase-users-setup.sql      # SQL script to create users table
├── supabase-categories-setup.sql # SQL script to create categories table

public/
├── images/
│   └── images.png (main logo)
└── index.html
```

## Troubleshooting

### Common Issues

1. **Firebase Configuration Error:**
   - Ensure all environment variables are set correctly
   - Check that your Firebase project has the required services enabled

2. **Authentication Issues:**
   - Verify that Authentication is enabled in Firebase Console
   - Check that the correct sign-in methods are enabled

3. **Image Upload Issues:**
   - Ensure Firebase Storage is enabled
   - Check Storage security rules allow authenticated users

4. **Database Permissions:**
   - Verify Supabase RLS policies are configured correctly
   - Check that the user is properly authenticated
   - Ensure the users table exists and has proper permissions

5. **User Management Issues:**
   - Verify the users table was created using the provided SQL script
   - Check that Firebase Auth and Supabase are both configured correctly
   - Ensure the current user has admin role for accessing Settings
   - For password reset functionality, backend implementation is required

### Support

For issues or questions, please check:
- Firebase Console for service status
- Browser console for error messages
- Network tab for failed requests

## Next Steps

After setup, you can:
1. Customize the branding and colors
2. Add more product fields as needed
3. Implement bulk operations
4. Add inventory tracking features
5. Create reports and analytics
6. Add barcode scanning functionality

The application is designed to be easily extensible and customizable for your specific inventory needs. 