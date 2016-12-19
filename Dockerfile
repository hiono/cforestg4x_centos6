FROM centos:centos6

MAINTAINER SoftwareCollections.org <sclorg@redhat.com>

RUN echo "minrate=1" >> /etc/yum.conf && echo "timeout=500" >> /etc/yum.conf
RUN yum -y install centos-release-scl
RUN yum -y install yum-utils
RUN yum -y install scl-utils
RUN yum-config-manager --enable rhel-server-rhscl-6-rpms

RUN yum install -y --setopt=tsflags=nodocs https://www.softwarecollections.org/repos/rhscl/devtoolset-3/epel-6-x86_64/noarch/rhscl-devtoolset-3-epel-6-x86_64-1-2.noarch.rpm
RUN yum update  -y
RUN yum install -y --skip-broken --setopt=tsflags=nodocs devtoolset-3
RUN yum install -y --skip-broken --setopt=tsflags=nodocs devtoolset-3-binutils
RUN yum install -y --skip-broken --setopt=tsflags=nodocs devtoolset-3-gcc
RUN yum install -y --skip-broken --setopt=tsflags=nodocs devtoolset-3-gcc-c++
RUN yum install -y --skip-broken --setopt=tsflags=nodocs devtoolset-3-git
RUN yum install -y --skip-broken --setopt=tsflags=nodocs python27
RUN yum install -y --skip-broken --setopt=tsflags=nodocs python27-python-devel
RUN yum install -y --skip-broken --setopt=tsflags=nodocs python27-python-pip
RUN yum install -y --skip-broken --setopt=tsflags=nodocs cmake-gui cmake
RUN yum install -y --skip-broken --setopt=tsflags=nodocs ccache
RUN yum groupinstall 'Development tools' -y

RUN yum clean all

RUN (source scl_source enable devtoolset-3 python27 && cd /tmp && curl -fsSkL -o gitflow-installer.sh "https://raw.github.com/petervanderdoes/gitflow/develop/contrib/gitflow-installer.sh" && bash gitflow-installer.sh install develop && rm -rf gitflow gitflow-installer.sh && curl -fsSkL -o /etc/bash_completion.d/git-flow-completion.bash "https://raw.githubusercontent.com/bobthecow/git-flow-completion/master/git-flow-completion.bash")
RUN (source scl_source enable devtoolset-3 python27 && cd /tmp && git clone "https://github.com/tj/git-extras.git" && cd git-extras && git checkout $(git describe --tags $(git rev-list --tags --max-count=1)) && make install && rm -rf /tmp/git-extras)

RUN (source scl_source enable devtoolset-3 python27 && cd /tmp && git clone "https://github.com/danmar/cppcheck.git" && cd cppcheck && env PREFIX=/usr/local CFGDIR=/usr/local/share/cppcheck make all install && rm -rf cppcheck)

RUN source scl_source enable python27 && pip install --upgrade pip
RUN source scl_source enable python27 && pip install -U cmakelint hacking pyelftools

ENV BASH_ENV=/etc/profile.d/cont-env.sh

ADD ./enabledevtoolset-3.sh /usr/share/cont-layer/common/env/enabledevtoolset-3.sh
ADD ./usr /usr
ADD ./etc /etc
ADD ./root /root

ENV HOME=/home/default
RUN mkdir -p /etc/sudoers.d
RUN chown -R 1000:1000 /home/defaulut
RUN groupadd -r default -f -g 1000
RUN useradd -u 1000 -r -g default -d ${HOME} -s /sbin/nologin -c "Default Application User" default
RUN echo defaulut:defaulut | chpasswd
RUN echo 'defaulut ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/defaulut && chmod 0440 /etc/sudoers.d/defaulut
USER 1000
WORKDIR /home/default

ENTRYPOINT ["/usr/bin/container-entrypoint"]

CMD ["container-usage"]
