#########################

use Test::More tests => 25;
BEGIN { use_ok 'HTML::BBCode'; }

#########################

use strict;
use warnings;

my $bbc = HTML::BBCode->new();
isa_ok($bbc, 'HTML::BBCode', 'default');

# Basic parsing
is($bbc->parse('[b]foo[/b]'), '<span style="font-weight: bold">foo</span>', 'bold');
is($bbc->parse('[u]foo[/u]'), '<span style="text-decoration: underline;">foo</span>', 'underline');
is($bbc->parse('[i]foo[/i]'), '<span style="font-style: italic">foo</span>', 'italic');
is($bbc->parse('[color=red]foo[/color]'), '<span style="color: red">foo</span>', 'color');
is($bbc->parse('[size=24]foo[/size]'),  '<span style="font-size: 24px">foo</span>', 'font size');
is($bbc->parse('[quote]foo[/quote]'), '<div class="bbcode_quote_header">Quote:</div><div class="bbcode_quote_body">foo</div>', 'quote (simple)');
is($bbc->parse('[quote="foo"]bar[/quote]'), '<div class="bbcode_quote_header">foo wrote:</div><div class="bbcode_quote_body">bar</div>', 'quote (with author)');
is($bbc->parse('[code]<foo>[/code]'), '<div class="bbcode_code_header">Code:</div><div class="bbcode_code_body">&lt;foo&gt;</div>', 'code');
is($bbc->parse('[url]http://www.b10m.net/[/url]'), '<a href="http://www.b10m.net/">http://www.b10m.net/</a>', 'hyperlink (simple)');
is($bbc->parse('[url=http://www.b10m.net/]lame site[/url]'), '<a href="http://www.b10m.net/">lame site</a>', 'hyperlink (with link-text)');
is($bbc->parse('[email]foo@bar.com[/email]'), '<a href="mailto:foo@bar.com">foo@bar.com</a>', 'mailto-links');
is($bbc->parse('[img]foo.png[/img]'), '<img src="foo.png" />', 'image');
is($bbc->parse('[list][*]foo[*]bar[/list]'), '<ul><li>foo</li><li>bar</li></ul>', 'unordered list');
is($bbc->parse('[list=1][*]foo[*]bar[/list]'), '<ol><li>foo</li><li>bar</li></ol>', 'ordered list');
is($bbc->parse('[list=a][*]foo[*]bar[/list]'), '<ol style="list-style-type: lower-alpha;"><li>foo</li><li>bar</li></ol>', 'ordered list (alpha style)');

# Mix them and do 'em wrong!
is($bbc->parse('[b]bold, [i]bold and italic[/i][/b][/b]'), '<span style="font-weight: bold">bold, <span style="font-style: italic">bold and italic</span></span>[/b]', 'mixed, and "wrong"');

# new object, with options
$bbc = HTML::BBCode->new({ allowed_tags => [qw(email quote)] });
isa_ok($bbc, 'HTML::BBCode', 'default');

# Nested tags
is($bbc->parse('[quote="[email]b10m@perlmonk.org[/email]"]foo[/quote]'), '<div class="bbcode_quote_header"><a href="mailto:b10m@perlmonk.org">b10m@perlmonk.org</a> wrote:</div><div class="bbcode_quote_body">foo</div>', 'nested tags');

# Nested tags with disallowed tag
is($bbc->parse('[quote="[email]b10m@perlmonk.org[/email]"][b]foo[/b][/quote]'), '<div class="bbcode_quote_header"><a href="mailto:b10m@perlmonk.org">b10m@perlmonk.org</a> wrote:</div><div class="bbcode_quote_body">[b]foo[/b]</div>', 'nested tags (w/ disallowed tag)');

# new object, with no_html
$bbc = HTML::BBCode->new({ no_html => 1 });
isa_ok($bbc, 'HTML::BBCode', 'default');
is($bbc->parse('<i>[b]bold[/b]</i>'), '&lt;i&gt;<span style="font-weight: bold">bold</span>&lt;/i&gt;', 'no_html');

# new object, with linebreak
$bbc = HTML::BBCode->new({ linebreaks => 1 });
isa_ok($bbc, 'HTML::BBCode', 'default');
my $test=<<'__TEXT__';
This is a test to see
wheter linebreaks can be converted.
__TEXT__

is($bbc->parse($test), "This is a test to see<br />\nwheter linebreaks can be converted.<br />\n");
