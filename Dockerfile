FROM python:3.8-alpine
WORKDIR /django
ENV PYTHONUNBUFFERED=1


RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
    git \
    build-base \
    cmake \
    bash \
    jemalloc-dev \
    boost-dev \
    autoconf \
    zlib-dev \
    flex \
    bison \
    postgresql-dev \
    gcc \
    python3-dev \
    musl-dev \
    make \
    g++ \
    zlib-dev \
    dpkg \
    curl \
    icu-libs 
#    icu-data-full


RUN apk add py3-numpy py3-scipy py3-pandas py3-arrow py3-pyarrow
RUN pip install --upgrade pip
RUN pip install --no-cache-dir six pytest numpy cython

ARG ARROW_VERSION=3.0.0
ARG ARROW_SHA1=c1fed962cddfab1966a0e03461376ebb28cf17d3
ARG ARROW_BUILD_TYPE=release

ENV ARROW_HOME=/django/usr/local \
    PARQUET_HOME=/django/usr/local

#disable backtrace
#RUN sed -i -e '/_EXECINFO_H/,/endif/d' -e '/execinfo/d' ../src/arrow/util/logging.cc

#Download and build apache-arrow
RUN mkdir /django/arrow \
    && wget -q https://github.com/apache/arrow/archive/apache-arrow-${ARROW_VERSION}.tar.gz -O /tmp/apache-arrow.tar.gz \
    && echo "${ARROW_SHA1} *apache-arrow.tar.gz" | sha1sum /tmp/apache-arrow.tar.gz \
    && tar -xvf /django/tmp/apache-arrow.tar.gz -C /django/arrow --strip-components 1 \
    && mkdir -p /django/arrow/cpp/build \
    && cd /django/arrow/cpp/build \
    && cmake -DCMAKE_BUILD_TYPE=$ARROW_BUILD_TYPE \
    -DOPENSSL_ROOT_DIR=/django/usr/local/ssl \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
    -DARROW_WITH_BZ2=ON \
    -DARROW_WITH_ZLIB=ON \
    -DARROW_WITH_ZSTD=ON \
    -DARROW_WITH_LZ4=ON \
    -DARROW_WITH_SNAPPY=ON \
    -DARROW_PARQUET=ON \
    -DARROW_PYTHON=ON \
    -DARROW_PLASMA=ON \
    -DARROW_BUILD_TESTS=OFF \
    .. \
    && make -j$(nproc) \
    && make install \
    && cd /django/arrow/python \
    && python setup.py build_ext --build-type=$ARROW_BUILD_TYPE --with-parquet \
    && python setup.py install \
    && rm -rf /django/arrow /django/tmp/apache-arrow.tar.gz

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt