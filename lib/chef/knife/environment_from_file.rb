#
# Author:: Stephen Delano (<stephen@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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

class Chef
  class Knife
    class EnvironmentFromFile < Knife

      deps do
        require 'chef/environment'
        require 'chef/knife/core/object_loader'
      end

      attr_accessor :git

      banner "knife environment from file FILE [FILE..] (options)"

      option :all,
      :short => "-a",
      :long  => "--all",
      :description => "Upload all environments"

      option :commit,
        :short => "-m",
        :long => "--commit MSG",
        :description => "Git commit message",
        :default => nil,
        :required => true

      def loader
        @loader ||= Knife::Core::ObjectLoader.new(Chef::Environment, ui)
      end

      def environments_path
        @environments_path ||= "environments"
      end

      def find_all_environments
        loader.find_all_objects("./#{environments_path}/")
      end

      def load_all_environments
        environments = find_all_environments
        if environments.empty?
          ui.fatal("Unable to find any environment files in '#{environments_path}'")
          exit(1)
        end

        # push changes before upload
        git.push_files(environments, config[:commit], "environment")

        # upload environments
        environments.each do |env|
          load_environment(env)
        end
      end

      def load_environment(env)
        updated = loader.load_from("environments", env)
        updated.save
        output(format_for_display(updated)) if config[:print_after]
        ui.info("Updated Environment #{updated.name}")
      end

      def run
        # Initialize git and ensure the local repo is synced
        @git = Chef::GitRepo.new(Chef::Config[:git_log])
        git.pull

        if config[:all] == true
          load_all_environments
        else
          if @name_args[0].nil?
            show_usage
            ui.fatal("You must specify a file to load")
            exit 1
          end
  
          # push changes before upload
          git.push_files(@name_args, config[:commit], "en")

          # upload environments
          @name_args.each do |arg|
            load_environment(arg)
          end
        end
      end
    end
  end
end
