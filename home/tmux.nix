{ ... }: {
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    mouse = true;
    extraConfig = ''
      setw -g pane-base-index 1
      set -g renumber-windows on

      # Switch windows with Alt + number
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # New window
      bind -n M-t new-window -c "#{pane_current_path}"

      # Split panes
      bind -n M-- split-window -v -c "#{pane_current_path}"
      bind -n M-\\ split-window -h -c "#{pane_current_path}"

      # Close current pane
      bind -n M-w kill-pane

      # Navigate panes with Alt + arrows
      bind -n M-Left  select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up    select-pane -U
      bind -n M-Down  select-pane -D
    '';
  };
}
