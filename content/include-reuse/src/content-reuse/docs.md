# Context Cancellation Reference

Use the caller's context when your function performs work that may be canceled.

<include src="shared/context-cancellation/module.md"></include>

Pass the context through to operations that accept it. Check `ctx.Done()`
or `ctx.Err()` when you need to stop your own work.
