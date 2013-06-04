# Chef

* Documentation: [http://docs.opscode.com](http://docs.opscode.com)
* Source: [http://github.com/opscode/chef/tree/master](http://github.com/opscode/chef/tree/master)
* Tickets/Issues: [http://tickets.opscode.com](http://tickets.opscode.com)
* IRC: `#chef` and `#chef-hacking` on Freenode
* Mailing list: [http://lists.opscode.com](http://lists.opscode.com)

Chef is a configuration management tool designed to bring automation to your
entire infrastructure.

The [Chef Wiki](http://wiki.opscode.com/display/chef/Home) is the definitive
source of user documentation.

This README focuses on developers who want to modify Chef source code. For
users who just want to run the latest and greatest Chef development version in
their environment, see the
[Installing Chef from HEAD](http://wiki.opscode.com/display/chef/Installing+Chef+from+HEAD)
page on the wiki.

## Contributing/Development

Before working on the code, if you plan to contribute your changes, you need to
read the
[Opscode Contributing document](http://wiki.opscode.com/display/chef/How+to+Contribute).

You will also need to set up the repository with the appropriate branches. We
document the process on the
[Working with Git](http://wiki.opscode.com/display/chef/Working+with+git) page
of the Chef wiki.

Once your repository is set up, you can start working on the code. We do use
TDD with RSpec, so you'll need to get a development environment running.

### Requirements

Ruby 1.8.7+ (As of 2012-05-25 Ruby 1.8.6 should still work, except for CHEF-2329.)

### Environment

In order to have a development environment where changes to the Chef code can
be tested, we'll need to install a few things after setting up the Git
repository.

#### Non-Gem Dependencies

Install these via your platform's preferred method; for example apt, yum,
ports, emerge, etc.

* [Git](http://git-scm.com/)
* GCC and C Standard Libraries, header files, etc. (i.e., build-essential on
debian/ubuntu)
* Ruby development package

#### Runtime Rubygem Dependencies

First you'll need [bundler](http://github.com/carlhuda/bundler) which can
be installed with a simple `gem install bundler`. Afterwords, do the following:

    bundle install

## Testing

We use RSpec for unit/spec tests. It is not necessary to start the development
environment to run the specs--they are completely standalone.

    rake spec

## Knife Configurations

Is needed insert these lines below on your knife.rb.

```
	chef_server_url          'http://chef.domain.com.br/'
	idkey                    'dbb7b294e78f1c47d4a10d160442fb6a276ea0eedd9ca7c7206731f29257b511' 
	git_repo                 '/home/user/chef-repo' 
	git_log                  '/tmp/chef/git.log'
```

## Nginx - VirtualHost

We use this part code on Nginx Virtualhost to force the Gem use. This Gem work with Git.

```
      
                location / {
                client_max_body_size 50m;
                # Block Knife Users
                #
                set $stateif "A";
                if ($request_method = POST) {
                        set $stateif "${stateif}POST";
                }
                if ($request_method = PUT) {
                        set $stateif "${stateif}PUT";
                }
                if ( $http_user_agent !~ "(Knife|Ruby)" ){
                        set $stateif "${stateif}AGENT";
                }
                if ( $http_idkey != "dbb7b294e78f1c47d4a10d160442fb6a276ea0eedd9ca7c7206731f29257b511" ){
                        set $stateif "${stateif}KEY";
                }
                if ($stateif = "APOSTAGENT") {
                        return 401;
                }
                if ($stateif = "APUTAGENT") {
                        return 401;
                }
                if ($stateif = "APOSTAGENTKEY") {
                        return 401;
                }
                if ($stateif = "APUTAGENTKEY") {
                        return 401;
                }

                proxy_set_header Host $host;
                proxy_pass http://chef-server-api;
                proxy_read_timeout 1800s;

        }

}

```


# License

Chef - A configuration management system

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | Adam Jacob (<adam@opscode.com>)
| **Copyright:**       | Copyright (c) 2008-2012 Opscode, Inc.
| **License:**         | Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
