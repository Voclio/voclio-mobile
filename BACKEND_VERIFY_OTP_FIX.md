# Backend Verify OTP Fix Required - Registration Flow

## 🚨 Current Issue

When a user enters the **correct OTP** during registration, the backend returns:
```
"Authentication failed. Please try again."
```

## 📋 Current Flow

1. User registers → POST `/auth/register` → User created with `email_verified: false`
2. User enters OTP → POST `/auth/verify-otp` (type: "registration")
3. Backend returns error: "Authentication failed" ❌

## 🔍 Root Cause

The backend's `/auth/verify-otp` endpoint for registration type is not properly handling the verification flow. It's likely:
- Not finding the user
- Not updating `email_verified` status
- Not generating tokens
- Or has authentication logic that blocks unverified users

## ✅ Required Backend Fix

### POST /auth/verify-otp (type: "registration")

**Request:**
```json
{
  "email": "user@example.com",
  "otp_code": "123456",
  "type": "registration"
}
```

**Backend Logic (REQUIRED):**
```javascript
async function verifyOTP(req, res) {
  const { email, otp_code, type } = req.body;
  
  if (type === 'registration') {
    // 1. Find the OTP record
    const otpRecord = await OTP.findOne({
      email,
      code: otp_code,
      type: 'registration',
      verified: false,
      expires_at: { $gt: Date.now() }
    });
    
    if (!otpRecord) {
      return res.status(401).json({
        success: false,
        error: {
          code: "UNAUTHORIZED_ERROR",
          message: "Invalid or expired OTP"
        }
      });
    }
    
    // 2. Find the user (should exist with email_verified: false)
    const user = await User.findOne({ email });
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: {
          code: "NOT_FOUND_ERROR",
          message: "User not found"
        }
      });
    }
    
    // 3. Update user's email_verified status
    user.email_verified = true;
    await user.save();
    
    // 4. Mark OTP as verified
    otpRecord.verified = true;
    await otpRecord.save();
    
    // 5. Generate tokens
    const tokens = generateTokens(user);
    
    // 6. Return success with tokens
    return res.status(200).json({
      success: true,
      message: "Success",
      data: {
        verified: true,
        user: {
          user_id: user._id,
          email: user.email,
          name: user.name,
          phone_number: user.phone_number,
          email_verified: true
        },
        tokens: {
          access_token: tokens.accessToken,
          refresh_token: tokens.refreshToken,
          expires_in: 86400
        },
        message: "Email verified successfully. Welcome to Voclio!"
      }
    });
  }
  
  // Handle other OTP types (password_reset, etc.)
  // ...
}
```

## 📊 Expected Response

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "verified": true,
    "user": {
      "user_id": 1,
      "email": "user@example.com",
      "name": "John Doe",
      "phone_number": "+1234567890",
      "email_verified": true
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expires_in": 86400
    },
    "message": "Email verified successfully. Welcome to Voclio!"
  }
}
```

## 🔄 Complete Registration Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    REGISTRATION FLOW                         │
└─────────────────────────────────────────────────────────────┘

1. User fills registration form
   ↓
2. POST /auth/register (no OTP)
   ↓
3. Backend:
   ✅ Check if email exists
   ✅ If exists with email_verified: true → Return 409
   ✅ If exists with email_verified: false → Resend OTP, return 200
   ✅ If not exists → Create user (email_verified: false), send OTP, return 201
   ↓
4. Frontend: Navigate to OTP screen
   ↓
5. User enters OTP
   ↓
6. POST /auth/verify-otp (type: "registration")
   {
     "email": "user@example.com",
     "otp_code": "123456",
     "type": "registration"
   }
   ↓
7. Backend:
   ✅ Find OTP record
   ✅ Verify OTP is correct and not expired
   ✅ Find user by email
   ✅ Update user.email_verified = true
   ✅ Mark OTP as verified
   ✅ Generate tokens
   ✅ Return user + tokens
   ↓
8. Frontend:
   ✅ Save tokens to secure storage
   ✅ Navigate to Home
   ↓
9. ✅ User is registered and logged in!
```

## 🐛 Common Backend Issues

### Issue 1: User Not Found
```javascript
// ❌ WRONG: Looking for verified user
const user = await User.findOne({ email, email_verified: true });

// ✅ CORRECT: User exists but not verified yet
const user = await User.findOne({ email });
```

