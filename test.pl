#!/usr/bin/perl -w
use strict;
use Test::More tests => 38;

require "./apt-mirror";

is( Local::AptMirror::round_number(-0.05), "-0.1", "round: -0.05" );
is( Local::AptMirror::round_number(-0.04), "-0.0", "round: -0.04" );
is( Local::AptMirror::round_number(-0.01), "-0.0", "round: -0.01" );
is( Local::AptMirror::round_number(0),      "0.0", "round: 0" );
is( Local::AptMirror::round_number(0.01),   "0.0", "round: +0.01" );
is( Local::AptMirror::round_number(0.04),   "0.0", "round: +0.04" );
is( Local::AptMirror::round_number(0.05),   "0.1", "round: +0.05" );

is( Local::AptMirror::format_bytes(0),         "0 bytes",      "format: 0" );
is( Local::AptMirror::format_bytes(1),         "1 bytes",      "format: 1" );
is( Local::AptMirror::format_bytes(1023),      "1023 bytes", "format: 1023" );
is( Local::AptMirror::format_bytes(1<<10),     "1.0 KiB",      "format: 1k" );
is( Local::AptMirror::format_bytes((1<<20)-1), "1024.0 KiB",   "format: 1k-1" );
is( Local::AptMirror::format_bytes(1<<20),     "1.0 MiB",      "format: 1m" );
is( Local::AptMirror::format_bytes(1<<30),     "1.0 GiB",      "format: 1g" );
is( Local::AptMirror::format_bytes(1<<40),     "1024.0 GiB",   "format: 1t" );

%Local::AptMirror::config_variables = (
    "simple" => "SIMPLE",
    "subst" => "SUBST\$simple",
    "recursive" => "\$recursive",
    "noref" => "\$undefined",
    "_tilde" => 0,
);
is( Local::AptMirror::get_variable("simple"), "SIMPLE",     "cfg: simple" );
is( Local::AptMirror::get_variable("subst"), "SUBSTSIMPLE", "cfg: subst" );
TODO: {
    todo_skip( "would die!", 1 );
    ok( Local::AptMirror::get_variables("recursive"), "cfg: recursive" );
}
is( Local::AptMirror::get_variable("undefined"), undef,     "cfg: undefined" );
is( Local::AptMirror::get_variable("noref"), "",            "cfg: noref" );

is( Local::AptMirror::sanitise_uri(""),                   "",       "sanitize: empty" );
is( Local::AptMirror::sanitise_uri("http://host/\@path"), "\@path", "sanitize: schema+host+path" );
is( Local::AptMirror::sanitise_uri("http://host/"),       "",       "sanitize: schemahost" );
is( Local::AptMirror::sanitise_uri("http://host:80/"),    "",       "sanitize: schema+host+port" );
is( Local::AptMirror::sanitise_uri("http://:80/"),        "",       "sanitize: schema+port" );
is( Local::AptMirror::sanitise_uri("http://host/:80/"),   ":80/",   "sanitize: schema+host+path" );
TODO: {
    local $TODO = "Disabled for UCS because we strip the host part";
is( Local::AptMirror::sanitise_uri("http://"),            "",       "sanitize: schema" );  ##
is( Local::AptMirror::sanitise_uri("http://user@"),       "",       "sanitize: schema+user" );  ##
is( Local::AptMirror::sanitise_uri("user@"),              "",       "sanitize: user" );  ##
is( Local::AptMirror::sanitise_uri("host/"),              "",       "sanitize: host" );  ##
is( Local::AptMirror::sanitise_uri(":port/"),             "",       "sanitize: port" );  ##
}

is( Local::AptMirror::remove_double_slashes("foo"),          "foo",         "rds: plain" );
is( Local::AptMirror::remove_double_slashes("foo/"),         "foo/",        "rds: trail" );
is( Local::AptMirror::remove_double_slashes("foo//"),        "foo/",        "rds: double" );
is( Local::AptMirror::remove_double_slashes("file://foo//"), "file://foo/", "rds: schema" );
is( Local::AptMirror::remove_double_slashes("foo/./"),       "foo/",        "rds: current" );
is( Local::AptMirror::remove_double_slashes("foo/bar/../"),  "foo/",        "rds: parent" );
is( Local::AptMirror::remove_double_slashes("foo/../"),      "",            "rds: empty" );

done_testing;
