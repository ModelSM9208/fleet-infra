# ── Stage 1: Build HandBrake with VCE support ────────────────────────────────
FROM automaticrippingmachine/automatic-ripping-machine:latest AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    cmake \
    git \
    libass-dev \
    libbz2-dev \
    libfontconfig-dev \
    libfreetype-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libjansson-dev \
    liblzma-dev \
    libmp3lame-dev \
    libnuma-dev \
    libogg-dev \
    libopus-dev \
    libsamplerate-dev \
    libspeex-dev \
    libtheora-dev \
    libtool \
    libturbojpeg0-dev \
    libvorbis-dev \
    libx264-dev \
    libxml2-dev \
    libvpx-dev \
    m4 \
    make \
    meson \
    nasm \
    ninja-build \
    patch \
    pkg-config \
    python3 \
    tar \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install AMF headers so HandBrake can compile VCE support
RUN git clone --depth 1 https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git /tmp/AMF \
    && cp -r /tmp/AMF/amf/public/include /usr/include/AMF \
    && rm -rf /tmp/AMF

RUN git clone --depth 1 --recurse-submodules https://github.com/HandBrake/HandBrake.git /tmp/HandBrake \
    && cd /tmp/HandBrake \
    && ./configure --disable-gtk --enable-vce --launch-jobs=$(nproc) --launch \
    && make --directory=build install \
    && rm -rf /tmp/HandBrake

# ── Stage 2: Final image ──────────────────────────────────────────────────────
FROM automaticrippingmachine/automatic-ripping-machine:latest

COPY --from=builder /usr/local/bin/HandBrakeCLI /usr/local/bin/HandBrakeCLI

RUN usermod -a -G video arm \
    && usermod -a -G render arm