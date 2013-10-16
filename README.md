# Knife Docker

## Description
A [knife] (http://docs.opscode.com/knife.html) plugin to create and delete
[Docker] (http://docker.io) containers to be managed by Chef.

## Installation
Make sure you are running Chef, which can be installed via:

    gem install chef

This plugin is distributed as a Ruby Gem. To install it, run:

    gem install knife-docker
    
Depending on your system's configuration, you may need to run this command
with root/administrator privileges.

## Prerequisites
You need to be able to create/list/stop Docker containers. Please see 
[the Docker documentation] (https://www.docker.io/gettingstarted/) for more information. 

knife-docker bootstraps your Docker containers via ssh. Make sure the Docker
image you are using has the ssh daemon installed, and that you are able to
login:
      
    id=$(docker run -d -p 22 $IMAGE /usr/sbin/sshd -D)
    port=$(docker port $id 22)
    ssh root@localhost -p $port

## Examples
      # Create and bootstrap a Debian container over ssh
      $ knife docker create -I emarocca/wheezy

      # Create a Debian container, bootstrap it, and apply the specified roles/recipes
      $ knife docker create -I emarocca/wheezy -r 'recipe[postgresql::server]'

      # Delete a container with id 3ebc494961fa and purge it from the Chef server
      $ knife docker delete 3ebc494961fa --purge

Use the --help option to read more about each subcommand. Eg:

    knife docker create --help
