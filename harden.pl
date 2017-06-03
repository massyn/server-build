#!/usr/bin/perl

sub setup_sshd
{
        # == Install OpenSSH server


        &param("/etc/ssh/sshd_config","PermitRootLogin","no");
        &param("/etc/ssh/sshd_config","X11Forwarding","no");
        &param("/etc/ssh/sshd_config","ChallengeResponseAuthentication","yes"); # need this for Google Authenticator
        #&param("/etc/ssh/sshd_config","ClientAliveInterval","300");
        #&param("/etc/ssh/sshd_config","ClientAliveCountMax","0");
        &param("/etc/ssh/sshd_config","IgnoreRhosts","yes");
        &param("/etc/ssh/sshd_config","HostbasedAuthentication","no");
        &param("/etc/ssh/sshd_config","Port",$CONFIG{SSHPORT});
        &param("/etc/ssh/sshd_config","PermitEmptyPasswords","no");
        &param("/etc/ssh/sshd_config","Banner","/etc/issue");
        &param("/etc/ssh/sshd_config","AllowTcpForwarding","no");
        &param("/etc/ssh/sshd_config","LoginGraceTime","30s");
}
