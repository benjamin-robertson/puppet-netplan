# @summary validates bridge config and writes it to $config_file via concat
#
# @api private
#
# @note intended to be used only by netplan class
#
# @param renderer
#  Use the given networking backend for this definition. Currently supported are networkd and NetworkManager.
#  This property can be specified globally in networks:, for a device type (in e. g. ethernets:) or for a
#  particular device definition. Default is networkd.
# @param dhcp4
#  Enable DHCP for IPv4. Off by default.
# @param dhcp6
#  Enable DHCP for IPv6. Off by default.
# @param ipv6_privacy
#  Enable IPv6 Privacy Extensions. Off by default.
# @param link_local
#  Configure the link-local addresses to bring up. Valid options are ‘ipv4’ and ‘ipv6’.
# @param critical
#  (networkd backend only) Designate the connection as "critical to the system", meaning that special
#  care will be taken by systemd-networkd to not release the IP from DHCP when the daemon is restarted.
# @param dhcp_identifier
#  When set to ‘mac’; pass that setting over to systemd-networkd to use the device’s MAC address as a
#  unique identifier rather than a RFC4361-compliant Client ID. This has no effect when NetworkManager
#  is used as a renderer.
# @param dhcp4_overrides
#  (networkd backend only) Overrides default DHCP behavior
# @param dhcp6_overrides
#  (networkd backend only) Overrides default DHCP behavior
# @param accept_ra
#  Accept Router Advertisement that would have the kernel configure IPv6 by itself. On by default.
# @param addresses
#  Add static addresses to the interface in addition to the ones received through DHCP or RA.
#  Each sequence entry is in CIDR notation, i. e. of the form addr/prefixlen. addr is an IPv4 or IPv6
#  address as recognized by inet_pton(3) and prefixlen the number of bits of the subnet.
# @param gateway4
#  Set default gateway for IPv4, for manual address configuration. This requires setting addresses too.
# @param gateway6
#  Set default gateway for IPv6, for manual address configuration. This requires setting addresses too.
# @param nameservers
#  Set DNS servers and search domains, for manual address configuration. There are two supported fields:
#  addresses: is a list of IPv4 or IPv6 addresses similar to gateway*, and
#  search: is a list of search domains.
# @param macaddress
#  Set the device’s MAC address. The MAC address must be in the form "XX:XX:XX:XX:XX:XX".
# @param mtu
#  Set the Maximum Transmission Unit for the interface. The default is 1500. Valid values depend on your network interface.
# @param optional
#  An optional device is not required for booting. Normally, networkd will wait some time for device to
#  become configured before proceeding with booting. However, if a device is marked as optional, networkd
#  will not wait for it. This is only supported by networkd, and the default is false.
# @param optional_addresses
#  Specify types of addresses that are not required for a device to be considered online.
# @param routes
#  Configure static routing for the device.
#  from: Set a source IP address for traffic going through the route.
#  to: Destination address for the route.
#  via: Address to the gateway to use for this route.
#  on-link: When set to "true", specifies that the route is directly connected to the interface.
#  metric: The relative priority of the route. Must be a positive integer value.
#  type: The type of route. Valid options are “unicast" (default), “unreachable", “blackhole" or “prohibited".
#  scope: The route scope, how wide-ranging it is to the network. Possible values are “global", “link", or “host".
#  table: The table number to use for the route.
#  mtu: The MTU to be used for the route, in bytes. Must be a positive integer value.
#  congestion-window: The congestion window to be used for the route, represented by number of segments. Must be a positive integer value.
#  advertised-receive-window: The receive window to be advertised for the route, represented by number of segments. Must be a positive integer value.
# @param routing_policy
#  The routing-policy block defines extra routing policy for a network, where traffic may be handled specially
#  based on the source IP, firewall marking, etc.
#  For from, to, both IPv4 and IPv6 addresses are recognized, and must be in the form addr/prefixlen or addr
#  from: Set a source IP address to match traffic for this policy rule.
#  to: Match on traffic going to the specified destination.
#  table: The table number to match for the route.
#  priority: Specify a priority for the routing policy rule, to influence the order in which routing rules are
#    processed. A higher number means lower priority: rules are processed in order by increasing priority number.
#  mark: Have this routing policy rule match on traffic that has been marked by the iptables firewall with
#    this value. Allowed values are positive integers starting from 1.
#  type_of_service: Match this policy rule based on the type of service number applied to the traffic.
#
# @param interfaces
#  All devices matching this ID list will be added to the bridge.
# @param parameters
#  Customization parameters for special bridging options. Using the NetworkManager renderer, parameter values 
#  for time intervals should be expressed in milliseconds; for the systemd renderer, they should be in seconds 
#  unless otherwise specified.
#  ageing_time: Set the period of time to keep a MAC address in the forwarding database after a packet is received.
#  priority: Set the priority value for the bridge. This value should be a number between 0 and 65535. 
#    Lower values mean higher priority. The bridge with the higher priority will be elected as the root bridge.
#  port_priority: Set the port priority to . The priority value is a number between 0 and 63. 
#    This metric is used in the designated port and root port selection algorithms.
#  forward_delay: Specify the period of time the bridge will remain in Listening and Learning states before 
#    getting to the Forwarding state. This value should be set in seconds for the systemd backend, and in 
#    milliseconds for the NetworkManager backend.
#  hello_time: Specify the interval between two hello packets being sent out from the root and designated bridges. 
#    Hello packets communicate information about the network topology.
#  max_age: Set the maximum age of a hello packet. If the last hello packet is older than that value, 
#    the bridge will attempt to become the root bridge.
#  path_cost: Set the cost of a path on the bridge. Faster interfaces should have a lower cost. This allows a 
#    finer control on the network topology so that the fastest paths are available whenever possible.
#  stp: Define whether the bridge should use Spanning Tree Protocol. The default value is "true", which means that 
#    Spanning Tree should be used.
#
define netplan::bridges (

  # common properties
  Optional[Enum['networkd', 'NetworkManager']]                    $renderer = undef,
  #lint:ignore:quoted_booleans
  Optional[Variant[Enum['true', 'false', 'yes', 'no'], Boolean]]  $dhcp4 = undef,
  Optional[Variant[Enum['true', 'false', 'yes', 'no'], Boolean]]  $dhcp6 = undef,
  #lint:endignore
  Optional[Boolean]                                               $ipv6_privacy = undef,
  Optional[Tuple[Enum['ipv4', 'ipv6'], 0]]                        $link_local = undef,
  Optional[Boolean]                                               $critical = undef,
  Optional[Enum['mac']]                                           $dhcp_identifier = undef,
  Optional[Struct[{
    Optional['use_dns']         => Boolean,
    Optional['use_ntp']         => Boolean,
    Optional['send_hostname']   => Boolean,
    Optional['use_hostname']    => Boolean,
    Optional['use_mtu']         => Boolean,
    Optional['hostname']        => Stdlib::Fqdn,
    Optional['use_routes']      => Boolean,
    Optional['route_metric']    => Integer,
    Optional['use_domains']     => Variant[Enum['route', 'true', 'false', 'yes', 'no'], Boolean],
  }]]                                                             $dhcp4_overrides = undef,
  Optional[Struct[{
    Optional['use_dns']         => Boolean,
    Optional['use_ntp']         => Boolean,
    Optional['send_hostname']   => Boolean,
    Optional['use_hostname']    => Boolean,
    Optional['use_mtu']         => Boolean,
    Optional['hostname']        => Stdlib::Fqdn,
    Optional['use_routes']      => Boolean,
    Optional['route_metric']    => Integer,
    Optional['use_domains']     => Variant[Enum['route', 'true', 'false', 'yes', 'no'], Boolean],
  }]]                                                             $dhcp6_overrides = undef,
  Optional[Boolean]                                               $accept_ra = undef,
  Optional[Array[Stdlib::IP::Address]]                            $addresses = undef,
  Optional[Stdlib::IP::Address::V4::Nosubnet]                     $gateway4 = undef,
  Optional[Stdlib::IP::Address::V6::Nosubnet]                     $gateway6 = undef,
  Optional[Struct[{
    Optional['search']          => Array[Stdlib::Fqdn],
    'addresses'                 => Array[Stdlib::IP::Address]
  }]]                                                             $nameservers = undef,
  Optional[Stdlib::MAC]                                           $macaddress = undef,
  Optional[Integer]                                               $mtu = undef,
  Optional[Boolean]                                               $optional = undef,
  Optional[Array[String]]                                         $optional_addresses = undef,
  Optional[Array[Struct[{
    Optional['from']                      => Stdlib::IP::Address,
    'to'                                  => Variant[Stdlib::IP::Address, Enum['0.0.0.0/0', '::/0']],
    Optional['via']                       => Stdlib::IP::Address::Nosubnet,
    Optional['on_link']                   => Boolean,
    Optional['metric']                    => Integer,
    Optional['type']                      => Enum['unicast', 'unreachable', 'blackhole', 'prohibited'],
    Optional['scope']                     => Enum['global', 'link', 'host'],
    Optional['table']                     => Integer,
    Optional['mtu']                       => Integer,
    Optional['congestion_window']         => Integer,
    Optional['advertised_receive_window'] => Integer,
  }]]]                                                            $routes = undef,
  Optional[Array[Struct[{
    'from'                      => Stdlib::IP::Address,
    'to'                        => Variant[Stdlib::IP::Address, Enum['0.0.0.0/0', '::/0']],
    Optional['table']           => Integer,
    Optional['priority']        => Integer,
    Optional['mark']            => Integer,
    Optional['type_of_service'] => Integer,
  }]]]                                                            $routing_policy = undef,

  # bridges specific properties
  Array[String]                                                   $interfaces = undef,
  Optional[Struct[{
    Optional['ageing_time']      => Integer,
    Optional['priority']         => Integer,
    Optional['port_priority']    => Integer,
    Optional['forward_delay']    => Integer,
    Optional['hello_time']       => Integer,
    Optional['max_age']          => Integer,
    Optional['path_cost']        => Integer,
    Optional['stp']              => Boolean,
  }]]                                                             $parameters = undef,

  ){

  $_dhcp4 = $dhcp4 ? {
    true    => true,
    'yes'   => true,
    false   => false,
    'no'    => false,
    default => undef,
  }

  $_dhcp6 = $dhcp6 ? {
    true    => true,
    'yes'   => true,
    false   => false,
    'no'    => false,
    default => undef,
  }

  $bridgestmp = epp("${module_name}/bridges.epp", {
    'name'               => $name,
    'renderer'           => $renderer,
    'dhcp4'              => $_dhcp4,
    'dhcp6'              => $_dhcp6,
    'ipv6_privacy'       => $ipv6_privacy,
    'link_local'         => $link_local,
    'critical'           => $critical,
    'dhcp_identifier'    => $dhcp_identifier,
    'dhcp4_overrides'    => $dhcp4_overrides,
    'dhcp6_overrides'    => $dhcp6_overrides,
    'accept_ra'          => $accept_ra,
    'addresses'          => $addresses,
    'gateway4'           => $gateway4,
    'gateway6'           => $gateway6,
    'nameservers'        => $nameservers,
    'macaddress'         => $macaddress,
    'mtu'                => $mtu,
    'optional'           => $optional,
    'optional_addresses' => $optional_addresses,
    'routes'             => $routes,
    'routing_policy'     => $routing_policy,
    'interfaces'         => $interfaces,
    'parameters'         => $parameters,
  })

  concat::fragment { $name:
    target  => $netplan::config_file,
    content => $bridgestmp,
    order   => '41',
  }

}
