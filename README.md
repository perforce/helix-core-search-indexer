# Helix Core Search Indexer

This helix server lua extension enables indexing current change as committed to helix server to keep the helix-p4search index up to date.


## Overview

This lua extension needs to be created on the Helix server and is invoked at a commit event by the Helix server.
This documents tells you how to customize the extension to run on any Helix server.


## Requirements

The extension requires a Helix Server version that supports extensions. This is
2019.1 or later for Linux systems.
You will also need the following correctly setup and working:

#### helix-p4search service
You'll need a helix-p4search service running and accessible from the helix server where this extension is installed.

#### Helix user for creating extension
Helix server super access is required to create server side extension.

#### Credentials to access helix-p4search
You will need valid credentials to access helix-p4search endpoint like X-Auth-Token or userid and token/password. 

## Deployment

(1) Ensure that the perforce server has an extensions depot. If not, create one using

    p4 -p localhost:1666 -u super depot -t extension extensions
    
(2) Create a skeleton of a server extension with name helix-core-search-indexer. You need to be in the parent directory of helix-core-search-indexer.

    cd ..
    p4 -plocalhost:1666 -u super extension --package helix-core-search-indexer
    
This will create an extension skeleton named helix-core-search-indexer.p4-extension.
  
(3) Install the server extension.

    p4 -plocalhost:1666 -u super extension -y --install helix-core-search-indexer.p4-extension
     	
(4) Configure the extension's global settings to provide the X-Auth-Token and ExtP4USER.

    	p4 -p localhost:1666 -u super extension --configure Perforce::helix-core-search-indexer
    	
Add the auth_token at the end of global-config.in file without altering spaces/tabs. 
    
        ExtConfig:
        	auth_token:	00000000-0000-0000-0000-000000000000

Change the ExtP4USER to your extension user.

(5) Configure the extension's instance settings.

    p4 -p localhost:1666 -u super extension --configure Perforce::helix-core-search-indexer --name Perforce

(6) Refer to [Helix Core Extensions Developer Guide](https://www.perforce.com/manuals/extensions/Content/Extensions/Home-extensions.html) for more information on helix extension.

(7) You must add a property (P4.P4Search.URL) in helix server which refers to the helix-p4search url.

	p4 -p localhost:1666 -u super property -a -n P4.P4Search.URL -v http://localhost:4567
  
The main.lua depends on this property being set.

## More info

List the extensions on helix server.

    p4 -plocalhost:1666 -usuper extension --list --type=extensions
        
List the extension's configurations.
    
    p4 -plocalhost:1666 -usuper extension --list --type=configs

Delete the extension's directory and extension from helix server.

    rm -f helix-core-search-indexer.p4-extension    
    p4 -plocalhost:1666 -usuper extension -y --delete Perforce::helix-core-search-indexer
