NAME = asterisk
VERSION = 0.0.2

build:
	docker build --tag="$(NAME):$(VERSION)" .

run:
	docker run -d --name $(NAME) "$(NAME):$(VERSION)

shell:
	docker exec -it $(NAME) /bin/sh

shell-build:
	docker run -it $(NAME):$(VERSION)  sh
