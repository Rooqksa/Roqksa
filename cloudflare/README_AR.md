# خادم الصوت Agora لمشروع Roqksa

يصدر هذا العامل رمز Agora لمدة ساعة بعد التحقق من Firebase ID token للمستخدم.

## متغيرات Cloudflare المطلوبة
- AGORA_APP_ID: App ID العام.
- AGORA_APP_CERTIFICATE: Primary Certificate كـ Secret فقط.

لا تضع الشهادة في GitHub أو Flutter أو المتصفح.

## ربط المستودع بالعامل roqksa-agora
Root directory: /
Build command: npm install
Deploy command: npx wrangler deploy

بعد الربط تأكد من وجود AGORA_APP_ID وAGORA_APP_CERTIFICATE في إعدادات العامل. لا تضف الشهادة إلى ملفات المستودع.

## الطلب
POST / مع Authorization: Bearer <Firebase ID token> وجسم JSON:
{"channelName":"roqksa_room_123"}

لا يصدر العامل رمزاً إلا لمستخدم مسجل دخوله في مشروع Firebase roqksa.
