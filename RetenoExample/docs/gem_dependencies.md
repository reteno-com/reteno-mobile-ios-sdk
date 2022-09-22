# Gem dependecies management

All gems should be integrated and managed through the Bundler - https://bundler.io

### Usage tips:

- On first project setup need to perform `./scripts/setup.sh` with base setup commands, it contains Gem dependencies setup
- To integrate new gem dependency need to add it to the *Gemfile* with specified version
- To run an executable that comes with a gem dependency: `bundle exec gem_dependency_command`