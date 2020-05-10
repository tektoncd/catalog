git-clone ssh
====

Prepare secrets for ssh authentication.

### Prepare known_hosts file
Example using github.com as host

1. Create file with known_hosts (you may also want to verify this further)

    ssh-keyscan github.com > ssh_known_hosts

2. Create secret from file

    kubectl create secret generic github-known-hosts --from-file=ssh_known_hosts

### Generate and distribute SSH key pair
Generate a separate SSH key pair for Tekton

1. Generate keypair to local file

    ssh-keygen -t rsa -b 4096 -f id_rsa -q -N ""

2. Create a secret from the private key

   kubectl create secret generic github-private-key --from-file=id_rsa

3. Upload the public key id_rsa.pub to GitHub

   Start with copying the content of the public key with

    pbcopy < id_rsa.pub

   And follow [Adding a new SSH key to your GitHub account](https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account)
~                                                                                                                                                                   