Pod::Spec.new do |s|
# 名称 使用的时候pod search [name]
s.name = "MSScrollView"
# 代码库的版本
s.version = "0.0.2"
# 简介
s.summary = "The easiest way to use pull-to-refresh with Swift2.0 program language."
# 主页
s.homepage = "https://github.com/yuanshuainiuniu/AdvertisingScrollView-banner"
# 许可证书类型，要和仓库的LICENSE 的类型一致
s.license = "MIT"
# 作者名称 和 邮箱
s.author = { "yuanshuai" => "717999274@qq.com" }
# 作者主页 s.social_media_url ="http://blog.csdn.net/boyXiong.com/"
# 代码库最低支持的版本
s.platform = :ios, "7.0"
# 代码的Clone 地址 和 tag 版本
s.source = { :git => "https://github.com/yuanshuainiuniu/AdvertisingScrollView-banner.git", :tag => "0.0.2" }
# 如果使用pod 需要导入哪些资源
s.source_files = "MSScrollViews", "MSScrollViews/*.{h,m}"
# gits.resources = "XWSwiftRefreshT/Icon/xw_icon.bundle"
# 框架是否使用的ARC
s.requires_arc = true
end
