#!/usr/bin/python

import sys
import os
import urllib.request, urllib.parse, urllib.error
import urllib.parse
import zipfile
import shutil


###################
# LOCAL FUNCTIONS #
###################

def prepare_workspace(dirs):
    '''
    Create directories recursively, if they don't exist
    '''
    try:
        os.makedirs(dirs)
    except:
        pass

def download_url(url, outdir):
    '''
    Download the file from the URL
    '''
    # get the file name from the URL
    split = urllib.parse.urlsplit(url)
    file = outdir + '/' + split.path.split("/")[-1]
    # downlaod
    urllib.request.urlretrieve(url, file)
    return file

def unzip_file(file, outdir):
    '''
    Extract unzip file
    '''
    with zipfile.ZipFile(file, 'r') as zip_ref:
        zip_ref.extractall(outdir)

def move_files(srcdir, trgdir):
    '''
    Move files
    '''
    dirs = [ name for name in os.listdir(srcdir) if os.path.isdir(os.path.join(srcdir, name)) ]
    srcdir = srcdir + '/' + dirs[0]
    print((srcdir +" > "+ trgdir))
    os.rename( srcdir, trgdir)

def remove_dir(dirs):
    '''
    Remove a directory
    '''
    shutil.rmtree(dirs)


##################
# MAIN FUNCTIONS #
##################
def main(sys):
    '''
    Main function
    '''
    # Get input parameters
    url = sys.argv[1]
    outdir = sys.argv[2]
    tmpdir = sys.argv[3]
    flag_move = True if len(sys.argv) == 5 else False

    print("-- prepare workspaces")
    prepare_workspace(tmpdir)

    print("-- download files: "+url+" > "+tmpdir)
    file = download_url(url, tmpdir)
    if flag_move:
        print("-- unzip files: "+file+" > "+tmpdir)
        unzip_file(file, tmpdir)
        print("-- move files to outdir")
        move_files(tmpdir, outdir)
    else:
        print("-- unzip files: "+file+" > "+outdir)
        unzip_file(file, outdir)

    print("-- remove tmpdir")
    remove_dir(tmpdir)





main(sys)