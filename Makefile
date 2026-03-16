.PHONY: build serve dev clean tweet tweet-dry

build:
	hype blog build

serve:
	hype blog serve

dev:
	hype blog serve -watch

clean:
	rm -rf public/

docker-build:
	docker build -t hypemd-dev .

docker-run:
	docker run -p 3000:3000 hypemd-dev

tweet:
	@./marketing/tweet.sh $(SLUG)

tweet-dry:
	@./marketing/tweet.sh --dry-run $(SLUG)
