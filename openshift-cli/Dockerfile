FROM docker.io/centos:7

RUN cd /tmp \
  && yum -y update \
  && yum install -y wget \
  && wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz \
  && tar -xvzf oc.tar.gz \
  && mv oc /usr/local/bin/ \
  && rm -rf oc.tar.gz

ENTRYPOINT ["oc"]

CMD ["help"]
