#########################

use Test::More tests => 3;
BEGIN { use_ok 'HTML::BBCode'; }

#########################

use strict;

my $bbc = new HTML::BBCode({ no_html => 1});

my $text = "[color=<xss>]<xss>[/color]";
is($bbc->parse($text), "<span style=\"color: &lt;xss&gt;\">&lt;xss&gt;</span>");

$text = "[url=<xss>]http:<xss>[/url]";
is($bbc->parse($text), "<a href=\"&lt;xss&gt;\">http:&lt;xss&gt;</a>");
