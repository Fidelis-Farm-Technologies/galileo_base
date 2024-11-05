# ---------------------------------------------------------------
#
# ---------------------------------------------------------------
FROM bitnami/minideb:bookworm AS gnat_base

# ---------------------------------------------------------------
#
# ---------------------------------------------------------------
RUN --mount=type=cache,target=/var/cache/apt \
	apt-get update \
    && apt-get install -yqq --no-install-recommends build-essential xsltproc \
    libglib2.0-dev automake autotools-dev libpcap-dev libpcre3-dev libssl-dev \
    flex curl libtorch-dev ca-certificates unzip git libtool \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# Install Rust and cargo
# ---------------------------------------------------------------
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
ENV PATH=/root/.cargo/bin:$PATH

# ---------------------------------------------------------------
# Install DuckDB CLI
# ---------------------------------------------------------------
WORKDIR /base/duckdb
RUN curl -L https://github.com/duckdb/duckdb/releases/download/v1.0.0/duckdb_cli-linux-amd64.zip --output duckdb_cli-linux-amd64.zip
RUN unzip duckdb_cli-linux-amd64.zip
RUN mv duckdb /usr/local/bin

# ---------------------------------------------------------------
# Install DuckDB library
# ---------------------------------------------------------------
WORKDIR /base/duckdb
RUN curl -L https://github.com/duckdb/duckdb/releases/download/v1.0.0/libduckdb-linux-amd64.zip  --output libduckdb-linux-amd64.zip 
RUN unzip libduckdb-linux-amd64.zip 
RUN mv duckdb.h duckdb.hpp /usr/local/include
RUN mv libduckdb.so libduckdb_static.a /usr/local/lib

# ---------------------------------------------------------------
# Install Pytorch C++ distribution libraries
# ---------------------------------------------------------------
WORKDIR /base/
RUN curl -L https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.3.0%2Bcpu.zip --output libtorch-cxx11-abi.zip
RUN unzip libtorch-cxx11-abi.zip

# ---------------------------------------------------------------
# Install Maxmind Geolite
# ---------------------------------------------------------------
WORKDIR /base/
RUN curl -L https://github.com/maxmind/libmaxminddb/releases/download/1.10.0/libmaxminddb-1.10.0.tar.gz --output libmaxminddb-1.10.0.tar.gz
RUN tar -xvzf libmaxminddb-1.10.0.tar.gz
RUN cd libmaxminddb-1.10.0 && ./configure && make && make check && make install

# ---------------------------------------------------------------
# Install libfixbuf
# ---------------------------------------------------------------
WORKDIR /base/
RUN git clone https://github.com/Fidelis-Farm-Technologies/cert-nsa-libfixbuf
WORKDIR /base/cert-nsa-libfixbuf
RUN ./configure --disable-tools --prefix=/opt/gnat
RUN make && make install

# ---------------------------------------------------------------
# Install nDPI v4.8-stable
# ---------------------------------------------------------------
WORKDIR /base/
RUN git clone https://github.com/ntop/nDPI.git -b 4.8-stable
WORKDIR /base/nDPI
RUN ./autogen.sh && ./configure && make && make install

# ---------------------------------------------------------------
# Install yaf
# ---------------------------------------------------------------
WORKDIR /base/
RUN git clone https://github.com/Fidelis-Farm-Technologies/cert-nsa-yaf -b ndpi-4.8
WORKDIR /base/cert-nsa-yaf
RUN ./configure --enable-entropy --with-ndpi --prefix=/opt/gnat
RUN make && make install