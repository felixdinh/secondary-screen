# secondary_screen_example

Point-of-Sale example for the `secondary_screen` package.

## Screens

- `SalesScreen` is the cashier-facing primary screen.
- `PromotionScreen` is the default customer-facing secondary screen.
- `OrderDisplayScreen` is shown on the secondary screen when the order has items.

## Routes

- `sales` and `/` -> `SalesScreen`
- `presentation` -> `PromotionScreen`
- `order_display` -> `OrderDisplayScreen`

Run it on an Android device or emulator with a secondary display:

```bash
flutter run
```
