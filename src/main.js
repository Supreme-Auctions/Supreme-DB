import { createApp } from 'vue';
import App from './App.vue';
import router from './router'; // Import the router

const app = createApp(App);

app.use(router); // Use the router

app.mount('#app');

// Add global styles to remove default body/html margin
const globalStyles = document.createElement('style');
globalStyles.innerHTML = `
  html,
  body {
    margin: 0;
    padding: 0;
    overflow: hidden; /* Prevent scrollbars if background elements overflow */
  }
`;
document.head.appendChild(globalStyles); 