# Scanner base image for Ubuntu 16.04, CUDA 8.0, OpenCV 3.1.0

FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04
MAINTAINER Will Crichton "wcrichto@cs.stanford.edu"

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y software-properties-common

# Apt-installable dependencies
RUN add-apt-repository -y ppa:george-edison55/cmake-3.x
RUN add-apt-repository -y ppa:git-core/ppa
RUN apt-get update
RUN apt-get install -y libssl-dev libcurl3-dev liblzma-dev \
    libprotobuf-dev protobuf-compiler libeigen3-dev libgflags-dev \
    libgoogle-glog-dev libatlas-base-dev libsuitesparse-dev \
    libx264-dev libavcodec-dev libavresample-dev libavformat-dev libavfilter-dev \
    ffmpeg libpng-dev libjpeg-dev libbz2-dev cmake git python-pip wget \
    libleveldb-dev libsnappy-dev libhdf5-serial-dev liblmdb-dev python-dev
RUN apt-get install -y --no-install-recommends libboost-all-dev
ADD thirdparty/cuda/libnvcuvid.so.367.48 /usr/local/cuda/lib64/libnvcuvid.so

# Python dependencies
RUN pip install --upgrade pip
RUN pip install numpy protobuf toml youtube-dl scipy scikit-learn scikit-image

# Non-apt-installable dependencies
ENV deps /deps
RUN mkdir ${deps}

# OpenCV
WORKDIR ${deps}
RUN git clone https://github.com/opencv/opencv
RUN git clone https://github.com/opencv/opencv_contrib
RUN git clone https://ceres-solver.googlesource.com/ceres-solver
RUN cd ceres-solver && mkdir build && cd build && cmake .. && make install -j
RUN mkdir ${deps}/opencv/build && \
    cd ${deps}/opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/opt/opencv-3.1.0 \
    -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D ENABLE_FAST_MATH=1 \
    -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 \
    -D OPENCV_EXTRA_MODULES_PATH=${deps}/opencv_contrib/modules \
    .. && \
    make install -j
ENV OpenCV_DIR /opt/opencv-3.1.0

# Caffe
RUN git clone https://github.com/BVLC/caffe
ADD thirdparty/caffe/Makefile.config ${deps}/caffe/Makefile.config
RUN cd caffe && mkdir build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/opt/caffe -DCUDA_ARCH_NAME=Manual \
          -D CUDA_ARCH_BIN="61" -DCUDA_ARCH_PTX="61" .. && \
    make install -j
ENV Caffe_DIR /opt/caffe
ENV PYTHONPATH /opt/caffe/python
