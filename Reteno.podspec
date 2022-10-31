Pod::Spec.new do |s|
  s.name         = 'Reteno'
  s.version      = '1.0.1'
  s.summary      = 'The Reteno iOS SDK for App Analytics and Engagement.'
  s.homepage     = 'https://github.com/reteno-com/reteno-mobile-ios-sdk'
  s.license      = { type: 'MIT', file: 'License' }
  s.authors      = { 'Reteno': 'mobile-sdk@reteno.com' }
  s.source       = { git: 'https://github.com/reteno-com/reteno-mobile-ios-sdk.git', tag: s.version }
  s.documentation_url = "https://docs.reteno.com/reference/ios#setting-up-the-sdk"
  s.frameworks = 'Foundation'
  s.ios.deployment_target = '12.0'
  s.source_files = 'Reteno/Sources/**/*.swift'
  s.swift_versions = ['5']

  s.dependency 'Alamofire', '5.6.2'
  s.dependency 'Sentry', '7.28.0'

end
