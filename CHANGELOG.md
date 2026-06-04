# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.2.5] - 2026-06-03

### 🐛 Fixed
- Made the SMTP user IAM policy condition truly optional by rendering the `condition` block only when `smtp_user_allow_condition` is provided (non-null)

### 🔧 Changed
- Renamed the SMTP condition input variable from the misspelled `stmp_user_allow_condition` to `smtp_user_allow_condition`
- Updated `smtp_user_allow_condition` to a structured object (`test`, `variable`, `values`) and made it nullable (default `null`)

### ⚠️ Upgrade Notes
- If you previously set `stmp_user_allow_condition`, rename it to `smtp_user_allow_condition` and provide keys: `test`, `variable`, `values`

## [v1.2.4] - 2026-01-22

### 🐛 Fixed
- **Critical**: Fixed Terraform cycle dependency error involving `aws_api_gateway_stage.prod`, `aws_api_gateway_integration_response`, and `aws_api_gateway_deployment` resources
- Resolved circular dependencies during `terraform destroy` operations that prevented clean resource teardown
- Fixed integration response dependencies that caused deployment ordering issues

### ✨ Enhanced  
- **CORS Support**: Added comprehensive CORS configuration with configurable allowed origins via `cors_allowed_origins` variable
- **Resource Management**: Improved resource dependency management with explicit `depends_on` declarations across all API Gateway resources
- **Code Organization**: Separated Cognito authorization configuration into dedicated `apig-auth.tf` file for better modularity
- **API Structure**: Added OPTIONS method support for proper CORS preflight handling in `apig-options.tf`

### 🔧 Improved
- **Resource Naming**: Standardized API Gateway resource naming convention (replaced `*_int_*` and `*_res_*` patterns with clearer `*_post_*` naming)
- **Deployment Logic**: Simplified deployment triggers to exclude integration responses and prevent cycles
- **Dependency Chain**: Optimized resource creation order with proper dependency isolation
- **Configuration**: Enhanced deployment trigger logic to be more resilient and avoid integration response cycles

### 📁 File Changes
- **New Files**:
  - `apig-auth.tf` - Centralized API Gateway authorization configuration  
  - `apig-options.tf` - CORS OPTIONS method handling
  - `CHANGELOG.md` - This changelog file

- **Modified Files**:
  - `apig.tf` - Core API Gateway deployment and dependency fixes
  - `apig-send-email.tf` - Resource naming standardization and dependency improvements
  - `main.tf` - CORS parameter definitions and code organization
  - `variables.tf` - Added `cors_allowed_origins` variable
  - `output.tf` - Moved API endpoints output to appropriate location

### ⚡ Performance
- Reduced deployment time by optimizing resource dependency chains
- Eliminated unnecessary resource recreation cycles during updates

### 🔐 Security
- Enhanced CORS security with configurable allowed origins instead of hardcoded wildcards
- Improved resource isolation to prevent unintended cross-dependencies

---

## [v1.0.0] - Initial Release

### ✨ Features
- Amazon SES Email channel integration
- POST endpoints and Lambda functions for sending emails  
- SMTP User creation and configuration
- Basic API Gateway setup for email services

---

**Note**: This changelog was created retroactively for v1.2.4. Future releases will maintain this format for tracking changes.