

Pod::Spec.new do |s|
s.name             = 'Mask'
s.version          = '0.1.0'
s.summary          = 'A short description of Mask.'

s.description      = <<-DESC
TODO: Add long description of the pod here.
DESC

s.homepage         = 'https://github.com/Huuush/Mask'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Huuush' => '609742482@qq.com' }
s.source           = { :git => 'https://github.com/Huuush/Mask-GPUImage.git', :tag => s.version.to_s }

s.ios.deployment_target = '9.0'

s.source_files = 'Mask/Classes/**/*'


# s.public_header_files = 'Pod/Classes/**/*.h'
# s.frameworks = 'UIKit', 'MapKit'

s.dependency 'Masonry','1.1.0'
s.dependency 'MJRefresh', '3.1.12'
s.dependency 'YYModel', '1.0.4'
s.dependency 'MJExtension'
s.dependency 'AFNetworking'
s.dependency 'GPUImage','0.1.7'

s.dependency 'YBImageBrowser'

end

