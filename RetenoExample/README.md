# Project Info

## Project setup

On first project setup need to perform `./scripts/setup.sh` with base setup commands. More information about it described below in **Gem dependecies**. 

## Project base overview

#### Project is divided into frameworks:

- `ProjectTemplate` - project itself. It contains all user flows, screens in flows (ViewControllers and active Models) and related resources (assets, localized string, fonts...).
- `UI` - UI related framework. It contains layout code of all views in app and related resources (localized string, fonts...)
- `Core` - framework for core logic of app. It contains data passive models, structures stored in DB and app's services.

#### Resources
All resources (colors, strings, images, fonts) should be generated via *SwiftGen* (https://github.com/SwiftGen/SwiftGen) to avoid usage of non-safe strings approach. It's integrated as cocoapod. Script for generation runs on each build to avoid non-existent resources usage. Generated resources are located in the `.../Resources/SwiftGen` directory (for each target - UI or ProjectTemplate).

To generate new resources, it's needed to switch to the `Swiftgen` target and build it.

#### Code styles
We use *SwiftLint* to support common code styles for better code reading. https://github.com/realm/SwiftLint.

#### Application Environments
Application's environments are needed to separate development, testing and release builds delivery.

Project has 3 environments: `Development`, `Staging`, `Release`, so application can be built with different environment configurations.

More about environments [here](docs/environments.md).

## Gem dependecies

To enforce version consistency for Ruby gem dependencies in project, all gems should be integrated and managed through the Bundler - https://bundler.io.

[Usage guide](docs/gem_dependencies.md).

## Architecture

We use modular approach as project's architecture: application is divided into logical flows (modules).
For screens and views in flows we use MVC or MVVM  patterns where it's necessary.

[Review architecture](docs/architecture.md)

## UI development

All screens (`UIViewController`s) and views (`UIView`s) are **code-based**. There is **NO nib files (`.storyboard`s or `.xib`s)** in the project! UI is done via code.

Read more about [UI development and layout](docs/ui_development.md).

## Database collaboration

All DB collaboration incapsulated in the `Core` framework. [More information](docs/db_development.md).

## DevTools

For more convenient debugging and testing, we have implemented ability to add development utilities in the project.

How to use existing utilities it or add new utility read [here](docs/dev_tools.md)
