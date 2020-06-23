from html import escape as htmlescape
from pwd import getpwnam
import traceback, os, subprocess, pickle

def changeuser():
    p = getpwnam("dummy")
    os.setgid(p.pw_gid)
    os.setuid(p.pw_uid)

def run(args, timelimit=10, input=""):
    if type(input) != str:
        raise ValueError("(std)input should be a string! Not", input)
    try:
        result=subprocess.run(args,
                timeout=timelimit,
                preexec_fn=changeuser,
                start_new_session=True,
                cwd="/home/dummy",
                input=input, shell=False,
                check=False, encoding="utf-8",
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE)
    except subprocess.TimeoutExpired as e:
        return e
    else:
        return result

def formatexception(e):
    if e is None:
        return ""
    return htmlescape("".join(traceback.format_exception(e,e,e.__traceback__)))

def trytoload(filename):
    try:
        with open(filename, "rb") as f:
            return pickle.load(f)
    except OSError:
        return None

def getitems(d, key, default="", nargs=""):
    # no content
    if key not in d:
        if nargs == "*":
            return []
        elif nargs == "+":
            return [default]
        else:
            return default
    
    # single result required
    if nargs == "":
        return d[key]        
    
    # list result (+/*) required
    if type(d[key]) != list:
        return [d[key]]
    
    # content is empty list
    if len(d[key]) == 0:
        if nargs == "+":
            return [default]
        else:
            return []
    # content is non-empty list
    if type(d[key][0]) == type(default):
        return d[key]
    else:
        return [d[key]]
