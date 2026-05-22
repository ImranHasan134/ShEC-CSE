# 🏛️ ShEC CSE (Sheikh Hasina Engineering College - Computer Science & Engineering) Mobile App

An advanced, feature-rich Flutter application designed specifically for the **Sheikh Hasina Engineering College (ShEC) Computer Science & Engineering (CSE)** department. This app streamlines campus communication, academic progress tracking, career navigation, real-time messaging, financial management, and official department procedures in one high-performance, beautiful mobile application.

---

## 🌟 Key Highlights & Architectural Features

### 🎨 1. Dynamic Design & Ultra-Premium UI/UX
- **Interactive Navigation**: Implements a smooth custom `hidden_drawer_menu` alongside a contemporary `google_nav_bar` at the bottom for modern, fluid transitions.
- **Advanced Dynamic Themes**: Powered by a robust `ThemeService` that supports **4 Theme Modes** (System, Light, Dark, and a true-black **Night Mode**) and **6 harmonious Color Themes** (Teal, Ocean Blue, Cosmic Purple, Emerald, Amber, and Crimson).
- **Material 3 Integration**: Tailored components with smooth glassmorphism, depth elevations, and responsive grid layouts.

### ⚡ 2. Resilient Cloud-Local Storage Architecture
- **Dual-Provider Storage Sync**: Uses a smart fallback storage pipeline in `StorageService`. Media is uploaded to **Cloudflare R2** (via S3 APIs) for maximum CDN speed and low cost, with a seamless, automatic fallback to **Supabase Storage** if R2 is unavailable.
- **On-the-Fly Image Processing**: Uses `ImageProcessingService` to automatically crop (`image_cropper`) and compress image files into high-performance **WebP format** (`flutter_image_compress`) before uploading to save bandwidth and storage.
- **Offline Caching**: Built-in `CacheService` backed by `shared_preferences` keeps essential dashboard notices, profile states, and preferences functional offline.

### 📈 3. Dhaka University Affiliated Colleges (DUCMC) Results Integration
- **Dynamic Scraper API Integration**: Connected to a custom hosted scrapper API (`saifur2025-ducmc-info-scrapper.hf.space`) to fetch, parse, and showcase semester results in real time.
- **Interactive CGPA Calculator**: Offline Grade Point Average (GPA) and Cumulative GPA (CGPA) projector to allow students to map out course grades and track progress.

---

## 🛠️ Complete Feature Matrix

| Feature | Description | State Management / Service |
| :--- | :--- | :--- |
| 🔑 **Supabase Auth & Roles** | Secure registration, real-time auth listeners, password recovery, and multi-level role authorization (`student` vs. `committee` / `President` / `Vice President`). | `AuthBloc` / `AuthService` |
| 📢 **Smart Notices** | Club & departmental announcements. Pinned notices remain anchored at the top. Features dynamic code-point icons & color-coded tags. | `NoticeBloc` / `NoticeService` |
| 💼 **Career Board** | Classified job matching platform categorizing recommended and recent opportunities, with deadline alerts and bookmarking features. | `JobService` |
| ⚔️ **Coding Contests & Courses** | Live feed of upcoming coding contests across platforms and recommended learning courses with direct resource links. | `ContestService` |
| 📸 **Advanced Campus Gallery** | Rich gallery supporting up to 5 image uploads per event, administrative approval workflows, toggle visibility, and WebP compression. | `GalleryService` |
| 💰 **Accounting Ledger** | Real-time transaction tracker showing revenues, expenses, and current balances for club funds. | `AccountingBloc` / `AccountingService` |
| 💬 **Real-time Chat** | Fully-featured instant messaging rooms and user-to-user chat built on Supabase Realtime databases. | `ChatBloc` / `ChatService` |
| 👥 **Academic Directories** | Detailed contact lists and bio cards for **Teachers** and **Alumni**, with search capability and direct contact shortcuts. | `TeacherService` / `AlumniService` |
| 📚 **Resource Sharing** | Categorized repository of shared course files, lecture slides, and past papers. | `ResourceService` |
| 🔄 **Auto App Updates** | In-app notification of new builds (via `app_updates` table) showing release notes and offering direct APK downloads. | `UpdateService` |

