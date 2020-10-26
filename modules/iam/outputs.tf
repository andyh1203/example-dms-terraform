output "dms_vpc_management_role" {
  value = aws_iam_role_policy_attachment.dms-vpc-role_AmazonDMSVPCManagementRole
}

output "dms_s3_access_role_arn" {
  value = aws_iam_role.dms_access_for_endpoint.arn
}
