#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

BASENAME="osu-micro-benchmarks-7.0.1"
BUILD_DIR="$(pwd)/build"
URL="https://mvapich.cse.ohio-state.edu/download/mvapich/${BASENAME}.tar.gz"
TARFILE="${BASENAME}.tar.gz"
SOURCE_DIR="${BUILD_DIR}/${BASENAME}"
INSTALL_DIR="${SOURCE_DIR}-install"

#Load and bind MPI and UCX
OMPI_VERSION="4.1.1-2"
UCX_VERSION="1.10.0"
module load ompi/$OMPI_VERSION
module load ucx/$UCX_VERSION

env | grep -e 'LD_LIBRARY_PATH'

mkdir -p ${BUILD_DIR}

if [ ! -d "${SOURCE_DIR}" ]; then
	pushd ${BUILD_DIR}
	wget ${URL}
	tar -xzvf ${TARFILE}
	popd
fi

pushd ${SOURCE_DIR}
	./configure CC=$(which mpicc) CXX=$(which mpicxx) --prefix=${INSTALL_DIR}
	make clean
	make

	if [ -d $INSTALL_DIR ]; then
		rm -r $INSTALL_DIR
	fi
	make install
popd
