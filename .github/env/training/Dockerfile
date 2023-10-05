FROM ubuntu:22.04

# CONFIGURE NON-INTERACTIVE APT
ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90assumeyes

# INSTALL CORE DEPENDENCIES
RUN apt-get update \
  && apt-get install --no-install-recommends \
    build-essential \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    iputils-ping \
    software-properties-common \
    pkg-config \
    curl \
    wget \
    unzip \
    gpg-agent \
    sudo \
    tzdata \
    locales \
  && locale-gen en_US.UTF-8 \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/*


# INSTALL NODE & GIT
RUN add-apt-repository ppa:git-core/ppa --yes \
  && curl --location https://deb.nodesource.com/setup_18.x | bash \
  && apt-get update \
  && apt-get install --yes git nodejs \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/*

# INSTALL PYTHON
RUN add-apt-repository universe --yes \
  && apt-get update \
  && apt-get install --yes --no-install-recommends python3 python3-pip python3-setuptools python3-dev \
  && update-alternatives --install /usr/bin/python python3 $(which python3) 10 \
  && python -m pip install pip --upgrade \
  && apt-get clean \
  && rm --recursive --force /var/lib/apt/lists/*
