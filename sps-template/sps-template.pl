##############################################################################
#
# This file is part of the SPS Suite
#
# (c) Piotr Synowiec <psynowiec@gmail.com>
#
# Date: Tuesday, 14 November 2000 (initial)
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
##############################################################################

use XSPST_LC;
use Term::ANSIColor;
use Tk;
use Tk::DialogBox;
use Tk::Optionmenu;
use Tk::ROTextANSIColor;
use Tk::Button;
use Tk::NoteBook;
use Tk::ROText;
use Tk::Label;
use Tk::Radiobutton;
use Tk::Entry;

$PRG_NAME =	'sps-template';
$PRG_VER =	'3.0.0';
$PRG_DATE =	"15 Apr 2018";
$PRG_AUTHOR =	'Piotr Synowiec';
$SPS_SUITE_CFG = "sps-suite.cfg";

################################################## 
# zmienne ktore moga isc do pliku z konfiguracja #
$LINE_COLOR = 'red';                             #
$RPS_COLOR  = 'blue';                            #
$SPS_COLOR  = 'blue';                            #
$XPS_COLOR  = 'blue';                            #
##################################################
$BUTTON_T_OPEN   = 1;
$BUTTON_T_SAVE   = 1;
$BUTTON_T_SAVEAS = 1;
##################################################




$ENTRY_WIDTH = 3;
$FILE_TEMPLATE_IS_DIRTY = 0;
$FILE_TEMPLATE_NEW = 0;

# tablice do przechowywania kilku lini plikow SPS
@RPSBUF = "";
@SPSBUF = "";
@XPSBUF = "";


$NOFLINES = 10; # number of lines to read from SPS files
$LINE0 = "00000000011111111112222222222333333333344444444445555555555666666666677777777778\n";
$LINE1 = "12345678901234567890123456789012345678901234567890123456789012345678901234567890\n";


ConfigCheck();
ConfigLoad();

$MW = MainWindow->new();
$MW->title( $PRG_NAME );

# zablokowanie mozliwosci zmiany rozmiaru okna (Perl receptury str. 516 )
$MW->bind('<Configure>'=>sub{$xe=$MW->XEvent; $MW->maxsize($xe->w, $xe->h); $MW->minsize($xe->w, $xe->h); } );
$MW->bind('<Destroy>'=>\&ExitProgram);

$menubar = $MW->Frame( -relief=>'raised', -borderwidth=>2 )->pack( -side=>'top', -fill=>'x' ); 
# File Menu
$file_menu = $menubar->Menubutton( -text=>XSPST_LC::LC('File'), -height=>1, -tearoff=>0 )->pack( -side => 'left' );
$file_menu->command( -label=>XSPST_LC::LC('Template New'), -command=>\&TemplateNew );
$file_menu->command( -label=>XSPST_LC::LC('Template Open'), -command=>\&TemplateOpen );
$FILE_MENU_TEMPLATE_SAVE = $file_menu->command( -label=>XSPST_LC::LC('Template Save'), -command=>\&TemplateSave );
$FILE_MENU_TEMPLATE_SAVEAS = $file_menu->command( -label=>XSPST_LC::LC('Template SaveAs'), -command=>\&TemplateSaveAs );
$file_menu->separator();
$file_menu->command( -label=>XSPST_LC::LC('RPS Open'), -command=>\&RPSOpen );
$file_menu->command( -label=>XSPST_LC::LC('SPS Open'), -command=>\&SPSOpen );
$file_menu->command( -label=>XSPST_LC::LC('XPS Open'), -command=>\&XPSOpen );
$file_menu->separator();
$file_menu->command( -label=>XSPST_LC::LC('Exit'), -command=>\&ExitProgram  );		   

# Help Menu
$help_menu = $menubar->Menubutton( -text=>XSPST_LC::LC('Help'), -height=>1, -tearoff=>0 )->pack( -side=>'right' );
$help_menu->command( -label=>XSPST_LC::LC('About'), -command=>\&HelpAbout );		   

my $fr1 = $MW->Frame()->pack( -side => 'top', -fill => 'both' ); 
if( $BUTTON_T_OPEN )
{
	$fr1->Button( -text=>XSPST_LC::LC('Template Open'), -command =>\&TemplateOpen, -anchor=>'w' )
    		    ->pack( -side=>'left', -padx=>1, -pady=>1);
}
if( $BUTTON_T_SAVE )
{
	$BUTTON_TEMPLATE_SAVE = $fr1->Button( -text=>XSPST_LC::LC('Template Save'), -command =>\&TemplateSave, -anchor=>'w' )
    		    ->pack( -side=>'left', -padx=>1, -pady=>1);
}
if( $BUTTON_T_SAVEAS )
{
	$BUTTON_TEMPLATE_SAVEAS = $fr1->Button( -text=>XSPST_LC::LC('Template SaveAs'), -command =>\&TemplateSaveAs, -anchor=>'w' )
    		    ->pack( -side=>'left', -padx=>1, -pady=>1);
}

my $NB = $MW->NoteBook()->pack(-side=>"top", -anchor=>"nw", -fill=>'x');
my $P1 = $NB->add( "P1", -label=>"RPS" );
my $P2 = $NB->add( "P2", -label=>"SPS" );
my $P3 = $NB->add( "P3", -label=>"XPS" );

$PRZERWA = " " x 5;

#
# RECEIVER
#
@RPS_B = qw( ID LN PN PI PC SC PD SD UT WD X Y Z DY TM );
$RPS_DESCR{ "ID" } = XSPST_LC::LC('Record ID');
$RPS_DESCR{ "LN" } = XSPST_LC::LC('Line Name'); 
$RPS_DESCR{ "PN" } = XSPST_LC::LC('Point Number'); 
$RPS_DESCR{ "PI" } = XSPST_LC::LC('Point Index');
$RPS_DESCR{ "PC" } = XSPST_LC::LC('Point Code');
$RPS_DESCR{ "SC" } = XSPST_LC::LC('Static Correction');
$RPS_DESCR{ "PD" } = XSPST_LC::LC('Point Depth');
$RPS_DESCR{ "SD" } = XSPST_LC::LC('Seismic Datum');
$RPS_DESCR{ "UT" } = XSPST_LC::LC('Uphole Time');
$RPS_DESCR{ "WD" } = XSPST_LC::LC('Water Depth');
$RPS_DESCR{ "X" } = XSPST_LC::LC('Grid Easting');
$RPS_DESCR{ "Y" } = XSPST_LC::LC('Grid Northing');
$RPS_DESCR{ "Z" } = XSPST_LC::LC('Surface Elevation');
$RPS_DESCR{ "DY" } = XSPST_LC::LC('Day of Year');
$RPS_DESCR{ "TM" } = XSPST_LC::LC('Time of Day');

$RPS_VAR;
my $fr1p1 = $P1->Frame()->pack( -side => 'top', -fill => 'both' ); 
$fr1p1->Button( -text=>XSPST_LC::LC('SPS Receiver File'), -command =>\&RPSOpen, -anchor=>'w' )
      ->pack( -side=>'left', -padx=>1, -pady=>1); 		
$fr1p1->Label( -textvariable => \$FILE_RPS )->pack( -side=>'left', -padx=>1, -pady=>1 );

my $fr2p1 = $P1->Frame()->pack( -side => 'top', -fill => 'both' ); 
$status_width = 60;

$rps_stat = $fr2p1->ROTextANSIColor( -width=>85, -height=>6, -wrap=>'none' )->pack();
 
my $fr3p1 = $P1->Frame()->pack( -side => 'left', -fill => 'both' ); 

my ($row, $col) = ( 0, 0 );
foreach my $s (@RPS_B) 
{
	$fr3p1->Radiobutton( -text=>$RPS_DESCR{$s}, -value=>$s, -variable=>\$RPS_VAR, -command=>\&RPSRefresh ) 
                                       ->grid( -row=>$row, -column=>$col, -sticky=>'w', -padx=>2 );
         
        my $ent = $fr3p1->Entry( -textvariable=>\${RPS_.${s}._C1}, -width=>$ENTRY_WIDTH, -justify=>'right' )
                        ->grid( -row=>$row, -column=>$col+1, -sticky=>'w', -padx=>2 );
	$ent->bind('<Return>'=>\&RPSRefresh); $ent->bind('<Tab>'=>\&RPSRefresh);
	                     
        my $ent = $fr3p1->Entry( -textvariable=>\${RPS_.${s}._C2}, -width=>$ENTRY_WIDTH, -justify=>'right' )
                     	->grid( -row=>$row, -column=>$col+2, -sticky=>'w', -padx=>2 );                     
	$ent->bind('<Return>'=>\&RPSRefresh); $ent->bind('<Tab>'=>\&RPSRefresh);                     	
	$fr3p1->Label( -text=>$PRZERWA )->grid( -row=>$row, -column=>$col+3, -sticky=>'w', -padx=>2 );
	$row++; 
	if( $row == 5 ) { $col += 4; $row = 0; }
}

