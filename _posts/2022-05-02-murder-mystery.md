---
title: A SIGKILL murder mystery
---


Today I found myself debugging a mystery kill:

     go test ./...
     [packages passing fine]
     fish: Job 1, 'go test ./...' terminated by signal SIGKILL (Forced quit)

Welp. This is a short writeup so that I remember what I did next time this happens.

First off, things that did not work:

- increasing test timeout
- disabling suspect services like apparmor
- strace -e 'trace=!all' go test ./..., strace also got killed
- looking at journalctl, dmesg

The thing that _did_ work. To install and start auditd:

    sudo apt install auditd


To enable logging of kills:

    sudo auditctl -a exit,always -F arch=b64 -S kill -k audit_kill
    tail -f /var/log/audit/audit.log

But wait:

    type=SYSCALL msg=audit(1651484100.495:62): ... comm="kill" exe="/usr/bin/kill" subj=? key="audit_kill"^]ARCH=x86_64 SYSCALL=kill

So something was killing /usr/bin/kill directly.

Uhhh, time to replace /usr/bin/kill with a script that just runs sleep[^1] and:


    rski@rski ~> lsof /usr/bin/kill
    COMMAND     PID USER   FD   TYPE DEVICE SIZE/OFF     NODE NAME
    kill    2580265 rski  255r   REG  253,1       44 15733179 /usr/bin/kill

    rski@rski ~> pstree -ps 2580265
    systemd(1)───.kitty-wrapped(5514)───fish(2520326)───make(2576202)───sh(2576214)───go(2576215)───somepackage.test(2580252)───kill(2580265)───sleep(2580266)

The call was coming from inside the house. A package that deals with killing other processes was calling kill during testing and blowing itself away.

[^1]: I could have munged the PATH I suppose, yes. Note-to-self-in-note-to-self: Do that next time.
