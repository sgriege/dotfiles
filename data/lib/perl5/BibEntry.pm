package BibEntry;

use strict;
use warnings;

sub new #(type, key)
{
  my $class        = shift;
  my ($type, $key) = @_;

  my $self = {type       => $type,
              key        => $key,
              fields     => [],
              field_data => {}};

  bless($self, $class);

  return $self;
}

sub clone #()
{
  my $self = shift;

  my $clone = ref($self)->new($self->{'type'}, $self->{'key'});

  @{$clone->{'fields'}}     = @{$self->{'fields'}};
  %{$clone->{'field_data'}} = %{$self->{'field_data'}};

  return $clone;
}

sub get_type #()
{
  my $self = shift;

  return $self->{'type'};
}

sub set_type #(type)
{
  my $self   = shift;
  my ($type) = @_;

  $self->{'type'} = $type;

  return $self;
}

sub get_key #()
{
  my $self = shift;

  return $self->{'key'};
}

sub add_field #(name, data)
{
  my $self          = shift;
  my ($name, $data) = @_;

  die 'Field "' . $name . '" already exists' . "\n"
    if (exists $self->{'field_data'}{$name});

  push(@{$self->{'fields'}}, $name);
  $self->{'field_data'}{$name} = $data;

  return $self;
}

sub remove_field #(name)
{
  my $self   = shift;
  my ($name) = @_;

  die 'Field "' . $name . '" does not exist' . "\n"
    unless (exists $self->{'field_data'}{$name});

  my @new_fields = ();

  for my $field (@{$self->{'fields'}}) {
    push(@new_fields, $field)
      unless ($field eq $name);
  }

  @{$self->{'fields'}} = @new_fields;
  delete $self->{'field_data'}{$name};

  return $self;
}

sub rename_field #(name, new_name)
{
  my $self              = shift;
  my ($name, $new_name) = @_;

  die 'Field "' . $name . '" does not exist' . "\n"
    unless (exists $self->{'field_data'}{$name});

  my @new_fields = ();

  for my $field (@{$self->{'fields'}}) {
    if ($field eq $name) {
      push(@new_fields, $new_name);
    }
    else {
      push(@new_fields, $field);
    }
  }

  @{$self->{'fields'}}             = @new_fields;
  $self->{'field_data'}{$new_name} = $self->{'field_data'}{$name};
  delete $self->{'field_data'}{$name};

  return $self;
}

sub set_field_data #(name, data)
{
  my $self          = shift;
  my ($name, $data) = @_;

  die 'Field "' . $name . '" does not exist' . "\n"
    unless (exists $self->{'field_data'}{$name});

  $self->{'field_data'}{$name} = $data;

  return $self;
}

sub has_field #(name)
{
  my $self   = shift;
  my ($name) = @_;

  return exists $self->{'field_data'}{$name};
}

sub get_field_data #(name)
{
  my $self   = shift;
  my ($name) = @_;

  die 'Field "' . $name . '" does not exist' . "\n"
    unless (exists $self->{'field_data'}{$name});

  return $self->{'field_data'}{$name};
}

sub write_to_file_handle #(fh)
{
  my $self = shift;
  my ($fh) = @_;

  # Find longest field name.
  my $max_length = 0;
  foreach my $field (@{$self->{'fields'}}) {
    $max_length = length($field)
      if (length($field) > $max_length);
  }

  print $fh '@' . $self->{'type'} . '{' . $self->{'key'} . ',' . "\n";
  foreach my $field (@{$self->{'fields'}}) {
    print $fh sprintf('  %-*s = {%s},',
                      $max_length, $field, $self->{'field_data'}{$field})
      . "\n";
  }
  print $fh '}' . "\n";

  return $self;
}

1;
