# Email as API
This terraform module will create a REST API to send Emails using Amazon SES.  You just provide the list of Projects, domain/email identities, this module will create Amazon SES configuration and will generate REST API endpoints accordingly.


# Links

- [Documentation](https://cloudpedia.ai/terraform-module/aws-email-as-api/)
- [Terraform module](https://registry.terraform.io/modules/cloudpediaai/email-as-api/aws/latest)
- [GitHub Repo](https://github.com/CloudPediaAI/terraform-aws-email-as-api)


## Latest Release - v1.2.4

### 🚀 What's New
- **Fixed Critical Terraform Cycle Issues**: Resolved API Gateway dependency conflicts that prevented clean deployments
- **Enhanced CORS Support**: Added configurable CORS origins for better security and flexibility  
- **Improved Resource Management**: Streamlined dependency chains for more reliable deployments
- **Better Code Organization**: Separated concerns with dedicated files for auth and CORS handling

See [CHANGELOG.md](CHANGELOG.md) for complete details.

## v1.0.0 
Initial release features:
- Amazon SES Email channel 
- POST endpoints and Lambda for sending emails
- SMTP User 