#
# SOURCE
#
@SPS_B = qw( ID LN PN PI PC SC PD SD UT WD X Y Z DY TM );
$SPS_DESCR{ "ID" } = XSPST_LC::LC('Record ID');
$SPS_DESCR{ "LN" } = XSPST_LC::LC('Line Name'); 
$SPS_DESCR{ "PN" } = XSPST_LC::LC('Point Number'); 
$SPS_DESCR{ "PI" } = XSPST_LC::LC('Point Index');
$SPS_DESCR{ "PC" } = XSPST_LC::LC('Point Code');
$SPS_DESCR{ "SC" } = XSPST_LC::LC('Static Correction');
$SPS_DESCR{ "PD" } = XSPST_LC::LC('Point Depth');
$SPS_DESCR{ "SD" } = XSPST_LC::LC('Seismic Datum');
$SPS_DESCR{ "UT" } = XSPST_LC::LC('Uphole Time');
$SPS_DESCR{ "WD" } = XSPST_LC::LC('Water Depth');
$SPS_DESCR{ "X" } = XSPST_LC::LC('Grid Easting');
$SPS_DESCR{ "Y" } = XSPST_LC::LC('Grid Northing');
$SPS_DESCR{ "Z" } = XSPST_LC::LC('Surface Elevation');
$SPS_DESCR{ "DY" } = XSPST_LC::LC('Day of Year');
$SPS_DESCR{ "TM" } = XSPST_LC::LC('Time of Day');

$SPS_VAR;
my $fr1p2 = $P2->Frame()->pack( -side => 'top', -fill => 'both' ); 
$fr1p2->Button( -text=>XSPST_LC::LC('SPS Source File'), -command =>\&SPSOpen, -anchor=>'w' )
      ->pack( -side=>'left', -padx=>1, -pady=>1); 		
$fr1p2->Label( -textvariable => \$FILE_SPS )->pack( -side=>'left', -padx=>1, -pady=>1 );

my $fr2p2 = $P2->Frame()->pack( -side => 'top', -fill => 'both' ); 
$status_width = 60;

$sps_stat = $fr2p2->ROTextANSIColor( -width=>85, -height=>6, -wrap=>'none' )->pack();
 
my $fr3p2 = $P2->Frame()->pack( -side => 'left', -fill => 'both' ); 

my ($row, $col) = ( 0, 0 );
foreach my $s (@SPS_B) 
{
	$fr3p2->Radiobutton( -text=>$SPS_DESCR{$s}, -value=>$s, -variable=>\$SPS_VAR, -command=>\&SPSRefresh ) 
                                       ->grid( -row=>$row, -column=>$col, -sticky=>'w', -padx=>2 );
         
        my $ent = $fr3p2->Entry( -textvariable=>\${SPS_.${s}._C1}, -width=>$ENTRY_WIDTH, -justify=>'right' )
                        ->grid( -row=>$row, -column=>$col+1, -sticky=>'w', -padx=>2 );
	$ent->bind('<Return>'=>\&SPSRefresh); $ent->bind('<Tab>'=>\&SPSRefresh);
	                     
        my $ent = $fr3p2->Entry( -textvariable=>\${SPS_.${s}._C2}, -width=>$ENTRY_WIDTH, -justify=>'right' )
                     	->grid( -row=>$row, -column=>$col+2, -sticky=>'w', -padx=>2 );                     
	$ent->bind('<Return>'=>\&SPSRefresh); $ent->bind('<Tab>'=>\&SPSRefresh);                     	
	$fr3p2->Label( -text=>$PRZERWA )->grid( -row=>$row, -column=>$col+3, -sticky=>'w', -padx=>2 );
	$row++; 
	if( $row == 5 ) { $col += 4; $row = 0; }
}


#
# RELATIONAL
#
@XPS_B = qw( ID TP RN RI IC LN PN PI FC TC CI RL FR TR RX );
$XPS_DESCR{ "ID" } = XSPST_LC::LC('Record ID');
$XPS_DESCR{ "TP" } = XSPST_LC::LC('Tape Number'); 
$XPS_DESCR{ "RN" } = XSPST_LC::LC('File Number'); 
$XPS_DESCR{ "RI" } = XSPST_LC::LC('File Increment');
$XPS_DESCR{ "IC" } = XSPST_LC::LC('Instrument Code');
$XPS_DESCR{ "LN" } = XSPST_LC::LC('Line Name');
$XPS_DESCR{ "PN" } = XSPST_LC::LC('Point Number');
$XPS_DESCR{ "PI" } = XSPST_LC::LC('Point Index');
$XPS_DESCR{ "FC" } = XSPST_LC::LC('From Channel');
$XPS_DESCR{ "TC" } = XSPST_LC::LC('To Channel');
$XPS_DESCR{ "CI" } = XSPST_LC::LC('Channel Increment');
$XPS_DESCR{ "RL" } = XSPST_LC::LC('Receiver Line');
$XPS_DESCR{ "FR" } = XSPST_LC::LC('From Receiver Point');
$XPS_DESCR{ "TR" } = XSPST_LC::LC('To Receiver Point');
$XPS_DESCR{ "RX" } = XSPST_LC::LC('Receiver Point Increment');

$XPS_VAR;
my $fr1p3 = $P3->Frame()->pack( -side => 'top', -fill => 'both' ); 
$fr1p3->Button( -text=>XSPST_LC::LC('SPS Relational File'), -command =>\&XPSOpen, -anchor=>'w' )
      ->pack( -side=>'left', -padx=>1, -pady=>1); 		
$fr1p3->Label( -textvariable => \$FILE_XPS )->pack( -side=>'left', -padx=>1, -pady=>1 );

my $fr2p3 = $P3->Frame()->pack( -side => 'top', -fill => 'both' ); 
$status_width = 60;

$xps_stat = $fr2p3->ROTextANSIColor( -width=>85, -height=>6, -wrap=>'none' )->pack();
 
my $fr3p3 = $P3->Frame()->pack( -side => 'left', -fill => 'both' ); 

my ($row, $col) = ( 0, 0 );
foreach my $s (@XPS_B) 
{
	$fr3p3->Radiobutton( -text=>$XPS_DESCR{$s}, -value=>$s, -variable=>\$XPS_VAR, -command=>\&XPSRefresh ) 
                                       ->grid( -row=>$row, -column=>$col, -sticky=>'w', -padx=>2 );
         
        my $ent = $fr3p3->Entry( -textvariable=>\${XPS_.${s}._C1}, -width=>$ENTRY_WIDTH, -justify=>'right' )
                        ->grid( -row=>$row, -column=>$col+1, -sticky=>'w', -padx=>2 );
	$ent->bind('<Return>'=>\&XPSRefresh); $ent->bind('<Tab>'=>\&XPSRefresh);
	                     
        my $ent = $fr3p3->Entry( -textvariable=>\${XPS_.${s}._C2}, -width=>$ENTRY_WIDTH, -justify=>'right' )
                     	->grid( -row=>$row, -column=>$col+2, -sticky=>'w', -padx=>2 );                     
	$ent->bind('<Return>'=>\&XPSRefresh); $ent->bind('<Tab>'=>\&XPSRefresh);                     	
	$fr3p3->Label( -text=>$PRZERWA )->grid( -row=>$row, -column=>$col+3, -sticky=>'w', -padx=>2 );
	$row++; 
	if( $row == 5 ) { $col += 4; $row = 0; }
}

TemplateCheck();

$frXX = $MW->Frame()->pack( -side => 'top', -fill => 'both' ); 
$xxlabel = "(c) " . $PRG_AUTHOR ." Ver ". $PRG_VER . " - ". $PRG_DATE;
$frXX->Label( -text => $xxlabel )->pack( -side=>'left', -padx=>1, -pady=>1 );

#
# dummy frame to keep size
#
$MW->Frame(-width  => 600)->pack(-side => 'top', -fill => 'x'); 

MainLoop;

##########################################
####  PROGRAM SUBROUTINES DEFINITION  ####
##########################################
sub Title
{
  	$MW->title( $PRG_NAME ." - ". $_[0] );
}

sub StatusWrite 
{
	my $text = shift;
	my $str = shift;
	my $ret = $text->insert('end', $str);
	$text->update;
}

