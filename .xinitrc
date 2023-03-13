changescreen -vga

autostart="pipewire"

for program in $autostart; do
	pidof -s "$program" || "$program" &
done >/dev/null 2>&1

ssh-agent dwm
