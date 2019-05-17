FROM centos:7

RUN yum update -y && \
    yum install --setopt=tsflags=nodocs -y \
    buildah && \
    yum clean all && rm -rf /var/cache/yum/

CMD /usr/bin/buildah
