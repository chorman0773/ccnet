local int2bin = {};

function int2bin.hword(h)
  return string.char(bit32.rshift(h,8))..string.char(bit32.band(h,255));
end

function int2bin.tohword(s)
  local a,b = s:byte(1,2);
  return a*256+b;
end

function int2bin.word(i)
  local ret = "";
  for _ in 1,4 do
    ret = string.char(i%256)..ret;
    i = bit32.arshift(i,8);
  end
  return ret;
end

function int2bin.toword(s)
  local a,b,c,d = s:byte(1,4);
  return a*16777216+b*65536+c*256+d;
end

function int2bin.dword(l)
  local ret = "";
  local low = l%(4294967296);
  local hi = (l-low)/4294967296;
  return int2bin.word(hi)..int2bin.word(low);
end

return int2bin;