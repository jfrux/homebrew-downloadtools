require 'formula'

class Couchpotato < Formula
  head 'git://github.com/RuudBurger/CouchPotato.git'
  homepage 'http://couchpotatoapp.com/'

  def install
    prefix.install Dir['*']
    bin.mkpath
    (bin+"couchpotato").write(startup_script)
    (prefix+"com.couchpotatoapp.couchpotato.plist").write(startup_plist)
    (prefix+"com.couchpotatoapp.couchpotato.plist").chmod 0644
  end

  def startup_plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>com.couchpotatoapp.couchpotato</string>
      <key>ProgramArguments</key>
      <array>
           <string>#{bin}/couchpotato</string>
           <string>-d</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>UserName</key>
      <string>#{`whoami`.chomp}</string>
    </dict>
    </plist>
    EOS
  end

  def startup_script; <<-EOS.undent
    #!/usr/bin/env ruby

    me = begin
      File.expand_path(
        File.join(
          File.dirname(__FILE__),
          File.readlink(__FILE__)
        )
      )
    rescue
      __FILE__
    end

    path = File.join(File.dirname(me), '..', 'CouchPotato.py')
    args = ["--pidfile", "#{var}/run/couchpotato.pid"]

    exec("#{`which python`.strip}", path, *(args + ARGV))
    EOS
  end

  def caveats; <<-EOS.undent
    CouchPotato will start up and launch http://localhost:5000/ when you run:

        couchpotato

    To launch automatically on startup, copy and paste the following into a terminal:

        mkdir -p ~/Library/LaunchAgents
        (launchctl unload -w ~/Library/LaunchAgents/com.couchpotatoapp.couchpotato.plist 2>/dev/null || true)
        ln -sf #{prefix}/com.couchpotatoapp.couchpotato.plist ~/Library/LaunchAgents/com.couchpotatoapp.couchpotato.plist
        launchctl load -w ~/Library/LaunchAgents/com.couchpotatoapp.couchpotato.plist

    You may want to edit:
      #{prefix}/com.couchpotatoapp.couchpotato.plist
    to change the port (default: 5000) or user (default: #{`whoami`.chomp}).
    EOS
  end
end
