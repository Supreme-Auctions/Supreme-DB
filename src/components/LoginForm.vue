<template>
  <div class="login-container">
    <!-- Background Pattern -->
    <div class="background-pattern">
      <div class="pattern-grid"></div>
      <div class="pattern-dots"></div>
    </div>
    
    <div class="login-card">
      <!-- Header with Logo -->
      <div class="card-header">
        <div class="logo-section">
          <img src="/images/images.png" alt="Supreme Logo" class="logo">
        </div>
        <div class="header-text">
      <h2 class="welcome-text">Welcome Back</h2>
          <p class="subtitle">Sign in to your account to continue</p>
        </div>
      </div>

      <!-- Login Form -->
      <form @submit.prevent="handleLogin" class="login-form">
      <div class="form-group">
          <label for="email">Email Address</label>
          <input 
            type="email" 
            id="email" 
            v-model="email" 
            placeholder="Enter your email" 
            class="form-input"
            required
          >
      </div>
      
      <div class="form-group">
          <label for="password">Password</label>
          <input 
            type="password" 
            id="password" 
            v-model="password" 
            placeholder="Enter your password" 
            class="form-input"
            required
          >
        </div>
        
        <button type="submit" class="login-button" :disabled="loading">
          {{ loading ? 'Signing in...' : 'Sign In' }}
        </button>
      </form>

      <!-- Footer -->
      <div class="card-footer">
        <p class="info-text">
          Access is managed by your administrator
        </p>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import { auth } from '@/firebase';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { useRouter } from 'vue-router';

export default {
  setup() {
    const email = ref('');
    const password = ref('');
    const loading = ref(false);
    const router = useRouter();

    const handleLogin = async () => {
      if (!email.value || !password.value) {
        alert('Please fill in all fields');
        return;
      }

      loading.value = true;
      try {
        await signInWithEmailAndPassword(auth, email.value, password.value);
        router.push('/dashboard');
      } catch (error) {
        console.error('Error during login:', error);
        let errorMessage = 'Login failed. Please try again.';
        
        if (error.code === 'auth/user-not-found') {
          errorMessage = 'No account found with this email address.';
        } else if (error.code === 'auth/wrong-password') {
          errorMessage = 'Incorrect password. Please try again.';
        } else if (error.code === 'auth/invalid-email') {
          errorMessage = 'Please enter a valid email address.';
        } else if (error.code === 'auth/too-many-requests') {
          errorMessage = 'Too many failed attempts. Please try again later.';
        }
        
        alert(errorMessage);
      } finally {
        loading.value = false;
      }
    };

    return {
      email,
      password,
      loading,
      handleLogin
    };
  }
};
</script>

<style scoped>
* {
  box-sizing: border-box;
}

.login-container {
  min-height: 100vh;
  background: #1a1d29;
  color: white;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

/* Background Pattern */
.background-pattern {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0.03;
  pointer-events: none;
}

.pattern-grid {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: 
    linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px);
  background-size: 50px 50px;
  animation: gridMove 20s linear infinite;
}

.pattern-dots {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
  height: 100%;
  background-image: radial-gradient(circle, rgba(255,255,255,0.1) 1px, transparent 1px);
  background-size: 30px 30px;
  animation: dotsMove 25s linear infinite reverse;
}

@keyframes gridMove {
  0% { transform: translate(0, 0); }
  100% { transform: translate(50px, 50px); }
}

@keyframes dotsMove {
  0% { transform: translate(0, 0); }
  100% { transform: translate(30px, 30px); }
}

/* Login Card */
.login-card {
  background: #242838;
  border: 1px solid #2d3748;
  border-radius: 16px;
  padding: 2.5rem;
  width: 100%;
  max-width: 420px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3), 0 10px 10px -5px rgba(0, 0, 0, 0.2);
  position: relative;
  z-index: 1;
  animation: cardSlideIn 0.5s ease-out;
}

@keyframes cardSlideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Header */
.card-header {
  text-align: center;
  margin-bottom: 2rem;
}

.logo-section {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.logo {
  max-width: 280px;
  height: auto;
  border-radius: 8px;
}

.header-text {
  margin-bottom: 1rem;
}

.welcome-text {
  font-size: 1.75rem;
  font-weight: 700;
  color: #e2e8f0;
  margin: 0 0 0.5rem 0;
}

.subtitle {
  color: #94a3b8;
  margin: 0;
  font-size: 0.95rem;
}

/* Form */
.login-form {
  margin-bottom: 1.5rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #e2e8f0;
  font-size: 0.875rem;
}

.form-input {
  width: 100%;
  background: #1a1d29;
  border: 1px solid #2d3748;
  color: white;
  padding: 0.875rem 1rem;
  border-radius: 8px;
  font-size: 0.95rem;
  transition: all 0.2s;
}

.form-input:focus {
  outline: none;
  border-color: #f97316;
  box-shadow: 0 0 0 3px rgba(249, 115, 22, 0.1);
}

.form-input::placeholder {
  color: #64748b;
}

.login-button {
  width: 100%;
  background: #f97316;
  color: white;
  border: none;
  padding: 0.875rem 1rem;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  margin-top: 0.5rem;
}

.login-button:hover:not(:disabled) {
  background: #ea580c;
  transform: translateY(-1px);
}

.login-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

/* Footer */
.card-footer {
  text-align: center;
  padding-top: 1.5rem;
  border-top: 1px solid #2d3748;
}

.info-text {
  color: #94a3b8;
  font-size: 0.875rem;
  margin: 0;
}

/* Responsive Design */
@media (max-width: 480px) {
  .login-card {
    margin: 1rem;
    padding: 2rem;
}

  .logo {
    max-width: 240px;
  }

  .welcome-text {
    font-size: 1.5rem;
  }
}
</style> 