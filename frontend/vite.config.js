import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5672,
  },
  preview: {
    port: 5672,
    host: true,
  },
});
