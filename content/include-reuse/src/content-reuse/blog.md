# When a Caller Stops Waiting

A client can disconnect while a server is still processing its request.
Passing the request's context to the work lets it respond to cancellation.

<include src="shared/context-cancellation/module.md"></include>

If your function ignores the context, it can keep doing work after the caller
has left. Start by checking whether the operations you call accept a context.
