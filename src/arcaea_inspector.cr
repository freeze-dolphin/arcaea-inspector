require "crsfml"
require "crsfml/system"
require "option_parser"
require "totem"
require "./vn_interpreter"

module ArcaeaInspector
  DEBUG = true
  @@waiting_for_next = false
  @@lowp_mode = false
  @@vsync = false
  @@fps_limit = -1
  @@style = SF::Style::Close
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

  @@totem : Totem::Config = Totem.from_file "./config.yaml"

  @@lowp_mode = @@totem.get("low_resolution_mode").as_bool
  @@vsync = @@totem.get("low_resolution_mode").as_bool
  @@fps_limit = @@totem.get("fps_limit").as_i
  @@style = SF::Style::Fullscreen if @@totem.get("fullscreen").as_bool

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

  @@width = 1960
  @@height = 1080

  if @@lowp_mode
    @@width = 1080
    @@height = 720
  end

  def ArcaeaInspector.slice_off_quote(s : String)
    head = s[0, 1]
    tail = s[s.size - 1, s.size]
    rst = s
    if head == "\""
      rst = rst[1, rst.size]
    end
    if tail == "\""
      rst = rst[0, rst.size - 1]
    end
    rst.gsub "\\\"", "\""
  end

  spawn do
    int = VNInterp::Interpreter.new @@window
    commands = ["play", "say", "wait", "auto", "move", "hide", "show", "stop", "volume", "end"]
    splited = (File.read target).split(/(\n| )/, remove_empty: true)
    # puts "before: #{splited}" if DEBUG
    splited << "end"
    # puts "after: #{splited}" if DEBUG
    splited.reject! { |x| x == "\n" || x == " " }
    # puts "ultimate: #{splited}" if DEBUG
    i = 0

    while i < splited.size
      case cmd = splited[i]
      when "play"
        puts cmd if DEBUG
        args = [] of String
        j = i + 1
        while !(commands.includes? splited[j])
          args << slice_off_quote splited[j]
          j += 1
        end

        int.play(
          res,
          args[0],
          args[1].to_f32,
          args.size < 3 ? false : true)
      when "say"
        puts cmd if DEBUG
        args = [] of String
        j = i + 1
        while !(commands.includes? splited[j])
          args << slice_off_quote splited[j]
          j += 1
        end

        loop do
          break if !@@waiting_for_next
        end
        int.say(args)
      when "wait"
        puts cmd if DEBUG
        args = [] of String
        j = i + 1
        while !(commands.includes? splited[j])
          args << slice_off_quote splited[j]
          j += 1
        end

        int.wait(args[0].to_f32)
      when "end"
        puts cmd if DEBUG
        loop do
          if !@@waiting_for_next
            @@window.close
            exit
          end
        end
      end
      i += 1
      puts i if DEBUG
    end
  end

  @@window = SF::RenderWindow.new(SF::VideoMode.new(@@width, @@height), "Arcaea Inspector", @@style)

  @@window.active = false

  if @@fps_limit > 0
    @@window.framerate_limit = @@fps_limit
  end

  if @@vsync
    @@window.vertical_sync_enabled = true
  end

  objs = Array(SF::Drawable).new

  @@font = SF::Font.from_file "resources/NotoSansCJKsc-Light.otf"

  @@arrow = SF::Text.new "v", @@font
  @@arrow.color = SF::Color::White
  @@arrow.character_size = 20
  @@arrow.origin = SF.vector2f @@arrow.local_bounds.width / 2, @@arrow.local_bounds.height / 2
  @@arrow.position =
    SF.vector2f(
      @@window.size.x / 2,
      @@window.size.y - @@window.size.y / 5 + 5 * 20)
  @@arrow.string = ""

  @@txts = Array(SF::Text).new
  @@txta = SF::Text.new "", @@font
  @@txta.color = SF::Color::White
  @@txta.character_size = 18
  @@txtb = SF::Text.new "", @@font
  @@txtb.color = SF::Color::White
  @@txtb.character_size = 18
  @@txtc = SF::Text.new "", @@font
  @@txtc.color = SF::Color::White
  @@txtc.character_size = 18

  @@txts << @@txta
  @@txts << @@txtb
  @@txts << @@txtc

  @@txts.each do |t|
    objs << t
  end
  objs << @@arrow

  def ArcaeaInspector.clear_txt
    @@txts.each do |t|
      t.string = ""
    end
    @@arrow.string = ""
  end

  def ArcaeaInspector.show_arrow
    @@arrow.string = "v"
    lb = @@arrow.local_bounds
    @@arrow.origin = SF.vector2f lb.left + lb.width / 2, lb.top + lb.height / 2
    @@arrow.position = SF.vector2f(
      @@window.size.x / 2,
      @@arrow.position.y
    )
    @@waiting_for_next = true
  end

  def ArcaeaInspector.update_txt(new_text : String, line_num : Int32)
    tx = @@txts[line_num]
    tx.string = new_text
    lb = tx.local_bounds
    tx.origin = SF.vector2f lb.left + lb.width / 2, lb.top + lb.height / 2
    tx.position = SF.vector2f(
      @@window.size.x / 2,
      @@window.size.y - @@window.size.y / 5 + line_num * 20)
  end

  SF::Thread.new(->do
    while @@window.open?
      while event = @@window.poll_event
        case event
        when SF::Event::Closed
          @@window.close
        when SF::Event::KeyReleased
          if event.code == SF::Keyboard::Space && @@waiting_for_next
            @@waiting_for_next = false
          end
        end
      end

      @@window.clear SF::Color::Black
      objs.each do |obj|
        @@window.draw obj
      end
      @@window.display
    end
    @@window.close
    exit
  end
  ).launch
end
