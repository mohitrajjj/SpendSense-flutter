# SpendSense

A personal expense tracker built as a Flutter Progressive Web App — you can install it straight from the browser without an app store, and it works offline.

## What it does

- Log and categorize expenses
- Set budget limits by category and track against them
- Visual spend breakdowns using fl_chart
- Export expense reports as PDF
- Works offline — data is stored locally in the browser, so there's no dependency on a server connection
- Installable as a PWA — add it to your home screen like a native app

## Tech stack

- Flutter, targeting the web as a Progressive Web App
- Provider for state management
- Local browser storage (localStorage) for offline-first data persistence
- fl_chart for the analytics views

## Running it locally

```bash
flutter pub get
flutter run -d chrome
```

Build for production:

```bash
flutter build web
```

## About me

Mohit Raj. [GitHub](https://github.com/mohitrajjj) · [LinkedIn](https://linkedin.com/in/mohit-rajj)
