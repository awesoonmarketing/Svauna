# 📖 Svauna — Sauna and Cold Plunge Tracking for iPhone + Apple Watch

**Author**: Built with a senior architect and Apple product designer approach.  
**Purpose**: Deliver an intuitive, resilient, and emotionally resonant experience for tracking and reviewing sauna and cold plunge sessions.

---

## 🧐 Product Vision

An application meticulously designed to track key metrics for **sauna** and **cold plunge** sessions:
- Time durations (total and segmented intervals/"laps")
- Caloric expenditure
- Real-time heart rate monitoring
- Passive blood oxygen readings

With exceptional attention to:
- Seamless Watch-to-iPhone synchronization
- Graceful crash recovery and session persistence
- Future-focused architecture ready for feature expansion

---

## 🌟 Project Objectives

Create a **dual-platform experience** with clear separation of concerns:
- **Apple Watch**: Primary device for active session management and health data collection
- **iPhone**: Rich visualization platform for session history review and analysis

### Core Priorities:
1. **Maximum Reliability**: Crash recovery and data integrity as first-class citizens
2. **Apple-Native UX**: Leveraging platform idioms and design patterns
3. **Expandable Architecture**: Foundation ready for future feature additions
4. **Offline-First Behavior**: Full functionality without constant connectivity
5. **Energy Efficiency**: Optimized battery usage during longer sessions

---

## 📊 Architecture Overview

| Layer | Purpose |
|:---|:---|
| **Views** | SwiftUI screens and modular, reusable components |
| **ViewModels** | ObservableObject-based MVVM pattern for UI state management |
| **Models** | Codable data structures for session information |
| **Services** | HealthKit integration, WatchConnectivity, Persistence, Crash Recovery |
| **Utils** | Supporting utilities for formatting and calculations |
| **Navigation** | Declarative, state-driven navigation system |

---

## 📂 Project Structure

```
Svauna/
├── Assets.xcassets
├── ContentView.swift
├── Data/
│   └── PersistenceService.swift
├── Models/
│   ├── Session.swift
│   ├── SessionSegment.swift
│   ├── HeartRateDataPoint.swift
│   ├── CaloriesDataPoint.swift
│   └── BloodOxygenDataPoint.swift
├── Navigation/
│   └── AppRouter.swift
├── Services/
│   ├── HealthKitService.swift
│   ├── WatchConnectivityService.swift
│   └── CrashRecoveryService.swift
├── Utils/
│   ├── DateUtils.swift
│   ├── TimeFormatters.swift
│   └── NumberFormatters.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── CalendarViewModel.swift
│   ├── HistoryIndexViewModel.swift
│   └── IndividualHistoryViewModel.swift
└── Views/
    ├── Components/
    │   └── CalendarDayView.swift
    └── Screens/
        ├── HomeView.swift
        ├── CalendarView.swift
        ├── HistoryIndexView.swift
        └── IndividualHistoryView.swift

Svauna Watch App/
├── Assets.xcassets
├── ContentView.swift
├── Data/
│   └── LocalSessionStore.swift
├── Models/ (Shared)
├── Navigation/
│   └── WatchRouter.swift
├── Services/
│   ├── WatchHealthKitService.swift
│   ├── WatchConnectivityService.swift
│   └── WatchCrashRecoveryService.swift
├── Utils/
│   └── WatchDateUtils.swift
├── ViewModels/
│   ├── WatchHomeViewModel.swift
│   └── WatchTrackingViewModel.swift
└── Views/
    ├── Components/
    │   ├── HeartRateLiveView.swift
    │   └── ActiveCaloriesView.swift
    └── Screens/
        ├── WatchHomeView.swift
        └── WatchTrackingView.swift
```

This parallel structure between iOS and Watch apps enhances maintainability and creates a consistent development pattern.

---

## 🎨 Key UX Features

