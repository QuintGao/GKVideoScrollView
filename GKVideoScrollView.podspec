Pod::Spec.new do |s|
  s.name         = "GKVideoScrollView"
  s.version      = "1.0.7"
  s.summary      = "iOS仿抖音等上下滑动切换内容，使用方便类似UITableView，可支持多种cell切换"
  s.homepage     = "https://github.com/QuintGao/GKVideoScrollView"
  s.license      = "MIT"
  s.authors      = { "QuintGao" => "1094887059@qq.com" }
  s.social_media_url   = "https://github.com/QuintGao"
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/QuintGao/GKVideoScrollView.git", :tag => s.version.to_s }
  s.source_files = 'GKVideoScrollView/*.{h,m}'
  
end