sub TemplateNew
{
	$FILE_TEMPLATE_NEW = 1;
	$FILE_TEMPLATE = '';

	#  RECEIVER
	$RPS_ID_S =  0;          $RPS_ID_L =  1;
	$RPS_LN_S =  1;          $RPS_LN_L = 16;
	$RPS_PN_S = 17;          $RPS_PN_L =  8;
	$RPS_PI_S = 25;          $RPS_PI_L =  1;
	$RPS_PC_S = 26;          $RPS_PC_L =  2;
	$RPS_SC_S = 28;          $RPS_SC_L =  4;
	$RPS_PD_S = 32;          $RPS_PD_L =  4;
	$RPS_SD_S = 36;          $RPS_SD_L =  4;
	$RPS_UT_S = 40;          $RPS_UT_L =  2;
	$RPS_WD_S = 42;          $RPS_WD_L =  4;
	$RPS_X_S = 46;          $RPS_X_L =  9;
	$RPS_Y_S = 55;          $RPS_Y_L = 10;
	$RPS_Z_S = 65;          $RPS_Z_L =  6;
	$RPS_DY_S = 71;          $RPS_DY_L =  3;
	$RPS_TM_S = 74;          $RPS_TM_L =  6;
	
	#  SOURCE
	$SPS_ID_S =  0;          $SPS_ID_L =  1;
	$SPS_LN_S =  1;          $SPS_LN_L = 16;
	$SPS_PN_S = 17;          $SPS_PN_L =  8;
	$SPS_PI_S = 25;          $SPS_PI_L =  1;
	$SPS_PC_S = 26;          $SPS_PC_L =  2;
	$SPS_SC_S = 28;          $SPS_SC_L =  4;
	$SPS_PD_S = 32;          $SPS_PD_L =  4;
	$SPS_SD_S = 36;          $SPS_SD_L =  4;
	$SPS_UT_S = 40;          $SPS_UT_L =  2;
	$SPS_WD_S = 42;          $SPS_WD_L =  4;
	$SPS_X_S = 46;          $SPS_X_L =  9;
	$SPS_Y_S = 55;          $SPS_Y_L = 10;
	$SPS_Z_S = 65;          $SPS_Z_L =  6;
	$SPS_DY_S = 71;          $SPS_DY_L =  3;
	$SPS_TM_S = 74;          $SPS_TM_L =  6;

	#  RELATIONAL
	$XPS_ID_S =  0;          $XPS_ID_L =  1;
	$XPS_TP_S =  1;          $XPS_TP_L =  6;
	$XPS_RN_S =  7;          $XPS_RN_L =  4;
	$XPS_RI_S = 11;          $XPS_RI_L =  1;
	$XPS_IC_S = 12;          $XPS_IC_L =  1;
	$XPS_LN_S = 13;          $XPS_LN_L = 16;
	$XPS_PN_S = 29;          $XPS_PN_L =  8;
	$XPS_PI_S = 37;          $XPS_PI_L =  1;
	$XPS_FC_S = 38;          $XPS_FC_L =  4;
	$XPS_TC_S = 42;          $XPS_TC_L =  4;
	$XPS_CI_S = 46;          $XPS_CI_L =  1;
	$XPS_RL_S = 47;          $XPS_RL_L = 16;
	$XPS_FR_S = 63;          $XPS_FR_L =  8;
	$XPS_TR_S = 71;          $XPS_TR_L =  8;
	$XPS_RX_S = 79;          $XPS_RX_L =  1;
	
	Title( XSPST_LC::LC('NEW TEMPLATE') );	
	TemplateCalc1();
	TemplateCheck();
}

sub TemplateOpen 
{ 
	my @types = ([XSPST_LC::LC('sps template files'), '*.tpl'] );
	my $old_file_template ='';
	
	if( $FILE_TEMPLATE ) { $old_file_template = $FILE_TEMPLATE; }
  	$FILE_TEMPLATE = $MW->getOpenFile(-filetypes=>\@types, -title=>XSPST_LC::LC('Open Template File'));
  	if( !$FILE_TEMPLATE ) 
  	{ 
  		if( $old_file_template ) { $FILE_TEMPLATE = $old_file_template; } 
  	}
  	else
  	{
  	  	do $FILE_TEMPLATE;
  	  	TemplateCalc1();
  	  	$FILE_TEMPLATE_IS_DIRTY = 0;
  	  	RPSRefresh();
  	  	SPSRefresh();
  	  	XPSRefresh();  	  	
  	  	Title( $FILE_TEMPLATE );
  	  	TemplateCheck();
  	  	$FILE_TEMPLATE_NEW == 0
  	  }
}

