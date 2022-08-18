## What is in this Wiki Page
- [About GitHub Workflow - Build & Deploy Non Prod](#about-github-workflow---build---deploy-non-prod)
- [GitHub Workflow Syntax](#github-workflow-syntax)
  * [On:](#on)
  * [Env:](#env)
  * [Jobs:](#jobs)
- [DockerFile - Application](#Dockerfile)
- [Jobs- Build Application](#jobs--build-application)
- [What is Self Hosted Runner?](#what-is-self-hosted-runner)
- [Jobs - Deploy to dev](#jobs---deploy-to-dev)
- [Where to find the Workflow Actions Tab](#where-to-find-the-workflow-actions-tab)

 

## About GitHub Workflow - Build & Deploy Non Prod
Build and deploy non prod workflow file is present in .github/workflow/ directory. GitHub Workflows allows us to have all the CI-CD steps in an well organized sequential manner which helps us in maintaining the versioning the workflow file as well.

 

[The Detailed workflow description is defined below](#github-workflow-syntax)

 

***
## GitHub Workflow Syntax

 

### On:
The workflow will trigger on Pull Request against all branches, but will be ignored if changes are made in the directory `terraform`, `k8s`, and `.github`

 

```yaml
on: 
  pull_request:
    paths-ignore:
    - "terraform/**"
    - "k8s/**"
    - ".github/**"
```

 

### Env:
A map of environment variables that are available to all jobs and steps in the workflow. You can also set environment variables that are only available to a job or step. Environment is set to use the default set variable values or the stored values in the environment variable which will be used in the different steps in the entire workflow where ever it is required.

 

### Jobs:
We are using two jobs, Build Application and Deploy to Non Prod in

 

***

 

### Dockerfile
Docker file is used to create an image for the application. A Docker image requires a base image.

 

* **FROM** syntax allows Docker to have a base image for the container.
  Docker base image is pulled from registry name _**docker-remote.registry.com**_ which includes image for _**maven:3.3.9-jdk-8**_
* **COPY** is used to copy any file from source to provided host destination within the Dockerfile system.
  In this Dockerfile, we are copying all files under src, pom.xml and settings.xml to the destination directory within the Docker filesystem.
* **RUN** is used to run the commands which will be executed during the docker build.
  RUN command is building the maven application using the pom.xml and setting.xml and skipping the tests using -DskipTests
* **USER** access is set to ROOT for the container.
* **ARG** is for setting the arguments for the Dockerfile 
* **ADD** is similar to COPY but ADD allows to download the file from the URL also and place it in the destination, whereas COPY allows only to copy file from source directory to destination directory.
* **EXPOSE** allows to set the exposed port for the container which will be used for interaction of outside services with the service running inside the container using the port defined.
* **ENTRYPOINT** is the default application set to run inside the container.
* **Keytool** keytool is a key and certificate management utility. keytool stores the keys and certificates in a so-called *keystore*. Here we are looping through the LDAP certificates in the path */usr/local/share/ca-certificates/* and importing them to *keystore* within the container.

 

***
### Jobs- Build Application

 

    jobs:
      build:
        name: 'Build Application'
        runs-on: self-hosted
  
    # Docker Build and push the image to ACR with unique tag
    - name: Build image and push to ACR with unique tag
      run: |
        BRANCH_NAME=${{ github.head_ref }}
        SHA=${{ github.event.pull_request.head.sha }}
        COMMIT_ID="$(echo $SHA | cut -c 1-8)"        
        UNIQUE_TAG=dev-$BRANCH_NAME-$COMMIT_ID
        IMAGE_NAME="${{ env.REGISTRY_NAME }}.azurecr.io/${{ env.APPLICATION_NAME }}"
        docker build -t $IMAGE_NAME:$UNIQUE_TAG -t $IMAGE_NAME:latest .
        docker push $IMAGE_NAME

 

>> Here we are building and tagging the Docker image using the `commit id`.
<br/>
>> Post that, the docker image is pushed to private Azure Container Registry.

 

***
<!---
### Jobs - Deploy to dev

 

Deploying to dev is a Github Actions Job that deploys the docker image onto the dev environment into AKS. Deploying to dev is dependent on the Build step to finish.

 

Set AKS context is for creating the namespace on the specified resource group and cluster name as in with: parameters declared under env syntax in workflow file. This step will use the **AZURE_DEPLOY_CREDENTIALS** stored in secrets of GitHub actions.

 

      - name: Setting AKS set context  
        uses: azure/aks-set-context@v1
        with:
            creds: ${{ secrets.AZURE_DEPLOY_CREDENTIALS }}
            resource-group: ${{ env.RESOURCE_GROUP }}
            cluster-name: ${{ env.CLUSTER_NAME }}
  
Below step will install the helm on the node agent of GitHub actions which will be used further for **helm upgrade**  
      # Setup Helm
      - name: Install Helm
        uses: azure/setup-helm@v1
        with:
          version: ${{ env.HELM_VERSION }}
--->

 

Below step is to update the helm dependencies if any update available for the application name.
      # Update chart dependencies
      - name: Helm dependency update
        run: helm dependency update ${{ github.workspace }}/charts/${{ env.APPLICATION_NAME }}

 

The below step is to deploy the helm chart on the cluster using the secrets and output of Get Secrets step which get stored in the variable 
**${{ steps.getSecrets.outputs.encryptionkey-test }}** and **${{ steps.getSecrets.outputs.auth-clientSecret-test }}**

 

      # Deploy the chart with secrets retrieved from Key Vault
      - name: Helm upgrade
        run: |
          helm upgrade --install \
            ${{ env.APPLICATION_NAME }} ${{ github.workspace}}/charts/${{ env.APPLICATION_NAME }} \
            --set secrets.ENCRYPTION_KEY=${{ steps.getSecrets.outputs.encryptionkey-test }} \
            --set secrets.AUTH_CLIENT_SECRET='${{ steps.getSecrets.outputs.auth-clientSecret-test }}' \
            --namespace ${{ env.NAMESPACE }}

 

***

 

### Where to find the Workflow Actions Tab
The GitHub workflow will be avilable on Actions tab > Workflows > All Workflows with name **Non-Prod Build and Deploy**

 

On opening the Workflows from the Actions Tab, you will see the workflow's detailed list of jobs which we have specify in the workflow yaml file and the each steps are shown in the right side of the image in the black terminal view.