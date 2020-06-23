FROM ubuntu:20.04

ADD https://github.com/muquit/mailsend-go/releases/download/v1.0.9/mailsend-go_1.0.9_linux-64bit.deb /mailsend-go.deb
ADD https://bootstrap.pypa.io/get-pip.py /get-pip.py

RUN apt update && apt -y upgrade
RUN apt -y install python2 python3-pip coreutils build-essential libssl-dev kmod iptables && \
    python2 get-pip.py

RUN export PIPINSTALL="-m pip install" && \
    export PYTHONPACKAGES="numpy scipy matplotlib python-dateutil" && \
    python2 $PIPINSTALL --upgrade pip && python2 $PIPINSTALL $PYTHONPACKAGES && \
    python3 $PIPINSTALL --upgrade pip && python3 $PIPINSTALL $PYTHONPACKAGES && \
    unset PIPINSTALL && unset PYTHONPACKAGES

RUN dpkg -i mailsend-go.deb

RUN echo 'dummy\ndummy\n' | adduser --gecos "" dummy

# maybe match the host locale?
RUN apt -y install locales && locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8
ENV LC_ALL='en_US.UTF-8'