sub TemplateSave
{
	if( $FILE_TEMPLATE )
	{
		if( $FILE_TEMPLATE_NEW == 0 ) 
		{ # zapisac
			TemplateCalc2();
			open( OUT, ">", $FILE_TEMPLATE );
			print OUT "#################################################\n";
			print OUT "# $PRG_NAME ver. $PRG_VER, $PRG_DATE\n";
			print OUT "# Template saved: ".`date`;
			print OUT "#################################################\n";			

			print OUT "\n#  RECEIVER\n";
			printf OUT "\$RPS_ID_S = %2d;          ", $RPS_ID_S;
			printf OUT "\$RPS_ID_L = %2d;\n", $RPS_ID_L;
			printf OUT "\$RPS_LN_S = %2d;          ", $RPS_LN_S;
			printf OUT "\$RPS_LN_L = %2d;\n", $RPS_LN_L;
			printf OUT "\$RPS_PN_S = %2d;          ", $RPS_PN_S;
			printf OUT "\$RPS_PN_L = %2d;\n", $RPS_PN_L;
			printf OUT "\$RPS_PI_S = %2d;          ", $RPS_PI_S;
			printf OUT "\$RPS_PI_L = %2d;\n", $RPS_PI_L;
			printf OUT "\$RPS_PC_S = %2d;          ", $RPS_PC_S;
			printf OUT "\$RPS_PC_L = %2d;\n", $RPS_PC_L;
			printf OUT "\$RPS_SC_S = %2d;          ", $RPS_SC_S;
			printf OUT "\$RPS_SC_L = %2d;\n", $RPS_SC_L;
			printf OUT "\$RPS_PD_S = %2d;          ", $RPS_PD_S;
			printf OUT "\$RPS_PD_L = %2d;\n", $RPS_PD_L;
			printf OUT "\$RPS_SD_S = %2d;          ", $RPS_SD_S;
			printf OUT "\$RPS_SD_L = %2d;\n", $RPS_SD_L;
			printf OUT "\$RPS_UT_S = %2d;          ", $RPS_UT_S;
			printf OUT "\$RPS_UT_L = %2d;\n", $RPS_UT_L;
			printf OUT "\$RPS_WD_S = %2d;          ", $RPS_WD_S;
			printf OUT "\$RPS_WD_L = %2d;\n", $RPS_WD_L;
			printf OUT "\$RPS_X_S  = %2d;          ", $RPS_X_S;
			printf OUT "\$RPS_X_L  = %2d;\n", $RPS_X_L;
			printf OUT "\$RPS_Y_S  = %2d;          ", $RPS_Y_S;
			printf OUT "\$RPS_Y_L  = %2d;\n", $RPS_Y_L;
			printf OUT "\$RPS_Z_S  = %2d;          ", $RPS_Z_S;
			printf OUT "\$RPS_Z_L  = %2d;\n", $RPS_Z_L;
			printf OUT "\$RPS_DY_S = %2d;          ", $RPS_DY_S;
			printf OUT "\$RPS_DY_L = %2d;\n", $RPS_DY_L;
			printf OUT "\$RPS_TM_S = %2d;          ", $RPS_TM_S;
			printf OUT "\$RPS_TM_L = %2d;\n", $RPS_TM_L;

			print OUT "\n#  SOURCE\n";
			printf OUT "\$SPS_ID_S = %2d;          ", $SPS_ID_S;
			printf OUT "\$SPS_ID_L = %2d;\n", $SPS_ID_L;
			printf OUT "\$SPS_LN_S = %2d;          ", $SPS_LN_S;
			printf OUT "\$SPS_LN_L = %2d;\n", $SPS_LN_L;
			printf OUT "\$SPS_PN_S = %2d;          ", $SPS_PN_S;
			printf OUT "\$SPS_PN_L = %2d;\n", $SPS_PN_L;
			printf OUT "\$SPS_PI_S = %2d;          ", $SPS_PI_S;
			printf OUT "\$SPS_PI_L = %2d;\n", $SPS_PI_L;
			printf OUT "\$SPS_PC_S = %2d;          ", $SPS_PC_S;
			printf OUT "\$SPS_PC_L = %2d;\n", $SPS_PC_L;
			printf OUT "\$SPS_SC_S = %2d;          ", $SPS_SC_S;
			printf OUT "\$SPS_SC_L = %2d;\n", $SPS_SC_L;
			printf OUT "\$SPS_PD_S = %2d;          ", $SPS_PD_S;
			printf OUT "\$SPS_PD_L = %2d;\n", $SPS_PD_L;
			printf OUT "\$SPS_SD_S = %2d;          ", $SPS_SD_S;
			printf OUT "\$SPS_SD_L = %2d;\n", $SPS_SD_L;
			printf OUT "\$SPS_UT_S = %2d;          ", $SPS_UT_S;
			printf OUT "\$SPS_UT_L = %2d;\n", $SPS_UT_L;
			printf OUT "\$SPS_WD_S = %2d;          ", $SPS_WD_S;
			printf OUT "\$SPS_WD_L = %2d;\n", $SPS_WD_L;
			printf OUT "\$SPS_X_S  = %2d;          ", $SPS_X_S;
			printf OUT "\$SPS_X_L  = %2d;\n", $SPS_X_L;
			printf OUT "\$SPS_Y_S  = %2d;          ", $SPS_Y_S;
			printf OUT "\$SPS_Y_L  = %2d;\n", $SPS_Y_L;
			printf OUT "\$SPS_Z_S  = %2d;          ", $SPS_Z_S;
			printf OUT "\$SPS_Z_L  = %2d;\n", $SPS_Z_L;
			printf OUT "\$SPS_DY_S = %2d;          ", $SPS_DY_S;
			printf OUT "\$SPS_DY_L = %2d;\n", $SPS_DY_L;
			printf OUT "\$SPS_TM_S = %2d;          ", $SPS_TM_S;
			printf OUT "\$SPS_TM_L = %2d;\n", $SPS_TM_L;

			print OUT "\n#  RELATIONAL\n";
			printf OUT "\$XPS_ID_S = %2d;          ", $XPS_ID_S;
			printf OUT "\$XPS_ID_L = %2d;\n", $XPS_ID_L;
			printf OUT "\$XPS_TP_S = %2d;          ", $XPS_TP_S;
			printf OUT "\$XPS_TP_L = %2d;\n", $XPS_TP_L;
			printf OUT "\$XPS_RN_S = %2d;          ", $XPS_RN_S;
			printf OUT "\$XPS_RN_L = %2d;\n", $XPS_RN_L;
			printf OUT "\$XPS_RI_S = %2d;          ", $XPS_RI_S;
			printf OUT "\$XPS_RI_L = %2d;\n", $XPS_RI_L;
			printf OUT "\$XPS_IC_S = %2d;          ", $XPS_IC_S;
			printf OUT "\$XPS_IC_L = %2d;\n", $XPS_IC_L;
			printf OUT "\$XPS_LN_S = %2d;          ", $XPS_LN_S;
			printf OUT "\$XPS_LN_L = %2d;\n", $XPS_LN_L;
			printf OUT "\$XPS_PN_S = %2d;          ", $XPS_PN_S;
			printf OUT "\$XPS_PN_L = %2d;\n", $XPS_PN_L;
			printf OUT "\$XPS_PI_S = %2d;          ", $XPS_PI_S;
			printf OUT "\$XPS_PI_L = %2d;\n", $XPS_PI_L;
			printf OUT "\$XPS_FC_S = %2d;          ", $XPS_FC_S;
			printf OUT "\$XPS_FC_L = %2d;\n", $XPS_FC_L;
			printf OUT "\$XPS_TC_S = %2d;          ", $XPS_TC_S;
			printf OUT "\$XPS_TC_L = %2d;\n", $XPS_TC_L;
			printf OUT "\$XPS_CI_S = %2d;          ", $XPS_CI_S;
			printf OUT "\$XPS_CI_L = %2d;\n", $XPS_CI_L;
			printf OUT "\$XPS_RL_S = %2d;          ", $XPS_RL_S;
			printf OUT "\$XPS_RL_L = %2d;\n", $XPS_RL_L;
			printf OUT "\$XPS_FR_S = %2d;          ", $XPS_FR_S;
			printf OUT "\$XPS_FR_L = %2d;\n", $XPS_FR_L;
			printf OUT "\$XPS_TR_S = %2d;          ", $XPS_TR_S;
			printf OUT "\$XPS_TR_L = %2d;\n", $XPS_TR_L;
			printf OUT "\$XPS_RX_S = %2d;          ", $XPS_RX_S;
			printf OUT "\$XPS_RX_L = %2d;\n", $XPS_RX_L;
	
			close( OUT );
		}
		else { TemplateSaveAs(); }
	}
	else
	{
		if( $FILE_TEMPLATE_NEW ) { TemplateSaveAs(); }
		#else {  } #WhatTheFuck();
	}
	TemplateCheck();
	RPSRefresh();
	SPSRefresh();
	XPSRefresh();
}

sub TemplateSaveAs
{
	my @types = ([XSPST_LC::LC('sps template files'), '*.tpl'] );
	my $old_file_template ='';
	if( $FILE_TEMPLATE ) { $old_file_template = $FILE_TEMPLATE; }
	
	$FILE_TEMPLATE = $MW->getSaveFile(-filetypes=>\@types, -title=>XSPST_LC::LC('Save Template File As'));		
  	if( !$FILE_TEMPLATE ) 
  	{ 
  		if( $old_file_template ) { $FILE_TEMPLATE = $old_file_template; } 
  	}
  	else
  	{
  	# dolozenie rozszerzenia
		my $l = length( $FILE_TEMPLATE );
  		my $ext = substr( $FILE_TEMPLATE, $l - 4, 4 );
  		if( $ext ne '.tpl' ) { $FILE_TEMPLATE .= '.tpl'; }		
  		if( $FILE_TEMPLATE_NEW == 1 ) { $FILE_TEMPLATE_NEW = 0; }
  		TemplateSave();
  	}
  	Title( $FILE_TEMPLATE ); 
  	TemplateCheck();
}

