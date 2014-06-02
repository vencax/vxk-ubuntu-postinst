#!/usr/bin/python

import re
import sys


def add(f, name, mac, ip):
    lines = f.readlines()
    del(lines[len(lines) - 1])  # rem the lasts
    for l in _populateRec(name, mac, ip):
        lines.append(l)
    lines.append('}\n')
    return ''.join(lines)


def _populateRec(name, mac, ip):
    return [
        '\thost %s {\n' % name,
        '\t\thardware ethernet %s;\n' % mac,
        '\t\tfixed-address %s;\n' % ip,
        '\t}\n']


endHostRe = re.compile('}\n')
def rem(f, name):
    lines = []
    within = False
    for l in f:
        if not within:
            if re.search('host %s {' % name, l):
                within = True
            else:
                lines.append(l)
        else:
            if endHostRe.search(l):
                within = False
    return ''.join(lines)


if __name__ == '__main__':
    confFile = '/etc/dhcp/dhcpd.conf'
    action = sys.argv[1]
    if action == 'add':
        with open(confFile, 'r') as f:
            newContent = add(f, sys.argv[2], sys.argv[3], sys.argv[4])
    elif action == 'del':
        with open(confFile, 'r') as f:
            newContent = rem(f, sys.argv[2])

    with open(confFile, 'w') as f:
        f.write(newContent)
