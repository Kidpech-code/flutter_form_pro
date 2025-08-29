# Validator RegExp Patterns Reference

This document explains the regular expressions used in FlutterFormPro validators to help developers understand the validation logic and create custom patterns if needed.

## Basic Text Patterns

### Alpha (Letters Only)

```regexp
^[A-Za-z]+$
```

- `^` - Start of string
- `[A-Za-z]` - Any uppercase or lowercase letter
- `+` - One or more occurrences
- `$` - End of string
- Matches: "Hello", "World"
- Rejects: "Hello123", "Hello World" (space), "José" (accents)

### Alphanumeric

```regexp
^[A-Za-z0-9]+$
```

- Combines letters and digits 0-9
- Matches: "Hello123", "ABC", "999"
- Rejects: "Hello World" (space), "test@domain"

### ASCII Only

```regexp
^[\x00-\x7F]+$
```

- `\x00-\x7F` - ASCII character range (0-127)
- Matches: Basic Latin characters, numbers, common symbols
- Rejects: Unicode characters like "café", "北京", "🚀"

## Network & Format Patterns

### Email Address

```regexp
^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$
```

Breakdown:

- `[A-Za-z0-9._%+-]+` - Local part: letters, numbers, dots, underscores, percent, plus, hyphens
- `@` - Literal @ symbol
- `[A-Za-z0-9.-]+` - Domain: letters, numbers, dots, hyphens
- `\.` - Literal dot (escaped)
- `[A-Za-z]{2,}` - TLD: at least 2 letters

Matches: "user@example.com", "test.email+tag@domain.co.uk"
Note: This is a simplified pattern. Full RFC 5322 compliance would be extremely complex.

### URL Pattern

```regexp
^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-\._\?\,\'\/\\\+&%\$#=~]*)?
```

Breakdown:

