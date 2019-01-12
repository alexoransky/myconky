#
# Alex Oransky, 2018
# https://github.com/alexoransky/myconky
#

DEST='/usr/lib/lua/5.3'

sudo cp colors.lua $DEST
sudo cp fonts.lua $DEST
sudo cp cmds.lua $DEST
sudo cp utils.lua $DEST
sudo cp dbg.lua $DEST
sudo cp netdata/nd.lua $DEST

ls $DEST
