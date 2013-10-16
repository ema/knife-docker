#
# Author:: Emanuele Rocca (<ema@linux.it>)
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife'

module ChefDocker
  class DockerCreate < Chef::Knife

    deps do
      require 'chef/knife/bootstrap'
      Chef::Knife::Bootstrap.load_deps
    end

    banner "knife docker create (options)"
    
    option :_image,
      :short => "-I IMAGE",
      :long => "--image IMAGE",
      :description => "The Docker container image to use"

    option :chef_node_name,
      :short => "-N NAME",
      :long => "--node-name NAME",
      :description => "The Chef node name for your new node"

    option :ssh_user,
      :short => "-x USERNAME",
      :long => "--ssh-user USERNAME",
      :description => "The ssh username",
      :default => 'root'

    option :ssh_password,
      :short => "-P PASSWORD",
      :long => "--ssh-password PASSWORD",
      :description => "The ssh password"

    option :ssh_port,
      :long => "--ssh-port PORT",
      :description => "The ssh port. Default is 22",
      :default => '22'

    option :distro,
      :short => "-d DISTRO",
      :long => "--distro DISTRO",
      :description => "Bootstrap a distro using a template",
      :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
      :default => "chef-full"

    option :template_file,
      :long => "--template-file TEMPLATE",
      :description => "Full path to location of template to use",
      :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
      :default => false

    option :run_list,
      :short => "-r RUN_LIST",
      :long => "--run-list RUN_LIST",
      :description => "Comma separated list of roles/recipes to apply",
      :proc => lambda { |o| o.split(/[\s,]+/) },
      :default => []

    option :identity_file,
      :short => "-i IDENTITY_FILE",
      :long => "--identity IDENTITY_FILE",
      :description => "SSH identity file for authentication"

    def locate_config_value(key)
      key = key.to_sym
      config[key] || Chef::Config[:knife][key]
    end

    def run
      unless config[:_image]
        ui.error("Please provide a valid Docker container image (-I)")
        show_usage
        exit 1
      end

      # start a new container with sshd
      id = `docker run -d -p #{config[:ssh_port]} #{config[:_image]} /usr/sbin/sshd -D`

      unless $?.exitstatus == 0
        ui.error("Cannot create container")
        exit 1
      end

      # get container IP
      container_info = `docker inspect #{id}`
      ip = container_info.match(/"IPAddress": "(?<ip>[\d\.]+)"/)['ip']

      # containers boot *very* fast, but it might happen that we try to
      # bootstrap before SSH is up. Let's wait a second.
      sleep 1

      bootstrap_container(ip, id.rstrip).run
    end

    def bootstrap_container(fqdn, id)
      bootstrap = Chef::Knife::Bootstrap.new
      bootstrap.name_args = [fqdn]
      bootstrap.config[:run_list] = config[:run_list]
      bootstrap.config[:ssh_user] = locate_config_value(:ssh_user)
      bootstrap.config[:ssh_password] = locate_config_value(:ssh_password)
      bootstrap.config[:ssh_port] = config[:ssh_port]
      bootstrap.config[:identity_file] = config[:identity_file]
      bootstrap.config[:chef_node_name] = config[:chef_node_name] || id
      bootstrap.config[:bootstrap_version] = config[:bootstrap_version]
      bootstrap.config[:distro] = locate_config_value(:distro)
      bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
      bootstrap.config[:use_sudo_password] = true if bootstrap.config[:use_sudo]
      bootstrap.config[:template_file] = locate_config_value(:template_file)
      bootstrap.config[:environment] = locate_config_value(:environment)

      bootstrap
    end
  end
end
