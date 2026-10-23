# Lesson: Context Cancellation

You'll use a cancel function and inspect the context before and after cancellation.

<include src="shared/context-cancellation/module.md"></include>

## Exercise

Copy the example into a separate file. Move `cancel()` below the print
statement and run the program again. Explain why `ctx.Err()` now returns
`nil`, then add another print statement after cancellation to compare the results.
