# Quick Start Guide - RACPL ERP Flutter App

## 🚀 Getting Started in 5 Minutes

### Step 1: Install Dependencies
```bash
cd d:\flutterprojects\racpl
flutter pub get
```

### Step 2: Run the App
```bash
# Ensure emulator is running or device is connected
flutter run

# Or run on specific device
flutter run -d <device-id>
```

### Step 3: Test the App
1. **Login Screen** appears first
2. Enter credentials:
   - Email: `test@email.com`
   - Password: `Test@123`
3. Tap "Sign Up" if you don't have an account
4. Once logged in, you'll see the **Dashboard**

### Step 4: Navigate Features
- Use **Bottom Navigation** to switch between screens
- Open **Drawer** (hamburger menu) for Profile & Logout
- Each screen has a **floating action button** for creating new items

---

## 📱 App Structure Overview

### Authentication Flow
```
Splash → Login/SignUp → Dashboard → Feature Screens
```

### 10 Main Tabs (Bottom Navigation)
1. **Dashboard** 📊 - Overview with stats
2. **Delegations** 📋 - Task delegation
3. **Checklists** ✅ - Checklist items
4. **Tickets** 🎫 - Help support tickets
5. **Todos** 📝 - Todo board (Kanban style)
6. **Meetings** 🤝 - Meeting notes
7. **Expenses** 💰 - Expense tracking
8. **Vendors** 🏪 - Vendor management
9. **Projects** 📁 - Project tracking
10. **Scores** ⭐ - Performance metrics

---

## 🔑 Key Files You Need to Know

### Configuration
- `lib/utils/constants.dart` - API base URL & constants
- `lib/main.dart` - App initialization & routing

### Services (API Calls)
- `lib/services/dio_service.dart` - HTTP client
- `lib/services/auth_service.dart` - Login/Signup API

### State Management  
- `lib/providers/auth_provider.dart` - Auth state
- `lib/providers/*_provider.dart` - Feature states

### Screens
- `lib/screens/auth/` - Login & Signup
- `lib/screens/home/` - Dashboard & Navigation
- `lib/screens/features/` - Feature list screens

---

## 🔐 Login Credentials (Test)

Since this is a new setup, you'll need valid backend credentials. Contact your backend team or check the backend README for test accounts.

**Expected Backend is running at**: `https://racpl-erp.vercel.app/api`

---

## 🛠️ Common Development Tasks

### Add a New Feature
1. Create model in `lib/models/feature_model.dart`
2. Create service in `lib/services/feature_service.dart`
3. Create provider in `lib/providers/feature_provider.dart`
4. Create screen in `lib/screens/features/feature_list_screen.dart`
5. Add to bottom navigation in `lib/screens/home/home_screen.dart`
6. Register service/provider in `lib/main.dart`

### Add a New API Endpoint
1. Define in service: `lib/services/feature_service.dart`
2. Call parent service that uses DioService
3. Handle error with AppError model
4. Update provider with new state

### Fix Compilation Errors
```bash
# Check errors
flutter analyze

# Get detailed error info
flutter run

# Fix by referencing error messages and column positions
```

### Hot Reload During Development
```bash
# While app is running:
r  - Hot reload (quick, code only)
R  - Hot restart (full restart)
q  - Quit
```

---

## 📊 API Response Structure

All APIs return in this format:
```json
{
  "success": true,
  "message": "Success message",
  "data": { /* Model data */ },
  "statusCode": 200
}
```

Errors return:
```json
{
  "success": false,
  "message": "Error description",
  "statusCode": 400/500
}
```

---

## 🎨 UI/UX Quick Reference

### Status Badges Colors
- **Pending**: Orange
- **In Progress**: Blue  
- **Completed**: Green
- **Done**: Green

### Priority Colors
- **High**: Red
- **Medium**: Orange
- **Low**: Green

### Dashboard Stats
- Pending Tasks: Count of pending delegations
- Total Todos: All todos status
- Total Expenses: Sum of all expenses

---

## 🔄 State Management Pattern

All features follow the same pattern:

