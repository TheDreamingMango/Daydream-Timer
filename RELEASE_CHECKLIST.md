# Release checklist

## Real-device testing

- [ ] Test on a physical iPhone.
- [ ] Test on a physical Android device.
- [ ] Confirm other music/audio is interrupted or ducked during each announcement.
- [ ] Confirm other music/audio resumes immediately after the announcement finishes.
- [ ] At two minutes, confirm audio stays interrupted through both the minute and quote, then resumes.
- [ ] Repeat while the app is foregrounded, backgrounded, and the screen is locked.

## Store preparation

- [x] Add final app icons for iOS and Android.
- [x] Replace placeholder bundle/application IDs.
- [x] iPhone 6.9″ App Store screenshots (`store-screenshots/iphone-6.9/`).
- [x] iPad is out of this release. The iOS target is iPhone only, so no iPad screenshots.
- [x] Google Play phone screenshots. Reuse the iPhone 6.9″ set.
- [ ] Configure production release signing for iOS and Android.
- [ ] Create a non-consumable product with id `daydream_timer_unlock` in App Store Connect and Google Play, and set the price there.
- [ ] On a real device, confirm the paywall shows that store price after the trial, a purchase unlocks the timer, and Restore purchase brings it back after a reinstall.

## Privacy and positioning

- [ ] Publish a privacy page describing the app's local-first behavior and any data handling.
- [ ] Publish a support/contact page.
- [x] Show this disclaimer on the timer screen while the session is stopped: “Daydream Timer is a grounding and time-awareness tool. It does not diagnose, treat, or cure any condition and is not a substitute for qualified professional care.”
- [x] Use that same disclaimer in the App Store and Play descriptions (`STORE_LISTING.md`).
- [ ] Review the rest of the store and in-app wording so the app is presented as a mindfulness/wellness tool, not medical treatment.