| Feature | Description |
|:---|:---|
| **Dynamic Backgrounds** | Warm color tones for Sauna sessions, cool tones for Cold Plunge |
| **Swipe to Segment** | Quick swipe-left gesture to mark a new segment/lap without interrupting the session |
| **Pause Visual State** | Clearly dimmed background with prominent "Paused" indicator |
| **Calendar Preview** | Bottom sheet previews of daily sessions from calendar view |
| **Auto-Generated Taglines** | Fun, automatically generated session summaries (e.g., "🔥 Sweated for 32min!") |
| **Blood Oxygen Display** | Clearly timestamped readings with auto-dimming for older samples |
| **Microinteractions & Haptics** | Light haptic feedback for start/pause/segment/end actions |

---

## 📊 App Flows

### Watch App Flow
- WatchHomeView ➔ Tap Sauna/Plunge ➔ TrackingView
- Swipe left during session ➔ Create New Segment
- Tap Pause ➔ Dimmed view with Options
- Tap End ➔ Save Session Locally ➔ Sync to iPhone

### iPhone App Flow
- HomeView (Calendar) ➔ Tap day ➔ Bottom sheet preview ➔ Tap session ➔ IndividualHistoryView
- Charts for heart rate and calorie trends
- Color-coded sessions based on type (warm/cool)
- Session taglines and comprehensive health data summaries

---

## 🧪 Health Data Strategy

### Data Collection:
- **Heart Rate**: Real-time streaming via HealthKit
- **Calories**: Active calorie burn calculation
- **Blood Oxygen**: Latest passive reading from system

### Implementation Notes:
- Blood oxygen is sampled passively by watchOS
- All health metrics include clear timestamps
- Health permission requests prioritize transparency
- Fallbacks for unavailable metrics

---

## 🛡️ Crash Recovery & Sync

- **Session State Preservation**:
  - Automatic background saving every 10 seconds
  - Session state capture on pause, segmentation, or end
  - Complete session restoration after crash or restart

- **Sync Architecture**:
  - Watch as the single source of truth for active sessions
  - Session transfer to iPhone after completion
  - Deferred sync queue for offline operation
  - Automatic retry when connectivity restored

---

## 🤓 Offline Behavior

- **Watch Independence**:
  - Full functionality without iPhone connection
  - Local storage of multiple completed sessions
  - No feature degradation when offline

- **Sync Intelligence**:
  - Automatic retry scheduling for failed transfers
  - Session integrity never compromised by connectivity issues
  - Subtle UI indicators for pending sync operations

---

## ⚡ Performance & Energy Efficiency

- **HealthKit Optimization**:
  - Streaming queries instead of resource-intensive polling
  - Batched data processing to reduce CPU usage

- **UI Efficiency**:
  - Minimal redraw operations during active sessions
  - Optimized animations for 60fps without battery drain
  - Background task coordination to avoid CPU spikes

- **Storage Efficiency**:
  - Compact data models for session storage
  - Intelligent data retention policies

---

## 🔍 Accessibility

- **Text Scaling**:
  - Dynamic Type support throughout both apps
  - Responsive layouts that accommodate larger text

- **Voice Interaction**:
  - Comprehensive VoiceOver labels for all elements
  - Logical navigation order for screen readers

- **Visual Accommodations**:
  - High-contrast color modes based on system settings
  - Large touch targets for critical session actions (Start, Pause, End)
  - Haptic feedback reinforcement for key interactions

---

## 🔬 Testing Strategy

| Area | Testing Approach |
|:---|:---|
| **Services** | Unit tests for HealthKit, WatchConnectivity, Persistence services |
| **Crash Recovery** | Simulated crash scenarios to verify auto-restore functionality |
| **Watch-iPhone Sync** | End-to-end tests for transfer reliability and edge cases |
| **Calendar + History** | UI tests for day selection and detail retrieval flows |
| **Accessibility** | Dynamic Type and VoiceOver navigation verification |
| **Performance** | Battery and CPU usage profiling during extended sessions |

---

## 🗓️ Future Enhancements (Planned)

