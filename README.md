# ☁️ Secure Azure Infrastructure with Bicep & GitHub Actions

![Architecture Diagram](architecture.drawio.png)

## 🎯 Project Overview
This project demonstrates a professional **Infrastructure as Code (IaC)** workflow. I have designed a secure, multi-resource Azure environment using **Bicep** and automated the validation process through a **CI/CD pipeline**.

## 🏗 Architecture Components
- **Virtual Network (VNet):** A private network space (10.0.0.0/16) for cloud resources.
- **Secure Subnet:** A segmented portion of the network (10.0.1.0/24).
- **Network Security Group (NSG):** A built-in firewall with a custom rule to **Allow HTTP (Port 80)** traffic while blocking unauthorized access.
- **Storage Account:** Configured with `Standard_LRS` for cost-effective data redundancy.

## 🛠 Tech Stack & Skills
- **Cloud Provider:** Microsoft Azure
- **IaC Tool:** Azure Bicep (Modular & Declarative)
- **CI/CD:** GitHub Actions (Automated Linting & Validation)
- **Security:** Network traffic filtering and Secure-by-Design principles.

## 🚀 CI/CD Workflow (Continuous Integration)
The project includes a GitHub Actions workflow (`main.yml`) that:
1. Triggers automatically on every **Git Push**.
2. Provisions a temporary **Linux (Ubuntu)** environment.
3. Executes `az bicep build` to perform **Static Analysis** and ensure the code is error-free before deployment.

## 🔧 Deployment
To deploy this infrastructure after the CI check passes, use the Azure CLI:
```bash
az deployment group create --resource-group <YourRG> --template-file main.bicep
```bash
az deployment group create --resource-group <YourRG> --template-file main.bicep
