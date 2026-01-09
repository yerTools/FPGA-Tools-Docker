# MIT License

# Copyright (c) 2025 Dmitry Ryabikov

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Thank you to Dmitry Ryabikov! This Dockerfile ended hours of trying to get Gowin to work on my machine. <3
# - Felix :)

FROM ubuntu:latest

LABEL maintainer="FelixM@yer.tools"

# Install basic dependencies
RUN apt-get update -y && \
    apt-get install -y \
    wget \
    build-essential \
    git \
    usbutils 

# Build Gowin Education
RUN wget https://cdn.gowinsemi.com.cn/Gowin_V1.9.10.03_Education_linux.tar.gz && \
    mkdir gowin && \
    tar -xf Gowin_V1.9.10.03_Education_linux.tar.gz -C gowin && \
    rm Gowin_V1.9.10.03_Education_linux.tar.gz

# Fix libz.so.1 conflict
RUN mv gowin/Programmer/bin/libz.so.1 gowin/Programmer/bin/libz.so.1.bak

# Install udev rules
RUN mkdir -p /etc/udev/rules.d && \
    cp gowin/Programmer/Driver/50-programmer_usb.rules /etc/udev/rules.d/

ENV PATH="/gowin/IDE/bin:/gowin/Programmer/bin:$PATH"
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libfreetype.so.6"

# Build Icarus Verilog
RUN apt-get update -y && \
    apt-get install -y \
    make \
    g++ \
    git \
    bison \
    flex \
    gperf \
    libreadline-dev \
    autoconf

RUN git clone https://github.com/steveicarus/iverilog && \
    cd iverilog && \
    autoconf && \
    ./configure && \
    make check && \
    make install && \
    cd ../ && \
    rm -rf iverilog

# Build Yosys
RUN apt-get update -y && \
    apt-get install -y \
    gperf \
    build-essential \
    bison \
    flex \
    libreadline-dev \
    gawk \
    tcl-dev \
    libffi-dev \
    git \
    graphviz \
    xdot \
    pkg-config \
    python3 \
    libboost-system-dev \
    libboost-python-dev \
    libboost-filesystem-dev \
    zlib1g-dev

RUN git clone --recurse-submodules https://github.com/YosysHQ/yosys.git && \
    cd yosys && \
    make && \
    make install && \
    cd ../ && \
    rm -rf yosys

# Build Verilator
RUN apt-get update -y && \
    apt-get install -y \
    git \
    help2man \
    perl \
    python3 \
    make \
    autoconf \
    g++ \
    flex \
    bison \
    ccache \
    libgoogle-perftools-dev \
    numactl \
    perl-doc
    
RUN git clone https://github.com/verilator/verilator && \
    cd verilator && \
    git checkout stable && \
    autoconf && \
    ./configure && \
    make -j `nproc` && \
    make install && \
    cd ../ && \
    rm -rf verilator

# Build Bazel (for Verible)
RUN apt install apt-transport-https curl gnupg -y && \
    curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg && \
    mv bazel-archive-keyring.gpg /usr/share/keyrings && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list && \
    apt-get update -y && \
    apt-get install bazel -y

# Build Verible 
RUN apt install bazel-7.6.0 -y && \
    git clone https://github.com/chipsalliance/verible.git && \
    cd verible && \
    bazel build -c opt :install-binaries && \
    .github/bin/simple-install.sh ../usr/local/bin && \
    cd ../ && \
    rm -rf verible && \
    rm -rf /root/.cache/bazel

RUN apt-get update -y && \
    apt-get install -y \
    python3 \
    python3-venv \
    python3-pip

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt ./
RUN pip install -r requirements.txt

# Install openFPGALoader (https://wiki.sipeed.com/hardware/en/tang/common-doc/flash-in-linux)
RUN apt-get update -y && \
    apt-get install -y \
    libftdi1-2 \
    libftdi1-dev \
    libhidapi-hidraw0 \
    libhidapi-dev \
    libudev-dev \
    zlib1g-dev \
    cmake \
    pkg-config \
    make \
    g++ && \
    git clone https://github.com/trabucayre/openFPGALoader.git && \
    cd openFPGALoader && \
    mkdir build && \
    cd build && \
    cmake ../ && \
    cmake --build . && \
    make install && \
    cd ../ && \
    mkdir -p /etc/udev/rules.d && \
    cp 99-openfpgaloader.rules /etc/udev/rules.d/ && \
    cd ../ && \
    rm -rf openFPGALoader

# Install PulseView and sigrok for Logic Analyzers (e.g., Sipeed SLogic16U3)
RUN apt-get update -y && \
    apt-get install -y \
    pulseview \
    sigrok \
    sigrok-cli \
    libsigrok-dev \
    sigrok-firmware-fx2lafw

# Install udev rules for sigrok-supported devices
RUN wget -O /etc/udev/rules.d/60-libsigrok.rules \
    https://raw.githubusercontent.com/sigrokproject/libsigrok/master/contrib/60-libsigrok.rules && \
    wget -O /etc/udev/rules.d/61-libsigrok-plugdev.rules \
    https://raw.githubusercontent.com/sigrokproject/libsigrok/master/contrib/61-libsigrok-plugdev.rules

# Add desktop entry for Gowin IDE
COPY gowin.desktop /usr/share/applications/gowin.desktop
RUN chmod 644 /usr/share/applications/gowin.desktop

# Add desktop entry for PulseView
COPY pulseview.desktop /usr/share/applications/pulseview.desktop
RUN chmod 644 /usr/share/applications/pulseview.desktop

# Final cleanup to reduce image size
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

# Smoke test - verify all tools are installed correctly
RUN set -e && \
    echo "=== Smoke Test ===" && \
    iverilog -V && \
    yosys -V && \
    verilator --version && \
    verible-verilog-lint --version && \
    openFPGALoader --help && \
    pulseview --version && \
    sigrok-cli --version && \
    which gw_ide && \
    which gw_sh && \
    pip list && \
    echo "✅ All tools verified!"

# For working in Distrobox or similar environments
# Reload the udev rules and activate them
# sudo udevadm control --reload-rules && sudo udevadm trigger # force udev to take new rule
# Add the current user to the plugdev group
# sudo usermod -a $USER -G plugdev # add user to plugdev group