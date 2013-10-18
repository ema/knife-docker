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
require 'chef/node'
require 'chef/api_client'

module ChefDocker
  class DockerDelete < Chef::Knife

    banner "knife docker delete CONTAINER_ID(s) (options)"

    option :_purge,
        :short => "-P",
        :long => "--purge",
        :boolean => true,
        :default => false,
        :description => "Destroy corresponding node and client on the Chef Server"

    def run
      if @name_args.length == 0
        ui.error("Please provide at least one container id")
        show_usage
        exit 1
      end

      running_containers = []

      `docker ps`.split(/\n/).each do |c|
        if c =~ /^[\d\w]{12}\s/
          running_containers.push c.split[0]
        end
      end

      @name_args.each do |name|
        unless running_containers.include? name
          ui.warn("Container #{name} does not exist")
          next
        end

        delete name
      end
    end

    def destroy_item(klass, name, type_name)
      begin
        object = klass.load(name)
        object.destroy
        ui.warn("Deleted #{type_name} #{name}")
      rescue Net::HTTPServerException
        ui.warn("Could not find a #{type_name} named #{name} to delete!")
      end
    end

    def delete(container)
      `docker stop #{container}`
      `docker rm #{container}`

      if config[:_purge]
        destroy_item(Chef::Node, container, "node")
        destroy_item(Chef::ApiClient, container, "client")
      end
    end
  end
end
