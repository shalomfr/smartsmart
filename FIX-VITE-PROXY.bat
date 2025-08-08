@echo off
chcp 65001 >nul
cls
color 0A
echo ****************************************************
echo *      הוספת Proxy ל-Vite Config                  *
echo ****************************************************
echo.

echo [1] יוצר vite.config.js עם proxy...
echo ====================================
(
echo import { defineConfig } from 'vite'
echo import react from '@vitejs/plugin-react'
echo import path from 'path'
echo.
echo export default defineConfig({
echo   base: './',
echo   plugins: [react()],
echo   server: {
echo     allowedHosts: true,
echo     proxy: {
echo       '/api': {
echo         target: 'http://localhost:4000',
echo         changeOrigin: true
echo       }
echo     }
echo   },
echo   resolve: {
echo     alias: {
echo       '@': path.resolve(__dirname, './src'),
echo     },
echo     extensions: ['.mjs', '.js', '.jsx', '.ts', '.tsx', '.json']
echo   },
echo   optimizeDeps: {
echo     esbuildOptions: {
echo       loader: {
echo         '.js': 'jsx',
echo       },
echo     },
echo   },
echo })
) > vite.config.js

echo.
echo [2] מעלה לשרת...
echo =================
scp vite.config.js root@31.97.129.5:/home/emailapp/site2/

echo.
echo [3] בונה מחדש...
echo ================
ssh root@31.97.129.5 "cd /home/emailapp/site2 && npm run build"

echo.
echo [4] מפעיל מחדש...
echo =================
ssh root@31.97.129.5 "pm2 restart site2-frontend"

echo.
echo ****************************************************
echo *           Proxy הוגדר בהצלחה!                   *
echo ****************************************************
echo.
echo עכשיו הבקשות ל-/api יועברו אוטומטית ל-Backend
echo.
pause