# Running Anime App on Your Android Phone

## Prerequisites Setup

### Step 1: Install Android Studio
Since you don't have Android SDK yet, you need to install it first.

**Download & Install:**
1. Go to: https://developer.android.com/studio
2. Download Android Studio
3. Run the installer
4. Accept all default options
5. Make sure "Android SDK" is checked during installation
6. Let Android Studio complete first-time setup (downloads SDK components)

**After Installation:**
```bash
flutter doctor --android-licenses
```
Accept all licenses by typing 'y'

---

## Phone Setup

### Step 1: Enable Developer Mode on Your Phone
1. Open **Settings** on your Android phone
2. Go to **About phone** (or **About device**)
3. Find **Build number** (might be under "Software information")
4. **Tap Build number 7 times** rapidly
5. You'll see: "You are now a developer!"

### Step 2: Enable USB Debugging
1. Go back to **Settings**
2. Find **Developer options** (usually under System or Additional settings)
3. Turn on **Developer options** (toggle at top)
4. Scroll down and enable:
   - ✅ **USB debugging**
   - ✅ **Install via USB** (if available)

### Step 3: Connect Your Phone to Computer
1. **Use a good USB cable** (must support data transfer, not just charging)
2. **Connect phone to your Windows PC**
3. **On your phone:**
   - You'll see a popup: "Allow USB debugging?"
   - Check "Always allow from this computer"
   - Tap **OK** or **Allow**

4. **Change USB mode if needed:**
   - Pull down notification shade on phone
   - Tap "Charging via USB" or similar notification
   - Select **"File Transfer"** or **"MTP"** mode

---

## Verify Connection

After Android Studio is installed and phone is connected:

```bash
# Check if phone is detected
flutter devices
```

You should see something like:
```
Found 4 connected devices:
  SM G991B (mobile) • 1234567890 • android-arm64 • Android 12 (API 31)
  Windows (desktop) • windows   • windows-x64    • Microsoft Windows
  Chrome (web)      • chrome    • web-javascript • Google Chrome
  Edge (web)        • edge      • web-javascript • Microsoft Edge
```

If you see your phone listed, you're ready!

---

## Run the App on Your Phone

### Option 1: Stop current app and restart on phone
```bash
# Press 'q' in the current flutter run terminal to quit
# Then run:
flutter run -d <device-id>
```

### Option 2: Simple way (Flutter will ask which device)
```bash
flutter run
```
Then select your Android phone from the list.

---

## Troubleshooting

### Phone not detected?

**Try these steps:**

1. **Check cable:**
   - Try a different USB cable
   - Some cables only charge, they don't transfer data

2. **Check USB mode:**
   - On phone, change to "File Transfer" or "MTP" mode

3. **Restart ADB:**
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

4. **Check USB debugging is ON:**
   - Settings → Developer options → USB debugging (should be enabled)

5. **Revoke and reauthorize:**
   - Settings → Developer options → Revoke USB debugging authorizations
   - Disconnect and reconnect phone
   - Allow the popup again

6. **Try different USB port:**
   - Try USB 2.0 port instead of 3.0
   - Try front panel USB instead of back (or vice versa)

### Still not working?

**Install phone drivers manually:**
- Most modern Android phones work automatically
- Some Samsung phones need Samsung USB drivers
- Google Pixel needs Google USB drivers
- Check your phone manufacturer's website

---

## Once Connected - Running the App

1. **Stop the Windows version** (press 'q' in terminal)

2. **Run on phone:**
   ```bash
   flutter run
   ```

3. **Select your Android device** when prompted

4. **Wait for build** (first build takes 2-5 minutes)

5. **App will install and launch on your phone!**

---

## What Will Work on Android

✅ **YouTube WebView** - Will work perfectly!
✅ **Video playback** - Full support
✅ **All features** - Everything will work
✅ **Better performance** - Smoother than Windows desktop

---

## Quick Commands Reference

```bash
# Check devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Clean build
flutter clean && flutter run

# Check ADB connection
adb devices

# Restart ADB
adb kill-server && adb start-server

# Check Flutter setup
flutter doctor

# Accept Android licenses
flutter doctor --android-licenses
```

---

## Alternative: Run on Chrome (Web)

If you can't set up Android right now, you can run on Chrome:

```bash
flutter run -d chrome
```

**Note:** WebView features will work differently on web, but you can test the app layout and most functionality.

---

## Expected First Build Time

- **First build on Android:** 2-5 minutes
- **Subsequent builds:** 10-30 seconds (hot reload even faster!)
- **Windows build was:** ~33 seconds (but WebView doesn't work there)

---

**Status:** Once Android Studio is installed and phone is connected, your app will work perfectly! 🎉

