# Troubleshooting Firebase Storage CORS Error

## 🚨 **Firebase Storage CORS Error Fix**

If you're seeing this error:
```
Access to XMLHttpRequest at 'https://firebasestorage.googleapis.com/...' has been blocked by CORS policy
```

### **Solution Steps:**

### 1. **Check Firebase Storage Rules**
Go to Firebase Console → Storage → Rules and update to:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      // Allow read access to all files
      allow read: if true;
      
      // Allow write access only to authenticated users
      allow write: if request.auth != null;
    }
  }
}
```

### 2. **Verify Firebase Project Setup**
Make sure your Firebase project has:
- ✅ **Storage enabled** (not just Firestore)
- ✅ **Authentication enabled** with Email/Password provider
- ✅ **Correct project ID** in your environment variables

### 3. **Check Environment Variables**
Verify your `.env.local` file has the correct values:
```env
VITE_FIREBASE_API_KEY=your_actual_api_key
VITE_FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your-project-id
VITE_FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
```

### 4. **Initialize Storage Bucket**
If you just created the project, you need to initialize Storage:
1. Go to Firebase Console → Storage
2. Click "Get Started"
3. Choose your storage location (can't be changed later)
4. Accept the default rules (we'll update them)

### 5. **Test Authentication First**
Before testing image upload, make sure authentication works:
1. Try logging in/registering
2. Check browser console for auth errors
3. Verify you see the dashboard after login

### 6. **Alternative Storage Rules (More Permissive)**
If still having issues, try these temporary rules for testing:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;  // ⚠️ WARNING: Only for testing!
    }
  }
}
```

**⚠️ Important:** Change back to secure rules after testing!

### 7. **Check Firebase Project Quotas**
- Go to Firebase Console → Usage tab
- Make sure you haven't exceeded free tier limits
- Storage: 5GB free
- Downloads: 1GB/day free

---

## 🔧 **Other Common Issues**

### **Authentication Not Working**
```javascript
// Add this to check auth state in ProductDashboard.vue
onMounted(() => {
  // Check if user is authenticated
  if (!auth.currentUser) {
    console.log('User not authenticated');
    router.push('/');
    return;
  }
  console.log('Current user:', auth.currentUser.email);
  loadProducts();
});
```

### **Firestore Permission Denied**
Update Firestore rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### **Images Not Displaying**
1. Check if image URLs are generated correctly
2. Verify Storage rules allow read access
3. Test image URL directly in browser

### **Build/Development Issues**
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install

# Or try with Yarn
rm -rf node_modules yarn.lock
yarn install
```

---

## 🔍 **Debugging Steps**

### **1. Check Browser Console**
Look for specific error messages:
- Authentication errors
- Network failures
- Permission denied

### **2. Test Firebase Services Individually**

**Test Authentication:**
```javascript
// Add to ProductDashboard.vue setup()
console.log('Auth object:', auth);
console.log('Current user:', auth.currentUser);
```

**Test Storage Access:**
```javascript
// Add to handleImageUpload function
console.log('Storage object:', storage);
console.log('File to upload:', file);
```

**Test Firestore Access:**
```javascript
// Add to loadProducts function
console.log('Database object:', db);
```

### **3. Network Tab Inspection**
1. Open Browser Dev Tools → Network tab
2. Try uploading an image
3. Look for failed requests
4. Check response status codes

---

## 🚀 **Quick Fix Commands**

```bash
# Restart dev server
npm run dev

# Clear browser cache
# Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)

# Check Firebase CLI (if using)
firebase --version
firebase login
firebase use --add
```

---

## 📞 **Still Having Issues?**

1. **Check Firebase Status**: https://status.firebase.google.com/
2. **Verify Project Settings**: Firebase Console → Project Settings
3. **Test with Simple Upload**: Try uploading without the app first
4. **Check Billing**: Some features require Blaze plan

### **Emergency Fallback (No Images)**
If you need to test without images temporarily, modify ProductDashboard.vue:

```javascript
// Comment out image upload in addProduct function
const addProduct = async () => {
  loading.value = true
  try {
    // let imageUrl = ''
    // if (newProduct.value.imageFile) {
    //   const fileName = `${Date.now()}_${newProduct.value.imageFile.name}`
    //   imageUrl = await uploadImage(newProduct.value.imageFile, fileName)
    // }

    await addDoc(collection(db, 'products'), {
      title: newProduct.value.title,
      barcode: newProduct.value.barcode,
      category: newProduct.value.category,
      price: parseFloat(newProduct.value.price),
      quantity: parseInt(newProduct.value.quantity),
      store: newProduct.value.store,
      status: newProduct.value.status,
      // imageUrl: imageUrl,  // Comment this out
      createdAt: new Date(),
      updatedAt: new Date()
    })
    
    // ... rest of function
  }
}
```

This will let you test the app functionality while fixing the storage issue. 