# przelicznie z (C,L) do (C1,C2)
sub TemplateCalc1
{
	$RPS_ID_C1 = $RPS_ID_S + 1;	$RPS_ID_C2 = $RPS_ID_S + $RPS_ID_L;
	$RPS_LN_C1 = $RPS_LN_S + 1;	$RPS_LN_C2 = $RPS_LN_S + $RPS_LN_L;
	$RPS_PN_C1 = $RPS_PN_S + 1;	$RPS_PN_C2 = $RPS_PN_S + $RPS_PN_L;		
	$RPS_PI_C1 = $RPS_PI_S + 1;	$RPS_PI_C2 = $RPS_PI_S + $RPS_PI_L;
	$RPS_PC_C1 = $RPS_PC_S + 1;	$RPS_PC_C2 = $RPS_PC_S + $RPS_PC_L;
	$RPS_SC_C1 = $RPS_SC_S + 1;	$RPS_SC_C2 = $RPS_SC_S + $RPS_SC_L;
	$RPS_SD_C1 = $RPS_SD_S + 1;	$RPS_SD_C2 = $RPS_SD_S + $RPS_SD_L;	
	$RPS_PD_C1 = $RPS_PD_S + 1;	$RPS_PD_C2 = $RPS_PD_S + $RPS_PD_L;
	$RPS_UT_C1 = $RPS_UT_S + 1;	$RPS_UT_C2 = $RPS_UT_S + $RPS_UT_L;
	$RPS_WD_C1 = $RPS_WD_S + 1;	$RPS_WD_C2 = $RPS_WD_S + $RPS_WD_L;	
	$RPS_X_C1 = $RPS_X_S + 1;	$RPS_X_C2 = $RPS_X_S + $RPS_X_L;
	$RPS_Y_C1 = $RPS_Y_S + 1;	$RPS_Y_C2 = $RPS_Y_S + $RPS_Y_L;
	$RPS_Z_C1 = $RPS_Z_S + 1;	$RPS_Z_C2 = $RPS_Z_S + $RPS_Z_L;	
	$RPS_DY_C1 = $RPS_DY_S + 1;	$RPS_DY_C2 = $RPS_DY_S + $RPS_DY_L;
	$RPS_TM_C1 = $RPS_TM_S + 1;	$RPS_TM_C2 = $RPS_TM_S + $RPS_TM_L;

	$SPS_ID_C1 = $SPS_ID_S + 1;	$SPS_ID_C2 = $SPS_ID_S + $SPS_ID_L;
	$SPS_LN_C1 = $SPS_LN_S + 1;	$SPS_LN_C2 = $SPS_LN_S + $SPS_LN_L;
	$SPS_PN_C1 = $SPS_PN_S + 1;	$SPS_PN_C2 = $SPS_PN_S + $SPS_PN_L;		
	$SPS_PI_C1 = $SPS_PI_S + 1;	$SPS_PI_C2 = $SPS_PI_S + $SPS_PI_L;
	$SPS_PC_C1 = $SPS_PC_S + 1;	$SPS_PC_C2 = $SPS_PC_S + $SPS_PC_L;
	$SPS_SC_C1 = $SPS_SC_S + 1;	$SPS_SC_C2 = $SPS_SC_S + $SPS_SC_L;
	$SPS_SD_C1 = $SPS_SD_S + 1;	$SPS_SD_C2 = $SPS_SD_S + $SPS_SD_L;	
	$SPS_PD_C1 = $SPS_PD_S + 1;	$SPS_PD_C2 = $SPS_PD_S + $SPS_PD_L;
	$SPS_UT_C1 = $SPS_UT_S + 1;	$SPS_UT_C2 = $SPS_UT_S + $SPS_UT_L;
	$SPS_WD_C1 = $SPS_WD_S + 1;	$SPS_WD_C2 = $SPS_WD_S + $SPS_WD_L;	
	$SPS_X_C1 = $SPS_X_S + 1;	$SPS_X_C2 = $SPS_X_S + $SPS_X_L;
	$SPS_Y_C1 = $SPS_Y_S + 1;	$SPS_Y_C2 = $SPS_Y_S + $SPS_Y_L;
	$SPS_Z_C1 = $SPS_Z_S + 1;	$SPS_Z_C2 = $SPS_Z_S + $SPS_Z_L;	
	$SPS_DY_C1 = $SPS_DY_S + 1;	$SPS_DY_C2 = $SPS_DY_S + $SPS_DY_L;
	$SPS_TM_C1 = $SPS_TM_S + 1;	$SPS_TM_C2 = $SPS_TM_S + $SPS_TM_L;
	
	$XPS_ID_C1 = $XPS_ID_S + 1;     $XPS_ID_C2 = $XPS_ID_S + $XPS_ID_L;
	$XPS_TP_C1 = $XPS_TP_S + 1;     $XPS_TP_C2 = $XPS_TP_S + $XPS_TP_L;
	$XPS_RN_C1 = $XPS_RN_S + 1;     $XPS_RN_C2 = $XPS_RN_S + $XPS_RN_L;
	$XPS_RI_C1 = $XPS_RI_S + 1;     $XPS_RI_C2 = $XPS_RI_S + $XPS_RI_L;
	$XPS_IC_C1 = $XPS_IC_S + 1;     $XPS_IC_C2 = $XPS_IC_S + $XPS_IC_L;
	$XPS_LN_C1 = $XPS_LN_S + 1;     $XPS_LN_C2 = $XPS_LN_S + $XPS_LN_L;
	$XPS_PN_C1 = $XPS_PN_S + 1;     $XPS_PN_C2 = $XPS_PN_S + $XPS_PN_L;
	$XPS_PI_C1 = $XPS_PI_S + 1;     $XPS_PI_C2 = $XPS_PI_S + $XPS_PI_L;
	$XPS_FC_C1 = $XPS_FC_S + 1;     $XPS_FC_C2 = $XPS_FC_S + $XPS_FC_L;
	$XPS_TC_C1 = $XPS_TC_S + 1;     $XPS_TC_C2 = $XPS_TC_S + $XPS_TC_L;
	$XPS_CI_C1 = $XPS_CI_S + 1;     $XPS_CI_C2 = $XPS_CI_S + $XPS_CI_L;
	$XPS_RL_C1 = $XPS_RL_S + 1;     $XPS_RL_C2 = $XPS_RL_S + $XPS_RL_L;
	$XPS_FR_C1 = $XPS_FR_S + 1;     $XPS_FR_C2 = $XPS_FR_S + $XPS_FR_L;
	$XPS_TR_C1 = $XPS_TR_S + 1;     $XPS_TR_C2 = $XPS_TR_S + $XPS_TR_L;
	$XPS_RX_C1 = $XPS_RX_S + 1;     $XPS_RX_C2 = $XPS_RX_S + $XPS_RX_L;
}                             
                              
# przelicznie z (C1,C2) do (C,L)
sub TemplateCalc2             
{                             
	TemplateValidate();
	
	$RPS_ID_S = $RPS_ID_C1 - 1;	$RPS_ID_L = $RPS_ID_C2 - $RPS_ID_S;
	$RPS_LN_S = $RPS_LN_C1 - 1;	$RPS_LN_L = $RPS_LN_C2 - $RPS_LN_S;
	$RPS_PN_S = $RPS_PN_C1 - 1;	$RPS_PN_L = $RPS_PN_C2 - $RPS_PN_S;
	$RPS_PI_S = $RPS_PI_C1 - 1;	$RPS_PI_L = $RPS_PI_C2 - $RPS_PI_S;
	$RPS_PC_S = $RPS_PC_C1 - 1;	$RPS_PC_L = $RPS_PC_C2 - $RPS_PC_S;
	$RPS_SC_S = $RPS_SC_C1 - 1;	$RPS_SC_L = $RPS_SC_C2 - $RPS_SC_S;	
	$RPS_SD_S = $RPS_SD_C1 - 1;	$RPS_SD_L = $RPS_SD_C2 - $RPS_SD_S;		
	$RPS_PD_S = $RPS_PD_C1 - 1;	$RPS_PD_L = $RPS_PD_C2 - $RPS_PD_S;
	$RPS_UT_S = $RPS_UT_C1 - 1;	$RPS_UT_L = $RPS_UT_C2 - $RPS_UT_S;
	$RPS_WD_S = $RPS_WD_C1 - 1;	$RPS_WD_L = $RPS_WD_C2 - $RPS_WD_S;
	$RPS_X_S = $RPS_X_C1 - 1;	$RPS_X_L = $RPS_X_C2 - $RPS_X_S;
	$RPS_Y_S = $RPS_Y_C1 - 1;	$RPS_Y_L = $RPS_Y_C2 - $RPS_Y_S;
	$RPS_Z_S = $RPS_Z_C1 - 1;	$RPS_Z_L = $RPS_Z_C2 - $RPS_Z_S;
	$RPS_DY_S = $RPS_DY_C1 - 1;	$RPS_DY_L = $RPS_DY_C2 - $RPS_DY_S;
	$RPS_TM_S = $RPS_TM_C1 - 1;	$RPS_TM_L = $RPS_TM_C2 - $RPS_TM_S;
	                      
	$SPS_ID_S = $SPS_ID_C1 - 1;	$SPS_ID_L = $SPS_ID_C2 - $SPS_ID_S;
	$SPS_LN_S = $SPS_LN_C1 - 1;	$SPS_LN_L = $SPS_LN_C2 - $SPS_LN_S;
	$SPS_PN_S = $SPS_PN_C1 - 1;	$SPS_PN_L = $SPS_PN_C2 - $SPS_PN_S;
	$SPS_PI_S = $SPS_PI_C1 - 1;	$SPS_PI_L = $SPS_PI_C2 - $SPS_PI_S;
	$SPS_PC_S = $SPS_PC_C1 - 1;	$SPS_PC_L = $SPS_PC_C2 - $SPS_PC_S;
	$SPS_SC_S = $SPS_SC_C1 - 1;	$SPS_SC_L = $SPS_SC_C2 - $SPS_SC_S;	
	$SPS_SD_S = $SPS_SD_C1 - 1;	$SPS_SD_L = $SPS_SD_C2 - $SPS_SD_S;		
	$SPS_PD_S = $SPS_PD_C1 - 1;	$SPS_PD_L = $SPS_PD_C2 - $SPS_PD_S;
	$SPS_UT_S = $SPS_UT_C1 - 1;	$SPS_UT_L = $SPS_UT_C2 - $SPS_UT_S;
	$SPS_WD_S = $SPS_WD_C1 - 1;	$SPS_WD_L = $SPS_WD_C2 - $SPS_WD_S;
	$SPS_X_S = $SPS_X_C1 - 1;	$SPS_X_L = $SPS_X_C2 - $SPS_X_S;
	$SPS_Y_S = $SPS_Y_C1 - 1;	$SPS_Y_L = $SPS_Y_C2 - $SPS_Y_S;
	$SPS_Z_S = $SPS_Z_C1 - 1;	$SPS_Z_L = $SPS_Z_C2 - $SPS_Z_S;
	$SPS_DY_S = $SPS_DY_C1 - 1;	$SPS_DY_L = $SPS_DY_C2 - $SPS_DY_S;
	$SPS_TM_S = $SPS_TM_C1 - 1;	$SPS_TM_L = $SPS_TM_C2 - $SPS_TM_S;	

	$XPS_ID_S = $XPS_ID_C1 - 1;     $XPS_ID_L = $XPS_ID_C2 - $XPS_ID_S;
	$XPS_TP_S = $XPS_TP_C1 - 1;     $XPS_TP_L = $XPS_TP_C2 - $XPS_TP_S;
	$XPS_RN_S = $XPS_RN_C1 - 1;     $XPS_RN_L = $XPS_RN_C2 - $XPS_RN_S;
	$XPS_RI_S = $XPS_RI_C1 - 1;     $XPS_RI_L = $XPS_RI_C2 - $XPS_RI_S;
	$XPS_IC_S = $XPS_IC_C1 - 1;     $XPS_IC_L = $XPS_IC_C2 - $XPS_IC_S;
	$XPS_LN_S = $XPS_LN_C1 - 1;     $XPS_LN_L = $XPS_LN_C2 - $XPS_LN_S;
	$XPS_PN_S = $XPS_PN_C1 - 1;     $XPS_PN_L = $XPS_PN_C2 - $XPS_PN_S;
	$XPS_PI_S = $XPS_PI_C1 - 1;     $XPS_PI_L = $XPS_PI_C2 - $XPS_PI_S;
	$XPS_FC_S = $XPS_FC_C1 - 1;     $XPS_FC_L = $XPS_FC_C2 - $XPS_FC_S;
	$XPS_TC_S = $XPS_TC_C1 - 1;     $XPS_TC_L = $XPS_TC_C2 - $XPS_TC_S;
	$XPS_CI_S = $XPS_CI_C1 - 1;     $XPS_CI_L = $XPS_CI_C2 - $XPS_CI_S;
	$XPS_RL_S = $XPS_RL_C1 - 1;     $XPS_RL_L = $XPS_RL_C2 - $XPS_RL_S;
	$XPS_FR_S = $XPS_FR_C1 - 1;     $XPS_FR_L = $XPS_FR_C2 - $XPS_FR_S;
	$XPS_TR_S = $XPS_TR_C1 - 1;     $XPS_TR_L = $XPS_TR_C2 - $XPS_TR_S;
	$XPS_RX_S = $XPS_RX_C1 - 1;     $XPS_RX_L = $XPS_RX_C2 - $XPS_RX_S;
}                             
                                                            
