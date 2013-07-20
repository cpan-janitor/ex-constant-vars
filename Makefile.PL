use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'ex::constant::vars',
    'VERSION_FROM'	=> 'lib/ex/constant/vars.pm', # finds $VERSION
    'PREREQ_PM'		=> {
                        Carp     => 0,
                        Exporter => 0,
                       },
    META_MERGE => {
        resources => {
            repository => 'https://github.com/neilbowers/ex-constant-vars',
        },
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),

);
