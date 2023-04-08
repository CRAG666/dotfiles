// SPDX-License-Identifier: CC0-1.0

const allowed_ports = [
  // uncomment and list any exceptions:
  3000,
];

// CIDR 0/8 and 127/8
const local_cidrs =
  /^(?:127(?:\.(?:\d{1,})){1,3}|0+(?:\.0+){0,3})$/;

// other notations for 0/8 and 127/8
const localhosts = [
  'localhost',
  '::',
  '::1',
  '0x00.0',
  '0177.1',
  '0x7f.1'
];

function FindProxyForURL(url, host)
{
  // check if localhost
  if (localhosts.includes(host) ||
      host.match(local_cidrs)) {

    // make exceptions for allowed ports
    let port = url.match(/^\w+:\/\/[^/]+?:(\d+)\//);
    if (port) {
      port = parseInt(port[1]);

      if (allowed_ports.includes(port)) {
        return 'DIRECT';
      }
    }

    // reject by proxying to local discard
    return 'PROXY 127.0.0.1:9';
  }

  // all other requests are allowed
  return 'DIRECT';
}
