#########################

use Test::Simple tests => 17;

#########################

use HTML::BBCode;

my $bbc = HTML::BBCode->new();
ok(defined($bbc));

# Basic parsing
ok($bbc->parse('[b]foo[/b]') eq '<span style="font-weight: bold">foo</span>');
ok($bbc->parse('[u]foo[/u]') eq '<span style="text-decoration: underline;">foo</span>');
ok($bbc->parse('[i]foo[/i]') eq '<span style="font-style: italic">foo</span>');
ok($bbc->parse('[color=red]foo[/color]') eq '<span style="color: red">foo</span>');
ok($bbc->parse('[size=24]foo[/size]') eq '<span style="font-size: 24px">foo</span>');
ok($bbc->parse('[quote]foo[/quote]') eq '<div class="bbcode_quote_header">Quote:</div><div class="bbcode_quote_body">foo</div>');
ok($bbc->parse('[quote="foo"]bar[/quote]') eq '<div class="bbcode_quote_header">foo wrote:</div><div class="bbcode_quote_body">bar</div>');
ok($bbc->parse('[code]<foo>[/code]') eq '<div class="bbcode_code_header">Code:</div><div class="bbcode_code_body">&lt;foo&gt;</div>');
ok($bbc->parse('[url]http://www.b10m.net/[/url]') eq '<a href="http://www.b10m.net/">http://www.b10m.net/</a>');
ok($bbc->parse('[url=http://www.b10m.net/]lame site[/url]') eq '<a href="http://www.b10m.net/">lame site</a>');
ok($bbc->parse('[email]foo@bar.com[/email]') eq '<a href="mailto:foo@bar.com">foo@bar.com</a>');
ok($bbc->parse('[img]foo.png[/img]') eq '<img src="foo.png" />');
ok($bbc->parse('[list][*]foo[*]bar[/list]') eq '<ul><li>foo</li><li>bar</li></ul>');
ok($bbc->parse('[list=1][*]foo[*]bar[/list]') eq '<ol><li>foo</li><li>bar</li></ol>');
ok($bbc->parse('[list=a][*]foo[*]bar[/list]') eq '<ol style="list-style-type: lower-alpha;"><li>foo</li><li>bar</li></ol>');

# Mix them and do 'em wrong!
ok($bbc->parse('[b]bold, [i]bold and italic[/i][/b][/b]') eq '<span style="font-weight: bold">bold, <span style="font-style: italic">bold and italic</span></span>[/b]');