sub RPSOpen                   
{                             
	my @types =           
	([XSPST_LC::LC('sps receiver files'), '*.rps *.rp *.r *.RPS *.R'],
	 [XSPST_LC::LC('all files'), '*.*']);
	my $old_file_rps =''; 
                              
	StatusClear( $rps_stat );
	                      
	if( $FILE_RPS ) { $old_file_rps = $FILE_RPS; }
  	$FILE_RPS = $MW->getOpenFile(-filetypes=>\@types, -title=>XSPST_LC::LC('Open RPS file'));
  	if( $FILE_RPS ) { $CHECK_RPS = 1; }
	else{ if( $old_file_rps ) { $FILE_RPS = $old_file_rps; } }
                              
	open( RPS, $FILE_RPS );
                              
	$RPSBUF[0] = $LINE0;  
	$RPSBUF[1] = $LINE1;  
	my $count = 2;        
	my $line;             
	while( ($line = <RPS>) && $count < $NOFLINES + 2 )
	{                     
		$h = substr( $line, 0, 1 );	
		if( $h ne 'H' )
		{             
			$RPSBUF[$count] = $line;
			$count++;
		}             
	}                     
	close( RPS );         
	$RPS_VAR = 'ID';
	RPSRefresh();         
}                             
                              
sub RPSRefresh                
{                             
	StatusClear( $rps_stat );
	                      
	if( $FILE_TEMPLATE && $RPS_VAR )
	{                     
		TemplateCalc2();
		# kolorwanie SPSu
		my $buf1, $buf2, $buf3, $len, $len1, $len2, $len3;
		my $count = 0;
		while( $RPSBUF[$count] )
		{             
			$len = length( $RPSBUF[$count] );
			$len1 = ${RPS_.${RPS_VAR}._S};
			$buf1 = substr( $RPSBUF[$count], 0, $len1 );
			$buf2 = substr( $RPSBUF[$count], ${RPS_.${RPS_VAR}._S}, ${RPS_.${RPS_VAR}._L} );
			$buf2 =~ s/ /_/g;
			$len3 = ${RPS_.${RPS_VAR}._S} + ${RPS_.${RPS_VAR}._L};
			$buf3 = substr( $RPSBUF[$count], $len3 , $len - $len3 );
                              
			StatusWrite( $rps_stat, $buf1 );
			if( $count < 2 ) { StatusWrite( $rps_stat, colored( $buf2, $LINE_COLOR ) ); }
			else{ StatusWrite( $rps_stat, colored( $buf2, $RPS_COLOR ) ); }
			StatusWrite( $rps_stat, $buf3 );
			$count++;
		}
	}                     
	else                  
	{
		if( $FILE_RPS && !$FILE_TEMPLATE ) { StatusWrite( $rps_stat, "SAVE TEMPLATE FIRST" ); }
	}                     
}                             
                                                            
sub SPSOpen                   
{                             
	my @types =           
	([XSPST_LC::LC('sps source files'), '*.sps *.sp *.s *.SPS *.S'],
	 [XSPST_LC::LC('all files'), '*.*']);
	my $old_file_sps =''; 
                              
	StatusClear( $sps_stat );
	                      
	if( $FILE_SPS ) { $old_file_sps = $FILE_SPS; }
  	$FILE_SPS = $MW->getOpenFile(-filetypes=>\@types, -title=>XSPST_LC::LC('Open SPS file'));
  	if( $FILE_SPS ) { $CHECK_SPS = 1; }
	else{ if( $old_file_sps ) { $FILE_SPS = $old_file_sps; } }
                              
	open( SPS, $FILE_SPS );
                              
	$SPSBUF[0] = $LINE0;  
	$SPSBUF[1] = $LINE1;  
	my $count = 2;        
	my $line;             
	while( ($line = <SPS>) && $count < $NOFLINES + 2 )
	{                     
		$h = substr( $line, 0, 1 );	
		if( $h ne 'H' )
		{             
			$SPSBUF[$count] = $line;
			$count++;
		}             
	}                     
	close( SPS );         
	$SPS_VAR = 'ID';
	SPSRefresh();         
}                             
                              
sub SPSRefresh                
{                             
	StatusClear( $sps_stat );
	                      
	if( $FILE_TEMPLATE && $SPS_VAR )
	{                     
		TemplateCalc2();
		# kolorwanie SPSu
		my $buf1, $buf2, $buf3, $len, $len1, $len2, $len3;
		my $count = 0;
		while( $SPSBUF[$count] )
		{             
			$len = length( $SPSBUF[$count] );
			$len1 = ${SPS_.${SPS_VAR}._S};
			$buf1 = substr( $SPSBUF[$count], 0, $len1 );
			$buf2 = substr( $SPSBUF[$count], ${SPS_.${SPS_VAR}._S}, ${SPS_.${SPS_VAR}._L} );
			$buf2 =~ s/ /_/g;
			$len3 = ${SPS_.${SPS_VAR}._S} + ${SPS_.${SPS_VAR}._L};
			$buf3 = substr( $SPSBUF[$count], $len3 , $len - $len3 );
                              
			StatusWrite( $sps_stat, $buf1 );
			if( $count < 2 ) { StatusWrite( $sps_stat, colored( $buf2, $LINE_COLOR ) ); }
			else{ StatusWrite( $sps_stat, colored( $buf2, $SPS_COLOR ) ); }
			StatusWrite( $sps_stat, $buf3 );
			$count++;
		}		1;
                              
	}                     
	else                  
	{                     
		if( $FILE_SPS && !$FILE_TEMPLATE ) { StatusWrite( $sps_stat, "SAVE TEMPLATE FIRST" ); }
	}                     
}                             
                              
sub XPSOpen                   
{                             
	my @types =           
	([XSPST_LC::LC('xps relational files'), '*.xps *.x* *.XPS *.X'],
	 [XSPST_LC::LC('all files'), '*.*']);
	my $old_file_xps =''; 
                              
	StatusClear( $xps_stat );
	                      
	if( $FILE_XPS ) { $old_file_xps = $FILE_XPS; }
  	$FILE_XPS = $MW->getOpenFile(-filetypes=>\@types, -title=>XSPST_LC::LC('Open XPS file'));
  	if( $FILE_XPS ) { $CHECK_XPS = 1; }
	else{ if( $old_file_xps ) { $FILE_XPS = $old_file_xps; } }
                              
	open( XPS, $FILE_XPS );
                              
	$XPSBUF[0] = $LINE0;  
	$XPSBUF[1] = $LINE1;  
	my $count = 2;        
	my $line;             
	while( ($line = <XPS>) && $count < $NOFLINES + 2 )
	{                     
		$h = substr( $line, 0, 1 );	
		if( $h ne 'H' )
		{             
			$XPSBUF[$count] = $line;
			$count++;
		}             
	}                     
	close( XPS );         
	$XPS_VAR = 'ID';	
	XPSRefresh();         
}                             
                              
