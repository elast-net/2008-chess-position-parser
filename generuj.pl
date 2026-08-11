# IN: plik (zapis partii ruch po ruchu) w formacie PGN
# OUT: generuje pozycje na planszy po $ile_ruchow posunieciach

#!/usr/bin/perl

use Switch;

$ile_ruchow=25;
$glowny_licznik=0;

open IN, "train.pgn";
open TEMP, ">temp.txt";
open OUT, ">out.txt";

$wynik=0;

$newline="\n";
$wynikb="1-0";
$wynikr="1/2-1/2";
$wynikc="0-1";

$lp=0; #liczba porzadkowa

# konwertuje plik do postaci wygodniejszej dla skryptu
while(<IN>) { 
  if(!/\[(.*)/) {
    s/$newline/ /g;
    s/[+#x]//g; #usuwa szachy, maty i bicia
    s/\d\.|\d\d\.|\d\d\d\.//g; #usuwa numer ruchu
    s/$wynikb/1$newline/g;
    s/$wynikr/2$newline/g;
    s/$wynikc/3$newline/g;
    s/a/1/g;
    s/b/2/g;
    s/c/3/g;
    s/d/4/g;
    s/e/5/g;
    s/f/6/g;
    s/g/7/g;
    s/h/8/g;
    
    s/\{(.*)\}//g;
    s/[\!\?\.\{\}\$\)\(\:\'\"\]\,\/]//g;
    s/[ijklmnopqrstuvwyzACEGHIJLTUWY]//g;
    
    print TEMP $_;
    
    $glowny_licznik++;
    if ($glowny_licznik%100000==0) { print "Skonwertowano ".($glowny_licznik/1000)." tys. wierszy\n"; }
    
  }
}

print "Skonwertowano ".$glowny_licznik." wierszy\n\n";
$glowny_licznik=0;

close TEMP;
open TEMP, "temp.txt";


#plansza:
#    A  B  C  D  E  F  G  H
# |------------------------
#8| 56 57 58 59 60 61 62 63
#7| 48 49 50 51 52 53 54 55 
#6| 40 41 42 43 44 45 46 47 
#5| 32 33 34 35 36 37 38 39 
#4| 24 25 26 27 28 29 30 31 
#3| 16 17 18 19 20 21 22 23 
#2|  8  9 10 11 12 13 14 15 
#1|  0  1  2  3  4  5  6  7 


# glowna petla, rozgrywa partie
while(<TEMP>) {
  @tab=();
  @tab=split(" ",$_);
   
   
  my (@plansza)=qw( 
  r n b q k b n r 
  p p p p p p p p 
  - - - - - - - - 
  - - - - - - - - 
  - - - - - - - - 
  - - - - - - - - 
  P P P P P P P P 
  R N B Q K B N R 
  ); #u gory biale, na dole czarne!
  $wynik=0;
  $licznik=0;
  $licznik_ruchow=0;
  $pozycja=0; 
  $glowny_licznik++;
  if ($glowny_licznik%5000==0) { print "Wygenerowano ".($glowny_licznik/1000)." tys. pozycji\n"; }
  
  
  @skoczek=(-17,-15,-10,-6,6,10,15,17); #wektory przesuniec ruchu skoczka
  
  
  if($#tab>=2*$ile_ruchow) { # filtruje partie z co najmniej $ile_ruchow ruchami
    $wynik=pop(@tab);
    foreach(@tab) {
      $licznik=($licznik+1)%2; # ruch bialych (1) czy czarnych (0) ?
      $licznik_ruchow+=$licznik;
      
      #if(length($_)==1) { $wynik=$_; }
      
      
      # LENGTH=2 --------------------------------------------------------------
            
      if(length($_)==2) { 
          
        # PIONEK --------------------------------------------------------------
             
        #ruch pionkiem bez bicia
        
        $pozycja=8*(substr($_,1,1)-1)+substr($_,0,1)-1;
        
        if(($licznik%2)==1) {           
          $plansza[$pozycja]="p";           
          do { $pozycja-=8; } while ($pozycja>=0&&$plansza[$pozycja] ne "p");
          $plansza[$pozycja]="-";
        }
        else { 
	  $plansza[$pozycja]="P";           
	  do { $pozycja+=8; } while ($pozycja<=63&&$plansza[$pozycja] ne "P");
          $plansza[$pozycja]="-";        
        }
      }      
      
      # LENGTH=3 --------------------------------------------------------------
      
      if(length($_)==3) {
        
        # ROSZADA -------------------------------------------------------------
        
        if($_ eq "O-O") {
          if(($licznik%2)==1) {
            $plansza[5]="r"; $plansza[6]="k";
            $plansza[4]="-"; $plansza[7]="-";
          }
          else {
            $plansza[61]="R"; $plansza[62]="K";
            $plansza[60]="-"; $plansza[63]="-";
          }
        }
        else {
        
          $pozycja=8*(substr($_,2,1)-1)+substr($_,1,1)-1;
          
          # RUCH FIGURA ---------------------------------------------------------
          if(substr($_,0,1) =~ /[RNBQK12345678]/) {
        
          $znaleziono=0;
          $i=0; $j=0;
          
          # WIEZA -------------------------------------------------------------
          
          if(substr($_,0,1) eq "R") {
            
            if(($licznik%2)==1) {               
              $i=$pozycja-1;
              while($i%8!=7&&($plansza[$i] eq "-"||$plansza[$i] eq "r")&&($znaleziono==0)) {
                if($plansza[$i] eq "r") { $plansza[$i]="-"; $znaleziono=1; }  
                $i--;
              }
              $i=$pozycja+1;
              while($i%8!=0&&($plansza[$i] eq "-"||$plansza[$i] eq "r")&&($znaleziono==0)) {
	        if($plansza[$i] eq "r") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i++;
              }
              $i=$pozycja-8;
	      while($i>=0&&($plansza[$i] eq "-"||$plansza[$i] eq "r")&&($znaleziono==0)) {
	        if($plansza[$i] eq "r") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i-=8;
	      }
	      $i=$pozycja+8;
	      while($i<=63&&($plansza[$i] eq "-"||$plansza[$i] eq "r")&&($znaleziono==0)) {
	        if($plansza[$i] eq "r") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i+=8;
              }
              $plansza[$pozycja]="r";           
            }
            
            else {            
	      $i=$pozycja-1;
	      while($i%8!=7&&($plansza[$i] eq "-"||$plansza[$i] eq "R")&&($znaleziono==0)) {
	        if($plansza[$i] eq "R") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i--;
	      }
	      $i=$pozycja+1;
	      while($i%8!=0&&($plansza[$i] eq "-"||$plansza[$i] eq "R")&&($znaleziono==0)) {
	    	if($plansza[$i] eq "R") { $plansza[$i]="-"; $znaleziono=1; }  
	      	$i++;
	      }
	      $i=$pozycja-8;
	      while($i>=0&&($plansza[$i] eq "-"||$plansza[$i] eq "R")&&($znaleziono==0)) {
	        if($plansza[$i] eq "R") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i-=8;
	      }
	      $i=$pozycja+8;
	        while($i<=63&&($plansza[$i] eq "-"||$plansza[$i] eq "R")&&($znaleziono==0)) {
	        if($plansza[$i] eq "R") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i+=8;
	      }
              $plansza[$pozycja]="R";           
            }
          }

          # SKOCZEK -----------------------------------------------------------

          if(substr($_,0,1) eq "N") {
             if(($licznik%2)==1) {
               $plansza[$pozycja]="n";
	       foreach(@skoczek) {     
	         if($pozycja+$_>=0&&$pozycja+$_<=63&&abs(($pozycja+$_)%8-$pozycja%8)<=2) {
	     	   if($plansza[$pozycja+$_] eq "n") { $plansza[$pozycja+$_]="-"; }
	         }
	       }
	     }
	     else {
               $plansza[$pozycja]="N";
	       foreach(@skoczek) {     
	         if($pozycja+$_>=0&&$pozycja+$_<=63&&abs(($pozycja+$_)%8-$pozycja%8)<=2) {
	           if($plansza[$pozycja+$_] eq "N") { $plansza[$pozycja+$_]="-"; }
	         }
	       }
	     }
          }
          
          # GONIEC ------------------------------------------------------------
          
          if(substr($_,0,1) eq "B") {
             
            $i=0;
            $j=0;
            $znaleziono=0;
	     
	    #print OUT "pozycja,i,j=".$pozycja.",".$i.",".$j."\n";
	     
            if(($licznik%2)==1) {               
              $i=$pozycja-9;
              while($i>=0&&$i%8!=7&&($plansza[$i] eq "-"||$plansza[$i] eq "b")&&($znaleziono==0)) {
                if($plansza[$i] eq "b") { $plansza[$i]="-"; $znaleziono=1; }  
                $i-=9;
              }
              $i=$pozycja+9;
              while($i<=63&&$i%8!=0&&($plansza[$i] eq "-"||$plansza[$i] eq "b")&&($znaleziono==0)) {
	        if($plansza[$i] eq "b") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i+=9;
              }
              $i=$pozycja-7;
	      while($i>=0&&$i%8!=0&&($plansza[$i] eq "-"||$plansza[$i] eq "b")&&($znaleziono==0)) {
	        if($plansza[$i] eq "b") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i-=7;
	      }
	      $i=$pozycja+7;
	      while($i<=63&&$i%8!=7&&($plansza[$i] eq "-"||$plansza[$i] eq "b")&&($znaleziono==0)) {
	        if($plansza[$i] eq "b") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i+=7;
              }
              $plansza[$pozycja]="b";           
            }
            
            else {            
              $i=$pozycja-9;
              while($i>=0&&$i%8!=7&&($plansza[$i] eq "-"||$plansza[$i] eq "B")&&($znaleziono==0)) {
                if($plansza[$i] eq "B") { $plansza[$i]="-"; $znaleziono=1; }  
                $i-=9;
              }
              $i=$pozycja+9;
              while($i<=63&&$i%8!=0&&($plansza[$i] eq "-"||$plansza[$i] eq "B")&&($znaleziono==0)) {
	        if($plansza[$i] eq "B") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i+=9;
              }
              $i=$pozycja-7;
	      while($i>=0&&$i%8!=0&&($plansza[$i] eq "-"||$plansza[$i] eq "B")&&($znaleziono==0)) {
	        if($plansza[$i] eq "B") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i-=7;
	      }
	      $i=$pozycja+7;
	      while($i<=63&&$i%8!=7&&($plansza[$i] eq "-"||$plansza[$i] eq "B")&&($znaleziono==0)) {
	        if($plansza[$i] eq "B") { $plansza[$i]="-"; $znaleziono=1; }  
	        $i+=7;
	      }
              $plansza[$pozycja]="B";           
            }          
          }
          
          # HETMAN ------------------------------------------------------------
         
          if(substr($_,0,1) eq "Q") {
            if(($licznik%2)==1) {
	      for($i=0;$i<=63;$i++) { if($plansza[$i] eq "q") { $plansza[$i]="-"; } }
	      $plansza[$pozycja]="q";
	    }
	    else {
	      foreach($i=0;$i<=63;$i++) { if($plansza[$i] eq "Q") { $plansza[$i]="-"; } }
	      $plansza[$pozycja]="Q";
	    }
          }
          
          # KROL --------------------------------------------------------------
          
          if(substr($_,0,1) eq "K") {
            if(($licznik%2)==1) {
	      foreach($i=0;$i<=63;$i++) { if($plansza[$i] eq "k") { $plansza[$i]="-"; }
	    }
	    $plansza[$pozycja]="k";
	    }
	    else {
	      foreach($i=0;$i<=63;$i++) { if($plansza[$i] eq "K") { $plansza[$i]="-"; }
	    }
	    $plansza[$pozycja]="K";
	    }
          }          
        
          # PIONEK, BICIE -----------------------------------------------------
        
          
          if(substr($_,0,1) =~ /[12345678]/) {
          
            if(($licznik%2)==1) {
              if(substr($_,0,1)-substr($_,1,1)==1) { $plansza[$pozycja-7]="-"; }
	      else { $plansza[$pozycja-9]="-"; }
	    
	      if($plansza[$pozycja] eq "-") { $plansza[$pozycja-8]="-"; } # bicie w przelocie
	      $plansza[$pozycja]="p";
	    }
	    else {
	      if(substr($_,0,1)-substr($_,1,1)==1) { $plansza[$pozycja+9]="-"; }
	      else { $plansza[$pozycja+7]="-"; }	    
	    
	      if($plansza[$pozycja] eq "-") { $plansza[$pozycja+8]="-"; }
	      $plansza[$pozycja]="P";
	    }       
          }
        }
      }
      }
      
      # LENGTH=4 --------------------------------------------------------------    
      
      if(length($_)==4) {  
        
        #pionek dochodzi na 1/8 linie i nastepuje promocja
        if(substr($_,2,1) eq "=") {
          $pozycja=8*(substr($_,1,1)-1)+substr($_,0,1)-1;
        
          $plansza[$pozycja]=substr($_,3,1);
          if(($licznik%2)==1) { $plansza[$pozycja-8]="-"; }
          else { $plansza[$pozycja+8]="-"; }
        }
        else {
          # FmnC - figura F na linii lub kolumnie m przesuwa sie na pole nC
          
          $pozycja=8*(substr($_,3,1)-1)+substr($_,2,1)-1;
          
          $i=0; $j=0;
          $temp=-1;
          $ile_figur=0;
          
	  $maly="";
	  if(substr($_,0,1) eq "R") { $maly="r"; }
	  if(substr($_,0,1) eq "N") { $maly="n"; }
	  if(substr($_,0,1) eq "B") { $maly="b"; }
	  if(substr($_,0,1) eq "Q") { $maly="q"; }
	  
          if(($licznik%2)==1) {                           
              $plansza[$pozycja]="-";
              
              $i=8*(substr($_,1,1)-1);
              for($j=0; $j<8; $j++) {
                if($plansza[$i+$j] eq $maly) { $ile_figur++; $temp=$i+$j; }
              }
              if($ile_figur==1) { $plansza[$temp]="-"; }
              else {
                $temp=-1;
                $ile_figur=0;
                
                $i=substr($_,1,1)-1;
                for($j=0; $j<8; $j++) {
		  if($plansza[$i+8*$j] eq $maly) { $ile_figur++; $temp=$i+8*$j; }
		}
		if($ile_figur==1) { $plansza[$temp]="-"; }
              }              
              $plansza[$pozycja]=$maly;
          }
          else {
               $plansza[$pozycja]="-";
               
               $i=8*(substr($_,1,1)-1);
               for($j=0; $j<8; $j++) {
                 if($plansza[$i+$j] eq substr($_,0,1)) { $ile_figur++; $temp=$i+$j; }
               }
               if($ile_figur==1) { $plansza[$temp]="-"; }
               else {
                 $temp=-1;
                 $ile_figur=0;
                 
                 $i=substr($_,1,1)-1;
                 for($j=0; $j<8; $j++) {
 		  if($plansza[$i+8*$j] eq substr($_,0,1)) { $ile_figur++; $temp=$i+8*$j; }
 		}
 		if($ile_figur==1) { $plansza[$temp]="-"; }
               }                         
               $plansza[$pozycja]=substr($_,0,1);
          }          
        }
      }
      
      # LENGTH=5 --------------------------------------------------------------
      
      if(length($_)==5) {
        
        # duza roszada, oczywiscie :)
        
        if($_ eq "O-O-O") {
	  if(($licznik%2)==1) {
	    $plansza[3]="r"; $plansza[2]="k";
	    $plansza[4]="-"; $plansza[0]="-";
	  }
	  else {
	    $plansza[59]="R"; $plansza[58]="K";
	    $plansza[60]="-"; $plansza[56]="-";
	  }
        }
        else {
        
          $pozycja=8*(substr($_,2,1)-1)+substr($_,1,1)-1;
          # pionek stojacy na 7. linii bije i promuje
        
          if(substr($_,3,1) eq "=") { 
            $plansza[$pozycja]=substr($_,4,1);
            if(($licznik%2)==1) {
  	      if(substr($_,0,1)-substr($_,1,1)==1) { $plansza[$pozycja-7]="-"; }
              else { $plansza[$pozycja-9]="-"; }	  	   
	    }
	    else {
              if(substr($_,0,1)-substr($_,1,1)==1) { $plansza[$pozycja+9]="-"; }
	      else { $plansza[$pozycja+7]="-"; }	    
	    }       
          }
          else {
            # FmCnD - figura F stojaca na polu mC przechodzi na nD
            $plansza[$pozycja]="-";
            $plansza[8*(substr($_,4,1)-1)+substr($_,3,1)-1]=substr($_,0,1);
          
          }
        }        
      }      
    
  
      

    $i=0;
    if($licznik_ruchow==$ile_ruchow&&$licznik==0&&$wynik!=null&&@plansza!=null) {  
    
    print OUT "# Input pattern ".++$lp.":\n";
    
    foreach($plansza[56],$plansza[57],$plansza[58],$plansza[59],$plansza[60],$plansza[61],$plansza[62],$plansza[63]) 
    { $i++; print OUT $_; if($i%8==0) { print OUT "\n"; $i=0; } }
    foreach($plansza[48],$plansza[49],$plansza[50],$plansza[51],$plansza[52],$plansza[53],$plansza[54],$plansza[55]) 
    { $i++; print OUT $_; if($i%8==0) { print OUT "\n"; $i=0; } }
    foreach($plansza[40],$plansza[41],$plansza[42],$plansza[43],$plansza[44],$plansza[45],$plansza[46],$plansza[47]) 
    { $i++; print OUT $_; if($i%8==0) { print OUT "\n"; $i=0; } }
    foreach($plansza[32],$plansza[33],$plansza[34],$plansza[35],$plansza[36],$plansza[37],$plansza[38],$plansza[39]) 
    { $i++; print OUT $_; if($i%8==0) { print OUT "\n"; $i=0; } }
    foreach($plansza[24],$plansza[25],$plansza[26],$plansza[27],$plansza[28],$plansza[29],$plansza[30],$plansza[31]) 
    { $i++; print OUT $_; if($i%8==0) { print OUT "\n"; $i=0; } }
    foreach($plansza[16],$plansza[17],$plansza[18],$plansza[19],$plansza[20],$plansza[21],$plansza[22],$plansza[23]) 
    { $i++; print OUT $_; if($i%8==0) { print OUT "\n"; $i=0; } }
    foreach($plansza[8],$plansza[9],$plansza[10],$plansza[11],$plansza[12],$plansza[13],$plansza[14],$plansza[15]) 
    { $i++; print OUT $_; if($i%8==0) { print OUT "\n"; $i=0; } }
    foreach($plansza[0],$plansza[1],$plansza[2],$plansza[3],$plansza[4],$plansza[5],$plansza[6],$plansza[7]) 
    { $i++; print OUT $_; if($i%8==0) { print OUT "\n"; $i=0; } }
    
    print OUT "# Output pattern ".$lp.":\n";

    #wynik w postaci wektora trojelementowego    
    #switch($wynik) {    
    #case 1 { print OUT "1 0 0\n" }
    #case 2 { print OUT "0 1 0\n" }
    #case 3 { print OUT "0 0 1\n" }
    #else { print OUT "0 0 0\n" }
    #}
    
    #wynik w postaci jednej wartosci
    switch($wynik) {    
    case 1 { print OUT "1\n" }
    case 2 { print OUT "0\n"; }
    case 3 { print OUT "-1\n"; }
    else { print OUT "0\n"; }
    }
    
    }
  }
  }
}

close IN;
close TEMP;
close OUT;

print "Zapisano ".$glowny_licznik." pozycji\nOK\n";
