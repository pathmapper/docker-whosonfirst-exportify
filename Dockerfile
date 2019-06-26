FROM alpine:latest

# https://proj4.org/download.html
# https://download.osgeo.org/geos
# https://download.osgeo.org/gdal/

ARG LIBGEOS_VERSION=3.7.2
ARG LIBGDAL_VERSION=3.0.0
ARG LIBPROJ_VERSION=6.1.0

ARG PYMZWOF_UTILS_VERSION=0.4.5
ARG PYMZWOF_EXPORT_VERSION=0.9.6

RUN apk update && apk upgrade \
    && apk add coreutils git make ca-certificates py-pip libc-dev gcc g++ python-dev \
    #
    # https://github.com/appropriate/docker-postgis/blob/master/Dockerfile.alpine.template
    #
    # && apk add --no-cache --virtual .build-deps-edge \
    #    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    #    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    #    gdal-dev geos-dev proj4-dev \
    #
    # or the hard way which takes _forever_ to build and doesn't always work...
    # but we're going to do things the hard way because the above no longer works
    # and doesn't return any useful error messages... (20190612/thisisaaronland)
    #
    && apk add libc-dev gcc g++ linux-headers python-dev sqlite sqlite-dev \       
    && mkdir /build \
    #
    && cd /build \
    && wget https://download.osgeo.org/proj/proj-${LIBPROJ_VERSION}.tar.gz && tar -xvzf proj-${LIBPROJ_VERSION}.tar.gz \
    && cd proj-${LIBPROJ_VERSION} && ./configure && make && make install \
    #
    && cd /build \
    && wget https://download.osgeo.org/geos/geos-${LIBGEOS_VERSION}.tar.bz2 && tar -xvjf geos-${LIBGEOS_VERSION}.tar.bz2 \
    && cd geos-${LIBGEOS_VERSION} && ./configure && make && make install \
    #
    && cd /build \
    && wget https://download.osgeo.org/gdal/${LIBGDAL_VERSION}/gdal-${LIBGDAL_VERSION}.tar.gz && tar -xvzf gdal-${LIBGDAL_VERSION}.tar.gz \
    && cd gdal-${LIBGDAL_VERSION} && ./configure && make && make install \
    #       
    && pip install gdal \
    #
    # Something to note here is that the URLs for py-mapzen-whosonfirst-utils and py-mapzen-whosonfirst-export
    # are subtlely different. Specifically the latter uses the `vX.Y.Z` convention for releases and the former
    # does not. The next release of py-mapzen-whosonfirst-utils (0.4.6) should use the updated convention so
    # we'll need to update this when it does. Could I just make a new release and be done with it? Yes, I could
    # but today I did not... (20190626/thisisaaronland)
    #
    && cd /build \
    && wget -O utils.tar.gz https://github.com/whosonfirst/py-mapzen-whosonfirst-utils/archive/${PYMZWOF_UTILS_VERSION}.tar.gz && tar -xvzf utils.tar.gz \
    && cd py-mapzen-whosonfirst-utils-${PYMZWOF_UTILS_VERSION} \
    && pip install -r requirements.txt . \
    #
    && cd /build \    
    && wget -O export.tar.gz https://github.com/whosonfirst/py-mapzen-whosonfirst-export/archive/v${PYMZWOF_EXPORT_VERSION}.tar.gz && tar -xvzf export.tar.gz \
    && cd py-mapzen-whosonfirst-export-${PYMZWOF_EXPORT_VERSION} \
    && pip install -r requirements.txt . \
    #
    && cd / && rm -rf /build