FROM openjdk:8-jdk-alpine

RUN set -x & \
  apk update && \
  apk upgrade && \
  apk add --no-cache curl && \
  apk --no-cache add openssl

ADD pull-from-artifactory.sh pull-from-artifactory.sh
RUN ["chmod", "+x", "pull-from-artifactory.sh"]

ADD entrypoint.sh entrypoint.sh
RUN ["chmod", "+x", "entrypoint.sh"]

#Default ENV Values
ENV requireSsl=true
ENV serverPort=443
ENV serverContextPath=/
ENV springFrameworkLogLevel=info
ENV keystoreLocation=/localkeystore.p12
ENV keystorePassword=changeme
ENV keystoreSSLKey=tomcat
ENV ribbonMaxAutoRetries=3
ENV ribbonConnectTimeout=1000
ENV ribbonReadTimeout=10000
ENV hystrixThreadTimeout=10000000
ENV SPRING_CLOUD_CONFIG_ENABLED=false
ENV TOMCAT_CERT_PATH=/tomcat-wildcard-ssl.crt
ENV TOMCAT_KEY_PATH=/tomcat-wildcard-ssl.key
ENV HEALTHY_STATUS='{"status":"UP"}'
ENV HEALTH_CHECK_URL="https://127.0.0.1:${serverPort}${serverContextPath}/health"

ENTRYPOINT [ "/entrypoint.sh"]

HEALTHCHECK CMD curl -k ${HEALTH_CHECK_URL} | grep -q ${HEALTHY_STATUS} || exit 1