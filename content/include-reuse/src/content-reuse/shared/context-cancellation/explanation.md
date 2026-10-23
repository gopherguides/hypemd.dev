A context tells a function when its caller no longer needs the work. Calling
the cancel function closes the context's `Done` channel, and `ctx.Err()`
reports why the context ended. The function doing the work still has to check
the context and stop; cancellation doesn't stop a goroutine for you.
