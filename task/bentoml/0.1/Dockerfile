FROM ubuntu:19.10

ENV PATH /usr/bin:$PATH

RUN apt-get update
RUN apt-get update && apt-get install --no-install-recommends --yes python3 python3-pip python3-dev python-dev gcc g++ build-essential

RUN pip3 install numpy Cython setuptools

RUN pip3 --no-cache-dir install bentoml
