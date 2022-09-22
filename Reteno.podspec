Pod::Spec.new do |s|
  s.name         = 'Reteno'
  s.version      = '1.0.0'
  s.summary      = 'Will be filled later'
  s.homepage     = 'https://gitlab.yalantis.com/yespo-sdk/reteno-ios.git'
  s.license      = { type: 'MIT', file: 'License' }
  s.authors      = { 'Serhii Prykhodko': 'serhii.prykhodko@yalantis.net' }
  s.source       = { git: 'git@gitlab.yalantis.com:yespo-sdk/reteno-ios.git', tag: s.version }
  s.frameworks = 'Foundation'
  s.ios.deployment_target = '12.0'
  s.source_files = 'Reteno/**/*'

  s.dependency 'FirebaseCrashlytics'
  s.dependency 'Alamofire', '5.6.2'

end
