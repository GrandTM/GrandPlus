THIS_DIR=$(cd $(dirname $0); pwd)
cd $THIS_DIR

install() {
      wget "https://valtman.name/files/telegram-cli-1222"
     mv telegram-cli-1222 tg
     sudo chmod +x tg
echo -e "———————————————————————————————————————————————————————————\n"
      echo -e "               Write to launch a source command                            in the terminal ./launch.sh          \n"
echo -e "———————————————————————————————————————————————————————————\n"
}

if [ "$1" = "install" ]; then
install
else
if [ ! -f ./tg ]; then
echo "TG not found"
echo "Run $0 install"
exit 1
fi
./tg -s bot.lua
fi