```dart
// 1. Call provider method
context.read<FeatureProvider>().fetchItems();

// 2. Provider fetches data via service
service.getItems();

// 3. Service makes API call via DioService
dioService.get('/endpoint');

// 4. Response parsed to model
Model.fromJson(response);

// 5. UI rebuilds
Consumer<FeatureProvider>(
  builder: (context, provider, _) {
    return ListView(
      children: provider.items
    );
  }
)
```

---

## 🐛 Debugging Tips

### View Provider State
```dart
// In any screen
print(context.read<FeatureProvider>().items);
```

### Check API Calls
- Open Android Studio / VS Code console
- Look for Dio request/response logs
- Search for "GET /endpoint"

### Check Local Storage
```dart
// Get stored token
final token = await StorageHelper().getToken();
print('Token: $token');
```

### Handle Errors
All errors are caught and displayed:
- Network error → Show error dialog with retry
- Validation error → Show specific field errors  
- Server error → Show server message
- Unknown error → Show generic error

---

## 📈 Performance

### Optimized
- Lazy service initialization
- Provider state caching
- Efficient rebuilds with Consumer
- Large list support

### Future Improvements
- Add pagination for large datasets
- Implement local database
- Add background sync
- Cache images

---

## 🌐 API Integration

### Base URL
```
https://racpl-erp.vercel.app/api
```

### Authentication
- Token sent in `Authorization: Bearer {token}` header
- Automatic token injection via Dio interceptor
- 1-day token expiry

### Token Storage
- Stored in SharedPreferences
- Secure storage available for sensitive data
- Auto-cleared on logout

---

## 📝 Project Highlights

✅ **Clean Architecture**: Models → Services → Providers → UI
✅ **Type Safe**: Full null safety with Dart
✅ **Error Handling**: Comprehensive error model
✅ **State Management**: Provider with ChangeNotifier
✅ **HTTP Client**: Dio with automatic token injection
✅ **Responsive**: Material Design 3 components
✅ **Scalable**: Easy to add new features
✅ **Well Documented**: 3 guide documents included

---

## 🎯 What's Included

- **45+ Files**: Complete app structure
- **13 Models**: Data structures for all features
- **10 Services**: API integration layer
- **10 Providers**: State management
- **12 Screens**: Complete UI
- **3 Reusable Widgets**: Button, TextField, Dialog
- **3 Utility Files**: Storage, Validators, Constants
- **3 Guide Documents**: Setup, Integration, Master Implementation

---

## ❓ FAQ

**Q: Why is my login failing?**
A: Ensure backend is running at https://racpl-erp.vercel.app/api and use valid credentials

**Q: How do I add a new screen?**
A: Create screen in `lib/screens/`, add to bottom navigation in `home_screen.dart`

**Q: How do I change the API base URL?**
A: Update `API_BASE_URL` in `lib/utils/constants.dart`

**Q: Can I customize colors?**
A: Yes, update seed color in `main.dart` ThemeData

**Q: How do I test the app offline?**
A: Currently requires backend. For offline testing, implement local database with Hive/Sqflite

---

## 🔗 Related Documentation

- **BUILD_COMPLETE.md** - Full build summary
- **BACKEND_INTEGRATION_GUIDE.md** - API documentation  
- **MASTER_IMPLEMENTATION_GUIDE.md** - Implementation roadmap
- **SETUP_COMPLETE.md** - Initial setup details

---

## 💡 Pro Tips

1. **Use Provider DevTools**: Add `flutter_riverpod` extension for debugging
2. **Hot Reload**: Use `r` in terminal for quick iterations
3. **Check Logs**: All API calls logged with Dio interceptor
4. **Profile App**: Use DevTools → Performance tab
5. **Test Errors**: Disconnect internet to test error handling

---

## 📞 Support

For issues or questions:
1. Check guide documents first
2. Review error message in app
3. Check console logs
4. Refer to code comments
5. Review model structure

---

*Version: 1.0.0*
*Last Updated: Build Complete*
*Status: Production Ready* ✅
