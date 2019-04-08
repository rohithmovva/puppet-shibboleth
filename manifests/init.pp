# Class: shibboleth
#
# This module manages shibboleth
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

# [Remember: No empty lines between comments and class definition]
class shibboleth (
  $admin              = $::shibboleth::params::admin,
  $hostname           = $::shibboleth::params::hostname,
  $user               = $::shibboleth::params::user,
  $group              = $::shibboleth::params::group,
  $logo_location      = $::shibboleth::params::logo_location,
  $style_sheet        = $::shibboleth::params::style_sheet,
  $conf_dir           = $::shibboleth::params::conf_dir,
  $conf_file          = $::shibboleth::params::conf_file,
  $sp_cert            = $::shibboleth::params::sp_cert,
  $bin_dir            = $::shibboleth::params::bin_dir,
  $handlerSSL         = true,
  $consistent_address = true
) inherits shibboleth::params {

  $config_file = "${conf_dir}/${conf_file}"

  user{$user:
    ensure  => 'present',
    home    => '/var/log/shibboleth',
    shell   => '/bin/false',
    require => Class['apache::mod::shib'],
  }

  # by requiring the apache::mod::shib, these should wait for the package
  # to create the directory.
  file{'shibboleth_conf_dir':
    ensure  => 'directory',
    path    => $conf_dir,
    owner   => $user,
    group   => $group,
    recurse => true,
    require => Class['apache::mod::shib'],
  }

  file{'shibboleth_config_file':
    ensure  => 'file',
    path    => $config_file,
    replace => false,
    content => template($shibboleth_xml),
    require => [Class['apache::mod::shib'],File['shibboleth_conf_dir']],
  }


  service{'shibd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [Class['apache::mod::shib'],User[$user]],
  }

}
