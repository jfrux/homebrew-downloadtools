require 'formula'

class Sabnzbd < Formula
  url 'https://github.com/sabnzbd/sabnzbd/archive/0.7.6.tar.gz'
  homepage 'http://sabnzbd.org/'
  md5 '33a5072d6bbf3016cc80664f5e8a5874'

  depends_on 'par2'
  depends_on 'unrar'
  depends_on 'gettext'

  depends_on 'Cheetah' => :python
  depends_on 'yenc' => :python
  depends_on 'OpenSSL' => :python

  def install
    prefix.install Dir['*']
    bin.mkpath
    (bin+"sabnzbd").write(startup_script)
    (etc+"sabnzbd").mkpath
    (prefix+"homebrew.mxcl.sabnzbd.plist").write(startup_plist)
    (prefix+"homebrew.mxcl.sabnzbd.plist").chmod 0644
  end

  def startup_plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>org.sabnzbd.sabnzbd</string>
      <key>ProgramArguments</key>
      <array>
           <string>#{bin}/sabnzbd</string>
           <string>-d</string>
           <string>-s</string>
           <string>localhost:8080</string>
           <string>-b</string>
           <string>0</string>
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

    path = File.join(File.dirname(me), '..', 'SABnzbd.py')
    args = ["-f", "#{etc}/sabnzbd/sabnzbd.ini", "--pid", "#{var}/run"]

    exec("#{`which python`.strip}", path, *(args + ARGV))
    EOS
  end

  def caveats; <<-EOS.undent
    SABnzbd will start up and launch http://localhost:8080/ when you run:

        sabnzbd

    To launch automatically on startup, copy and paste the following into a terminal:

        mkdir -p ~/Library/LaunchAgents
        (launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.sabnzbd.plist 2>/dev/null || true)
        ln -sf #{prefix}/homebrew.mxcl.sabnzbd.plist ~/Library/LaunchAgents/homebrew.mxcl.sabnzbd.plist
        launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.sabnzbd.plist

    You may want to edit:
      #{prefix}/homebrew.mxcl.sabnzbd.plist
    to change the port (default: 8080) or user (default: #{`whoami`.chomp}).
    EOS
  end
end
