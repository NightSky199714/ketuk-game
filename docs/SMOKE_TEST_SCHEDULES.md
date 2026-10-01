# Smoke Test — Hidden Schedules

## Pasar Tua

Enter Pasar Tua at different times.

Verify:
- a location can exist while its NPC is absent;
- absent NPC produces environmental text, not an exact schedule;
- BICARA is hidden when nobody is there;
- waiting 30 minutes can change who is present;
- inventory remains unchanged while waiting;
- time advances globally.

## Yanto

Arrive before his Sunday window.

Expected:
- Lorong Belakang exists;
- Yanto is not present;
- no BICARA / TUNJUKKAN BARANG for him.

Return later.

Expected:
- Yanto can appear;
- selected inventory item can be shown.

## World Locations

Visit Toko Kamera or Bengkel near/after closing.

Expected:
- travel still consumes time;
- location remains visible;
- environmental closed text appears;
- transaction/service actions are unavailable.

## Kedai Foto

Visit without knowing Adi.

Expected:
- place is still visitable;
- player can talk to the shopkeeper;
- showing a camera can independently surface the name Adi;
- exact Adi schedule is not shown in UI.

Visit Monday morning during his hidden window.

Expected:
- if Adi has been heard of and camera is still owned, interaction can become available.

## Terminal

Visit with no Sentana context.

Expected:
- player can still sit/listen;
- it may produce no useful result.

Later show FOTO POSTER SENTANA or arrive with prior Sentana context.

Expected:
- name can be recognized;
- further listening may reveal an uncertain address.

## Poster

Visit Papan Pengumuman before Sunday 18:30.

Expected:
- no Sentana poster.

Return after Sunday 18:30 or on Monday.

Expected:
- poster appears because of time;
- photographing it adds FOTO POSTER SENTANA to inventory.

## Regression Blockers

- schedule times shown as quest UI;
- NPC name appended to map as waypoint;
- closed shop still allows transactions;
- leaving/re-entering market resets time;
- waiting does not refresh presence;
- poster depends on arbitrary interaction count;
- inventory resets during schedule changes.
