# throwtube

Open a URL in Firefox on another machine over SSH.

One small script. You run it here, the tab opens there.

## Requirements

- Bash on the sending machine
- SSH key auth to the target (no password prompt)
- The target user must be the one logged into the desktop session
- Firefox installed on the target, reachable as `firefox`

## Install

```bash
git clone <your-repo-url> ~/src/throwtube
ln -s ~/src/throwtube/throwtube ~/bin/throwtube
chmod +x ~/src/throwtube/throwtube
```

If `~/bin` isn't on your `PATH`, either add it or drop the symlink and call the script by full path.

Set up the key once:

```bash
ssh-keygen -t ed25519 -N ''
ssh-copy-id you@192.168.1.50
```

## Configure

Edit the `HOST` variable at the top of the script:

```bash
HOST="you@192.168.1.50"
```

A `~/.ssh/config` alias works too ? set `HOST=tvbox` and define the host, user, and identity file there instead.

## Usage

```bash
throwtube 'https://youtu.be/dQw4w9WgXcQ'   # open a URL
throwtube                                   # open the clipboard contents
```

URLs missing a scheme get `https://` prepended, so `throwtube youtu.be/xyz` works.

## How it works

`ssh` to the target, then `nohup firefox --new-tab <url> &` with the display variables set. `nohup` keeps the tab alive after the connection closes. The URL is shell-quoted with `printf '%q'` so query strings survive intact.

## Troubleshooting

**Nothing opens, no error.** The SSH session can't see the desktop. Test the display value directly:

```bash
ssh you@192.168.1.50 'DISPLAY=:0 firefox --new-tab https://example.com'
```

Adjust `DISPLAY` (try `:1`) or the `WAYLAND_DISPLAY` value in the script until it works.

**Wayland-only target.** Drop `DISPLAY=:0` from the script and keep `WAYLAND_DISPLAY=wayland-0`. The socket may be `wayland-1` on multi-seat boxes ? check `ls /run/user/$(id -u)` on the target.

**`firefox: command not found`.** Non-interactive SSH gets a minimal `PATH`. Use the absolute path, or `flatpak run org.mozilla.firefox` / `snap run firefox` if it's a sandboxed install.

**Prompts for a password.** Key auth isn't set up for that host, or `BatchMode` is off. Re-run `ssh-copy-id` and confirm `ssh you@192.168.1.50 true` returns silently.

**Tab opens on the wrong monitor / steals focus.** Expected ? `--new-tab` reuses the running instance and whatever window it's in. Move the window yourself, or change the flag to `--new-window`.

## Notes

- Same user on both ends is the supported setup. Launching into another user's session needs `sudo -u` plus their `XDG_RUNTIME_DIR`.
- No auth beyond SSH. Don't expose the target's SSH port to the internet without keys restricted in `authorized_keys`.
