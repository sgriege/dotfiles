package Bib;

use 5.036;
use strict;
use warnings;

use BibEntry;

sub new #()
{
  my $class = shift;

  my $self = {entries => []};

  bless($self, $class);

  return $self;
}

sub add_entry #(entry)
{
  my $self    = shift;
  my ($entry) = @_;

  push(@{$self->{'entries'}}, $entry);
  return $self;
}

sub read_from_file_handle #(fh)
{
  my $self = shift;
  my ($fh) = @_;

  my $in_entry = 0;
  my $entry    = undef;
  my $line_num = 1;

  while (my $line = <$fh>) {
    if (not $in_entry) {
      if ($line =~ m'^\s*\@(\w+)\{(\w+)\s*,\s*$'o) {
        # Start of entry.
        $in_entry = 1;
        $entry    = BibEntry->new($1, $2);
      }
      else {
        # Unparsed string.
        $self->add_entry($line);
      }
    }
    else {
      if ($line =~ m'^\s*(\w+)\s*=\s*\{(.*)\}\s*,?\s*$'o) {
        # Entry field.
        $entry->add_field($1, $2);
      }
      elsif ($line =~ m'^\s*\}\s*$'o) {
        # End of entry.
        $self->add_entry($entry);
        $entry    = undef;
        $in_entry = 0;
      }
      elsif ($line =~ m'^\s*$'o) {
        # Empty line.
      }
      else {
        die 'Failed to parse line ' . $line_num . "\n";
      }
    }

    $line_num++;
  }
}

sub get_entries #()
{
  my $self = shift;

  return @{$self->{'entries'}};
}

sub write_to_file_handle #(fh)
{
  my $self = shift;
  my ($fh) = @_;

  foreach my $entry ($self->get_entries()) {
    if ($entry isa BibEntry) {
      $entry->write_to_file_handle($fh);
    }
    else {
      print $fh $entry;
    }
  }
}

1;
