source ~/dotfiles/private.zsh

export PATH=$PATH:~/scripts:~/.gem/ruby/2.3.0/bin
export VISUAL="vim"

# Load ssh keys (working directory is ~/.ssh/)
eval $(keychain --eval --quiet --noask id_rsa)

alias hc=herbstclient
alias poweroff="systemctl poweroff"
alias reboot="systemctl reboot"

function yaourt-cleandeps() { yaourt -Rns $(yaourt -Qtdq) }
