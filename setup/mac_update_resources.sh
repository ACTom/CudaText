#!/bin/sh
from=~/cuda/cuda/app
app=~/cuda/cuda/app/cudatext.app

rm -rf $app/Contents/Resources/data
rm -rf $app/Contents/Resources/readme
rm -rf $app/Contents/Resources/sett*

cp -rf $from/data $app/Contents/Resources
cp -rf $from/readme $app/Contents/Resources
cp -rf $from/settings_default $app/Contents/Resources

mkdir $app/Contents/Resources/py
mkdir $app/Contents/Resources/py/cuda_addonman
mkdir $app/Contents/Resources/py/cuda_insert_time
mkdir $app/Contents/Resources/py/cuda_make_plugin
mkdir $app/Contents/Resources/py/cuda_multi_installer
mkdir $app/Contents/Resources/py/cuda_comments
mkdir $app/Contents/Resources/py/cuda_new_file
mkdir $app/Contents/Resources/py/cuda_options_editor
mkdir $app/Contents/Resources/py/cuda_palette
mkdir $app/Contents/Resources/py/cuda_project_man
mkdir $app/Contents/Resources/py/cuda_tabs_list
mkdir $app/Contents/Resources/py/cuda_show_unsaved
mkdir $app/Contents/Resources/py/requests
mkdir $app/Contents/Resources/py/chardet
mkdir $app/Contents/Resources/py/urllib3
mkdir $app/Contents/Resources/py/certifi
mkdir $app/Contents/Resources/py/idna

cp $from/py/*.py $app/Contents/Resources/py
cp $from/py/cuda_addonman/*.inf $app/Contents/Resources/py/cuda_addonman
cp $from/py/cuda_addonman/*.py $app/Contents/Resources/py/cuda_addonman
cp $from/py/cuda_insert_time/*.py $app/Contents/Resources/py/cuda_insert_time
cp $from/py/cuda_insert_time/*.in* $app/Contents/Resources/py/cuda_insert_time
cp $from/py/cuda_make_plugin/*.py $app/Contents/Resources/py/cuda_make_plugin
cp $from/py/cuda_make_plugin/*.inf $app/Contents/Resources/py/cuda_make_plugin
cp $from/py/cuda_multi_installer/*.py $app/Contents/Resources/py/cuda_multi_installer
cp $from/py/cuda_multi_installer/*.inf $app/Contents/Resources/py/cuda_multi_installer
cp $from/py/cuda_comments/*.py $app/Contents/Resources/py/cuda_comments
cp $from/py/cuda_comments/*.inf $app/Contents/Resources/py/cuda_comments
cp $from/py/cuda_new_file/*.py $app/Contents/Resources/py/cuda_new_file
cp $from/py/cuda_new_file/*.inf $app/Contents/Resources/py/cuda_new_file
rm -rf $from/py/cuda_project_man/__pycache__
cp -rf $from/py/cuda_project_man/* $app/Contents/Resources/py/cuda_project_man
rm -rf $from/py/cuda_options_editor/__pycache__
cp -rf $from/py/cuda_options_editor/* $app/Contents/Resources/py/cuda_options_editor
rm -rf $from/py/cuda_tabs_list/__pycache__
cp -rf $from/py/cuda_tabs_list/* $app/Contents/Resources/py/cuda_tabs_list
rm -rf $from/py/cuda_show_unsaved/__pycache__
cp -rf $from/py/cuda_show_unsaved/* $app/Contents/Resources/py/cuda_show_unsaved
cp -rf $from/py/cuda_palette/* $app/Contents/Resources/py/cuda_palette
cp -rf $from/py/requests $app/Contents/Resources/py
cp -rf $from/py/chardet $app/Contents/Resources/py
cp -rf $from/py/urllib3 $app/Contents/Resources/py
cp -rf $from/py/certifi $app/Contents/Resources/py
cp -rf $from/py/idna $app/Contents/Resources/py

echo Done
