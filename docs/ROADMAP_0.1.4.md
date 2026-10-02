# KETUK. v0.1.4 — Development Roadmap

Status: proposed scope for the next development cycle.

## Existing playable endpoint

The current public flow already establishes:

- Pasar Tua as a knowledge/network space.
- Sentana as a verified name.
- a poster reading **SENTANA PRIVATE AUCTION — BY INVITATION ONLY**.
- the poster requirement `INVITE REQUIRED`.
- `sentana_photo` as a real inventory item after the player photographs the poster.
- Save / Continue and world-state persistence around this progress.

This is the current narrative/system handoff point.

## Proposed smallest coherent slice

**Working slice: UNDANGAN SENTANA**

Goal: turn the existing poster/photo discovery into a playable investigation for access to the private auction.

The private auction itself is **not** part of this slice yet.

### Player question

> “Aku tahu acara itu ada. Sekarang bagaimana caranya masuk?”

The game should continue to avoid a direct quest-marker answer.

## Scope

1. Recognize the existing Sentana poster/photo state.
2. Allow the player to use that evidence in the existing world/network loop.
3. Produce at least one credible lead toward an invitation.
4. Let the player follow that lead through people/places rather than a menu shortcut.
5. End the slice with a clear access-state outcome:
   - invitation/access secured; or
   - a clearly understood missing requirement that can continue in a later slice.

## Guardrails

- Do not add a new auction event yet.
- Do not reset or invalidate v0.1.3 saves.
- Preserve the distinction between rumor and verified information.
- NPCs must keep bounded knowledge; no universal appraiser/information source.
- No objective marker that simply tells the player the correct route.
- Existing economy, kiosk consequences, and Chapter 2/3 state must remain intact.
- New state must be covered by export/reset/import roundtrip regression tests.

## Technical acceptance

Before merge:

- `release_check.ps1` remains green.
- existing `STATE_ROUNDTRIP_OK` remains green.
- existing `SAVE_RECOVERY_OK` remains green.
- add regression coverage for any new invitation/access state.
- Continue from an existing v0.1.3-compatible save does not crash or reset progress.
- no duplicate reward/access grant.
- no scene dead end.

## Out of scope

- full Sentana private auction gameplay;
- new economy rebalance;
- save-schema rewrite;
- Android packaging;
- Web as a release blocker.

## Promotion rule

Do not call the build v0.1.4 until the invitation slice has a complete playable start, middle, end, and regression coverage.
