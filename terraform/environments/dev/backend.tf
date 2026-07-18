terraform {
  backend "s3" {
    bucket       = "ridham-task-manager-tfstate-0303e1ee"
    key          = "dev/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}