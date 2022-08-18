### Table of Contents
- [Secrets](#Secrets)
- [Encryption](#Encryption)
- [Azure Key Vault secrets](#Azure-Key-Vault-secrets)
- [Kubernetes Secrets](#Kubernetes-Secrets)
- [GitHub Secrets](#GitHub-Secrets)


### Secrets
Key Vault provides secure storage of secrets, such as passwords and database connection strings.


From a developer's perspective, Key Vault APIs accept and return secret values as strings. Internally, Key Vault stores and manages secrets as sequences of octets (8-bit bytes), with a maximum size of 25k bytes each. The Key Vault service doesn't provide semantics for secrets. It merely accepts the data, encrypts it, stores it, and returns a secret identifier ("id"). The identifier can be used to retrieve the secret at a later time.


For highly sensitive data, clients should consider additional layers of protection for data. Encrypting data using a separate protection key prior to storage in Key Vault is one example.


Key Vault also supports a contentType field for secrets. Clients may specify the content type of a secret to assist in interpreting the secret data when it's retrieved. The maximum length of this field is 255 characters. There are no pre-defined values. The suggested usage is as a hint for interpreting the secret data. For instance, an implementation may store both passwords and certificates as secrets, then use this field to differentiate. There are no predefined values.


### Encryption
All secrets in your Key Vault are stored encrypted. This encryption is transparent, and requires no action from the user. The Azure Key Vault service encrypts your secrets when you add them, and decrypts them automatically when you read them. The encryption key is unique to each key vault.


### Azure Key Vault secrets
Azure Key Vault enables Microsoft Azure applications and users to store and use several types of secret/key data. Key Vault resource provider supports two resource types: vaults and managed HSMs.


Download secret from a KeyVault.


    # Download TLS Certificate and Key from Keyvault
    - name: Download TLS Certificate and key
      run: |
        az keyvault secret download --name ${​​​​​​​{​​​​​​​ env.ACR_CERTIFICATE_NAME }​​​​​​​}​​​​​​​ --vault-name ${​​​​​​​{​​​​​​​ env.KEYVAULT_NAME }​​​​​​​}​​​​​​​ -f certificate.crt
        az keyvault secret download --name ${​​​​​​​{​​​​​​​ env.ACR_PRIVATEKEY_NAME }​​​​​​​}​​​​​​​ --vault-name ${​​​​​​​{​​​​​​​ env.KEYVAULT_NAME }​​​​​​​}​​​​​​​ -f privatekey.key
        
Here downloading two secret files from the Azure Key Vault, `certificate.crt` and `prikvatekey.key`. The above code snippet used in setup-kubenetes-cluster workflow.


> Note: Action to download secrets is permitted because the service principal which we are using to login to Azure has the permissions to do so.


Retreive secret from a KeyVault


    # Retrieves secrets from Key Vault
    - name: Get Kubernetes Secrets
      uses: Azure/get-keyvault-secrets@v1.1
      with:
        keyvault: ${​​​​​​​{​​​​​​​ env.KEYVAULT_NAME }​​​​​​​}​​​​​​​
        secrets: 'encryptionkey-dev'
      id: getSecrets
      
Here retreiving the secret from the Azure Key Vault. The above code snippet used in build-deploy workflow.


Using retreived secret in an action


    # Deploy the chart with secrets retrieved from Key Vault
    - name: Helm upgrade
      run: |
        helm upgrade --install \
          ${​​​​​​​{​​​​​​​ env.APPLICATION_NAME }​​​​​​​}​​​​​​​ ${​​​​​​​{​​​​​​​ github.workspace}​​​​​​​}​​​​​​​/charts/${​​​​​​​{​​​​​​​ env.APPLICATION_NAME }​​​​​​​}​​​​​​​ \
          --values ${​​​​​​​{​​​​​​​ github.workspace }​​​​​​​}​​​​​​​/environments/dev/values.yaml \
          --set image.tag=${​​​​​​​{​​​​​​​ github.event.pull_request.head.sha }​​​​​​​}​​​​​​​ \
          --set secrets.ENCRYPTION_KEY=${​​​​​​​{​​​​​​​ steps.getSecrets.outputs.encryptionkey-dev }​​​​​​​}​​​​​​​ \
          --namespace ${​​​​​​​{​​​​​​​ env.NAMESPACE }​​​​​​​}​​​​​​​


Here using the retreived secret in actions job. The above code snippet used in build-deploy workflow.


### Kubernetes Secrets
Kubernetes Secrets let you store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. Storing confidential information in a Secret is safer and more flexible than putting it verbatim in a Pod definition or in a container image. 


A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in an image. Users can create Secrets and the system also creates some Secrets.


    # Create TLS secret for Ingress
    - name: Create TLS Secret
      run: |
        kubectl delete secret ${​​​​​​​{​​​​​​​ env.TLS_SECRET_NAME }​​​​​​​}​​​​​​​ --ignore-not-found -n ${​​​​​​​{​​​​​​​ env.INGRESS_NAMESPACE }​​​​​​​}​​​​​​​
        kubectl create secret tls ${​​​​​​​{​​​​​​​ env.TLS_SECRET_NAME }​​​​​​​}​​​​​​​ --cert=certificate.crt --key=privatekey.key -n ${​​​​​​​{​​​​​​​ env.INGRESS_NAMESPACE }​​​​​​​}​​​​​​​
       
 Here creating the secret in Kubernetes using kubectl. The above code snippet used in setup-kubenetes-cluster workflow.
 
 ### GitHub Secrets
Secrets are encrypted environment variables that you create in a repository or organization. The secrets you create are available to use in GitHub Actions workflows.


For secrets stored at the organization-level, you can use access policies to control which repositories can use organization secrets. Organization-level secrets let you share secrets between multiple repositories, which reduces the need for creating duplicate secrets. Updating an organization secret in one location also ensures that the change takes effect in all repository workflows that use that secret.


   # Create ImagePullSecret for Dev environment
    - name: Create ImagePullSecret for dev
      uses: azure/k8s-create-secret@v1
      with:
        namespace: ${​​​​​​​{​​​​​​​ env.DEV_NAMESPACE }​​​​​​​}​​​​​​​
        container-registry-url: ${​​​​​​​{​​​​​​​ env.REGISTRY_NAME }​​​​​​​}​​​​​​​.azurecr.io
        container-registry-username: ${​​​​​​​{​​​​​​​ env.REGISTRY_USERNAME }​​​​​​​}​​​​​​​
        container-registry-password: ${​​​​​​​{​​​​​​​ secrets.SERVICE_PRINCIPAL_CLIENT_SECRET }​​​​​​​}​​​​​​​ # ${​​​​​​​{​​​​​​​ secrets.REGISTRY_PASSWORD }​​​​​​​}​​​​​​​
        secret-name: ${​​​​​​​{​​​​​​​ env.IMAGEPULL_SECET_NAME }​​​​​​​}​​​​​​​
        
 Here using the Service Principal Client Secret Password from secrets. The secrets you create are available to use in GitHub Actions workflows.


 > Kubernetes cluster uses the `ImagePullSecret` of `docker-registry` type to authenticate with Azure container registry to `pull` a private image.






















