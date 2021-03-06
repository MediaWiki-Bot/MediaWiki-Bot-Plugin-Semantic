package MediaWiki::Bot::Plugin::Semantic;

use strict;

our $VERSION = '0.1.1';

=head1 NAME

MediaWiki::Bot::Plugin::Semantic - a plugin for MediaWiki::Bot which interacts with Semantic MediaWiki websites

=head1 SYNOPSIS
                                                                                                                                                                     
use strict;
use warnings;

use MediaWiki::Bot;
use Data::Dumper;

my $bot = MediaWiki::Bot->new();
$bot->set_wiki('bots.snpedia.com','/');
my $results = $bot->askargs({
    conditions=>'[[Category:Is a snp]] [[On chromosome::3]] [[Repute::+]]',
    outs=>['Repute','Magnitude','Chromosome position'],
			}
    );

# parameters{limit} isn't yet respected, but that seems to be a server side issue

my $i = 0;
foreach my $key (keys %$results) {
    $i++;
    print "$i $key ",Dumper $results->{$key};
}

=head1 DESCRIPTION

MediaWiki::Bot is a framework that can be used to write Mediawiki
bots. MediaWiki::Bot::Plugin::Semantic can be used for data retrieval
and reporting bots related to Semantic MediaWiki

https://github.com/cariaso/Semantic-MediaWiki-Bot

=head1 AUTHOR

Michael Cariaso

=head1 METHODS

=over 4

=item import()

Calling import from any module will, quite simply, transfer these
subroutines into that module's namespace. This is possible from any
module which is compatible with MediaWiki/Bot.pm.

=cut

sub import {
	no strict 'refs';
	foreach my $method (qw/ask askargs/) {
		*{caller() . "::$method"} = \&{$method};
	}
}

=item ask($params)

Ask the query, return the result.

=cut


sub ask {
    my $self    = shift;
    my $args    = shift;

    die("query must be set") unless $args->{query};

    my $askhash = {};
    $askhash->{action} = $args->{action} || 'ask';
    $askhash->{query} = $args->{query};

    my $smw = $self->{api};
    my $response = $smw->api($askhash)
	|| die $smw->{error}->{code} . ': ' . $smw->{error}->{details};

    return $response->{query}->{results};
}









sub askargs {
    my $self    = shift;
    my $args    = shift;

    die("conditions must be set") unless $args->{conditions};

    my $askhash = {};
    $askhash->{action} = $args->{action} || 'askargs';
    $askhash->{conditions} = $args->{conditions};
    $askhash->{printouts} = $args->{printouts} || join('|',@{$args->{outs}});
    $askhash->{parameters} = $args->{parameters};


    my $smw = $self->{api};
    my $response = $smw->api($askhash)
	|| die $smw->{error}->{code} . ': ' . $smw->{error}->{details};

    return $response->{query}->{results};
}







1;
