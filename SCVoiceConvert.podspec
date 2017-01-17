
Pod::Spec.new do |s|

  s.name         = "SCVoiceConvert"
  s.version      = "0.1.0"
  s.summary      = "VoiceConvert."
  s.homepage     = "http://www.zytec.cn"
  s.license      = "MIT"
  s.author       = { "lastobject@gmail.com" => "lastobject@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://git.oschina.net/dl_zytec/SCVoiceConvert.git", :tag => "#{s.version}" }
  s.source_files = "SCVoiceConvert/**/*.{h,m,mm}"
  s.vendored_libraries = 'SCVoiceConvert/**/*.a'
  s.library      = "stdc++"

end
