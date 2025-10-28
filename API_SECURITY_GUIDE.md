# API Security Guide - Contentflow Pro

## 🔐 ความปลอดภัยของ API Keys

การจัดการ API Keys อย่างถูกต้องเป็นสิ่งสำคัญที่สุดในการพัฒนาแอปพลิเคชัน

---

## ⚠️ สิ่งที่ **ห้าม** ทำ

### ❌ อย่าแชร์ Secret Keys ในที่สาธารณะ

```dart
// ❌ ผิด - อย่าทำแบบนี้
static const String stripeSecretKey = 'sk_live_1234567890...';
```

### ❌ อย่าเก็บ Secret Keys ใน Git

```dart
// ❌ ผิด - อย่า commit ไฟล์ที่มี secret keys
class Config {
  static const apiKey = 'sk_live_real_key_here';
}
```

### ❌ อย่าใช้ Secret Keys ใน Client-Side Code

```dart
// ❌ ผิด - Secret keys ไม่ควรอยู่ใน Flutter app
final response = await http.post(
  url,
  headers: {'Authorization': 'Bearer sk_live_...'},
);
```

---

## ✅ วิธีที่ถูกต้อง

### 1. ใช้ Environment Variables

```dart
// ✅ ถูกต้อง
static const String stripePublishableKey = String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
  defaultValue: 'YOUR_STRIPE_PUBLISHABLE_KEY',
);
```

รันแอปด้วย:
```bash
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
```

### 2. สร้าง Backend API สำหรับ Sensitive Operations

```dart
// ✅ ถูกต้อง - เรียก backend API
Future<void> createSubscription(String tier) async {
  final response = await http.post(
    Uri.parse('https://your-backend.com/api/subscriptions'),
    headers: {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'tier': tier}),
  );
}
```

### 3. ใช้ Supabase Edge Functions

```typescript
// ✅ ถูกต้อง - Supabase Edge Function
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import Stripe from 'https://esm.sh/stripe@11.1.0?target=deno'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') || '', {
  apiVersion: '2022-11-15',
})

serve(async (req) => {
  const { tier, userId } = await req.json()
  
  // Create subscription using secret key (server-side)
  const subscription = await stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: priceId }],
  })
  
  return new Response(JSON.stringify(subscription), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

---

## 🔑 ประเภทของ API Keys

### Publishable Keys (ใช้ได้ใน Client-Side)

```
pk_test_...  // Test mode
pk_live_...  // Production mode
```

**ใช้สำหรับ:**
- เริ่มต้น Stripe Elements
- สร้าง Payment Methods
- แสดง Checkout UI

### Secret Keys (ใช้ได้ใน Server-Side เท่านั้น)

```
sk_test_...  // Test mode
sk_live_...  // Production mode
```

**ใช้สำหรับ:**
- สร้าง Charges
- จัดการ Subscriptions
- คืนเงิน (Refunds)
- เข้าถึงข้อมูลลูกค้า

---

## 🏗️ สถาปัตยกรรมที่แนะนำ

```
┌─────────────────┐
│  Flutter App    │
│  (Client-Side)  │
└────────┬────────┘
         │
         │ 1. User action
         │    (Subscribe to Pro)
         │
         ▼
┌─────────────────┐
│  Supabase       │
│  Edge Function  │
│  (Server-Side)  │
└────────┬────────┘
         │
         │ 2. Create subscription
         │    using Secret Key
         │
         ▼
┌─────────────────┐
│  Stripe API     │
└─────────────────┘
```

---

## 📝 Checklist ก่อน Deploy

- [ ] ลบ Secret Keys ทั้งหมดออกจากโค้ด
- [ ] ใช้ Environment Variables
- [ ] เพิ่ม `.env` ใน `.gitignore`
- [ ] สร้าง Backend API หรือ Edge Functions
- [ ] ทดสอบด้วย Test Keys ก่อน
- [ ] ตรวจสอบ API key rotation policy
- [ ] Setup monitoring สำหรับ API usage

---

## 🚨 กรณีฉุกเฉิน: Secret Key รั่วไหล

### ทำทันที:

1. **Revoke Key ที่รั่วไหล**
   - เข้า Stripe Dashboard → API Keys
   - คลิก "Roll key" หรือ "Delete"

2. **สร้าง Key ใหม่**
   - สร้าง Secret Key ใหม่
   - อัพเดทใน Backend/Edge Functions

3. **ตรวจสอบ Activity Logs**
   - ดู Stripe Dashboard → Developers → Events
   - ตรวจสอบว่ามีการใช้งานผิดปกติหรือไม่

4. **แจ้ง Stripe Support**
   - หากพบการใช้งานที่ผิดปกติ
   - ติดต่อ Stripe Support ทันที

---

## 🔒 Best Practices

### 1. Principle of Least Privilege
ให้สิทธิ์เท่าที่จำเป็นเท่านั้น

### 2. Key Rotation
หมุนเวียน API keys เป็นประจำ (ทุก 90 วัน)

### 3. Separate Keys per Environment
- Development: `sk_test_...`
- Staging: `sk_test_...` (ต่างจาก dev)
- Production: `sk_live_...`

### 4. Monitor API Usage
ตั้ง alerts สำหรับ:
- Unusual API call patterns
- Failed authentication attempts
- High error rates

### 5. Use Webhooks Securely
```dart
// ตรวจสอบ webhook signature
bool verifyWebhookSignature(
  String payload,
  String signature,
  String secret,
) {
  // Implement signature verification
  return true;
}
```

---

## 📚 เอกสารเพิ่มเติม

- [Stripe Security Best Practices](https://stripe.com/docs/security)
- [Supabase Security](https://supabase.com/docs/guides/platform/security)
- [Ayrshare API Security](https://www.ayrshare.com/docs/security)
- [OWASP API Security](https://owasp.org/www-project-api-security/)

---

## 🎯 สรุป

**จำไว้เสมอ:**
1. Secret Keys = Server-Side เท่านั้น
2. Publishable Keys = Client-Side ได้
3. ใช้ Environment Variables
4. ไม่ commit secrets ใน Git
5. Revoke ทันทีถ้ารั่วไหล

---

**หากมีข้อสงสัยเกี่ยวกับความปลอดภัย:**
- อ่านเอกสารของ API provider
- ปรึกษา Security Expert
- ทดสอบใน Test Environment ก่อนเสมอ

