import 'package:flutter/material.dart';

/// واجهة معاينة لإدارة تفويض الإداريين.
/// لا تحفظ تغييرات فعلية حتى تُربط بوظائف خادم موثوقة وهوية المالك.
class AdminPermissionsScreen extends StatefulWidget {
  const AdminPermissionsScreen({super.key});

  @override
  State<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends State<AdminPermissionsScreen> {
  static const _gold = Color(0xFFFFC86B);
  static const _surface = Color(0xFF192A3B);

  final _admins = const ['إداري تجريبي 1', 'مراقب تجريبي 2'];
  final _permissionGroups = <String, List<String>>{
    'إدارة الأعضاء': ['عرض ملفات الأعضاء', 'تحذير عضو', 'كتم عضو', 'حظر مؤقت', 'حظر دائم', 'رفع الحظر'],
    'إدارة الغرف': ['إدارة الغرف العامة', 'إيقاف غرفة', 'حذف محتوى مخالف'],
    'البلاغات والمحتوى': ['مراجعة البلاغات', 'مراجعة الحالات', 'حذف منشور مخالف'],
    'VIP والشخصيات': ['منح VIP', 'خفض VIP', 'تحديد مدة VIP', 'منح الشخصيات والألقاب', 'سحب الشخصيات والألقاب'],
    'المتجر والمحفظة': ['عرض سجل العملات والهدايا', 'تعويض رصيد ضمن حد يحدده المالك'],
    'الإعلانات': ['إدارة الإعلانات'],
    'السجلات': ['عرض سجل الإجراءات الإدارية'],
  };

  String _selectedAdmin = 'إداري تجريبي 1';
  final Set<String> _selectedPermissions = {'عرض ملفات الأعضاء', 'مراجعة البلاغات'};

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('إدارة صلاحيات الإداريين')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF49351D).withValues(alpha: .45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _gold.withValues(alpha: .5)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_rounded, color: _gold),
                    SizedBox(width: 10),
                    Expanded(child: Text(
                      'معاينة تصميم فقط: الحسابات المعروضة تجريبية، والتغييرات لا تُحفظ ولا تمنح صلاحيات حقيقية. سيُفعّل الحفظ بعد ربط تحقق المالك بالخادم.',
                      style: TextStyle(height: 1.5, fontSize: 12),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('اختر الإداري', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedAdmin,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.admin_panel_settings_outlined)),
                items: _admins.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                onChanged: (value) {
                  if (value != null) setState(() {
                    _selectedAdmin = value;
                    _selectedPermissions
                      ..clear()
                      ..addAll(value == _admins.first
                          ? ['عرض ملفات الأعضاء', 'مراجعة البلاغات']
                          : ['عرض سجل الإجراءات الإدارية']);
                  });
                },
              ),
              const SizedBox(height: 18),
              Row(children: [
                const Expanded(child: Text('الصلاحيات المتاحة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17))),
                Text('${_selectedPermissions.length} محددة', style: const TextStyle(color: _gold, fontSize: 12)),
              ]),
              const SizedBox(height: 8),
              ..._permissionGroups.entries.map((group) => Card(
                    color: _surface,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(group.key, style: const TextStyle(fontWeight: FontWeight.w800)),
                      children: group.value.map((permission) => CheckboxListTile(
                            value: _selectedPermissions.contains(permission),
                            activeColor: _gold,
                            checkColor: const Color(0xFF172331),
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(permission, style: const TextStyle(fontSize: 13)),
                            onChanged: (checked) => setState(() {
                              if (checked == true) {
                                _selectedPermissions.add(permission);
                              } else {
                                _selectedPermissions.remove(permission);
                              }
                            }),
                          )).toList(),
                    ),
                  )),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.lock_outline),
                label: const Text('حفظ الصلاحيات — غير مفعّل حالياً'),
              ),
              const SizedBox(height: 8),
              const Text(
                'حساب المالك لا يظهر ضمن قائمة الإداريين ولا يمكن تعديل صلاحياته من هذه الشاشة. ولا تتضمن قائمة التفويض أي صلاحية لنقل الملكية أو حظر المالك أو تغيير صلاحياته.',
                style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
              ),
            ],
          ),
        ),
      );
}
