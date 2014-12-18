# == Class: nfs::init
#
# This class exists to
#  1. overwrite operatingsystem default params
#  2. decide to act as a server, client or both
#
# === Parameters
#
# TODO: has to be filled
#
# === Examples
#
# TODO: has to be filled
#
#
# === Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#
# === Authors
#
# * Daniel Klockenkämper <mailto:dk@marketing-factory.de>
#

class nfs(
  $ensure                     = present,
  $server_enabled             = false,
  $client_enabled             = false,
  $nfs_v4                     = false,
  $status                     = $::nfs::params::status,
  $exports_file               = $::nfs::params::exports_file,
  $idmapd_file                = $::nfs::params::idmapd_file,
  $defaults_file              = $::nfs::params::defaults_file,
  $server_packages            = $::nfs::params::server_packages,
  $client_packages            = $::nfs::params::client_packages,
  $server_service_name        = $::nfs::params::server_service_name,
  $server_service_ensure      = running,
  $server_service_enable      = true,
  $server_service_hasrestart  = $::nfs::params::server_service_hasrestart,
  $server_service_hasstatus   = $::nfs::params::server_service_hasstatus,
  $server_nfsv4_servicehelper = $::nfs::params::server_nfsv4_servicehelper,
  $client_services            = $::nfs::params::client_services,
  $client_nfsv4_services      = $::nfs::params::client_nfsv4_services,
  $client_services_hasrestart = $::nfs::params::client_services_hasrestart,
  $client_services_hasstatus  = $::nfs::params::client_services_hasstatus,
  $client_idmapd_setting      = $::nfs::params::client_idmapd_setting,
  $client_nfs_fstype          = $::nfs::params::client_nfs_fstype,
  $client_nfs_options         = $::nfs::params::client_nfs_options,
  $client_nfsv4_fstype        = $::nfs::params::client_nfsv4_fstype,
  $client_nfsv4_options       = $::nfs::params::client_nfsv4_options,
  $nfs_v4_export_root         = $::nfs::params::nfs_v4_export_root,
  $nfs_v4_export_root_clients = $::nfs::params::nfs_v4_export_root_clients,
  $nfs_v4_mount_root          = $::nfs::params::nfs_v4_mount_root,
  $nfs_v4_idmap_domain        = $::nfs::params::nfs_v4_idmap_domain
) inherits nfs::params {

  validate_bool($server_enabled)
  validate_bool($client_enabled)
  validate_bool($nfs_v4)

  if $server_enabled {
    $effective_client_packages       = difference($client_packages, $server_packages)
    $effective_nfsv4_client_services = delete($client_nfsv4_services, $server_nfsv4_servicehelper)
    $effective_client_services       = $client_services
  } else {
    $effective_client_packages       = $client_packages
    $effective_nfsv4_client_services = $client_nfsv4_services
    $effective_client_services       = $client_services
  }

  if $server_enabled {
    class { '::nfs::server': }
  }
  if $client_enabled {
    class { '::nfs::client': }
  }
}