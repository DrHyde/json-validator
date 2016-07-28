package t::Helper;
use Mojo::Base -strict;
use Mojo::JSON 'encode_json';
use Mojo::Util 'monkey_patch';
use JSON::Validator;

my $validator = JSON::Validator->new;

sub validate_ok {
  my ($schema, $data, $expected) = @_;
  my $description ||= @$expected ? "errors: @$expected" : "expected: " . encode_json($data);
  Test::More::is_deeply(
    [map { $_->TO_JSON } sort { $a->path cmp $b->path } $validator->validate($data, $schema)],
    [map { $_->TO_JSON } sort { $a->path cmp $b->path } @$expected], $description);
}

sub import {
  my $class  = shift;
  my $caller = caller;

  strict->import;
  warnings->import;
  monkey_patch $caller => E           => \&JSON::Validator::E;
  monkey_patch $caller => false       => \&Mojo::JSON::false;
  monkey_patch $caller => true        => \&Mojo::JSON::true;
  monkey_patch $caller => validate_ok => \&validate_ok;
}

1;
