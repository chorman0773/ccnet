local installdir = __ccnet_path.__install_dir;

local loaderPath = package.path;
package.path = loaderPath..";"..fs.combine(installdir,"?")..";"..fs.combine(installdir,"?.lua");
