# Basic AWS Stack Demo with NodeJS API & Terraform

## Table of content

   * [Solution overview](#solution-overview)
   * [Infrastructure](#infrastructure)



## Solution overview

This repo contains Terraform code to deploy a NodeJS API that connects to a PostgreSQL database and can send files to an S3 bucket.

<p align="center">
  <img src="docs/solution.png"/>
</p>




## Infrastructure

The `aws/` folder contains the terraform code to deploy AWS resources, and `aws/mods/` is for the modules.

About the modules:

- networking: will create resources if `vpc_id` is empty.
  - vpc
  - public, private and data subnets
  - nat gateway, elastic ips and routes

- rds: postgresql database
  - security group
  - database subnet group
  - database parameter group
  - database instance
  - random password and secrets 
  - paramter store
  - cloudwatc alarms

- alb: will create application load balancer if `create_alb` is `true`
  - security group
  - application load balancer
  - http listener

- s3: bucket with versioning enabled
- sns: sns alarm topic 
- ecr: container image repository
- ecs/cluster: ecs cluster using fargate
- ecs/task-def: ecs task definition
  - execution role to deploy the service
  - task role
  - task definition

- ecs/service: ecs service
  - security group
  - target group with health check
  - listener rule to attach to a listener
  - ecs service attached to a load balancer
  - cloudwatch alarms

- devops: configure github actions
  - cicd user
  - envs and secrets on guthub actions


