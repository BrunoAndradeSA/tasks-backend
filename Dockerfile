FROM tomcat:jdk16-openjdk

ARG WAR_FILE 
ARG CONTEXT

COPY ${WAR_FILE} /usr/local/tomcat/webapps/${CONTEXT}.war