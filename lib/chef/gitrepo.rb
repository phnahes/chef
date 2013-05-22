#
# Author:: Valter Douglas 'GigaNERDs' Lisboa Junior (<vdlisboa@gmail.com>)
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

require 'git'

class Chef
  class GitRepo
    
    # Repository constants
    REMOTE = 'origin'
    BRANCH = 'master'
    AUTO_MERGE_MSG = 'knife is doing auto-merging from origin'

    # Log constants
    LOG_ROTATE = 3
    ROTATE_SIZE = 1024000

    # User interface
    attr_accessor :ui

    # Git repository
    attr_accessor :git

    # Initialize the internal classes attributes
    # - log_file The log_file to save git messages. If not given log to STDOUT.
    def initialize(log_file = nil)
      @ui = Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})

      logger = nil
      if log_file.nil?
        logger = Logger.new(STDOUT)
      else
        logger = Logger.new(
                  open(log_file, 
                    File::WRONLY | File::APPEND | File::CREAT), 
                    LOG_ROTATE, 
                    ROTATE_SIZE
                  )
      end
      
      @git = Git.open(Chef::Config[:git_repo], :log => logger)
      
    end

    # Sync local repo with remote
    def pull
      ui.info("Pulling from origin")
      git.pull(REMOTE, [ REMOTE, BRANCH ], AUTO_MERGE_MSG)
    end

    # Send cookbooks to remote repo
    # - cbs Hash of cookbooks to sync
    # - commit_msg Commit message
    def push_cookbooks(cbs, commit_msg)
      ui.info("Applying your repository changes")
      Dir.chdir(Chef::Config[:git_repo]) do
        cbs.each do |cbname, cb|
          ui.info("- cookbook #{cbname} ")
          git.add("cookbooks/#{cbname}")
        end
        push(commit_msg)
      end
    end

    # Send list of files to remote repo
    # This is used by from files subcommands
    # - files Array of files to sent
    # - commit_msg Commit message
    # - type A string of the file type to send (role,environment or data bag)
    def push_files(files, commit_msg, type)
      ui.info("Applying your repository changes")
      Dir.chdir(Chef::Config[:git_repo]) do
        files.each do |file|
          ui.info("- #{type} #{file} ")
          git.add("#{file}")
        end
        push(commit_msg)
      end
    end

    private

    # commit and push the modifications
    # - commit_msg Commit message
    def push(commit_msg)
      begin
        ui.info("Committing with message: #{commit_msg}")
        git.commit(commit_msg)
        ui.info("Pushing changes")
        git.push()
      rescue Git::GitExecuteError => e
        if(e.message.include? "Your branch is ahead of 'origin/master' by ")
          ui.info("Your local repo is ahead from git remote repository! Correcting situation...")
          git.push()
        else
          raise e
        end
      end
    end

  end
end