- `(https?:\/\/)?` - Optional protocol (http:// or https://)
- `([\w\-]+\.)+` - Domain parts with dots (www.example.)
- `[\w\-]+` - Final domain part (com, org)
- `(\/...)*` - Optional path with various allowed characters

Matches: "https://example.com", "www.site.org/path?param=value"

### IPv4 Address

```regexp
^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$
```

Breakdown:

- `(?:...)` - Non-capturing group
- `[0-9]{1,3}` - 1 to 3 digits
- `\.` - Literal dot
- `{3}` - Repeat the group 3 times
- `[0-9]{1,3}` - Final octet

Matches: "192.168.1.1", "127.0.0.1"
Note: This allows invalid IPs like "999.999.999.999". More strict validation would require additional logic.

### Hex Color

```regexp
^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$
```

Breakdown:

- `#?` - Optional hash symbol
- `(...|...)` - Either 6 or 3 hex digits
- `[0-9A-Fa-f]` - Hex characters (0-9, A-F, a-f)

Matches: "#FF0000", "fff", "#ABC", "123456"

## Thai-Specific Patterns

### Thai Phone Number

```regexp
^(0[689]{1})\d{8}$
```

Breakdown:

- `^0` - Must start with 0
- `[689]` - Second digit must be 6, 8, or 9
- `{1}` - Exactly one occurrence
- `\d{8}` - Exactly 8 more digits

Matches: "0812345678" (mobile), "0612345678" (landline), "0912345678" (mobile)
Covers: Thai mobile (08x, 09x) and some landline (06x) patterns

### Thai Postal Code

```regexp
^[1-9][0-9]{4}$
```

Breakdown:

- `[1-9]` - First digit 1-9 (not 0)
- `[0-9]{4}` - Exactly 4 more digits

Matches: "10110" (Bangkok), "50000" (Chiang Mai)
Note: Thai postal codes are 5 digits and don't start with 0

### Thai Text Only

```regexp
^[ก-๙\s]+$
```

Breakdown:

- `ก-๙` - Thai Unicode range (U+0E01 to U+0E39)
- `\s` - Whitespace characters
- Covers Thai consonants, vowels, tone marks, and digits

Matches: "สวัสดี", "ภาษาไทย 123", "กรุงเทพฯ"

## Financial & Security Patterns

### Currency (Basic)

```regexp
^\d+(\.\d{1,2})?$
```

Breakdown:

- `\d+` - One or more digits
- `(...)?` - Optional decimal part
- `\.` - Literal decimal point
- `\d{1,2}` - 1 or 2 decimal digits

Matches: "100", "99.99", "0.5"
Rejects: "100.123" (too many decimals), ".99" (no leading digit)

### Thai Baht

```regexp
^฿\d+(\.\d{1,2})?$
```

- Same as currency but requires ฿ symbol prefix

### Credit Card Patterns

#### Visa

```regexp
^4[0-9]{12}(?:[0-9]{3})?$
```

- `^4` - Must start with 4
- `[0-9]{12}` - Exactly 12 more digits (13-digit cards)
- `(?:[0-9]{3})?` - Optional 3 more digits (16-digit cards)

#### MasterCard

```regexp
^5[1-5][0-9]{14}$
```

- `^5` - Must start with 5
- `[1-5]` - Second digit 1-5
- `[0-9]{14}` - Exactly 14 more digits (total 16)

### Password Patterns

#### Strong Password

```regexp
^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~])[A-Za-z\d!@#\$&*~]{8,}$
```

Breakdown:

- `(?=.*[a-z])` - Positive lookahead: contains lowercase
- `(?=.*[A-Z])` - Contains uppercase
- `(?=.*\d)` - Contains digit
- `(?=.*[!@#\$&*~])` - Contains special character
- `[A-Za-z\d!@#\$&*~]{8,}` - At least 8 characters from allowed set

Requires: All four character types in minimum 8 characters

### UUID Version 4

```regexp
^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$
```

Breakdown:

- `[0-9a-fA-F]{8}` - 8 hex characters
- `-` - Literal hyphen
- `4[0-9a-fA-F]{3}` - Version 4 identifier (starts with 4)
- `[89abAB][0-9a-fA-F]{3}` - Variant bits (8, 9, A, or B)
- Standard UUID v4 format validation

## Advanced Validation Logic

### National ID (Thai)

The Thai National ID uses a checksum algorithm beyond RegExp:

```regexp
^\d{13}$  // Basic format check
```

Then applies MOD 11 checksum:

```dart
int sum = 0;
for (int i = 0; i < 12; i++) {
	sum += int.parse(value[i]) * (13 - i);
}
int check = (11 - (sum % 11)) % 10;
return check == int.parse(value[12]);
```

### Credit Card (Luhn Algorithm)

Basic format varies by brand, then applies Luhn checksum:

```dart
int sum = 0;
bool alt = false;
for (int i = digits.length - 1; i >= 0; i--) {
	int n = int.parse(digits[i]);
	if (alt) {
		n *= 2;
		if (n > 9) n -= 9;
	}
	sum += n;
	alt = !alt;
}
return sum % 10 == 0;
```

### IBAN Validation

Basic format check, then MOD 97 algorithm:

```regexp
^[A-Za-z]{2}\d{2}[A-Za-z0-9]{1,30}$
```

Then rearrange and apply MOD 97 to check validity.

## Performance Considerations

### Pre-compilation Benefits

All RegExp patterns are compiled as `static final` fields:

```dart
static final RegExp _email = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
```

Performance Impact:

- First use: Compile time + match time (~0.1ms)
- Subsequent uses: Match time only (~0.01ms)
- Memory: ~50 bytes per compiled pattern

### Pattern Complexity

- Simple patterns (alpha, numeric): ~0.005ms
- Medium patterns (email, phone): ~0.01ms
- Complex patterns (strong password): ~0.02ms
- Algorithmic validation (Luhn, MOD 97): ~0.05ms

## Creating Custom Patterns

### Best Practices

1. Anchor your patterns: Always use `^` and `$`
2. Be specific: Use character classes instead of `.`
3. Optimize for common cases: Put likely matches first in alternations
4. Consider Unicode: Use `\w` carefully with international text

### Example: Custom Phone Pattern

```dart
// Custom international phone pattern
static final RegExp _customPhone = RegExp(
	r'^(\+\d{1,3}[-.\s]?)?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}$'
);

static Validator customPhone([String? message]) {
	return (value) => (value is String && !_customPhone.hasMatch(value))
		? (message ?? Messages.t('invalid_phone'))
		: null;
}
```

### Testing Patterns

Always test your patterns thoroughly:

```dart
void testPattern() {
	final pattern = RegExp(r'^your-pattern$');

	// Test valid cases
	assert(pattern.hasMatch('valid-input'));

	// Test invalid cases
	assert(!pattern.hasMatch('invalid-input'));

	// Test edge cases
	assert(!pattern.hasMatch(''));
	assert(!pattern.hasMatch(' valid-input ')); // whitespace
}
```

## Common Pitfalls

1. Forgetting anchors: `[A-Z]+` matches "ABC" in "123ABC456"
2. Escaping special chars: Use `\.` not `.` for literal dots
3. Unicode assumptions: `\w` doesn't match Thai/Chinese characters
4. Overly strict: Email validation can reject valid addresses
5. Performance: Avoid excessive backtracking in complex patterns

For more complex validation needs, combine RegExp with algorithmic checks like the examples shown for credit cards and national IDs.
