# RACPL Dashboard Implementation Guide - Flutter

**Status**: Implementation Started  
**Reference**: Web Frontend (React) Dashboard  
**Backend API**: https://racpl-erp.vercel.app/api  

---

## 📱 Dashboard Screen Architecture

### Main Components (In Order)

#### 1. **Welcome Section**
```
┌─────────────────────────────────────┐
│ Welcome back, Ashish Yashwant! 👋   │
│ Here's what's happening today...    │
└─────────────────────────────────────┘
```
- Gradient background (Primary/10 to transparent)
- User name from `AuthProvider.currentUser`
- Motivational message
- **Data Source**: AuthProvider

---

#### 2. **Stats Grid (4 Cards)**
Layout: 2x2 on mobile, 4 columns on web

| Card | Title | Icon | Color | Data Source |
|------|-------|------|-------|-------------|
| 1 | Total Employees | groups | Blue | Employee count from API |
| 2 | Present Today | how_to_reg | Green | Attendance count |
| 3 | Pending Tasks | pending_actions | Orange | Task count |
| 4 | Open Tickets | confirmation_number | Purple | Ticket count |

Each card shows:
- Title + Icon
- Large value (font size: 28)
- Trend badge (e.g., "+2%", "92%", "Urgent", "Low")
- Trend label (e.g., "vs last month")

**Colors Mapping**:
```dart
blue: Color(0xFF3B82F6)
green: Color(0x10B981)
orange: Color(0xFFF59E0B)
purple: Color(0xA855F7)
```

---

#### 3. **Two Column Section**

**Left Column (2/3 width)**:
- **Attendance Trends Chart**
  - Type: Line chart with area fill under curve
  - X-axis: Week 1, Week 2, Week 3, Week 4
  - Y-axis: Attendance percentage
  - Dropdown: "This Month", "Last Month", "Last Quarter"
  - **Library**: fl_chart (recommended for Flutter)

**Right Column (1/3 width)**:
- **Quick Actions** (Section 1)
  - 4 buttons in 2x2 grid
  - Each: icon + label
  - Buttons: New Task, Apply Leave, Upload File, Payslip
  - Click → Navigate to respective screens
  
- **Todo Summary** (Section 2)
  - Show pending, in-progress, completed counts
  - List top 3 todos with checkboxes

---

#### 4. **Recent Activity Section**
Table/List with columns:
- Module (colored dot + name)
- Description
- User (avatar + name)
- Time
- Status badge (Completed/Pending/Processing)

**Sample Data**:
```
[HRMS] New policy document uploaded | Sarah Jenkins | 2 mins ago | ✅ Completed
[Help Ticket] Ticket #2049: Login issue | Mike Ross | 15 mins ago | ⏳ Pending
[FMS] Monthly expense report generated | System | 1 hour ago | ⏳ Processing
[IMS] Inventory stock level low alert | Warehouse Bot | 3 hours ago | ✅ Completed
```

---

## 🎨 Design System

### Colors
```dart
Primary: #137fec (Blue)
Success: #10b981 (Emerald)
Warning: #f59e0b (Amber)
Danger: #ef4444 (Red)
```

### Typography
- **Heading**: Bold, size 20-24
- **Subheading**: Bold, size 16-18
- **Body**: Regular, size 14
- **Caption**: Regular, size 12

### Spacing
- Card padding: 16dp
- Section gap: 24dp
- Grid gap: 12-16dp

---

## 📊 Data Flow & APIs

### Required Endpoints (Backend)

1. **Dashboard Stats** (Single endpoint or multiple)
   - Total Employees Count
   - Present Today Count
   - Pending Tasks Count
   - Open Tickets Count

2. **Attendance Trend** (Weeks data)
   - GET `/api/dashboard/attendance-trends?month=<month>`

3. **Recent Activity Log** (Last 4 activities)
   - GET `/api/dashboard/recent-activity` 

4. **Todo Summary**
   - GET `/api/todos?filter=pending,inProgress,done`

### Provider Methods Needed

```dart
// DashboardProvider (NEW)
- fetchDashboardStats() → DashboardStats
- fetchAttendanceTrends(month) → List<AttendanceData>
- fetchRecentActivity() → List<Activity>
- fetchTodoSummary() → TodoStats

// Existing Providers
- delegations, expenses, todos already implemented
```

---

## 🚀 Implementation Roadmap

### Phase 1: Static Layout (TODAY)
- [x] Welcome section widget
- [x] Stats grid with mock data
- [x] Two-column layout structure
- [x] Quick Actions buttons (navigation ready)
- [x] Todo Summary basic layout
- [x] Recent Activity table/list
- [x] Responsive design (mobile first)

### Phase 2: Dynamic Data (This Week)
- [ ] Create DashboardProvider
- [ ] Create DashboardService with API calls
- [ ] Register DashboardProvider in main.dart
- [ ] Connect providers to UI widgets
- [ ] Add loading/error states
- [ ] Add empty state messages

### Phase 3: Interactivity (This Week)
- [ ] Quick Actions - Implement click handlers
- [ ] Recent Activity - Navigate to module details
- [ ] Attendance Chart - Add real data
- [ ] Refresh functionality
- [ ] Pull-to-refresh

### Phase 4: Polish (Next Week)
- [ ] Dark mode support
- [ ] Animations on load
- [ ] Skeleton loaders
- [ ] Error boundary
- [ ] Accessibility

---

## 📝 Files to Create/Modify

### Create
```
lib/
├── models/
│   ├── dashboard_stats_model.dart (NEW)
│   ├── attendance_trend_model.dart (NEW)
│   └── activity_model.dart (already exists)
│
├── services/
│   └── dashboard_service.dart (NEW)
│
├── providers/
│   └── dashboard_provider.dart (NEW)
│
└── screens/
    └── home/
        ├── components/
        │   ├── welcome_card.dart (NEW)
        │   ├── stat_card.dart (NEW)
        │   ├── attendance_chart.dart (NEW)
        │   ├── quick_actions.dart (NEW)
        │   ├── todo_summary.dart (NEW)
        │   └── recent_activity.dart (NEW)
        │
        └── dashboard_screen.dart (MODIFY)
```

### Modify
```
lib/main.dart - Add DashboardProvider to MultiProvider
```

---

## 💡 Notes

1. **Chart Library**: Use `fl_chart` for line charts
2. **Icons**: Use FontAwesome or Material Icons
3. **Responsive**: Design for mobile < 600px, tablet 600-900px, desktop > 900px
4. **Dark Mode**: Implement with ColorScheme
5. **State Management**: Provider + ChangeNotifier pattern

---

## 🎯 Success Criteria

✅ Dashboard loads without errors
✅ All sections display with mock data
✅ Responsive on mobile/tablet/desktop
✅ Navigation from Quick Actions works
✅ Stats update when data changes
✅ Recent Activity shows real data
✅ Chart displays trends

---

**Next Step**: Start with lib/screens/home/components/ widgets

