Pod::Spec.new do |s|
s.name = 'MSScrollView'
s.version = '0.0.2'
s.summary = 'The easiest way to use pull-to-refresh with Swift2.0 program language.'
s.homepage = 'https://github.com/yuanshuainiuniu/AdvertisingScrollView-banner'
s.license = 'MIT'
s.author = { 'yuanshuai' => '717999274@qq.com' }
s.platform = :ios, '7.0'
s.source = { :git => 'https://github.com/yuanshuainiuniu/AdvertisingScrollView-banner.git', :tag => s.version }
s.source_files = 'MSScrollViewLib/**/*.{h,m}'
s.resources = 'MSScrollViewLib/MSSource.bundle'
# 框架是否使用的ARC
s.requires_arc = true
end
