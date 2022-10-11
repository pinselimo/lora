# Welcome to LORA - the LibreOffice Recovery Assistant

LibreOffice's recovery function is great when your machine suddenly crashes while you're writing that all important pamphlet against the closed source conspiracy.
But most of the time it's plain annoying. Asking you to recover files that weren't even edited when you shut down your computer yesterday.

Lora helps you find the right, personalized solution.

## Installation

Lora is a simple ``bash`` script. If you are on a standard Linux distribution move the script to your local binaries..

~~~
$ wget -O ~/.local/bin/lora https://raw.githubusercontent.com/pinselimo/lora/main/lora.sh
~~~

..and make sure [yq](https://kislyuk.github.io/yq/) is installed.

If you are using the ``nix`` package manager and have flakes enabled you can just add this repo to your inputs and use the ``lora`` derivation.

## Usage

To re-open all documents in LibreOffice automatically use ``lora --unsaved`` or ``lora -u``. Without the ``--unsaved`` flag previously unsaved files will not be included.
To additionally suppress LibreOffice's recovery dialogue use the ``--noprompt`` option. This will open any documents scheduled for recovery but not recover any unsaved changes. All entries can be removed using the ``--delete`` flag.

A combination of the ``--noprompt`` and the ``--delete`` flag will lead to the loss of all unsaved edits!

## License

This project is open source under the ``MIT`` license (C) 2022 Simon Plakolb. Find more information in the accompanying ``LICENSE`` file.

