NAME = asterisk
VERSION = 0.0.2

build:
	BUILDKIT_PROGRESS=plain docker build --tag="$(NAME):$(VERSION)" .

buildc:
	BUILDKIT_PROGRESS=plain docker build --tag="$(NAME):$(VERSION)" . --no-cache
run:
	docker run -d --name $(NAME) "$(NAME):$(VERSION)

shell:
	docker exec -it $(NAME) /bin/sh

shell-build:
	docker run -it $(NAME):$(VERSION)  bash
