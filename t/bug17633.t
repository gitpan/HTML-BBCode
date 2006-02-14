#########################

use Test::More tests => 7;
BEGIN { use_ok 'HTML::BBCode'; }

#########################

use strict;

my $bbc = new HTML::BBCode;
isa_ok($bbc, 'HTML::BBCode');

my $text = "[url=javascript:alert('B10m should check security better...')]click me[/url]";
is($bbc->parse($text), "<a href=\"alert('B10m should check security better...')\">click me</a>");

$text = "[img]javascript:alert('B10m thanks Alex')[/img]";
is($bbc->parse($text), "<img src=\"alert('B10m thanks Alex')\" alt=\"\" />");

$text = "But I can still use the link thing normally, like javascript:alert('ok'), right?";
is($bbc->parse($text), $text);

my $bbc2 = new HTML::BBCode({ no_jslink => 0 });
isa_ok($bbc2, 'HTML::BBCode');
$text = "[url=javascript:alert('No Fear!')]click me[/url]";
is($bbc2->parse($text), "<a href=\"javascript:alert('No Fear!')\">click me</a>");
