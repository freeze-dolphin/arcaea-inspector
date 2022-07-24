require "crsfml"

module VNInterp
  def get_texture(path : String)
    if !File.exists? path
      raise NotFoundError.new "Cannot found texture file: #{path}"
    else
      return SF::Texture.from_file path
    end
  end

  def get_sound(path : String)
    if !File.exists? path
      raise NotFoundError.new "Cannot found sound file: #{path}"
    else
      return SF::SoundBuffer.from_file path
    end
  end

  def play_sound(path : String)
    sound = SF::Sound.new
    sound.buffer = get_sound path
    sound.play
  end

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
    end

    def play(audio : String,
             volume : Float64,
             loop? : Bool = false)
    end

    def volume(audio : String,
               volFrom : Float64, volTo : Float64)
    end

    def stop(audio : String,
             duration : Float64)
    end

    def say(content : String)
    end

    def show(pic : String,
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

    def self.wait(duration : Float64)
    end
  end
end
