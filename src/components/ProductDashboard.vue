<template>
  <div class="dashboard">
    <!-- Top Navigation -->
    <nav class="top-nav">
      <div class="nav-content">
        <div class="logo-section">
          <img src="/images/images.png" alt="Supreme Logo" class="logo">
        </div>
        
        <div class="nav-tabs">
          <button 
            @click="activeSection = 'products'" 
            :class="['nav-tab', { active: activeSection === 'products' }]"
          >
            Dashboard
          </button>
        </div>

        <div class="nav-actions">
          <button class="search-btn">🔍</button>
          <button class="notification-btn">🔔</button>
          <div class="user-profile" @click.stop>
            <div class="user-info">
              <span class="user-display-name">{{ currentUserData?.display_name || userEmail?.split('@')[0] }}</span>
              <span class="user-role">{{ currentUserRole.charAt(0).toUpperCase() + currentUserRole.slice(1) }}</span>
            </div>
            <div class="user-dropdown-container">
              <button @click="toggleUserDropdown" class="user-dropdown-btn">▼</button>
              
              <!-- User Dropdown Menu -->
              <div v-if="showUserDropdown" class="user-dropdown-menu">
                <button @click="openUserSettings" class="dropdown-item">
                  ⚙️ User Settings
                </button>
                <button 
                  v-if="canAccessSettings"
                  @click="openAdminSettings" 
                  class="dropdown-item admin-item"
                >
                  🛠️ Admin Settings
                </button>
                <button @click="logout" class="dropdown-item logout-item">
                  🚪 Logout
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
      <!-- Products Section -->
      <div v-if="activeSection === 'products'">
        <!-- Header -->
        <div class="content-header">
          <h1>Dashboard</h1>
          <div v-if="canAddStock" class="header-actions">
            <button 
              @click="showBulkImport = true" 
              class="bulk-import-btn"
            >
              📂 Bulk Import
            </button>
            <button 
              @click="showAddProduct = true" 
              class="add-product-btn"
            >
              + Add Product
            </button>
          </div>
        </div>

      <!-- Statistics Cards -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-info">
              <h3>Total Products</h3>
              <div class="stat-number">{{ totalProducts.toLocaleString() }}</div>
              <div class="stat-change neutral">Overall inventory count</div>
            </div>
            <div class="stat-icon total">📦</div>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-info">
              <h3>Categories</h3>
              <div class="stat-number">{{ totalCategories.toLocaleString() }}</div>
              <div class="stat-change neutral">Product categories</div>
            </div>
            <div class="stat-icon categories">📂</div>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-info">
              <h3>Recent Additions</h3>
              <div class="stat-number">{{ recentProducts.toLocaleString() }}</div>
              <div class="stat-change neutral">Added this week</div>
            </div>
            <div class="stat-icon recent">✨</div>
          </div>
        </div>
      </div>

      <!-- Products Table Section -->
      <div class="table-section">
        <div class="table-header">
          <div class="table-tabs">
            <span class="table-title">Products list</span>
            <button class="tab-btn active">All</button>
            <button class="tab-btn">Active</button>
            <button class="tab-btn">Sold</button>
          </div>
          
          <div class="table-actions">
            <div class="search-box">
              <input 
                v-model="searchTerm" 
                type="text" 
                placeholder="Search" 
                class="search-input"
              >
              <span class="search-icon">🔍</span>
            </div>
            <button class="filter-btn">🔽 Filter</button>
          </div>
        </div>

        <!-- Products Table -->
        <div class="products-table">
          <table>
            <thead>
              <tr>
                <th class="checkbox-col">
                  <input type="checkbox" @change="toggleSelectAll">
                </th>
                <th class="image-col">Image</th>
                <th class="title-col">Title ↕</th>
                <th class="barcode-col">Barcode ↕</th>
                <th class="category-col">Category ↕</th>
                <th class="action-col">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="product in filteredProducts" :key="product.id" class="product-row">
                <td class="checkbox-col">
                  <input type="checkbox" v-model="selectedProducts" :value="product.id">
                </td>
                <td class="image-col">
                  <img :src="product.image_url || '/images/placeholder.png'" :alt="product.title" class="product-image">
                </td>
                <td class="title-col">
                  <span class="product-title">{{ product.title }}</span>
                </td>
                <td class="barcode-col">
                  <span class="product-barcode">{{ product.barcode }}</span>
                </td>
                <td class="category-col">
                  <span class="product-category">{{ product.category }}</span>
                </td>
                <td class="action-col">
                  <button 
                    v-if="canEditStock"
                    @click="editProduct(product)" 
                    class="action-btn edit-btn"
                  >
                    ✏️
                  </button>
                  <span v-else class="no-action">-</span>
                </td>
              </tr>
            </tbody>
          </table>
          
          <!-- Empty State -->
          <div v-if="filteredProducts.length === 0" class="empty-state">
            <div class="empty-icon">📦</div>
            <h3>No Products Found</h3>
            <p>{{ searchTerm ? 'Try adjusting your search' : 'Start by adding your first product' }}</p>
            <button @click="showAddProduct = true" class="add-product-btn">Add Your First Product</button>
          </div>
        </div>
      </div>
      </div>

      <!-- Admin Settings Section -->
      <div v-if="activeSection === 'settings'">
        <!-- Header -->
        <div class="content-header">
          <div class="header-left">
            <button @click="activeSection = 'products'" class="back-btn">
              ← Back to Dashboard
            </button>
            <h1>Admin Settings</h1>
          </div>
          <button 
            v-if="adminActiveTab === 'users'"
            @click="showAddUser = true" 
            class="add-product-btn"
          >
            + Add User
          </button>
          <button 
            v-if="adminActiveTab === 'categories'"
            @click="showAddCategory = true" 
            class="add-product-btn"
          >
            + Add Category
          </button>
        </div>

        <!-- Admin Tabs -->
        <div class="admin-tabs">
          <button 
            @click="adminActiveTab = 'users'"
            :class="['admin-tab', { active: adminActiveTab === 'users' }]"
          >
            Users
          </button>
          <button 
            @click="adminActiveTab = 'categories'"
            :class="['admin-tab', { active: adminActiveTab === 'categories' }]"
          >
            Categories
          </button>
        </div>

        <!-- User Management Section -->
        <div v-if="adminActiveTab === 'users'" class="table-section">
          <div class="table-header">
            <div class="table-tabs">
              <span class="table-title">User Management</span>
              <button class="tab-btn active">All Users</button>
              <button class="tab-btn">Active</button>
              <button class="tab-btn">Inactive</button>
            </div>
            
            <div class="table-actions">
              <div class="search-box">
                <input 
                  v-model="userSearchTerm" 
                  type="text" 
                  placeholder="Search Users" 
                  class="search-input"
                >
                <span class="search-icon">🔍</span>
              </div>
              <button class="filter-btn">🔽 Filter</button>
            </div>
          </div>

          <!-- Users Table -->
          <div class="products-table">
            <table>
              <thead>
                <tr>
                  <th class="checkbox-col">
                    <input type="checkbox" @change="toggleSelectAllUsers">
                  </th>
                  <th class="name-col">Name ↕</th>
                  <th class="email-col">Email ↕</th>
                  <th class="role-col">Role ↕</th>
                  <th class="created-col">Created ↕</th>
                  <th class="status-col">Status ↕</th>
                  <th class="action-col">Action</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="user in filteredUsers" :key="user.id" class="product-row">
                  <td class="checkbox-col">
                    <input type="checkbox" v-model="selectedUsers" :value="user.id">
                  </td>
                  <td class="name-col">
                    <div class="user-info-cell">
                      <div class="user-avatar-small">{{ getUserInitials(user.display_name || user.email) }}</div>
                      <div class="user-details">
                        <div class="user-name">{{ user.display_name || user.email.split('@')[0] }}</div>
                        <div class="user-subtitle">{{ user.role.charAt(0).toUpperCase() + user.role.slice(1) }}</div>
                      </div>
                    </div>
                  </td>
                  <td class="email-col">
                    <span class="user-email">{{ user.email }}</span>
                  </td>
                  <td class="role-col">
                    <span :class="['role-badge', user.role]">
                      {{ user.role.charAt(0).toUpperCase() + user.role.slice(1) }}
                    </span>
                  </td>
                  <td class="created-col">
                    <span class="user-created">{{ formatDate(user.created_at) }}</span>
                  </td>
                  <td class="status-col">
                    <span :class="['status-badge', user.status]">
                      {{ user.status.charAt(0).toUpperCase() + user.status.slice(1) }}
                    </span>
                  </td>
                  <td class="action-col">
                    <button @click="editUser(user)" class="action-btn edit-btn">✏️</button>
                  </td>
                </tr>
              </tbody>
            </table>
            
            <!-- Empty State -->
            <div v-if="filteredUsers.length === 0" class="empty-state">
              <div class="empty-icon">👥</div>
              <h3>No Users Found</h3>
              <p>{{ userSearchTerm ? 'Try adjusting your search' : 'Start by adding your first user' }}</p>
              <button @click="showAddUser = true" class="add-product-btn">Add Your First User</button>
            </div>
                      </div>
          </div>
        </div>

        <!-- Category Management Section -->
        <div v-if="adminActiveTab === 'categories'" class="table-section">
          <div class="table-header">
            <div class="table-tabs">
              <span class="table-title">Category Management</span>
              <button class="tab-btn active">All Categories</button>
            </div>
            
            <div class="table-actions">
              <div class="search-box">
                <input 
                  v-model="categorySearchTerm" 
                  type="text" 
                  placeholder="Search Categories" 
                  class="search-input"
                >
                <span class="search-icon">🔍</span>
              </div>
              <button class="filter-btn">🔽 Filter</button>
            </div>
          </div>

          <!-- Categories Table -->
          <div class="products-table">
            <table>
              <thead>
                <tr>
                  <th class="checkbox-col">
                    <input type="checkbox" @change="toggleSelectAllCategories">
                  </th>
                  <th class="name-col">Name ↕</th>
                  <th class="created-col">Created ↕</th>
                  <th class="action-col">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="category in filteredCategories" :key="category.id" class="product-row">
                  <td class="checkbox-col">
                    <input type="checkbox" v-model="selectedCategories" :value="category.id">
                  </td>
                  <td class="name-col">
                    <span class="category-name">{{ category.name }}</span>
                  </td>
                  <td class="created-col">
                    <span class="category-created">{{ formatDate(category.created_at) }}</span>
                  </td>
                  <td class="action-col">
                    <button @click="editCategory(category)" class="action-btn edit-btn">✏️</button>
                  </td>
                </tr>
              </tbody>
            </table>
            
            <!-- Empty State -->
            <div v-if="filteredCategories.length === 0" class="empty-state">
              <div class="empty-icon">📂</div>
              <h3>No Categories Found</h3>
              <p>{{ categorySearchTerm ? 'Try adjusting your search' : 'Start by adding your first category' }}</p>
              <button @click="showAddCategory = true" class="add-product-btn">Add Your First Category</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Add User Modal -->
    <div v-if="showAddUser" class="modal-overlay" @click.self="showAddUser = false">
      <div class="modal">
        <div class="modal-header">
          <h2>Add New User</h2>
          <button @click="showAddUser = false" class="close-btn">&times;</button>
        </div>
        <form @submit.prevent="addUser" class="product-form">
          <div class="form-row">
            <div class="form-group">
              <label>Display Name *</label>
              <input v-model="newUser.displayName" type="text" required class="form-input">
            </div>
            <div class="form-group">
              <label>Email *</label>
              <input v-model="newUser.email" type="email" required class="form-input">
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label>Password *</label>
              <input v-model="newUser.password" type="password" required class="form-input" minlength="6">
            </div>
                         <div class="form-group">
               <label>Role *</label>
               <select v-model="newUser.role" required class="form-input">
                 <option value="admin">Admin - Can do everything</option>
                 <option value="lister">Lister - Can add and edit stock (can't delete)</option>
                 <option value="user">User - Can view stock only</option>
               </select>
             </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label>Status</label>
              <select v-model="newUser.status" class="form-input">
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" @click="showAddUser = false" class="cancel-btn">Cancel</button>
            <button type="submit" :disabled="loading" class="submit-btn">
              {{ loading ? 'Creating...' : 'Create User' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Edit User Modal -->
    <div v-if="showEditUser" class="modal-overlay" @click.self="showEditUser = false">
      <div class="modal">
        <div class="modal-header">
          <h2>Edit User</h2>
          <button @click="showEditUser = false" class="close-btn">&times;</button>
        </div>
        <form @submit.prevent="updateUser" class="product-form">
          <div class="form-row">
            <div class="form-group">
              <label>Display Name *</label>
              <input v-model="editingUser.display_name" type="text" required class="form-input">
            </div>
            <div class="form-group">
              <label>Email *</label>
              <input v-model="editingUser.email" type="email" required class="form-input" readonly>
              <small style="color: #94a3b8; font-size: 0.75rem;">Email cannot be changed</small>
            </div>
          </div>
          
          <div class="form-row">
                         <div class="form-group">
               <label>Role *</label>
               <select v-model="editingUser.role" required class="form-input">
                 <option value="admin">Admin - Can do everything</option>
                 <option value="lister">Lister - Can add and edit stock (can't delete)</option>
                 <option value="user">User - Can view stock only</option>
               </select>
             </div>
            <div class="form-group">
              <label>Status</label>
              <select v-model="editingUser.status" class="form-input">
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label>Reset Password</label>
              <input v-model="editingUser.newPassword" type="password" class="form-input" minlength="6" placeholder="Leave blank to keep current password">
              <small style="color: #94a3b8; font-size: 0.75rem;">Only fill if you want to reset the password</small>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" @click="showEditUser = false" class="cancel-btn">Cancel</button>
            <button type="button" @click="deleteUser(editingUser.id)" class="delete-btn" :disabled="editingUser.email === userEmail">Delete User</button>
            <button type="submit" :disabled="loading" class="submit-btn">
              {{ loading ? 'Updating...' : 'Update User' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Add Product Modal -->
    <div v-if="showAddProduct" class="modal-overlay" @click.self="showAddProduct = false">
      <div class="modal">
        <div class="modal-header">
          <h2>Add New Product</h2>
          <button @click="showAddProduct = false" class="close-btn">&times;</button>
        </div>
        <form @submit.prevent="addProduct" class="product-form">
          <div class="form-row">
            <div class="form-group">
              <label>Product Image</label>
              <input type="file" @change="handleImageUpload" accept="image/*" class="file-input">
              <div v-if="newProduct.imagePreview" class="image-preview">
                <img :src="newProduct.imagePreview" alt="Preview">
              </div>
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label>Title *</label>
              <input v-model="newProduct.title" type="text" required class="form-input">
            </div>
            <div class="form-group">
              <label>Barcode *</label>
              <input v-model="newProduct.barcode" type="text" required class="form-input">
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label>Category *</label>
              <select v-model="newProduct.category" required class="form-input">
                <option value="">Select a category</option>
                <option v-for="category in categories" :key="category.id" :value="category.name">
                  {{ category.name }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" @click="showAddProduct = false" class="cancel-btn">Cancel</button>
            <button type="submit" :disabled="loading" class="submit-btn">
              {{ loading ? 'Adding...' : 'Add Product' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Edit Product Modal -->
    <div v-if="showEditProduct" class="modal-overlay" @click.self="showEditProduct = false">
      <div class="modal">
        <div class="modal-header">
          <h2>Edit Product</h2>
          <button @click="showEditProduct = false" class="close-btn">&times;</button>
        </div>
        <form @submit.prevent="updateProduct" class="product-form">
          <div class="form-row">
            <div class="form-group">
              <label>Product Image</label>
              <input type="file" @change="handleEditImageUpload" accept="image/*" class="file-input">
              <div v-if="editingProduct.image_url" class="image-preview">
                <img :src="editingProduct.image_url" alt="Current Image">
              </div>
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label>Title *</label>
              <input v-model="editingProduct.title" type="text" required class="form-input">
            </div>
            <div class="form-group">
              <label>Barcode *</label>
              <input v-model="editingProduct.barcode" type="text" required class="form-input">
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label>Category *</label>
              <select v-model="editingProduct.category" required class="form-input">
                <option value="">Select a category</option>
                <option v-for="category in categories" :key="category.id" :value="category.name">
                  {{ category.name }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" @click="showEditProduct = false" class="cancel-btn">Cancel</button>
            <button 
              v-if="canDeleteStock"
              type="button" 
              @click="deleteProduct(editingProduct.id)" 
              class="delete-btn"
            >
              Delete Product
            </button>
            <button type="submit" :disabled="loading" class="submit-btn">
              {{ loading ? 'Updating...' : 'Update Product' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Custom Confirmation Dialog -->
    <div v-if="showConfirmDialog" class="modal-overlay">
              <div class="custom-modal confirmation-modal">
          <div class="custom-modal-header">
            <div class="modal-icon">{{ confirmDialog.title.includes('Delete') ? '🗑️' : '⚠️' }}</div>
            <h3>{{ confirmDialog.title }}</h3>
          </div>
        <div class="custom-modal-body">
          <p>{{ confirmDialog.message }}</p>
        </div>
        <div class="custom-modal-actions">
          <button @click="confirmDialog.onCancel" class="modal-cancel-btn">
            {{ confirmDialog.cancelText }}
          </button>
          <button @click="confirmDialog.onConfirm" class="modal-confirm-btn">
            {{ confirmDialog.confirmText }}
          </button>
        </div>
      </div>
    </div>

    <!-- Custom Success/Error Message -->
    <div v-if="showSuccessMessage" class="modal-overlay">
      <div class="custom-modal" :class="{ 'success-modal': successMessage.title === 'Success', 'error-modal': successMessage.title === 'Error' }">
        <div class="custom-modal-header">
          <div class="modal-icon">{{ successMessage.title === 'Success' ? '✅' : '❌' }}</div>
          <h3>{{ successMessage.title }}</h3>
        </div>
        <div class="custom-modal-body">
          <p>{{ successMessage.message }}</p>
        </div>
        <div class="custom-modal-actions">
          <button @click="closeSuccessMessage" class="modal-ok-btn">
            OK
          </button>
        </div>
      </div>
    </div>

    <!-- Add Category Modal -->
    <div v-if="showAddCategory" class="modal-overlay" @click.self="showAddCategory = false">
      <div class="modal">
        <div class="modal-header">
          <h2>Add New Category</h2>
          <button @click="showAddCategory = false" class="close-btn">&times;</button>
        </div>
        <form @submit.prevent="addCategory" class="product-form">
          <div class="form-row">
            <div class="form-group">
              <label>Category Name *</label>
              <input v-model="newCategory.name" type="text" required class="form-input">
            </div>
          </div>

          <div class="form-actions">
            <button type="button" @click="showAddCategory = false" class="cancel-btn">Cancel</button>
            <button type="submit" :disabled="loading" class="submit-btn">
              {{ loading ? 'Creating...' : 'Create Category' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Edit Category Modal -->
    <div v-if="showEditCategory" class="modal-overlay" @click.self="showEditCategory = false">
      <div class="modal">
        <div class="modal-header">
          <h2>Edit Category</h2>
          <button @click="showEditCategory = false" class="close-btn">&times;</button>
        </div>
        <form @submit.prevent="updateCategory" class="product-form">
          <div class="form-row">
            <div class="form-group">
              <label>Category Name *</label>
              <input v-model="editingCategory.name" type="text" required class="form-input">
            </div>
          </div>

          <div class="form-actions">
            <button type="button" @click="showEditCategory = false" class="cancel-btn">Cancel</button>
            <button type="button" @click="deleteCategory(editingCategory.id)" class="delete-btn">Delete Category</button>
            <button type="submit" :disabled="loading" class="submit-btn">
              {{ loading ? 'Updating...' : 'Update Category' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- User Settings Modal -->
    <div v-if="showUserSettings" class="modal-overlay" @click.self="closeUserSettings">
      <div class="modal">
        <div class="modal-header">
          <h2>User Settings</h2>
          <button @click="closeUserSettings" class="close-btn">&times;</button>
        </div>
        <form @submit.prevent="updateUserSettings" class="product-form">
          <div class="form-row">
            <div class="form-group">
              <label>Display Name *</label>
              <input v-model="userSettingsForm.display_name" type="text" required class="form-input">
            </div>
          </div>
          
          <div class="form-section">
            <h3 class="section-title">Change Password</h3>
            <p class="section-subtitle">Leave blank to keep current password</p>
            
            <div class="form-row">
              <div class="form-group">
                <label>Current Password</label>
                <input v-model="userSettingsForm.current_password" type="password" class="form-input" placeholder="Enter current password">
              </div>
            </div>
            
            <div class="form-row">
              <div class="form-group">
                <label>New Password</label>
                <input v-model="userSettingsForm.new_password" type="password" class="form-input" minlength="6" placeholder="Enter new password">
              </div>
              <div class="form-group">
                <label>Confirm New Password</label>
                <input v-model="userSettingsForm.confirm_password" type="password" class="form-input" minlength="6" placeholder="Confirm new password">
              </div>
            </div>
          </div>

          <div class="form-actions">
            <button type="button" @click="closeUserSettings" class="cancel-btn">Cancel</button>
            <button type="submit" :disabled="loading" class="submit-btn">
              {{ loading ? 'Updating...' : 'Update Settings' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Bulk Import Modal -->
    <div v-if="showBulkImport" class="modal-overlay" @click.self="showBulkImport = false">
      <div class="modal large-modal">
        <div class="modal-header">
          <h2>Bulk Import Products</h2>
          <button @click="showBulkImport = false" class="close-btn">&times;</button>
        </div>
        
        <!-- Import Tabs -->
        <div class="import-tabs">
          <button 
            @click="bulkImportActiveTab = 'csv'"
            :class="['import-tab', { active: bulkImportActiveTab === 'csv' }]"
          >
            📄 CSV Import
          </button>
          <button 
            @click="bulkImportActiveTab = 'images'"
            :class="['import-tab', { active: bulkImportActiveTab === 'images' }]"
          >
            🖼️ Image Upload
          </button>
        </div>

        <!-- CSV Import Tab -->
        <div v-if="bulkImportActiveTab === 'csv'" class="import-content">
          <div v-if="!csvPreview.length" class="csv-upload-section">
            <div class="upload-info">
              <h3>Upload CSV File</h3>
              <p>CSV should contain columns: <strong>title, barcode, category</strong></p>
              <p class="upload-note">Make sure your CSV has headers and uses comma separation.</p>
            </div>
            
            <div class="file-upload-area" @drop="handleCSVDrop" @dragover.prevent @dragenter.prevent>
              <input 
                type="file" 
                @change="handleCSVUpload" 
                accept=".csv" 
                class="file-input-hidden"
                ref="csvFileInput"
              >
              <div class="upload-content">
                <div class="upload-icon">📄</div>
                <p>Drag & drop your CSV file here or <button @click="$refs.csvFileInput.click()" class="upload-link">browse</button></p>
              </div>
            </div>
          </div>

          <!-- CSV Preview -->
          <div v-if="csvPreview.length" class="csv-preview-section">
            <div class="preview-header">
              <h3>CSV Preview ({{ csvData.length }} products)</h3>
              <div class="preview-actions">
                <button @click="clearCSVData" class="secondary-btn">Clear</button>
                <button @click="importCSVProducts" :disabled="loading" class="import-btn">
                  {{ loading ? 'Importing...' : 'Import Products' }}
                </button>
              </div>
            </div>
            
            <div class="csv-preview-table">
              <table>
                <thead>
                  <tr>
                    <th>Title</th>
                    <th>Barcode</th>
                    <th>Category</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, index) in csvPreview" :key="index">
                    <td>{{ row.title || 'Missing' }}</td>
                    <td>{{ row.barcode || 'Missing' }}</td>
                    <td>{{ row.category || 'Missing' }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Import Progress -->
          <div v-if="importProgress > 0" class="import-progress">
            <div class="progress-bar">
              <div class="progress-fill" :style="{ width: importProgress + '%' }"></div>
            </div>
            <p>{{ importStatus }}</p>
          </div>
        </div>

        <!-- Image Upload Tab -->
        <div v-if="bulkImportActiveTab === 'images'" class="import-content">
          <div class="image-upload-section">
            <div class="upload-info">
              <h3>Upload Product Images</h3>
              <p>Image filenames should match product barcodes (e.g., "12345.jpg" for barcode "12345")</p>
              <p class="upload-note">Supported formats: JPG, PNG, WebP</p>
            </div>
            
            <div class="file-upload-area" @drop="handleImageDrop" @dragover.prevent @dragenter.prevent>
              <input 
                type="file" 
                @change="handleBulkImageUpload" 
                accept="image/*" 
                multiple
                class="file-input-hidden"
                ref="imageFileInput"
              >
              <div class="upload-content">
                <div class="upload-icon">🖼️</div>
                <p>Drag & drop your images here or <button @click="$refs.imageFileInput.click()" class="upload-link">browse</button></p>
              </div>
            </div>

            <!-- Image Match Results -->
            <div v-if="imageMatchResults.length" class="image-match-results">
              <div class="match-header">
                <h3>Image Matching Results</h3>
                <button @click="uploadMatchedImages" :disabled="loading" class="import-btn">
                  {{ loading ? 'Uploading...' : 'Upload Images' }}
                </button>
              </div>
              
              <div class="match-summary">
                <div class="match-stat">
                  <span class="match-count success">{{ imageMatchResults.filter(r => r.matched).length }}</span>
                  <span>Matched</span>
                </div>
                <div class="match-stat">
                  <span class="match-count warning">{{ imageMatchResults.filter(r => !r.matched).length }}</span>
                  <span>Unmatched</span>
                </div>
              </div>

              <div class="match-list">
                <div v-for="result in imageMatchResults" :key="result.filename" class="match-item" :class="{ matched: result.matched }">
                  <div class="match-info">
                    <strong>{{ result.filename }}</strong>
                    <span v-if="result.matched" class="match-status success">→ {{ result.productTitle }}</span>
                    <span v-else class="match-status error">No matching barcode found</span>
                  </div>
                  <img :src="result.preview" :alt="result.filename" class="match-preview">
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Click outside to close dropdown -->
    <div v-if="showUserDropdown" @click="closeUserDropdown" class="dropdown-overlay"></div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { auth } from '@/firebase'
import { signOut } from 'firebase/auth'
import { supabase, uploadFile, getFileUrl } from '@/supabase'

export default {
  name: 'ProductDashboard',
  setup() {
    const router = useRouter()
    const products = ref([])
    const users = ref([])
    const categories = ref([])
    const currentUserRole = ref('user') // Default to most restrictive role
    const currentUserData = ref(null)
    const loading = ref(false)
    const searchTerm = ref('')
    const userSearchTerm = ref('')
    const categorySearchTerm = ref('')
    const showAddProduct = ref(false)
    const showEditProduct = ref(false)
    const showBulkImport = ref(false)
    const showAddUser = ref(false)
    const showEditUser = ref(false)
    const showAddCategory = ref(false)
    const showEditCategory = ref(false)
    const showUserSettings = ref(false)
    const showUserDropdown = ref(false)
    const selectedProducts = ref([])
    const selectedUsers = ref([])
    const selectedCategories = ref([])
    const userEmail = ref(auth.currentUser?.email || '')
    const userAvatar = ref('https://via.placeholder.com/40x40/4A90E2/ffffff?text=U')
    const activeSection = ref('products')
    const adminActiveTab = ref('users')
    const bulkImportActiveTab = ref('csv')
    
    // Bulk import state
    const csvFile = ref(null)
    const csvData = ref([])
    const csvPreview = ref([])
    const imageFiles = ref([])
    const importProgress = ref(0)
    const importStatus = ref('')
    const imageMatchResults = ref([])
    
    // Custom modal states
    const showConfirmDialog = ref(false)
    const showSuccessMessage = ref(false)
    const confirmDialog = ref({
      title: '',
      message: '',
      confirmText: 'OK',
      cancelText: 'Cancel',
      onConfirm: () => {},
      onCancel: () => {}
    })
    const successMessage = ref({
      title: 'Success',
      message: ''
    })

    const newProduct = ref({
      title: '',
      barcode: '',
      category: '',
      imageFile: null,
      imagePreview: null
    })

    const editingProduct = ref({
      id: '',
      title: '',
      barcode: '',
      category: '',
      image_url: '',
      imageFile: null
    })

    const newUser = ref({
      displayName: '',
      email: '',
      password: '',
      role: 'user',
      status: 'active'
    })

    const editingUser = ref({
      id: '',
      display_name: '',
      email: '',
      role: 'user',
      status: 'active',
      newPassword: ''
    })

    const newCategory = ref({
      name: ''
    })

    const editingCategory = ref({
      id: '',
      name: ''
    })

    const userSettingsForm = ref({
      display_name: '',
      current_password: '',
      new_password: '',
      confirm_password: ''
    })

    // Computed properties for statistics
    const totalProducts = computed(() => products.value.length)
    const totalCategories = computed(() => categories.value.length)
    const recentProducts = computed(() => {
      // Products added in the last week
      const oneWeekAgo = new Date()
      oneWeekAgo.setDate(oneWeekAgo.getDate() - 7)
      return products.value.filter(p => p.created_at && new Date(p.created_at) > oneWeekAgo).length
    })

    const filteredProducts = computed(() => {
      let filtered = products.value

      if (searchTerm.value) {
        const search = searchTerm.value.toLowerCase()
        filtered = filtered.filter(product => 
          product.title.toLowerCase().includes(search) ||
          product.barcode.toLowerCase().includes(search) ||
          product.category.toLowerCase().includes(search)
        )
      }

      return filtered
    })

    const filteredUsers = computed(() => {
      let filtered = users.value

      if (userSearchTerm.value) {
        const search = userSearchTerm.value.toLowerCase()
        filtered = filtered.filter(user => 
          (user.display_name && user.display_name.toLowerCase().includes(search)) ||
          user.email.toLowerCase().includes(search) ||
          user.role.toLowerCase().includes(search)
        )
      }

      return filtered
    })

    const filteredCategories = computed(() => {
      let filtered = categories.value

      if (categorySearchTerm.value) {
        const search = categorySearchTerm.value.toLowerCase()
        filtered = filtered.filter(category => 
          category.name.toLowerCase().includes(search)
        )
      }

      return filtered
    })

    // Permission System - Role-based access control
    const canViewStock = computed(() => {
      return ['user', 'lister', 'admin'].includes(currentUserRole.value)
    })

    const canAddStock = computed(() => {
      return ['lister', 'admin'].includes(currentUserRole.value)
    })

    const canEditStock = computed(() => {
      return ['lister', 'admin'].includes(currentUserRole.value)
    })

    const canDeleteStock = computed(() => {
      return currentUserRole.value === 'admin'
    })

    const canManageUsers = computed(() => {
      return currentUserRole.value === 'admin'
    })

    const canAccessSettings = computed(() => {
      return currentUserRole.value === 'admin'
    })

    // Methods
    const loadCurrentUserRole = async () => {
      try {
        if (!auth.currentUser) {
          console.warn('No authenticated user found')
          return
        }

        console.log('Loading current user role...')
        const { data, error } = await supabase
          .from('users')
          .select('*')
          .eq('firebase_uid', auth.currentUser.uid)
          .single()

        if (error) {
          if (error.code === 'PGRST116') {
            // User not found in database, might be legacy user
            console.warn('User not found in users table, defaulting to user role')
            currentUserRole.value = 'user'
            currentUserData.value = {
              email: auth.currentUser.email,
              role: 'user',
              display_name: auth.currentUser.email.split('@')[0]
            }
          } else {
            throw error
          }
        } else {
          currentUserRole.value = data.role
          currentUserData.value = data
          console.log(`Current user role: ${currentUserRole.value}`)
        }
      } catch (error) {
        console.error('Error loading user role:', error)
        // Default to most restrictive role on error
        currentUserRole.value = 'user'
      }
    }

    const loadProducts = async () => {
      try {
        if (!canViewStock.value) {
          showSuccess('You do not have permission to view products.', 'Access Denied')
          return
        }

        console.log('Loading products from Supabase...')
        console.log('Supabase instance:', supabase)
        
        const { data, error } = await supabase
          .from('products')
          .select('*')
          .order('title', { ascending: true })
        
        if (error) {
          throw error
        }
        
        products.value = data || []
        console.log(`Loaded ${products.value.length} products successfully`)
      } catch (error) {
        console.error('Error loading products:', error)
        console.error('Error message:', error.message)
        
        let errorMessage = 'Error loading products. Please try again.'
        
        if (error.message) {
          errorMessage = `Error: ${error.message}`
        }
        
        showSuccess(errorMessage, 'Error')
      }
    }

    const handleImageUpload = (event) => {
      const file = event.target.files[0]
      if (file) {
        newProduct.value.imageFile = file
        const reader = new FileReader()
        reader.onload = (e) => {
          newProduct.value.imagePreview = e.target.result
        }
        reader.readAsDataURL(file)
      }
    }

    const handleEditImageUpload = (event) => {
      const file = event.target.files[0]
      if (file) {
        editingProduct.value.imageFile = file
        const reader = new FileReader()
        reader.onload = (e) => {
          editingProduct.value.image_url = e.target.result
        }
        reader.readAsDataURL(file)
      }
    }

    const uploadImage = async (file, fileName) => {
      try {
        console.log('Uploading image to Supabase:', fileName, 'Size:', file.size)
        console.log('Current user:', auth.currentUser?.email)
        
        const filePath = `products/${fileName}`
        console.log('Upload path:', filePath)
        
        // Upload file to Supabase Storage
        await uploadFile('product-images', filePath, file)
        console.log('Upload successful')
        
        // Get public URL
        const publicURL = getFileUrl('product-images', filePath)
        console.log('Public URL:', publicURL)
        
        return publicURL
      } catch (error) {
        console.error('Image upload error:', error)
        console.error('Error message:', error.message)
        throw error
      }
    }

    const addProduct = async () => {
      if (!canAddStock.value) {
        showSuccess('You do not have permission to add products.', 'Access Denied')
        return
      }

      loading.value = true
      try {
        console.log('Starting product addition...')
        console.log('User authenticated:', !!auth.currentUser)
        
        let imageUrl = ''
        
        if (newProduct.value.imageFile) {
          console.log('Image file selected, starting upload...')
          const fileName = `${Date.now()}_${newProduct.value.imageFile.name}`
          
          try {
            imageUrl = await uploadImage(newProduct.value.imageFile, fileName)
            console.log('Image uploaded successfully:', imageUrl)
          } catch (uploadError) {
            console.error('Image upload failed:', uploadError)
            
            // Ask user if they want to continue without image
            const continueWithoutImage = await showConfirm(
              'Image Upload Failed',
              `Image upload failed. Would you like to add the product without an image?\n\nError: ${uploadError.message}`,
              null,
              'Continue Without Image',
              'Cancel'
            )
            
            if (!continueWithoutImage) {
              return
            }
            
            imageUrl = '' // Continue without image
          }
        }

        console.log('Adding product to Supabase...')
        const { data, error } = await supabase
          .from('products')
          .insert([{
            title: newProduct.value.title,
            barcode: newProduct.value.barcode,
            category: newProduct.value.category,
            image_url: imageUrl,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          }])

        if (error) {
          throw error
        }

        console.log('Product added to Supabase successfully')

        // Reset form
        newProduct.value = {
          title: '',
          barcode: '',
          category: '',
          imageFile: null,
          imagePreview: null
        }
        showAddProduct.value = false
        await loadProducts()
        showSuccess('Product added successfully!')
      } catch (error) {
        console.error('Error adding product:', error)
        console.error('Error code:', error.code)
        console.error('Error message:', error.message)
        
        let errorMessage = 'Error adding product. Please try again.'
        
        if (error.code === 'permission-denied') {
          errorMessage = 'Permission denied. Please check your Firebase security rules.'
        } else if (error.code === 'unauthenticated') {
          errorMessage = 'You are not logged in. Please log in and try again.'
        } else if (error.message) {
          errorMessage = `Error: ${error.message}`
        }
        
        showSuccess(errorMessage, 'Error')
      } finally {
        loading.value = false
      }
    }

    const editProduct = (product) => {
      if (!canEditStock.value) {
        showSuccess('You do not have permission to edit products.', 'Access Denied')
        return
      }
      
      editingProduct.value = { ...product }
      showEditProduct.value = true
    }

    const updateProduct = async () => {
      if (!canEditStock.value) {
        showSuccess('You do not have permission to update products.', 'Access Denied')
        return
      }

      loading.value = true
      try {
        let imageUrl = editingProduct.value.image_url

        if (editingProduct.value.imageFile) {
          const fileName = `${Date.now()}_${editingProduct.value.imageFile.name}`
          imageUrl = await uploadImage(editingProduct.value.imageFile, fileName)
        }

        const { data, error } = await supabase
          .from('products')
          .update({
            title: editingProduct.value.title,
            barcode: editingProduct.value.barcode,
            category: editingProduct.value.category,
            image_url: imageUrl,
            updated_at: new Date().toISOString()
          })
          .eq('id', editingProduct.value.id)

        if (error) {
          throw error
        }

        showEditProduct.value = false
        await loadProducts()
        showSuccess('Product updated successfully!')
      } catch (error) {
        console.error('Error updating product:', error)
        showSuccess('Error updating product. Please try again.', 'Error')
      } finally {
        loading.value = false
      }
    }

    const deleteProduct = async (productId) => {
      if (!canDeleteStock.value) {
        showSuccess('You do not have permission to delete products.', 'Access Denied')
        return
      }

      // Close edit modal first to prevent z-index issues
      showEditProduct.value = false

      showConfirm(
        'Delete Product',
        'Are you sure you want to delete this product? This action cannot be undone.',
        async () => {
          try {
            const { error } = await supabase
              .from('products')
              .delete()
              .eq('id', productId)

            if (error) {
              throw error
            }
            
            await loadProducts()
            showSuccess('Product deleted successfully!')
          } catch (error) {
            console.error('Error deleting product:', error)
            showSuccess('Error deleting product. Please try again.', 'Error')
          }
        },
        'Delete',
        'Cancel'
      )
    }



    const toggleSelectAll = (event) => {
      if (event.target.checked) {
        selectedProducts.value = products.value.map(p => p.id)
      } else {
        selectedProducts.value = []
      }
    }

    const toggleSelectAllUsers = (event) => {
      if (event.target.checked) {
        selectedUsers.value = users.value.map(u => u.id)
      } else {
        selectedUsers.value = []
      }
    }

    // User Management Methods
    const loadUsers = async () => {
      try {
        if (!canManageUsers.value) {
          showSuccess('You do not have permission to view users.', 'Access Denied')
          return
        }

        console.log('Loading users from Supabase...')
        
        const { data, error } = await supabase
          .from('users')
          .select('*')
          .order('created_at', { ascending: false })
        
        if (error) {
          throw error
        }
        
        users.value = data || []
        console.log(`Loaded ${users.value.length} users successfully`)
      } catch (error) {
        console.error('Error loading users:', error)
        showSuccess('Error loading users. Please try again.', 'Error')
      }
    }

    // Category Management Methods
    const loadCategories = async () => {
      try {
        console.log('Loading categories from Supabase...')
        
        const { data, error } = await supabase
          .from('categories')
          .select('*')
          .order('name', { ascending: true })
        
        if (error) {
          throw error
        }
        
        categories.value = data || []
        console.log(`Loaded ${categories.value.length} categories successfully`)
      } catch (error) {
        console.error('Error loading categories:', error)
        showSuccess('Error loading categories. Please try again.', 'Error')
      }
    }

    const addCategory = async () => {
      if (!canManageUsers.value) {
        showSuccess('You do not have permission to create categories.', 'Access Denied')
        return
      }

      loading.value = true
      try {
        console.log('Creating new category...')

        const { data, error } = await supabase
          .from('categories')
          .insert([{
            name: newCategory.value.name,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          }])

        if (error) {
          throw error
        }

        console.log('Category added successfully')

        // Reset form
        newCategory.value = {
          name: ''
        }
        showAddCategory.value = false
        await loadCategories()
        showSuccess('Category created successfully!')
      } catch (error) {
        console.error('Error creating category:', error)
        
        let errorMessage = 'Error creating category. Please try again.'
        
        if (error.code === '23505') {
          errorMessage = 'A category with this name already exists.'
        } else if (error.message) {
          errorMessage = `Error: ${error.message}`
        }
        
        showSuccess(errorMessage, 'Error')
      } finally {
        loading.value = false
      }
    }

    const editCategory = (category) => {
      if (!canManageUsers.value) {
        showSuccess('You do not have permission to edit categories.', 'Access Denied')
        return
      }
      
      editingCategory.value = { ...category }
      showEditCategory.value = true
    }

    const updateCategory = async () => {
      if (!canManageUsers.value) {
        showSuccess('You do not have permission to update categories.', 'Access Denied')
        return
      }

      loading.value = true
      try {
        console.log('Updating category...')

        const { data, error } = await supabase
          .from('categories')
          .update({
            name: editingCategory.value.name,
            updated_at: new Date().toISOString()
          })
          .eq('id', editingCategory.value.id)

        if (error) {
          throw error
        }

        showEditCategory.value = false
        await loadCategories()
        showSuccess('Category updated successfully!')
      } catch (error) {
        console.error('Error updating category:', error)
        
        let errorMessage = 'Error updating category. Please try again.'
        
        if (error.code === '23505') {
          errorMessage = 'A category with this name already exists.'
        } else if (error.message) {
          errorMessage = `Error: ${error.message}`
        }
        
        showSuccess(errorMessage, 'Error')
      } finally {
        loading.value = false
      }
    }

    const deleteCategory = async (categoryId) => {
      if (!canManageUsers.value) {
        showSuccess('You do not have permission to delete categories.', 'Access Denied')
        return
      }

      const categoryToDelete = categories.value.find(c => c.id === categoryId)
      
      // Close edit modal first to prevent z-index issues
      showEditCategory.value = false
      
      showConfirm(
        'Delete Category',
        `Are you sure you want to delete category "${categoryToDelete?.name}"? This action cannot be undone and may affect existing products.`,
        async () => {
          try {
            const { error } = await supabase
              .from('categories')
              .delete()
              .eq('id', categoryId)

            if (error) {
              throw error
            }
            
            await loadCategories()
            showSuccess('Category deleted successfully!')
          } catch (error) {
            console.error('Error deleting category:', error)
            showSuccess('Error deleting category. Please try again.', 'Error')
          }
        },
        'Delete',
        'Cancel'
      )
    }

    const toggleSelectAllCategories = (event) => {
      if (event.target.checked) {
        selectedCategories.value = categories.value.map(c => c.id)
      } else {
        selectedCategories.value = []
      }
    }

    const addUser = async () => {
      if (!canManageUsers.value) {
        showSuccess('You do not have permission to create users.', 'Access Denied')
        return
      }

      loading.value = true
      try {
        console.log('Creating new user...')

        // First create the user in Firebase Auth
        const { createUserWithEmailAndPassword } = await import('firebase/auth')
        const userCredential = await createUserWithEmailAndPassword(
          auth, 
          newUser.value.email, 
          newUser.value.password
        )

        console.log('User created in Firebase Auth:', userCredential.user.uid)

        // Then add user details to Supabase
        const { data, error } = await supabase
          .from('users')
          .insert([{
            firebase_uid: userCredential.user.uid,
            email: newUser.value.email,
            display_name: newUser.value.displayName,
            role: newUser.value.role,
            status: newUser.value.status,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          }])

        if (error) {
          // If Supabase insert fails, delete the Firebase user
          await userCredential.user.delete()
          throw error
        }

        console.log('User added to database successfully')

        // Reset form
        newUser.value = {
          displayName: '',
          email: '',
          password: '',
          role: 'employee',
          status: 'active'
        }
        showAddUser.value = false
        await loadUsers()
        
        // Important note: Firebase automatically logs in the newly created user
        // This means the admin will be logged out. We'll show a warning about this.
        showSuccess('User created successfully! Note: You have been automatically logged out due to Firebase Auth behavior. Please log back in with your admin credentials.', 'Success - Logout Required')
        
        // After a short delay, redirect to login
        setTimeout(() => {
          logout()
        }, 3000)
        
      } catch (error) {
        console.error('Error creating user:', error)
        
        let errorMessage = 'Error creating user. Please try again.'
        
        if (error.code === 'auth/email-already-in-use') {
          errorMessage = 'This email is already registered.'
        } else if (error.code === 'auth/weak-password') {
          errorMessage = 'Password should be at least 6 characters.'
        } else if (error.code === 'auth/invalid-email') {
          errorMessage = 'Invalid email address.'
        } else if (error.message) {
          errorMessage = `Error: ${error.message}`
        }
        
        showSuccess(errorMessage, 'Error')
      } finally {
        loading.value = false
      }
    }

    const editUser = (user) => {
      if (!canManageUsers.value) {
        showSuccess('You do not have permission to edit users.', 'Access Denied')
        return
      }
      
      editingUser.value = { ...user, newPassword: '' }
      showEditUser.value = true
    }

    const updateUser = async () => {
      if (!canManageUsers.value) {
        showSuccess('You do not have permission to update users.', 'Access Denied')
        return
      }

      loading.value = true
      try {
        console.log('Updating user...')

        // Update user in Supabase
        const updateData = {
          display_name: editingUser.value.display_name,
          role: editingUser.value.role,
          status: editingUser.value.status,
          updated_at: new Date().toISOString()
        }

        const { data, error } = await supabase
          .from('users')
          .update(updateData)
          .eq('id', editingUser.value.id)

        if (error) {
          throw error
        }

        // If password reset is requested
        if (editingUser.value.newPassword) {
          // Note: In a production app, you would typically send a password reset email
          // or use Firebase Admin SDK on the backend to update the password
          console.log('Password reset requested for user:', editingUser.value.email)
          showSuccess('User updated successfully! Password reset functionality requires backend implementation.', 'Partial Success')
        } else {
          showSuccess('User updated successfully!')
        }

        showEditUser.value = false
        await loadUsers()
      } catch (error) {
        console.error('Error updating user:', error)
        showSuccess('Error updating user. Please try again.', 'Error')
      } finally {
        loading.value = false
      }
    }

    const deleteUser = async (userId) => {
      if (!canManageUsers.value) {
        showSuccess('You do not have permission to delete users.', 'Access Denied')
        return
      }

      const userToDelete = users.value.find(u => u.id === userId)
      
      // Close edit modal first to prevent z-index issues
      showEditUser.value = false
      
      showConfirm(
        'Delete User',
        `Are you sure you want to delete user "${userToDelete?.display_name || userToDelete?.email}"? This action cannot be undone.`,
        async () => {
          try {
            const { error } = await supabase
              .from('users')
              .delete()
              .eq('id', userId)

            if (error) {
              throw error
            }
            
            await loadUsers()
            showSuccess('User deleted successfully!')
          } catch (error) {
            console.error('Error deleting user:', error)
            showSuccess('Error deleting user. Please try again.', 'Error')
          }
        },
        'Delete',
        'Cancel'
      )
    }

    // Bulk Import Methods
    const handleCSVUpload = (event) => {
      const file = event.target.files[0]
      if (file && file.type === 'text/csv') {
        csvFile.value = file
        parseCSV(file)
      } else {
        showSuccess('Please select a valid CSV file.', 'Error')
      }
    }

    const handleCSVDrop = (event) => {
      event.preventDefault()
      const file = event.dataTransfer.files[0]
      if (file && file.type === 'text/csv') {
        csvFile.value = file
        parseCSV(file)
      } else {
        showSuccess('Please drop a valid CSV file.', 'Error')
      }
    }

    const parseCSV = (file) => {
      const reader = new FileReader()
      reader.onload = (e) => {
        const text = e.target.result
        const lines = text.split('\n').filter(line => line.trim())
        
        if (lines.length < 2) {
          showSuccess('CSV file appears to be empty or invalid.', 'Error')
          return
        }

        // Parse header and data
        const headers = lines[0].split(',').map(h => h.trim().toLowerCase())
        const requiredHeaders = ['title', 'barcode', 'category']
        
        // Check for required headers
        const missingHeaders = requiredHeaders.filter(h => !headers.includes(h))
        if (missingHeaders.length > 0) {
          showSuccess(`Missing required columns: ${missingHeaders.join(', ')}`, 'Error')
          return
        }

        // Parse data rows
        const data = []
        for (let i = 1; i < lines.length; i++) {
          const values = lines[i].split(',').map(v => v.trim().replace(/"/g, ''))
          const row = {}
          headers.forEach((header, index) => {
            row[header] = values[index] || ''
          })
          
          // Validate required fields
          if (row.title && row.barcode && row.category) {
            data.push(row)
          }
        }

        csvData.value = data
        csvPreview.value = data.slice(0, 10) // Show first 10 rows as preview
        
        if (data.length === 0) {
          showSuccess('No valid product data found in CSV.', 'Error')
        }
      }
      reader.readAsText(file)
    }

    const clearCSVData = () => {
      csvFile.value = null
      csvData.value = []
      csvPreview.value = []
      importProgress.value = 0
      importStatus.value = ''
    }

    const importCSVProducts = async () => {
      if (!csvData.value.length) return

      loading.value = true
      importProgress.value = 0
      
      try {
        const total = csvData.value.length
        let successful = 0
        let failed = 0

        for (let i = 0; i < csvData.value.length; i++) {
          const product = csvData.value[i]
          importStatus.value = `Importing product ${i + 1} of ${total}: ${product.title}`
          
          try {
            // Check if barcode already exists
            const { data: existing } = await supabase
              .from('products')
              .select('barcode')
              .eq('barcode', product.barcode)
              .single()

            if (!existing) {
              // Insert new product
              const { error } = await supabase
                .from('products')
                .insert([{
                  title: product.title,
                  barcode: product.barcode,
                  category: product.category,
                  image_url: '',
                  created_at: new Date().toISOString(),
                  updated_at: new Date().toISOString()
                }])

              if (error) {
                console.error('Error inserting product:', error)
                failed++
              } else {
                successful++
              }
            } else {
              console.log(`Product with barcode ${product.barcode} already exists, skipping`)
              failed++
            }
          } catch (error) {
            console.error('Error processing product:', error)
            failed++
          }

          importProgress.value = Math.round(((i + 1) / total) * 100)
        }

        importStatus.value = `Import complete: ${successful} successful, ${failed} failed/skipped`
        
        if (successful > 0) {
          await loadProducts()
          showSuccess(`Successfully imported ${successful} products! ${failed > 0 ? `${failed} products were skipped (duplicates or errors).` : ''}`)
        } else {
          showSuccess('No products were imported. All items may have been duplicates or had errors.', 'Import Complete')
        }

        // Clear form after successful import
        setTimeout(() => {
          clearCSVData()
        }, 2000)

      } catch (error) {
        console.error('Error during bulk import:', error)
        showSuccess('Error during bulk import. Please try again.', 'Error')
      } finally {
        loading.value = false
      }
    }

    const handleBulkImageUpload = (event) => {
      const files = Array.from(event.target.files)
      processImageFiles(files)
    }

    const handleImageDrop = (event) => {
      event.preventDefault()
      const files = Array.from(event.dataTransfer.files)
      processImageFiles(files)
    }

    const processImageFiles = (files) => {
      imageFiles.value = files
      const results = []

      files.forEach(file => {
        // Extract barcode from filename (remove extension)
        const barcode = file.name.replace(/\.[^/.]+$/, '')
        
        // Find matching product
        const matchingProduct = products.value.find(p => p.barcode === barcode)
        
        // Create preview URL
        const preview = URL.createObjectURL(file)
        
        results.push({
          file,
          filename: file.name,
          barcode,
          matched: !!matchingProduct,
          productTitle: matchingProduct?.title || null,
          productId: matchingProduct?.id || null,
          preview
        })
      })

      imageMatchResults.value = results
    }

    const uploadMatchedImages = async () => {
      const matchedResults = imageMatchResults.value.filter(r => r.matched)
      
      if (matchedResults.length === 0) {
        showSuccess('No matched images to upload.', 'Info')
        return
      }

      loading.value = true
      
      try {
        let successful = 0
        let failed = 0

        for (let i = 0; i < matchedResults.length; i++) {
          const result = matchedResults[i]
          importStatus.value = `Uploading image ${i + 1} of ${matchedResults.length}: ${result.filename}`
          
          try {
            // Upload image
            const fileName = `${Date.now()}_${result.file.name}`
            const imageUrl = await uploadImage(result.file, fileName)
            
            // Update product with image URL
            const { error } = await supabase
              .from('products')
              .update({
                image_url: imageUrl,
                updated_at: new Date().toISOString()
              })
              .eq('id', result.productId)

            if (error) {
              console.error('Error updating product image:', error)
              failed++
            } else {
              successful++
            }
          } catch (error) {
            console.error('Error uploading image:', error)
            failed++
          }

          importProgress.value = Math.round(((i + 1) / matchedResults.length) * 100)
        }

        importStatus.value = `Upload complete: ${successful} successful, ${failed} failed`
        
        if (successful > 0) {
          await loadProducts()
          showSuccess(`Successfully uploaded ${successful} images! ${failed > 0 ? `${failed} images failed to upload.` : ''}`)
        }

        // Clean up preview URLs
        imageMatchResults.value.forEach(result => {
          if (result.preview) {
            URL.revokeObjectURL(result.preview)
          }
        })

        // Clear form after successful upload
        setTimeout(() => {
          imageFiles.value = []
          imageMatchResults.value = []
          importProgress.value = 0
          importStatus.value = ''
        }, 2000)

      } catch (error) {
        console.error('Error during image upload:', error)
        showSuccess('Error during image upload. Please try again.', 'Error')
      } finally {
        loading.value = false
      }
    }

    // Helper Functions
    const getUserInitials = (name) => {
      if (!name) return '?'
      const parts = name.split(' ')
      if (parts.length === 1) {
        return parts[0].charAt(0).toUpperCase()
      }
      return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
    }

    const formatDate = (dateString) => {
      if (!dateString) return 'N/A'
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }

    // User Profile Dropdown Functions
    const toggleUserDropdown = () => {
      showUserDropdown.value = !showUserDropdown.value
    }

    const closeUserDropdown = () => {
      showUserDropdown.value = false
    }

    const openUserSettings = () => {
      // Initialize form with current user data
      userSettingsForm.value = {
        display_name: currentUserData.value?.display_name || userEmail.value?.split('@')[0] || '',
        current_password: '',
        new_password: '',
        confirm_password: ''
      }
      showUserSettings.value = true
      showUserDropdown.value = false
    }

    const openAdminSettings = () => {
      activeSection.value = 'settings'
      showUserDropdown.value = false
    }

    const closeUserSettings = () => {
      showUserSettings.value = false
      // Reset form
      userSettingsForm.value = {
        display_name: '',
        current_password: '',
        new_password: '',
        confirm_password: ''
      }
    }

    const updateUserSettings = async () => {
      loading.value = true
      try {
        console.log('Updating user settings...')

        // Validate password fields if changing password
        if (userSettingsForm.value.new_password) {
          if (!userSettingsForm.value.current_password) {
            showSuccess('Current password is required to change password.', 'Error')
            return
          }
          
          if (userSettingsForm.value.new_password !== userSettingsForm.value.confirm_password) {
            showSuccess('New passwords do not match.', 'Error')
            return
          }

          if (userSettingsForm.value.new_password.length < 6) {
            showSuccess('New password must be at least 6 characters.', 'Error')
            return
          }
        }

        // Update display name in Supabase
        if (currentUserData.value?.id) {
          const { error } = await supabase
            .from('users')
            .update({
              display_name: userSettingsForm.value.display_name,
              updated_at: new Date().toISOString()
            })
            .eq('id', currentUserData.value.id)

          if (error) {
            throw error
          }

          // Update local data
          currentUserData.value.display_name = userSettingsForm.value.display_name
        }

        // Handle password change if requested
        if (userSettingsForm.value.new_password) {
          try {
            // Re-authenticate user with current password
            const { signInWithEmailAndPassword, updatePassword } = await import('firebase/auth')
            
            await signInWithEmailAndPassword(
              auth, 
              auth.currentUser.email, 
              userSettingsForm.value.current_password
            )

            // Update password
            await updatePassword(auth.currentUser, userSettingsForm.value.new_password)
            
            showSuccess('Settings updated successfully! Password has been changed.')
          } catch (passwordError) {
            console.error('Password update error:', passwordError)
            
            let errorMessage = 'Error updating password.'
            
            if (passwordError.code === 'auth/wrong-password') {
              errorMessage = 'Current password is incorrect.'
            } else if (passwordError.code === 'auth/weak-password') {
              errorMessage = 'New password is too weak.'
            } else if (passwordError.message) {
              errorMessage = `Password error: ${passwordError.message}`
            }
            
            showSuccess(errorMessage, 'Error')
            return
          }
        } else {
          showSuccess('Display name updated successfully!')
        }

        closeUserSettings()
      } catch (error) {
        console.error('Error updating user settings:', error)
        showSuccess('Error updating settings. Please try again.', 'Error')
      } finally {
        loading.value = false
      }
    }

    // Custom dialog functions
    const showConfirm = (title, message, onConfirm, confirmText = 'OK', cancelText = 'Cancel') => {
      return new Promise((resolve) => {
        confirmDialog.value = {
          title,
          message,
          confirmText,
          cancelText,
          onConfirm: () => {
            showConfirmDialog.value = false
            if (onConfirm) onConfirm()
            resolve(true)
          },
          onCancel: () => {
            showConfirmDialog.value = false
            resolve(false)
          }
        }
        showConfirmDialog.value = true
      })
    }

    const showSuccess = (message, title = 'Success') => {
      successMessage.value = { title, message }
      showSuccessMessage.value = true
    }

    const closeSuccessMessage = () => {
      showSuccessMessage.value = false
    }

    const logout = async () => {
      try {
        await signOut(auth)
        router.push('/')
      } catch (error) {
        console.error('Error logging out:', error)
      }
    }

    // Lifecycle
    onMounted(async () => {
      console.log('Dashboard mounted')
      console.log('Auth state:', auth.currentUser)
      console.log('Config check:', {
        firebaseAuthDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
        firebaseProjectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
        supabaseUrl: import.meta.env.VITE_SUPABASE_URL,
        supabaseAnonKey: import.meta.env.VITE_SUPABASE_ANON_KEY ? 'Set' : 'Not set'
      })
      
      // Check if user is authenticated
      if (!auth.currentUser) {
        console.warn('User not authenticated, redirecting to login')
        router.push('/')
        return
      }
      
      console.log('User authenticated:', auth.currentUser.email)
      
      // Load user role first, then load data based on permissions
      await loadCurrentUserRole()
      
      if (canViewStock.value) {
        loadProducts()
      }
      
      if (canManageUsers.value) {
        loadUsers()
      }
      
      // Load categories for all users (needed for product forms)
      loadCategories()
    })

          return {
        // Core state
        products,
        users,
        categories,
        currentUserRole,
        currentUserData,
        loading,
        searchTerm,
        userSearchTerm,
        categorySearchTerm,
        activeSection,
        adminActiveTab,
        
        // Product management
        showAddProduct,
        showEditProduct,
        showBulkImport,
        selectedProducts,
        newProduct,
        editingProduct,
        
        // Bulk import
        bulkImportActiveTab,
        csvFile,
        csvData,
        csvPreview,
        imageFiles,
        importProgress,
        importStatus,
        imageMatchResults,
        
        // User management
        showAddUser,
        showEditUser,
        showUserSettings,
        showUserDropdown,
        selectedUsers,
        newUser,
        editingUser,
        userSettingsForm,
        
        // Category management
        showAddCategory,
        showEditCategory,
        selectedCategories,
        newCategory,
        editingCategory,
        
        // User info
        userEmail,
        userAvatar,
        
        // Statistics
        totalProducts,
        totalCategories,
        recentProducts,
        
        // Computed
        filteredProducts,
        filteredUsers,
        filteredCategories,
        
        // Permissions
        canViewStock,
        canAddStock,
        canEditStock,
        canDeleteStock,
        canManageUsers,
        canAccessSettings,
        
        // Modals
        showConfirmDialog,
        showSuccessMessage,
        confirmDialog,
        successMessage,
        
        // Product methods
        handleImageUpload,
        handleEditImageUpload,
        addProduct,
        editProduct,
        updateProduct,
        deleteProduct,
        toggleSelectAll,
        
        // Bulk import methods
        handleCSVUpload,
        handleCSVDrop,
        parseCSV,
        clearCSVData,
        importCSVProducts,
        handleBulkImageUpload,
        handleImageDrop,
        processImageFiles,
        uploadMatchedImages,
        
        // User methods
        addUser,
        editUser,
        updateUser,
        deleteUser,
        toggleSelectAllUsers,
        getUserInitials,
        formatDate,
        loadCurrentUserRole,
        
        // Category methods
        loadCategories,
        addCategory,
        editCategory,
        updateCategory,
        deleteCategory,
        toggleSelectAllCategories,
        
        // User profile dropdown
        toggleUserDropdown,
        closeUserDropdown,
        openUserSettings,
        openAdminSettings,
        closeUserSettings,
        updateUserSettings,
        
        // Utility methods
        showConfirm,
        showSuccess,
        closeSuccessMessage,
        logout
      }
  }
}
</script>

<style scoped>
* {
  box-sizing: border-box;
}

.dashboard {
  min-height: 100vh;
  background: #1a1d29;
  color: white;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
}

/* Top Navigation */
.top-nav {
  background: #242838;
  border-bottom: 1px solid #2d3748;
  padding: 0;
}

.nav-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
  height: 64px;
}

.logo-section {
  display: flex;
  align-items: center;
}

.logo {
  height: 32px;
  width: auto;
  border-radius: 6px;
}

.nav-tabs {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.nav-tab {
  padding: 0.5rem 1rem;
  background: none;
  border: none;
  color: #94a3b8;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.2s;
}

.nav-tab:hover {
  color: white;
  background: rgba(255,255,255,0.05);
}

.nav-tab.active {
  background: #f97316;
  color: white;
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.search-btn, .notification-btn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: none;
  background: rgba(255,255,255,0.05);
  color: #94a3b8;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.search-btn:hover, .notification-btn:hover {
  background: rgba(255,255,255,0.1);
  color: white;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.user-display-name {
  font-size: 0.875rem;
  color: #e2e8f0;
  margin: 0;
  font-weight: 500;
}

.user-role {
  font-size: 0.75rem;
  color: #94a3b8;
  text-transform: capitalize;
}

.user-dropdown-container {
  position: relative;
}

.user-dropdown-btn {
  background: none;
  border: none;
  color: #94a3b8;
  cursor: pointer;
  padding: 0.25rem;
  transition: color 0.2s;
}

.user-dropdown-btn:hover {
  color: white;
}

.user-dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  background: #242838;
  border: 1px solid #2d3748;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  min-width: 180px;
  z-index: 1000;
  margin-top: 0.5rem;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  width: 100%;
  padding: 0.75rem 1rem;
  background: none;
  border: none;
  color: #e2e8f0;
  text-align: left;
  cursor: pointer;
  font-size: 0.875rem;
  transition: background-color 0.2s;
  white-space: nowrap;
}

.dropdown-item:hover {
  background: rgba(255, 255, 255, 0.1);
}

.dropdown-item:first-child {
  border-radius: 8px 8px 0 0;
}

.dropdown-item:last-child {
  border-radius: 0 0 8px 8px;
}

.admin-item {
  border-top: 1px solid #2d3748;
  color: #f97316;
}

.admin-item:hover {
  background: rgba(249, 115, 22, 0.1);
}

.logout-item {
  border-top: 1px solid #2d3748;
  color: #f87171;
}

.logout-item:hover {
  background: rgba(248, 113, 113, 0.1);
}

.dropdown-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 999;
}

/* Main Content */
.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.content-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.content-header h1 {
  font-size: 2rem;
  font-weight: 700;
  margin: 0;
  color: white;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.back-btn {
  background: none;
  border: 1px solid #2d3748;
  color: #94a3b8;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 0.875rem;
  cursor: pointer;
  transition: all 0.2s;
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.05);
  color: white;
  border-color: #4a5568;
}

/* Admin Tabs */
.admin-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  border-bottom: 1px solid #2d3748;
}

.admin-tab {
  padding: 0.75rem 1.5rem;
  background: none;
  border: none;
  color: #94a3b8;
  font-weight: 500;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  transition: all 0.2s;
}

.admin-tab:hover {
  color: white;
}

.admin-tab.active {
  color: #f97316;
  border-bottom-color: #f97316;
}

/* Category Management Styles */
.category-name {
  font-weight: 600;
  color: white;
  font-size: 0.875rem;
  margin: 0;
  padding: 0;
  line-height: 1.4;
  display: inline;
}

.user-email {
  color: #94a3b8;
  font-size: 0.875rem;
  margin: 0;
  padding: 0;
  line-height: 1.4;
  display: inline;
}

.user-created {
  color: #94a3b8;
  font-size: 0.875rem;
  margin: 0;
  padding: 0;
  line-height: 1.4;
  display: inline;
}

.category-created {
  color: #94a3b8;
  font-size: 0.875rem;
  margin: 0;
  padding: 0;
  line-height: 1.4;
  display: inline;
}



.add-product-btn {
  background: #f97316;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.add-product-btn:hover {
  background: #ea580c;
  transform: translateY(-1px);
}

/* Statistics Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background: #242838;
  border-radius: 12px;
  padding: 1.5rem;
  border: 1px solid #2d3748;
}

.stat-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.stat-info h3 {
  font-size: 0.875rem;
  color: #94a3b8;
  margin: 0 0 0.5rem 0;
  font-weight: 500;
}

.stat-number {
  font-size: 2rem;
  font-weight: 700;
  color: white;
  margin-bottom: 0.5rem;
}

.stat-change {
  font-size: 0.75rem;
  color: #10b981;
}

.stat-change.neutral {
  color: #94a3b8;
}

.stat-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
  color: white;
}

.stat-icon.total { background: #f97316; }
.stat-icon.categories { background: #3b82f6; }
.stat-icon.recent { background: #10b981; }

/* Table Section */
.table-section {
  background: #242838;
  border-radius: 12px;
  border: 1px solid #2d3748;
  overflow: hidden;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #2d3748;
}

.table-tabs {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.table-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: white;
  margin-right: 1rem;
}

.tab-btn {
  padding: 0.5rem 1rem;
  background: none;
  border: none;
  color: #94a3b8;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s;
}

.tab-btn:hover {
  color: white;
  background: rgba(255,255,255,0.05);
}

.tab-btn.active {
  background: #3b82f6;
  color: white;
}

.table-actions {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.search-box {
  position: relative;
}

.search-input {
  background: #1a1d29;
  border: 1px solid #2d3748;
  color: white;
  padding: 0.5rem 2.5rem 0.5rem 1rem;
  border-radius: 8px;
  width: 200px;
  font-size: 0.875rem;
}

.search-input::placeholder {
  color: #64748b;
}

.search-icon {
  position: absolute;
  right: 0.75rem;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
}

.filter-btn {
  background: #1a1d29;
  border: 1px solid #2d3748;
  color: #94a3b8;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.875rem;
  transition: all 0.2s;
}

.filter-btn:hover {
  background: rgba(255,255,255,0.05);
  color: white;
}

/* Products Table */
.products-table {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th {
  background: #2d3748;
  padding: 1rem;
  text-align: left;
  font-size: 0.875rem;
  font-weight: 600;
  color: #94a3b8;
  white-space: nowrap;
  vertical-align: middle;
  border-bottom: 1px solid #374151;
}

.product-row {
  border-bottom: 1px solid #2d3748;
  transition: all 0.2s;
}

.product-row:hover {
  background: rgba(255,255,255,0.02);
}

td {
  padding: 1rem;
  vertical-align: middle;
  border-bottom: 1px solid #2d3748;
  color: #e2e8f0;
}

/* Table Column Layout with Checkbox */
.checkbox-col {
  width: 5%;
  min-width: 50px;
  text-align: center;
}

.checkbox-col input[type="checkbox"] {
  width: 16px;
  height: 16px;
  accent-color: #f97316;
  cursor: pointer;
}

/* Center-align specific column headers */
th.checkbox-col,
th.image-col,
th.action-col {
  text-align: center;
}

/* Ensure table cell alignment matches headers */
td.checkbox-col,
td.action-col {
  text-align: center;
}

td.name-col,
td.title-col,
td.email-col,
td.barcode-col,
td.category-col,
td.role-col,
td.created-col,
td.status-col {
  text-align: left;
}

.image-col {
  width: 12%;
  min-width: 80px;
  text-align: center;
}

.title-col {
  width: 33%;
  min-width: 200px;
  text-align: left;
}

.barcode-col {
  width: 20%;
  min-width: 120px;
  text-align: left;
}

.category-col {
  width: 20%;
  min-width: 120px;
  text-align: left;
}

.product-image {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  object-fit: cover;
  background: #374151;
}

.product-title {
  font-weight: 600;
  color: white;
  font-size: 0.875rem;
  margin: 0;
  padding: 0;
  line-height: 1.4;
  display: inline;
}

.product-barcode {
  color: #94a3b8;
  font-family: 'Courier New', monospace;
  font-size: 0.875rem;
  margin: 0;
  padding: 0;
  line-height: 1.4;
  display: inline;
}

.product-category {
  color: #e2e8f0;
  font-size: 0.875rem;
  margin: 0;
  padding: 0;
  line-height: 1.4;
  display: inline;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 16px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: capitalize;
}

.status-badge.active {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
  border: 1px solid rgba(16, 185, 129, 0.2);
}

.status-badge.deactive {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.2);
}

.action-col {
  width: 10%;
  min-width: 80px;
  text-align: center;
}

.action-btn {
  background: none;
  border: none;
  padding: 0.5rem;
  cursor: pointer;
  border-radius: 6px;
  transition: all 0.2s;
  font-size: 1rem;
  color: #94a3b8;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
}

.action-btn:hover {
  background: rgba(255,255,255,0.1);
  color: white;
}

.edit-btn:hover {
  background: rgba(59, 130, 246, 0.1);
  color: #60a5fa;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: #64748b;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.empty-state h3 {
  color: white;
  margin: 1rem 0;
}

/* Modal Overlay */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background: #242838;
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  border: 1px solid #2d3748;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #2d3748;
}

.modal-header h2 {
  margin: 0;
  color: white;
  font-size: 1.25rem;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #64748b;
  padding: 0.5rem;
  border-radius: 6px;
  transition: all 0.2s;
}

.close-btn:hover {
  background: rgba(255,255,255,0.1);
  color: white;
}

/* Product Form */
.product-form {
  padding: 1.5rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.form-row:first-child {
  grid-template-columns: 1fr;
}

.form-row:last-child {
  grid-template-columns: 1fr;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  font-size: 0.875rem;
  font-weight: 600;
  color: #e2e8f0;
  margin-bottom: 0.5rem;
}

.form-input, .file-input {
  background: #1a1d29;
  border: 1px solid #2d3748;
  color: white;
  padding: 0.75rem;
  border-radius: 8px;
  font-size: 0.875rem;
  transition: all 0.2s;
}

.form-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.image-preview {
  margin-top: 1rem;
  text-align: center;
}

.image-preview img {
  max-width: 200px;
  max-height: 200px;
  border-radius: 8px;
  object-fit: cover;
  border: 1px solid #2d3748;
}

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid #2d3748;
}

.cancel-btn, .submit-btn, .delete-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.875rem;
  transition: all 0.2s;
}

.cancel-btn {
  background: #374151;
  color: white;
}

.cancel-btn:hover {
  background: #4b5563;
}

.delete-btn {
  background: #dc2626;
  color: white;
}

.delete-btn:hover {
  background: #b91c1c;
}

.submit-btn {
  background: #f97316;
  color: white;
}

.submit-btn:hover:not(:disabled) {
  background: #ea580c;
}

.submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* User Management Styles */
.user-info-cell {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.user-avatar-small {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #f97316, #ea580c);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 0.875rem;
}

.user-details {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-weight: 600;
  color: white;
  font-size: 0.875rem;
}

.user-subtitle {
  color: #94a3b8;
  font-size: 0.75rem;
}

.role-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.75rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 500;
  text-transform: capitalize;
}

.role-badge.admin {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.2);
}

.role-badge.lister {
  background: rgba(249, 115, 22, 0.1);
  color: #f97316;
  border: 1px solid rgba(249, 115, 22, 0.2);
}

.role-badge.user {
  background: rgba(34, 197, 94, 0.1);
  color: #22c55e;
  border: 1px solid rgba(34, 197, 94, 0.2);
}

/* Table column widths for user table */
.name-col {
  width: 25%;
  min-width: 200px;
}

.email-col {
  width: 25%;
  min-width: 180px;
}

.role-col {
  width: 15%;
  min-width: 100px;
}

.created-col {
  width: 15%;
  min-width: 120px;
}

.status-col {
  width: 10%;
  min-width: 100px;
}

.no-action {
  color: #94a3b8;
  font-style: italic;
}

/* User Settings Modal Styles */
.form-section {
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid #2d3748;
}

.section-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: white;
  margin: 0 0 0.5rem 0;
}

.section-subtitle {
  font-size: 0.875rem;
  color: #94a3b8;
  margin: 0 0 1rem 0;
}

/* Header Actions */
.header-actions {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.bulk-import-btn {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.bulk-import-btn:hover {
  background: #2563eb;
  transform: translateY(-1px);
}

/* Large Modal */
.large-modal {
  max-width: 800px;
  width: 95%;
}

/* Import Tabs */
.import-tabs {
  display: flex;
  border-bottom: 1px solid #2d3748;
  background: #1a1d29;
}

.import-tab {
  padding: 1rem 1.5rem;
  background: none;
  border: none;
  color: #94a3b8;
  font-weight: 500;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.import-tab:hover {
  color: white;
  background: rgba(255, 255, 255, 0.05);
}

.import-tab.active {
  color: #3b82f6;
  border-bottom-color: #3b82f6;
  background: rgba(59, 130, 246, 0.1);
}

/* Import Content */
.import-content {
  padding: 2rem;
  min-height: 400px;
}

/* Upload Section */
.csv-upload-section, .image-upload-section {
  text-align: center;
}

.upload-info {
  margin-bottom: 2rem;
}

.upload-info h3 {
  color: white;
  margin-bottom: 1rem;
  font-size: 1.25rem;
}

.upload-info p {
  color: #94a3b8;
  margin-bottom: 0.5rem;
}

.upload-note {
  font-size: 0.875rem;
  color: #64748b;
  font-style: italic;
}

/* File Upload Area */
.file-upload-area {
  border: 2px dashed #2d3748;
  border-radius: 12px;
  padding: 3rem 2rem;
  cursor: pointer;
  transition: all 0.2s;
  background: rgba(255, 255, 255, 0.02);
}

.file-upload-area:hover {
  border-color: #3b82f6;
  background: rgba(59, 130, 246, 0.05);
}

.file-input-hidden {
  display: none;
}

.upload-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.upload-icon {
  font-size: 3rem;
  color: #64748b;
}

.upload-link {
  background: none;
  border: none;
  color: #3b82f6;
  text-decoration: underline;
  cursor: pointer;
  font-weight: 500;
}

.upload-link:hover {
  color: #2563eb;
}

/* CSV Preview */
.csv-preview-section {
  margin-top: 2rem;
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.preview-header h3 {
  color: white;
  margin: 0;
}

.preview-actions {
  display: flex;
  gap: 1rem;
}

.secondary-btn {
  background: #374151;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.875rem;
}

.secondary-btn:hover {
  background: #4b5563;
}

.import-btn {
  background: #10b981;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.875rem;
  font-weight: 600;
}

.import-btn:hover:not(:disabled) {
  background: #059669;
}

.import-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* CSV Preview Table */
.csv-preview-table {
  background: #1a1d29;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #2d3748;
  max-height: 300px;
  overflow-y: auto;
}

.csv-preview-table table {
  width: 100%;
  border-collapse: collapse;
}

.csv-preview-table th {
  background: #2d3748;
  padding: 0.75rem;
  text-align: left;
  font-size: 0.875rem;
  font-weight: 600;
  color: #94a3b8;
  position: sticky;
  top: 0;
}

.csv-preview-table td {
  padding: 0.75rem;
  border-bottom: 1px solid #2d3748;
  color: #e2e8f0;
  font-size: 0.875rem;
}

/* Import Progress */
.import-progress {
  margin-top: 2rem;
  text-align: center;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: #2d3748;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 1rem;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #3b82f6, #10b981);
  transition: width 0.3s ease;
}

.import-progress p {
  color: #94a3b8;
  font-size: 0.875rem;
}

/* Image Match Results */
.image-match-results {
  margin-top: 2rem;
}

.match-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.match-header h3 {
  color: white;
  margin: 0;
}

.match-summary {
  display: flex;
  gap: 2rem;
  justify-content: center;
  margin-bottom: 2rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.02);
  border-radius: 8px;
}

.match-stat {
  text-align: center;
}

.match-count {
  display: block;
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
}

.match-count.success {
  color: #10b981;
}

.match-count.warning {
  color: #f59e0b;
}

.match-stat span:last-child {
  color: #94a3b8;
  font-size: 0.875rem;
}

/* Match List */
.match-list {
  max-height: 400px;
  overflow-y: auto;
  border: 1px solid #2d3748;
  border-radius: 8px;
}

.match-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-bottom: 1px solid #2d3748;
  background: rgba(239, 68, 68, 0.05);
}

.match-item.matched {
  background: rgba(16, 185, 129, 0.05);
}

.match-item:last-child {
  border-bottom: none;
}

.match-info {
  flex: 1;
}

.match-info strong {
  color: white;
  display: block;
  margin-bottom: 0.25rem;
}

.match-status {
  font-size: 0.875rem;
}

.match-status.success {
  color: #10b981;
}

.match-status.error {
  color: #ef4444;
}

.match-preview {
  width: 60px;
  height: 60px;
  border-radius: 6px;
  object-fit: cover;
  border: 1px solid #2d3748;
}

/* Responsive Design */
@media (max-width: 768px) {
  .nav-content {
    padding: 0 1rem;
  }

  .nav-tabs {
    display: none;
  }

  .main-content {
    padding: 1rem;
  }

  .content-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .table-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }

  .table-actions {
    justify-content: center;
  }

  .search-input {
    width: 100%;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .form-actions {
    flex-direction: column;
  }
}

/* Custom Modal Styles */
.custom-modal {
  background: #242838;
  border-radius: 12px;
  width: 90%;
  max-width: 400px;
  border: 1px solid #2d3748;
  box-shadow: 0 10px 25px rgba(0,0,0,0.5);
  animation: modalSlideIn 0.3s ease-out;
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.custom-modal-header {
  padding: 1.5rem 1.5rem 1rem;
  border-bottom: 1px solid #2d3748;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.modal-icon {
  font-size: 1.5rem;
  flex-shrink: 0;
}

.custom-modal-header h3 {
  margin: 0;
  color: #e2e8f0;
  font-size: 1.25rem;
  font-weight: 600;
}

.custom-modal-body {
  padding: 1.5rem;
}

.custom-modal-body p {
  margin: 0;
  color: #94a3b8;
  line-height: 1.5;
  white-space: pre-line;
}

.custom-modal-actions {
  padding: 1rem 1.5rem 1.5rem;
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}

.modal-cancel-btn, .modal-confirm-btn, .modal-ok-btn {
  padding: 0.75rem 1.5rem;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.875rem;
  transition: all 0.2s;
  min-width: 80px;
}

.modal-cancel-btn {
  background: #374151;
  color: white;
}

.modal-cancel-btn:hover {
  background: #4b5563;
}

.modal-confirm-btn {
  background: #dc2626;
  color: white;
}

.modal-confirm-btn:hover {
  background: #b91c1c;
}

.modal-ok-btn {
  background: #f97316;
  color: white;
}

.modal-ok-btn:hover {
  background: #ea580c;
}

/* Success modal specific styling */
.success-modal .custom-modal-header h3 {
  color: #10b981;
}

.success-modal .custom-modal-header {
  border-bottom-color: rgba(16, 185, 129, 0.2);
}

/* Error modal styling */
.error-modal .custom-modal-header h3 {
  color: #ef4444;
}

.error-modal .custom-modal-header {
  border-bottom-color: rgba(239, 68, 68, 0.2);
}
</style> 