# Priority App — Command Reference

All commands are run from the project root: `C:\Users\ssharma\Downloads\p_repo\priority`

---

## Run the App

### Web (development — persistent login)
```powershell
C:\Users\ssharma\flutter\bin\flutter.bat run -d chrome --web-browser-flag "--user-data-dir=C:\Users\ssharma\flutter-chrome-profile"
```
Or double-click **`run_web.bat`** in the project folder.

> Sign in once — the Chrome profile at `C:\Users\ssharma\flutter-chrome-profile` persists your session between runs.

### Hot reload / restart while running
| Key | Action |
|-----|--------|
| `r` | Hot reload (keeps state) |
| `R` | Full restart (clears state) |
| `d` | Detach — keeps Chrome alive, frees terminal |
| `q` | Quit — closes Chrome |

### Android (emulator or USB device)
```powershell
C:\Users\ssharma\flutter\bin\flutter.bat run
```

---

## Build for Production

### Web
```powershell
C:\Users\ssharma\flutter\bin\flutter.bat build web --release --web-renderer canvaskit
```

### Android APK (for direct install)
```powershell
C:\Users\ssharma\flutter\bin\flutter.bat build apk --release
```

### Android AAB (for Google Play Store)
```powershell
C:\Users\ssharma\flutter\bin\flutter.bat build appbundle --release
```

---

## Deploy

### Deploy web to Firebase Hosting
```powershell
$env:PATH = "C:\Program Files\nodejs;" + $env:PATH
C:\Users\ssharma\AppData\Roaming\npm\firebase.cmd deploy --only hosting
```

### Deploy Firestore security rules + indexes
```powershell
$env:PATH = "C:\Program Files\nodejs;" + $env:PATH
C:\Users\ssharma\AppData\Roaming\npm\firebase.cmd deploy --only firestore:rules,firestore:indexes
```

### Deploy everything at once
```powershell
$env:PATH = "C:\Program Files\nodejs;" + $env:PATH
C:\Users\ssharma\AppData\Roaming\npm\firebase.cmd deploy
```

---

## Code Quality

### Analyze (check for errors)
```powershell
C:\Users\ssharma\flutter\bin\flutter.bat analyze
```

### Run tests
```powershell
C:\Users\ssharma\flutter\bin\flutter.bat test
```

### Regenerate freezed/json code (run after changing any model file)
```powershell
C:\Users\ssharma\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs
```

---

## Firebase

### List Firebase projects
```powershell
$env:PATH = "C:\Program Files\nodejs;" + $env:PATH
C:\Users\ssharma\AppData\Roaming\npm\firebase.cmd projects:list
```

### Open Firebase Console
https://console.firebase.google.com/project/priority-d553f

### Firebase project ID
`priority-d553f`

### Web app URL (after deploying)
https://priority-d553f.web.app

---

## One-Time Setup (already done — kept here for reference)

```powershell
# 1. Connect to Firebase project
$env:PATH = "C:\Users\ssharma\flutter\bin;" + $env:PATH
C:\Users\ssharma\AppData\Local\Pub\Cache\bin\flutterfire.bat configure --project priority-d553f

# 2. Install dependencies
C:\Users\ssharma\flutter\bin\flutter.bat pub get

# 3. Generate model code
C:\Users\ssharma\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs

# 4. Deploy Firestore rules
$env:PATH = "C:\Program Files\nodejs;" + $env:PATH
C:\Users\ssharma\AppData\Roaming\npm\firebase.cmd deploy --only firestore:rules,firestore:indexes
```

---

## Add Flutter + Firebase CLI to PATH permanently

Run this once in PowerShell (as Administrator) so you never need full paths:

```powershell
[System.Environment]::SetEnvironmentVariable(
  "PATH",
  "$env:PATH;C:\Users\ssharma\flutter\bin;C:\Program Files\nodejs;C:\Users\ssharma\AppData\Roaming\npm",
  "User"
)
```

Then restart PowerShell — after that you can just type `flutter`, `dart`, `firebase` directly.
