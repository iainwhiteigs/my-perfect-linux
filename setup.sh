#!/bin/bash

sudo apt-get update && sudo apt-get upgrade -y

# Create a list of all the packages to be installed:
packages=(
    git
    zsh
    nano # text editor
    micro # text editor
    exa # ls replacement
    fzf # fuzzy finder
    cowsay # for fun
    zoxide # for fast directory navigation
    python3
    htop
)

# Kubernetes tools
packages+=(
    kubectl
    kubectx
    kubens
    k9s
    helm
    stern
    kustomize
    kubeseal
)

# If an argument contains the word "bare", add the bare metal packages to the list:
if [[ $1 == *"bare"* ]]; then
    # Add to the list if running on bare metal:
    packages+=(
        cockpit # remote management
        fonts-powerline # for powerlevel10k
        docker.io
        nodejs
        node-red
    )
fi

echo "Installing packages: ${packages[@]}"

# Cycle through the list and install each package with apt:
for package in "${packages[@]}"; do
    sudo apt-get install -y "$package"
done

# Clean up
sudo apt-get autoremove -y

# Set zsh as default shell
chsh -s $(which zsh)

# Install Oh My Zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# use sed to replace ZSH_THEME="robbyrussell" with ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# Get the powerlevel10k config file
curl https://raw.githubusercontent.com/iainwhiteigs/my-perfect-linux/main/.p10k.zsh --output ~/.p10k.zsh

# Insert at the beginning of the .zshrc file
cat << 'EOF' > ~/.zshrc_temp
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
EOF

cat ~/.zshrc >> ~/.zshrc_temp
mv ~/.zshrc_temp ~/.zshrc

# Append to the end of the .zshrc file
cat << 'EOF' >> ~/.zshrc
#p10k init
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Setup zoxide to replace cd
eval "$(zoxide init zsh --cmd cd)"

# Aliases
alias ls='exa --icons'
alias lst='exa -lma -s modified --icons'
EOF

# Install oh-my-zsh plugins
sudo git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc