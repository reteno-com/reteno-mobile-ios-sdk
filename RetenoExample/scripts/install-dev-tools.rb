require 'xcodeproj'

def pod_dev_tools(legacy_gitlab: false, configs: ['Debug', 'Staging-Debug', 'Release', 'Staging-Release'])
  host = legacy_gitlab ? "https://git.yalantis.com/" : "git@gitlab.yalantis.com:"

  pod 'BuildInfo', :configurations => configs, :git => "#{host}ios-solutions/BuildInfo.git"
  pod 'YALLeaksTracker', :configurations => configs, :git => "#{host}ios-solutions/LeaksTracker.git"
end

def install_dev_tools(installer)
  # Options for LeaksTracker. Pass 1 to enable and 0 to disable
  leaks_tracker_settings = 'LT_TRACKING_ENABLED=1 LT_PRINT_DEBUG=1 LT_SHOW_ALERT=1 LT_MAKE_SNAPSHOT=1 LT_VIBRATE=1'

  installer.pods_project.targets.each do |target|
      if target.name == "YALLeaksTracker"
          puts "Updating #{target.name} GCC_PREPROCESSOR_DEFINITIONS"

          target.build_configurations.each do |config|
              base_config_ref = config.base_configuration_reference

              if base_config_ref != nil then
                base_config = Xcodeproj::Config.new(base_config_ref.real_path)

                config_extras = Xcodeproj::Config.new({
                  'GCC_PREPROCESSOR_DEFINITIONS' => leaks_tracker_settings
                })
                # Appending custom GCC_PREPROCESSOR_DEFINITIONS to base config
                # Saving it to the original file
                base_config.merge(config_extras).save_as(base_config_ref.real_path)
              end
          end
      end
  end
end
