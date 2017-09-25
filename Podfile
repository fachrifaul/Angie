# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Angie' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Angie
  pod 'Alamofire', '~> 4.4'
  pod 'Kingfisher', '~> 4.0.1'
  pod 'SnapKit'
  pod 'Hue'
  pod 'SCLAlertView'
  pod 'SwiftyJSON'
  pod 'ALThreeCircleSpinner'
  pod 'XLActionController'
  pod 'Hue'
  pod 'DGElasticPullToRefresh', :git => 'https://github.com/fachrifaul/DGElasticPullToRefresh.git', :branch => 'master'

  target 'AngieTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

