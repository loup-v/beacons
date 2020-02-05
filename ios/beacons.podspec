Pod::Spec.new do |s|
  s.name             = 'beacons'
  s.version          = '0.0.1'
  s.summary          = 'Flutter beacons plugin for iOS and Android.'
  s.description      = <<-DESC
Flutter beacons plugin for iOS and Android.
                       DESC
  s.homepage         = 'https://github.com/loup-v/beacons'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Loup Inc.' => 'hello@intheloup.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  s.dependency 'Flutter'
  s.frameworks = 'CoreLocation'
  s.ios.deployment_target = '8.0'

end

