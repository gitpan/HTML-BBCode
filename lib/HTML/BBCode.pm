package HTML::BBCode;

=head1 NAME

HTML::BBCode - Perl extension for converting BBcode to HTML.

=head1 SYNOPSIS

  use HTML::BBCode;

  my $bbc  = HTML::BBCode->new( \%options );
  my $html = $bbc->parse($bbcode);

=head1 DESCRIPTION

C<HTML::BBCode> converts BBCode -as used on the phpBB bulletin
boards- to it's HTML equivalent.

=head2 METHODS

The following methods can be used

=head3 new
   
   my $bbc = HTML::BBCode->new({
      allowed_tags => [ @bbcode_tags ],
      html_tags    => \%html_tags, 
      match        => \%match, 
      substitute   => \%substitute,
      no_html	   => 1,
      linebreaks   => 1,
   });

C<new> creates a new C<HTML::BBCode> object using the configuration
passed to it. The object's default configuration allows all BBCode to
be converted to the default HTML.

=head4 options

=over 5

=item allowed_tags

Defaults to all currently know C<BBCode tags>, being:
b, u, i, color, size, quote, code, list, url, email, img. With this
option, you can specify what BBCode tags you would like to convert.

=item html_tags

Configures the wanted output in HTML. Defaults to (almost) the same as
used on the phpbb bulletin boards (<b>, <u> etc. have been turned into
their CSS equivalents).

=item match

Specifies the regexp needed to catch the BBCode.

=item substitute

Specifies the substitute command for the C<match> regexp.

=item no_html

Disabled by default.

When true, HTML tags will be converted from '<br />' to '&lt;br /&gt'

=item linebreaks

Disabled by default.

When true, will substitute linebreaks into HTML ('<br />')

=back

=head3 parse

   my $html = $bbc->parse($bbcode); 

Parses text supplied as a single scalar string and returns the HTML as 
a single scalar string.

=head1 SEE ALSO

http://www.b10m.net/cgi-bin/HTML-BBCode.cgi
http://www.phpbb.com/phpBB/faq.php?mode=bbcode

=head1 BUGS

C<Bugs? Impossible!>. This module is still experimental. Please
notify the author when you find bugs.

=head1 AUTHOR

M. Blom, E<lt>b10m@perlmonk.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by M. Blom

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
#------------------------------------------------------------------------------#
use strict;
use warnings;
use Data::Dumper;

our $VERSION = '0.04';
our @bbcode_tags = qw(code quote b u i color size list url email img);

sub new {
   my ($class, $args) = @_;
   $args ||= {};
   $class->_croak("Options must be a hash reference")
      if ref($args) ne 'HASH';
   my $self = {};
   bless $self, $class;
   $self->_init($args) or return undef;

   return $self;
}

