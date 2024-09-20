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

For example, to switch to v3.5.1, use:

```bash
$ git checkout v3.5.1
```

1.4) Retrieve the ArchivesSpace Docker images:

```bash
$ docker-compose -f docker-compose-dev.yml build
```

1.5) Run MySQL and Solr in the background:

```bash
$ docker-compose -f docker-compose-dev.yml up --detach
```

1.6) Download the MySQL connector:

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
     [java] Retrying fetcher due to error (2/4): NameError uninitialized constant Dir::FileUtils
     [java] Fetching gem metadata from https://rubygems.org/.
     [java] Retrying fetcher due to error (3/4): NameError uninitialized constant Dir::FileUtils
     [java] Retrying fetcher due to error (4/4): NameError uninitialized constant Dir::FileUtils
```

I was able to get the command to work using Java 8, specifically:

```bash
$ java -version
java version "1.8.0_301"
Java(TM) SE Runtime Environment (build 1.8.0_301-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.301-b09, mixed mode)
```

---

---

**Note:** This command will occasionally fail with an error message similar to:

```text
     [java] NameError: uninitialized constant Gem::Installer::FileUtils
     [java] An error occurred while installing clipboard-rails (1.7.1), and Bundler cannot
     [java] continue.
```

It is unclear why this error occurs, but it appears to be intermittent, and
re-running the command will usually work (may take several tries, sometimes 5 or
6, usually making progress and failing differently each time).

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

## 2. ArchivesSpace UMD Plugins Setup

---

**Note:**  Running a stock ArchivesSpace

If at this point you just want to run a stock ArchivesSpace, without any UMD
customizations, skip this step, and go directly to Step 3.

---

2.1) In a separate terminal, switch to the "plugins" subdirectory:

```bash
$ cd plugins
```

2.2) Clone the following Git repositories:

* AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin
  (<https://github.com/AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin>) -
  Should be cloned into an "aeon_fulfillment" directory
* umd-libaspace_yale_accessions (<https://github.com/umd-lib/aspace_yale_accessions>)
* umd-lib/umd_aeon_fulfillment (<https://github.com/umd-lib/umd_aeon_fulfillment>)
* umd-lib/umd-lib-aspace-theme (<https://github.com/umd-lib/umd-lib-aspace-theme>)

```bash
$ git clone https://github.com/AtlasSystems/ArchivesSpace-Aeon-Fulfillment-Plugin.git aeon_fulfillment

# Checkout the aeon_fulfillment tag specified in docker_config/archivesspace/config/plugins
$ cd aeon_fulfillment
$ git checkout 20180726
$ cd ..

$ git clone git@github.com:umd-lib/aspace_yale_accessions.git
$ git clone git@github.com:umd-lib/umd_aeon_fulfillment.git
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

adding the following lines (drawn from
<https://github.com/umd-lib/aspace-custom/blob/main/docker_config/archivesspace/archivesspace/config/config.rb>):

```ruby
AppConfig[:plugins] << 'aspace_yale_accessions'
AppConfig[:plugins] << 'umd-lib-aspace-theme'
AppConfig[:public_theme] = 'umd-lib-aspace-theme'

unless ENV['DISABLE_AEON_REQUEST'] == 'true'
  AppConfig[:plugins] << 'aeon_fulfillment' << 'umd_aeon_fulfillment'
  AppConfig[:aeon_fulfillment] = {
    'umd_test' => {
      request_in_new_tab: true,
      requests_permitted_for_containers_only: true,
      aeon_web_url: 'https://aeon.lib.umd.edu/logon/',
      aeon_return_link_label: 'UMD Archives',
      aeon_site_code: 'TEST'
    }
  }
end

AppConfig[:pui_enable_staff_link] = false

AppConfig[:pui_page_actions_request] = false

AppConfig[:pui_hide][:accessions] = true
AppConfig[:pui_hide][:classifications] = true
AppConfig[:pui_hide][:subjects] = true
AppConfig[:pui_hide][:agents] = true
AppConfig[:pui_hide][:search_tab] = true
```

This loads and configures various UMD-customized plugins, including:

* Sets the "theme" to use the "umd-lib-aspace-theme" plugin in the front-end
  (staff) and public interfaces.
* Configures the "aeon_fulfillment"/"umd_aeon_fulfillment" plugins for the
  "UMD_TEST" repository (created below), and hides some of the navigation bar
  items.
* Adds the "umd-lib/aspace_yale_accessions" plugin for handling
  "Department Codes" in the front-end (staff) interface, and configuring the
  "Identifier" field for accessions and resources.

This configuration does not include all the plugins used on the server. To see
a list of all the plugins (and their versions) used on the servers, see
the "[docker_config/archivesspace/config/plugins][aspace-custom-plugins]" file
in the "[umd-lib/aspace-custom][aspace-custom]" GitHub repository.

To match what is configured on the servers, see
<https://github.com/umd-lib/aspace-custom/blob/main/docker_config/archivesspace/archivesspace/config/config.rb>.

## 3. Run ArchivesSpace

3.1) Setup the development database:

