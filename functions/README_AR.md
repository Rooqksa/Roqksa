# خادم رموز Agora لمشروع Roqksa

هذا الخادم يصدر AccessToken2 لمستخدم Firebase المسجل فقط. لا تضع App Certificate داخل تطبيق Flutter أو مستودع Git.

## إعداد السرّ ونشر الدالة

من مجلد المشروع:

```bash
firebase functions:secrets:set AGORA_APP_CERTIFICATE
```

ألصق قيمة **Primary Certificate** في مطالبة الطرفية الخاصة بالأمر، ولا تضعها في ملف أو رسالة أو مستودع.

ثم:

```bash
cd functions
npm install
cd ..
firebase deploy --only functions:createAgoraRtcToken
```

قد يطلب Firebase تفعيل خطة Blaze وربط وسيلة دفع لنشر Cloud Functions. لا تنشر الدالة قبل مراجعة إعدادات الفوترة.

## الواجهة

الدالة callable باسم `createAgoraRtcToken`. يجب استدعاؤها من مستخدم مسجل الدخول، وتمرير `channelName`. تعيد `appId`, `channelName`, `uid`, `token`, و`expiresIn`.

## ملاحظات أمنية

- App ID معرّف عام؛ Primary Certificate سرّ خاص بالخادم.
- الرموز صالحة لمدة ساعة.
- كل UID ثابت للمستخدم المصادق عليه، ولا يقبل العميل UID اعتباطياً.
- هذه الدالة هي أساس إصدار الرمز فقط؛ لا تعني أن واجهة الغرف أو بث المايك قد تم ربطهما أو اختبارهُما بعد.
