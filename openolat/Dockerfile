FROM ubuntu:23.04

ARG JDK_URL=https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.7%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.7_7.tar.gz
ARG TOMCAT_URL=https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.15/bin/apache-tomcat-10.1.15.tar.gz
ARG OPENOLAT_URL=https://www.openolat.com/fileadmin/downloads/releases/openolat_1727.war

RUN apt-get -y update && \
    apt-get -y install wget unzip busybox gettext

RUN useradd -m -s /bin/bash openolat

USER openolat
WORKDIR /home/openolat

RUN wget -qO- "${JDK_URL}" | tar xz && \
    ln -s `echo ./jdk*` ./jre

RUN wget -qO- "${TOMCAT_URL}"| tar xz && \
    ln -s `echo ./apache-tomcat*` ./tomcat 

RUN wget -q "${OPENOLAT_URL}" -O openolat.war && \
    unzip -qq -d ./openolat_war openolat.war && \
    rm openolat.war && \
    ln -s ./openolat_war ./webapp 

RUN mkdir bin conf lib run logs && \
    cd /home/openolat/conf && \
    ln -s ../tomcat/conf/web.xml web.xml && \
    cd /home/openolat/bin && \
    ln -s ../tomcat/bin/catalina.sh catalina.sh && \
    cd /home/openolat/ && \
    ln -s tomcat/bin/startup.sh start && \
    ln -s tomcat/bin/shutdown.sh stop 

COPY ./conf/server.xml /home/openolat/conf/server.xml

COPY ./bin/setenv.sh /home/openolat/bin/setenv.sh

COPY ./lib/olat.local.properties /home/openolat/lib/olat.local.properties.template
# This will be env-subst'ed in entrypotin.sh

COPY ./lib/log4j2.xml /home/openolat/lib/log4j2.xml

RUN mkdir -p /home/openolat/conf/Catalina/localhost/
COPY ./conf/Catalina/localhost/ROOT.xml /home/openolat/conf/Catalina/localhost/

# Custom Theme
COPY --chown=openolat ./themes /home/openolat/openolat_war/static/themes/

ENV CATALINA_BASE=/home/openolat
ENV CATALINA_HOME=/home/openolat/tomcat
ENV JRE_HOME=/home/openolat/jre

ENV LANG=C.UTF-8

RUN mkdir -p /home/openolat/olatdata && \
    mkdir -p /home/openolat/logs

COPY entrypoint.sh /home/openolat/entrypoint.sh

ENTRYPOINT [ "/home/openolat/entrypoint.sh" ]
CMD [ "/home/openolat/tomcat/bin/catalina.sh", "run" ]
