package SubCmd::MethLevDist;

use strict;
use warnings;
use File::Basename;
use FindBin;
use Pod::Usage;
use Cwd qw(abs_path);
use Term::ANSIColor;

use Meth::LevDist;
use SubCmd::CommonArgument;

## class, $opts, $opts_sub
sub new{
    my $class     = shift;
    return bless {}, $class;  # built in bless function 
}

sub check_para_sub{

    my ($class, $opts_sub, $opts) = @_;

    if($opts->{help}){
        pod2usage(-exitval => 0, -verbose => 2, -input => "$FindBin::Bin/doc/pod4help_MethLevDist.txt");
        exit 0;
    }

    if(!&check_para($class, $opts_sub)){
        print "Please provide parameters\n";
        pod2usage(-exitval => 1, -verbose => 2, -input => "$FindBin::Bin/doc/pod4help_MethLevDist.txt");
        exit 0;
    }

    my $exit_code = 0;

    if(!@{$opts_sub->{"sample"}}){
	print "Please provide --sample!\n";
	++$exit_code; #exit 0;
    }
    #print "After sample: $exit_code\n";

    if($opts_sub->{region}){
        $opts_sub->{region} = abs_path $opts_sub->{region};
	print "\nDistribution of methylation levels in $opts_sub->{region} will be calculated!\n\n";
    }

    if(!$opts_sub->{"binMethLev"}){
        $opts_sub->{"binMethLev"} = 0.1;
    }
    print "Bin size is: $opts_sub->{binMethLev}\n";

    ### Common arguments
    my $cm_arg = SubCmd::CommonArgument -> new();
    my $exit_num_return = $cm_arg -> common_argument($opts_sub);
    $exit_code += $exit_num_return;
 
    if($exit_code > 0){
	print "$exit_code\n";
        exit 0;
    }else{
	return "TRUE";
    }
}

sub check_para{
    my ($class, $opts) = @_;
    my $def = 0;
    my $num = 0;
    foreach(values %$opts){
        if(defined $_){
	    ## if one argument can be used multiple times. Even if you don't provide the argument, the value would be an reference to an array.
	    if(!/ARRAY/ || @{$_}){
		#print "Value\t@{$_}\n";
                $def ++;
	    }
        }
        ++$num;
    }
    if($def == 0){
        return 0;   ## No parameter was provide!
    }else{
        return 1;
    }
}

sub run_methLevDist{ 
    my ($class, $opts_sub) = @_;
    my $meth_geno = Meth::LevDist->new();
    print "$class\n"; 
    $meth_geno -> calMeth($opts_sub);
    $meth_geno -> drawMeth($opts_sub);
}

1;
