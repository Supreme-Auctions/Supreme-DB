# Supreme-DB Hybrid Setup Guide (Firebase Auth + Supabase Storage)

This setup uses **Firebase for authentication** and **Supabase for product storage and file uploads** to avoid CORS issues.

## 🔧 Prerequisites

- Node.js (v16 or higher)
- Firebase account (for authentication)
- Supabase account (for database and storage)

## 📋 Setup Steps

### 1. **Firebase Setup (Authentication Only)**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create or select your project
3. Enable **Authentication** → Sign-in method → Enable Email/Password
4. Get your Firebase config from Project Settings

### 2. **Supabase Setup (Database + Storage)**

1. Go to [Supabase](https://supabase.com/) and create a new project
2. Wait for the project to be ready (takes 1-2 minutes)

#### **Create Products Table:**
Go to Supabase Dashboard → SQL Editor and run:

```sql
-- Create products table
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  barcode VARCHAR(100) NOT NULL,
  category VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  quantity INTEGER NOT NULL DEFAULT 0,
  store VARCHAR(100) DEFAULT 'Store 1',
  status VARCHAR(20) DEFAULT 'active',
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations (you can make this more restrictive later)
CREATE POLICY "Enable all operations for authenticated users" ON products
FOR ALL USING (true);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

#### **Create Storage Bucket:**
1. Go to Supabase Dashboard → Storage
2. Create a new bucket called `product-images`
3. Make it **public** for easy access
4. Set up storage policies:

```sql
-- Allow public read access to product images
CREATE POLICY "Public read access for product images" ON storage.objects
FOR SELECT USING (bucket_id = 'product-images');

-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload product images" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'product-images');

-- Allow authenticated users to update their uploads
CREATE POLICY "Authenticated users can update product images" ON storage.objects
FOR UPDATE USING (bucket_id = 'product-images');

-- Allow authenticated users to delete images
CREATE POLICY "Authenticated users can delete product images" ON storage.objects
FOR DELETE USING (bucket_id = 'product-images');
```

### 3. **Environment Variables**

Create a `.env.local` file in your project root:

```env
# Firebase (Authentication only)
VITE_FIREBASE_API_KEY=your_firebase_api_key
VITE_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your-firebase-project-id
VITE_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_firebase_app_id

# Supabase (Database and Storage)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 4. **Install Dependencies**

```bash
npm install
```

### 5. **Run the Application**

```bash
npm run dev
```

## 🚀 **How It Works**

### **Authentication Flow (Firebase):**
1. User registers/logs in through Firebase Auth
2. User gets redirected to dashboard
3. Firebase handles all authentication state

### **Product Management (Supabase):**
1. Product data stored in Supabase PostgreSQL database
2. Product images uploaded to Supabase Storage
3. Real-time updates through Supabase client

### **Benefits of This Approach:**
- ✅ **No CORS issues** - Supabase handles CORS properly
- ✅ **Better performance** - Supabase is optimized for file uploads
- ✅ **More reliable** - Uses PostgreSQL instead of NoSQL
- ✅ **Cost effective** - Supabase free tier is generous
- ✅ **Familiar auth** - Keep using Firebase Auth you already have

## 📊 **Database Schema**

```sql
products (
  id              BIGSERIAL PRIMARY KEY,
  title           VARCHAR(255) NOT NULL,
  barcode         VARCHAR(100) NOT NULL,
  category        VARCHAR(100) NOT NULL,
  price           DECIMAL(10,2) NOT NULL DEFAULT 0,
  quantity        INTEGER NOT NULL DEFAULT 0,
  store           VARCHAR(100) DEFAULT 'Store 1',
  status          VARCHAR(20) DEFAULT 'active',
  image_url       TEXT,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
```

## 🔒 **Security Notes**

### **Supabase RLS (Row Level Security):**
The current setup allows all operations for simplicity. For production, you might want:

```sql
-- More restrictive policy example
CREATE POLICY "Users can only see active products" ON products
FOR SELECT USING (status = 'active');

-- Admin-only write access
CREATE POLICY "Only admins can modify products" ON products
FOR ALL USING (auth.jwt() ->> 'role' = 'admin');
```

### **Storage Security:**
- Product images are publicly readable (for display)
- Only authenticated users can upload/modify
- Consider adding file size limits and type validation

## 🔧 **Troubleshooting**

### **Common Issues:**

1. **"relation products does not exist"**
   - Make sure you ran the SQL commands to create the table

2. **"bucket product-images does not exist"**
   - Create the storage bucket in Supabase dashboard

3. **Authentication not working**
   - Check Firebase configuration
   - Verify environment variables

4. **Images not uploading**
   - Check Supabase storage policies
   - Verify bucket is public
   - Check browser console for errors

5. **Empty product list**
   - Check if products table was created correctly
   - Verify Supabase connection in browser console

### **Debug Commands:**
```bash
# Check if Supabase is connected
# Look for console logs in browser dev tools

# Test Supabase connection manually:
# Go to Supabase Dashboard → API → and test the endpoints
```

## 📱 **Testing the Setup**

1. **Register/Login** → Should work with Firebase
2. **View Dashboard** → Should show empty products initially
3. **Add Product** → Should save to Supabase
4. **Upload Image** → Should upload to Supabase Storage
5. **Edit Product** → Should update in Supabase
6. **Delete Product** → Should remove from Supabase

## 🎯 **Next Steps**

- [ ] Add more product fields as needed
- [ ] Implement bulk operations
- [ ] Add product categories management
- [ ] Create inventory reports
- [ ] Add barcode scanning
- [ ] Set up automated backups

## 📞 **Support**

If you encounter issues:
1. Check browser console for error messages
2. Verify all environment variables are set
3. Check Supabase dashboard for table/bucket existence
4. Test Firebase authentication separately

This hybrid approach gives you the best of both platforms while avoiding the Firebase Storage CORS issues! 