---

## 🏗️ Technical Architecture & Directory Structure

```
lib/
├── backend/
│   ├── DUCMC Resul Scrapper/      # Scraper assets and models
│   └── services/                  # Database, storage, and API microservices
├── core/
│   ├── services/                  # Global singletons (Theme, Cache, Storage, Image)
│   └── utils/                     # Helpers (IconMapper, ValidationRules)
└── features/                      # Domain-driven features (Clean Architecture block layout)
    ├── about/                     # About screen & project contributors
    ├── accounting/                # Financial ledger & transaction systems
    ├── alumni/                    # Alumni directory and bios
    ├── auth/                      # Authentication (Splash, Login, Password Reset)
    ├── cgpa_calculator/           # Offline grade estimator
    ├── club/                      # Club specific views
    ├── contests/                  # Competitive coding events
    ├── dashboard/                 # Central navigation hub (Home & Drawer screens)
    ├── department/                # Department profile and teachers list
    ├── gallery/                   # Multi-image WebP gallery with approvals
    ├── jobs/                      # Career and job search boards
    ├── messenger/                 # Real-time chat & message rooms
    ├── notices/                   # Academic and club notice board
    ├── profile/                   # User profile management
    ├── resources/                 # Academic files and PDFs share
    └── results/                   # Dynamic semester result viewing (DUCMC Scraper)
```

---

## 🚀 Setting Up the Project

### Prerequisites
- Flutter SDK `^3.11.0` or higher
- A Supabase Project (Postgres Database, Auth, Realtime, and Storage enabled)
- A Cloudflare R2 bucket (Optional but highly recommended for fast asset serving)
- A hosted DUCMC Scrapper instance

### 1. Database Initialization
Execute the SQL scripts located at the root of the project to set up the necessary tables, triggers, and Row Level Security (RLS) policies:
1. First, run [Supabase_Tables.txt](file:///e:/Programs/Flutter/ShEC_CSE/Supabase_Tables.txt) in your Supabase SQL Editor.
2. Next, run [update_database_v3.sql](file:///e:/Programs/Flutter/ShEC_CSE/update_database_v3.sql) to apply designations, visibility fields, and additional indexes.

### 2. Environment Configuration
Create a `.env` file at the root of the project (as defined in `pubspec.yaml` assets) with the following structure:
```env
# Supabase Configuration
SUPABASE_URL=YOUR_SUPABASE_PROJECT_URL
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY

# Cloudflare R2 Configuration (Fallback to Supabase Storage if missing)
R2_ENDPOINT=YOUR_CLOUDFLARE_R2_S3_ENDPOINT
R2_ACCESS_KEY=YOUR_R2_ACCESS_KEY
R2_SECRET_KEY=YOUR_R2_SECRET_KEY
R2_BUCKET_NAME=YOUR_R2_BUCKET_NAME
R2_PUBLIC_URL=YOUR_R2_PUBLIC_CDN_URL

# Result Scraper API
RESULT_API_URL=YOUR_RESULT_SCRAPER_API_URL
```

### 3. Build & Run Command
Ensure dependencies are fetched and run the app in debug/profile mode:
```bash
flutter pub get
flutter run
```

---

## 📦 Production Release Build

> [!IMPORTANT]
> **Icon Tree Shaking Warning**
> This project displays dynamic icons loaded from the database via code point values. Standard Flutter release builds perform tree-shaking on font icons, which will cause these dynamically loaded icons to appear blank.
>
> You **must** disable icon tree-shaking when building the production APK:
> ```bash
> flutter build apk --no-tree-shake-icons
> ```

---

## 🤝 Project Contributors
We want to acknowledge the contributors who put their heart and soul into building this academic tool:
- **Saifur Rahman** (Project Architecture, Scraper Integration, and Backend pipeline)
- CSE Club Committee & volunteers
- **Imran Hasan** (Project UI/UX Designer)
- CSE Club Committee & volunteers