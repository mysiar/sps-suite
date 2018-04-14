##############################################################################
#
# This file is part of the SPS Suite
#
# (c) Piotr Synowiec <psynowiec@gmail.com>
#
# Date: Saturday, 24 February 2001 (initial)
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
##############################################################################

package XSPST_LC;

use strict;
use vars qw(@EXPORT $VERSION %EN %PL $LANG);
use 5.004;

$VERSION = "0.01";

### ENGLISH ###
$EN{ 'File' } = 'File';
$EN{ 'Template New' }= 'Template New';
$EN{ 'Template Open' } = 'Template Open';
$EN{ 'Template Save' } = 'Template Save';
$EN{ 'Template SaveAs' } = 'Template SaveAs';
$EN{ 'RPS Open' } = 'RPS Open';
$EN{ 'SPS Open' } = 'SPS Open';
$EN{ 'XPS Open' } = 'XPS Open';
$EN{ 'Exit' } = 'Exit';

$EN{ 'Help' } = 'Help';
$EN{ 'About' } = 'About';

$EN{ 'Version' } = 'Version';
$EN{ 'Date' } = 'Date';
$EN{ 'Author' } = 'Author';

$EN{ 'NEW TEMPLATE' } = 'NEW TEMPLATE';
$EN{ 'Open Template File' } = 'Open Template File';
$EN{ 'Save Template File As' } = 'Save Template File As';
$EN{ 'Open RPS file' } = 'Open RPS file';
$EN{ 'Open SPS file' } = 'Open SPS file';
$EN{ 'Open XPS file' } = 'Open XPS file';
$EN{ 'all files' } = 'all files';
$EN{ 'sps template files' } = 'sps template files';
$EN{ 'sps receiver files' } = 'sps receiver files';
$EN{ 'sps source files' } = 'sps source files';
$EN{ 'xps relational files' } = 'xps relational files';

$EN{ 'SPS Receiver File' } = 'SPS Receiver File';
$EN{ 'SPS Source File' } = 'SPS Source File';
$EN{ 'SPS Relational File' } = 'SPS Relational File';

# RPS, SPS
$EN{ 'Record ID' } = 'Record ID';      
$EN{ 'Line Name' } = 'Line Name';        
$EN{ 'Point Number' } = 'Point Number';    
$EN{ 'Point Index' } = 'Point Index';     
$EN{ 'Point Code'  } = 'Point Code';    
$EN{ 'Static Correction' } = 'Static Correction';
$EN{ 'Point Depth' } = 'Point Depth';    
$EN{ 'Seismic Datum' } = 'Seismic Datum';   
$EN{ 'Uphole Time' } = 'Uphole Time';   
$EN{ 'Water Depth' } = 'Water Depth';     
$EN{ 'Grid Easting' } = 'Grid Easting';    
$EN{ 'Grid Northing' } = 'Grid Northing';   
$EN{ 'Surface Elevation' } = 'Surface Elevation';
$EN{ 'Day of Year' } = 'Day of Year';     
$EN{ 'Time of Day' } = 'Time of Day';    
# dodatki do XPS, kt�rych nie ma w RPS, SPS
$EN{ 'Tape Number' } = 'Tape Number';
$EN{ 'File Number' } = 'File Number';
$EN{ 'File Increment' } = 'File Increment';          
$EN{ 'Instrument Code' } = 'Instrument Code';         
$EN{ 'From Channel' } = 'From Channel';            
$EN{ 'To Channel' } = 'To Channel';              
$EN{ 'Channel Increment' } = 'Channel Increment';       
$EN{ 'Receiver Line' } = 'Receiver Line';          
$EN{ 'From Receiver Point' } = 'From Receiver Point';     
$EN{ 'To Receiver Point' } = 'To Receiver Point';      
$EN{ 'Receiver Point Increment' } = 'Receiver Point Increment';

$EN{ 'ERROR' } = 'ERROR';
$EN{ 'Config file does not exist' } = 'Config file does not exist';

### POLISH ###
$PL{ 'File' } = 'Plik';
$PL{ 'Template New' } = 'Nowy Wzorzec';
$PL{ 'Template Open' } = 'Otworz Wzorzec';
$PL{ 'Template Save' } = 'Zapisz Wzorzec';
$PL{ 'Template SaveAs' } = 'Zapisz Wzorzec Jako';
$PL{ 'RPS Open' } = 'Otw�rz RPS';
$PL{ 'SPS Open' } = 'Otw�rz SPS';
$PL{ 'XPS Open' } = 'Otw�rz XPS';
$PL{ 'Exit' } = 'Koniec';

