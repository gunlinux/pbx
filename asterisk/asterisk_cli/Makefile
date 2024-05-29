.PHONY: all client server

all: client server

client:
	cd client && go build -ldflags="-s -w" -trimpath -tags netgo -installsuffix netgo -o client client.go

server:
	cd server && go build -ldflags="-s -w" -trimpath -tags netgo -installsuffix netgo -o server server.go


