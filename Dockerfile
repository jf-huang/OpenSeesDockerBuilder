FROM ubuntu:18.04

# basic variables and packages
ENV DEBIAN_FRONTEND=noninteractive \
    mainDir=/home
WORKDIR $mainDir

# basic packages
RUN apt-get -y update && \
apt-get --no-install-recommends -y install build-essential gcc gfortran make cmake dkms tcl8.6-dev zlib1g-dev flex bison python git && \
rm -rf /var/lib/apt/lists/*
#apt-get -y upgrade

#COPY mpich2-1.5rc3.tar.gz blas-3.8.0.tgz lapack-3.9.0.tar.gz scalapack-2.1.0.tar.gz \
#     metis-5.1.0.tar.gz parmetis-4.0.3.tar.gz scotch_6.0.9.tar.gz MUMPS_5.2.1.tar.gz \
#     CMake-hdf5-1.10.4.tar.gz ./

# get dependent packages, specify http.sslVerify=false to disable security check
RUN git -c http.sslVerify=false clone https://github.com/jf-huang/OpenSeesDcokerBuilder.git && \
mv OpenSeesDcokerBuilder/* ./ && rm -r OpenSeesDcokerBuilder mumps_5.1.2.orig.tar.gz v2.2.1.petsc.tar.gz *Dockerfile* && \
\
\
\
# mpich, install path: $mainDir/mpiInstall/bin
tar -xzf ./mpich2-1.5rc3.tar.gz && \
cd ./mpich2-1.5rc3 && \
./configure --prefix=$mainDir/mpiInstall 2>&1 | tee c.txt && \
make 2>&1 | tee m.txt && \
make install 2>&1 | tee mi.txt && \
cd .. && rm -r mpich2-1.5rc3.tar.gz ./mpich2-1.5rc3 && \
export PATH=$PATH:$mainDir/mpiInstall/bin && \
#ENV PATH "$PATH:$mainDir/mpiInstall/bin" \
\
\
\
# blas, lapack and scalapack, installed in /usr/local/lib/ \
tar -xzf blas-3.8.0.tgz && \
cd BLAS-3.8.0 && make && mv blas_LINUX.a libblas.a && \
cp libblas.a /usr/local/lib/ && \
cd .. && tar -xzf lapack-3.9.0.tar.gz && \
cd lapack-3.9.0 && mv make.inc.example make.inc && ulimit -s unlimited && make && \
cp liblapack.a /usr/local/lib/ && \
cd .. && tar -xzf scalapack-2.1.0.tar.gz && \
cd scalapack-2.1.0 && mv SLmake.inc.example SLmake.inc && make && \
cp libscalapack.a /usr/local/lib/ && \
cd .. && rm -r blas-3.8.0.tgz BLAS-3.8.0 lapack-3.9.0.tar.gz lapack-3.9.0 scalapack-2.1.0.tar.gz scalapack-2.1.0 && \
\
\
\
# metis and parmetis, installed in /usr/local by default \
tar -xzf metis-5.1.0.tar.gz && cd metis-5.1.0 && \
sed -i 's/#define IDXTYPEWIDTH 32/#define IDXTYPEWIDTH 64/g' ./include/metis.h && make && make install && \
cd .. && tar -xzf parmetis-4.0.3.tar.gz && cd parmetis-4.0.3 && \
sed -i 's/#define IDXTYPEWIDTH 32/#define IDXTYPEWIDTH 64/g' ./metis/include/metis.h && make && make install && \
cd .. && rm -r metis-5.1.0.tar.gz parmetis-4.0.3.tar.gz && \
\
\
\
# scotch and pscotch, installed in /usr/local by default \
tar -xzf scotch_6.0.9.tar.gz && cd scotch_6.0.9 && \
cd src && cp Make.inc/Makefile.inc.x86-64_pc_linux2 Makefile.inc && \
sed -i 's/CCD		= gcc/CCD		= mpicc/g' Makefile.inc && \
make ptscotch && make install && \
cd ../../ && rm -r scotch_6.0.9.tar.gz && \
\
\
\
# mumps, note that metis, parmetis, scotch are deleted after compilation of mumps to reduce docker image size \
tar -xzf MUMPS_5.2.1.tar.gz && cd MUMPS_5.2.1 && \
cp Make.inc/Makefile.inc.generic Makefile.inc && \
sed -i 's:#SCOTCHDIR  = ${HOME}/scotch_6.0:SCOTCHDIR  = /usr/local:g' Makefile.inc && \
sed -i 's:#ISCOTCH    = -I$(SCOTCHDIR)/include:ISCOTCH    = -I$(SCOTCHDIR)/include:g' Makefile.inc && \
sed -i 's:#LSCOTCH    = -L$(SCOTCHDIR)/lib -lptesmumps -lptscotch -lptscotcherr:LSCOTCH    = -L$(SCOTCHDIR)/lib -lptesmumps -lptscotch -lptscotcherr:g' Makefile.inc && \
sed -i 's:#LMETISDIR = /opt/metis-5.1.0/build/Linux-x86_64/libmetis:LMETISDIR = /usr/local/lib:g' Makefile.inc && \
sed -i 's:#IMETIS    = /opt/metis-5.1.0/include:IMETIS    = /usr/local/include:g' Makefile.inc && \
sed -i 's:#LMETIS    = -L$(LMETISDIR) -lparmetis -lmetis:LMETIS    = -L$(LMETISDIR) -lparmetis -lmetis:g' Makefile.inc && \
sed -i 's:#ORDERINGSF = -Dscotch -Dmetis -Dpord -Dptscotch -Dparmetis:ORDERINGSF = -Dscotch -Dmetis -Dpord -Dptscotch -Dparmetis:g' Makefile.inc && \
sed -i 's:CC      = cc:CC      = mpicc:g' Makefile.inc && \
sed -i 's:FC      = f90:FC      = mpif90:g' Makefile.inc && \
sed -i 's:FL      = f90:FL      = mpif90:g' Makefile.inc && \
sed -i 's:INCPAR  = -I/usr/include:INCPAR  = -I${mainDir}/mpiInstall:g' Makefile.inc && \
sed -i 's:OPTF    = -O:OPTF    = -O -I${mainDir}/scotch_6.0.9/include -I${mainDir}/mpiInstall:g' Makefile.inc && \
sed -i 's:OPTC    = -O -I.:OPTC    = -O -I. -I${mainDir}/scotch_6.0.9/include:g' Makefile.inc && \
make alllib && \
cd .. && rm -r MUMPS_5.2.1.tar.gz metis-5.1.0 parmetis-4.0.3 scotch_6.0.9 && \
\
\
\
# hdf5 \
tar -xzf CMake-hdf5-1.10.4.tar.gz && cd CMake-hdf5-1.10.4/ && cd hdf5-1.10.4 && \
./configure --prefix=/usr/local/hdf5 --enable-parallel --enable-build-mode=production --disable-shared && \
make && make install && make check-install && \
cd ../../ && rm -r CMake-hdf5-1.10.4.tar.gz CMake-hdf5-1.10.4 && \
#make && make check && make install && make check-install \
\
\
\
# opensees, install path: $mainDir/bin \
#RUN git clone https://github.com/jf-huang/OpenSees.git \
# parallel version \
git -c http.sslVerify=false clone https://github.com/jf-huang/OpenSees.git && cd OpenSees && \
rm Makefile.def && cp Makefile_PARALLEL.def Makefile.def && \
sed -i 's:HOME  = /home/jfhuang:HOME  = ${mainDir}:g' Makefile.def && \
sed -i 's:MUMPS_DIR = /home/jfhuang/Downloads/MUMPS_5.1.2:MUMPS_DIR = ${mainDir}/MUMPS_5.2.1:g' Makefile.def && \
make wipe && make && \
cd .. && rm -r OpenSees MUMPS_5.2.1

ENV PATH "$PATH:$mainDir/mpiInstall/bin:$mainDir/bin"

# sequential version, might need to rebuild sequential version of HDF5 Lib
#RUN ls /usr/local/hdf5/include && rm -r OpenSees && git clone https://github.com/jf-huang/OpenSees.git && cd OpenSees && rm Makefile.def && cp Makefile_SEQ.def Makefile.def && \
#sed -i 's:HOME		= /home/jfhuang:HOME            = ${mainDir}:g' Makefile.def && \
#make && \
#cd .. && rm -r OpenSees MUMPS_5.2.1





















