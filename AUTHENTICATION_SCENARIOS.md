1# Authentication Scenarios - Complete Flow Documentation

## 📋 Three Authentication Scenarios

### **Scenario 1: First Time Registration (New User)** ✅

**Flow:**
```
1. User opens app → Register screen
2. User fills form (email, password, name, phone)
3. User clicks "Sign Up"
4. Frontend: POST /auth/register
5. Backend: Creates user with email_verified: false
6. Backend Response (201 Created):
   {
     "success": true,
     "message": "Registration initiated. Please verify your email.",
     "data": {
       "user": {
         "user_id": 1,
         "email": "user@example.com",
         "name": "John Doe",
         "phone_number": "+1234567890",
         "email_verified": false
       },
       "message": "Please verify your email with the OTP sent."
     }
   }
7. Frontend: Detects no tokens → Emits RegistrationPending
8. Frontend: Navigates to OTP screen
9. User enters OTP
10. Frontend: POST /auth/verify-otp (type: "registration")
11. Backend: Verifies OTP, updates email_verified: true, returns tokens
12. Frontend: Saves tokens → Navigates to Home ✅
```

**Code Flow:**
```dart
// Register Screen
listener: (context, state) {
  if (state is RegistrationPending) {
    // No tokens, email not verified
    context.pushRoute(AppRouter.otp, extra: registrationData);
  }
}

// OTP Screen
void _onVerifyOTP() {
  if (widget.type == OTPType.registration) {
    // Send complete registration with OTP
    context.read<AuthBloc>().add(RegisterEvent(requestWithOTP));
  }
}

// Auth Bloc
_onRegister() {
  if (response.token.isNotEmpty) {
    emit(AuthSuccess(response));  // Has tokens → Go to home
  } else {
    emit(RegistrationPending(response));  // No tokens → Go to OTP
  }
}
```

---

### **Scenario 2: Incomplete Registration (User Left App)** ✅

**Flow:**
```
1. User opens app → Register screen
2. User fills form with SAME email as before
3. User clicks "Sign Up"
4. Frontend: POST /auth/register
5. Backend: User exists but email_verified: false
6. Backend: Sends NEW OTP, invalidates old OTP
7. Backend Response (200 OK):
   {
     "success": true,
     "message": "Registration updated. Please verify your email.",
     "data": {
       "user": {
         "user_id": 1,
         "email": "user@example.com",
         "email_verified": false
       },
       "message": "A new verification code has been sent to your email. Previous codes have been invalidated."
     }
   }
8. Frontend: Detects no tokens → Emits RegistrationPending
9. Frontend: Navigates to OTP screen
10. User enters NEW OTP
11. Frontend: POST /auth/verify-otp
12. Backend: Verifies OTP, updates email_verified: true, returns tokens
13. Frontend: Saves tokens → Navigates to Home ✅
```

**Alternative Path (User tries to Login):**
```
1. User opens app → Login screen
2. User enters email + password
3. Frontend: POST /auth/login
4. Backend: User exists but email_verified: false
5. Backend Response (401 Unauthorized):
   {
     "success": false,
     "error": {
       "code": "UNAUTHORIZED_ERROR",
       "message": "Please verify your email before logging in"
     }
   }
6. Frontend: Detects "not verified" in error message
7. Frontend: Shows dialog "Email Not Verified"
8. User clicks "Verify Now"
9. Frontend: POST /auth/send-otp (type: "registration")
10. Frontend: Navigates to OTP screen
11. User enters OTP → Verification complete → Home ✅
```

**Code Flow:**
```dart
// Login Screen
listener: (context, state) {
  if (state is AuthError) {
    final isUnverifiedEmail =
        message.contains('not verified') ||
        message.contains('verify your email');

    if (isUnverifiedEmail) {
      // Show dialog with "Verify Now" button
      VoclioDialog.show(
        title: 'Email Not Verified',
        message: 'Your email is not verified yet. We\'ll send you a new verification code.',
        primaryButtonText: 'Verify Now',
        onPrimaryPressed: () {
          // Send new OTP
          context.read<AuthBloc>().add(SendOTPEvent(email, OTPType.registration));
          // Navigate to OTP screen
          context.pushRoute(AppRouter.otp);
        },
      );
    }
  }
}
```

---

### **Scenario 3: Already Registered & Verified** ✅

**Flow:**
```
1. User opens app → Register screen
2. User fills form with EXISTING verified email
3. User clicks "Sign Up"
4. Frontend: POST /auth/register
5. Backend: User exists AND email_verified: true
6. Backend Response (409 Conflict):
   {
     "success": false,
     "error": {
       "code": "CONFLICT_ERROR",
       "message": "Email already registered"
     }
   }
7. Frontend: Detects "already registered" in error
8. Frontend: Shows dialog "Email Already Registered"
9. User clicks "Go to Login"
10. Frontend: Navigates to Login screen
11. User logs in → Home ✅
```

**Code Flow:**
```dart
// Register Screen
listener: (context, state) {
  if (state is AuthError) {
    final isDuplicateEmail =
        message.contains('already') ||
        message.contains('exists') ||
        message.contains('registered') ||
        message.contains('conflict');

    if (isDuplicateEmail) {
      VoclioDialog.show(
        title: 'Email Already Registered',
        message: 'This email is already registered. Please login or use a different email.',
        primaryButtonText: 'Go to Login',
        secondaryButtonText: 'Try Different Email',
        onPrimaryPressed: () {
          context.goRoute(AppRouter.login);
        },
      );
    }
  }
}
```

---

## 🔄 Complete State Machine