```bash
$ ./build/run db:migrate
```

3.2) Clear out any existing Solr state:

```bash
$ ./build/run solr:reset
```

3.3) In separate terminals, run the following commands:

```bash
term1$ build/run backend:devserver

term2$ build/run frontend:devserver

term3$ build/run public:devserver

term4$ build/run indexer
```

3.4) Verify that the front-end staff interface is running by going to
<http://localhost:3000/>.

If you are running a stock ArchivesSpace, you can sign in using "admin" as the
username, and "admin" as the password.

3.5) Verify that the front-end public interface is running by going to
<http://localhost:3001/>.

3.6) Verify that a Solr instance is running at <http://localhost:8983/>.

## 4. Sample Data

### Loading EAD Sample Data

Sample data files are in the "docs/resources/ead" folder:

* 0251.UA_20181203_205932_UTC__ead.xml
* 0073.LIT_20171121_141039_UTC__ead.xml
* 0057.LIT_20171121_135754_UTC__ead.xml

4.1) Log in to the front-end staff interface (<http://localhost:3000/>).

4.2) Create a new repository by selecting "System | Manage Repositories" in the
navigation bar, and then left-clicking the "Create Repository" button in the
resulting page. The "New Repository" form will be displayed.

4.3) On the "New Repository" form, fill out the following fields:

| Field                 | Value |
| ----------------------| ----- |
| Repository Short Name | UMD_TEST |
| Repository Name       | UMD Test Repository |
| Publish?              | \<Checked> |

then left-click the "Save Repository" button. The page should refresh indicating
that the repository was created.

4.4) In the navigation bar, left-click the "Select Repository" drop-down, select
the "UMD_TEST" repository, and left-click the "Select Repository" button. The
page will refresh and indicate that the "UMD_TEST" repository is now active.

4.5) In the application menubar, select "Create | Background Job | Import Data".
The "New Background Job - Import Data" form will be displayed.

4.6) In the "New Background Job - Import Data" form, select "EAD" in the
"Import Type" dropdown. Then, using the "Add file" button, select the EAD files
to upload. Left-click the "Start Job" button. The "Import Job" page will be
displayed.

4.7) Once the job has completed, the "Amoss, William L. papers" collection
will be published, but the other two collection will be unpublished:

* Archives of the Atlantic Monthly
* Louis Auchincloss papers

To publish these collections, for each unpublished collection:

4.7.1) Select "Browse | Resources". The "Resources" page will be displayed.

4.7.2) Select the "Edit" button for an unpublished collection, then on the
resulting page, left-click the "Publish All" button, and then select
"Publish All" in the confirmation dialog.

4.8) Go to the front-end public interface (<http://localhost:3001/>). Left-click
the "Libraries" link on the application home page. The resulting page should
display the "UMD Test Repository", and indicate that it has 3 collections.

### Resetting the Sample Data

---

**WARNING** This command will destroy all the data, so should obviously only be
run on development systems that aren't connected to an actual database.

---

From <https://archivesspace.github.io/tech-docs/development/dev.html>:

> There is a task for resetting the database:
>
> ```bash
> $ ./build/run db:nuke
> ```
>
> Which will first delete then migrate the database.

Note that this should be followed by commands to reload the "accessibility.sql"
sample date, reset the Solr database, and re-run the database migrations:

```zsh
$ docker exec -it as_dev_db /bin/bash -c \
    'gzip -dc /tmp/accessibility.sql.gz | \
    mysql --host=127.0.0.1 --port=3306  -u root -p123456 archivesspace'
$ ./build/run solr:reset
$ ./build/run db:migrate
```

---
[aspace-custom]: https://github.com/umd-lib/aspace-custom
[aspace-custom-plugins]: https://github.com/umd-lib/aspace-custom/blob/main/docker_config/archivesspace/config/plugins
