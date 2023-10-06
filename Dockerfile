FROM python:3.7-alpine3.8
WORKDIR /django
ENV PYTHONUNBUFFERED=1

#RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev make cmake g++ zlib-dev dpkg git curl
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
    icu-libs \
    icu-data-full


RUN pip install six numpy pandas cython pytest
#RUN pip install --no-cache-dir six pytest numpy cython
#RUN pip install --no-cache-dir pandas
RUN git clone https://github.com/apache/arrow.git
RUN mkdir /arrow/cpp/build    
WORKDIR /arrow/cpp/build

ENV ARROW_BUILD_TYPE=release
ENV ARROW_HOME=/usr/local
ENV PARQUET_HOME=/usr/local

#disable backtrace
RUN sed -i -e '/_EXECINFO_H/,/endif/d' -e '/execinfo/d' ../src/arrow/util/logging.cc

RUN cmake -DCMAKE_BUILD_TYPE=$ARROW_BUILD_TYPE \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
    -DARROW_PARQUET=on \
    -DARROW_PYTHON=on \
    -DARROW_PLASMA=on \
    -DARROW_BUILD_TESTS=OFF \
    ..
RUN make -j$(nproc)
RUN make install

WORKDIR /arrow/python

RUN python setup.py build_ext --build-type=$ARROW_BUILD_TYPE \
    --with-parquet --inplace
#--with-plasma  # commented out because plasma tests don't work
RUN py.test pyarrow

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt