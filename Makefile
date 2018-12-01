build-all: npm-deps purs-deps build

npm-deps:
	yarn install

purs-deps:
	psc-package2nix
	nix-shell install-deps.nix --run 'echo installation complete.'
build:
	yarn build:prod