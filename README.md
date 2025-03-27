# Capstone Project

## Retail Store Microservices on Kubernetes with Observability

This capstone project aims to design, deploy, and manage a cloud-native retail store microservice architecture on a Kubernetes cluster, emphasizing observability and secure external access. The project demonstrates a comprehensive understanding of modern cloud technologies and best practices.

## Architecture and Implementation

The retail store application is decomposed into a microservice architecture, allowing for independent development, deployment, and scaling of individual components. These microservices included:

* **Storefront:** Provides the frontend user interface for the retail store.
* **Product Catalog Service:** Manages product listing and details.
* **Cart Service:** Manages customer shopping cart.
* **Checkout Service:** Orchestrates the checkout process.
* **Order Service:** Handles order placement and processing.
* **Static Assets:** Serves static assets like images related to the product catalog.

These microservices are containerized using Docker with Kustomize customization and orchestrated using Kubernetes, providing a scalable and resilient platform.

## Observability

To ensure the health and performance of the microservices, a robust observability stack is implemented using:

* **Prometheus:** Collected time-series metrics from the Kubernetes cluster and microservices. Custom metrics were defined to monitor key performance indicators (KPIs) such as request latency, error rates, and resource utilization.
* **Grafana:** Visualized the collected metrics through customizable dashboards, providing real-time insights into the system's behavior. Grafana dashboards were created to monitor cluster health, microservice performance, and application-specific metrics.

This observability setup enables proactive monitoring, rapid troubleshooting, and performance optimization.

## Secure External Access

To provide secure external access to the retail store application, the following technologies are employed:

* **HTTPS:** Encrypt communication between clients and the application, ensuring data confidentiality and integrity.
* **External DNS:** Dynamically manage DNS records, enabling access to the application through a user-friendly domain name.
* **Cert-Manager:** Automate the process of obtaining and renewing TLS certificates from Let's Encrypt, simplifying certificate management and ensuring continuous HTTPS availability.
* **Ingress:** Used to route external HTTP and HTTPS traffic to the correct microservice.

This setup ensures secure and reliable access to the application from the public internet.

## Key Technologies

* Kubernetes
* Terraform
* Helm
* Kustomize
* Prometheus
* Grafana
* External DNS
* Cert-Manager
* Ingress
* Microservices Architecture

## Project Outcomes

* A fully functional retail store microservice architecture deployed on Kubernetes.
* Comprehensive observability using Prometheus and Grafana.
* Secure external access via HTTPS, External DNS, and Cert-Manager with Let's Encrypt.
* Demonstrate proficiency in cloud-native technologies and best practices.
* A solid foundation for building and managing scalable and resilient applications in a production environment.

## Conclusion

This capstone project successfully demonstrates the ability to design and implement a complex microservice architecture on Kubernetes, incorporating essential aspects of observability and secure access. The project provides valuable hands-on experience with modern cloud technologies and highlightes the importance of these technologies in building and managing scalable and reliable applications.

![architecture](docs/diagrams/architecture.drawio.svg)

For more details, read the [documentation](https://ntu-ce8-project.github.io/eks-infra/).

To contribute to the repository, follow our [contribution guidelines](/CONTRIBUTING.md).
