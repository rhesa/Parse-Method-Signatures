
use strict;
use warnings;
use Test::More;

BEGIN {
    eval 'use MooseX::Declare';
    plan skip_all => 'MooseX::Declare required for these tests' if $@;
}

use Class::MOP;

{
    use MooseX::Declare;
    role MyParaRoleDoesNotPolluteMain (Str :$name) { }
}

is (Class::MOP::class_of('main'), undef); # package main not affected

{
    package MySame; # package can have same name as role
    use MooseX::Declare;
    role MySame (Str :$name) { has $name => ( is => 'ro', default => "$name" ); }
}

{
    use MooseX::Declare;
    class MyClass { with MySame => { name => "my_name" }; }
}

can_ok('MyClass', 'my_name');
is(MyClass->new(my_name => "author")->my_name, "author");

ok 1;

done_testing;

