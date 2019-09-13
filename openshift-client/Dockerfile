FROM registry.access.redhat.com/ubi8/ubi:latest

RUN cd /tmp \
  && yum -y update \
  && yum install -y wget \
  && yum clean all \
  && wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz \
  && tar -xvzf oc.tar.gz \
  && mv oc /usr/local/bin/oc \
  && rm -rf oc.tar.gz

ENTRYPOINT ["/usr/local/bin/oc"]

CMD ["help"]
