#! /usr/bin/env python2

import os
import ConfigParser

FMT_HEADER = """
SCRIPT(1)
=========

NAME
----
%s - a
"""

FMT_OPTIONS = """
Options
-------
"""

FMT_OPTION = """
*%s* '%s'::
	default '%s'
....
%s
....
"""

FMT_COMMANDS = """
Commands
--------
"""

FMT_COMMAND = """
*%s*::
....
%s
....
"""

cp = ConfigParser.SafeConfigParser()

cp.read(["out"])

files = {}
for section in cp.sections():
    path = cp.get(section, "file", raw=True)
    type = cp.get(section, "type", raw=True)
    if path not in files:
        files[path] = {
            "options": [],
            "commands": [],
        }

    if type == "option":
        default = "null"
        try:
            default = cp.get(section, "default", raw=True)
        except ConfigParser.NoOptionError as e: pass
        files[path]["options"].append(FMT_OPTION % (section, cp.get(section, "kaktype", raw=True), default, cp.get(section, "docstring", raw=True)))
    elif type == "command":
        files[path]["commands"].append(FMT_COMMAND % (section, cp.get(section, "docstring", raw=True)))
    else:
        raise Exception("unknown type: %s" % type)

for path, d in files.iteritems():
    with open(path, "w") as f:
        f.write(FMT_HEADER % os.path.basename(path).replace(".asciidoc", ""))

        if d["options"]:
            f.write(FMT_OPTIONS)
            for option in d["options"]:
                f.write(option)

        if d["commands"]:
            f.write(FMT_COMMANDS)
            for command in d["commands"]:
                f.write(command)