sub _init {
   my ($self, $args) = @_;

   my %html_tags   = (
     code       => '<div class="bbcode_code_header">Code:</div>'.
                   '<div class="bbcode_code_body">%s</div>',
     quote      => '<div class="bbcode_quote_header">%s</div>'.
                   '<div class="bbcode_quote_body">%s</div>',
     b          => '<span style="font-weight: bold">%s</span>', 
     u          => '<span style="text-decoration: underline;">%s</span>',
     i          => '<span style="font-style: italic">%s</span>', 
     color      => '<span style="color: %s">%s</span>',
     size       => '<span style="font-size: %spx">%s</span>',
     url        => '<a href="%s">%s</a>',
     email      => '<a href="mailto:%s">%s</a>',
     img        => '<img src="%s" />',
     ul         => '<ul>%s</ul>',
     ol_number  => '<ol>%s</ol>',
     ol_alpha   => '<ol style="list-style-type: lower-alpha;">%s</ol>',
   );

   my %match = (
     code  => qr|\[code\](.+?)\[/code\]|iso,
     quote => qr|\[quote(="([^"]+)")?\](.+?)\[/quote\]|iso,
     b     => qr|\[b\](.+?)\[/b\]|iso,
     u     => qr|\[u\](.+?)\[/u\]|iso,
     i     => qr|\[i\](.+?)\[/i\]|iso,
     color => qr|\[color=(.+?)\](.+?)\[/color\]|iso,
     size  => qr|\[size=(.+?)\](.+?)\[/size\]|iso,
     url   => qr|\[url[=]?([^\]]+?)?\](.+?)\[/url\]|iso,
     email => qr|\[email\](.+?)\[/email\]|iso,
     img   => qr|\[img\](.+?)\[/img\]|iso,
     list  => qr|\[list[=]?([^\]]+?)?\](.+?)\[/list\]|iso,
   );

   my %substitute = (
     code  => 'sprintf($html_tags{code},&_code($1))',
     quote => 'sprintf($html_tags{quote},($2)?"$2 wrote:":"Quote:", $3)',
     b     => 'sprintf($html_tags{b},$1)',
     u     => 'sprintf($html_tags{u},$1)',
     i     => 'sprintf($html_tags{i},$1)',
     color => 'sprintf($html_tags{color}, $1, $2)',
     size  => 'sprintf($html_tags{size}, $1, $2)',
     url   => 'sprintf($html_tags{url},($1)?$1:$2, $2)',
     email => 'sprintf($html_tags{email}, $1, $1)',
     img   => 'sprintf($html_tags{img}, $1)',
     list  => '&_list($self, $1, $2)',
   );

   my %options = ( 
                  allowed_tags => [ @bbcode_tags ],
                  html_tags    => \%html_tags, 
                  match        => \%match, 
                  substitute   => \%substitute, 
                  no_html      => 0,
                  linebreaks   => 0,
                  %{ $args },
                 );

   $self->{options} = \%options;

   return $self;
}

sub parse {
   my ($self, $bbcode) = @_;
   $self->{bbcode} = $bbcode; 
   $self->{html} = $bbcode; 

   my %match      = %{ $self->{options}->{match} };
   my %substitute = %{ $self->{options}->{substitute} };
   my %html_tags  = %{ $self->{options}->{html_tags} };

   # "Strip" HTML input
   if($self->{options}->{no_html}) {
      $self->{html} =~ s|<|&lt;|gs;
      $self->{html} =~ s|>|&gt;|gs;
   }

   # Substitute linebreaks
   $self->{html} =~ s|\n|<br />\n|gs if($self->{options}->{linebreaks});
  
   # Substitute the BBCode
   map { 
         if(_is_allowed($self, $_)) {
          $self->{html} =~ s|$match{$_}|$substitute{$_}|eegis
         }
       } @bbcode_tags;

   return $self->{html};
}

sub _is_allowed {
   my ($self, $check) = @_;
   map { 
         return 1 if ($_ eq $check); 
       } @{$self->{options}->{allowed_tags}};
   return 0; 
}

sub _code {
   my $code = shift;
   $code =~ s|^\n||;
   $code =~ s|<|\&lt;|g;
   $code =~ s|>|\&gt;|g;
   $code =~ s|\[|\&#091;|g;
   $code =~ s|\]|\&#093;|g;
   $code =~ s| |\&nbsp;|g;
   $code =~ s|\n|<br />|g;
   return $code;
}

sub _list {
   my ($self, $type, $list) = @_;
   my $html;
   if($type) {
      $html = $self->{options}->{html_tags}->{ol_number} if($type =~ m|^\d|);
      $html = $self->{options}->{html_tags}->{ol_alpha} if($type =~ m|^\D|i);
   }
   else {
      $html = $self->{options}->{html_tags}->{ul}; 
   }

   $list =~ s|\[\*\]([^\[]+)|<li>$1</li>|gs;
   return sprintf($html, $list);
}

sub _croak {
    my ($class, @error) = @_;
    require Carp;
    Carp::croak(@error);
}

1;
__END__
