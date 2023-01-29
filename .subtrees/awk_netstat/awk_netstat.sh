# Based on gist https://gist.github.com/staaldraad/4c4c80800ce15b6bef1c1186eaa8da9f
# - added TCP states

awk 'BEGIN{states["01"]="TCP_ESTABLISHED"
states["02"]="TCP_SYN_SENT"
states["03"]="TCP_SYN_RECV"
states["04"]="TCP_FIN_WAIT1"
states["05"]="TCP_FIN_WAIT2"
states["06"]="TCP_TIME_WAIT"
states["07"]="TCP_CLOSE"
states["08"]="TCP_CLOSE_WAIT"
states["09"]="TCP_LAST_ACK"
states["0A"]="TCP_LISTEN"
states["0B"]="TCP_CLOSING"
states["0C"]="TCP_NEW_SYN_RECV"
}
function hextodec(str,ret,n,i,k,c){
    ret = 0
    n = length(str)
    for (i = 1; i <= n; i++) {
        c = tolower(substr(str, i, 1))
        k = index("123456789abcdef", c)
        ret = ret * 16 + k
    }
    return ret
}
function getIP(str,ret){
    ret=hextodec(substr(str,index(str,":")-2,2));
    for (i=5; i>0; i-=2) {
        ret = ret"."hextodec(substr(str,i,2))
    }
    ret = ret":"hextodec(substr(str,index(str,":")+1,4))
    return ret
}
NR > 1 {{if(NR==2)print "Local - Remote";local=getIP($2);remote=getIP($3)}{print local" - "remote" "states[$4]}}' /proc/net/tcp
