# CloudOrch To-Do

**CloudOrch To-Do** is not just another To-Do app — it’s a **cloud-infrastructure project** that highlights how to build and deploy a scalable application on Azure using **Infrastructure as Code (IaC)**.

The project uses **ARM templates** and **Custom Script Extensions** to automatically provision and configure the entire environment:

* **OS:** Ubuntu Linux (24.04 LTS) for all VMs  
* **Frontend (React + Nginx)** on two VMs behind the Azure Load Balancer 
* **Backend (Node.js + Express)** on a separate VM
* **Database (PostgreSQL)** on a dedicated VM
* **Azure Load Balancer** distributing traffic for high availability

This demonstrates how IaC can be applied to create **reproducible, automated, and scalable cloud environments**.

## Features

* **Infrastructure as Code (IaC):** ARM templates define the whole setup (VNet, Subnets, NSGs, VMs, Load Balancer)
* **Cloud-native design:** full separation of frontend, backend, and database tiers
* **Scalability & high availability:** Azure Load Balancer spreads traffic across backend VMs
* **Automated provisioning:** custom scripts configure servers on deployment
* **Simple To-Do CRUD operations** to validate the architecture

## How to Deploy

### Option 1: One-click deployment

Click the button below to deploy directly to your Azure subscription:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](
https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FWaleedAlsafari%2FCloudOrch-To-Do%2Frefs%2Fheads%2Fmain%2Finfrastructure%2Ftemplate.json)


### Option 2: Deploy with Azure CLI

1. Clone the repository:

   ```bash
   git clone https://github.com/WaleedAlsafari/CloudOrch-To-Do.git
   cd CloudOrch-To-Do
   ```
2. Run the deployment command:

   ```bash
   az deployment group create \
     --resource-group <your-resource-group> \
     --template-file template.json \
     --parameters parameters.json
   ```

Once the deployment finishes successfully, copy the public IP address of the Load Balancer from the Azure Portal and paste it into a new browser tab to access the app.

