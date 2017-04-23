tdcli = dofile('./tdcli.lua')
URL = require "socket.url"
http = require "socket.http"
https = require "ssl.https"
ltn12 = require "ltn12"
serpent = require ("serpent")
db = require('redis')
redis = db.connect('127.0.0.1', 6379)
JSON = require('dkjson')
http.TIMEOUT = 10
--###############################--
sudo_users = {305941305}

--##########GetMessage###########--
local function getMessage(chat_id, message_id,callback)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, callback, nil)
end

--###############################--
function is_sudo(msg)
local var = false
for v,user in pairs(sudo_users) do
  if user == msg.sender_user_id_ then
    var = true
  end
end
return var
end
--###############################--
function is_owner(msg)
local var = false
local group_mods = redis:get('owners:'..msg.chat_id_)
if group_mods == tostring(msg.sender_user_id_) then
  var = true
end
for v, user in pairs(sudo_users) do
  if user == msg.sender_user_id_ then
    var = true
  end
end
return var
end
--###############################--
function is_momod(msg)
local var = false
if redis:sismember('mods:'..msg.chat_id_,msg.sender_user_id_) then
  var = true
end
if redis:get('owners:'..msg.chat_id_) == tostring(msg.sender_user_id_) then
  var = true
end
for v, user in pairs(sudo_users) do
  if user == msg.sender_user_id_ then
    var = true
  end
end
return var
end
--###############################--
function is_banned(msg)
local var = false
local chat_id = msg.chat_id_
local user_id = msg.sender_user_id_
local hash = 'banned:'..chat_id
local banned = redis:sismember(hash, user_id)
if banned then
  var = true
end
return var
end
--###############################--
function is_muted(msg)
local var = false
local chat_id = msg.chat_id_
local user_id = msg.sender_user_id_
local hash = 'muteusers:'..chat_id
local muted = redis:sismember(hash, user_id)
if muted then
  var = true
end
return var
end
--###############################--
function is_gbanned(msg)
local var = false
local chat_id = msg.chat_id_
local user_id = msg.sender_user_id_
local hash = 'gbanned:'
local banned = redis:sismember(hash, user_id)
if banned then
  var = true
end
return var
end
--###############################--
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function run(data,edited_msg)
local msg = data.message_
if edited_msg then
  msg = data
end
-- vardump(msg)
local input = msg.content_.text_
local chat_id = msg.chat_id_
local user_id = msg.sender_user_id_
local botgp = redis:get("addedgp"..chat_id)
local wlcmsg = "wlc"..chat_id
local setwlc = "setwlc"..chat_id
local floodMax = "floodMax"..chat_id
local floodTime = "floodTime"..chat_id
local mutehash = 'muteall:'..chat_id
local hashflood = "flood"..chat_id
local hashbot = "bot"..chat_id
local hashlink = "link"..chat_id
local hashtag = "tag"..chat_id
local hashusername = "username"..chat_id
local hashforward = "forward"..chat_id
local hasharabic = "arabic"..chat_id
local hashtgservice = "tgservice"..chat_id
local hasheng = "eng"..chat_id
local hashbadword = "badword"..chat_id
local hashedit = "edit"..chat_id
local hashinline = "inline"..chat_id
local hashemoji = "emoji"..chat_id
local hashall = "all"..chat_id
local hashsticker = "sticker"..chat_id
local hashgif = "gif"..chat_id
local hashcontact = "contact"..chat_id
local hashphoto = "photo"..chat_id
local hashaudio = "audio"..chat_id
local hashvoice = "voice"..chat_id
local hashvideo = "video"..chat_id
local hashdocument = "document"..chat_id
local hashtext1 = "text"..chat_id
if not botgp and not is_sudo(msg) then
  return false
end
if msg.chat_id_ then
  local id = tostring(msg.chat_id_)
  if id:match('-100(%d+)') then
    chat_type = 'super'
  elseif id:match('^(%d+)') then
    chat_type = 'user'
  else
    chat_type = 'group'
  end
end
-------------------------------------------------------------------------------------------
if redis:get(mutehash) == 'Enable' and not is_momod(msg) then
  tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
