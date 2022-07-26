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
    def initialize(duration : Float64, curve : VNInterp::Curve)
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

    def play(res : String, audio : String,
             volume : Float64,
             loop? : Bool = false)
      puts "play #{audio}"
      if loop?
        @@sound_registry.not_nil!.each do |k, v|
          if v.loop
            stop(k, 0)
          end
        end
      end
      buffer = SF::SoundBuffer.from_file(res + File::SEPARATOR_STRING + audio)
      sound = SF::Sound.new buffer
      sound.volume = volume * 100
      sound.loop = loop?
      sound.play
      @@sound_registry.not_nil![audio] = sound
      puts "playing #{audio}; registry: #{@@sound_registry}" if @@debug
    end

    def volume(audio : String,
               volFrom : Float64, volTo : Float64)
    end

    def stop(audio : String,
             duration : Float64)
    end

    def say(content : Array(String))
      ArcaeaInspector.clear_txt
      return if content.nil? || content.size == 0
      i = 0
      content.each do |t|
        SF.sleep SF.seconds 1.5
        i += 1
        ArcaeaInspector.update_txt t, i
      end
      SF.sleep SF.seconds 1
      ArcaeaInspector.show_arrow
    end

    def show(res : String, pic : String,
             posX : Float64, poxY : Float64,
             anchorX : Float64, anchorY : Float64,
             scaleX : Float64, scaleY : Float64,
             transition : VNInterp::Transition,
             superposition : VNInterp::SuperPosition)
    end

    def hide(pic : String,
             transition : VNInterp::Transition)
    end

    def move(pic : String,
             dx : Float64, dy : Float64,
             duration : Float64,
             curve : VNInterp::Curve)
    end

    def scale(pic : String,
              scaleX : Float64, scaleY : Float64,
              duration : Float64,
              curve : VNInterp::Curve)
    end

    def auto(duration : Float64)
    end

    def wait(duration : Float64)
      SF.sleep SF.seconds duration
    end
  end
end
