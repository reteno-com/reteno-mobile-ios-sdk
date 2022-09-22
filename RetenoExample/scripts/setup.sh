#!/bin/bash

echo "Setting up the project ..."

if ! [ -x "$(command -v bundle)" ]; then
	echo "Installing Bundler - dependencies manager..."

	if [ -x "$(command -v rbenv)" ] || [ -x "$(command -v rvm)" ]; then		
		gem install bundler
	else
		echo "Installing Bundler to the default gem directory..."
		sudo gem install bundler
	fi
fi

echo "Installing dependencies through Bundler..."
bundle install --without ci

echo "Installing pods..."
bundle exec pod install --repo-update

echo "All good, use bundle \"exec { dependency_command } from here\""