if msg.content_.sticker_ and redis:get(hashsticker) == 'Enable' and not is_momod(msg) then
  tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
if msg.content_.animation_ and redis:get(hashgif) == 'Enable' and not is_momod(msg) then
   tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
if msg.content_.contact_ and redis:get(hashgif) == 'Enable' and not is_momod(msg) then
  tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
if msg.content_.photo_ and redis:get(hashgif) == 'Enable' and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
if msg.content_.audio_ and redis:get(hashaudio) == 'Enable' and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
if msg.content_.voice_ and redis:get(hashvoice) == 'Enable' and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
if msg.content_.video_ and redis:get(hashvideo) == 'Enable' and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
if msg.content_.document_ and redis:get(hashdocument) == 'Enable' and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
if msg.forward_info_ and redis:get(hashforward) == 'Enable' and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end
if msg.via_bot_user_id_ ~= 0 and redis:get(hashinline) == 'Enable' and not is_momod(msg) then
  tdcli.deleteMessages(chat_id, {[0] = msg.id_})
end

local floodMax = redis:get('floodMax') or 10
local floodTime = redis:get('floodTime') or 150
if msg and redis:get(hashflood) == 'Enable' and not is_momod(msg) then
  local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
  local msgs = tonumber(redis:get(hash) or 0)
  if msgs > (floodMax - 1) then
    tdcli.changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر _'..msg.sender_user_id_..' به دلیل ارسال اسپم حذف شد!', 1, 'md')
    redis:setex(hash, floodTime, msgs+1)
  end
end


if msg.content_.ID == "MessageText" then
  local is_link_msg = input:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or input:match("[Tt].[Mm][Ee]/")
  if redis:get(hashlink) and is_link_msg and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
  end
  if redis:get(hashtag) and input:match("#") and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
  end
  if redis:get(hashusername) and input:match("@") and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})

  end
  if redis:get(hasharabic) and input:match("[\216-\219][\128-\191]") and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
  end
  local is_english_msg = input:match("[a-z]") or input:match("[A-Z]")
  if redis:get(hasheng) and msg.content_.text_ and is_english_msg and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
  end
  local is_fosh_msg = input:match("کیر") or input:match("کس") or input:match("کون") or input:match("85") or input:match("جنده") or input:match("ننه") or input:match("ننت") or input:match("مادر") or input:match("قهبه") or input:match("گایی") or input:match("سکس") or input:match("kir") or input:match("kos") or input:match("kon") or input:match("nne") or input:match("nnt")
  if redis:get(hashbadword) and is_fosh_msg and not is_momod(msg) then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
  end
  local is_emoji_msg = input:match("😀") or input:match("😬") or input:match("😁") or input:match("😂") or  input:match("😃") or input:match("😄") or input:match("😅") or input:match("☺️") or input:match("🙃") or input:match("🙂") or input:match("😊") or input:match("😉") or input:match("😇") or input:match("😆") or input:match("😋") or input:match("😌") or input:match("😍") or input:match("😘") or input:match("😗") or input:match("😙") or input:match("😚") or input:match("🤗") or input:match("😎") or input:match("🤓") or input:match("🤑") or input:match("😛") or input:match("😏") or input:match("😶") or input:match("😐") or input:match("😑") or input:match("😒") or input:match("🙄") or input:match("🤔") or input:match("😕") or input:match("😔") or input:match("😡") or input:match("😠") or input:match("😟") or input:match("😞") or input:match("😳") or input:match("🙁") or input:match("☹️") or input:match("😣") or input:match("😖") or input:match("😫") or input:match("😩") or input:match("😤") or input:match("😲") or input:match("😵") or input:match("😭") or input:match("😓") or input:match("😪") or input:match("😥") or input:match("😢") or input:match("🤐") or input:match("😷") or input:match("🤒") or input:match("🤕") or input:match("😴") or input:match("💋") or input:match("❤️")
  if redis:get(hashemoji) and is_emoji_msg and not is_momod(msg)  then
    tdcli.deleteMessages(chat_id, {[0] = msg.id_})
  end
end
--###############################--
local text = msg.content_.text_
-- if text and text:match('[QWERTYUIOPASDFGHJKLZXCVBNM]') then
  -- text = text:lower()