| Feature | Phase |
|:---|:---|
| **Session Notes and Ratings** | Phase 2 |
| **Backend Cloud Syncing** | Phase 3 |
| **Blood Oxygen Threshold Alerts** | Phase 3 |
| **GPX / HealthKit Export** | Phase 3 |
| **Multiple Device Support** | Phase 3 |
| **Statistical Analysis Dashboard** | Phase 4 |

---

## 🚀 Setup Instructions

1. Clone the repository
2. Open `Svauna.xcodeproj` in Xcode 15 or later
3. Connect a compatible iPhone and Apple Watch (Series 6 or newer recommended)
4. Grant required HealthKit permissions when prompted
5. Build and run the Watch app first, then the iPhone app

### Required Permissions:
- HealthKit (heart rate, active energy, oxygen saturation)
- Background app refresh (for sync operations)

---

## 🧐 Design Principles for Future Developers

1. **Reliability First**: Prioritize resilient session tracking above all other concerns
2. **Emotional Connection**: Maintain engaging microinteractions that create a premium feel
3. **Architectural Clarity**: Keep architecture clean and scalable for future cloud services
4. **Offline Resilience**: Always build features with offline-first mentality
5. **Accessibility as Core**: Consider all users from the beginning, not as an afterthought

Always update this README when adding features to maintain accurate documentation.

---

## ✅ Summary

Svauna is engineered for **reliability, emotional resonance, resilience, and expansion**. This README provides the architectural blueprint to extend and refine the app while protecting its premium-level vision and user experience.









# Svauna Development: Three-Phase Implementation Plan

Here's a comprehensive breakdown of the three development phases for your Svauna app, detailing the specific files to create and their responsibilities:

## Phase 1: Core Session Tracking on Watch

**Objective**: Build a reliable, standalone Apple Watch app for sauna and cold plunge session tracking.

### Files to Create:

#### Models
1. **Session.swift**
   - Core data structure for sauna/plunge sessions
   - Properties: `id`, `type` (sauna/plunge), `startDate`, `endDate`, `segments`, `heartRateData`, `caloriesData`, `bloodOxygenData`, `state` (active/paused/completed)
   - Methods for calculating duration, calories, average heart rate
   - Codable implementation for persistence
   - State transition validation

2. **SessionSegment.swift**
   - Represents intervals within a session ("laps")
   - Properties: `id`, `startTime`, `endTime`, `segmentType`
   - Duration calculation and data summarization methods
   - Codable implementation

3. **HeartRateDataPoint.swift**
   - Properties: `timestamp`, `bpm`, `source`
   - Formatting methods for display
   - Statistical calculation helpers (min/max/avg)

4. **CaloriesDataPoint.swift**
   - Properties: `timestamp`, `activeCalories`, `totalCalories`
   - Aggregate calculation methods
   - Rate calculation (calories/minute)

5. **BloodOxygenDataPoint.swift**
   - Properties: `timestamp`, `percentage`, `confidence`
   - Quality assessment methods
   - Sample age calculation

#### Services
1. **WatchHealthKitService.swift**
   - HealthKit authorization setup
   - Streaming queries for heart rate and calories
   - Blood oxygen reading methods
   - Error handling and recovery
   - Query cleanup on session end

2. **WatchCrashRecoveryService.swift**
   - Background session state persistence (10-second intervals)
   - App restart detection
   - Session state restoration
   - Crash analysis for debugging
   - Battery depletion handling

3. **LocalSessionStore.swift**
   - FileManager operations for session storage
   - Session metadata tracking
   - Disk space management
   - Queue for pending iPhone transfers
   - Data integrity verification

4. **WatchSessionManager.swift**
   - Session lifecycle state management
   - Coordinator between services
   - Timer handling for duration tracking
   - Event broadcasting for UI updates
   - Error handling and recovery

#### Navigation
1. **WatchRouter.swift**
   - Route definition (home, tracking)
   - Navigation state persistence
   - State validation to prevent UI inconsistencies
   - Coordination with session lifecycle

