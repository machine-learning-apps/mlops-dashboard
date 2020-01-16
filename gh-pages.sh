#!/bin/bash

#https://gist.github.com/cobyism/4730490#gistcomment-1394421
git add -f dashboard/_site/ && git commit -m "Initial dist subtree commit" 
git subtree split --prefix dashboard/_site -b gh-pages
git push -f origin gh-pages:gh-pages
git branch -D gh-pages
