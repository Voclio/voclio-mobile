# OTP Registration Fix - "Email Already Registered" Error ✅

## 🐛 Problem

When entering the **correct OTP** during registration, the app showed:
```
Verification Failed
Email already registered
```

## 🔍 Root Cause

The registration flow was incorrect:

### ❌ Wrong Flow (Before):
```
1. User fills registration form
2. POST /auth/register → Sends OTP, creates pending user
3. User enters OTP
4. POST /auth/register AGAIN (with OTP) → Error: "Email already registered"
   ↑
   WRONG! Trying to register twice!
```

The app was calling the `/auth/register` endpoint **twice**:
- First time: To send OTP
- Second time: With OTP to complete registration

But the backend already created the user on the first call, so the second call failed with "email already registered".

### ✅ Correct Flow (After):
```
1. User fills registration form
2. POST /auth/register → Sends OTP, creates pending user
3. User enters OTP
4. POST /auth/verify-otp (type: "registration") → Verifies OTP, returns tokens
   ↑
   CORRECT! Using the verify endpoint!
```

## 📋 API Documentation (Correct Flow)

According to `AUTH_API_DOCUMENTATION.md`:

### Step 1: Register (Send OTP)
**POST /auth/register**
```json
Request:
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe",
  "phone_number": "+1234567890"
}

Response (201):
{
  "success": true,
  "message": "Registration initiated. Please verify your email.",
  "data": {
    "user": {
      "user_id": "uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "email_verified": false
    },
    "message": "Please verify your email with the OTP sent to complete registration."
  }
}
```

### Step 2: Verify OTP (Complete Registration)
**POST /auth/verify-otp**
```json
Request:
{
  "email": "user@example.com",
  "otp_code": "123456",
  "type": "registration"
}

Response (200):
{
  "success": true,
  "message": "Success",
  "data": {
    "verified": true,
    "user": {
      "user_id": "uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "email_verified": true
    },
    "tokens": {
      "access_token": "jwt_token",
      "refresh_token": "refresh_jwt_token",
      "expires_in": 86400
    },
    "message": "Email verified successfully. Welcome to Voclio!"
  }
}
```

## 🔧 Solution Implemented

### 1. Updated OTP Verification Method

**Before:**
```dart
void _onVerifyOTP() {
  final otp = _otpController.text.trim();

  if (widget.type == OTPType.registration && widget.registrationData != null) {
    // ❌ WRONG: Calling register again
    final request = AuthRequest(
      email: widget.registrationData!.email,
      password: widget.registrationData!.password,
      fullName: widget.registrationData!.fullName,
      phoneNumber: widget.registrationData!.phoneNumber,
      otp: otp,
    );
    context.read<AuthBloc>().add(RegisterEvent(request));
  }
}
```

**After:**
```dart
void _onVerifyOTP() {
  final otp = _otpController.text.trim();

  // ✅ CORRECT: Always use verify OTP endpoint
  final request = OTPRequest(
    email: widget.email,
    otp: otp,
    type: widget.type,
  );
  context.read<AuthBloc>().add(VerifyOTPEvent(request));
}
```

### 2. Updated State Handling

The auth bloc already handles this correctly:

```dart
Future<void> _onVerifyOTP(VerifyOTPEvent event, Emitter<AuthState> emit) async {
  emit(OTPLoading());
  final result = await _verifyOTPUseCase(event.request);
  
  result.fold(
    (failure) => emit(AuthError(failure.message)),
    (response) {
      if (response.token != null && response.token!.isNotEmpty) {
        // ✅ OTP verified, tokens returned - registration complete
        final authResponse = AuthResponse(
          user: response.user!,
          token: response.token!,
          refreshToken: response.refreshToken ?? '',
          expiresAt: response.expiresAt,
        );
        emit(AuthSuccess(authResponse));
      } else {
        // OTP verified but no tokens (e.g., forgot password)
        emit(OTPVerified(response));
      }
    }
  );
}
```

### 3. Updated OTP Screen Listener

