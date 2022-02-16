# EC deployment automation

The main goal of this feature is to deploy the EC agents in EKS environment using automation scripts. EC Subscribers will have the capability to provide the mandatory ec-agent-configurations through the UI. 

We have 2 possible ways for deploying the application

## Deploy with Argo CD

![deployment-argocd](https://user-images.githubusercontent.com/38732583/151253203-02cf0b81-adcf-4d71-b035-dbb897bf5764.png)

As reflected in the diagram above, the configurations from the UI will be converted into scripts and those scripts will be stored in github using GitHub APIs. Then those deployment scripts will be pulled from GitHub via ArgoCD to deploy the ec-agents with the required configurations in the EKS environment. 

## Deploy with remote control

![deployment-remotecontrol](https://user-images.githubusercontent.com/38732583/151253237-8db0dd35-ff9f-401e-9d6e-a56046d14f3b.png)

