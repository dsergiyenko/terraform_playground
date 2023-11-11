input creds in file your_env_file and use terraform

```
   cat <<EOF >>your_env_file
   #!/bin/sh
   export TF_VAR_user_name='your_username'
   export TF_VAR_password='your_password'
   export TF_VAR_tenant_name='your_tenant_name'
   EOF

   source your_env_file
   terraform init
   terraform plan
   terraform apply
   terraform destroy
```