sub XPSRefresh                
{                             
	StatusClear( $xps_stat );
	                      
	if( $FILE_TEMPLATE && $XPS_VAR )
	{                     
		TemplateCalc2();
		# kolorwanie XPSu
		my $buf1, $buf2, $buf3, $len, $len1, $len2, $len3;
		my $count = 0;
		while( $XPSBUF[$count] )
		{             
			$len = length( $XPSBUF[$count] );
			$len1 = ${XPS_.${XPS_VAR}._S};
			$buf1 = substr( $XPSBUF[$count], 0, $len1 );
			$buf2 = substr( $XPSBUF[$count], ${XPS_.${XPS_VAR}._S}, ${XPS_.${XPS_VAR}._L} );
			$buf2 =~ s/ /_/g;
			$len3 = ${XPS_.${XPS_VAR}._S} + ${XPS_.${XPS_VAR}._L};
			$buf3 = substr( $XPSBUF[$count], $len3 , $len - $len3 );
                              
			StatusWrite( $xps_stat, $buf1 );
			if( $count < 2 ) { StatusWrite( $xps_stat, colored( $buf2, $LINE_COLOR ) ); }
			else{ StatusWrite( $xps_stat, colored( $buf2, $XPS_COLOR ) ); }
			StatusWrite( $xps_stat, $buf3 );
			$count++;
		}		1;
                              
	}                     
	else                  
	{                     
		if( $FILE_XPS && !$FILE_TEMPLATE ) { StatusWrite( $xps_stat, "SAVE TEMPLATE FIRST" ); }
	}                     
}                             
                              
sub StatusClear               
{                             
	$_[0]->delete( "0.0", "end" );
}                             
                              
sub TemplateCheck
{
	if( $FILE_TEMPLATE_NEW || $FILE_TEMPLATE ) 
	{ 
		$FILE_MENU_TEMPLATE_SAVE->configure( -state=>'normal' );
		$FILE_MENU_TEMPLATE_SAVEAS->configure( -state=>'normal' );
		$BUTTON_TEMPLATE_SAVE->configure( -state=>'normal' );
		$BUTTON_TEMPLATE_SAVEAS->configure( -state=>'normal' );
	} 	
	else 
	{ 
		$FILE_MENU_TEMPLATE_SAVE->configure( -state=>'disabled' ); 
		$FILE_MENU_TEMPLATE_SAVEAS->configure( -state=>'disabled' ); 
		$BUTTON_TEMPLATE_SAVE->configure( -state=>'disabled' ); 
		$BUTTON_TEMPLATE_SAVEAS->configure( -state=>'disabled' ); 
	}
}

