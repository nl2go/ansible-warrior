# Ansible Warrior

Containerized [Ansible](https://www.ansible.com/) CLI.

Contains additional tools/packages (s. [Dockerfile](Dockerfile)).

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


#### Recap
You have successfully run the playbook `key_authentication.yml` against `crash-test-dummy` host using SSH key authentication.

### Ansible Galaxy Role

The playbook `galaxy_role.yml` relies on the [Ansible Galaxy](https://galaxy.ansible.com/) Role `chusiang.helloworld`.
To be able to execute the playbook the role must be installed first.

1. Create `requirements.yml` within the `roles` directory as required by [Ansible Tower](https://www.ansible.com/products/tower).

        $ touch roles/requirements.yml
        
1. Add `chusiang.helloworld` role to the `roles/requirements.yml`.

        $ echo '- src: chusiang.helloworld' > roles/requirements.yml
        
1. Install roles from `roles/requirements.yml`.

        $ ansible-galaxy-init
        Installing Ansible Galaxy roles from /ansible/roles/requirements.yml.
        - downloading role 'helloworld', owned by chusiang
        - downloading role from https://github.com/chusiang/helloworld.ansible.role/archive/master.tar.gz
        - extracting chusiang.helloworld to /root/.ansible/roles/chusiang.helloworld
        - chusiang.helloworld (master) was installed successfully

1. Run `galaxy_role.yml` playbook.

        $ ansible-playbook -i inventories/dev/hosts.ini galaxy_role.yml
        
#### Recap
You have successfully installed an Ansible Galaxy Role and run the `galaxy_role.yml` playbook. Next time you start the
Ansible container any Ansible Galaxy Roles specified within `roles/requirements.yml` will be installed automatically.



## Maintainers

- [build-failure](https://github.com/build-failure)

## License

See the [LICENSE.md](LICENSE.md) file for details
