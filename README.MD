# Stupidity

The layout switcher...

## Setup

Please symlink a file in your keyd config directory to a user owned file:

```bash
mkdir -p ~/.local/state/
touch ~/.local/state/stupidity.keyd
ln -s /home/user/.local/state/stupidity.keyd /etc/keyd/stupidity_current_layout
```

Next, include the file in your keyd main config:

`/etc/keyd/default.conf`

```keyd
[ids]
*

include stupidity_current_layout

...
```

If you use waybar, copy the following module into your config and move the layout.bash file into your waybar config directory

```jsonc
"custom/layout": {
    "format": "{}",
    "return-type": "json",
    "exec": "~/.config/waybar/layout.bash",
    "tooltip": true,
    "interval": 2,
    "on-click": "~/dotfiles/scripts/stupidity default",
    "on-click-middle": "~/dotfiles/scripts/stupidity next",
    "on-click-right": "~/dotfiles/scripts/stupidity daily"
},
```

Set up sudo to allow you to run `keyd reload` without password

```bash
echo '%wheel ALL=(root) NOPASSWD: /usr/bin/keyd' | sudo tee /etc/sudoers.d/stupidity_keyd > /dev/null
```

Place `stupidity.bash` in your scripts directory and set some paths...

- Point the two paths within `stupidity.bash` to go to your new keyd config file and another new file
- Point `layout.bash` to `stupidity.bash`

And finally, set both scripts to be executable.

## Configuration

Available layouts, daily layouts and the default layout can be set within `stupidity.bash`. They are documented there.

> [!NOTE]
> Since keyd does not support recursive `include` statements, you must include all layouts you intend to use within your main keyd config file.

## Usage

The usage of the program is explained by passing `help` to the script.