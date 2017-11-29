# Scanner base image for Ubuntu 16.04

FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04
MAINTAINER Will Crichton "wcrichto@cs.stanford.edu"
ARG cores=1
ARG cpu_only=OFF

# Apt-installable dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:git-core/ppa && \
    add-apt-repository -y ppa:jonathonf/python-2.7 && \
    apt-get update && \
    apt-get install -y libssl-dev libcurl3-dev liblzma-dev libeigen3-dev  \
    libgoogle-glog-dev libatlas-base-dev libsuitesparse-dev libgflags-dev \
    libx264-dev libopenjpeg-dev libxvidcore-dev \
    libpng-dev libjpeg-dev libbz2-dev git python-pip wget \
    libleveldb-dev libsnappy-dev libhdf5-serial-dev liblmdb-dev python-dev \
    llvm clang python-tk autoconf autogen libtool libtbb-dev libopenblas-dev \
    liblapacke-dev swig yasm python2.7
ADD thirdparty/cuda/libnvcuvid.so.367.48 /usr/lib/x86_64-linux-gnu/libnvcuvid.so
RUN ln -s /usr/local/cuda-8.0/targets/x86_64-linux/lib/stubs/libcuda.so \
       /usr/local/cuda-8.0/targets/x86_64-linux/lib/stubs/libcuda.so.1
ENV CUDA_LIB_PATH /usr/local/cuda/lib64/stubs

# Non-apt-installable dependencies
ENV deps /deps
RUN mkdir ${deps}
WORKDIR ${deps}

# CMake
RUN wget "https://cmake.org/files/v3.8/cmake-3.8.1.tar.gz" && \
    tar -xf cmake-3.8.1.tar.gz && cd ${deps}/cmake-3.8.1 && \
    ./bootstrap --parallel=${cores} && \
    make install -j${cores} && \
    rm -rf ${deps}/cmake-3.8.1.tar.gz ${deps}/cmake-3.8.1

# Python dependencies
ADD requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# FFMPEG
RUN git clone -b n3.3.1 https://git.ffmpeg.org/ffmpeg.git && cd ffmpeg && \
    ./configure --prefix=/opt/ffmpeg-3.3.1 --extra-version=0ubuntu0.16.04.1 \
                --toolchain=hardened --cc=cc --cxx=g++ --enable-gpl \
                --enable-shared --disable-stripping \
                --disable-decoder=libopenjpeg --disable-decoder=libschroedinger \
                --enable-avresample --enable-libopenjpeg --enable-libxvid \
                --enable-libx264 --enable-nonfree --enable-nvenc --enable-cuda \
                --enable-libnpp --enable-cuvid \
                --extra-cflags=-I/usr/local/include \
                --extra-cflags=-I/usr/local/cuda/include \
                --extra-ldflags=-L/usr/local/cuda/lib64 && \
    make install -j${cores} && \
    rm -rf ${deps}/ffmpeg
ENV PATH /opt/ffmpeg-3.3.1/bin:${PATH}
ENV LD_LIBRARY_PATH /opt/ffmpeg-3.3.1/lib:${LD_LIBRARY_PATH}
ENV PKG_CONFIG_PATH /opt/ffmpeg-3.3.1/lib/pkgconfig:${PKG_CONFIG_PATH}

# Boost 1.63.0
RUN wget "https://dl.bintray.com/boostorg/release/1.63.0/source/boost_1_63_0.tar.gz" && \
    tar -xf boost_1_63_0.tar.gz && cd boost_1_63_0 && ./bootstrap.sh && \
    ./b2 install --prefix=/opt/boost-1.63.0 -j ${cores} && \
    rm -rf ${deps}/boost_1_63_0.tar.gz ${deps}/boost_1_63_0
ENV BOOST_ROOT /opt/boost-1.63.0
ENV LD_LIBRARY_PATH /opt/boost-1.63.0/lib:${LD_LIBRARY_PATH}

