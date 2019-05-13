local SHA = require"SHA";

local CRC32 = require"CRC32";

local int2bin = require"int2bin";

local checkSumFn = CRC32.forPolynomial(0xC704DD7B);

local computerMacAddress = string.char(0,249)..SHA.SHA1(os.getid()):sub(1,4);

local preambleAndSMID = string.char(85,85,85,85,85,85,85,211);

local broadcastMac = string,char(255,255,255,255,255,255);

local interpacket = string.char(255,255,255,255,255,255,255,255,255,255,255,255);

local modems;

local channel =802;

local listeningAddressesSet = {[computerMacAddress]=true,[broadcastMac]=true}

local function init()
    for _, side in ipairs(peripheral.getNames()) do
        local type = peripheral.getType(side);
        if type == "modem" or type=="wireless_modem" then
           local modem = peripheral.wrap(side);
           table.insert(modems,modem);
           modem.open(channel);
        end
    end
end

local function sendTo(addr, payload)
    local check = checkSumFn(payload);
    local len = #payload
    
    local frame = preambleAndSMID..addr..computerMacAddress..(int2bin.hword(len))..payload..check..interpacket;
    for _, modem in ipairs(modems) do
      modem.transmit(channel,channel,frame);
    end
end

local function breakPayload(payload)
    if #payload > 1500 then
        return payload:sub(1,1500), breakPayload(payload:sub(1501,-1))
    else 
        return payload
    end
end

function send(addr,payload)
    local payloads = {breakPayload(payload)};
    for _,v in ipairs(payloads) do
        sendTo(addr,payload)
    end
end

local function recievePackets()
    local _1, senderChannel, _3, message = os.pullEvent("modem_message");
    if senderChannel==channel and message:sub(1,8)==preambleAndSMID then
      --We have an ethernet message, handle it appropriately
      local recieverMac = message:sub(9,15);
      local sourceMac = message:sub(16,22);
      if listeningAddressesSet[recieverMac] then
          local len = int2bin.tohword(message:sub(23,24));
          local payload = message:sub(25,25+len);
          local check = message:sub(26+len,30+len);
          if checkSumFn(payload)~=check then
              os.queueEvent("rdether_message",recieverMac,sourceMac,message);
          end
       end
    end
end

function waitForPackets()
    async.doAsync(recievePackets);
    return os.pullEvent("rdether_message");
end
