terraform {
    backend "s3" {
        bucket = "fmk-test-state"
        key = "aws/fmk/dev/infrastructure/terraform.tfstate"
        region = "eu-west-2"
        encrypt = "true"
    }
}