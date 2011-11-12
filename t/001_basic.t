#!perl -w
use strict;
use Test::More;

use App::pad;

# test App::pad here
my $app = App::pad->new('--version');

my $help = $app->help_message;
note $help;
ok $help, 'help_message';

ok $app->appname,         'appname';
ok $app->version_message, 'version_message';

my $v = do {
    open my $fh, '>', \my $buffer;
    local *STDOUT = $fh;
    $app->run(); # do version
    $buffer;
};
like $v, qr/perl/;

my $x = `$^X -Ilib script/pad --version`;
like $x, qr/perl/, 'exec pad --version';


done_testing;
