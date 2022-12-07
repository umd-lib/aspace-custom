# Development Setup

## Introduction

This page describes how to set up a local ArchivesSpace development environment,
and other information useful for developers to be aware of.

See <https://archivesspace.github.io/tech-docs/development/dev.html> for the
official ArchivesSpace development environment setup instructions.

This document is designed to support ArchivesSpace v3.0 and later. For earlier
versions of ArchivesSpace see
<https://confluence.umd.edu/display/LIB/ArchivesSpace+Development+Environment>.

## 1) Stock ArchivesSpace Setup

1.1) Clone the "archivesspace/archivesspace" GitHub repository (<https://github.com/archivesspace/archivesspace>):

```bash
$ git clone https://github.com/archivesspace/archivesspace.git
```

1.2) Switch into the "archivesspace" directory:

```bash
$ cd archivesspace
```

1.3) Checkout the ArchivesSpace version to use in development, where
     <VERSION_TAG> is the Git tag for the version to use:

```bash
$ git checkout <VERSION_TAG>
```

For example, to switch to v3.3.1, use:

```bash
$ git checkout v3.3.1
```

1.4) Retrieve the ArchivesSpace Docker images:

```bash
$ docker-compose -f docker-compose-dev.yml build
```

1.5) Run MySQL and Solr in the background:

```bash
$ docker-compose -f docker-compose-dev.yml up --detach
```

1.6) Download the MySQL connection:

```bash
$ cd ./common/lib && wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.23/mysql-connector-java-8.0.23.jar && cd -
```

1.7) Download all application dependencies:

```bash
$ ./build/run bootstrap
```

---
**Note:**  On Apple Silicon, got the following error when using
OpenJDK v11.0.16.1:

```text
bundler:
     [echo] Fetching gems for ../backend/Gemfile
     [java] /Users/dsteelma/Junk4/aspace_template_fix/archivesspace/build/gems/gems/bundler-2.1.4/lib/bundler/vendor/net-http-persistent/lib/net/http/persistent.rb:203: warning: Process#getrlimit not supported on this platform
     [java] git version 2.38.0
     [java] warning: thread "Ruby-0-Thread-1: uri:classloader:/META-INF/jruby.home/lib/ruby/stdlib/open3.rb:200" terminated with exception (report_on_exception is true):
     [java] NotImplementedError: waitpid unsupported or native support failed to load; see https://github.com/jruby/jruby/wiki/Native-Libraries
     [java]   waitpid at org/jruby/RubyProcess.java:936
     [java] NotImplementedError: waitpid unsupported or native support failed to load; see https://github.com/jruby/jruby/wiki/Native-Libraries
     [java]   waitpid at org/jruby/RubyProcess.java:936
```

I was able to get the command to work using Java 8, specifically:

```bash
$ java -version
java version "1.8.0_301"
Java(TM) SE Runtime Environment (build 1.8.0_301-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.301-b09, mixed mode)
```

---

1.8) Load the dev database:

1.8.1) Copy the "./build/mysql_db_fixtures/accessibility.sql.gz" file to the
"as_dev_db" Docker container:

```bash
$ docker cp ./build/mysql_db_fixtures/accessibility.sql.gz as_dev_db:/tmp/
```

1.8.2) Extract the file into the MySQL client on "as_dev_db":

```bash
$ docker exec -it as_dev_db /bin/bash -c \
    'gzip -dc /tmp/accessibility.sql.gz | \
    mysql --host=127.0.0.1 --port=3306  -u root -p123456 archivesspace'
```

1.8.3) Setup the development database:

```bash
$ ./build/run db:migrate
```

1.8.4) Clear out any existing Solr state:

```bash
$ ./build/run solr:reset
```

1.9) In separate terminals, run the following commands:

```bash
term1$ build/run backend:devserver

term2$ build/run frontend:devserver

term3$ build/run public:devserver

term4$ build/run indexer
```

1.10) Verify that the front-end staff interface is running by going to
<http://localhost:3000/>. You can sign in using "admin" as the username, and
"admin" as the password.

1.11) Verify that the front-end public interface is running by going to
<http://localhost:3001/>.

1.12) Verify that a Solr instance is running at <http://localhost:8983/>.

## 2. ArchivesSpace UMD Plugins Setup

2.1) In a separate terminal, switch to the "plugins" subdirectory:

```bash
$ cd plugins
```

2.2) Clone the following Git repositories:

* AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin
  (<https://github.com/AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin>) -
  Should be cloned into an "aeon_fulfillment" directory
* umd-lib/umd_aeon_fulfillment (<https://github.com/umd-lib/umd_aeon_fulfillment>)
* umd-lib/umd-lib-aspace-theme (<https://github.com/umd-lib/umd-lib-aspace-theme>)

```bash
$ git clone https://github.com/AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin.git aeon_fulfillment
$ git clone https://github.com/umd-lib/umd_aeon_fulfillment.git
$ git clone git@github.com:umd-lib/umd-lib-aspace-theme.git
```

2.3) Switch back to the archivesspace root directory:

```bash
$ cd ..
```

2.4) Create or edit the "common/config/config.rb" file:

```bash
$ vi common/config/config.rb
```

adding the following lines (modified from https://bitbucket.org/umd-lib/aspace-env/src/master/archivesspace/config/config.rb):

```ruby
AppConfig[:plugins] << 'umd-lib-aspace-theme'
AppConfig[:public_theme] = 'umd-lib-aspace-theme'

unless ENV['DISABLE_AEON_REQUEST'] == 'true'
  AppConfig[:plugins] << 'aeon_fulfillment' << 'umd_aeon_fulfillment'
  AppConfig[:aeon_fulfillment] = {
    'test' => {
      requests_permitted_for_containers_only: true,
      aeon_web_url: 'https://aeon.lib.umd.edu/logon/',
      aeon_return_link_label: 'UMD Archives',
      aeon_site_code: 'TEST'
    }
  }
end

AppConfig[:pui_page_actions_request] = false

AppConfig[:pui_hide][:accessions] = true
AppConfig[:pui_hide][:classifications] = true
AppConfig[:pui_hide][:subjects] = true
AppConfig[:pui_hide][:agents] = true
AppConfig[:pui_hide][:search_tab] = true
```

This sets the "theme" to use the "umd-lib-aspace-theme" plugin, configures the
"aeon_fulfillment" plugin for the "TEST" repository (created below), and hides
some of the navigation bar items. To match what is configured on the servers,
see <https://github.com/umd-lib/aspace-custom/blob/main/docker_config/archivesspace/archivesspace/config/config.rb>.

2.5) In the terminal where the "public" front-end is running ("term3" from the
steps above), stop the application using "Ctrl-C", and build/run it again:

```bash
term3$ <Ctrl-C>
term3$ build/run public:devserver
```

2.6) Verify that the front-end public interface is running by going to
<http://localhost:3001/>. The public interface should now display UMD branding,
and a "local development" environment banner, indicating that it has picked up
the "umd-lib-aspace-theme" plugin.

At least for the "umd-lib-aspace-theme" plugin, changes can be made directly in
the "plugins/umd-lib-aspace-theme" directories, and ArchivesSpace will
immediately pick up the changes without having to be restarted.
