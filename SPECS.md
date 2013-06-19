# Specs

## mysv

### Models [implemented]

#### `Design`

| Field          | Type     |
| -------------- | -------- |
| name           | String   |
| price          | Integer  |
| availability   | String   |
| required_stage | String   |
| public_at      | Datetime |

#### `AddonPlanSettings`

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

### Workers

* `PlayerFilesGeneratorWorker` (no-op, delegated to `plsv`)

### Private APIs [implemented]

* `/private_api/sites/:token/addons?state=subscribed`
* `/private_api/sites/:token/kits`

### Workflow

* Each time a site is saved or its kits settings are saved, invokes
  `PlayerFilesGeneratorWorker` (plsv) with the `:settings` param.
* Each time a site's addons are saved, invokes `PlayerFilesGeneratorWorker` (plsv)
  with the `:addons` param.
* When a site is archived, invokes `PlayerFilesGeneratorWorker` (plsv)
  with the `:destroy` param.

## plsv

### Models

#### `Package`

| Field           | Type           |
| --------------- | -------------- |
| name            | String         |
| version         | String         |
| dependencies    | Text (Array)   |
| settings        | Text (Hash)    |

#### `AppBundle`

| Field            | Type           |
| --------------   | -------------- |
| token            | String         |

#### `AppBundlesPackages`

| Field            | Type           |
| ---------------- | -------------- |
| app_bundle_id    | Integer        |
| package_id       | Integer        |

#### `Loader`

| Field            | Type           |
| --------------   | -------------- |
| site_token       | String         |
| app_bundle_id    | Integer        |

### Definitions

#### Package

Zip file that contains one or several JS files and assets and which has
dependencies (declared in a `package.json` file) on other packages.

##### Structure

```
- classic-player-controls
   +- addons_settings
   |  +- controls.rb
   +- assets
   |  +- play.png
   `- package.json
   `- main.js
```

Generated settings from this package would be:

```
classic-player-controls: {
  controls: { ... }
}
```


```
- sony-player
   +- addons_settings
   |  +- controls.rb
   |  +- subtitles.rb
   `- package.json
   `- main.js
```

Generated settings from this package would be:

```
sony-player: {
  controls: { ... },
  subtitles: { ... }
}
```

#### App

A JS file that is the concatenation of all the packages needed by a site.

#### Loader

A JS file that contains the URL to the App JS file. The URL contains app-<bundle_token>.js.

#### Settings

A JS file that contains the settings

#### Template

A template JS file containing some code that is common to all generated files.
For instance, there is a loader template and an app template.

[FIXME] The app template, loader template and settings templates are "special" packages
that depends on some packages or none.

* [FIXME] The app template must be put at the top of the app file;
* The loader template must be interpolated with Ruby variables and put in the
  final loader file.
* The settings template must be interpolated with Ruby variables and put in the
  final settings file.

[FIXME] All 3 packages are included in the packages array used to generate the App bundle token (a MD5).

### Workers

* `PlayerFilesGeneratorWorker`
* `AppFileGeneratorWorker`
* `LoaderFileGeneratorWorker`
* `SettingsFileGeneratorWorker`

### Services

* `AppFileGenerator`
* `LoaderFileGenerator`
* `SettingsFileGenerator`

### Design + Addon => Package map

A map will link a design + addon to a package, i.e.:

| Design          | Addon           | Package                  |
| --------------  | --------------- | ------------------------ |
| classic         | controls        | classic-player-controls  |
| flat            | controls        | floating-player-controls |
| sony            | controls        | sony-player              |
| sony            | lightbox        | sony-player              |

Typically, custom players will have only one package.

### Workflow

#### New package upload

* The app will expose an API / UI for the player team to upload new packages.
* Each time a new package version is uploaded, the `PlayerFilesGeneratorWorker`
  worker will be invoked.
* The zip file is uploaded to S3. Dependencies & settings are stored in the DB.

TBD: We should maybe namespace the assets under their package name. e.g.:

* `/a/<bundle_token>/classic-player-controls/play.png`
* `/a/<bundle_token>/floating-player-controls/play.png`

#### PlayerFilesGeneratorWorker

This worker delegates to several workers depending on the event passed to it:

* `SettingsFileGenerator` when event is `:settings`
* `AppFileGeneratorWorker` when event is `:addons`
* `LoaderFileGeneratorWorker` & `SettingsFileGenerator` when event is `:destroy`

#### AppBundle

When an new `AppBundle` is created, it uploads all the assets files of the
associated packages to `/a/<bundle_token>/`.

#### AppFileGenerator

1. From the list of site's add-ons and designs (from kits), it gets the list of
  packages (from the mapping table `design + add-on -> package name`).
2. From the list of packages names, it generatess a `bundle_token` (a MD5) for
  this array of packages (sorted).
3. It check if an `AppBundle` exists fot this `bundle_token`.
    * If yes, returns the `bundle_token`, the app bundle already exists!
    * If no, concatenate all the packages `main.js` files and insert them in a
      template! It creates a new `AppBundle` record for the `bundle_token`. The
      file is then uploaded to `/js/app-<bundle_token>.js` and return the `bundle_token`.

#### LoaderFileGenerator

1. Insert the `bundle_token` from the app generation step into the loader
  template and upload it.

#### SettingsFileGenerator

1. It find the site's current `Loader`.
2. From the loader record, it gets its list of packages.
3. From the list of site's add-ons and designs (from kits), it gets the list of
  packages (from the mapping table `design + add-on -> package name`).
    1. For each package, it gets the bundled version from the packages list from 2.
    2. It then merges the package settings with the kit's settings.
4. It populates the template with the full settings hash (e.g. `{ '1': { design: 'flat',
  settings: { ... } } }`).
5. It then uploads the file to `/s3/<token>.js`.

### Notes

* The path for the new settings file will be `/s3` to ensure a smooth transition
  from the old to the new settings.
