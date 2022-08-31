ARG UBUNTU_VER="jammy-20220801"
ARG TCL_VER="99b8ad35a258cade"
ARG TCLCONFIG_VER="1f17dfd726292dc4"
ARG THREAD_VER="2a83440579"
ARG PARSEARGS_VER="v0.3.3"
ARG RL_JSON_VER="0.11.3"
ARG TCLLIB_VER="1.20"

FROM ubuntu:$UBUNTU_VER as ubuntu-base
RUN apt-get update && apt-get install -y \
		build-essential \
		autoconf \
		wget \
		locales \
		git \
		vim \
	&& \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
	apt-get dist-upgrade -y && \
	apt-get autoremove && \
	apt-get clean					# Updated 2022-08-29
#	rm -rf /var/lib/apt/lists/*
#RUN apt-get install -y wget
ENV LANG en_US.utf8
WORKDIR /src/tcl
ARG TCL_VER
RUN wget "https://core.tcl-lang.org/tcl/tarball/${TCL_VER}/tcl.tar.gz" -O - | tar xz --strip-components=1
WORKDIR /src/tclconfig
ARG TCLCONFIG_VER
RUN wget "https://core.tcl-lang.org/tclconfig/tarball/${TCLCONFIG_VER}/tclconfig.tar.gz" -O - | tar xz --strip-components=1
WORKDIR /src/thread
ARG THREAD_VER
RUN wget "https://core.tcl-lang.org/thread/tarball/${THREAD_VER}/thread.tar.gz" -O - | tar xz --strip-components=1
WORKDIR /src/parse_args
ARG PARSEARGS_VER
RUN wget "https://github.com/RubyLane/parse_args/archive/${PARSEARGS_VER}.tar.gz" -O - | tar xz --strip-components=1
WORKDIR /src/rl_json
ARG RL_JSON_VER
RUN wget "https://github.com/RubyLane/rl_json/archive/${RL_JSON_VER}.tar.gz" -O - | tar xz --strip-components=1
WORKDIR /src/tcllib
ARG TCLLIB_VER
RUN wget "https://core.tcl-lang.org/tcllib/uv/tcllib-${TCLLIB_VER}.tar.gz" -O - | tar xz --strip-components=1



FROM ubuntu-base as optimized
ARG CFLAGS="-O3 -march=haswell -flto"
WORKDIR /src/tcl
RUN cd /src/tcl/unix && \
    ./configure CFLAGS="${CFLAGS}" --enable-64bit --enable-symbols && \
    make CFLAGS="${CFLAGS} -fprofile-generate=prof -lgcov" -j 16 all && \
	make CFLAGS="${CFLAGS} -fprofile-generate=prof -lgcov" test && \
	make clean && \
    make CFLAGS="${CFLAGS} -fprofile-use=prof -fprofile-partial-training -Wno-coverage-mismatch" -j 16 all && \
    make install-binaries install-libraries install-tzdata install-packages install-headers install-private-headers && \
    cp ../libtommath/tommath.h /usr/local/include/ && \
    ln -s /usr/local/bin/tclsh8.7 /usr/local/bin/tclsh && \
    mkdir /usr/local/lib/tcl8/site-tcl
WORKDIR /src/thread
RUN ln -s /src/tclconfig && \
	autoconf && \
	./configure CFLAGS="${CFLAGS}" --enable-symbols && \
	make CFLAGS="${CFLAGS} -fprofile-generate=prof -lgcov" -j 16 all && \
	make CFLAGS="${CFLAGS} -fprofile-generate=prof -lgcov" test && \
	make clean && \
	make CFLAGS="${CFLAGS} -fprofile-use=prof -fprofile-partial-training -Wno-coverage-mismatch" -j 16 all && \
	make install-binaries install-libraries clean
WORKDIR /src/parse_args
RUN ln -s ../tclconfig && \
	autoconf && ./configure CFLAGS="${CFLAGS}" --enable-symbols && \
	make CFLAGS="${CFLAGS} -fprofile-generate=prof -lgcov" -j 16 binaries && \
	make CFLAGS="${CFLAGS} -fprofile-generate=prof -lgcov" test && \
	make clean && \
	make CFLAGS="${CFLAGS} -fprofile-use=prof -fprofile-partial-training -Wno-coverage-mismatch" -j 16 binaries && \
	make install-binaries install-libraries clean
WORKDIR /src/rl_json
RUN ln -s ../tclconfig && \
	autoconf && ./configure CFLAGS="${CFLAGS}" --enable-symbols && \
	make CFLAGS="${CFLAGS} -fprofile-generate=prof -lgcov" -j 16 binaries && \
	make CFLAGS="${CFLAGS} -fprofile-generate=prof -lgcov" test && \
	make clean && \
	make CFLAGS="${CFLAGS} -fprofile-use=prof -fprofile-partial-training -Wno-coverage-mismatch" -j 16 binaries && \
	make install-binaries install-libraries clean
WORKDIR /src/tcllib
RUN ./configure && \
	make install-libraries install-applications

FROM ubuntu-base as debug
ARG CFLAGS="-Og -DPURIFY"
ARG TCL_VER
WORKDIR /src/tcl
RUN cd /src/tcl/unix && \
    ./configure CFLAGS="${CFLAGS}" --enable-64bit --enable-symbols && \
    make -j 16 all && \
    make install-binaries install-libraries install-tzdata install-packages install-headers install-private-headers && \
    cp ../libtommath/tommath.h /usr/local/include/ && \
    ln -s /usr/local/bin/tclsh8.7 /usr/local/bin/tclsh && \
    make clean && \
    mkdir /usr/local/lib/tcl8/site-tcl

