package HTML::BBCode::StripScripts;

use strict;
use base qw(HTML::StripScripts::Parser);

our $VERSION = '0.01';

my %bbattrib;
my %bbstyle;
my %bbstyle_overrides = (
   'text-decoration' => 'word',
   'font-style'      => 'word',
   'font-weight'     => 'word',
   'list-style-type' => 'word',
);


sub init_attrib_whitelist {
   unless (%bbattrib) {
      %bbattrib = %{__PACKAGE__->SUPER::init_attrib_whitelist};
      $bbattrib{'h5'}{'class'} = 'word';
   } 
   return \%bbattrib;
}       

sub init_style_whitelist {
   unless (%bbstyle) {
      %bbstyle = %{__PACKAGE__->SUPER::init_style_whitelist};
      @bbstyle{keys %bbstyle_overrides} = values %bbstyle_overrides;
   }     
   return \%bbstyle;
}       

1;
