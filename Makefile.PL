use ExtUtils::MakeMaker;

my $mm_ver = $ExtUtils::MakeMaker::VERSION;
if ($mm_ver =~ /_/) { # dev version
    $mm_ver = eval $mm_ver;
    die $@ if $@;
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'ex::constant::vars',
    'VERSION_FROM'	=> 'lib/ex/constant/vars.pm', # finds $VERSION
    'PREREQ_PM'		=> {
                        Carp     => 0,
                        Exporter => 0,
                       },

    ($mm_ver <= 6.45
        ? ()
        : (META_MERGE => {
            'meta-spec' => { version => 2 },
            resources => {
                bugtracker  => 'http://rt.cpan.org/Public/Dist/Display.html?Name=ex-constant-vars',
                repository  => {
                    type => 'git',
                    web  => 'https://github.com/neilbowers/ex-constant-vars',
                    url  => 'git://github.com/neilbowers/ex-constant-vars.git',
                },
            },
          })
    ),

    ($mm_ver >= 6.48
        ? (MIN_PERL_VERSION => 5.006)
        : ()
    ),

    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),

);
