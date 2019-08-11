
---
--Implementation of RFC 791
--

local localhost = "127.0.0.1";
local localhostEncoded = string.char(127,0,0,1);
local loopbackPrefix = "127.0.0.0/24";
local loopbackLen = 24;
local prefixEncoded = string.char(127,0,0,0);

local gateway;
local gatewayEncoded;
local interfaceAddress;
local netprefix;

local prefixLen;
local networkAddr;

local gatewayMAC = string.char(255,255,255,255,255,255);
local idGateway = true; --We need to ID what the gateway is.


