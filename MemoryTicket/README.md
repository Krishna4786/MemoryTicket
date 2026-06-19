# Memory Ticket — Setup Guide

## Requirements
- **Xcode 15.0+**
- **iOS 17.0+** target
- **Swift 5.9+**

## Quick Setup (5 minutes)

### Step 1: Create Xcode Project
1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Set:
   - Product Name: `MemoryTicket`
   - Organization Identifier: `com.yourname` (anything works)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**
4. Click **Create**

### Step 2: Add the Files
1. **Delete** the default `ContentView.swift` that Xcode created
2. **Delete** the default `MemoryTicketApp.swift` that Xcode created
3. Drag ALL `.swift` files from this folder into your Xcode project navigator
4. When prompted, check **"Copy items if needed"** and your target

### Step 3: Configure Target
1. Select your project in the navigator (blue icon at top)
2. Select the **MemoryTicket** target
3. Under **General → Minimum Deployments**, set iOS to **17.0**
4. Under **Signing & Capabilities**, select your Team

### Step 4: Add Privacy Descriptions
1. Select **Info** tab (or open Info.plist)
2. Add these keys:
   - `NSPhotoLibraryUsageDescription` → "Memory Ticket needs access to your photos to create memory tickets."
   - `NSCameraUsageDescription` → "Memory Ticket uses your camera to capture moments."

### Step 5: Run
1. Select a Simulator (iPhone 15 Pro recommended) or your device
2. Press **⌘R** to build and run

## File Overview

| File | Purpose |
|------|---------|
| `MemoryTicketApp.swift` | App entry point, splash screen orchestration |
| `Models.swift` | Data models (MemoryTicket, LocationInfo, TicketCategory) |
| `TicketStore.swift` | Observable data store with JSON persistence |
| `AppTheme.swift` | Design system (colors, shapes, animations, reusable components) |
| `SplashView.swift` | Animated splash screen with floating particles |
| `MainTabView.swift` | Custom tab bar with center FAB button |
| `HomeView.swift` | Home dashboard with stats and recent tickets |
| `CreateTicketView.swift` | Multi-step ticket creation flow with reveal animation |
| `TicketCardView.swift` | The core ticket card visual component |
| `TicketDetailView.swift` | Full ticket detail view with share/delete |
| `CollectionView.swift` | Grid/list collection with search and filters |

## Architecture
- **Pattern**: MVVM with ObservableObject
- **Storage**: JSON files in Documents directory (no Core Data setup needed)
- **Images**: Saved as JPEG files in Documents directory
- **Navigation**: NavigationStack + fullScreenCover

## What's Included (Phase 1 MVP)
- ✅ Animated splash screen
- ✅ Create tickets with photo, title, date, location, mood, category
- ✅ Beautiful ticket card design with perforated edges
- ✅ Ticket reveal animation with confetti
- ✅ Collection grid and list views
- ✅ Search and category filtering
- ✅ Share tickets as images
- ✅ Delete and duplicate tickets
- ✅ Streak counter and monthly stats
- ✅ Dark mode
- ✅ Haptic feedback throughout
- ✅ Spring animations on every interaction
