# StuBaToo - Stumie's Bash Toolbox
This repository is a toolbox of Bash scripts, that often rely on each other.\
Its use case is to suit my own needs best. But since most of my needs are probably also someone else's needs, I decided to share my toolbox via GitHub under GPL 3.0 license.
## Scripts
### current-cpu-frequency.sh
Little helper script to show live CPU frequencies over all cores, without installing any bigger tool for that use case.
### get-new-kerberos-ticket.sh
When I sometimes need a new kerberos token, where I almost always forget a step. This little helper stands by.
### install-outlook-on-edge.sh
Creates a nice `*.desktop` file for Microsoft Outlook Web.

> [!WARNING]
> Needs Microsoft Edge installed and openable via `microsoft-edge`. _(So e. g. probably not working with MS Edge installed via Flatpak)_

> [!TIP]
> Is not relying on other sub-scripts, could be easily forked or used independently.
### netstat-without-netstat.sh
based on [qistoph/awk_netstat.sh](https://gist.github.com/qistoph/1b0708c888f078c3720de6c6f9562997)
### nslookup-multi.sh
Little helper script to find out, if a DNS change already synchronized to some of the major DNS service providers.
### pull-all-git-repos-in-workspace.sh
I usually clone my git repos to `$HOME\workspace`. 
This little helper script pulls all repos in that workspace directory.
### wine-prefix-installer.sh
_tbd_