sub TemplateValidate
{
	# RPS
	if( $RPS_ID_C1 == 0 ) { $RPS_ID_C1 = 1; } 
	if( $RPS_LN_C1 == 0 ) { $RPS_LN_C1 = 1; } 
	if( $RPS_PN_C1 == 0 ) { $RPS_PN_C1 = 1; } 
	if( $RPS_PI_C1 == 0 ) { $RPS_PI_C1 = 1; } 
	if( $RPS_PC_C1 == 0 ) { $RPS_PC_C1 = 1; } 
	if( $RPS_SC_C1 == 0 ) { $RPS_SC_C1 = 1; } 
	if( $RPS_PD_C1 == 0 ) { $RPS_PD_C1 = 1; } 
	if( $RPS_SD_C1 == 0 ) { $RPS_SD_C1 = 1; } 
	if( $RPS_UT_C1 == 0 ) { $RPS_UT_C1 = 1; } 			
	if( $RPS_WD_C1 == 0 ) { $RPS_WD_C1 = 1; } 
	if( $RPS_X_C1 == 0 ) { $RPS_X_C1 = 1; } 
	if( $RPS_Y_C1 == 0 ) { $RPS_Y_C1 = 1; } 
	if( $RPS_Z_C1 == 0 ) { $RPS_Z_C1 = 1; } 
	if( $RPS_DY_C1 == 0 ) { $RPS_DY_C1 = 1; } 
	if( $RPS_TM_C1 == 0 ) { $RPS_TM_C1 = 1; } 

	if( $RPS_ID_C2 < $RPS_ID_C1 || $RPS_ID_C2 == 0 ) { $RPS_ID_C2 = $RPS_ID_C1; } 
	if( $RPS_LN_C2 < $RPS_LN_C1 || $RPS_LN_C2 == 0 ) { $RPS_LN_C2 = $RPS_LN_C1; } 
	if( $RPS_PN_C2 < $RPS_PN_C1 || $RPS_PN_C2 == 0 ) { $RPS_PN_C2 = $RPS_PN_C1; } 
	if( $RPS_PI_C2 < $RPS_PI_C1 || $RPS_PI_C2 == 0 ) { $RPS_PI_C2 = $RPS_PI_C1; } 
	if( $RPS_PC_C2 < $RPS_PC_C1 || $RPS_PC_C2 == 0 ) { $RPS_PC_C2 = $RPS_PC_C1; } 
	if( $RPS_SC_C2 < $RPS_SC_C1 || $RPS_SC_C2 == 0 ) { $RPS_SC_C2 = $RPS_SC_C1; } 
	if( $RPS_PD_C2 < $RPS_PD_C1 || $RPS_PD_C2 == 0 ) { $RPS_PD_C2 = $RPS_PD_C1; } 
	if( $RPS_SD_C2 < $RPS_SD_C1 || $RPS_SD_C2 == 0 ) { $RPS_SD_C2 = $RPS_SD_C1; } 
	if( $RPS_UT_C2 < $RPS_UT_C1 || $RPS_UT_C2 == 0 ) { $RPS_UT_C2 = $RPS_UT_C1; } 
	if( $RPS_WD_C2 < $RPS_WD_C1 || $RPS_WD_C2 == 0 ) { $RPS_WD_C2 = $RPS_WD_C1; } 
	if( $RPS_X_C2 < $RPS_X_C1 || $RPS_X_C2 == 0 ) { $RPS_X_C2 = $RPS_X_C1; } 
	if( $RPS_Y_C2 < $RPS_Y_C1 || $RPS_Y_C2 == 0 ) { $RPS_Y_C2 = $RPS_Y_C1; } 
	if( $RPS_Z_C2 < $RPS_Z_C1 || $RPS_Z_C2 == 0 ) { $RPS_Z_C2 = $RPS_Z_C1; } 
	if( $RPS_DY_C2 < $RPS_DY_C1 || $RPS_DY_C2 == 0 ) { $RPS_DY_C2 = $RPS_DY_C1; } 
	if( $RPS_TM_C2 < $RPS_TM_C1 || $RPS_TM_C2 == 0 ) { $RPS_TM_C2 = $RPS_TM_C1; } 
	
	# SPS
	if( $SPS_ID_C1 == 0 ) { $SPS_ID_C1 = 1; } 
	if( $SPS_LN_C1 == 0 ) { $SPS_LN_C1 = 1; } 
	if( $SPS_PN_C1 == 0 ) { $SPS_PN_C1 = 1; } 
	if( $SPS_PI_C1 == 0 ) { $SPS_PI_C1 = 1; } 
	if( $SPS_PC_C1 == 0 ) { $SPS_PC_C1 = 1; } 
	if( $SPS_SC_C1 == 0 ) { $SPS_SC_C1 = 1; } 
	if( $SPS_PD_C1 == 0 ) { $SPS_PD_C1 = 1; } 
	if( $SPS_SD_C1 == 0 ) { $SPS_SD_C1 = 1; } 
	if( $SPS_UT_C1 == 0 ) { $SPS_UT_C1 = 1; } 			
	if( $SPS_WD_C1 == 0 ) { $SPS_WD_C1 = 1; } 
	if( $SPS_X_C1 == 0 ) { $SPS_X_C1 = 1; } 
	if( $SPS_Y_C1 == 0 ) { $SPS_Y_C1 = 1; } 
	if( $SPS_Z_C1 == 0 ) { $SPS_Z_C1 = 1; } 
	if( $SPS_DY_C1 == 0 ) { $SPS_DY_C1 = 1; } 
	if( $SPS_TM_C1 == 0 ) { $SPS_TM_C1 = 1; } 

	if( $SPS_ID_C2 < $SPS_ID_C1 || $SPS_ID_C2 == 0 ) { $SPS_ID_C2 = $SPS_ID_C1; } 
	if( $SPS_LN_C2 < $SPS_LN_C1 || $SPS_LN_C2 == 0 ) { $SPS_LN_C2 = $SPS_LN_C1; } 
	if( $SPS_PN_C2 < $SPS_PN_C1 || $SPS_PN_C2 == 0 ) { $SPS_PN_C2 = $SPS_PN_C1; } 
	if( $SPS_PI_C2 < $SPS_PI_C1 || $SPS_PI_C2 == 0 ) { $SPS_PI_C2 = $SPS_PI_C1; } 
	if( $SPS_PC_C2 < $SPS_PC_C1 || $SPS_PC_C2 == 0 ) { $SPS_PC_C2 = $SPS_PC_C1; } 
	if( $SPS_SC_C2 < $SPS_SC_C1 || $SPS_SC_C2 == 0 ) { $SPS_SC_C2 = $SPS_SC_C1; } 
	if( $SPS_PD_C2 < $SPS_PD_C1 || $SPS_PD_C2 == 0 ) { $SPS_PD_C2 = $SPS_PD_C1; } 
	if( $SPS_SD_C2 < $SPS_SD_C1 || $SPS_SD_C2 == 0 ) { $SPS_SD_C2 = $SPS_SD_C1; } 
	if( $SPS_UT_C2 < $SPS_UT_C1 || $SPS_UT_C2 == 0 ) { $SPS_UT_C2 = $SPS_UT_C1; } 
	if( $SPS_WD_C2 < $SPS_WD_C1 || $SPS_WD_C2 == 0 ) { $SPS_WD_C2 = $SPS_WD_C1; } 
	if( $SPS_X_C2 < $SPS_X_C1 || $SPS_X_C2 == 0 ) { $SPS_X_C2 = $SPS_X_C1; } 
	if( $SPS_Y_C2 < $SPS_Y_C1 || $SPS_Y_C2 == 0 ) { $SPS_Y_C2 = $SPS_Y_C1; } 
	if( $SPS_Z_C2 < $SPS_Z_C1 || $SPS_Z_C2 == 0 ) { $SPS_Z_C2 = $SPS_Z_C1; } 
	if( $SPS_DY_C2 < $SPS_DY_C1 || $SPS_DY_C2 == 0 ) { $SPS_DY_C2 = $SPS_DY_C1; } 
	if( $SPS_TM_C2 < $SPS_TM_C1 || $SPS_TM_C2 == 0 ) { $SPS_TM_C2 = $SPS_TM_C1; } 
	
	# XPS
	if( $XPS_ID_C1 == 0 ) { $XPS_ID_C1 = 1; } 
	if( $XPS_TP_C1 == 0 ) { $XPS_TP_C1 = 1; } 
	if( $XPS_RN_C1 == 0 ) { $XPS_RN_C1 = 1; } 
	if( $XPS_RI_C1 == 0 ) { $XPS_RI_C1 = 1; } 
	if( $XPS_IC_C1 == 0 ) { $XPS_IC_C1 = 1; } 
	if( $XPS_LN_C1 == 0 ) { $XPS_LN_C1 = 1; } 
	if( $XPS_PN_C1 == 0 ) { $XPS_PN_C1 = 1; } 
	if( $XPS_PI_C1 == 0 ) { $XPS_PI_C1 = 1; } 
	if( $XPS_FC_C1 == 0 ) { $XPS_FC_C1 = 1; } 			
	if( $XPS_TC_C1 == 0 ) { $XPS_TC_C1 = 1; } 
	if( $XPS_CI_C1 == 0 ) { $XPS_CI_C1 = 1; } 
	if( $XPS_RL_C1 == 0 ) { $XPS_RL_C1 = 1; } 
	if( $XPS_FR_C1 == 0 ) { $XPS_FR_C1 = 1; } 
	if( $XPS_TR_C1 == 0 ) { $XPS_TR_C1 = 1; } 
	if( $XPS_RX_C1 == 0 ) { $XPS_RX_C1 = 1; } 

	if( $XPS_ID_C2 < $XPS_ID_C1 || $XPS_ID_C2 == 0 ) { $XPS_ID_C2 = $XPS_ID_C1; } 
	if( $XPS_TP_C2 < $XPS_TP_C1 || $XPS_TP_C2 == 0 ) { $XPS_TP_C2 = $XPS_TP_C1; } 
	if( $XPS_RN_C2 < $XPS_RN_C1 || $XPS_RN_C2 == 0 ) { $XPS_RN_C2 = $XPS_RN_C1; } 
	if( $XPS_RI_C2 < $XPS_RI_C1 || $XPS_RI_C2 == 0 ) { $XPS_RI_C2 = $XPS_RI_C1; } 
	if( $XPS_IC_C2 < $XPS_IC_C1 || $XPS_IC_C2 == 0 ) { $XPS_IC_C2 = $XPS_IC_C1; } 
	if( $XPS_LN_C2 < $XPS_LN_C1 || $XPS_LN_C2 == 0 ) { $XPS_LN_C2 = $XPS_LN_C1; } 
	if( $XPS_PN_C2 < $XPS_PN_C1 || $XPS_PN_C2 == 0 ) { $XPS_PN_C2 = $XPS_PN_C1; } 
	if( $XPS_PI_C2 < $XPS_PI_C1 || $XPS_PI_C2 == 0 ) { $XPS_PI_C2 = $XPS_PI_C1; } 
	if( $XPS_FC_C2 < $XPS_FC_C1 || $XPS_FC_C2 == 0 ) { $XPS_FC_C2 = $XPS_FC_C1; } 
	if( $XPS_TC_C2 < $XPS_TC_C1 || $XPS_TC_C2 == 0 ) { $XPS_TC_C2 = $XPS_TC_C1; } 
	if( $XPS_CI_C2 < $XPS_CI_C1 || $XPS_CI_C2 == 0 ) { $XPS_CI_C2 = $XPS_CI_C1; } 
	if( $XPS_RL_C2 < $XPS_RL_C1 || $XPS_RL_C2 == 0 ) { $XPS_RL_C2 = $XPS_RL_C1; } 
	if( $XPS_FR_C2 < $XPS_FR_C1 || $XPS_FR_C2 == 0 ) { $XPS_FR_C2 = $XPS_FR_C1; } 
	if( $XPS_TR_C2 < $XPS_TR_C1 || $XPS_TR_C2 == 0 ) { $XPS_TR_C2 = $XPS_TR_C1; } 
	if( $XPS_RX_C2 < $XPS_RX_C1 || $XPS_RX_C2 == 0 ) { $XPS_RX_C2 = $XPS_RX_C1; } 
}
                              
                              
sub HelpAbout                 
{                             
my $ver = XSPST_LC::LC('Version');
my $dt = XSPST_LC::LC('Date');
my $author = XSPST_LC::LC('Author');
$MW->messageBox( -icon => 'info', 
		 -title => XSPST_LC::LC('About'), 
		 -message => "$PRG_NAME
                              
$ver: $PRG_VER             
$dt: $PRG_DATE               
$author: $PRG_AUTHOR", );     
	                      
}	                      
                              
sub ExitProgram               
{                             
	if( Tk::Exists( $MW )  )   { $MW->Tk::destroy; }
                              
}                             
                              
sub WhatTheFuck               
{                             
	$MW->messageBox( -icon=>'error', 
			 -title=>':-||| ', 
			 -message => "!?!?!?!?!?!" ); 
}


sub ConfigDir 
{
	use Env qw( SPS_SUITE_DIR );
	$SPS_SUITE_DIR =~ s/\\/\//g;
	return $SPS_SUITE_DIR;
}

sub ConfigCheck
{
	my $cfg_dir = ConfigDir();
	if( !$cfg_dir )
	{
		$MW = MainWindow->new();
		$MW->messageBox( -icon=>'error', -title=>XSPST_LC::LC('ERROR'), -message => 'System variable XSPSSUITE_DIR is not set.' ); 
		exit;
	}
	my $cfg_file1 = $cfg_dir."/".$SPS_SUITE_CFG;
	if( !(-e $cfg_file1) )
	{
		$MW = MainWindow->new();
		$MW->messageBox( -icon=>'error', -title=>XSPST_LC::LC('ERROR'), -message=>XSPST_LC::LC('Config file does not exist') . ":  " . $cfg_file1 ); 
		exit;
	}
}
 
sub ConfigLoad
{
	my $cfg_file1 = ConfigDir()."/".$SPS_SUITE_CFG;
	do $cfg_file1;
	XSPST_LC::set_lc( $SPS_SUITE_LANG );
}        