-- end
if msg.content_.ID == "MessageText" then
  msg_type = 'text'
  if msg_type == 'text' and text and text:match('^[/$#!]') then
    text = text:gsub('^[/$!#]','')
  end
end
if text == "p r" and is_sudo(msg) then
tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'ربات* موفقیت ریلود شد*',1, 'html')
  io.popen("pkill tg")
end
if text == "ping" then
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '*انلاینم....!*',1, 'md')
  end
local hashadd = "addedgp"..chat_id
if text == "add" and is_sudo(msg) then
  if botgp then
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '*ربات از قبل با موفقیت فعال شده بود!*', 1, 'md')
  else
    redis:set(hashadd, true)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '*ربات با موفقیت فعال شد.*', 1, 'md')
  end
end
if text == "rem" and is_sudo(msg) then
  if not botgp then
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '*ربات از قبل با موفقیت غیر فعال شده بود!*', 1, 'md')
  else
    redis:del(hashadd, true)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '*ربات با موفقیت غیر فعال شد.*', 1, 'md')
  end
end

if text == "setowner" and is_owner(msg) and msg.reply_to_message_id_ then
  function setowner_reply(extra, result, success)
    redis:del('owners:'..result.chat_id_)
    redis:set('owners:'..result.chat_id_,result.sender_user_id_)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر *'..result.sender_user_id_..'* باموفقیت مالک گروه شد', 1, 'md')
  end
  getMessage(chat_id,msg.reply_to_message_id_,setowner_reply,nil)
end
if text == "owners" then
  local hash = 'owners:'..chat_id
  local owner = redis:get(hash)
  if owner == nil then
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'گروه هیچ مالکی ندارد ', 1, 'md')
  end
  local owner_list = redis:get('owners:'..chat_id)
  text = '* مالک گروه:* '..owner_list
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text and text:match('^setowner (.*)') and not text:find('@') and is_sudo(msg) then
  local so = {string.match(text, "^setowner (.*)$")}
  redis:del('owners:'..chat_id)
  redis:set('owners:'..chat_id,so[1])
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..so[1]..' به موفقیت مالک گروه شد', 1, 'md')
end
if text and text:match('^setowner (.*)') and text:find('@') and is_owner(msg) then
  local sou = {string.match(text, "^setowner (.*)$")}
  function Inline_Callback_(arg, data)
    redis:del('owners:'..chat_id)
    redis:set('owners:'..chat_id,sou[1])
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..sou[1]..' با موفقیت مالک گروه شد', 1, 'md')
  end
  tdcli_function ({ID = "SearchPublicChat",username_ =sou[1]}, Inline_Callback_, nil)
end

 
if text == "promote" and is_sudo(msg) and msg.reply_to_message_id_ then
  function setmod_reply(extra, result, success)
    redis:sadd('mods:'..result.chat_id_,result.sender_user_id_)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..result.sender_user_id_..' به لیست ناظران گروه اضافه شد', 1, 'md')
  end
 getMessage(chat_id,msg.reply_to_message_id_,setmod_reply,nil)
end
if text == "demote" and is_sudo(msg) and msg.reply_to_message_id_ then
  function remmod_reply(extra, result, success)
    redis:srem('mods:'..result.chat_id_,result.sender_user_id_)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..result.sender_user_id_..' از لیست ناظران گروه حذف شد', 1, 'md')
  end
  getMessage(chat_id,msg.reply_to_message_id_,remmod_reply,nil)
end
if text and text:match('^promote (.*)') and not text:find('@') and is_sudo(msg) then
  local pm = {string.match(text, "^promote (.*)$")}
  redis:sadd('mods:'..chat_id,pm[1])
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..pm[1]..' به لیست ناظران گروه اضافه شد', 1, 'md')
end
if text and text:match('^demote (.*)') and not text:find('@') and is_sudo(msg) then
  local dm = {string.match(text, "^demote (.*)$")}
  redis:srem('mods:'..chat_id,dm[1])
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..dm[1]..' از لیست ناظران گروه حذف شد', 1, 'md')
end
if text == "modlist" then
  if redis:scard('mods:'..chat_id) == 0 then
   text = "لیست ناظران گروه خالی است"
  else
  text = "لیست ناظران گروه\n"
  for k,v in pairs(redis:smembers('mods:'..chat_id)) do
    text = text.."<b>"..k.."</b> - <b>"..v.."</b>\n"
  end
