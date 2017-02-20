# Scanner base image for Ubuntu 16.04, CUDA 8.0, OpenCV 3.2.0

FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04
MAINTAINER Will Crichton "wcrichto@cs.stanford.edu"
ARG cores=1

# Apt-installable dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:george-edison55/cmake-3.x && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && \
    apt-get install -y libssl-dev libcurl3-dev liblzma-dev libeigen3-dev  \
    libgoogle-glog-dev libatlas-base-dev libsuitesparse-dev libgflags-dev \
    libx264-dev libavcodec-dev libavresample-dev libavformat-dev libavfilter-dev \
    ffmpeg libpng-dev libjpeg-dev libbz2-dev cmake git python-pip wget \
    libleveldb-dev libsnappy-dev libhdf5-serial-dev liblmdb-dev python-dev \
    llvm clang python-tk autoconf autogen libtool libtbb-dev && \
    apt-get install -y --no-install-recommends libboost-all-dev
ADD thirdparty/cuda/libnvcuvid.so.367.48 /usr/lib/x86_64-linux-gnu/libnvcuvid.so
RUN ln -s /usr/local/cuda-8.0/targets/x86_64-linux/lib/stubs/libcuda.so \
       /usr/local/cuda-8.0/targets/x86_64-linux/lib/stubs/libcuda.so.1

# Python dependencies
RUN pip install --upgrade pip && \
    pip install numpy protobuf toml youtube-dl scipy scikit-learn scikit-image \
    enum34 matplotlib seaborn grpcio doxypypy

# Non-apt-installable dependencies
ENV deps /deps
RUN mkdir ${deps}
WORKDIR ${deps}

# gRPC
RUN git clone -b v1.0.0 https://github.com/grpc/grpc && \
    cd grpc && git submodule update --init && make install -j$cores && \
    cd third_party/protobuf && make install -j$cores && \
    rm -rf ${deps}/grpc

# OpenCV
RUN git clone -b 3.2.0 https://github.com/opencv/opencv && \
    git clone -b 3.2.0  https://github.com/opencv/opencv_contrib && \
    git clone -b 1.12.0 https://github.com/ceres-solver/ceres-solver && \
    cd ${deps}/ceres-solver && mkdir build && cd build && cmake .. && \
    make install -j$cores && \
    mkdir ${deps}/opencv/build && cd ${deps}/opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/opt/opencv-3.2.0 \
    -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D ENABLE_FAST_MATH=1 \
    -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 \
    -D OPENCV_EXTRA_MODULES_PATH=${deps}/opencv_contrib/modules \
    .. && \
    make install -j$cores && \
    rm -rf ${deps}/opencv ${deps}/opencv_contrib ${deps}/ceres-solver
ENV OpenCV_DIR /opt/opencv-3.2.0
ENV PYTHONPATH /opt/opencv-3.2.0/lib/python2.7/dist-packages:$PYTHONPATH

# Caffe
RUN git clone https://github.com/BVLC/caffe
ADD thirdparty/caffe/Makefile.config ${deps}/caffe/Makefile.config
RUN cd caffe && mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/opt/caffe -DCUDA_ARCH_NAME=Manual \
          -D CUDA_ARCH_BIN="61" -DCUDA_ARCH_PTX="61" .. && \
    make install -j$cores && \
    rm -rf ${deps}/caffe
ENV Caffe_DIR /opt/caffe
ENV PYTHONPATH /opt/caffe/python:$PYTHONPATH

# Halide
RUN git clone https://github.com/halide/Halide && \
    cd Halide && git checkout auto_scheduler && make distrib -j$cores && \
    cp -r distrib /opt/halide && \
    rm -rf ${deps}/Halide
ENV Halide_DIR /opt/halide

# dlib
RUN git clone -b v19.2 https://github.com/davisking/dlib && \
    cd dlib && mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/opt/dlib .. && \
    make install -j$cores && \
    rm -rf ${deps}dlib
ENV CMAKE_PREFIX_PATH /opt/dlib/lib/cmake/dlib:${CMAKE_PREFIX_PATH}

# OpenFace
RUN git clone https://github.com/scanner-research/OpenFace.git && \
    cd OpenFace && mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/opt/OpenFace .. && \
    make install -j$cores && \
    rm -rf ${deps}/OpenFace
ENV CMAKE_PREFIX_PATH /opt/OpenFace/lib/cmake:${CMAKE_PREFIX_PATH}

WORKDIR /
