package WWW::Pagination;

use 5.005;
use strict;

our $VERSION = '0.35';

# {{{ constructor

# making all calculations and storing results at class hash for public access

sub new
{
    my $self = bless {}, shift;

    # statistics:

    $self->{total_entries} = shift;
    $self->{entries_per_page} = shift;
    $self->{pages_per_block} = shift;

    # pages control:

    # total number of pages
    $self->{total_pages} = int(($self->{total_entries} - 1) / $self->{entries_per_page}) + 1;

    # current page
    $self->{current_page} = shift;
    if ($self->{current_page} < 1) {
        $self->{current_page} = 1;
    } elsif ($self->{current_page} > $self->{total_pages}) {
        $self->{current_page} = $self->{total_pages};
    }

    # previous number of page
    # undefine, if haven't place to be
    $self->{prev_page} = $self->{current_page} - 1;
    if ($self->{prev_page} < 1) {
        $self->{prev_page} = undef;
    }

    # next number of page
    # undefine, if haven't place to be
    $self->{next_page} = $self->{current_page} + 1;
    if ($self->{next_page} > $self->{total_pages}) {
        $self->{next_page} = undef;
    }

    # block control:

    # start position of current block
    $self->{start_of_block} = int(($self->{current_page} - 1) / $self->{pages_per_block}) * $self->{pages_per_block} + 1;

    # end position of current block
    $self->{end_of_block} = $self->{start_of_block} + $self->{pages_per_block} - 1;
    if ($self->{end_of_block} > $self->{total_pages}) {
        $self->{end_of_block} = $self->{total_pages};
    }

    # nearest page number in previos block
    # undefine, if haven't place to be
    $self->{prev_block_page} = $self->{start_of_block} - 1;
    if ($self->{prev_block_page} < 1) {
        $self->{prev_block_page} = undef;
    }

    # nearest page number in next block
    # undefine, if haven't place to be
    $self->{next_block_page} = $self->{end_of_block} + 1;
    if ($self->{next_block_page} > $self->{total_pages}) {
        $self->{next_block_page} = undef;
    }

    # slice params:

    # start position in the slice
    $self->{start_of_slice} = ($self->{current_page} - 1) * $self->{entries_per_page};

    # end position in the slice
    $self->{end_of_slice} = $self->{current_page} * $self->{entries_per_page} - 1;
    if ($self->{end_of_slice} > $self->{total_entries} - 1) {
        $self->{end_of_slice} = $self->{total_entries} - 1;
    }

    # slice length
    $self->{length_of_slice} = $self->{end_of_slice} - $self->{start_of_slice} + 1;

    return $self;
}

# }}}

1;

__END__

=head1 NAME

WWW::Pagination - paginal navigation on a site

=head1 SYNOPSIS

  my $pg = WWW::Pagination->new(
     $total_entries,    # - count of SQL records or length of array or
                        #   something other (>= 1)
                        #   example: SELECT count(*) ...
                        #
     $entries_per_page, # - how much records (>= 1) maximum you want to
                        #   see on one page
                        #
     $pages_per_block,  # - how much pages you want to see in pages list.
                        #   if you don't want to use this feature, then
                        #   don't use, but some number (>= 1) must be
                        #   presented here
                        #
     $current_page      # - user specified number of page from
                        #   GET request. you must check this before.
                        #   must contain correct integer number!
  );

  # slice params intended for getting slice from list of records
  # example: SELECT ... LIMIT $pg->{start_of_slice},$pg->{length_of_slice}

  $pg->{start_of_slice};
  $pg->{end_of_slice};
  $pg->{length_of_slice};

  # statistics (copied from arguments)

  $pg->{total_entries};
  $pg->{entries_per_page};
  $pg->{pages_per_block};

  # pages control

  $pg->{total_pages};
  $pg->{current_page};
  $pg->{prev_page};
  $pg->{next_page};

  # block control

  $pg->{start_of_block};
  $pg->{end_of_block};
  $pg->{prev_block_page};
  $pg->{next_block_page};

=head1 DESCRIPTION

This is utility intended for simple organization of paginal navigation on
a site.

B<SCHEMATIC EXAMPLE:>

  WWW::Pagination->new(200, 10, 5, 7);

  RESULTS:
  ------------------------------------------------------------------------

  start_of_slice   - 60
  end_of_slice     - 69
  length_of_slice  - 10

  total_entries    - 200
  entries_per_page - 10
  pages_per_block  - 5

  total_pages      - 20
  current_page     - 7
  prev_page        - 6
  next_page        - 8

  start_of_block   - 6
  end_of_block     - 10
  prev_block_page  - 5
  next_block_page  - 11

  SCHEME:
  ------------------------------------------------------------------------

                  total_pages
                 /   total_entries
  Total pages: 20   /
  Total records: 200
  Shown from 61 to 70 records
               \     \
                \     start_of_slice + 1
                 end_of_slice + 1

                              current_page (7)
                prev_page (6)     |            next_page (8)
                      \           |                /
              <<       <       6 [7] 8 9 10       >       >>
              /               /           \                \
    prev_block_page (5)      /             \          next_block_page (11)
                            /               \
                    start_of_block (6)   end_of_block (10)

=head1 METHODS

=over 4

=item B<OBJ = WWW::Pagination-E<gt>new(total_entries, entries_per_page, pages_per_block, current_page)>

Making all calculations and storing results at class hash for public access

B<total_entries> - total number of entries (>= 1)

B<entries_per_page> - number of entries per page (>= 1)

B<pages_per_block> - number of pages in the block (>= 1)

B<current_page> - current number of page

Note: B<all arguments are required and must contains integer numbers>

=back

=head1 VARIABLES

=over 4

=item B<STATISTICS>

B<OBJ-E<gt>{total_entries}> - total number of entries (copied from arguments) (>= 1)

B<OBJ-E<gt>{entries_per_page}> - number of entries per page (copied from arguments) (>= 1)

B<OBJ-E<gt>{pages_per_block}> - number of pages in the block (copied from arguments) (>= 1)

=item B<PAGES CONTROL>

B<OBJ-E<gt>{total_pages}> - total number of pages (>= 1)

B<OBJ-E<gt>{current_page}> - current number of page (corrected) (>= 1)

B<OBJ-E<gt>{prev_page}> - previous number of page (>= 1) or undefined, if haven't place to be

B<OBJ-E<gt>{next_page}> - next number of page (>= 1) or undefined, if haven't place to be

=item B<BLOCK CONTROL>

B<OBJ-E<gt>{start_of_block}> - start position of current block (>= 1)

B<OBJ-E<gt>{end_of_block}> - end position of current block (>= 1)

B<OBJ-E<gt>{prev_block_page}> - nearest page number in previos block (>= 1) or undefined, if haven't place to be

B<OBJ-E<gt>{next_block_page}> - nearest page number in next block (>= 1) or undefined, if haven't place to be

=item B<SLICE PARAMS>

B<OBJ-E<gt>{start_of_slice}> - start position in the slice (>= 0)

B<OBJ-E<gt>{end_of_slice}> - end position in the slice (>= 0)

B<OBJ-E<gt>{length_of_slice}> - slice length (>= 1)

=back

=head1 AUTHOR

Andrian Zubko aka Ondr E<lt>ondr@cpan.orgE<gt>

=cut
