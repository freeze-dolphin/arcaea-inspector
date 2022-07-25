require "crsfml/audio"
require "crsfml/system"

spawn do
  sound = SF::Sound.new SF::SoundBuffer.from_file(
    "/home/freeze-dolphin/Documents/arcaea_4.0.255c_assets/app-data/story/vn/res/lastVocal_A_epilogue.ogg")
  sound.volume = 100
  sound.play

  loop do
    sound.finalize if sound.status == SF::SoundSource::Status::Stopped
  end
end

Fiber.yield
puts "done"
