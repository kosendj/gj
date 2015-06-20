STYLUS = ./node_modules/.bin/stylus
COFFEE = ./node_modules/.bin/coffee
LSC = ./node_modules/.bin/lsc

all: css script

before:
	@mkdir -p build

css: before
	@$(STYLUS) -o build -c src/*.styl

script: before
	@$(COFFEE) -co build/ src/*.coffee
	@$(LSC) -co build/ src/*.ls