#### ViewModels
1. **WatchHomeViewModel.swift**
   - Session type selection logic
   - Session preparation
   - UI state management for buttons
   - Crash recovery detection
   - Recent session summary

2. **WatchTrackingViewModel.swift**
   - Active session display management
   - Health metric formatting
   - Session control actions (pause/resume/end)
   - Gesture handling for segmentation
   - UI updates based on session state

#### Views
1. **WatchHomeView.swift**
   - Main entry screen
   - Sauna/Plunge selection buttons
   - Recovery notification display
   - Recent session summary
   - Settings access

2. **WatchTrackingView.swift**
   - Active session interface
   - Heart rate display
   - Calories and timer visualization
   - Swipe gesture area for segmentation
   - Session control buttons
   - Paused session visual state

3. **HeartRateLiveView.swift**
   - Real-time heart rate visualization
   - BPM display with animation
   - Min/max indicators
   - Visual styling based on intensity

4. **ActiveCaloriesView.swift**
   - Calorie burn visualization
   - Active vs total calories display
   - Rate indication (calories/minute)
   - Progress styling

#### Utils
1. **WatchDateUtils.swift**
   - Time formatting for display
   - Duration calculations
   - Timestamp comparison
   - Date range utilities

### Phase 1 Outcome
By the end of Phase 1, you'll have a fully functional Watch app that:
- Starts sauna or cold plunge sessions
- Tracks heart rate, calories, and time
- Supports session pausing and segmenting
- Recovers from crashes automatically
- Stores completed sessions locally

## Phase 2: iPhone Session History + Watch Sync

**Objective**: Create an iPhone companion app to receive, store, and visualize session history from the Watch.

### Files to Create:

#### Services (iPhone)
1. **PersistenceService.swift**
   - Core Data stack setup
   - Session and segment data modeling
   - CRUD operations for session data
   - Query methods for calendar and history views
   - Data migration handling

2. **WatchConnectivityService.swift (iPhone)**
   - WatchConnectivity session establishment
   - Message handling from Watch
   - File transfer processing
   - Background transfer support
   - Connection state monitoring

3. **WatchConnectivityService.swift (Watch)**
   - Session transfer to iPhone
   - Connectivity status monitoring
   - Queue for unsent sessions
   - Transfer retry logic
   - Progress indicators

#### Navigation (iPhone)
1. **AppRouter.swift**
   - Screen navigation management
   - History deep linking
   - Modal presentation control
   - Navigation state tracking
   - Transition animations

#### Utils (iPhone)
1. **TimeFormatters.swift**
   - Duration formatting (hrs:min:sec)
   - Time display options
   - Calendar-specific formatting
   - Relative time descriptions

2. **NumberFormatters.swift**
   - Calorie formatting with units
   - Heart rate display formatting
   - Blood oxygen percentage formatting
   - Value rounding and precision control

3. **DateUtils.swift**
   - Calendar helper functions
   - Date range calculations
   - Week/month boundary detection
   - Comparative date utilities

#### ViewModels (iPhone)
1. **HomeViewModel.swift**
   - Calendar data preparation
   - Day selection handling
   - Session preview data assembly
   - Statistics summarization
   - Recent session highlighting

2. **CalendarViewModel.swift**
   - Calendar navigation logic
   - Session data aggregation by date
   - Month navigation control
   - Day selection state management
   - Visual indicator data preparation

3. **HistoryIndexViewModel.swift**
   - Session list management
   - Filtering and sorting options
   - Search functionality
   - Date-based grouping
   - Session preview generation

4. **IndividualHistoryViewModel.swift**
   - Detailed session data processing
   - Chart data preparation
   - Segment marker calculation
   - Session metrics computation
   - Export preparation

#### Views (iPhone)
1. **HomeView.swift**
   - Main entry screen with calendar
   - Summary statistics display
   - Navigation controls to history/settings
   - Sync status indicators

