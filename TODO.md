# TODO

## Security hardening + tests

- [x] Step 1: Harden Firestore rules (fix `/shareCodes/{code}` authorization and add schema validation).
- [x] Step 2: Remove/guard debug prints and avoid logging exception internals in Dart services.
- [x] Step 3: Add unit tests for `lib/utils/helpers.dart` validators (edge cases included).
- [x] Step 4: Update `SECURITY_CHECKLIST.md` to reflect implemented items.
- [ ] Step 5: Run `flutter test` and fix any failing tests/build issues.

