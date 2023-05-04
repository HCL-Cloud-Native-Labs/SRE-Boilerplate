# Get Started: Install Jenkins on an Azure Linux VM

This article shows how to install [Jenkins](https://jenkins.io) on an Ubuntu Linux VM with the tools and plug-ins configured to work with Azure.

In this article, you'll learn how to:

> * Create a setup file that downloads and installs Jenkins
> * Create a resource group
> * Create a virtual machine with the setup file
> * Open port 8080 in order to access Jenkins on the virtual machine
> * Connect to the virtual machine via SSH
> * Configure a sample Jenkins job based on a sample Java app in GitHub
> * Build the sample Jenkins job

## 1. Create a virtual machine

1. Create a test directory called `jenkins-get-started`.

1. Switch to the test directory.

1. Create a file named `cloud-init-jenkins.txt`.

1. Paste the following code into the new file:

    ```
    #cloud-config
    package_upgrade: true
    runcmd:
      - sudo apt install openjdk-11-jre -y
      - wget -qO - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
      - sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
      - sudo apt-get update && sudo apt-get install jenkins -y
      - sudo service jenkins restart
    ```
    
1. Run [az group create](/cli/azure/group#az-group-create) to create a resource group.

    ```azurecli
    az group create --name jenkins-get-started-rg --location eastus
    ```

1. Run [az vm create](/cli/azure/vm#az-vm-create) to create a virtual machine.

    ```azurecli
    az vm create \
    --resource-group jenkins-get-started-rg \
    --name jenkins-get-started-vm \
    --image UbuntuLTS \
    --admin-username "azureuser" \
    --generate-ssh-keys \
    --public-ip-sku Standard \
    --custom-data cloud-init-jenkins.txt
    ```

1. Run [az vm list](/cli/azure/vm#az-vm-list) to verify the creation (and state) of the new virtual machine.

    ```azurecli
    az vm list -d -o table --query "[?name=='jenkins-get-started-vm']"
    ```

1. As Jenkins runs on port 8080, run [az vm open](/cli/azure/vm#az-vm-open-port) to open port 8080 on the new virtual machine.

    ```azurecli
    az vm open-port \
    --resource-group jenkins-get-started-rg \
    --name jenkins-get-started-vm  \
    --port 8080 --priority 1010
    ```

## 2. Configure Jenkins

1. Run [az vm show](/cli/azure/vm#az-vm-show) to get the public IP address for the sample virtual machine.

    ```azurecli
    az vm show \
    --resource-group jenkins-get-started-rg \
    --name jenkins-get-started-vm -d \
    --query [publicIps] \
    --output tsv
    ```

    **Key points**:

    - The `--query` parameter limits the output to the public IP addresses for the virtual machine.

1. Using the IP address retrieved in the previous step, SSH into the virtual machine. You'll need to confirm the connection request.

    ```azurecli
    ssh azureuser@<ip_address>
    ```

    **Key points**:

    - Upon successful connection, the Cloud Shell prompt includes the user name and virtual machine name: `azureuser@jenkins-get-started-vm`.

1. Verify that Jenkins is running by getting the status of the Jenkins service.

    ```bash
    service jenkins status
    ```

    **Key points**:

    - If you receive an error regarding the service not existing, you may have to wait a couple of minutes for everything to install and initialize.

1. Get the autogenerated Jenkins password.

    ```bash
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

1. Using the IP address, open the following URL in a browser: `http://<ip_address>:8080`

1. Enter the password you retrieved earlier and select **Continue**.

    ![Initial page to unlock Jenkins](./media/unlock-jenkins.png)

1. Select **Select plug-in to install**.

    ![Select the option to install selected plug-ins](./media/select-plugins.png)

1. In the filter box at the top of the page, enter `github`. Select the GitHub plug-in and select **Install**.

    ![Install the GitHub plug-ins](./media/install-github-plugin.png)

1. Enter the information for the first admin user and select **Save and Continue**.

    ![Enter information for first admin user](./media/create-first-user.png)

1. On the **Instance Configuration** page, select **Save and Finish**.

    ![Confirmation page for instance configuration](./media/instance-configuration.png)

1. Select **Start using Jenkins**.

    ![Jenkins is ready!](./media/start-using-jenkins.png)

## 3. Create your first job

1. On the Jenkins home page, select **Create a job**.

    ![Jenkins console home page](./media/jenkins-home-page.png)

1. Enter a job name of `mySampleApp`, select **Freestyle project**, and select **OK**.

    ![New job creation](./media/new-job.png)

1. Select the **Source Code Management** tab. Enable **Git** and enter the following URL for the **Repository URL** value: `https://github.com/spring-guides/gs-spring-boot.git`. Then change the **Branch Specifier** to `*/main`.

    ![Define the Git repo](./media/source-code-management.png)

1. Select the **Build** tab, then select **Add build step**

    ![Add a new build step](./media/add-build-step.png)

1. From the drop-down menu, select **Invoke Gradle script**.

    ![Select the Gradle script option](./media/invoke-gradle-script-option.png)

1. Select **Use Gradle Wrapper**, then enter `complete` in **Wrapper location** and `build` for **Tasks**.

    ![Gradle script options](./media/gradle-script-options.png)

1. Select **Advanced** and enter `complete` in the **Root Build script** field.

    ![Advanced Gradle script options](./media/root-build-script.png)

1. Scroll to the bottom of the page, and select **Save**.

## 4. Build the sample Java app

1. When the home page for your project displays, select **Build Now** to compile the code and package the sample app.

    ![Project home page](./media/project-home-page.png)

1. A graphic below the **Build History** heading indicates that the job is being built.

    ![Job-build in progress](./media/job-currently-building.png)

1. When the build completes, select the **Workspace** link.

    ![Select the workspace link.](./media/job-workspace.png)

1. Navigate to `complete/build/libs` to see that the `.jar` file was successfully built.

    ![The target library verifies the build succeeded.](./media/successful-build.png)

1. Your Jenkins server is now ready to build your own projects in Azure!

## Troubleshooting

If you encounter any problems configuring Jenkins, refer to the [Jenkins installation page](https://www.jenkins.io/doc/book/installing/) for the latest instructions and known issues.
