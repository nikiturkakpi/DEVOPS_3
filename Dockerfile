FROM alpine AS build
RUN apk add --no-cache build-base make automake autoconf git pkgconfig glib-dev gtest-dev gtest cmake
WORKDIR /home/optima
RUN git clone --branch branchHTTPserver https://github.com/nikiturkakpi/DEVOPS_3.git
WORKDIR /home/optima/DEVOPS_3
RUN autoconf
RUN ./configure
RUN cmake
FROM alpine
COPY --from=build /home/optima/DEVOPS_3/myprogram /usr/local/bin/myprogram
ENTRYPOINT ["/usr/local/bin/myprogram"]


