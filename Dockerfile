FROM python:2
ARG APT_PROXY
ARG PIP_INDEX_URL
ARG PIP_TRUSTED_HOST
ONBUILD ENV PIP_TRUSTED_HOST=$PIP_TRUSTED_HOST PIP_INDEX_URL=$PIP_INDEX_URL
ONBUILD RUN test -n $APT_PROXY && echo 'Acquire::http::Proxy \"$APT_PROXY\";' \
    >/etc/apt/apt.conf.d/proxy

# TERM needs to be set here for exec environments
# PIP_TIMEOUT so installation doesn't hang forever
ENV TERM=xterm \
    PIP_TIMEOUT=180

RUN apt-get update -qq && \
    apt-get install -qy \
        netbase ca-certificates apt-transport-https \
        build-essential locales \
        libdb5.3-dev \
        libxml2-dev \
        libssl-dev \
        libxslt1-dev \
        libevent-dev \
        libffi-dev \
        libpcre3-dev \
        libz-dev \
        telnet vim htop iputils-ping curl wget lsof git \
        ghostscript
# http://unix.stackexchange.com/questions/195975/cannot-force-remove-directory-in-docker-build
#        && rm -rf /var/lib/apt/lists

# adding custom locales to provide backward support with scrapy cloud 1.0
RUN echo 'en_US.UTF-8 UTF-8\nde_DE.UTF-8 UTF-8\nnl_NL.UTF-8 UTF-8\nfr_FR.UTF-8 UTF-8' \
    >> /etc/locale.gen && locale-gen

# Setting environment for bsddb3 install (deltafetch addon)
ENV BERKELEYDB_DIR=/usr

# Custom entrypoint in json format passed via environment
ENV ENTRYPOINT='["/usr/local/sbin/portia-entrypoint"]'
COPY portia-entrypoint /usr/local/sbin/

COPY eggbased-entrypoint /usr/local/sbin/
RUN chmod +x /usr/local/sbin/eggbased-entrypoint && \
    ln -s /usr/local/sbin/eggbased-entrypoint /usr/local/sbin/start-crawl

COPY requirements.txt /requirements-portia.txt
RUN pip install --no-cache-dir -r requirements-portia.txt
