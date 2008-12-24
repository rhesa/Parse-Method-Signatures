use strict;
use warnings;

use Test::More tests => 16;
use Test::Differences;

use_ok('SlimSignature') or BAIL_OUT('Cannot continue');

eq_or_diff(
  scalar SlimSignature->signature('(Str $name)'),
  { params => [
      { tc => 'Str',
        var => '$name',
      }
    ]
  },
);

eq_or_diff(
  scalar SlimSignature->signature('(Str :$who, Int :$age where { $_ > 0 })'),
  { params => [
      { tc => 'Str',
        named => 1,
        var => '$who'
      },
      { tc => 'Int',
        named => 1,
        var => '$age',
        where => [
          '{ $_ > 0 }'
        ]
      },
    ]
  },
);

eq_or_diff( 
  scalar SlimSignature->signature('(Str $name, Bool :$excited = 0)'),
  { params => [
      { tc => 'Str',
        var => '$name',
      },
      { tc => 'Bool',
        var => '$excited',
        named => 1,
        default => '0'
      },
    ]
  },
);

eq_or_diff(
  scalar SlimSignature->signature('(Animal|Human $affe)'),
  { params => [
      { tc => 'Animal|Human',
        var => '$affe'
      },
    ]
  },
);

eq_or_diff(
  scalar SlimSignature->signature('(:$a, :$b, :$c)'),
  { params => [
      { var => '$a',
        named => 1
      },
      { var => '$b',
        named => 1
      },
      { var => '$c',
        named => 1
      },
    ]
  },
);

eq_or_diff( 
  scalar SlimSignature->signature('( $a,  $b, :$c)'),
  { params => [
      { var => '$a' },
      { var => '$b' },
      { var => '$c',
        named => 1
      },
    ]
  },
);

eq_or_diff( 
  scalar SlimSignature->signature('($a , $b!, :$c!, :$d!)'),
  { params => [
      { var => '$a' },
      { var => '$b',
        required => 1
      },
      { var => '$c',
        named => 1,
        required => 1
      },
      { var => '$d',
        named => 1,
        required => 1
      },
    ]
  },
);

eq_or_diff( 
  scalar SlimSignature->signature('($a?, $b?, :$c , :$d?)'),
  { params => [
      { var => '$a',
        optional => 1
      },
      { var => '$b',
        optional => 1
      },
      { var => '$c',
        named => 1,
      },
      { var => '$d',
        named => 1,
        optional => 1
      },
    ]
  },
);

eq_or_diff(
  scalar SlimSignature->signature('($self:  $moo)'),
  { params => [
      { var => '$moo' }
    ],
    invocant => {
      var => '$self'
    }
  },
);

# TODO: Should this have a empty invocant struct?
eq_or_diff(
  scalar SlimSignature->signature('(:     $affe ) # called as $obj->foo(affe => $value)'),
  { params => [
      { var => '$affe',
        named => 1
      }
    ]
  }, 
);

eq_or_diff(
  scalar SlimSignature->signature('(:apan($affe)) # called as $obj->foo(apan => $value)'),
  { params => [
      { label => 'apan',
        var => '$affe',
        named => 1
      }
    ]
  },
);

eq_or_diff(
  scalar SlimSignature->signature(q#(SomeClass $thing where { $_->can('stuff') }:
Str  $bar  = "apan"
Int :$baz! = 42 where { $_ % 2 == 0 } where { $_ > 10 })#),
  { params => [
      { tc => 'Str',
        var => '$bar',
        default => '"apan"'
      },
      { tc => 'Int',
        var => '$baz',
        named => 1,
        required => 1,
        where => [
          '{ $_ % 2 == 0 }',
          '{ $_ > 10 }'
        ],
        default => '42'
      }
    ],
    invocant => {
      tc => 'SomeClass',
      var => '$thing',
      where => [
        '{ $_->can(\'stuff\') }'
      ]
    }
  },
);


eq_or_diff(
  [ SlimSignature->signature('(Str $name)') ],
  [ { params => [
      { tc => 'Str',
        var => '$name',
      }
    ]
  }, ''],
);

eq_or_diff(
  [ SlimSignature->signature('(Str $name) further data }') ],
  [ { params => [
      { tc => 'Str',
        var => '$name',
      }
    ]
  }, 'further data }'],
);


eq_or_diff(
  [ SlimSignature->param(
      input => 'previous data(Str $name) further data }',
      offset => 14) ],
  [ { tc => 'Str',
      var => '$name',
    },
    ') further data }'],
);