```
┌─────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION STATES                     │
└─────────────────────────────────────────────────────────────┘

[Register Screen]
       ↓
   POST /auth/register
       ↓
   ┌───────────────────────────────────────┐
   │  Backend checks email & verified      │
   └───────────────────────────────────────┘
       ↓
   ┌───┴───┬───────────┬──────────────┐
   │       │           │              │
   ↓       ↓           ↓              ↓
[201]   [200]       [409]         [400]
New     Exists      Verified      Error
User    Unverified  User
   │       │           │              │
   ↓       ↓           ↓              ↓
Send    Resend      Show          Show
OTP     OTP         "Go to        Error
   │       │        Login"
   ↓       ↓           │
[OTP Screen]           │
   │                   │
   ↓                   │
Verify OTP             │
   │                   │
   ↓                   │
[Home] ←───────────────┘
       (after login)
```

---

## 📊 Backend Response Matrix

| Scenario | HTTP Status | email_verified | Has Tokens | Frontend Action |
|----------|-------------|----------------|------------|-----------------|
| **New User** | 201 Created | false | ❌ No | Navigate to OTP |
| **Incomplete Reg** | 200 OK | false | ❌ No | Navigate to OTP |
| **Already Verified** | 409 Conflict | true | ❌ No | Show "Go to Login" |
| **OTP Verified** | 200 OK | true | ✅ Yes | Navigate to Home |
| **Login Success** | 200 OK | true | ✅ Yes | Navigate to Home |
| **Login Unverified** | 401 Unauthorized | false | ❌ No | Show "Verify Email" |

---

## 🎯 Key Decision Points

### **1. Registration Response Handler**
```dart
if (response.token.isNotEmpty) {
  // Scenario: OTP was verified, user is logged in
  emit(AuthSuccess(response));
  → Navigate to Home
} else {
  // Scenario: New user OR incomplete registration
  emit(RegistrationPending(response));
  → Navigate to OTP screen
}
```

### **2. Login Error Handler**
```dart
if (error.message.contains('not verified')) {
  // Scenario: User exists but email not verified
  → Show "Verify Email" dialog
  → Send new OTP
  → Navigate to OTP screen
} else if (error.message.contains('already registered')) {
  // Scenario: Trying to register with verified email
  → Show "Go to Login" dialog
} else {
  // Scenario: Other errors (wrong password, etc.)
  → Show error message
}
```

### **3. OTP Verification Handler**
```dart
if (widget.type == OTPType.registration) {
  // Send complete registration with OTP
  final request = AuthRequest(
    email: email,
    password: password,
    fullName: name,
    phoneNumber: phone,
    otp: otp,  // ← Include OTP
  );
  context.read<AuthBloc>().add(RegisterEvent(request));
}
```

---

## ✅ Implementation Checklist

- [x] **Scenario 1: New User**
  - [x] POST /auth/register returns 201 with no tokens
  - [x] Frontend navigates to OTP screen
  - [x] OTP verification completes registration
  - [x] User navigates to home

- [x] **Scenario 2: Incomplete Registration**
  - [x] POST /auth/register returns 200 with no tokens
  - [x] Frontend navigates to OTP screen
  - [x] New OTP sent, old OTP invalidated
  - [x] Login with unverified email shows "Verify Email" dialog
  - [x] Dialog sends new OTP and navigates to OTP screen

- [x] **Scenario 3: Already Verified**
  - [x] POST /auth/register returns 409 error
  - [x] Frontend shows "Go to Login" dialog
  - [x] User can navigate to login screen

---

## 🔧 Files Modified

1. **lib/features/auth/presentation/screens/login_screen.dart**
   - Added unverified email detection
   - Added "Verify Email" dialog
   - Sends new OTP and navigates to OTP screen

2. **lib/features/auth/presentation/screens/register_screen.dart**
   - Already handles all scenarios correctly
   - Shows appropriate dialogs for each case

3. **lib/features/auth/presentation/screens/otp_screen.dart**
   - Handles registration with OTP
   - Completes verification and navigates to home

4. **lib/features/auth/presentation/bloc/auth_bloc.dart**
   - Checks for tokens in registration response
   - Emits appropriate states

---

## 🚀 Testing Scenarios

### Test 1: New User Registration
1. Open app
2. Go to Register
3. Enter new email
4. Click Sign Up
5. ✅ Should navigate to OTP screen
6. Enter correct OTP
7. ✅ Should navigate to Home

### Test 2: Incomplete Registration (via Register)
1. Register with email (don't verify)
2. Close app
3. Open app again
4. Go to Register
5. Enter same email
6. Click Sign Up
7. ✅ Should navigate to OTP screen
8. Enter new OTP
9. ✅ Should navigate to Home

### Test 3: Incomplete Registration (via Login)
1. Register with email (don't verify)
2. Close app
3. Open app again
4. Go to Login
5. Enter email + password
6. Click Login
7. ✅ Should show "Email Not Verified" dialog
8. Click "Verify Now"
9. ✅ Should navigate to OTP screen
10. Enter OTP
11. ✅ Should navigate to Home

### Test 4: Already Registered
1. Register and verify email
2. Close app
3. Open app again
4. Go to Register
5. Enter same email
6. Click Sign Up
7. ✅ Should show "Email Already Registered" dialog
8. Click "Go to Login"
9. ✅ Should navigate to Login screen

---

## 📝 Summary

All three authentication scenarios are now properly handled:

1. ✅ **New User** → Register → OTP → Home
2. ✅ **Incomplete Registration** → Register/Login → OTP → Home
3. ✅ **Already Verified** → Register → "Go to Login" → Login → Home

The implementation is complete and ready for testing!