end
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end
--[[if txet == "ban" and is_momod(msg) then
  function ban_reply(extra, result, success)
 redis:sadd('banned:'..result.chat_id_,result.sender_user_id_)
 tdcli.changeChatMemberStatus(result.chat_id_, result.sender_user_id_, 'Kicked')
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..result.sender_user_id_..' به لیست افراد بن شده اضافه شد', 1, 'md')
  end
getMessage(chat_id,reply,ban_reply,nil)
end
end
if text and text:match('^ban (.*)') and not text:find('@') and is_momod(msg) then
  local ki = {string.match(text, "^ban (.*)$")}
redis:sadd('banned:'..chat_id,ki[1])
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..ki[1]..' به لیست افراد بن شده اضافه شد', 1, 'md')
  tdcli.changeChatMemberStatus(chat_id, ki[1], 'Kicked')
end
if text and text:match('^ban @(.*)') and is_momod(msg) then
  local ku = {string.match(text, "^ban @(.*)$")}
redis:sadd('banned:'..chat_id,ku[1])
  function Inline_Callback_(arg, data)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..ku[1]..' به لیست افراد بن شده اضافه شد', 1, 'html')
    tdcli.changeChatMemberStatus(chat_id, data.id_, 'Kicked')
  end

if txet == "unban" and is_momod(msg) then
  function unban_reply(extra, result, success)
 redis:srem('banned:'..result.chat_id_,result.sender_user_id_)

    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..result.sender_user_id_..' از لیست افراد بن شده حذف شد', 1, 'md')
  end
  getMessage(chat_id,reply,unban_reply,nil)
end
if text and text:match('^unban (.*)') and not text:find('@') and is_momod(msg) then
  local ki = {string.match(text, "^unban (.*)$")}
redis:srem('banned:'..chat_id,ub[1])
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..ub[1]..' از لیست افراد بن شده حذف شد', 1, 'md')
end
if text and text:match('^unban @(.*)') and is_momod(msg) then
  local ku = {string.match(text, "^unban @(.*)$")}
redis:srem('banned:'..chat_id,unb[1])
  function Inline_Callback_(arg, data)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..unb[1]..' از لیست افراد بن شده حذف شد', 1, 'html')
  end
  tdcli_function ({ID = "SearchPublicChat",username_ =unb[1]}, Inline_Callback_, nil)
end]]--
if text == "banlist" then

  if redis:scard('banned:'..chat_id) == 0 then
   text = "لیست بن های گروه خالی است"
  else
  text = "بن لیست گروه\n"
  for k,v in pairs(redis:smembers('banned:'..chat_id)) do
    text = text.."<b>"..k.."</b> - <b>"..v.."</b>\n"
  end
end
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end
if text == "muteuser" and is_momod(msg) and msg.reply_to_message_id_ then
  function setmute_reply(extra, result, success)
    redis:sadd('muteusers:'..result.chat_id_,result.sender_user_id_)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..result.sender_user_id_..' به لیست ساکت ها اضافه شد', 1, 'md')
  end
getMessage(chat_id,msg.reply_to_message_id_,setmute_reply,nil)
end
if text == "unmuteuser" and is_momod(msg) and msg.reply_to_message_id_ then
  function demute_reply(extra, result, success)
    redis:srem('muteusers:'..result.chat_id_,result.sender_user_id_)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..result.sender_user_id_..' از لیست ساکت ها حذف شد', 1, 'md')
  end
  getMessage(chat_id,msg.reply_to_message_id_,demute_reply,nil)
end
if text and text:match("^muteuser (%d+)") and is_momod(msg) then
  local mt = {string.match(text, "^muteuser (%d+)$")}
  redis:sadd('muteusers:'..chat_id,mt[1])
     tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..mt[1]..' به لیست ساکت ها اضافه شد', 1, 'md')
