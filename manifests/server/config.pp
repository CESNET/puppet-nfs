# == Class: nfs::server::config
#
# This class exists to
#  1. configure nfs as a server
#
#
# === Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#
# === Authors
#
# * Daniel Klockenkaemper <mailto:dk@marketing-factory.de>
#

class nfs::server::config {

  if $::nfs::defaults_file != undef {
    augeas { $::nfs::defaults_file:
      context => "/files/${::nfs::defaults_file}",
      changes => [
        "set MOUNTD_PORT ${::nfs::server_mountd_port}",
        "set STATD_PORT ${::nfs::server_statd_port}",
        "set LOCKD_TCPPORT ${::nfs::server_lockd_tcp_port}",
        "set LOCKD_UDPPORT ${::nfs::server_lockd_udp_port}"
      ]
    }
  }

  concat { $::nfs::exports_file:
    ensure  => present,
  }

  concat::fragment { 'nfs_exports_header':
    target  => $::nfs::exports_file,
    content => "# This file is configured through the nfs::server puppet module\n",
    order   => 1;
  }

  if $::nfs::nfs_v4 {

    concat::fragment { 'nfs_exports_root':
      target  => $::nfs::exports_file,
      content => "${::nfs::server::nfs_v4_export_root} ${::nfs::server::nfs_v4_export_root_clients}\n",
      order   => 2,
    }

    if ! defined(File[$::nfs::server::nfs_v4_export_root]) {
      file { $::nfs::server::nfs_v4_export_root:
        ensure => directory,
      }
    }

    augeas { $::nfs::idmapd_file:
      context => "/files/${::nfs::idmapd_file}/General",
      lens    => 'Puppet.lns',
      incl    => $::nfs::idmapd_file,
      changes => [
        "set Domain ${::nfs::server::nfs_v4_idmap_domain}",
        "set Local-Realms ${::nfs::server::nfs_v4_idmap_local_realms}"
      ],
    }

    augeas { $::nfs::idmapd_file:
      context => "/files/${::nfs::idmapd_file}/Translation",
      lens    => 'Puppet.lns',
      incl    => $::nfs::idmapd_file,
      changes => ["set Method ${::nfs::server::nfs_v4_idmap_translation_method}"],
    }

    if $nfs::storeconfigs_enabled {
      @@nfs::client::mount { $::nfs::nfs_v4_mount_root:
        ensure        => $::nfs::server::nfs_v4_root_export_ensure,
        server        => $::clientcert,
        remounts      => $::nfs::server::nfs_v4_root_export_remounts,
        atboot        => $::nfs::server::nfs_v4_root_export_atboot,
        options_nfsv4 => $::nfs::server::nfs_v4_root_export_options,
        bindmount     => $::nfs::server::nfs_v4_root_export_bindmount,
        nfstag        => $::nfs::server::nfs_v4_root_export_tag,
      }
    }
  }
}
