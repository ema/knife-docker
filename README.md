# Knife Docker

## Description
knife-docker makes it easy to test your Chef cookbooks against a clean system.
It is a [knife] (http://docs.opscode.com/knife.html) plugin to create and
delete [Docker] (http://docker.io) containers managed by Chef.

Used together with [chef-zero] (https://github.com/opscode/chef-zero),
knife-docker is a great way to get started with Chef.

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

knife-docker bootstraps your Docker containers via SSH. Thus, you need to use a Docker image with the SSH daemon installed and your public key in root's authorized_keys. The easiest way to ensure this prerequisite is met is using [the Dockerfile we provide] (https://github.com/ema/knife-docker/blob/master/Dockerfile). You should modify it to make sure your SSH public key is included in the resulting image.

    # Add your SSH key to Dockerfile
    $ vim Dockerfile

    # Build a Docker container image called 'knife-docker-debian'
    $ docker build -t knife-docker-debian .

## Examples
      # Create and bootstrap a Debian container over ssh
      $ knife docker create -I knife-docker-debian

      # If using boot2docker (i.e. running docker + knife under os x)
      $ knife docker create -I knife-docker-debian -b

      # Create a Debian container, bootstrap it, and apply the specified roles/recipes
      $ knife docker create -I knife-docker-debian -r 'recipe[postgresql::server]'

      # Delete a container with id 3ebc494961fa and purge it from the Chef server
      $ knife docker delete 3ebc494961fa --purge

Use the --help option to read more about each subcommand. Eg:

    knife docker create --help