### Issue 2: Authentication Check Too Early
```javascript
// ❌ WRONG: Checking authentication before verification
if (!user.email_verified) {
  return res.status(401).json({ error: "Email not verified" });
}

// ✅ CORRECT: This is the verification step!
// Don't check email_verified, we're about to set it to true
```

### Issue 3: Not Returning Tokens
```javascript
// ❌ WRONG: Only returning verification status
return res.json({
  success: true,
  data: { verified: true }
});

// ✅ CORRECT: Return tokens for auto-login
return res.json({
  success: true,
  data: {
    verified: true,
    user: { ... },
    tokens: {
      access_token: "...",
      refresh_token: "...",
      expires_in: 86400
    }
  }
});
```

### Issue 4: OTP Already Verified
```javascript
// ❌ WRONG: Not checking if OTP was already used
const otpRecord = await OTP.findOne({ email, code: otp_code });

// ✅ CORRECT: Only find unverified OTPs
const otpRecord = await OTP.findOne({
  email,
  code: otp_code,
  verified: false,  // ← Important!
  expires_at: { $gt: Date.now() }
});
```

## 🎯 Testing Checklist

### Test 1: New User Registration
```bash
# Step 1: Register
POST /auth/register
{
  "email": "newuser@example.com",
  "password": "password123",
  "name": "New User",
  "phone_number": "+1234567890"
}

# Expected: 201 Created
# Response should have: email_verified: false, no tokens

# Step 2: Verify OTP
POST /auth/verify-otp
{
  "email": "newuser@example.com",
  "otp_code": "123456",
  "type": "registration"
}

# Expected: 200 OK
# Response should have:
# - verified: true
# - email_verified: true
# - access_token
# - refresh_token
```

### Test 2: Incomplete Registration
```bash
# Step 1: Register (user already exists, not verified)
POST /auth/register
{
  "email": "existing@example.com",
  "password": "password123",
  "name": "Existing User",
  "phone_number": "+1234567890"
}

# Expected: 200 OK
# Response: "A new verification code has been sent"

# Step 2: Verify with NEW OTP
POST /auth/verify-otp
{
  "email": "existing@example.com",
  "otp_code": "654321",  # New OTP
  "type": "registration"
}

# Expected: 200 OK
# Response should have tokens
```

### Test 3: Wrong OTP
```bash
POST /auth/verify-otp
{
  "email": "user@example.com",
  "otp_code": "000000",  # Wrong OTP
  "type": "registration"
}

# Expected: 401 Unauthorized
# Response: "Invalid or expired OTP"
```

### Test 4: Expired OTP
```bash
# Wait for OTP to expire (10 minutes)
POST /auth/verify-otp
{
  "email": "user@example.com",
  "otp_code": "123456",  # Expired OTP
  "type": "registration"
}

# Expected: 401 Unauthorized
# Response: "Invalid or expired OTP"
```

## 📝 Database State Verification

After successful OTP verification, verify database state:

```javascript
// User record should be updated
{
  _id: ObjectId("..."),
  email: "user@example.com",
  name: "John Doe",
  phone_number: "+1234567890",
  email_verified: true,  // ← Should be true
  created_at: "2026-02-04T...",
  updated_at: "2026-02-04T..."  // ← Should be updated
}

// OTP record should be marked as verified
{
  _id: ObjectId("..."),
  email: "user@example.com",
  code: "123456",
  type: "registration",
  verified: true,  // ← Should be true
  created_at: "2026-02-04T...",
  expires_at: "2026-02-04T..."
}
```

## 🔗 Related Endpoints

### POST /auth/register
- Creates user with `email_verified: false`
- Sends OTP
- Returns user data (no tokens)

### POST /auth/verify-otp
- Verifies OTP
- Updates `email_verified: true`
- Returns user data + tokens

### POST /auth/login
- Checks `email_verified: true`
- If false, returns error
- If true, returns tokens

## 📋 Summary

**Current Problem:**
- Backend's `/auth/verify-otp` endpoint returns "Authentication failed"
- User cannot complete registration

**Required Fix:**
- Update `/auth/verify-otp` endpoint to:
  1. Find user by email (even if not verified)
  2. Verify OTP
  3. Update `email_verified: true`
  4. Generate and return tokens

**Priority:** 🔴 **CRITICAL** - Blocks all user registrations

**Impact:** Users cannot complete registration and login to the app

## 🚀 Once Fixed

After the backend fix:
1. ✅ Users can complete registration
2. ✅ OTP verification works correctly
3. ✅ Users are automatically logged in after verification
4. ✅ All three authentication scenarios work properly
