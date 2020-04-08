#!/bin/bash

cd /tmp
rm -rf repo*
mkdir repo1
cd repo1
git init --bare
cd ..
git clone repo1 repo2
cd repo2
echo 'ohai!' >> readme.txt
git add readme.txt
git commit -m"Initial commit"
git push
touch file1.txt
git add .
git commit -F- <<EOF
add capital case subject

body text ex
EOF

echo "message without body check" >> file1.txt
git commit -m"Add message without body" -a
echo "subject without imperative verb check" >> file1.txt
git commit -a -F- <<EOF
Subject without imperative verb

body text ex
EOF

echo "Add subject too long\n\n" >> file1.txt

git commit -a -F- <<EOF
Add subject too long...........................

body text ex
EOF

echo "Add body too short" >> file1.txt

git commit -a -F- <<EOF
Add body too short

short
EOF