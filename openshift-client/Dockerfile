FROM quay.io/openshift/origin-cli:latest

RUN mv /usr/bin/oc /usr/local/bin/oc-origin

ADD script.sh /usr/local/bin/oc

RUN chmod +x /usr/local/bin/oc

ENTRYPOINT ["/usr/local/bin/oc"]

CMD ["help"]
