package App::pad;
use 5.012;
use warnings;

our $VERSION = '0.01';

use Getopt::Long ();

use Plack::Runner;
use Plack::App::Directory;
use Plack::Builder;

sub getopt_spec {
    return(
        'version',
        'help',
    );
}

sub getopt_parser {
    return Getopt::Long::Parser->new(
        config => [qw(
            no_ignore_case
            bundling
            no_auto_abbrev
        )],
    );
}

sub appname {
    my($self) = @_;
    require File::Basename;
    return File::Basename::basename($0);
}

sub new {
    my $class = shift;
    local @ARGV = @_;

    my %opts;
    my $success = $class->getopt_parser->getoptions(
        \%opts,
        $class->getopt_spec());

    if(!$success) {
        $opts{help}++;
        $opts{getopt_failed}++;
    }

    $opts{argv} = \@ARGV;

    return bless \%opts, $class;
}

sub run {
    my $self = shift;

    if($self->{help}) {
        $self->do_help();
    }
    elsif($self->{version}) {
        $self->do_version();
    }
    else {
        $self->dispatch(@ARGV);
    }

    return;
}

sub dispatch {
    my($self, $www_root) = @_;
    $www_root //= '.';

    my $app = builder {
        enable 'AccessLog';

        Plack::App::Directory->new(
            root => $www_root,
        )->to_app();
    };

    my $server = Plack::Runner->new();
    #$server->parse_options(@args);
    $server->run($app);
    return;
}

sub Dump {
    my($data, $name) = @_;
    require Data::Dumper;
    my $dd = Data::Dumper->new([$data], [$name || 'app']);
    $dd->Indent(1);
    $dd->Maxdepth(3);
    $dd->Quotekeys(0);
    $dd->Sortkeys(1);
    return $dd->Dump();
}

sub do_help {
    my($self) = @_;
    if($self->{getopt_failed}) {
        die $self->help_message();
    }
    else {
        print $self->help_message();
    }
}

sub do_version {
    my($self) = @_;
    print $self->version_message();
}

sub help_message {
    my($self) = @_;
    require Pod::Usage;

    open my $fh, '>', \my $buffer;
    Pod::Usage::pod2usage(
        -message => $self->version_message(),
        -exitval => 'noexit',
        -output  => $fh,
        -input   => __FILE__,
    );
    close $fh;
    return $buffer;
}

sub version_message {
    my($self) = @_;

    require Config;
    return sprintf "%s\n" . "\t%s/%s\n" . "\tperl/%vd on %s\n",
        $self->appname(), ref($self), $VERSION,
        $^V, $Config::Config{archname};
}

1;
__END__

=head1 NAME

App::pad - 3-letter interface to Plack::App::Directory

=head1 VERSION

This document describes App::pad version 0.01.

=head1 SYNOPSIS

    $ pad

=head1 DESCRIPTION

# TODO

=head1 DEPENDENCIES

Perl 5.12.0 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<Plack>

L<Plack::App::Directory>

=head1 AUTHOR

Fuji, Goro (gfx) E<lt>gfuji@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011, Fuji, Goro (gfx). All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
