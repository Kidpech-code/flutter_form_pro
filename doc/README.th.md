## FlutterFormPro (ภาษาไทย)

แพ็กเกจตรวจสอบความถูกต้องของฟอร์ม (validation) และวิดเจ็ตฟอร์มแบบ Reactive สำหรับ Flutter เน้นประสิทธิภาพและรองรับหลายภาษา (i18n) โดยตั้งค่าเริ่มต้นเป็นภาษาไทย พร้อมตัวตรวจสอบที่ใช้งานได้ทันทีจำนวนมาก

<img src="../assets/images/screenshot.png" alt="FlutterFormPro screenshot" width="480" />

### คุณสมบัติเด่น

- ตัวตรวจสอบครบถ้วน: สตริง ตัวเลข รายการ วันเวลา เครือข่าย/รูปแบบ (email/URL/JSON/สี) ความปลอดภัย (รหัสผ่าน/OTP/PIN) เฉพาะไทย (เบอร์โทร/ไปรษณีย์/บัตรประชาชน) บัตรเครดิต ฯลฯ
- i18n ผ่านไฟล์ JSON (th/en/zh/ja/fr) พร้อม fallback ภาษาไทยในตัว ใช้งานได้แม้ยังไม่ได้โหลดไฟล์
- ประสิทธิภาพสูง: แคชข้อความ i18n และใช้ RegExp ที่คอมไพล์ไว้ล่วงหน้า
- วิดเจ็ต Reactive: TextField (Material/Cupertino), Autocomplete, Number, DatePicker, ปุ่ม Submit และตัวช่วยกด Enter
- ยืดหยุ่น: ใช้ validators อย่างเดียว หรือใช้ชุดวิดเจ็ต FormPro และ custom ได้เต็มที่ด้วย FormProField

---

### ติดตั้ง

เพิ่มแพ็กเกจลงใน `pubspec.yaml`

```yaml
dependencies:
	flutter_form_pro: ^0.0.2
```

หมายเหตุ:

- ถ้าใช้งานเป็น dependency การโหลดไฟล์ i18n จะใช้ path `packages/flutter_form_pro/assets/i18n/...` ให้เอง
- ค่าเริ่มต้นเป็นไทย (`th`) ถ้าไม่ตั้งค่าภาษา

---

### เริ่มต้นใช้งาน (i18n)

```dart
import 'package:flutter_form_pro/flutter_form_pro.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await FormProI18n.setLocaleAndLoad('th'); // หรือ 'en'
	runApp(const MyApp());
}
```

---

### การใช้งานแบบ Validators อย่างเดียว

```dart
TextFormField(
	validator: Validators.multi([
		Validators.required(),
		Validators.email(),
		Validators.minLength(6),
	]),
)
```

ตัวอย่างอื่น ๆ:

```dart
Validators.isUUIDv4();
Validators.isUrl();
Validators.passwordNumberTextSpecial();
Validators.isThaiPhone();
Validators.isFutureDate();
```

หมวดสำคัญที่รองรับ (ยกตัวอย่าง)

- ข้อความ: required, min/max length, isAlpha, isAlphanumeric, isAscii, ตัวพิมพ์เล็ก/ใหญ่, เฉพาะไทย/อังกฤษ
- วันเวลา: date (YYYY-MM-DD), datetime, isFutureDate, isPastDate
- เครือข่าย/รูปแบบ: email, isEmailDomain, isEmailInDomains, isUrl, isJson, isHexColor
- ความปลอดภัย/บัญชี: username, phone, otp, pin, กลุ่ม password\*, creditCard, isVisaCard, isMasterCard
- มาตรฐานบาร์โค้ด/หนังสือ: isEAN8Checksum, isEAN13Checksum, isISBN10, isISBN13
- การเงิน/บัญชี: iban
- ตัวเลข/รายการ: isInt, isDouble, isPositive/Negative, isEven/Odd, isMultipleOf, isInList/isNotInList
- เฉพาะไทย: isThaiPhone, isThaiZipCode, nationalId

---

### วิดเจ็ตฟอร์ม (Reactive)

```dart
late final FormPro form;

@override
void initState() {
	super.initState();
	form = FormPro.builder()
			.addField('email', FormFieldConfig(validators: [Validators.required(), Validators.email()]))
			.addField('username', FormFieldConfig(validators: [Validators.required()]))
			.addField('city', FormFieldConfig(validators: [Validators.required()]))
			.build();
}

@override
Widget build(BuildContext context) {
	return FormProWidget(
		form: form,
		onSubmit: (values) => debugPrint('submit: $values'),
		child: const FormProKeyboardSubmit(
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					SizedBox(height: 12),
					FormProTextField(
						formFieldName: 'email',
						decoration: InputDecoration(labelText: 'Email'),
					),
					SizedBox(height: 12),
					FormProTextControllerField(
						formFieldName: 'username',
						decoration: InputDecoration(labelText: 'Username'),
					),
				],
			),
		),
	);
}
```

