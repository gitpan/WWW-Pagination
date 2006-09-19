
# WWW::Pagination Makefile maker

use 5.005;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME           => 'WWW::Pagination',
    VERSION_FROM   => 'lib/WWW/Pagination.pm',
    ABSTRACT_FROM  => 'lib/WWW/Pagination.pm',
    AUTHOR         => 'Andrian Zubko aka Ondr <ondr@cpan.org>'
);
