# KETUK. 0.1.0-rc1 — Release Checklist

## Definition of Release

0.1.0 adalah **public playable demo / first release**, bukan game lengkap.

Release dianggap siap jika:
- aplikasi boot ke Main Menu;
- game baru bisa dimainkan dari pembuka sampai world exploration;
- pemain tidak terjebak dead-end teknis;
- ownership/inventory konsisten;
- Save / Continue bekerja;
- satu full session tidak menghasilkan parse/runtime blocker;
- Windows export berhasil;
- Web export berhasil atau secara eksplisit ditahan jika platform export template bermasalah.

---

## Automated Gate

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\release_check.ps1 -GodotPath "PATH_KE_GODOT.exe"
```

Required terminal ending:

```
KETUK_RELEASE_CHECK_OK
```

This checks startup for:
- Main Menu
- opening
- auction room
- reveal
- home
- world exploration
- Pasar Tua

The check uses `release-check` mode so autosave does not touch player progress.

---

## Full Manual Run — Required Once

### Main Menu
- GAME BARU starts clean.
- LANJUTKAN disabled if no save exists.
- after first safe checkpoint, return to Main Menu.
- LANJUTKAN restores progress.

### Auction
- investigate each lot.
- BID / WAIT / STOP all respond.
- no missing-node errors after UI migration to `.tscn`.
- winning Lot 02 creates KOTAK CAMPURAN.
- losing Lot 02 never creates it.
- winning Lot 03 creates KAMERA ANALOG.
- losing Lot 03 never creates it.

### Home
- inventory matches actual auction ownership.
- BUKU LAMA exists.
- no automatic Mixed Box opening.
- checkpoint save is created.

### World
- portrait layout scrolls vertically.
- ordinary locations are visitable without quest markers.
- closed places remain visible but cannot transact.
- travel consumes time.
- selling camera adds cash but does not auto-pay kiosk.
- Pak Arman payment must be done separately.

### Mixed Box
- showing it at irrelevant places does not solve it.
- Bengkel Umum can open it.
- alternatively Yanto can open it.
- contents only appear after successful opening:
  - Tatakan Logam
  - Korek Meja
  - Adaptor Lama

### Pasar Tua
- layout scrolls vertically.
- NPC presence follows hidden time windows.
- wrong-time visits show environmental absence.
- showing same item twice to same NPC does not replay the discovery.
- leaving and returning preserves memory/inventory/time.

### Knowledge
- rumor begins as DENGAR.
- direct evidence only verifies the narrow claim it proves.
- BUKU LAMA updates.
- Book does not become a quest list.

### Deadline
- time continues while exploring.
- missing the kiosk deadline can close the kiosk.
- game continues after kiosk loss.

### Sentana
- poster is not present too early.
- later visit can reveal it.
- photographing it creates FOTO POSTER SENTANA.
- poster does not automatically verify every rumor about Sentana.

---

## Save / Continue Regression

Test at least these checkpoints:
1. Home after auction.
2. World Map after moving locations.
3. Pasar Tua after opening Mixed Box.
4. After camera transaction.
5. After kiosk resolution.

For each:
- return to Main Menu;
- Continue;
- verify inventory, cash, time, rumor status, NPC memory, kiosk state, and current world location.

---

## Export Gate

Install matching Godot export templates first.

Build:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build_release.ps1 -GodotPath "PATH_KE_GODOT.exe" -Target all
```

Expected:
- `build/windows/KETUK.exe`
- `build/web/index.html` and companion Web files

The build script automatically runs the release smoke gate before exporting.

---

## Release Blockers

Do not publish if any of these remain:
- parse error;
- missing node / invalid node path;
- scene transition dead-end;
- Continue loads wrong state;
- lost item appears in inventory;
- owned item disappears without transaction;
- duplicated sale/reward;
- save corruption during normal exit/menu flow;
- UI controls inaccessible in portrait view;
- kiosk consequence resets after load;
- world time resets after load;
- export fails.

---

## Non-Blockers for 0.1.0

Can ship and improve later:
- placeholder NPC expression text;
- lack of final portraits;
- simple bid AI;
- limited content breadth;
- no voice acting;
- no Android store release;
- no advanced relationship simulation;
- old internal scene names containing chapter terminology.

---

## Promotion Rule

After:
1. automated gate passes,
2. one full manual run passes,
3. Windows/Web export succeeds,

promote:
- `0.1.0-rc1` → `0.1.0`
- cut release branch/tag
- merge release candidate to `main`
- publish build artifacts.