วิดเจ็ตเพิ่มเติม

```dart
// Autocomplete
FormProAutocomplete<String>(
	formFieldName: 'city',
	optionsBuilder: (text) {
		const cities = <String>{'Bangkok', 'Chiang Mai', 'Phuket', 'Khon Kaen'};
		final q = text.text.toLowerCase();
		return cities.where((c) => c.toLowerCase().contains(q));
	},
	displayStringForOption: (s) => s,
	decoration: const InputDecoration(labelText: 'City'),
),
const SizedBox(height: 16),
const FormProSubmitButton(child: Text('Submit')),

// Number (รองรับทศนิยม/เครื่องหมาย)
const FormProNumberField(
	formFieldName: 'amount',
	decoration: InputDecoration(labelText: 'Amount'),
	allowDecimal: true,
	signed: false,
)

// Date picker (เก็บเป็นสตริง YYYY-MM-DD)
const FormProDatePickerField(
	formFieldName: 'birthday',
	decoration: InputDecoration(labelText: 'Birthday'),
)

// Cupertino style
const FormProCupertinoTextField(
	formFieldName: 'email',
	placeholder: 'Email',
)
```

Custom UI ด้วย Builder (ควบคุมเองทั้งหมด)

```dart
final myController = TextEditingController();
...
FormProField<String>(
	name: 'username',
	builder: (ctx, value, error, onChanged) => TextField(
		controller: myController..text = value ?? '',
		decoration: InputDecoration(labelText: 'Custom Username', errorText: error),
		onChanged: onChanged,
	),
)
```

---

### กำหนดข้อความเอง และการใช้ค่าเริ่มต้น

- กำหนดข้อความต่อฟิลด์:

```dart
TextFormField(
	validator: Validators.multi([
		Validators.required('กรุณากรอกอีเมล'),
		Validators.email('รูปแบบอีเมลไม่ถูกต้อง'),
		Validators.maxLength(64, 'ไม่เกิน 64 ตัวอักษร'),
	]),
)
```

- เปลี่ยนข้อความแบบรวม (runtime) ด้วย i18n:

```dart
await FormProI18n.setLocaleAndLoad('th');
FormProI18n.add('required', 'ห้ามเว้นว่าง');
FormProI18n.add('email', 'กรุณากรอกอีเมลที่ถูกต้อง');
```

- จัดเก็บข้อความถาวร (แนะนำสำหรับงานทีม/CI): แก้ไฟล์ `assets/i18n/<locale>.json` ของแอป

```json
{
  "required": "ห้ามเว้นว่าง",
  "email": "กรุณากรอกอีเมลที่ถูกต้อง"
}
```

- ใช้ค่าเริ่มต้นของแพ็กเกจ:

ถ้าไม่ตั้งค่า i18n แพ็กเกจจะใช้ภาษาไทย (`th`) โดยอัตโนมัติ และมี fallback ข้อความสำคัญในตัว

```dart
void main() {
	runApp(const MyApp()); // ไม่ต้องตั้งค่า i18n ก็ใช้งานได้ทันที (ภาษาไทย)
}

TextFormField(
	validator: Validators.required(), // แสดงข้อความภาษาไทยโดยอัตโนมัติ
)
```

---

### เปลี่ยนภาษา (i18n)

```dart
await FormProI18n.setLocaleAndLoad('en');
await FormProI18n.preload(['th','en','ja']); // แคชไว้ล่วงหน้า
```

โครงสร้างไฟล์ i18n ภายในแพ็กเกจ: `assets/i18n/<locale>.json`

ถ้าใช้งานเป็น dependency ไม่ต้องตั้งค่าเพิ่มเติม ระบบจะโหลดด้วย path `packages/flutter_form_pro/...` ให้เอง

---

### เคล็ดลับประสิทธิภาพ

- i18n ถูกแคชต่อภาษา; ถ้าเปลี่ยนภาษาบ่อยให้ใช้ `preload([...])`
- `Validators` ใช้ RegExp ที่คอมไพล์ไว้ล่วงหน้า; ควร reuse เพื่อลดการสร้างซ้ำ
- เรียง `required()` ไว้หน้า เพื่อกันเคสว่างก่อนตัวตรวจสอบที่หนักกว่า

---

### การทดสอบ

```zsh
flutter test
```

มีเคสทดสอบ: ขอบเขตวันเวลา รายการ/เอนัมทางลบ วิดเจ็ต Number/Date ที่ผูกกับ FormPro และการส่งฟอร์มด้วยปุ่ม Enter

---

### ตัวอย่างเต็ม

ดูแอปตัวอย่างในโฟลเดอร์ `example/`

---

### ใบอนุญาต / ข้อเสนอแนะ

- ใบอนุญาต: MIT
- ยินดีรับ Issue/PR สำหรับฟีเจอร์/บั๊ก และคำแปลใหม่ ๆ
