VER = 22.04-8.7a4-1

all: ubuntu-tcl-optimized ubuntu-tcl-debug

ubuntu-tcl-optimized: Dockerfile
	docker build --target optimized -t cyanogilvie/ubuntu-tcl:$(VER)-optimized .

ubuntu-tcl-debug: Dockerfile
	docker build --target debug -t cyanogilvie/ubuntu-tcl:$(VER)-debug .

upload: all
	docker push cyanogilvie/ubuntu-tcl:$(VER)-optimized
	#docker push cyanogilvie/ubuntu-tcl:$(VER)-debug

.PHONY: all ubuntu-optimized ubuntu-debug upload
