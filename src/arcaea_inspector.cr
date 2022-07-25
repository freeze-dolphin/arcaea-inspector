require "crsfml"
require "crsfml/system"
require "option_parser"
require "totem"
require "./vn_interpreter"

module ArcaeaInspector
  DEBUG = true
  @@waiting_for_next = false
  lowp_mode = false
  vsync = false
  fps_limit = -1
  style = SF::Style::Close
  target = ""
  res = ""

  if !File.exists? "./config.yaml"
    File.write "./config.yaml", <<-EOF
    low_resolution_mode: false
    vsync: false
    fps_limit: -1
    fullscreen: false
    EOF
  end

  totem = Totem.from_file "./config.yaml"

  lowp_mode = totem.get("low_resolution_mode").as_bool
  vsync = totem.get("low_resolution_mode").as_bool
  fps_limit = totem.get("fps_limit").as_i
  style = SF::Style::Fullscreen if totem.get("fullscreen").as_bool

  OptionParser.parse do |psr|
    psr.banner = "The Arcaea Inspector v0.1.0"

    psr.on "-h", "--help", "Show help" do
      puts psr
      exit
    end

    psr.on "-v", "--version", "Show version" do
      puts "arcaea-inspector v0.1.0"
      exit
    end

    psr.on "-o PATH_TO_VNS", "--open PATH_TO_VNS", "Specifiy target" do |path|
      target = path
    end

    psr.on "-7", "--720p", "Enable low resolution mode" do
      lowp_mode = true
    end

    psr.on "-s", "--vsync", "Enable vertical sync mode" do
      vsync = true
    end

    psr.on "-l MAX", "--limit=MAX", "Specify framerate limitation" do |max|
      fps_limit = max.to_i
    end

    psr.on "-f", "--fullscreen", "Enable fullscreen mode" do
      style = SF::Style::Fullscreen
    end
  end

  if target == "" || !File.exists? target
    puts
    puts "No valid target specified, exit..."
    exit
  end

  if DEBUG
    puts
    puts "Target: #{target}"
    ress = target.split "/"
    ress.pop
    ress << "res"
    res = ress[0, ress.size].join "/"
    puts "Resource Folder: #{res}"
  end

  width = 1960
  height = 1080

  if lowp_mode
    width = 1080
    height = 720
  end

  # window preparation end

  window = SF::RenderWindow.new(SF::VideoMode.new(width, height), "Arcaea Inspector", style)

  window.active = false

  if fps_limit > 0
    window.framerate_limit = fps_limit
  end

  if vsync
    window.vertical_sync_enabled = true
  end

  spawn do
    int = VNInterp::Interpreter.new window
    commands = ["play", "say", "wait", "auto", "move", "hide", "show", "stop", "volume", "end"]
    splited = (File.read target).split(/(\n| )/, remove_empty: true)
    splited << "end"
    splited.reject! { |x| x == "\n" || x == " " }
    i = 0
    channel = Channel(Nil).new

    while i < splited.size
      if splited[i] == "play"
        args = [] of String
        j = i + 1
        while !(commands.includes? splited[j])
          t = splited[j]
          if t[0, 1] == "\"" && t[-1, t.size - 1] == "\""
            t = t[1, t.size - 2]
          end
          args << t
          j += 1
        end

        int.play(
          res,
          args[0],
          args[1].unsafe_as(Float64),
          args.size < 3 ? false : true)
      elsif splited[i] == "say"
        args = [] of String
        j = i + 1
        while !(commands.includes? splited[j])
          t = splited[j]
          if t[0, 1] == "\"" || t[-1, t.size - 1] == "\""
            t = t[1, t.size - 2]
          end
          args << t
          j += 1
        end

        loop do
          break if !@@waiting_for_next
        end
        int.say(args)
        @@waiting_for_next = true
      end
      i += 1
    end
  end

  SF::Thread.new(->{
    font = SF::Font.from_file "resources/NotoSansCJKsc-Light.otf"
    txt = SF::Text.new "", font
    x, y = txt.global_bounds.width, txt.global_bounds.height
    ctr = (SF.vector2f x, y) / 2
    lb = txt.local_bounds
    lbv = SF.vector2f lb.left, lb.top
    # rounded = lb.round

    while window.open?
      while event = window.poll_event
        case event
        when SF::Event::Closed
          window.close
        when SF::Event::KeyReleased
          if event.code == SF::Keyboard::Space && @@waiting_for_next
            @@waiting_for_next = false
          end
        end
      end
    end
  }).launch
end
