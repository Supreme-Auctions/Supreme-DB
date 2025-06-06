import { createRouter, createWebHistory } from 'vue-router';
import { auth } from '@/firebase';
import LoginForm from '@/components/LoginForm.vue';
import ProductDashboard from '@/components/ProductDashboard.vue';

const routes = [
  {
    path: '/',
    name: 'Login',
    component: LoginForm
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: ProductDashboard,
    meta: {
      requiresAuth: true
    }
  }
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
});

// Navigation guard for authentication
router.beforeEach((to, from, next) => {
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth);
  const isAuthenticated = auth.currentUser;

  if (requiresAuth && !isAuthenticated) {
    next('/');
  } else if (to.path === '/' && isAuthenticated) {
    next('/dashboard');
  } else {
    next();
  }
});

export default router; 