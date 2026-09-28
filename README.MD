Static Website Project
----------------------

To deploy a static website on amazon s3 bucket using 2 methods


Manual setup
----------------------
Git clone the repo into your local repo so you have the website files handy in your system

Login into the aws console
- Search and go to the s3 section and click the create bucket button
- Fillout the name of the bucket, uncheck the Block all public access(for public access) and go through the other parts of the form and click create bucket.
- Click to the General purpose buckets to see the newly created bucket.
- Click on the bucket name(its empyty) and go to the property section; Stroll down to the end of the page and click the static web hosting and click edit.
- check the enable option and click save
- Go back to the General purpose buckets section at the right hand side and click the bucket name once again.
- Once inside the bucket click the upload button and upload the website files manually



Using Terraform
----------------------
- provider file is created with the name provider.tf to specify your infracture provider.
- main.tf file is created which will contain all the necessary configurations resources.
- aws_s3_bucket resource is first provisioned with the bucket name and tags if needed.
- aws_s3_bucket_public_access_block resource is added to ensure the bucket is public by setting the following to false
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false

    referencing the s3_bucket first added.
- aws_s3_bucket_ownership_controls resource is added to set the rule of bucketownership to BucketOwnerPreferred
- aws_s3_bucket_acl is added to depends on both the aws_s3_bucket_public_access_block and the aws_s3_bucket_ownership_controls and set the acl to public-read.
- aws_s3_bucket_policy is added. it depends on the aws_s3_bucket_acl and set the policy to the bucket.
- aws_s3_bucket_website_configuration is added to set the index.html (and error html is needed)
- Once the bucket configuration is completed, we need to upload the git repo so we can access it publicly. 
    a null_resource is added to help with the task of clonning and uploading the files into the bucket.

    1st... I tried a direct approach of using this command:
        aws s3 scp https://github.com/cloudacademy/static-website-example.git s3://${aws_s3_bucket.terraform-static-web-s3.id}/ 
    Didnt work.
    Tried aws s3 cp https://github.com/cloudacademy/static-website-example.git s3://${aws_s3_bucket.terraform-static-web-s3.id}/ 
    thinking the scp is the error so I used the cp but didnt well too.

    Finally I had to go through the normal long and not-confusing process and using the heredoc to simplify the commands;
        - created a dir on my local system 
        - git clone the repo into the dir
        - remove the .git dir from the files using the 
            rm -rf /tmp/git-to-s3-repo/.git
        - upload the files uisng sync 
         aws s3 sync /tmp/git-to-s3-repo/ s3://${aws_s3_bucket.terraform-static-web-s3.id}/
        - Deleting the dir from my local repo immediately the upload finishes
        - EndOfFile for the heredoc
    

Cheers