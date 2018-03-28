#!/bin/bash

cd ~

# install system tools
##########################################
# update silently
sudo apt update -qq
# all yes
sudo apt upgrade -yy


sudo apt -y install zsh cmake make vim git g++ gcc curl

# tilix terminal
##########################################
read -p "Install tilix? <Y/y>" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # tilix only available in newer ubuntu versions
    sudo apt -y install tilix || { echo ; echo "tilix not available, add private repo"; echo ; \
    sudo add-apt-repository ppa:webupd8team/terminix; \
    sudo apt -qq update; sudo apt -y install tilix }
else
    echo "tilix will not be installed."
    echo
fi

# virtualbox prep
##########################################
read -p "Remove current virtualbox for later install of newest version? <Y/y>" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt autoremove --purge virtualbox*
fi


# install all packages in installer dir
##########################################
# packages for dir:
# + slack
# + mailspring
# + clion
# + pycharm
# + gitkraken (if manual)
# + anaconda (if manual)
# + boostnote
# + synology drive
# + virtualbox
# + vs code
read -p "Install additional *.deb files from ./deb_packages/? <Y/y>" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # ask for every packe, no -y
    sudo apt install ./deb_packages/*

    echo "All deb packages installed."
    echo
else
    echo "No additional packages will be instaled."
    echo
fi


# install and set up zsh
##########################################
read -p "Set up zsh and oh-my-zsh? <Y/y>" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # install oh my zsh
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    #TODO change zshrc to use agnoster theme
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
    # change zsh theme
    sed -i 's/ZSH_THEME="robbyrussell"q/ZSH_THEME="agnoster"/' ~/.zshrc
    # install fonts for agnoster theme
    sudo apt -y install fonts-powerline
    # adapt theme so it doesnt show the user
    echo "DEFAULT_USER=$(whoami)" >> .zshrc

    echo "ZSH installed and set up."
    echo
else
    echo "zsh will not be set up."
    echo
fi

# install CUDA and cudnn
##########################################
read -p "Install CUDA and cuDNN? <Y/y>" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # install all deb packages in cuda dir
    sudo apt install -y cuda/*.deb || exit
    # unzip cudnn
    tar -xvzf cuda/cudnn-9.0-linux-x64-v7.1.tgz 
    # files are now in cuda/cuda/
    # move cudnn header and binaries
    sudo mv cuda/cuda/include/* /usr/local/cuda-9.0/include/
    sudo mv cuda/cuda/lib64/* /usr/local/cuda-9.0/lib64/
    rm -r cuda/cuda

    # export cuda path to zsh and bash
    # cuda path
    CMD="export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64"
    echo $CMD >> ~/.zshrc
    echo $CMD >> ~/.bashrc

    echo "CUDA and cuDNN installed."
    echo
else
    echo "CUDA will not be installed."
    echo
fi


# install anaconda
########################################## 
read -p "Download and install Anaconda? <Y/y>" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    CONDAFILE=Anaconda3-5.1.0-Linux-x86_64.sh
    curl -O https://repo.continuum.io/archive/$CONDAFILE
    bash ./$CONDAFILE
    rm $CONDAFILE


    read -p "Set up Anaconda env? <Y/y>" -n 1 -r
    echo    
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # TODO write separate script to manage env & packages
    else
        echo "Anaconda env will not be set up."
    fi
else
    echo "Anaconda will not be installed."
fi




# install spotify
##########################################
# https://www.spotify.com/de/download/linux/
read -p "Install Spotify? <Y/y>" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410
    echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update -qq
    sudo apt install -y spotify-client 
    echo "Spotfiy was installed."
    echo
else
    echo "Spotify will not be installed."
    echo
fi



# download and install gitkraken
##########################################
read -p "Install gitkraken? <Y/y>" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # installs all necessary dependencies
    KRAKENFILE=gitkraken-amd64.deb
    curl -O https://release.gitkraken.com/linux/$KRAKENFILE
    sudo apt install ./$KRAKENFILE
    rm $KRAKENFILE
    echo "Gitkraken was installed."
    echo
else
    echo "Gitkraken will not be installed."
    echo
fi

# enpass
##########################################
read -p "Install enpass? <Y/y>" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # opens a new shell as sudo with bash
    sudo -i
    echo "deb http://repo.sinew.in/ stable main" > \
    /etc/apt/sources.list.d/enpass.list
    # import key that is used to sign the release:
    wget -O - https://dl.sinew.in/keys/enpass-linux.key | apt-key add -
    apt update -qq
    apt install enpass
    # closes that sudo shell
    exit
else
    echo "Enpass will not be installed."
fi



# planck
##########################################
read -p "Install Plank dock? <Y/y>" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo add-apt-repository ppa:ricotz/docky
    sudo apt update -qq
    sudo apt install plank
fi

# resilio sync
##########################################
read -p "Install resilio sync? <Y/y>" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # register resilio repo
    echo "deb http://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" | sudo tee /etc/apt/sources.list.d/resilio-sync.list
    # add public key
    wget -qO - https://linux-packages.resilio.com/resilio-sync/key.asc | sudo apt-key add -
    sudo apt update -qq
    sudo apt install -y resilio-sync
fi

# shell aliases
##########################################
read -p "Do you  want to add shell aliases to zsh and bash rc? <Y/y>" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "alias lsd='ls -d */'" | tee -a ~/.bashrc ~/.zshrc > /dev/null
fi




echo "#################################"
echo "#################################"
echo "Installation script has finished."