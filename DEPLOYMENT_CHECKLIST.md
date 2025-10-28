# Deployment Checklist - Contentflow Pro

## 📋 Pre-Deployment Checklist

ใช้ checklist นี้เพื่อให้แน่ใจว่าทุกอย่างพร้อมสำหรับการ deploy

---

## 🔧 1. Environment Configuration

### Supabase
- [ ] สร้าง Supabase project แล้ว
- [ ] สร้าง database tables ทั้งหมดแล้ว
- [ ] ตั้งค่า Row Level Security (RLS) แล้ว
- [ ] เปิดใช้งาน Authentication providers
- [ ] ทดสอบ authentication flow
- [ ] Copy Project URL และ Anon Key

### Ayrshare
- [ ] สร้าง Ayrshare account แล้ว
- [ ] เลือก subscription plan
- [ ] Copy API Key
- [ ] เชื่อมต่อ social accounts สำหรับทดสอบ
- [ ] ทดสอบ posting functionality

### Stripe
- [ ] สร้าง Stripe account แล้ว
- [ ] สร้าง Products และ Prices
- [ ] Copy Publishable Key
- [ ] Copy Secret Key (เก็บปลอดภัย!)
- [ ] ตั้งค่า Webhooks
- [ ] ทดสอบ payment flow ด้วย test cards

---

## 📝 2. Code Configuration

### Update Environment Variables

```dart
// lib/config/env_config.dart

class EnvConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_ACTUAL_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_ACTUAL_SUPABASE_ANON_KEY';

  // Ayrshare API Configuration
  static const String ayrshareApiKey = 'YOUR_ACTUAL_AYRSHARE_API_KEY';

  // Stripe Configuration
  static const String stripePublishableKey = 'YOUR_ACTUAL_STRIPE_PUBLISHABLE_KEY';
  static const String stripeSecretKey = 'YOUR_ACTUAL_STRIPE_SECRET_KEY';
}
```

### Or use dart-define:

```bash
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key \
  --dart-define=AYRSHARE_API_KEY=your_key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=your_key \
  --dart-define=STRIPE_SECRET_KEY=your_key
```

### Checklist
- [ ] อัพเดท environment variables
- [ ] ลบ test/mock data
- [ ] ลบ debug code
- [ ] ตรวจสอบ API endpoints
- [ ] ตรวจสอบ error handling

---

## 🔐 3. Security Review

### API Keys
- [ ] ลบ hardcoded API keys ทั้งหมด
- [ ] ใช้ environment variables
- [ ] เพิ่ม `.env` ใน `.gitignore`
- [ ] ตรวจสอบว่าไม่มี secrets ใน Git history
- [ ] ใช้ Secret Keys ใน server-side เท่านั้น

### Authentication
- [ ] ตั้งค่า password requirements
- [ ] เปิดใช้งาน email verification
- [ ] ตั้งค่า session timeout
- [ ] ทดสอบ OAuth flows
- [ ] ตรวจสอบ authorization logic

### Database
- [ ] ตรวจสอบ RLS policies
- [ ] ทดสอบ data access permissions
- [ ] Backup database
- [ ] ตั้งค่า database monitoring

---

## 🧪 4. Testing

### Unit Tests
- [ ] รัน `flutter test`
- [ ] ทดสอบ providers
- [ ] ทดสอบ services
- [ ] ทดสอบ models

### Integration Tests
- [ ] ทดสอบ authentication flow
- [ ] ทดสอบ posting functionality
- [ ] ทดสอบ payment flow
- [ ] ทดสอบ subscription management

### Manual Testing
- [ ] ทดสอบบน Android device
- [ ] ทดสอบบน iOS device
- [ ] ทดสอบบน Web browser
- [ ] ทดสอบ responsive design
- [ ] ทดสอบ offline functionality

### User Acceptance Testing
- [ ] สร้าง test accounts
- [ ] ทดสอบ user flows ทั้งหมด
- [ ] เก็บ feedback
- [ ] แก้ไข bugs ที่พบ

---

## 📱 5. Build Configuration

### Android

#### Update `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.contentflowpro"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### Checklist:
- [ ] อัพเดท `applicationId`
- [ ] อัพเดท `versionCode` และ `versionName`
- [ ] สร้าง signing key
- [ ] ตั้งค่า ProGuard rules
- [ ] ทดสอบ release build

#### Build:
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

#### Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Contentflow Pro</string>
<key>CFBundleIdentifier</key>
<string>com.yourcompany.contentflowpro</string>
```

#### Checklist:
- [ ] อัพเดท Bundle Identifier
- [ ] อัพเดท Display Name
- [ ] ตั้งค่า signing certificates
- [ ] เพิ่ม required permissions
- [ ] ทดสอบ release build

#### Build:
```bash
flutter build ios --release
```

### Web

#### Update `web/index.html`:
```html
<title>Contentflow Pro</title>
<meta name="description" content="AI Social Media Management">
```

#### Checklist:
- [ ] อัพเดท title และ meta tags
- [ ] ตั้งค่า favicon
- [ ] ตั้งค่า PWA manifest
- [ ] ทดสอบ responsive design
- [ ] ทดสอบ performance

#### Build:
```bash
flutter build web --release
```

---

## 🚀 6. Deployment

### Android (Google Play Store)

1. **สร้าง Developer Account**
   - [ ] สมัคร Google Play Console
   - [ ] จ่ายค่าธรรมเนียม $25

2. **เตรียม Store Listing**
   - [ ] App name
   - [ ] Short description
   - [ ] Full description
   - [ ] Screenshots (ขั้นต่ำ 2 ภาพ)
   - [ ] Feature graphic
   - [ ] App icon

3. **Upload Build**
   - [ ] Upload AAB file
   - [ ] กรอก release notes
   - [ ] ตั้งค่า pricing & distribution
   - [ ] Submit for review

### iOS (App Store)

1. **สร้าง Developer Account**
   - [ ] สมัคร Apple Developer Program
   - [ ] จ่ายค่าธรรมเนียม $99/ปี

2. **เตรียม App Store Connect**
   - [ ] สร้าง App ID
   - [ ] สร้าง App Store listing
   - [ ] เพิ่ม screenshots
   - [ ] เขียน description

3. **Upload Build**
   - [ ] Archive app ใน Xcode
   - [ ] Upload to App Store Connect
   - [ ] Submit for review

### Web (Hosting)

#### Option 1: Firebase Hosting
```bash
firebase init hosting
firebase deploy
```

#### Option 2: Netlify
```bash
# Drag and drop build/web folder
```

#### Option 3: Vercel
```bash
vercel --prod
```

#### Checklist:
- [ ] เลือก hosting provider
- [ ] ตั้งค่า custom domain
- [ ] ตั้งค่า SSL certificate
- [ ] ตั้งค่า CDN
- [ ] ทดสอบ production URL

---

## 📊 7. Monitoring & Analytics

### Setup Monitoring
- [ ] Firebase Analytics
- [ ] Crashlytics
- [ ] Performance monitoring
- [ ] Error tracking (Sentry)

### Setup Alerts
- [ ] API error alerts
- [ ] Payment failure alerts
- [ ] Server downtime alerts
- [ ] High error rate alerts

---

## 📚 8. Documentation

### User Documentation
- [ ] User guide
- [ ] FAQ
- [ ] Video tutorials
- [ ] Help center

### Developer Documentation
- [ ] API documentation
- [ ] Code comments
- [ ] Architecture diagram
- [ ] Deployment guide

---

## 🎯 9. Marketing & Launch

### Pre-Launch
- [ ] Create landing page
- [ ] Setup social media accounts
- [ ] Prepare press release
- [ ] Contact tech bloggers

### Launch Day
- [ ] Announce on social media
- [ ] Send email to beta testers
- [ ] Post on Product Hunt
- [ ] Monitor feedback

### Post-Launch
- [ ] Collect user feedback
- [ ] Monitor analytics
- [ ] Fix critical bugs
- [ ] Plan updates

---

## 🔄 10. Post-Deployment

### Week 1
- [ ] Monitor crash reports
- [ ] Check API usage
- [ ] Review user feedback
- [ ] Fix critical bugs

### Week 2-4
- [ ] Analyze user behavior
- [ ] Optimize performance
- [ ] Plan feature updates
- [ ] Improve documentation

### Monthly
- [ ] Review analytics
- [ ] Update dependencies
- [ ] Security audit
- [ ] Backup database

---

## ⚠️ Rollback Plan

### If Something Goes Wrong

1. **Immediate Actions**
   - [ ] Revert to previous version
   - [ ] Notify users
   - [ ] Investigate issue

2. **Fix and Redeploy**
   - [ ] Identify root cause
   - [ ] Fix the issue
   - [ ] Test thoroughly
   - [ ] Deploy again

3. **Post-Mortem**
   - [ ] Document what happened
   - [ ] Update processes
   - [ ] Prevent future issues

---

## ✅ Final Checklist

Before clicking "Deploy":

- [ ] ✅ All tests passing
- [ ] ✅ All API keys configured
- [ ] ✅ Security review completed
- [ ] ✅ Documentation updated
- [ ] ✅ Backup created
- [ ] ✅ Monitoring setup
- [ ] ✅ Rollback plan ready
- [ ] ✅ Team notified
- [ ] ✅ Support ready

---

## 🎉 Ready to Deploy!

เมื่อทุกอย่างใน checklist นี้เสร็จสมบูรณ์แล้ว คุณพร้อมที่จะ deploy Contentflow Pro!

**Good luck! 🚀**

---

**Remember:**
- Deploy ในช่วงเวลาที่มี traffic น้อย
- มีทีมพร้อมช่วยเหลือ
- Monitor ใกล้ชิดหลัง deploy
- เตรียม rollback plan ไว้เสมอ

