require "crsfml"
require "crsfml/audio"

module VNInterp
  enum VNInterp::SuperPosition
    Normal
    Overlay
    OverlayPlus
  end

  enum VNInterp::Curve
    Linear
    SineOut    # easeOutSine
    SineIn     # easeInSine
    SineInOut  # eaesInOutSine
    EaseOut    # easeOutBack
    EaseIn     # easeInBack
    EaseInOut  # eaesInOutBack
    CubicOut   # easeOutCubic
    CubicIn    # easeInCubic
    CubicInOut # eaesInOutCubic
  end

  class VNInterp::Transition
    def initialize(duration : Float32, curve : VNInterp::Curve)
      @@duration = duration
      @@curve = curve
    end
  end

  class VNInterp::Interpreter
    def initialize(window : SF::RenderWindow)
      @@window = window
      @@sound_registry = Hash(String, SF::Sound).new
      @@img_registry = Hash(String, SF::Sprite).new
      @@debug = ArcaeaInspector::DEBUG
    end

    private def update_sound_registry
      @@sound_registry.not_nil!.each do |k, v|
        if v.status == SF::SoundSource::Status::Stopped
          @@sound_registry.not_nil!.delete k
        end
      end
    end

    def play(res : String, audio : String,
             volume : Float32,
             loop? : Bool = false)
      update_sound_registry
      puts "play #{audio}, orig-volume: #{volume}" if @@debug
      if loop?
        @@sound_registry.not_nil!.each do |k, v|
          if v.loop
            stop(k, 1)
          end
        end
      end
      puts "#{res}, volume: #{volume * 100}" if @@debug
      sound = SF::Sound.new SF::SoundBuffer.from_file(res + File::SEPARATOR_STRING + audio)
      sound.volume = volume * 100
      sound.loop = loop?
      sound.play
      @@sound_registry.not_nil![audio] = sound
      puts "playing #{audio}; registry: #{@@sound_registry}" if @@debug
    end

    def volume(audio : String,
               new_volume : Float32, duration : Float32)
      update_sound_registry
      sound = @@sound_registry[audio]
      tv = new_volume * 100
      spawn do
        while sound.volume < tv && sound.status == SF::SoundSource::Status::Playing
          SF.sleep SF.seconds duration / 10
          sound.volume += tv / 10
        end
        update_sound_registry
      end
    end

    def stop(audio : String,
             duration : Float32)
    end

    def say(content : Array(String))
      ArcaeaInspector.clear_txt
      i = -1
      content.each do |t|
        SF.sleep SF.seconds 1.5
        i += 1
        # ArcaeaInspector.update_txt t, i
      end
      SF.sleep SF.seconds 1
      ArcaeaInspector.show_arrow
    end

    def show(res : String, pic : String,
             posX : Float32, poxY : Float32,
             anchorX : Float32, anchorY : Float32,
             scaleX : Float32, scaleY : Float32,
             transition : VNInterp::Transition,
             superposition : VNInterp::SuperPosition)
    end

    def hide(pic : String,
             transition : VNInterp::Transition)
    end

    def move(pic : String,
             dx : Float32, dy : Float32,
             duration : Float32,
             curve : VNInterp::Curve)
    end

    def scale(pic : String,
              scaleX : Float32, scaleY : Float32,
              duration : Float32,
              curve : VNInterp::Curve)
    end

    def auto(duration : Float32)
    end

    def wait(duration : Float32)
      SF.sleep SF.seconds duration
    end
  end
end
