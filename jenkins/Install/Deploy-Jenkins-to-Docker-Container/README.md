## Jenkins Setup with Docker and Jenkins Configuration as Code 

### Introduction:
Jenkins is one of the most popular open-source automation servers, often used to orchestrate continuous integration (CI) and/or continuous deployment (CD) workflows. Configuring Jenkins is typically done manually through a web-based setup wizard; this can be a slow, error-prone, and non-scalable process. configurations cannot be tracked in a version control system (VCS) like Git, nor be under the scrutiny of any code review process.

In this tutorial, you will automate the installation and configuration of Jenkins using Docker and the Jenkins Configuration as Code (JCasC) method.

### Prerequisites
To complete this tutorial, you will need:

Access to a server with at least 2GB of RAM and Docker installed. This can be your local development machine, a Droplet, or any kind of server. Follow Step 1 — Installing Docker from one of the tutorials in the How to Install and Use Docker collection to set up Docker.

    Note: This tutorial is tested on Ubuntu 18.04; however, because Docker images are self-contained, the steps outlined here would work for any OSes with
    Docker installed.
    
### Step 1 — Disabling the Setup Wizard
Using JCasC eliminates the need to show the setup wizard; therefore, in this first step, you’ll create a modified version of the official [jenkins/jenkins](https://hub.docker.com/r/jenkins/jenkins/) image that has the setup wizard disabled. You will do this by creating a Dockerfile and building a custom Jenkins image from it.

The jenkins/jenkins image allows you to enable or disable the setup wizard by passing in a system property named jenkins.install.runSetupWizard via the JAVA_OPTS environment variable. Users of the image can pass in the JAVA_OPTS environment variable at runtime using the --env flag to docker run. However, this approach would put the onus of disabling the setup wizard on the user of the image. Instead, you should disable the setup wizard at build time, so that the setup wizard is disabled by default.

You can achieve this by creating a Dockerfile and using the ENV instruction to set the JAVA_OPTS environment variable.

First, create a new directory inside your server to store the files you will be creating in this tutorial:

      mkdir -p $HOME/jenkins
 
Then, navigate inside that directory:

      cd $HOME/jenkins
 
Next, using your editor, create a new file named Dockerfile:

      vi $HOME/jenkins/Dockerfile
 
Then, copy the following content into the Dockerfile:
 
      FROM jenkins/jenkins:latest
      ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
 
Here, you’re using the FROM instruction to specify jenkins/jenkins:latest as the base image, and the ENV instruction to set the JAVA_OPTS environment variable.

Save the file and exit the editor by pressing CTRL+X followed by Y.

With these modifications in place, build a new custom Docker image and assign it a unique tag (we’ll use jcasc here):

      docker build -t jenkins:jcasc .
 
You will see output similar to the following:

      Output
      Sending build context to Docker daemon  2.048kB
      Step 1/2 : FROM jenkins/jenkins:latest
       ---> 1f4b0aaa986e
      Step 2/2 : ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
       ---> 7566b15547af
      Successfully built 7566b15547af
      Successfully tagged jenkins:jcasc
      
Once built, run your custom image by running docker run:

      docker run --name jenkins --rm -p 8080:8080 jenkins:jcasc

Jenkins will take a short period of time to initiate. When Jenkins is ready, you will see the following line in the output:

      Output
      ... hudson.WebAppMain$3#run: Jenkins is fully up and running
Now, open up your browser to **server_ip:8080**. You’re immediately shown the dashboard without the setup wizard.

### Step 2 — Installing Jenkins Plugins
To use JCasC, you need to install the Configuration as Code plugin. In this step, you’re going to modify your Dockerfile to pre-install a selection of plugins, including the Configuration as Code plugin.

To automate the plugin installation process, you can make use of an installation script that comes with the jenkins/jenkins Docker image. You can find it inside the container at /usr/local/bin/install-plugins.sh. To use it, you would need to:

- Create a text file containing a list of plugins to install
- Copy it into the Docker image
- Run the install-plugins.sh script to install the plugins

First, using your editor, create a new file named plugins.txt:
       
       vi $HOME/jenkins/plugins.txt

Then, add in the following newline-separated list of plugin names and versions (using the format id:version)
    
        ace-editor:latest
        ant:latest
        antisamy-markup-formatter:latest
        apache-httpcomponents-client-4-api:latest
        bouncycastle-api:latest
        branch-api:latest
        authorize-project:latest
        build-timeout:latest
        cloudbees-folder:latest
        configuration-as-code:latest
        credentials:latest
        credentials-binding:latest
        display-url-api:latest
        durable-task:latest
        echarts-api:latest
        email-ext:latest
        git:latest
        git-client:latest
        git-server:latest
        github:latest
        github-api:latest
        github-branch-source:latest
        gradle:latest
        handlebars:latest
        jackson2-api:latest
        jdk-tool:latest
        jquery-detached:latest
        jquery3-api:latest
        jsch:latest
        junit:latest
        ldap:latest
        lockable-resources:latest
        mailer:latest
        mapdb-api:latest
        matrix-auth:latest
        matrix-project:latest
        momentjs:latest
        okhttp-api:latest
        pam-auth:latest
        pipeline-build-step:latest
        pipeline-graph-analysis:latest
        pipeline-input-step:latest
        pipeline-milestone-step:latest
        pipeline-model-api:latest
        pipeline-model-definition:latest
        pipeline-model-extensions:latest
        pipeline-rest-api:latest
        pipeline-stage-step:latest
        pipeline-stage-tags-metadata:latest
        pipeline-github-lib:latest
        pipeline-stage-view:latest
        plain-credentials:latest
        plugin-util-api:latest
        resource-disposer:latest
        scm-api:latest
        script-security:latest
        snakeyaml-api:latest
        ssh-credentials:latest
        ssh-slaves:latest
        structs:latest
        subversion:latest
        timestamper:latest
        token-macro:latest
        trilead-api:latest
        workflow-aggregator:latest
        workflow-api:latest
        workflow-basic-steps:latest
        workflow-cps:latest
        workflow-cps-global-lib:latest
        workflow-durable-task-step:latest
        workflow-job:latest
        workflow-multibranch:latest
        workflow-scm-step:latest
        workflow-step-api:latest
        workflow-support:latest
        ws-cleanup:latest

Save the file and exit your editor.

Next, open up the Dockerfile file:
    
    vi $HOME/jenkins/Dockerfile
    
In it, add a COPY instruction to copy the plugins.txt file into the /usr/share/jenkins/ref/ directory inside the image; this is where Jenkins normally looks for plugins. Then, include an additional RUN instruction to run the install-plugins.sh script:

    FROM jenkins/jenkins:latest

    USER root
    # skip the setup wizard
    ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
    ENV JENKINS_HOME "/var/jenkins_home"

    RUN ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''

    # install plugins
    COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
    RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
    
Save the file and exit the editor. Then, build a new image using the revised Dockerfile:
    
    docker build -t jenkins:jcasc .

This step involves downloading and installing many plugins into the image, and may take some time to run depending on your internet connection. Once the plugins have finished installing, run the new Jenkins image:

    docker run --name jenkins --rm -p 8080:8080 jenkins:jcasc

### Step 4 — Creating a User
So far, your setup has not implemented any authentication and authorization mechanisms. In this step, you will set up a basic, password-based authentication scheme and create a new user named admin.

Start by opening your default-user.groovy file:

    vi $HOME/jenkins/default-user.groovy

Then, add in the highlighted snippet:
    
    import jenkins.model.*
    import hudson.security.*

    def env = System.getenv()

    def jenkins = Jenkins.getInstance()
    if(!(jenkins.getSecurityRealm() instanceof HudsonPrivateSecurityRealm))
        jenkins.setSecurityRealm(new HudsonPrivateSecurityRealm(false))

    if(!(jenkins.getAuthorizationStrategy() instanceof GlobalMatrixAuthorizationStrategy))
        jenkins.setAuthorizationStrategy(new GlobalMatrixAuthorizationStrategy())

    // create new Jenkins user account
    // username & password from environment variables
    def user = jenkins.getSecurityRealm().createAccount(env.JENKINS_USER, env.JENKINS_PASS)
    user.save()
    jenkins.getAuthorizationStrategy().add(Jenkins.ADMINISTER, env.JENKINS_USER)

    jenkins.save()
    
In the context of Jenkins, a security realm is simply an authentication mechanism; the local security realm means to use basic authentication where users must specify their ID/username and password. Other security realms exist and are provided by plugins. For instance, the LDAP plugin allows you to use an existing LDAP directory service as the authentication mechanism. The GitHub Authentication plugin allows you to use your GitHub credentials to authenticate via OAuth.


Also adding default-user.groovy file by opening Dockerfile file:

    vi $HOME/jenkins/Dockerfile
    
Then, add in the highlighted snippet:

    #configure user, urls
    COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

Note that you’ve also specified allowsSignup: false, which prevents anonymous users from creating an account through the web interface.

Finally, instead of hard-coding the user ID and password, you are using variables whose values can be filled in at runtime. This is important because one of the benefits of using JCasC is that the default-user.groovy file can be committed into source control; if you were to store user passwords in plaintext inside the configuration file, you would have effectively compromised the credentials. Instead, variables are defined using the ${VARIABLE_NAME} syntax, and its value can be filled in using an environment variable of the same name, or a file of the same name that’s placed inside the /run/secrets/ directory within the container image.

Next, build a new image to incorporate the changes made to the default-user.groovy file:

    docker build -t jenkins:jcasc .

Then, run the updated Jenkins image whilst passing in the JENKINS_USER and JENKINS_PASS environment variables via the --env option (replace \<password\> with a password of your choice):

    docker run --name jenkins --rm -p 8080:8080  --env JENKINS_USER=admin --env JENKINS_PASS=admin jenkins:jcasc
    
Run updated Jenkins image as docker in detach mode (by adding -detach or -d in short)
    
    docker run -d --name jenkins --rm -p 8080:8080  --env JENKINS_USER=admin --env JENKINS_PASS=admin jenkins:jcasc
    
Run the container by attaching the volume and assigning the targeted port.

First create persistant volume
        
    docker volume create jenkins-pv
        
    docker run -d --name jenkins --rm -p 8080:8080 -v jenkins-pv:/var/jenkins_home --env JENKINS_USER=admin --env JENKINS_PASS=admin jenkins:jcasc

The source code is available in [github repository](https://github.com/HCL-Cloud-Native-Labs/SRE-Boilerplate/tree/main/jenkins/Install/Deploy-Jenkins-to-Docker-Container)
