
Pod::Spec.new do |s|

  s.name         = "SCVoiceConvert"
  s.version      = "0.1.2"
  s.summary      = "VoiceConvert."
  s.homepage     = "http://www.zytec.cn"
  s.license      = "MIT"
  s.author       = { "lastobject@gmail.com" => "lastobject@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/lastObject/SCVoiceConvert.git", :tag => s.version.to_s }
  s.source_files = "SCVoiceConvert/**/*.{h,m,mm}"
  s.vendored_libraries = 'SCVoiceConvert/**/*.a'
  s.library      = "stdc++"
  s.public_header_files = 'SCVoiceConvert/Classes/*.h'
end
