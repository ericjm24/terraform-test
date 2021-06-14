# terraform-test
A simple project testing out using Terraform and Github Actions for DevOps.

This project sets up a virtual machine on google cloud. The machine is loaded with a docker image containing a simple "Hello World" Flask app that can be accessed by directing a standard browser to the external IP address of that machine. The entire system is set up through github actions on push to any branch in [main|stage|dev], and sets up a corresponding [prod|stage|dev] virtual machine. Pushes to any other branch will do nothing.

In order to work, the corresponding Github repo must be equipped with a Github Secret containing the contents of a Google Service Account json key that has the required permissions. These permissions include the ability to create/access storage objects, access the Google Container Registry, create and modify Google Compute Engine resources, and ability to edit Service Account permissions. A better version of this code would utilize different access tokens with more limited permissions following the rule of least access, but that is not in the scope of this proof-of-concept.

Github actions are currently commented out so they do not create resources on push. Simply uncomment the "on:" block of .github/workflows/terraform.yml to activate the action on push.