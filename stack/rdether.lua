local SHA = require"apis.SHA";

local CRC32 = require"apis.CRC32";

local int2bin = require"apis.int2bin";

local checkSumFn = CRC32.forPolynomial(0xC704DD7B);



local preambleAndSMID = string.char(85,85,85,85,85,85,85,211);

local broadcastMac = string.char(255,255,255,255,255,255);

local interpacket = string.char(255,255,255,255,255,255,255,255,255,255,255,255);

local interfaces;

local channel =8023;





local function breakPayload(payload)
    if #payload > 1500 then
        return payload:sub(1,1500), breakPayload(payload:sub(1501,-1))
    else 
        return payload
    end
end

local function newInterface(side,name) 
  local modem = peripheral.wrap(side);
  modem.open(channel);
  local ifaceMacAddress = string.char(0,249)..SHA.SHA256(os.getid()..side):sub(1,4);
  local interface = {};
  local listeningAddressesSet = {[ifaceMacAddress]=true,[broadcastMac]=true}
  function interface:send(addr,payload)
      local payloads = {breakPayload(payload)};
      for _,v in ipairs(payloads) do
          interface:sendTo(addr,payload)
      end
  end
  
  function interface:recieveFrames()
    while true do
      local _side, senderChannel, _3, message = os.pullEvent("modem_message");
      if _side ==side and senderChannel==channel and message:sub(1,8)==preambleAndSMID then
        --We have an ethernet message, handle it appropriately
        local recieverMac = message:sub(9,15);
        local sourceMac = message:sub(16,22);
        if listeningAddressesSet[recieverMac] then
            local len = int2bin.tohword(message:sub(23,24));
            local payload = message:sub(25,25+len);
            local check = message:sub(26+len,30+len);
            if checkSumFn(payload)~=check then
                return recieverMac,sourceMac,message;
            end
         end
      end
    end
  end
  
  function interface:listenOn(addr)
    listeningAddressesSet[addr] = true;
  end
  
  function interface:unlistenOn(addr)
    listeningAddressesSet[addr] = false;
  end
  
  function interface:getHardwareAddress()
    return ifaceMacAddress;
  end
  
  function interface:getArpHardwareProtocolNumber()
    return 1
  end
  function interface:getName()
    return name;
  end
  function interface:disconnect()
    
  end
end

local icount = 0;

function getInterface(side)
  if interfaces[side] then
    return interfaces[side];
  else
    local iface = newInterface(side,"eth"..icount);
    icount = icount +1;
    interfaces[side] = iface;
    return iface;
  end
end