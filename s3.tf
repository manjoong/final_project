resource "aws_s3_bucket" "S3Bucket" {
    bucket  = "skcc-cicd-workshop-${var.region}-${var.userid}-${data.aws_caller_identity.current.account_id}"
    acl     = "private"
    
    versioning {
        enabled = true
    }
    
	tags = {
		Name = "CICDWorkshop-S3Bucket"
		Environment = "Dev"
	}
}