$PL{ 'Help' } = 'Pomoc';
$PL{ 'About' } = 'O programie';

$PL{ 'Version' } = 'Wersja';
$PL{ 'Date' } = 'Data';
$PL{ 'Author' } = 'Autor';

$PL{ 'NEW TEMPLATE' } = 'NOWY WZORZEC';
$PL{ 'Open Template File' } = 'Otw�rz Plik Wzorca';
$PL{ 'Save Template File As' } = 'Zapisz Plik Wzorca Jako';
$PL{ 'Open RPS file' } = 'Otw�rz plik RPS';
$PL{ 'Open SPS file' } = 'Otw�rz plik SPS';
$PL{ 'Open XPS file' } = 'Otw�rz plik XPS';
$PL{ 'all files' } = 'wszystkie pliki';
$PL{ 'sps template files' } = 'pliki wzorca sps';
$PL{ 'sps receiver iles' } = 'pliki pkt. odbioru';
$PL{ 'sps source files' } = 'pliki pkt. wzbudzania';
$PL{ 'xps relational files' } = 'pliki relacji';

$PL{ 'SPS Receiver File' } = 'Plik SPS punkt�w odbioru';
$PL{ 'SPS Source File' } = 'Plik SPS punkt�w wzbudzania';
$PL{ 'SPS Relational File' } = 'Plik SPS relacji';

# RPS, SPS
$PL{ 'Record ID' } = 'Identyfikator';      
$PL{ 'Line Name' } = 'Linia';        
$PL{ 'Point Number' } = 'Punkt';    
$PL{ 'Point Index' } = 'Indeks Punktu';     
$PL{ 'Point Code'  } = 'Kod Punktu';    
$PL{ 'Static Correction' } = 'Poprawka Statyczna';
$PL{ 'Point Depth' } = 'G��boko�� Punktu';    
$PL{ 'Seismic Datum' } = 'Poziom Odniesienia';   
$PL{ 'Uphole Time' } = 'Uphole Time';   
$PL{ 'Water Depth' } = 'G��boko�� Wody';     
$PL{ 'Grid Easting' } = 'Wsp�rz�dna X';    
$PL{ 'Grid Northing' } = 'Wsp�rz�dna Y';   
$PL{ 'Surface Elevation' } = 'Elewacja';
$PL{ 'Day of Year' } = 'Dzie� Roku';     
$PL{ 'Time of Day' } = 'Czas';    
# dodatki do XPS, kt�rych nie ma w RPS, SPS
$PL{ 'Tape Number' } = 'Numer Ta�my';
$PL{ 'File Number' } = 'Numer Rekordu';
$PL{ 'File Increment' } = 'file increment ???';          
$PL{ 'Instrument Code' } = 'Kod Aparatury';         
$PL{ 'From Channel' } = 'Od Kana�u';            
$PL{ 'To Channel' } = 'Do Kana�u';              
$PL{ 'Channel Increment' } = 'channel increment ???';       
$PL{ 'Receiver Line' } = 'Linia Odbioru';          
$PL{ 'From Receiver Point' } = 'Od Punktu Odbioru';     
$PL{ 'To Receiver Point' } = 'Do Punktu Odbioru';      
$PL{ 'Receiver Point Increment' } = 'receiver point increment ???';

$PL{ 'ERROR' } = 'B��D';
$PL{ 'Config file does not exist' } = 'Brak pliku konfiguracyjnego';



@EXPORT = qw(set_lc LC);

sub set_lc
{
	$LANG = uc( $_[0] );	
}

sub LC
{
	my $var = $_[0];
	if( $LANG eq 'EN' )
	{
		if( $EN{ $var } ) { return $EN{ $var };	}
		else { return "????"; }
	}
	elsif( $LANG eq 'PL' )
	{
		if( $PL{ $var } ) { return $PL{ $var };  }
		elsif( $EN{ $var } ) { return $EN{ $var }; }
		else { return "????"; }
	}
	else
	{
		if( $EN{ $var } ) { return $EN{ $var };	}
		else { return "????"; }
	}	
}


