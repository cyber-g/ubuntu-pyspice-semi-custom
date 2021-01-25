FROM ubuntu:focal
ENV DEBIAN_FRONTEND=noninteractive
RUN (   apt-get update && apt-get upgrade -y -q \
        && apt-get -y -q autoclean \
        && apt-get -y -q autoremove)

# Install convenient tools for working on the host
RUN apt install -y bash-completion vim

# Install minimal dependencies
RUN apt install -y git wget unzip python3

# Install an additional package for enabling graphics output with python on
# docker
RUN apt-get install -y python3-tk

# Install python dependencies for PySpice
RUN apt-get install -y  python3-numpy python3-matplotlib \
                        python3-yaml python3-cffi

# Install libngspice dependencies
RUN apt-get install -y libc6 libedit2 libgomp1 libncurses6 libtinfo6

# Retrieve latest version of PySpice
WORKDIR /root
RUN git clone https://github.com/FabriceSalvaire/PySpice.git

# Set the PYTHONPATH to the path of the PySpice module
ENV PYTHONPATH=/root/PySpice
# Show that PySpice is properly found by python
RUN python3 -c "import PySpice; print(PySpice.__version__)"

# Retrieve the compiled shared library from ubuntu
ENV DEBVER=31.3-2
RUN wget http://fr.archive.ubuntu.com/ubuntu/pool/universe/n/ngspice/libngspice0_${DEBVER}_amd64.deb
RUN wget http://fr.archive.ubuntu.com/ubuntu/pool/universe/n/ngspice/libngspice0-dev_${DEBVER}_amd64.deb
# libngspice "Manual install"
RUN dpkg -x libngspice0_${DEBVER}_amd64.deb .
RUN dpkg -x libngspice0-dev_${DEBVER}_amd64.deb .
# Set the path of LD_LIBRARY_PATH to libngspice.so
ENV LD_LIBRARY_PATH=/root/usr/lib/x86_64-linux-gnu

# Run PySpice example
ENTRYPOINT python3 PySpice/examples/transistor/transistor.py
