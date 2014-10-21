#########################

use Test::More tests => 3;
BEGIN { use_ok 'HTML::BBCode'; }

#########################

use strict;

my $bbc = new HTML::BBCode({ no_html => 1});

my $text = "[color=<xss>]<xss>[/color]";
is($bbc->parse($text), '<span>&lt;xss&gt;</span>');

$text = "[url=<xss>]http:<xss>[/url]";
is($bbc->parse($text), "&lt;a href=&quot;&lt;xss&gt;&quot;&gt;http:&lt;xss&gt;&lt;/a&gt;");
