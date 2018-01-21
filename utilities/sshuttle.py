#!/usr/bin/env python

import subprocess
import sys
import time
import traceback


def main():
    try:
        gateway = sys.argv[1]
        subnets = sys.argv[2:]

    except Exception:
        print traceback.format_exc()
        usage()

    command = 'sshuttle -v -r %s %s' % (gateway, ' '.join(subnets))
    print '-' * 10, command
    proc = subprocess.Popen(['/bin/bash', '-c', command])
    proc.communicate()

    # reconnect if sub/child process is terminated
    while True:
        if proc.returncode is not None:
            proc = subprocess.Popen(['/bin/bash', '-c', command])
            out, err = proc.communicate()
        reconnect_poll_interval = 5
        time.sleep(reconnect_poll_interval)
        print "proc.returncode=%s" % proc.returncode


def usage():
    print """
./sshuttle.py <gateway> <subnet1> <subnet2> ...
"""


if __name__ == "__main__":
    main()
