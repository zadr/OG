Pod::Spec.new do |s|
  s.name = 'OG'
  s.version = '1.4'
  s.license = 'BSD'
  s.summary = 'An OpenGraph parser in Swift'
  s.homepage = 'https://github.com/zadr/OG'
  s.authors = { 'Zachary Drayer' => 'zacharydrayer@gmail.com' }
  s.source = { :git => 'https://github.com/zadr/OG.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Sources/*.swift'
end
