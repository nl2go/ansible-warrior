# Ansible Warrior

A tutorial that helps to get to know important [Ansible](https://www.ansible.com/) features around
SSH Key authentication, secret encryption and [Ansible Galaxy](https://galaxy.ansible.com/) role management.

This project relies on [nl2go/docker-ansible](https://github.com/nl2go/docker-ansible) providing a [Docker](https://www.docker.com/)
image for Ansible with additional convenience features.

## Prerequisites

Before getting started, following packages must be installed.

- [Git](https://git-scm.com/downloads)
- [Docker](https://docs.docker.com/v17.09/engine/installation/) `>= 17.x`
- [Docker Compose](https://docs.docker.com/compose/install/) `>= 2.x`

## Preparations

1. Clone this project to the directory of your choice.

        $ git clone https://github.com/nl2go/ansible-warrior.git
        $ cd ansible-warrior

2. Backup your current private key if present.

        $ mv ~/.ssh/id_rsa ~/.ssh/id_rsa_backup

## Scenarios

### Run Ansible Container

1. Run Ansible container using Docker Compose.

        $ docker-compose run ansible
        Skipping SSH Agent start. No private key was found at /tmp/.ssh/id_rsa.
        Skpping Ansible Vault password decryption. No .vault-password files present.
        Skipping Ansible Galaxy roles installation. No /ansible/roles/requirements.yml file present.

1. Print Ansible version.

        $ ansible --version
        ansible 2.7.0
          config file = None
          configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
          ansible python module location = /usr/lib/python3.7/site-packages/ansible
          executable location = /usr/bin/ansible
          python version = 3.7.5 (default, Oct 17 2019, 12:25:15) [GCC 8.3.0]

1. Exit Ansible container.
    
        $ exit

#### Recap
You have successfully run Ansible inside the Docker container using [docker-compose.yml](docker-compose.yml).

### Key Based Authentication

1. Copy the project test private key to the standard key location.

       $ cp .docker/root/.ssh/id_rsa ~/.ssh/id_rsa
  
1. Run Ansible container.

        $ docker-compose run ansible
    
1. Specify test private key passphrase `Abcd1234`.

        ...
        Starting SSH Agent.
        Enter passphrase for /root/.ssh/id_rsa: 

1. Ensure test private key was added to the SSH agent.

        ...
        Identity added: /root/.ssh/id_rsa (/root/.ssh/id_rsa)
        ...
 
1. Run Ansible playbook `key_authentication.yml`

        $ ansible-playbook -i inventories/dev/hosts.ini key_authentication.yml
        
        PLAY [crash-test-dummy] ****************************************************
        
        TASK [Test SSH connection using private/public key pair.] ******************
        ok: [crash-test-dummy]
        
        PLAY RECAP *****************************************************************
        crash-test-dummy           : ok=1    changed=0    unreachable=0    failed=0   

1. Exit Ansible container.
    
        $ exit

1. Remove project test private key

        $ rm ~/.ssh/id_rsa

#### Recap
You have successfully run the playbook `key_authentication.yml` against `crash-test-dummy` host using SSH key authentication.

### Ansible Galaxy Role

The playbook `galaxy_role.yml` relies on the [Ansible Galaxy](https://galaxy.ansible.com/) Role `chusiang.helloworld`.
To be able to execute the playbook the role must be installed first.

1. Create `requirements.yml` within the `roles` directory as required by [Ansible Tower](https://www.ansible.com/products/tower).

        $ touch roles/requirements.yml
        
1. Add `chusiang.helloworld` role to the `roles/requirements.yml`.

        $ echo '- src: chusiang.helloworld' > roles/requirements.yml

1. Run Ansible container.

        $ docker-compose run ansible
        Skipping SSH Agent start. No private key was found at /tmp/.ssh/id_rsa.
        Skpping Anisble Vault password decryption. No .vault-password files present.
        Installing Ansible Galaxy roles from /ansible/roles/requirements.yml.
        - downloading role 'helloworld', owned by chusiang
        - downloading role from https://github.com/chusiang/helloworld.ansible.role/archive/master.tar.gz
        - extracting chusiang.helloworld to /root/.ansible/roles/chusiang.helloworld
        - chusiang.helloworld (master) was installed successfully
        
1. Run `galaxy_role.yml` playbook.

        $ ansible-playbook -i inventories/dev/hosts.ini galaxy_role.yml

1. Exit Ansible container.
    
        $ exit
        
1. Remove `roles/requirements.yml`.

        $ rm roles/requirements.yml

#### Recap
You have successfully installed an Ansible Galaxy Role and run the `galaxy_role.yml` playbook.

### Ansible Vault Master Password

1. Run Ansible container.

        $ docker-compose run ansible
        
1. Generate encrypted vault password file for the `dev` inventory using master password `master` and the inventory Vault
password `Abcd1234`.

        $ cd inventories/dev
        $ ansible-encrypt-vault-password
        Enter the master password for .vault-password files:
        Enter the vault password for dev inventory:
        
1. Exit Ansible container.
    
        $ exit

1. Run Ansible container and specify the Vault master password `master`.

        $ docker-compose run ansible
        Skipping SSH Agent start. No private key was found at /tmp/.ssh/id_rsa.
        Decrypting Ansible Vault passwords.
        Enter decryption password for .vault-password files: 
        Decrypting /ansible/inventories/dev/.vault-password.
        Skipping Ansible Galaxy roles installation. No /ansible/roles/requirements.yml file present.

1. Run `vault_master_password` playbook.

        $ ansible-playbook -i inventories/dev/hosts.ini vault_master_password.yml
        
        PLAY [localhost] ***********************************************************
        
        TASK [Gathering Facts] *****************************************************
        ok: [localhost]
        
        TASK [debug] ***************************************************************
        ok: [localhost] => {
            "msg": "Hello World!"
        }
        
        PLAY RECAP *****************************************************************
        localhost                  : ok=2    changed=0    unreachable=0    failed=0   

1. Exit Ansible container.
    
        $ exit
        
#### Recap

You have successfully run the `vault_master_password` playbook while decrypting the `secret_message` variable to `Hello World!`.

### Ansible Vault Secret
This scenario relies on existing encrypted Vault password file for the `dev` inventory located at `inventories/dev/.vault-password`.

1. Run Ansible container.

        $ docker-compose run ansible
        
1. Run Ansible container and specify the Vault master password `master`.

        $ docker-compose run ansible
        Skipping SSH Agent start. No private key was found at /tmp/.ssh/id_rsa.
        Decrypting Ansible Vault passwords.
        Enter decryption password for .vault-password files: 
        Decrypting /ansible/inventories/dev/.vault-password.
        Skipping Ansible Galaxy roles installation. No /ansible/roles/requirements.yml file present.
        
1. Encrypt secret value `foobar123` for the `dev` inventory.

        $ ansible-vault encrypt_string --encrypt-vault-id 'dev' 'foobar123'
        !vault |
                  $ANSIBLE_VAULT;1.2;AES256;dev
                  34313833626331373036336338663831333833356532306363336532306362376232653835613035
                  6131303730313238633938636564663866356164383735610a353133613363663239326337313231
                  64333737343634356531383864313031333134646264373035626363363865343037306436363462
                  3832363461623233620a383135343062643433613763656462623565346363303866376264643661
                  6236
        Encryption successful

1. Replace the plain `bar` value within `inventories/dev/host_vars/localhost/foo.yml` with the encrypted
value from the previous step and verify the result.

        $ cat inventories/dev/host_vars/localhost/foo.yml
        ---
        bar: !vault |
          $ANSIBLE_VAULT;1.2;AES256;dev
          34313833626331373036336338663831333833356532306363336532306362376232653835613035
          6131303730313238633938636564663866356164383735610a353133613363663239326337313231
          64333737343634356531383864313031333134646264373035626363363865343037306436363462
          3832363461623233620a383135343062643433613763656462623565346363303866376264643661
          6236
         
1. Run the `vault_secret` playbook.

        $ ansible-playbook -i inventories/dev/hosts.ini vault_secret.yml
        
        PLAY [localhost] ***********************************************************
        
        TASK [Gathering Facts] *****************************************************
        ok: [localhost]
        
        TASK [debug] ***************************************************************
        ok: [localhost] => {
            "msg": "foobar123"
        }
        
        PLAY RECAP *****************************************************************
        localhost                  : ok=2    changed=0    unreachable=0    failed=0   

#### Recap

You have successfully encrypted an existing variable `bar` and executed the `vault_secret` playbook that
utilizes the encrypted variable.

## Maintainers

- [build-failure](https://github.com/build-failure)

## License

See the [LICENSE.md](LICENSE.md) file for details
