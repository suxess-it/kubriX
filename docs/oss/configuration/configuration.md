# Configuration

The **Configuration** section of kubriX explains how the Internal Developer Platform (IDP) is structured, configured, and customized to fit different environments and customer needs.

kubriX follows a **modular configuration model** built around Helm values files, allowing both **turnkey installations** and **fine-grained customization**.  
This approach makes it possible to deliver a stable, secure, and well-integrated platform while keeping it flexible for diverse infrastructure setups.

---

## 📘 Overview

### [Configuration Structure →](./helm-values-structure.md)
Learn how kubriX organizes and prioritizes its configuration files.  
This document describes:
- The modular Helm-based values file system  
- The reasoning behind multiple configuration layers  
- The order of evaluation and override logic  
- The role of installation variables such as `KUBRIX_CLUSTER_TYPE` or `KUBRIX_TSHIRT_SIZE`

This overview is essential for understanding how kubriX assembles a full configuration stack.

---

### [Customizing kubriX for Your Needs →](./customizations.md)
Once you understand the base configuration structure, this guide explains **how to adapt kubriX** to your own use case:
- Adding or overriding Helm values safely  
- Managing environment-specific or customer-specific settings  
- Working with bootstrap-generated values  
- Using `KUBRIX_APP_EXCLUDE` and other installation variables for selective deployments  

---

## 💡 Tips for Working with kubriX Configuration

- **Start from the defaults:** Use the shipped `values-kubrix-default.yaml` as your foundation.
- **Add modular overrides:** Extend configuration through dedicated values files instead of editing defaults directly.
- **Keep overrides visible:** Maintain a clear separation between kubriX-provided and customer-specific configuration.
- **Validate early:** Use `helm lint` and CI rendering previews to ensure configuration consistency before deployment.
- **Prefer maps over lists:** This allows simpler overrides and better composability.

---

## 🧩 Related Topics

- [Installation and Bootstrapping](../installation/installation.md)  

---

> **Summary:**  
> kubriX’s configuration system combines opinionated defaults with full flexibility.  
> Understanding the configuration structure and how to safely extend it is key to building a stable, maintainable IDP deployment.
