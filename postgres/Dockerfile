FROM busybox as build
ARG OPENOLAT_URL=https://www.openolat.com/fileadmin/downloads/releases/openolat_1727.war
RUN wget -qO- "${OPENOLAT_URL}" | busybox unzip -d /openolat - && \
    unzip -qq `echo openolat/WEB-INF/lib/openolat-lms-*.jar` -d olatlms

# -----------------------

FROM postgres:12.15-alpine 
COPY --from=build /olatlms/database/postgresql/setupDatabase.sql /docker-entrypoint-initdb.d

