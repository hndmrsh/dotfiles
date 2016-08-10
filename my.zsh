export PATH=$PATH:~/scripts:~/.gem/ruby/2.3.0/bin

# Load ssh keys (working directory is ~/.ssh/)
eval $(keychain --eval --quiet id_rsa)

alias hc=herbstclient
alias poweroff="systemctl poweroff"
alias reboot="systemctl reboot"

function yaourt-cleandeps() { yaourt -Rns $(yaourt -Qtdq) }
