# Azure Infrastructure Deployment with Bicep & GitHub Actions

## 🎯 Overview
This project demonstrates my ability to provision cloud resources on **Azure** using **Infrastructure as Code (IaC)**. It automates the deployment process and ensures code quality through a **CI/CD pipeline**.

## 🛠 Tech Stack
- **Cloud Provider:** Microsoft Azure
- **IaC Tool:** Bicep
- **CI/CD:** GitHub Actions
- **Version Control:** Git

## 🏗 Project Structure
- `storage.bicep`: Defines an Azure Storage Account with specific configurations (LRS, Hot Tier).
- `.github/workflows/main.yml`: A GitHub Actions workflow that automatically validates the Bicep code (Linting) on every push.

## 🚀 Key Learning Outcomes
- Understanding of **Azure Resource Providers**.
- Practical experience with **Declarative Syntax** in Bicep.
- Implementation of **Continuous Integration (CI)** to catch configuration errors early.

## 🔧 How to run
To deploy this infrastructure, use the Azure CLI:
```bash
az deployment group create --resource-group <YourResourceGroup> --template-file storage.bicep
