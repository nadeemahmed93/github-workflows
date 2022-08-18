<span style="color:black;">In this article</span>
- [What is GitHub actions workflow](#what-is-github-actions-workflow)
- [What are Jobs?](#what-are-jobs)
  * [name:](#name)
  * [on](#on)
  * [env](#env)
  * [jobs](#jobs)
  * [What is jobs.<job_id>.steps?](#what-is-jobs-job-id-steps)
- [Deployments in GitHub Workflow](#deployments-in-github-workflow)


---


## What is GitHub actions workflow
A workflow is a configurable automated process made up of one or more jobs. You must create a YAML file to define your workflow configuration.


About YAML syntax for workflows:


* Workflow files use YAML syntax, and must have either a .yml or .yaml file extension. If you're new to YAML and want to learn more, see [Learn YAML in five minutes.](https://www.codeproject.com/Articles/1214409/Learn-YAML-in-five-minutes)
* You must store workflow files in the .github/workflows directory of your repository.


## What are Jobs?
A workflow run is made up of one or more jobs. Jobs run in parallel by default. To run jobs sequentially, you can define dependencies on other jobs using the `jobs.<job_id>`


Each job runs in an environment specified by `runs-on`


You can run an unlimited number of jobs as long as you are within the workflow usage limits. 
>> For more information, see [Usage limits and billing](https://docs.github.com/en/free-pro-team@latest/actions/reference/usage-limits-billing-and-administration) for GitHub-hosted runners and [About self-hosted runners](https://docs.github.com/en/free-pro-team@latest/actions/hosting-your-own-runners/about-self-hosted-runners/#usage-limits) for self-hosted runner usage limits.


>> If you need to find the unique identifier of a job running in a workflow run, you can use the GitHub API. For more information, see [Workflow Jobs.](https://docs.github.com/en/free-pro-team@latest/v3/actions/workflow-jobs)


### name: 
The name of your workflow. GitHub displays the names of your workflows on your repository's actions page. If you omit name, GitHub sets it to the workflow file path relative to the root of the repository.


    name: 'Build and Deploy Non-Prod'
### on
Required The name of the GitHub event that triggers the workflow. You can provide a single event string, array of events, array of event types, or an event configuration map that schedules a workflow or restricts the execution of a workflow to specific files, tags, or branch changes.


    on:
      pull_request:
        paths-ignore:
        - "terraform/**"
        - "k8s/**"


### env
A map of environment variables that are available to all jobs and steps in the workflow. You can also set environment variables that are only available to a job or step.


    env:
      REGISTRY_NAME: ''
      REGISTRY_USERNAME: ''
      KEYVAULT_NAME: ''
      APPLICATION_NAME: '' 
      NAMESPACE: ''
      HELM_VERSION: '3.4.0'
      RESOURCE_GROUP: ''
      CLUSTER_NAME: ''


### jobs
A workflow run is made up of one or more jobs. Jobs run in parallel by default. To run jobs sequentially, you can define dependencies on other jobs using the jobs.<job_id>.needs keyword.
Each job runs in an environment specified by runs-on.


    jobs:
      build:
        name: 'Build Application'
        runs-on: self-hosted


### What is jobs.<job_id>.steps?
A job contains a sequence of tasks called steps. Steps can run commands, run setup tasks, or run an action in your repository, a public repository, or an action published in a Docker registry. Not all steps run actions, but all actions run as a step. Each step runs in its own process in the runner environment and has access to the workspace and filesystem. Because steps run in their own process, changes to environment variables are not preserved between steps. GitHub provides built-in steps to set up and complete a job.


    steps:
      # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v2




***


## Deployments in GitHub Workflow


  Deployments are requests to deploy a specific ref (branch, SHA, tag). GitHub dispatches a deployment event that external services can listen for and act on when new deployments are created. Deployments enable developers and organizations to build loosely coupled tooling around deployments, without having to worry about the implementation details of delivering different types of applications (e.g., web, native).


      deploy:
        name: 'Deploy to Non-Prod'
        needs: build
        runs-on: self-hosted


 You can find action Workflow under


<em>**Actions** tab > **Workflows** > **All Workflows** with name **Build and Deploy Non Prod** </em>
 as provided in the *name* syntax.


![Github Actions Workflow]()


On opening the Workflow, you will see the jobs which we have specified in the workflow yaml file and the steps as shown in the right side of the image.


![Workflow Jobs and Steps]()
 




