end
if text and text:match('^unmuteuser (%d+)$') and is_momod(msg) then
  local umt = {string.match(text, "^muteuser (%d+)$")}
  redis:srem('muteusers:'..chat_id,umt[1])
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر '..umt[1]..' از لیست ساکت ها حذف شد', 1, 'md')
end
if text == "mutelist" then
  if redis:scard('muteusers:'..chat_id) == 0 then
   text = "لیست بن های گروه خالی است"
  else
  text = "بن لیست گروه\n"
  for k,v in pairs(redis:smembers('muteusers:'..chat_id)) do
    text = text.."<b>"..k.."</b> - <b>"..v.."</b>\n"
  end
end
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end
if text and text:match("^clean (.*)$") and is_momod(msg) then
  local txt = {string.match(text, "^(clean) (.*)$")}
  if txt[2] == 'banlist' then
    redis:del('banned:'..msg.chat_id_)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '_لیست بن با موفقیت حذف شد_', 1, 'md')
  end
  if txt[2] == 'modlist' then
    redis:del('mods:'..msg.chat_id_)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '_لیست ناظران گروه با موفقیت حذف شد _', 1, 'md')
  end
  if txt[2] == 'mutelist' then
    redis:del('muted:'..msg.chat_id_)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '_لیست ساکت های گروه با موفقیت حذف شد_', 1, 'md')
  end

end
if text == "delall" and msg.reply_to_message_id_ then
  function delall(extra, result, success)
    tdcli.deleteMessagesFromUser(result.chat_id_, result.sender_user_id_)
  end
  getMessage(chat_id, msg.reply_to_message_id_, delall, nil)
end
if text and text:match('^setlink (.*)/joinchat/(.*)') and is_owner(msg) then
  local l = {string.match(text, '^setlink (.*)/joinchat/(.*)')}
  redis:set('gplink'..chat_id,"https://t.me/joinchat/"..l[2])
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, 'لینک گروه با موفقیت ثبت شد.', 1, 'html')
end
if text == "link"  and is_momod(msg) then
  local linkgp = redis:get('gplink'..chat_id)
  if not linkgp then
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '<code>لینک ورود به گروه تنظیم نشده.</code>\n<code>ثبت لینک جدید با دستور</code>\n<b>/setlink</b> <i>لینک</i>', 1, 'html')
    return
  else
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '<b>لینک گروه :</b>\n'..linkgp, 1, 'html')
  end
end
if text and text:match('^setrules (.*)') and is_owner(msg) then redis:set('gprules'..chat_id,text:match('^setrules (.*)'))
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '*قوانین گروه با موفقیت تنظیم شد*', 1, 'md')
end
if text == "rules" then
  rules = redis:get('gprules'..chat_id)
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '<b>قوانین گروه :</b>\n'..rules, 1, 'html')
end
if text and text:match('^setname (.*)$')  and is_momod(msg)  then
  local matches = {string.match(text, '^setname (.*)$')}
  tdcli.changeChatTitle(chat_id, matches[1])
end
if text == "leave" and is_sudo(msg) then
  function botid(a,b,c)
    tdcli.changeChatMemberStatus(chat_id, b.id_, "Left")
  end
  tdcli.getMe(botid, nil)
