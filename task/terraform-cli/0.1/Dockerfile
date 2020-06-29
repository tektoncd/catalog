FROM registry.access.redhat.com/ubi8/ubi

RUN yum update -y && \
    yum install zip -y && \
    curl -O https://releases.hashicorp.com/terraform/0.12.13/terraform_0.12.13_linux_amd64.zip && \
    unzip terraform_0.12.13_linux_amd64.zip -d /usr/local/bin && \
    yum clean all && \
    rm -rf /var/cache/yum


USER 1001

ENTRYPOINT ["/usr/local/bin/terraform"]





