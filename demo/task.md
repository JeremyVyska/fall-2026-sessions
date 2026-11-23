# Feature request: minimum lead time on delivery windows

**From:** the dispatch team

Dispatch needs notice to plan a route. Today an order can be booked into a
delivery window for tomorrow, even for windows that need days of preparation.

## What we need

- Each delivery window gets a **minimum lead time in days**. Planners set it
  on the Delivery Windows page.
- When an order is booked into a window, or its requested delivery date
  changes, the date must be at least that many days ahead. If it is too
  soon, the booking is refused with a message that names the window and the
  earliest date allowed.
- Zero means no minimum. Existing windows keep working as they do today.
- The daily capacity check stays as it is.

## Done when

- The field is on the Delivery Windows page.
- A too-early booking is refused, and a booking on the earliest allowed date
  is accepted.
- New tests cover both, and all tests pass.
