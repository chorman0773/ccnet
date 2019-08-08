# Registered Ports

The following Ports are Registered for TCP and UDP On CCNet.

## Well Known Ports

All well-known ports (ports in the range 0-1023) mirror their registered counterpart as released by the IANA And IETF. In particular, the following well-known ports have implementations. Additional ones may be added iff they have compliant implementations of their associated RFC.

<table>
  <tr>
    <th>Port</th>
    <th>TCP/UDP</th>
    <th>Protocol Name</th>
    <th>Implementing API</th>
  </tr>
  <tr>
    <td>0</td>
    <td>N/A</td>
    <td>Reserved. Hint that indicates a Dynamic Port in range 49152-65535 may be assigned when using socket apis.</td>
  </tr>
  <tr>
    <th>20</th>
    <th>TCP</th>
    <th>FTP Data</th>
    <th>ftp</th>
  </tr>
</table>

## Registered Ports

Ports designated by the IANA as Registered (1024-49151) may be registered by ComputerCraft users. Ports will be assigned on a first-come-first-serve basis, except implementations of IANA Registered protocols that use these ports will be given the port the protocol is assigned by the IANA reguardless of if that port is already registered or requested. In particular, ports registered for git services, bittorrent, and those registered for [PkmCom](https://chorman0773.github.com/PkmCom-APL-Library) aren't likely to be assigned outside of such an implementation.

There are presently no registered ports in use.

## Private/Dynamic Ports

Ports designated by the IANA as Private/Dynamic (49152-65535) are also considered such in ccnet. They are not reserveable, and may be used freely as a temporary port. They SHOULD NOT be statically used without configurability.
