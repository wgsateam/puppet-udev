# == Class: udev
#
# Manages the udev package and device rules
#
# This class does not need to be declared in the manfiest when using the
# udev::rule defined type.
#
#
# === Parameters
#
# [*udev_log*]
#
# String. Possible values: 'err, 'info', 'debug'
#
# Default: 'err'
#
#
# === Examples
#
# include udev
#
class udev(
  Enum['err', 'info', 'debug']  $udev_log            = $udev::params::udev_log,
  Boolean                       $config_file_replace = $udev::params::config_file_replace,
  Optional[String]              $rules               = $udev::params::rules,
) inherits udev::params {

  anchor { 'udev:begin': }
  -> package{ $udev::params::udev_package:
    ensure => present,
  }
  -> file { '/etc/udev/udev.conf':
    ensure  => file,
    content => template("${module_name}/udev.conf.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => $config_file_replace,
    notify  => Class['udev::udevadm::logpriority'],
  }
  -> anchor { 'udev:end': }

  Anchor['udev:begin']
  -> class { 'udev::udevadm::trigger': }
  -> Anchor['udev:end']

  Anchor['udev:begin']
  -> class { 'udev::udevadm::logpriority': udev_log => $udev_log }
  -> Anchor['udev:end']

  if $rules {
    create_resources('udev::rule', $rules)
  }
}