end
if text == "settings" and is_momod(msg)  then
  local text = "————————\n_📛تنظیمات گروه📛_ \n————————\n◾️قفل‌لینک : "..(redis:get(hashlink) or "Disabled").."\n◾️️قفل‌فلود :  "..(redis:get(hashflood) or "Disabled").."\n◾️قفل‌فوروارد :  "..(redis:get(hashforward) or "Disabled").."\n◾️قفل‌تگ(#) "..(redis:get(hashtag) or "Disabled").."\n◾️قفل‌یوزرنیم(@) : "..(redis:get(hashusername) or "Disabled").."\n◾️قفل‌ربات : "..(redis:get(hashbot) or "Disabled").."\n◾️قفل‌ورود‌و‌خروج "..(redis:get(hashtgservice) or "Disabled").."\n◾️قفل‌عربی/فارسی : "..(redis:get(hasharabic) or "Disabled").."\n◾️قفل‌انگلیسی : "..(redis:get(hasheng) or "Disabled").."\n" 
  text = text.."◾️️قفل‌فحش : "..(redis:get(hashbadword) or "Disabled").."\n◾️قفل‌مخاطب :  "..(redis:get(hashcontact) or "Disabled").."\n◾️قفل‌استیکر :  "..(redis:get(hashsticker) or "Disabled").."\n" 
  text = text.."◾️قفل‌کیبور‌انلاین : "..(redis:get(hashinline) or "Disabled").."\n◾️قفل‌ایموجی : "..(redis:get(hashemoji) or "Disabled").."\n" 
  text = text.."————————\n_📛فیلتر لیست📛_\n————————\n◾️فیلتر‌گیف : "..(redis:get(hashgif) or "Disabled").."\n◾️فیلتر‌عکس : "..(redis:get(hashphoto) or "Disabled").."\n◾️فیلتر‌اهنگ : "..(redis:get(hashaudio) or "Disabled").."\n" 
  text = text.."◾️فیلتر‌‌‌وییس : "..(redis:get(hashvoice) or "Disabled").."\n◾️فیلتر‌ویدیو : "..(redis:get(hashvideo) or "Disabled").."\n◾️فیلتر‌فایل : "..(redis:get(hashdocument) or "Disabled").."\n◾️فیلتر‌متن : "..(redis:get(hashtext1) or "Disabled").."\n"
     text = text.."————————\n_📛دیگر تنظیمات📛_\n————————\n◾️زمان فلود : *"..floodTime.."*\n◾️تعداد فلود : *"..floodMax.."*"
        text = string.gsub(text, "Enable", "✅")
        text = string.gsub(text, "Disabled", "⛔️")
        text = string.gsub(text, ":", "*>*")
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "lock flood" and is_momod(msg) then
if redis:get(hashflood) == "Enable" then
  local text = "قفل فلود از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashflood ,"Enable")
  local text = "قفل فلود باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock flood"  and is_momod(msg) then
if not redis:get(hashflood) == "Enable" then
  local text = "قفل فلود از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashflood)
  local text = "قفل فلود باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock bots" and is_momod(msg) then
if redis:get(hashbot) == "Enable" then
  local text = "قفل ربات از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashbot ,"Enable")
  local text = "قفل ورود ربات باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock bots"  and is_momod(msg) then
if not redis:get(hashbot) == "Enable" then
  local text = "قفل ربات از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashbot)
  local text = "قفل ورود ربات باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock tgservice" and is_momod(msg) then
if redis:get(hashtgservice) == "Enable" then
  local text = "قفل پیام ورود و خروج از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashtgservice ,"Enable")
  local text = "قفل پیام ورود و خروج باموفقیت فعال شد"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock tgservice"  and is_momod(msg) then
if not redis:get(hashtgservice) == "Enable" then
  local text = "قفل پیام ورود و خروج از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashtgservice)
  local text = "قفل پیام ورود و خروج  باموفقیت غیرفعال شد"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock links" and is_momod(msg)  then
if redis:get(hashlink) == "Enable" then
local text = "قفل لینک از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashlink ,"Enable")
  local text = "قفل لینک باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock links" and is_momod(msg)  then
if not redis:get(hashlink) == "Enable" then
local text = "قفل لینک از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashlink)
  local text = "قفل لینک باموفقیت غیر فعال شد!"
   tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock tag" and is_momod(msg)  then
if redis:get(hashtag) == "Enable" then
local text = "قفل تگ [#] از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashtag ,"Enable")
  local text = "قفل تگ [#] باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock tag"  and is_momod(msg) then
if not redis:get(hashtag) == "Enable" then
local text = "قفل تگ [#] از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashtag)
    local text = "قفل تگ [#] باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock username" and is_momod(msg)  then
if redis:get(hashusername) == "Enable" then
local text = "قفل یوزرنیم (@) از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashusername ,"Enable")
  local text = "قفل یوزرنیم (@) باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock username" and is_momod(msg)  then
if not redis:get(hashusername) == "Enable" then
local text = "قفل یوزرنیم (@) از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashusername)
  local text = "قفل نام یوزرنیم (@) باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock forward"  and is_momod(msg) then
