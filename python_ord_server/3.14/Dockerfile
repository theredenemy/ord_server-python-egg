FROM		python:3.14-slim-trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	dnsutils \
	ffmpeg \
	g++ \
	gcc \
	git \
	iproute2 \
	procps \
	tini \
	libzbar0 \
	&& rm -rf /var/lib/apt/lists/*


ENV         USER=container
ENV         HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL	SIGINT

COPY        --chown=root:root --chmod=755 ./../entrypoint.sh /entrypoint.sh
ENTRYPOINT	["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
