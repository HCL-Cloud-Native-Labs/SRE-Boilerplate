FROM jenkins/jenkins:latest

USER root
# skip the setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV JENKINS_HOME "/var/jenkins_home"

RUN ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''

RUN apt-get update
RUN apt-get install -y ansible

# install plugins
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

#configure jenkins user
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

