# LSUnusedResources
A Mac App to 

1. find unused images and resources in an XCode project;
2. find total images and resources  in an XCode project;
3. do LinkMap file analysis.

 It is forked from [tinymind/LSUnusedResources](https://github.com/tinymind/LSUnusedResources) and [bang590/linkmap.js](https://gist.github.com/bang590/8f3e9704f1c2661836cd), 
and add the function 2.&& 3. by me.

## Example



## Usage

It's an useful utility tool to check what resources are not being used in your Xcode projects. Very easy to use: 

1. Click `Browse..` to select a project folder.
2. Click `Search` to start searching.
3. Wait a few seconds, the results will be shown in the tableview.
4. click the "Total" radio button to show the total images/resources.

It also can do LinkMap file analysis when you :

1. In XCode -> Project -> Build Settings -> search map -> set "Write Link Map File" to yes，and set the storage locaiton for linkMap;
2. Build the project and find the XX-LinkMap-normal-XXX.txt in the path like:  ```/Users/XXX/Library/Developer/Xcode/DerivedData/XXXX-bcldsniprdstvaduhphplctoilfa/Build/Intermediates.noindex/XXXX.build/Debug-iphonesimulator/XXXX.build/XXXX-LinkMap-normal-x86_64.txt ```
3. Fill the textField in the LinkMap panel with the path above;
4. Click the "Analysis" button and wait to see the result in the below view.

## Installation

* build and run the project using XCode.

## How it works

1. Get resource files (default: `[imageset, jpg, png, gif]`) in these folders `[imageset, launchimage, appiconset, bundle, png]`.
2. Use regex to search all string names in code files (default: `[h, m, mm, swift, xib, storyboard, strings, c, cpp, html, js, json, plist, css]`).
3. Exclude all used string names from resources files, we get all unused resources files.

## Requirements

Requires OS X 10.7 and above, ARC.
