require 'formula'

class Sabnzbd < Formula
  url 'https://github.com/sabnzbd/sabnzbd/tarball/0.6.9'
  homepage 'http://sabnzbd.org/'
  md5 '634112978dd3e7c22dfe927d02b99227'

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
    (prefix+"org.sabnzbd.sabnzbd.plist").write(startup_plist)
    (prefix+"org.sabnzbd.sabnzbd.plist").chmod 0644
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
        (launchctl unload -w ~/Library/LaunchAgents/org.sabnzbd.sabnzbd.plist 2>/dev/null || true)
        ln -sf #{prefix}/org.sabnzbd.sabnzbd.plist ~/Library/LaunchAgents/org.sabnzbd.sabnzbd.plist
        launchctl load -w ~/Library/LaunchAgents/org.sabnzbd.sabnzbd.plist

    You may want to edit:
      #{prefix}/org.sabnzbd.sabnzbd.plist
    to change the port (default: 8080) or user (default: #{`whoami`.chomp}).
    EOS
  end
end
