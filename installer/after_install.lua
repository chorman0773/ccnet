

local function emitCCNETPaths(installpath)
  local installpathline = "__install_path = \""..installpath.."\"\n";
  local binpathline = "__bin_path = \""..installpath.."/bin\"\n";
  local file = io.open("/__ccnet_paths","w");
  file:write(installpathline);
  file:write(binpathline);
end


local function copyStartupFiles(installpath)
  local installStartupFiles = fs.combine(installpath,"installer/startup/ccnet");
  for _,path in ipairs(fs.list(installStartupFiles)) do
    fs.copy(fs.combine(installStartupFiles,path),fs.combine("/startup","ccnet_"..path));
  end
end

local function afterInstallRunStartupFiles(installpath)
  local installStartupFiles = fs.combine(installpath,"installer/startup/ccnet");
  for _,path in ipairs(fs.list(installStartupFiles)) do
    shell.run(fs.combine(installStartupFiles,path));
  end
end

local function afterInstall(installpath)
  emitCCNETPaths(installpath);
  afterInstallRunStartupFiles(installpath);
  copyStartupFiles(installpath);  
end

afterInstall(shell.dir());

