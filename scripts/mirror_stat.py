#!/usr/bin/env python2
# -*- coding:utf8 -*-

import subprocess as sp
import argparse
import fcntl
import os
import pyinotify
import json
import daemon

SYNC_HOME = os.path.dirname( os.getcwd() )
STAT_DIR = os.path.join( SYNC_HOME, "status" )
LOG_DIR = os.path.join( SYNC_HOME, "logs" )
JSON = "/srv/www/m_status.json"
SRV_ROOT = "/srv/www"
LOG_URL = "/index/mlog"
TMP = "/tmp/status"

class EventHandler(pyinotify.ProcessEvent):
    def process_default( self, event ):
        update_json()

def getlog(logdir):
    p = sp.Popen(
        ['ls','-t',logdir],
        stdout=sp.PIPE, stderr=sp.PIPE
    )
    return p.communicate()[0].split()[0]

def update_json():
    stat_list = os.listdir(STAT_DIR)
    output = {}
    for repo in stat_list:
        stat_file = os.path.join( STAT_DIR, repo )
        try:
            f = open( stat_file, 'r' )
            repo_stat = json.loads( f.read() )
        except :
            pass
        status = repo_stat['status']
        repo_log_dir = os.path.join( LOG_DIR, repo )
        if status != '-1':
            try:
                repo_stat['log'] = repo_stat['log']  or os.path.join(LOG_URL, repo+'.log') 
                slog = os.path.join( repo_log_dir, getlog(repo_log_dir) )
                dlog = SRV_ROOT + repo_stat['log']
                sp.call( ['cp',slog,dlog] ) 
            except:
                pass
        output[repo] = repo_stat 
        f.close()
    json_out = json.dumps( output, sort_keys=True, indent=4 )

    f = open( JSON, 'w' )
    fcntl.flock( f, fcntl.LOCK_SH ) 
    f.write( json_out )
    fcntl.flock( f, fcntl.LOCK_UN )

def inotify_loop():
    IN_MODIFY = pyinotify.IN_MODIFY
    IN_DELETE = pyinotify.IN_DELETE
    wm = pyinotify.WatchManager()

    wm.add_watch( STAT_DIR, IN_MODIFY | IN_DELETE, rec=True )
    eh = EventHandler()
    notifier = pyinotify.Notifier( wm, eh ) 
    notifier.loop()

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Monitor mirror sync status and generate JSON")
    parser.add_argument( '-D', '--daemon', action='store_true', help="Deamonize to monitor" )
    args = parser.parse_args()
    if args.daemon: 
        with daemon.DaemonContext():
            inotify_loop()
    else:
        update_json()
