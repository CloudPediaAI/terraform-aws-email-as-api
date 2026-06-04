# Email as API
This terraform module will create a REST API to send Emails using Amazon SES.  You just provide the list of Projects, domain/email identities, this module will create Amazon SES configuration and will generate REST API endpoints accordingly.


# Links

- [Documentation](https://cloudpedia.ai/terraform-module/aws-email-as-api/)
- [Terraform module](https://registry.terraform.io/modules/cloudpediaai/email-as-api/aws/latest)
- [GitHub Repo](https://github.com/CloudPediaAI/terraform-aws-email-as-api)


## Latest Release - v1.2.5

### 🚀 What's New
- **Optional SMTP IAM Condition**: SMTP user policy `condition` is now only added when `smtp_user_allow_condition` is set (non-null)
- **Input Fix**: Standardized the variable name to `smtp_user_allow_condition` and made it a structured object (`test`, `variable`, `values`)

See [CHANGELOG.md](CHANGELOG.md) for complete details.

### SMTP policy condition (optional)
If you enable `need_smtp_user`, you can optionally restrict the SMTP IAM user policy with `smtp_user_allow_condition`. Leave it unset / `null` to omit the condition block.

Example:
```hcl
smtp_user_allow_condition = {
	test     = "IpAddress"
	variable = "aws:SourceIp"
	values   = ["9.9.9.9/32"]
}
```

## v1.0.0 
Initial release features:
- Amazon SES Email channel 
- POST endpoints and Lambda for sending emails
- SMTP User 

