# Specs

## mysv

### Models

#### `Design`

| Field          | Type     |
| -------------- | -------- |
| name           | String   |
| price          | Integer  |
| availability   | String   |
| required_stage | String   |
| public_at      | Datetime |

#### `Addon`

| Field             | Type     |
| ----------------- | -------- |
| category          | String   |
| name              | String   |
| price             | Integer  |
| availability      | String   |
| required_stage    | String   |
| public_at         | Datetime |

#### `AddonSettings`

| Field     | Type          |
| --------- | ------------- |
| addon_id  | Integer       |
| design_id | Integer       |
| template  | String (Hash) |

#### `Kit`

| Field     | Type          |
| --------- | ------------- |
| design_id | Integer       |
| settings  | String (Hash) |

### Workflow

* Each time a site is saved, invokes `SiteComponentsGeneratorWorker` (plsv).
* Each time a site's kit is saved, invokes `SiteComponentsGeneratorWorker` (plsv).

## plsv

### Models

#### `Package`

| Field           | Type           |
| --------------- | -------------- |
| name            | String         |
| version         | String         |
| dependencies    | Text (Array)   |
| settings        | Text (Hash)    |

#### `AppMd5`

| Field            | Type           |
| --------------   | -------------- |
| md5              | String         |

#### `AppMd5sPackages`

| Field            | Type           |
| ---------------- | -------------- |
| app_md5_id       | Integer        |
| package_id       | Integer        |

#### `Loader`

| Field            | Type           |
| --------------   | -------------- |
| site_token       | String         |
| app_md5_id       | Integer        |

#### `LoaderTemplate`

| Field            | Type           |
| --------------   | -------------- |
| stage            | String         |
| template         | Text           |

### Definitions

#### Package

Zip file that contains one or several JS files and assets and which has
dependencies (declared in a `package.json` file) on other packages.

#### App

A JS file that is the concatenation of all the packages needed by a site.

#### Loader

A JS file that contains the URL to the App JS file. The URL contains a MD5 of the packages + versions bundled in the file.

#### Template

A template JS file containing some code that is common to all generated files.
For instance, there is a loader template and an app template.

### Workers

* `SiteComponentsGeneratorWorker`

### Services

* `AppFileGenerator`
* `LoaderFileGenerator`
* `SettingsFileGenerator`

### Workflow

#### New package upload

The app will expose an API / UI for the player team to upload new package
versions. Each time a new package version is uploaded, the
`SiteComponentsGeneratorWorker` worker will be invoked.

#### Site components generator worker `SiteComponentsGeneratorWorker`

This worker generates several JS files for a site in the following order:

1. App file & Settings file (can be done in parallel)
2. Loader file (can only be done once the app file is generated / checked)

#### App file generation `AppFileGenerator`

1. `plsv` calls `mysv` to get the list of the site' subscribed add-ons.
2. From this list of add-ons, it gets the list of packages (from the mapping
  table `add-on -> packages`).
3. From the list of packages, it resolve the dependency tree and ends up with a
  list of package versions.
4. It then generates a MD5 for this list of package versions (sorted).
5. It check if an AppMD5 exists fot this MD5.
    * If yes, simply use the existing file and the md5.
    * If no, concatenate all the package versions content and insert them
      in a blank file with the "header" package first! Then upload the file
      to `/js/app-<md5>.js` and return the md5.

#### Loader generation

1. Insert the md5 from the app generation step into the loader template.

#### Settings generation

1. `plsv` calls `mysv` to get the list of the site' subscribed add-on plans.
2. `plsv` calls `mysv` to get the list of the site's kits.
3. It inserts the list of kit design + settings (`{ '1': { design: 'flat',
  settings: { ... } } }`) in the settings template. It also insert the default
  settings for the add-on plan if these settings are specific for this design.
4. From this list of add-on plans, it gets the list of default settings not
  specific to a design and insert them in the settings template.
5. It then upload the file to `/s2/<token>.js`.

### Notes

* The new settings will list only once the default values for each add-on
(instead) of listing them per kit.
* The path for the new settings file will be `/s2` to ensure a smooth transition
from the old to the new settings.
