## What is in this Wiki Page
- [About Helm](#about-helm)
- [What is a Helm Chart](#What-is-a-Helm-chart)
- [How Helm is implemented for ](#How-Helm-is-implemented-for-)
- [Helm Ignore File](#Helm-Ignore-File)
- [What are Templates?](#What-are-Templates?)

 

## About Helm
Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application.
Charts are easy to create, version, share, and publish — so start using Helm and stop the copy-and-paste.
Helm is a graduated project in the CNCF and is maintained by the Helm community.

 

**The Purpose of Helm**

 

Helm is a tool for managing Kubernetes packages called charts. Helm can do the following:

 

* Create new charts from scratch
* Package charts into chart archive (tgz) files
* Interact with chart repositories where charts are stored
* Install and uninstall charts into an existing Kubernetes cluster
* Manage the release cycle of charts that have been installed with Helm

 

**For Helm, there are three important concepts:**

 

* The chart is a bundle of information necessary to create an instance of a Kubernetes application.
* The config contains configuration information that can be merged into a packaged chart to create a releasable object.
* A release is a running instance of a chart, combined with a specific config.

 

## How Helm is implemented for 

 

The Helm chart is a yaml template file which maintains the application info which help you define, install, and upgrade .
Helm chart is available in path charts/

 

## What is a Helm Chart

 

Helm uses a packaging format called charts. A chart is a collection of files that describe a related set of Kubernetes resources. A single chart might be used to deploy something simple, like a memcached pod, or something complex, like a full web app stack with HTTP servers, databases, caches, and so on.
Charts are created as files laid out in a particular directory tree. They can be packaged into versioned archives to be deployed.

 

**Charts and Versioning**
It's a YAML file containing the information about the chart for application.
Every chart must have a version number. A version must follow the SemVer 2 standard. Unlike Helm Classic, Helm v2 and later uses version numbers as release markers. Packages in repositories are identified by name plus version.

 

**API Version Field** 
The apiVersion field should be v2 for Helm charts that require at least Helm 3. Charts supporting previous Helm versions have an apiVersion set to v1 and are still installable by Helm 3.

 

**AppVersion**
Note that the appVersion field is not related to the version field. It is a way of specifying the version of the application.

 

**Values.yaml**

 

The order of specificity: values.yml is the default, which can be overridden by parent chart's values.yml, which can in turn be overridden by a user supplied values file, which can be in turn overridden by --set parameters.

 

## What are Templates?

 

A directory of templates that, when combined with values, will generate valid Kubernetes manifest files.
Helm reserves use of the charts/, crds/, and templates/ directories, and of the listed file names. Other files will be left as they are.