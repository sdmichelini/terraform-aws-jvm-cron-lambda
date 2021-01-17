# JVM Cron Lambda

Opinionated AWS lambda function used for cron based JVM workloads

## Features

### Execution Role Creation

Creates the resources used need to give the lambda an IAM role.

### Multi-workspace and multi-region agnostic

Applys friendly names to resources and makes sure its resource names don't collide across
regions or terraform workspaces.

### Fail-fast mentality

Does a data lookup of the s3 artifact to ensure existence before creating other resources.