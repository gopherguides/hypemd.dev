.PHONY: build serve dev clean

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