2. **CalendarView.swift**
   - Month grid display
   - Navigation between months
   - Day selection handling
   - Session intensity visualization
   - Today highlighting

3. **CalendarDayView.swift**
   - Individual day cell
   - Session indicator badges
   - Selection state visualization
   - Session type indicators

4. **HistoryIndexView.swift**
   - Chronological session list
   - Type filtering controls
   - Search implementation
   - Pull-to-refresh for sync
   - Preview tiles for sessions

5. **IndividualHistoryView.swift**
   - Full session details
   - Heart rate and calorie charts
   - Segment markers and labels
   - Session statistics display
   - Share and export options

### Phase 2 Outcome
By the end of Phase 2, you'll have:
- A complete iPhone app showing session history
- Calendar view with visual session indicators
- Detailed charts and statistics for each session
- Automatic syncing from Watch to iPhone
- Date-based organization of sessions

## Phase 3: Polish, Expandability, Accessibility

**Objective**: Add professional polish, ensure accessibility compliance, and prepare for future feature expansion.

### New Files to Create:

#### Services
1. **WatchOfflineSyncManager.swift**
   - Unsynced session tracking
   - Advanced retry strategies
   - Transfer optimization
   - Priority queue management
   - Sync status notifications

2. **ErrorHandlingService.swift**
   - Centralized error processing
   - User-friendly error messages
   - Logging and diagnostics
   - Recovery suggestion logic
   - Critical error handling

3. **SessionExportService.swift**
   - Multiple export format support (JSON/CSV/GPX)
   - File sharing implementation
   - HealthKit export integration
   - Format customization options
   - Share sheet integration

4. **SessionNotesService.swift**
   - Note attachment to sessions
   - Rating system implementation
   - Tagging functionality
   - Cross-device syncing
   - Text storage and processing

#### Models
1. **SessionNote.swift**
   - Text content storage
   - Rating value (1-5)
   - Creation timestamp
   - Tag collection
   - Session association

#### Utils
1. **AccessibilityHelpers.swift**
   - VoiceOver label generation
   - Dynamic Type support utilities
   - Accessibility trait management
   - Color contrast utilities
   - Focus management helpers

2. **WatchPerformanceOptimizer.swift**
   - Battery usage monitoring
   - Write operation batching
   - HealthKit query optimization
   - Background task management
   - Animation performance tuning

#### Views
1. **BloodOxygenDisplayView.swift**
   - Blood oxygen visualization
   - Timestamp freshness indicator
   - Confidence level display
   - Trend visualization
   - Warning threshold indicators

2. **SessionTagsView.swift**
   - Tag display and management
   - Tag creation interface
   - Filtering controls
   - Color coordination system
   - Organization options

3. **SettingsView.swift**
   - App preferences controls
   - Health permission management
   - Data management options
   - Export and backup controls
   - About and support information

### Updates to Existing Files:

#### Session.swift
- Add note attachment support
- Add rating field
- Add tags collection
- Implement export format conversion
- Update Codable implementation

#### WatchHealthKitService.swift
- Add blood oxygen monitoring
- Optimize query efficiency
- Add background updates
- Improve battery performance
- Implement threshold alerts

#### All View Files
- Add comprehensive accessibility labels
- Implement Dynamic Type support
- Add reduced motion alternatives
- Improve VoiceOver navigation
- Add high contrast support

#### All ViewModels
- Add error handling enhancements
- Implement offline state management
- Optimize data loading
- Add analytics event points
- Reduce memory usage

### Phase 3 Outcome
By the end of Phase 3, you'll have:
- A fully accessible app supporting all users
- Blood oxygen monitoring and visualization
- Energy-efficient HealthKit integration
- Reliable offline syncing with intelligent retry
- Session notes, ratings, and tags
- Export functionality for data portability
- Professional error handling throughout the app

This three-phase approach ensures you build the core functionality first, then add user-facing features, and finally polish everything to professional quality while preparing for future expansion.
