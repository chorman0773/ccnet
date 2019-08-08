local SHA = {};

local SHA2_roundconstants = 
  {[0]=0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
   0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
   0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
   0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
   0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
   0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
   0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
   0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2};

local function i2s(i)
  local ret = "";
  for _ in 1,4 do
    ret = string.char(i%256)..ret;
    i = bit32.arshift(i,8);
  end
  return ret;
end

local function l2s(l)
  local ret = "";
  local low = l%(4294967296);
  local hi = (l-low)/4294967296;
  return i2s(hi)..i2s(low);
end

local function s2i(s,begin)
  local a,b,c,d = s:byte(begin,begin+4);
  return a*16777216+b*65536+c*256+d;
end

local function SHA2_32_pad(inbytes)
  local len = #inbytes;
  local padLen = 64-((len+1+8)%64);
  len = len * 8;
  inbytes = inbytes .. string.char(0x80);
  for _=1,padLen do
    inbytes = inbytes .. string.char(0);
  end
  inbytes = inbytes .. l2s(len);
  return inbytes;
end

local function SHA2_32(inbytes,h)
  inbytes = SHA2_32_pad(inbytes);
  local blockCount = (#inbytes)/64;
  for b=0,(blockCount-1) do
    local block = inbytes:sub(b*64 + 1,(b+1)*64);
    local w = {};
    for i=0,15 do
      w[i] = s2i(block,i*4 + 1);
    end
    for i=16,63 do
      --s0 := (w[i-15] rightrotate  7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift  3)
      --s1 := (w[i- 2] rightrotate 17) xor (w[i- 2] rightrotate 19) xor (w[i- 2] rightshift 10)
      local s0 = bit32.bxor(bit32.rrotate(w[i-15],7),bit32.rrotate(w[i-15],18),bit32.rrotate(w[i-15],3));
      local s1 = bit32.bxor(bit32.rrotate(w[i-2],17),bit32.rrotate(w[i-2],19),bit32.rrotate(w[i-2],10));
      w[i] = (w[i-16] + s0 + w[i-7] + s1)%4294967296;
    end
    
    local a = h[0];
    local b = h[1];
    local c = h[2];
    local d = h[3];
    local e = h[4];
    local f = h[5];
    local g = h[6];
    local k = h[7];
    
    for i=0,63 do
      --S1 := (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
      --ch := (e and f) xor ((not e) and g)
      --temp1 := h + S1 + ch + k[i] + w[i]
      --S0 := (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
      --maj := (a and b) xor (a and c) xor (b and c)
      --temp2 := S0 + maj
      local S1 = bit32.bxor(bit32.rrotate(e,6),bit32.rrotate(e,11),bit32.rrotate(e,25));
      local ch = bit32.bxor(bit32.band(e,f),bit32.band(bit32.bnot(e),g));
      local temp1 = (h + S1 + ch + k[i] + w[i])%4294967296;
      local S0 = bit32.bxor(bit32.rrotate(a,2),bit32.rrotate(a,13),bit32.rrotate(a,22));
      local maj = bit32.bxor(bit32.band(a,b),bit32.band(a,c),bit32.band(b,c));
      local temp2 = (S0 + maj)%4294967296;
      
      k = g;
      g = f;
      f = e;
      e = (d+temp1)%4294967296;
      d = c;
      c = b;
      b = a;
      a = (temp1+temp2)%4294967296;
    end
    h[0] = (h[0]+a)%4294967296;
    h[1] = (h[1]+b)%4294967296;
    h[2] = (h[2]+c)%4294967296;
    h[3] = (h[3]+d)%4294967296;
    h[4] = (h[4]+e)%4294967296;
    h[5] = (h[5]+f)%4294967296;
    h[6] = (h[6]+g)%4294967296;
    h[7] = (h[7]+k)%4294967296;
  end
end

function SHA.SHA256(input)
  local h = {[0]=0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
            0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19};
  SHA2_32(input,h);
  return i2s(h[0])..i2s(h[1])..i2s(h[2])..i2s(h[3])..i2s(h[4])..i2s(h[5])..i2s(h[6])..i2s(h[7]);
end

function SHA.SHA224(input)
  local h = {[0]=0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939, 
        0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4};
  SHA2_32(input,h);
  return i2s(h[0])..i2s(h[1])..i2s(h[2])..i2s(h[3])..i2s(h[4])..i2s(h[5])..i2s(h[6]);
end

return SHA;