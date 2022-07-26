require "crsfml/audio"
require "crsfml/system"

sound = SF::Sound.new SF::SoundBuffer.from_file(
  "/home/freeze-dolphin/Documents/arcaea_4.0.255c_assets/app-data/story/vn/res/lastVocal_A_epilogue.ogg")
sound.play

puts gets