if redis:get(hashforward) == "Enable" then
local text = "قفل فوروارد از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashforward ,"Enable")
  local text = "قفل فروارد باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock forward" and is_momod(msg)  then
if not redis:get(hashforward) == "Enable" then
local text = "قفل فوروارد از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashforward)
  local text = "قفل فروارد باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock arabic"  and is_momod(msg) then
if redis:get(hasharabic) == "Enable" then
local text = "قفل عربی/فارسی از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hasharabic ,"Enable")
  local text = "قفل زبان عربی/فارسی باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock arabic"  and is_momod(msg) then
if not redis:get(hasharabic) == "Enable" then
local text = "قفل عربی/فارسی از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hasharabic)
  local text = "قفل زبات عربی/فارسی باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock english"  and is_momod(msg) then
if redis:get(hasheng) == "Enable" then
local text = "قفل زبان انگلیسی از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hasheng ,"Enable")
  local text = "قفل زبان انگلیسی باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock english"  and is_momod(msg) then
if not redis:get(hasheng) == "Enable" then
local text = "قفل زبان انگلیسی از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hasheng)
  local text = "قفل زبان انگلیسی باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "lock fosh"  and is_momod(msg) then
if redis:get(hashbadword) == "Enable" then
local text = "قفل فحش از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashbadword ,"Enable")
  local text = "قفل فحش باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock fosh" and is_momod(msg)  then
if not redis:get(hashbadword) == "Enable" then
local text = "قفل فحش از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashbadword)
  local text = "قفل فحش باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock inline" and is_momod(msg)  then
if redis:get(hashinline) == "Enable" then
local text = "قفل دکمه شیشه ای از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashinline ,"Enable")
  local text = "قفل دکمه شیشه ای باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock inline" and is_momod(msg)  then
if not redis:get(hashinline) == "Enable" then
local text = "قفل دکمه شیشه ای از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashinline)
  local text = "قفل دکمه شیشه ای باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock emoji" and is_momod(msg)  then
if redis:get(hashemoji) == "Enable" then
local text = "قفل ایموجی (😄) از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashemoji ,"Enable")
  local text = "قفل ایموجی (😄) باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "unlock emoji" and is_momod(msg)  then
if not redis:get(hashemoji) == "Enable" then
local text = "قفل ایموجی (😄) از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashemoji)
  local text = "قفل ایموجی (😄) باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock contact" and is_momod(msg)  then
if redis:get(hashcontact) == "Enable" then
local text = "قفل اشتراک گذاری مخاطبین از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashcontact ,"Enable")
  local text = "قفل اشتراک گذاری مخاطبین باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock contact" and is_momod(msg)  then
if not redis:get(hashcontact) == "Enable" then
local text = "قفل اشتراک گذاری مخاطبین از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashcontact)
  local text = "قفل اشتراک گذاری مخاطبین باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "lock sticker" and is_momod(msg)  then
if redis:get(hashcontact) == "Enable" then
local text = "قفل ارسال استیکر از قبل فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:set(hashsticker ,"Enable")
  local text = "قفل ارسال استیکر باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end
if text == "unlock sticker" and is_momod(msg)  then
if not redis:get(hashcontact) == "Enable" then
local text = "قفل ارسال استیکر از قبل غیر فعال شده بود!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
else
  redis:del(hashsticker)
  local text = "قفل ارسال استیکر باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
end

