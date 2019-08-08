local CRC32 = {};

local function cache(table,fn)
  return setmetatable(table,{
    __index=function(t,k)
      local val = fn(k);
      t[k] = val;
      return val;
    end
  })
end

local function computeByteTableFunction(polynomial)
  return function(byte)
    local crc = byte;
    for _=1,8 do
      local b = bit32.band(crc,1);
      crc = bit32.arshift(crc,1);
      if b==1 then crc = bit32.bxor(crc,polynomial); end
    end
    return crc;
  end
end

local function mkCRCAlgorithm(polynomial)
  local bytetable = cache({},computeByteTableFunction(polynomial));
  local function crcByte(byte,crc)
    crc = bit32.bnot(crc or 0);
    local v1 = bit32.rshift(crc,8);
    local v2 = bytetable[bit32.bxor(crc%256,byte)]
    return bit32.bxor(0xFFFFFFFF,v1,v2);
  end
  return function(str)
    local crc;
    for i,byte in ipairs({str:byte(1,-1)}) do
      crc = crcByte(byte,crc);
    end
  end
end

local polycache = cache({},mkCRCAlgorithm);

function CRC32.forPolynomial(polynomial)
  polynomial = bit32.bxor(polynomial,0);--Constrain it to a 32-bit integer.
  return polycache[polynomial];
end

return CRC32;