```dart
listener: (context, state) {
  if (state is AuthSuccess) {
    // ✅ OTP verification returned tokens - registration complete
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful! Welcome to Voclio!'),
        backgroundColor: Colors.green,
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      context.goRoute(AppRouter.home);
    });
  } 
  else if (state is OTPVerified) {
    // OTP verified but no tokens (forgot password flow)
    if (widget.type == OTPType.forgotPassword) {
      context.pushRoute(AppRouter.resetPassword);
    } else {
      context.goRoute(AppRouter.login);
    }
  }
  else if (state is AuthError) {
    // Show error dialog
    showDialog(...);
  }
}
```

## 📊 Flow Comparison

### Before (Wrong):
```
Register Screen
    ↓
POST /auth/register (sends OTP)
    ↓
OTP Screen
    ↓
POST /auth/register (with OTP) ❌
    ↓
Error: "Email already registered"
```

### After (Correct):
```
Register Screen
    ↓
POST /auth/register (sends OTP)
    ↓
OTP Screen
    ↓
POST /auth/verify-otp (type: "registration") ✅
    ↓
Success: Returns tokens
    ↓
Navigate to Home
```

## 🎯 Testing Scenarios

### ✅ Scenario 1: Successful Registration
1. Fill registration form with new email
2. Click "Sign Up"
3. OTP sent to email
4. Enter correct OTP
5. **Result**: ✅ "Registration successful! Welcome to Voclio!"
6. Navigate to home screen
7. User is logged in with tokens saved

### ✅ Scenario 2: Wrong OTP, Then Correct OTP
1. Fill registration form
2. Click "Sign Up"
3. OTP sent
4. Enter wrong OTP (e.g., 123456)
5. Error dialog: "Verification Failed"
6. Click "Try Again"
7. Enter correct OTP
8. **Result**: ✅ "Registration successful!"
9. Navigate to home

### ✅ Scenario 3: Resend OTP
1. Fill registration form
2. Click "Sign Up"
3. OTP sent
4. Click "Resend Code"
5. New OTP sent
6. Enter new OTP
7. **Result**: ✅ Registration successful

## 🔄 Complete Registration Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    REGISTRATION FLOW                         │
└─────────────────────────────────────────────────────────────┘

1. User fills form (email, password, name, phone)
   ↓
2. Click "Sign Up"
   ↓
3. Frontend: POST /auth/register
   {
     "email": "user@example.com",
     "password": "password123",
     "name": "John Doe",
     "phone_number": "+1234567890"
   }
   ↓
4. Backend:
   - Creates pending user (email_verified: false)
   - Generates OTP
   - Sends OTP email
   - Returns user data (no tokens)
   ↓
5. Frontend: Navigate to OTP screen
   ↓
6. User enters OTP
   ↓
7. Frontend: POST /auth/verify-otp
   {
     "email": "user@example.com",
     "otp_code": "123456",
     "type": "registration"
   }
   ↓
8. Backend:
   - Verifies OTP
   - Updates user (email_verified: true)
   - Generates tokens
   - Returns user + tokens
   ↓
9. Frontend:
   - Saves tokens to secure storage
   - Shows success message
   - Navigates to home
   ↓
10. ✅ User is registered and logged in!
```

## 📝 Files Modified

1. **lib/features/auth/presentation/screens/otp_screen.dart**
   - Changed to always use `VerifyOTPEvent` instead of `RegisterEvent`
   - Updated state handling for `AuthSuccess` and `OTPVerified`
   - Removed duplicate code

2. **lib/features/auth/presentation/bloc/auth_bloc.dart**
   - Already correct! No changes needed
   - Properly handles OTP verification with tokens

3. **lib/features/auth/data/models/otp_response_model.dart**
   - Already supports tokens! No changes needed

## ✅ Result

**The registration flow now works correctly:**
- ✅ No more "Email already registered" error
- ✅ OTP verification completes registration
- ✅ Tokens are saved properly
- ✅ User is logged in automatically
- ✅ Smooth navigation to home screen

## 🚀 Ready for Testing

The fix is complete and ready for testing. The registration flow now follows the correct API pattern:
1. Register → Send OTP
2. Verify OTP → Complete registration with tokens
3. Navigate to home → User logged in

No more duplicate registration attempts!
