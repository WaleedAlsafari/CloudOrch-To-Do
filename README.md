# CloudOrch To-Do

**CloudOrch To-Do** is not just another To-Do app — it’s a **cloud-infrastructure project** that focuses on how to build and deploy a scalable application on Azure using **Infrastructure as Code (IaC)**.

The project uses **ARM templates** and **Custom Script Extensions** to automatically provision and configure the entire environment:

* **OS:** Ubuntu Linux for all VMs  
* **Frontend (React + Nginx)** on two VMs behind the Azure Load Balancer 
* **Backend (Node.js + Express)** on a separate VM
* **Database (PostgreSQL)** on a separate VM
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



## Accessing the Virtual Machines for additional configuration

> **Note:** You can't access the VMs directly because they are connected to a **private virtual network** for security reasons.  
> To connect to them, you have three options:

1. **Azure Bastion** *(Recommended)*  
2. **Virtual Network Gateway (VPN)**  
3. **Public IPs** *(Not recommended due to security risks)*

---

### Option 1: Using Azure Bastion (Recommended)

Azure Bastion allows you to securely connect to your VMs **directly through the Azure Portal** — no need for public IPs or VPN setup.  
It provides **browser-based RDP/SSH access** over SSL, keeping your VMs isolated within the private network.

You can deploy the Bastion Host for this project using the button below:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FWaleedAlsafari%2FCloudOrch-To-Do%2Frefs%2Fheads%2Fmain%2Finfrastructure%2Fbastion-template.json)

---

### After Deployment Succeeds

1. Open the **target VM** you want to connect to.  
2. From the top menu, click **Connect → Bastion**.  
3. Select **SSH** (because it's Linux-based).  
4. Enter the VM’s username and password and then click **Connect**.  
5. A new session will open in the browser  — **you’re now connected to your VM through Azure Bastion!**

---

### Option 2: Using Virtual Network Gateway (VPN)

You can deploy the Azure **Virtual Network Gateway** (VPN) template directly to your subscription by clicking the button below:

Before deployment:
1. Run the folowing two commands respectively to generate root and client certificate used for authenticate your device with the VPN:

$cert = New-SelfSignedCertificate `
  -Type Custom `
  -KeySpec Signature `
  -Subject "CN=RootCert" `
  -KeyExportPolicy Exportable `
  -HashAlgorithm sha256 `
  -KeyLength 2048 `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -KeyUsageProperty Sign `
  -KeyUsage CertSign

  New-SelfSignedCertificate `
  -Type Custom `
  -DnsName "ClientCert" `
  -KeySpec Signature `
  -Subject "CN=ClientCert" `
  -KeyExportPolicy Exportable `
  -HashAlgorithm sha256 `
  -KeyLength 2048 `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -Signer $cert `
  -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FWaleedAlsafari%2FCloudOrch-To-Do%2Fmain%2Finfrastructure%2Fvpn-template.json)

After deployment:
1. Install the **Azure VPN Client** app from Microsoft Store
1. Open the created **Virtual Network Gateway**.  
2. Navigate to **Point-to-site configuration** → **Download VPN client**.  
3. Install the client on your device and connect securely to your VNet.

---


