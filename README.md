# ![Islandora CLAW Vagrant](https://cloud.githubusercontent.com/assets/2371345/22829608/c44c500c-ef79-11e6-93f6-e2222b60fbc4.png) Islandora CLAW Vagrant
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)
[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](./LICENSE)

## Introduction

The is a development environment virtual machine for Islandora CLAW. It should work on any operating system that supports VirtualBox and Vagrant.

N.B. This virtual machine **should not** be used in production.

## Requirements

1. [VirtualBox](https://www.virtualbox.org/)
2. [Vagrant](http://www.vagrantup.com/) 1.8.5+
3. [git](https://git-scm.com/)

## Variables

### System Resources

By default the virtual machine that is built uses 3GB of RAM. Your host machine will need to be able to support the additional memory use. You can override the CPU and RAM allocation by creating `ISLANDORA_VAGRANT_CPUS` and `ISLANDORA_VAGRANT_MEMORY` environment variables and setting the values. For example, on an Ubuntu host you could add to `~/.bashrc`:

```bash
export ISLANDORA_VAGRANT_CPUS=4
export ISLANDORA_VAGRANT_MEMORY=4096
```

### Hostname and Description

If you use a DNS or host file management plugin with Vagrant, you may want to set a specific hostname for the virtual machine. You can do that with the `ISLANDORA_VAGRANT_HOSTNAME` variable.  The `ISLANDORA_VAGRANT_VIRTUALBOXDESCRIPTION` variables can be used to track the VM build. For example:

```bash
export ISLANDORA_VAGRANT_HOSTNAME="claw"
export ISLANDORA_VAGRANT_VIRTUALBOXDESCRIPTION="Islandora CLAW"
```

## Use

VirtualBox:

1. `git clone https://github.com/Islandora-CLAW/claw_vagrant`
2. `cd claw_vagrant`
3. `vagrant up`

## Connect

You can connect to the machine via the browser at [http://localhost:8000](http://localhost:8000).

### Drupal

The default Drupal login details are:
  
  * username: admin
  * password: islandora

### MySQL
  
  * username: root
  * password: islandora

### Fedora4

The Fedora 4 REST API can be accessed at [http://localhost:8080/fcrepo/rest](http://localhost:8080/fcrepo/rest). 

Authentication is done via [Syn](https://github.com/Islandora-CLAW/Syn) using [JWT](https://jwt.io) tokens.

### Tomcat Manager
  
  * username: islandora
  * password: islandora

### SSH

You can connect to the machine via ssh:

  * `vagrant ssh`
  * `ssh -p 2222 ubuntu@localhost`

### VM

The default VM login details are:
  
  * username: ubuntu
  * password: ubuntu
  
### ActiveMQ

The default ActiveMQ login details are:
  
  * username: admin
  * password: admin

You can access the ActiveMQ administrative interface at: http://localhost:8161/admin

### Cantaloupe

You can access the Canataloupe admin interface at: http://localhost:8080/cantaloupe/admin

  * username: admin
  * password: islandora
  
You can access the IIIF interface at: http://localhost:8080/cantaloupe/iiif/2/

### JWT

CLAW uses JWT for authentication across the stack. Crayfish microservices, Fedora, and Drupal all use them. 
Crayfish and Fedora have been set up to use a master token of `islandora` to make testing easier.  To use it, just set
the following header in HTTP requests:

  * `Authorization: Bearer islandora`
  
### BlazeGraph (Bigdata)

You can access the BlazeGraph interface at: http://localhost:8080/bigdata/

You have to select the islandora namespace in the [namespaces tab](http://localhost:8080/bigdata/#namespaces) before you can execute queries.
  
## Environment

- Ubuntu 16.04.2
- Drupal 8.2.7
- MySQL 5.7.15
- Apache 2.4.18
- Tomcat 8.0.32.0
- Solr 6.2.1
- Camel 2.18.1
- Fedora 4.7.2
- Fedora Camel Component 4.5.0
- BlazeGraph 2.4.1
- Karaf 4.0.8
- Alpaca 0.3.1-SNAPSHOT
- Islandora 8.x-1.x
- PHP 7.0.15
- Java 8 (Oracle)
- Cantaloupe IIIF Server v3.3
- ActiveMQ 5.14.5

## Windows Troubleshooting

If you receive errors involving `\r` (end of line) you have two options:

1. Clone the project using `--single-branch`.

  ```
  git clone --single-branch git@github.com:Islandora-CLAW/claw_vagrant.git
  ```
  A benifit to this approach is that files created or edited on a Windows environment will be pushed back to your fork with appropriate `LF` endings.

2. Modify your global `.gitconfig` file to disable the Windows behavior of `autocrlf` entirely.

  Edit the global `.gitconfig` file, find the line:
  ```
  autocrlf = true
  ```
  and change it to
  ```
  autocrlf = false
  ```
  Remove and clone again. This will prevent Windows git clients from automatically replacing Unix line endings LF with Windows line endings CRLF.

## Sponsors

* UPEI
* discoverygarden inc.
* LYRASIS
* McMaster University
* University of Limerick
* York University
* University of Manitoba
* Simon Fraser University
* PALS
* American Philosophical Society
* Common Media Inc.

## Maintainers

* [Nick Ruest](https://github.com/ruebot)

## Development

If you would like to contribute, please get involved by attending our weekly [Tech Call](https://github.com/Islandora-CLAW/CLAW/wiki). We love to hear from you!

If you would like to contribute code to the project, you need to be covered by an Islandora Foundation [Contributor License Agreement](http://islandora.ca/sites/default/files/islandora_cla.pdf) or [Corporate Contributor Licencse Agreement](http://islandora.ca/sites/default/files/islandora_ccla.pdf). Please see the [Contributors](http://islandora.ca/resources/contributors) pages on Islandora.ca for more information.
