# PBD Group - Real-Time PDF Editor Tools

![Flutter](https://img.shields.io/badge/Flutter-3.11.5+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-Pattern-8A2BE2?style=for-the-badge)
![License](https://img.shields.io/badge/License-Proprietary-DD0000?style=for-the-badge)

A powerful, enterprise-grade **Real-Time PDF Editor & Document Collaboration Platform** designed specifically for the users, team members, and enterprise workflows of **PBD Group**.

---

## 📌 Overview

The **PBD Group Real-Time PDF Editor** provides a seamless mobile and cross-platform experience for viewing, editing, annotating, signing, and managing PDF documents live. Whether handling real-estate contracts, architectural plans, business agreements, or operational reports, PBD Group team members can collaborate in real time with instant synchronization, cloud-backed storage, and robust security.

---

## ✨ Key Features

* 📄 **Real-Time PDF Editing & Annotation**
  * Live text editing, markups, highlighting, freehand drawing, and stamp additions.
  * Form field filling, digital signature insertion, and page reordering.
  * Real-time sync across multi-user sessions for collaborative review.

* 🎨 **Official PBD Group Brand Identity**
  * Built using the official PBD Group color palette — Crimson Red (`#DD0000`) and Royal Navy Blue (`#002A82`).
  * Adaptive **Light Mode** and **Dark Mode** themes for effortless reading in any environment.
  * Responsive layout with custom typography (Lato font family) and modern Material 3 design elements.

* 📊 **Business Analytics & Executive Dashboard**
  * Interactive business metrics, charts, and performance graphs (`fl_chart`).
  * Real-time tracking of document revision statuses, pending approvals, and active workflows.

* 🔔 **Real-Time Push Notifications**
  * Integrated Firebase Cloud Messaging (FCM) & local notifications for instant updates on document modifications, shared files, and review requests.

* 🔐 **Enterprise Security & Encrypted Storage**
  * Encrypted storage for session tokens and sensitive preferences via `encrypt_shared_preferences`.
  * Secure API network layer built on `dio` with automated token refresh and retry interceptors.

---

## 🛠️ Tech Stack & Architecture

| Layer | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) (Dart SDK `^3.11.5`) |
| **State Management & Navigation** | [GetX](https://pub.dev/packages/get) |
| **Networking** | [Dio](https://pub.dev/packages/dio) HTTP Client with custom interceptors |
| **Analytics & Data Visualization** | [FL Chart](https://pub.dev/packages/fl_chart) |
| **Encrypted Storage** | Encrypted Shared Preferences |
| **Push Notifications** | Firebase Messaging & Flutter Local Notifications |
| **UI Components & Theme** | Material 3 Design System with custom PBD Group Theme System |

---

## 📁 Project Structure

```
lib/
├── app/                  # App initialization, routes, and main bindings
├── core/                 # Core utilities, network services, theme system
│   ├── helper/           # Form validators, image pickers, logger helpers
│   ├── network/          # Dio API client, HTTP status codes, retry logic
│   ├── style/            # Brand design tokens (app_colors.dart, app_light_theme.dart, app_dark_theme.dart)
│   └── utils/            # Dimensions, asset constants, custom snackbars
├── db/                   # Encrypted local database & preferences manager
├── features/             # Feature-based modular architecture (GetX)
│   ├── dashboard/        # Executive dashboard, business graphs, KPI widgets
│   ├── login/            # Authentication, splash screen, user login
│   └── notification/     # In-app and push notification hub
├── services/             # Firebase notifications & native system services
└── widgets/              # Reusable custom UI components (buttons, shimmers, logo, textfields)
```

---

## 🚀 Getting Started

### Prerequisites

* **Flutter SDK**: `^3.11.5` or later
* **Dart SDK**: `^3.11.5` or later
* **Java Development Kit (JDK)**: JDK 17+ (for Android builds)
* **Xcode**: 15+ (for iOS builds)

### Installation & Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/major-the-dev-69/real-time-pdf-editor.git
   cd real-time-pdf-editor
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Application**
   ```bash
   flutter run
   ```

---

## 📄 License & Copyright

Copyright © 2026 **PBD Group**. All rights reserved.  
This project is proprietary software for internal and authorized user use within **PBD Group**.
