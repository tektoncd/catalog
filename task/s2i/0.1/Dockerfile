FROM centos:7

# Install security updates
RUN yum -y update && yum clean all &&  rm -rf /var/cache/yum

# Get latest S2I release  from github with some curl+rest+python magic (which is provided by default
# in the image so wedon't have to install extra packages)
RUN mkdir -p /usr/local/bin && \
    curl -L $(curl -L -s "https://api.github.com/repos/openshift/source-to-image/releases/latest"| python -c "import sys, json;x=json.load(sys.stdin);print([ r['browser_download_url'] for r in x['assets'] if 'linux-amd64' in r['name']][0])") -o /tmp/s2i.tgz && \
    tar xz -f/tmp/s2i.tgz -C /usr/local/bin/ && \
	chmod -R 0755 /usr/local/bin

ENTRYPOINT ["/usr/local/bin/s2i"]
