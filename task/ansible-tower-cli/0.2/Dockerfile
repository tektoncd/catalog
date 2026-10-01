FROM registry.access.redhat.com/ubi7/ubi  

RUN curl -O https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install ./epel-release-latest-*.noarch.rpm -y && \
    yum update -y && \
    yum install python-pip -y && \
    pip install --upgrade pip && \
    pip install ansible-tower-cli --no-cache-dir && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf ~/.cache/pip

USER 1001

ENTRYPOINT ["/usr/bin/tower-cli/"]

