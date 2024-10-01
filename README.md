# StuBaToo - Stumie's Bash Toolbox
This repository is a toolbox of Bash scripts, that often rely on each other.\
Its use case is to suit my own needs best. But since most of my needs are probably also someone else's needs, I decided to share my toolbox via GitHub under GPL-3.0 license.
> [!WARNING]
> 1. The scripts are only tested manually and only on my personal systems, which normally have a Debian stable- or Debian unstable-based Linux distribution installed. So, you might encounter unknown issues with other distributions or even other Debian release versions.
> 2. I'm not a real programmer myself, so be cautious, that my scripts might not follow otherwise vastly established programming principles.
## Scripts
### current-cpu-frequency.sh
Little helper script to show live CPU frequencies over all cores, without installing any bigger tool for that use case.
### get-new-kerberos-ticket.sh
When I sometimes need a new kerberos token, where I almost always forget a step. This little helper stands by.
### install-onenote-on-edge.sh
Creates a nice `*.desktop` file for Microsoft OneNote Web.

> [!WARNING]
> Needs Microsoft Edge installed and openable via `microsoft-edge`. _(So e. g. probably not working with MS Edge installed via Flatpak.)_

> [!TIP]
> `install-onenote-on-edge.sh` is not relying on other sub-scripts and therefore could be easily forked or used independently.
### install-outlook-on-edge.sh
Creates a nice `*.desktop` file for Microsoft Outlook Web.

> [!WARNING]
> Needs Microsoft Edge installed and openable via `microsoft-edge`. _(So e. g. probably not working with MS Edge installed via Flatpak.)_

> [!TIP]
> `install-outlook-on-edge.sh` is not relying on other sub-scripts and therefore could be easily forked or used independently.
### netstat-without-netstat.sh
based on [qistoph/awk_netstat.sh](https://gist.github.com/qistoph/1b0708c888f078c3720de6c6f9562997)
### nslookup-multi.sh
Little helper script to find out, if a DNS change already synchronized to some of the major DNS service providers.
### pull-all-git-repos-in-workspace.sh
I usually clone my git repos to `$HOME\workspace`. 
This little helper script pulls all repos in that workspace directory.
### wine-prefix-installer.sh
#### Introduction
This is the probably biggest and most complex script within my toolbox. The script's goal is to help installing Windows software under Linux via Wine, like e. g. also [Lutris](https://lutris.net/), [PlayOnLinux](https://www.playonlinux.com/) or [Bottles](https://usebottles.com/) _(..., which can be also chosen as installation target in my script...)_ do. Main differences of this script are the higher focus on automation and the absence of a GUI _(and of course, that my script is much simpler since it's only an one-person-hobby-project)_.\
It all started with my efforts in bringing O365 to Linux: Therefore, the `wine-prefix-installer.sh` script's forefather is my other GitHub repo [Stumie/wine-prefix_O365](https://github.com/Stumie/wine-prefix_O365), which still exists, but is not publicly available anymore.
#### Known flaws
Before use, be aware of some known flaws:
* The script does have minor error handling. It shouldn't break your system, but still, be cautious and check console output carefully! _(...although wine tends to be very verbose...)_
* The script currently only has dependency installation routines for Debian-based distributions, mainly because of included apt-get commands and apt source installations.
* The script currently automatically installs the most current [WineHQ](https://www.winehq.org/) release of the chosen release branch _(except for the `bottles` variant)_, directly from the WineHQ repositories. Although I'm able to test some releases, I cannot guarantee functionality.
* The script, and especially its `wine-prefix-orders`, include some hardcoded URLs or other clauses, which might get outdated or break in the future. Also here: No guarantee for functionality.
* If you choose `bottles` as your installation target, in the current state Mono and Gecko are not installed by default: That means, that some `wine-prefix-orders`, that do work with the WineHQ variant, might not work with Bottles as installation target _(at least not out of the box)_.
* ...and probably many more flaws...
#### Try Distrobox, e. g. if the script does not work on your system (e. g. most non-Debian systems)
If you e. g. run Fedora Linux, Arch Linux or openSUSE, and the script does not work for you on a regular basis, you might want to still try the script with the help of [distrobox](https://github.com/89luca89/distrobox).
1. Install distrobox on your system: https://github.com/89luca89/distrobox?tab=readme-ov-file#installation
2. Create and enter a Debian-based distrobox container, e. g. like this _(here, in this __example__, to install the wine-prefix-order 'sketchupmake2017de-x64')_:  
`wineprefixinstallerappname="sketchupmake2017de-x64"; distrobox-create --yes --name ${wineprefixinstallerappname} --image quay.io/toolbx-images/debian-toolbox:12; distrobox-enter --no-workdir --name ${wineprefixinstallerappname};`
3. After you entered the newly created, Debian-based distrobox container, you need to add the `contrib` repository to the APT sources, e. g. like this:  
`sudo sed -i 's/Components: main/Components: main contrib/g' /etc/apt/sources.list.d/debian.sources`
4. Unfortunately `lsb_release` does not seem to be installed within that container image. So you have to install it, e. g. like this:  
`sudo apt-get update && sudo apt-get install lsb-release`
5. Then you might want to clone the stubatoo GitHub repository and install the wine-prefix-order 'sketchupmake2017de-x64' into the distrobox container with a single line:  
`cd $HOME && stubatoogitrepourl="https://github.com/Stumie/stubatoo.git" && stubatoogitrepofolder="$HOME/.$(basename -s .git $stubatoogitrepourl)" && { git -C "$stubatoogitrepofolder" pull 2> /dev/null || { mkdir -p "$stubatoogitrepofolder" && git clone "$stubatoogitrepourl" "$stubatoogitrepofolder"; }; } && $stubatoogitrepofolder/wine-prefix-installer.sh stable sketchupmake2017de-x64 && unset stubatoogitrepourl stubatoogitrepofolder`
6. When the script and the 'SketchUp Make 2017' _(or your respective application to be installed)_ installer finished, you could try to start the application from the distrobox container's shell, e. g. like this:  
`WINEPREFIX=$HOME/.wine-prefix/sketchupmake2017de-x64 wine $HOME/.wine-prefix/sketchupmake2017de-x64/drive_c/Program\ Files/SketchUp/SketchUp\ 2017/SketchUp.exe`
7. Normally, you could even export a launcher to the host-system from the distrobox container via `distrobox-export`, e. g. like this:  
`distrobox-export --app SketchUp.desktop`  
Unfortunately, this seems to be broken for the wine-prefix-order 'sketchupmake2017de-x64' (2024-02-25), because the application path contains a whitespace, which is handled incorrectly...
### wine-prefix-remover.sh
With this handy little script you can remove wine prefixes and bottles comfortable, that you formerly created with the help of `wine-prefix-installer.sh`.
