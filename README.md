## הפעלה מהירה

יש שתי אפשרויות:

1) מצב פיתוח (Hot reload):

```
START_ALL.bat
```

זה מפעיל Backend על פורט 4000 ו-Frontend (Vite dev) על 5173, ופותח דפדפן.

2) בנייה והפעלה מהבנייה (Preview):

```
BUILD-AND-START.bat
```

הסקריפט יתקין תלויות, יבנה את ה-Frontend ויפעיל Vite Preview על 5173, וה-Backend ירוץ על 4000.

# Base44 App


This app was created automatically by Base44.
It's a Vite+React app that communicates with the Base44 API.

## Running the app

```bash
npm install
npm run dev
```

## Building the app

```bash
npm run build
```

For more information and support, please contact Base44 support at app@base44.com.