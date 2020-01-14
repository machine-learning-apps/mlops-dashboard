## Purpose

Give developers an incentive to provide a [standardized ML specification](https://docs.google.com/document/d/1dt3FfZjXDaOHQfZIDFkLLKLlJasxluaQlw5LkXp5ZtI/edit) for machine learning projects, to  enable the following:

- An entrypoint for users to run ML workloads on the compute of their choice ( or on GitHub directly? )
- Provide mechanisms to make ML workflows extensible and facilitate greater collaboration / experimentation.
- Transperency by organizing information into a common format
- Reproduceability

One way of providing this incentive is to render the information associated with the standardized specification into a dashboard which facilitates the consumption of this information.  Furthermore, this dashboard should facilitate interacting with the ML workflow, including running and deploying models.

## The Prototype

This initial prototype uses [Jekyll](https://jekyllrb.com/docs/) and GitHub Actions to render assets (metadata in the form of YAML & JSON, notebooks, etc) into a MLOps Dashboard.  The metadata is located in a repo in a pre-determined directory structure. When metadata is created or changed in a repo, a GitHub Action refreshes the GitHub page.  
