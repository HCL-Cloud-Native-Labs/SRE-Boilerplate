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
 
