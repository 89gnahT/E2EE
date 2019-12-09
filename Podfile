# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'E2EE' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'SwiftProtobuf', '~> 1.7.0'
  pod 'Curve25519'
  pod 'Firebase/Analytics'
  pod 'Firebase/Storage'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  # Pods for E2EE

  target 'E2EETests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Firebase/Analytics'
    pod 'Firebase/Storage'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
  end

  target 'E2EEUITests' do
    # Pods for testing
  end

end
