-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Match pointer speed to laptop vs external monitor.
o.launch_on_start(os.getenv("HOME") .. "/.config/hypr/scripts/pointer-sensitivity-by-monitor.sh")
