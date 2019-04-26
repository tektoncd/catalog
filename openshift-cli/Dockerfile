FROM docker.io/centos:7

RUN cd /tmp \
  && yum -y update \
  && yum install -y wget \
  && wget https://mirror.openshift.com/pub/openshift-v3/clients/4.0.22/linux/oc.tar.gz \
  && tar -xvzf oc.tar.gz \
  && mv oc /usr/local/bin/ \
  && rm -rf oc.tar.gz

ENTRYPOINT ["oc"]

CMD ["help"]