# OpenCV 3.2.0 + OpenCV contrib
RUN git clone -b 3.2.0 https://github.com/opencv/opencv && \
    git clone -b 3.2.0  https://github.com/opencv/opencv_contrib && \
    git clone -b 1.12.0 https://github.com/ceres-solver/ceres-solver && \
    cd ${deps}/ceres-solver && mkdir build && cd build && cmake .. && \
    make install -j$cores && \
    mkdir ${deps}/opencv/build && cd ${deps}/opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/opt/opencv-3.2.0 \
          -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D ENABLE_FAST_MATH=1 \
          -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 -D WITH_NVCUVID=1 \
          -D OPENCV_EXTRA_MODULES_PATH=${deps}/opencv_contrib/modules \
          .. && \
    make install -j$cores && \
    rm -rf ${deps}/opencv ${deps}/opencv_contrib ${deps}/ceres-solver
ENV OpenCV_DIR /opt/opencv-3.2.0
ENV PYTHONPATH /opt/opencv-3.2.0/lib/python2.7/dist-packages:${PYTHONPATH}

# gRPC 1.4.7
RUN git clone -b v1.4.7 https://github.com/grpc/grpc && \
    cd grpc && git submodule update --init && make install -j$cores && \
    cd third_party/protobuf && make install -j$cores && \
    rm -rf ${deps}/grpc

# Caffe rc5
RUN git clone -b rc5 https://github.com/BVLC/caffe caffe
ADD thirdparty/caffe/Makefile.config ${deps}/caffe/Makefile.config
RUN cd caffe. && mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/caffe \
          -DCPU_ONLY=${cpu_only}  \
          -DCUDA_ARCH_NAME="Manual" \
          -DCUDA_ARCH_BIN="30 35 50 60 61" \
          -DCUDA_ARCH_PTX="30 35 50 60 61" \
          .. && \
    make install -j$cores && \
    rm -rf ${deps}/caffe
ENV Caffe_DIR /opt/caffe
ENV PYTHONPATH /opt/caffe/python:${PYTHONPATH}

# Halide (arbitrary commit)
RUN git clone -b release_2016_10_25 https://github.com/halide/Halide && \
    cd Halide && \
    make distrib -j$cores && \
    cp -r distrib /opt/halide && \
    rm -rf ${deps}/Halide
ENV Halide_DIR /opt/halide

# dlib 19.2
RUN git clone -b v19.2 https://github.com/davisking/dlib && \
    cd dlib && mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/opt/dlib .. && \
    make install -j$cores && make install -j$cores && \
    cd .. && python setup.py install && \
    rm -rf ${deps}/dlib
ENV CMAKE_PREFIX_PATH /opt/dlib/lib/cmake/dlib:${CMAKE_PREFIX_PATH}

# OpenFace (our build)
RUN git clone https://github.com/scanner-research/OpenFace.git && \
    cd OpenFace && mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/opt/OpenFace .. && \
    make install -j$cores && \
    rm -rf ${deps}/OpenFace
ENV CMAKE_PREFIX_PATH /opt/OpenFace/lib/cmake:${CMAKE_PREFIX_PATH}

# FAISS (arbitrary commit)
RUN git clone https://github.com/facebookresearch/faiss/ && \
    cd faiss && git checkout 6893b9e170d75dc0292eb6ea893a54db10acd9fe && \
    cp example_makefiles/makefile.inc.Linux makefile.inc && \
    sed -i -e 's/BLASLDFLAGS=\/usr\/lib64\/libopenblas.so.0/BLASLDFLAGS=\/usr\/lib\/libopenblas.so.0/g' makefile.inc && \
    sed -i -e 's/\/usr\/lib64\/python2.7\/site-packages\/numpy\/core\/include\//\/usr\/local\/lib\/python2.7\/dist-packages\/numpy\/core\/include/g' makefile.inc && \
    make -j$cores && make py -j$cores && \
    cd gpu && make -j$cores && make py -j$cores && \
    cp -r ${deps}/faiss /opt/faiss && \
    rm -rf ${deps}/faiss
ENV PYTHONPATH /opt/faiss:${PYTHONPATH}

WORKDIR /
