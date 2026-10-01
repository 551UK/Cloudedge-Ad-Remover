# CloudEdge Ad Remover

Rootless tweak for **CloudEdge 6.3.4** (`com.meari.smartcamera`).

## What it removes

- Launch/startup advertisements.
- Home promotion banners, discount banners, splash promotions and promotional red dots.
- Free-trial and subscription prompts.
- Cloud-storage purchase and upsell UI.
- Paid-service purchase/payment screens and buttons leading into them.
- AI-service promotion UI, AI search, AI summaries and AI-analysis entry screens.
- Known CloudEdge promotional popups and offer cards.
- A text/class-based fallback scrubber for server-driven promo UI that uses generic containers.

## What it does not do

This tweak does **not** fake an active subscription, unlock paid entitlements, or alter CloudEdge account/server billing state. It removes the unwanted advertising, AI and paid-service UI from the app.

## Target

- CloudEdge 6.3.4 / build 432
- Bundle ID: `com.meari.smartcamera`
- Rootless jailbreaks (arm64 / arm64e)
- iOS 15+

## Testing

If any ad, AI item, subscription card, popup or purchase button remains, send a screenshot with the unwanted element circled in red. The remaining surface can then be mapped to its exact CloudEdge class or server-driven view and added to the remover.
