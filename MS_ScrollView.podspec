Pod::Spec.new do |s|
s.name = 'MS_ScrollView'
s.version = '0.1.1'
s.summary = 'The easiest way to use pull-to-refresh with Swift2.0 program language.'
s.homepage = 'https://github.com/yuanshuainiuniu/AdvertisingScrollView-banner'
s.license = 'MIT'
s.author = { 'yuanshuai' => '717999274@qq.com' }
s.platform = :ios, '7.0'
s.source = { :git => 'https://github.com/yuanshuainiuniu/AdvertisingScrollView-banner.git', :tag => s.version }
s.source_files = 'MSScrollViewLib/**/*.{h,m}'
s.resource     = 'MSScrollViewLib/MSSource.bundle'
s.requires_arc = true
end