if text == "mute gif" and is_momod(msg)  then
  redis:set(hashgif ,"Enable")
  local text = "فیتلر گیف (عکس متحرک) باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "unmute gif"  and is_momod(msg) then
  redis:del(hashgif)
  local text = "فیتلر گیف (عکس متحرک) غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "mute photo"  and is_momod(msg) then
  redis:set(hashphoto ,"Enable")
  local text = "فیتلرعکس باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "unmute photo"  and is_momod(msg) then
  redis:del(hashphoto)
  local text = "فیتلرعکس باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "mute audio"  and is_momod(msg) then
  redis:set(hashaudio ,"Enable")
    local text = "فیتلر اهنگ باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "unmute audio"  and is_momod(msg) then
  redis:del(hashaudio)
  local text = "فیتلر اهنگ باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "mute voice" and is_momod(msg)  then
  redis:set(hashvoice ,"Enable")
  local text = "فیتلر صدا باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "unmute voice" and is_momod(msg)  then
  redis:del(hashvoice)
  local text = "فیتلر صدا باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "mute video" and is_momod(msg)  then
  redis:set(hashvideo ,"Enable")
  local text = "فیتلر فیلم باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "unmute video" and is_momod(msg)  then
  redis:del(hashvideo)
  local text = "فیتلر فیلم باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "mute document" and is_momod(msg)  then
  redis:set(hashdocument ,"Enable")
  local text = "فیتلر فایل باموفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "unmute document" and is_momod(msg)  then

  redis:del(hashdocument)
  local text = "فیتلر فایل باموفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "mute text" and is_momod(msg)  then
  redis:set(hashtext1 ,"Enable")
  local text = "فیتلر متن با موفقیت فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == "unmute text" and is_momod(msg)  then
  redis:del(hashtext1)
  local text = "فیتلر متن با موفقیت غیر فعال شد!"
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'md')
end
if text == 'pin' and is_momod(msg)  then
  tdcli.pinChannelMessage(msg.chat_id_, msg.reply_to_message_id_, 1)
end
if text == "unpin" and is_momod(msg)  then
  tdcli.unpinChannelMessage(chat_id, 1)
end
if text == "help"  and is_momod(msg) then
help = [[
به زودی....!]]
tdcli.sendMessage(msg.chat_id_, msg.id_, 1, help, 1, 'md')
end
if text == "del" and is_momod(msg)  then
  tdcli.deleteMessages(chat_id, {[0] = msg.id_})
  tdcli.deleteMessages(chat_id,{[0] = reply_id})
end
if text == "gpinfo" and is_momod(msg)  then
  function info(arg,data)
    -- vardump(data)
    tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "اعطلاعات گروه\n*تعداد ادمین ها : *"..data.administrator_count_.."\n*تعداد ریمو شده ها : *"..data.kicked_count_.."\n*تعداد اعضا : *"..data.member_count_.."", 1, 'md')
  end
  tdcli.getChannelFull(chat_id, info, nil)
end
if text and text:match("^getpro (.*)$") then
  profilematches = {string.match(text, "^getpro (.*)$")}
  local function dl_photo(arg,data)
    tdcli.sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, data.photos_[0].sizes_[1].photo_.persistent_id_, nil)
  end
  tdcli.getUserProfilePhotos(user_id, profilematches[1] - 1, profilematches[1], dl_photo, nil)
end
if text and text:match('^setfloodtime (.*)$') and is_owner(msg) then
 redis:set('floodTime',text:match('setfloodtime (.*)'))
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '_حداکثر زمان اسپم تنظیم شد به_ : *'..text:match('setfloodtime (.*)')..'*', 1, 'md')
        end
if text and text:match('^setflood (.*)$') and is_owner(msg) then
    redis:set('floodMax',text:match('setflood (.*)'))
          tdcli.sendMessage(msg.chat_id_, msg.id_, 1, '_حداکثر تعداد اسپم تنظیم شد به_ : *'..text:match('setflood (.*)')..'*', 1, 'md')
        end
if text == "id" then
  function dl_photo(arg,data)
    local text = 'ایدی گروه : ['..msg.chat_id_:gsub('-100','').."]\nایدی شما  : ["..msg.sender_user_id_.."]\nتعداد عکس های شما : ["..data.total_count_.."]"
    tdcli.sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, data.photos_[0].sizes_[1].photo_.persistent_id_, text)
  end
  tdcli.getUserProfilePhotos(user_id, 0, 1, dl_photo, nil)
end
end
function tdcli_update_callback(data)
if (data.ID == "UpdateNewMessage") then
  run(data)
elseif data.ID == "UpdateMessageEdited" then
  local function edited_cb(arg, data)
    run(data,true)
  end
  getMessage(data.chat_id_, data.message_id_, edited_cb, nil)
elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({ID="GetChats", offset_order_="9223372036854775807", offset_chat_id_=0, limit_=20}, dl_cb, nil)    
  end
end