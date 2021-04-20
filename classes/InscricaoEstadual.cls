public with sharing class InscricaoEstadual {
  
  public static boolean validaIE( String aUF, String aNumber )
  {
    return true;
    integer lLen = aNumber.length();
    String lNb = '';
    for ( integer i=0; i<lLen; i++ )
    {
      String lChar = aNumber.substring( i, i + 1 );
      if ( lChar >= '0' && lChar <= '9' )
        lNb += lChar;
    }
    if ( aUF.equalsIgnoreCase( 'SP' ) ) return validaIE_SP( lNb, aNumber.startsWith( 'P' ) );
    else if ( aUF.equalsIgnoreCase( 'RJ' ) ) return validaIE_RJ( lNb );
    else if ( aUF.equalsIgnoreCase( 'DF' ) ) return validaIE_DF( lNb );
    else if ( aUF.equalsIgnoreCase( 'MG' ) ) return validaIE_MG( lNb );
    else if ( aUF.equalsIgnoreCase( 'SC' ) ) return validaIE_SC( lNb );
    else if ( aUF.equalsIgnoreCase( 'PR' ) ) return validaIE_PR( lNb );
    else if ( aUF.equalsIgnoreCase( 'RS' ) ) return validaIE_RS( lNb );
    else if ( aUF.equalsIgnoreCase( 'BA' ) ) return validaIE_BA( lNb );
    else if ( aUF.equalsIgnoreCase( 'PE' ) ) return validaIE_PE( lNb );
    else if ( aUF.equalsIgnoreCase( 'ES' ) ) return validaIE_ES( lNb );
    else if ( aUF.equalsIgnoreCase( 'PB' ) ) return validaIE_PB( lNb );
    else if ( aUF.equalsIgnoreCase( 'CE' ) ) return validaIE_CE( lNb );
    else if ( aUF.equalsIgnoreCase( 'SE' ) ) return validaIE_SE( lNb );
    else if ( aUF.equalsIgnoreCase( 'MA' ) ) return validaIE_MA( lNb );
    else if ( aUF.equalsIgnoreCase( 'PI' ) ) return validaIE_PI( lNb );
    else if ( aUF.equalsIgnoreCase( 'RN' ) ) return validaIE_RN( lNb );
    else if ( aUF.equalsIgnoreCase( 'AL' ) ) return validaIE_AL( lNb );
    else if ( aUF.equalsIgnoreCase( 'GO' ) ) return validaIE_GO( lNb );
    else if ( aUF.equalsIgnoreCase( 'MT' ) ) return validaIE_MT( lNb );
    else if ( aUF.equalsIgnoreCase( 'MS' ) ) return validaIE_MS( lNb );
    else if ( aUF.equalsIgnoreCase( 'TO' ) ) return validaIE_TO( lNb );
    else if ( aUF.equalsIgnoreCase( 'PA' ) ) return validaIE_PA( lNb );
    else if ( aUF.equalsIgnoreCase( 'AM' ) ) return validaIE_AM( lNb );
    else if ( aUF.equalsIgnoreCase( 'AP' ) ) return validaIE_AP( lNb );
    else if ( aUF.equalsIgnoreCase( 'RO' ) ) return validaIE_RO( lNb );
    else if ( aUF.equalsIgnoreCase( 'RR' ) ) return validaIE_RR( lNb );
    else if ( aUF.equalsIgnoreCase( 'AC' ) ) return validaIE_AC( lNb );
    return false;
  }
  
//--------------------------------------------------------------------/
//             Valida IE do Estado: Acre
//--------------------------------------------------------------------/
  private static boolean validaIE_AC( String aNumber )
  {
    return aNumber.length() == 13 && aNumber.startsWith( '01' )
        && aNumber.substring( 11, 12 ).equalsIgnoreCase( modulo11( aNumber.substring( 0, 11 ), 2, 9 ) )
        && aNumber.substring( 12, 13 ).equalsIgnoreCase( modulo11( aNumber.substring( 0, 12 ), 2, 9 ) );
  }  

//--------------------------------------------------------------------/
//             Valida IE do Estado: Alagoas
//--------------------------------------------------------------------/ 
 private static boolean validaIE_AL( String aNumber )
  {
    String lPreffix;
    return aNumber.length() == 9 && aNumber.startsWith( '24' )
        && ( ( lPreffix = aNumber.substring( 2, 3 ) ).equalsIgnoreCase( '0' )
            || lPreffix.equalsIgnoreCase( '3' ) || lPreffix.equalsIgnoreCase( '5' )
            || lPreffix.equalsIgnoreCase( '7' ) || lPreffix.equalsIgnoreCase( '8' ) )
        && aNumber.endsWith( modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }  

//--------------------------------------------------------------------/
//             Valida IE do Estado: Amapá
//--------------------------------------------------------------------/ 
  private static boolean validaIE_AP( String aNumber )
  {
    if ( aNumber.length() != 9 || !aNumber.startsWith( '03' ) ) return false;
    integer lNb = Integer.valueOf( aNumber.substring( 2, 8 ) );
    Integer lSoma, d;
    if( lNb <= 17000 )
    {
      lSoma = 5;
      d = 0;
    }
    else
      if ( lNb >= 19023 )
      {
        lSoma = 0;
        d = 0;
      }
      else
      {
        lSoma = 9;
        d = 1;
      }
    
    String lNum = aNumber.substring( 0, 8 );
    for ( integer i=0; i<lNum.length(); i++ )
      lSoma += Integer.valueOf( lNum.substring( i, i + 1 ) ) * ( 10 - i - 1 );
    integer lSobra = Math.mod( lSoma, 11 );
    if ( lSobra == 0 ) lSobra = 0;
    else if ( lSobra == 1 ) lSobra = d;
    else lSobra = 11 - lSobra;
    return aNumber.endsWith( String.valueOf( lSobra ) );
  }  

//--------------------------------------------------------------------/
//             Valida IE do Estado: Amazonas
//--------------------------------------------------------------------/ 
  private static boolean validaIE_AM( String aNumber )
  {
    return aNumber.length() == 9 
        && aNumber.endsWith( modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }  

//--------------------------------------------------------------------/
//             Valida IE do Estado: Bahia
//--------------------------------------------------------------------/ 
  private static boolean validaIE_BA( String aNumber )
  {
    if ( aNumber.length() != 8 && aNumber.length() != 9 ) return false;
    Integer lLastPos = aNumber.length() - 2;
    
    String lNum = aNumber.substring( 0, lLastPos );
    String lFirstNum = aNumber.substring( 0, 1 );
    Integer lMod = ( lFirstNum.equalsIgnoreCase( '6' ) 
                  || lFirstNum.equalsIgnoreCase( '7' ) 
                  || lFirstNum.equalsIgnoreCase( '9' ) ) ? 11 : 10;
    Integer lSoma = 0;
    for ( Integer i=1; i<=2; i++ )
    {
      for ( integer j=lNum.length()-1; j>=0; j-- )
        lSoma += Integer.valueOf( lNum.substring( j, j + 1 ) ) * ( lLastPos + i - j );
      Integer lSobra = Math.mod( lSoma, lMod );
      lNum += lSobra < lMod-9 ? '0' : String.valueOf( lMod - lSobra );
      lSoma = 0;
    }
    return aNumber.endsWith( lNum.substring( lLastPos+1, lLastPos+2 ) + lNum.substring( lLastPos, lLastPos+1 ) );
  }  

//--------------------------------------------------------------------/
//             Valida IE do Estado: Ceará
//--------------------------------------------------------------------/ 
  private static boolean validaIE_CE( String aNumber )
  {
    return aNumber.length() == 9
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }  

//--------------------------------------------------------------------/
//             Valida IE do Estado: Distrito Federal
//--------------------------------------------------------------------/ 
  private static boolean validaIE_DF( String aNumber )
  {
    if ( aNumber.length() != 13 ) return false;
    String lNum = aNumber.substring( 0, 11 );
    Integer lSoma = 0;
    for ( Integer i=1; i<=2; i++ )
    {
      Integer lMult = 2;
      for ( integer j=lNum.length()-1; j>=0; j-- )
      {
        lSoma += Integer.valueOf( lNum.substring( j, j+1 ) ) * lMult;
        lMult = lMult==9? 2 : lMult+1;
      }
      Integer lSobra = Math.mod( lSoma, 11 );
      lSobra = 11 - lSobra;
      if ( lSobra > 9 ) lSobra = 0;
      lNum += lSobra;
      lSoma = 0;
    }
    return aNumber.endsWith( lNum.substring( 11, 13 ) );
  }  

//--------------------------------------------------------------------/
//             Valida IE do Estado: Espírito Santo
//--------------------------------------------------------------------/ 
  private static boolean validaIE_ES( String aNumber )
  {
    return aNumber.length() == 9 
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }  

//--------------------------------------------------------------------/
//             Valida IE do Estado: Goiás
//--------------------------------------------------------------------/ 
  private static boolean validaIE_GO( String aNumber )
  {
    if ( aNumber.length() != 9 ) return false;
    String lPreffix = aNumber.substring( 0, 2 );
    if ( !lPreffix.equalsIgnoreCase( '10' ) && !lPreffix.equalsIgnoreCase( '11' ) 
    && !lPreffix.equalsIgnoreCase( '15' ) ) return false;
    String lNum = aNumber.substring( 0, 8 );
    Integer lSoma = 0;
    Integer lMult = 2;
    for ( Integer i=lNum.length()-1; i>=0; i-- )
    {
      lSoma += Integer.valueOf( aNumber.substring( i, i + 1 ) ) * lMult;
      lMult = lMult==9? 2 : lMult+1;
    }
    Integer lSobra = Math.mod( lSoma, 11 );
    String lDig;
    if ( lSobra < 2 )
      if ( lSobra == 0 ) lDig = '0';
      else
      {
        Integer lNb = Integer.valueOf( aNumber.substring( 0, 8 ) );
        if ( ( lNb == 11094402 ) || ( lNb >= 10103105 && lNb <= 10119997 ) )
          lDig = '1';
        else
          lDig = '0';
      }
    else
      lDig = String.valueOf( 11 - lSobra );
    return aNumber.endsWith( lDig );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Maranhão
//--------------------------------------------------------------------/ 
  private static boolean validaIE_MA( String aNumber )
  {
    return aNumber.length() == 9 && aNumber.startsWith( '12' )
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Mato Grosso
//--------------------------------------------------------------------/ 
  private static boolean validaIE_MT( String aNumber )
  {
    return aNumber.length() == 11
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 10 ), 2, 9 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Mato Grosso do Sul
//--------------------------------------------------------------------/ 
  private static boolean validaIE_MS( String aNumber )
  {
    return aNumber.length() == 9 && aNumber.startsWith( '28' )
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Minas Gerais
//--------------------------------------------------------------------/ 
  private static boolean validaIE_MG( String aNumber )
  {
    if ( aNumber.length() != 13 ) return false;
    String lNum = aNumber.substring( 0, 3 ) + '0' + aNumber.substring( 3 );
    Integer lSoma = 0;
    Integer lSobra;
    for ( Integer i=0; i<12; i++ )
    {
      lSobra = Integer.valueOf( lNum.substring( i, i + 1 ) ) * ( Math.mod( i, 2 )==0 ? 1:2 );
      lSoma += ( lSobra > 9 ? lSobra/10 + Math.mod( lSobra, 10 ):lSobra );
    }
    lNum = aNumber.substring( 0, 11 ) + ( Math.mod( lSoma, 10 )==0 ? '0': String.valueOf( ( ( ( lSoma/10 ) + 1 ) * 10 ) - lSoma ) );
    lNum += modulo11( lNum, 2, 11 );
    return aNumber.endsWith( lNum.substring( 11, 13 ) );
  }


//--------------------------------------------------------------------/
//             Valida IE do Estado: Pará
//--------------------------------------------------------------------/ 
  private static boolean validaIE_PA( String aNumber )
  {
    return aNumber.length() == 9 && aNumber.startsWith( '15' )
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Paraíba
//--------------------------------------------------------------------/ 
  private static boolean validaIE_PB( String aNumber )
  {
    return aNumber.length() == 9
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Paraná
//--------------------------------------------------------------------/ 
  private static boolean validaIE_PR( String aNumber )
  {
    if ( aNumber.length() != 10 ) return false;
    String lNum = aNumber.substring( 0, 8 );
    lNum += modulo11( lNum, 2, 7 );
    lNum += modulo11( lNum, 2, 7 );
    return aNumber.endsWith( lNum.substring( 8, 10 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Pernambuco
//--------------------------------------------------------------------/ 
  private static boolean validaIE_PE( String aNumber )
  {
    Integer lTam = aNumber.length();
    
    if( lTam == 14 ){ 
      Integer lSoma = 0;
      Integer lMult = 2;
      for ( Integer i=aNumber.length()-2; i>=0; i-- )
      {
        lSoma += Integer.valueOf( aNumber.substring( i, i + 1 ) ) * lMult;
        lMult = lMult==9? 1 : lMult+1;
      }
      lSoma = 11 - Math.mod( lSoma, 11 );
      if( lSoma > 9 ) lSoma = lSoma -10;
      return aNumber.endsWith( String.valueOf( lSoma ) );
    }else if( lTam == 9 ){
      String lNum = aNumber.substring( 0, 7 );
        lNum += modulo11( lNum, 2, 8 );
        lNum += modulo11( lNum, 2, 9 );
        return aNumber.endsWith( lNum.substring( 7, 9 ));
    }
    return false;
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Piauí
//--------------------------------------------------------------------/ 
  private static boolean validaIE_PI( String aNumber )
  {
    return aNumber.length() == 9
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Rio de Janeiro
//--------------------------------------------------------------------/ 
  private static boolean validaIE_RJ( String aNumber )
  {
    return aNumber.length() == 8
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 7 ), 2, 7 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Rio Grande do Norte
//--------------------------------------------------------------------/ 
  private static boolean validaIE_RN( String aNumber )
  {
    integer lLen = aNumber.length();
    if ( ( lLen != 9 && lLen != 10 ) || !aNumber.startsWith( '20' ) ) return false;
    Integer lSoma = 0;
    Integer lMult = 2;
    //String lNum = aNumber.substring( 0, 9 );
    for ( Integer i=aNumber.length()-2; i>=0; i-- )
    {
      lSoma += Integer.valueOf( aNumber.substring( i, i + 1 ) ) * lMult;
      lMult++;
    }
    lSoma = Math.mod( lSoma * 10, 11 );
    if ( lSoma == 10 ) lSoma = 0;
    return aNumber.endsWith( String.valueOf( lSoma ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Rio Grande do Sul
//--------------------------------------------------------------------/ 
  private static boolean validaIE_RS( String aNumber )
  {
    return aNumber.length() == 10
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 9 ), 2, 9 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Rondônia
//--------------------------------------------------------------------/ 
  private static boolean validaIE_RO( String aNumber )
  {
    if ( aNumber.length() != 14 ) return false;
    String lNum = aNumber.substring( 0, 13 );
    Integer lSoma = 0;
    Integer lMult = 2;
    for ( Integer i=lNum.length()-1; i>=0; i-- )
    {
      lSoma += Integer.valueOf( lNum.substring( i, i + 1 ) ) * lMult;
      lMult = lMult==9? 2 : lMult+1;
    }
    lSoma = 11 - Math.mod( lSoma, 11 );
    if ( lSoma > 9 ) lSoma = lSoma - 10;
    return aNumber.endsWith( String.valueOf( lSoma ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Roraima
//--------------------------------------------------------------------/ 
  private static boolean validaIE_RR( String aNumber )
  {
    if ( aNumber.length() != 9 && !aNumber.startsWith('24') ) return false;
    String lNum = aNumber.substring( 0, 8 );
    Integer lSoma = 0;
    Integer lLen = lNum.length();
    for ( Integer i=0; i<lLen; i++ )
      lSoma += Integer.valueOf( lNum.substring( i, i + 1 ) ) * ( i + 1 );
    return aNumber.endsWith( String.valueOf( Math.mod( lSoma, 9 ) ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Santa Catarina
//--------------------------------------------------------------------/ 
  private static boolean validaIE_SC( String aNumber )
  {
    return aNumber.length() == 9
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: São Paulo
//--------------------------------------------------------------------/ 
  private static boolean validaIE_SP( String aNumber, boolean aComP )
  {
    String lNum;
    Integer lSoma = 0;
    Integer[] lMult = new Integer[]{ 1, 3, 4, 5, 6, 7, 8, 10 };
    if ( aComP )
    {
      if ( aNumber.length() != 13 ) return false;
      lNum = aNumber.substring( 1, 9 );
      for ( Integer i=0; i<8; i++ )
        lSoma += Integer.valueOf( lNum.substring( i, i + 1 ) ) * ( lMult[ i ] );
      lSoma = Math.mod( lSoma, 11 );
      if ( lSoma > 9 ) lSoma = 0;
      return aNumber.substring( 10, 11 ).equalsIgnoreCase( String.valueOf( lSoma ) );
    }
    else
    {
      if ( aNumber.length() != 12 ) return false;
      lNum = aNumber.substring( 0, 8 );
      for ( Integer i=0; i<8; i++ )
        lSoma += Integer.valueOf( lNum.substring( i, i + 1 ) ) * ( lMult[ i ] );
      lSoma = Math.mod( lSoma, 11 );
      if ( lSoma > 9 ) lSoma = 0;
      lNum += lSoma + aNumber.substring( 9, 11 );
      Integer ll = 2;
      lSoma = 0;
      for ( Integer i=10; i>=0; i-- )
      {
        lSoma += Integer.valueOf( lNum.substring( i, i + 1 ) ) * ll;
        ll = ll==10 ? 2:ll+1;
      }
      lSoma = Math.mod( lSoma, 11 );
      if ( lSoma > 9 ) lSoma = 0;
      return aNumber.endsWith( lNum.substring( 8, 11 ) + String.valueOf( lSoma ) );
    }
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Sergipe
//--------------------------------------------------------------------/ 
  private static boolean validaIE_SE( String aNumber )
  {
    return aNumber.length() == 9
        && aNumber.endsWith( Modulo11( aNumber.substring( 0, 8 ), 2, 9 ) );
  }

//--------------------------------------------------------------------/
//             Valida IE do Estado: Tocantins
//--------------------------------------------------------------------/ 
  private static boolean validaIE_TO( String aNumber )
  {
    String lPreffix;
    if ( aNumber.length() != 11 || !aNumber.startsWith( '29' )
    || ( !( lPreffix = aNumber.substring( 2, 4 ) ).startsWith( '01' ) 
    && !lPreffix.startsWith( '02' ) && !lPreffix.startsWith( '03' ) 
    && !lPreffix.startsWith( '99' ) ) ) return false;
    String lNum =  aNumber.substring( 0, 2 ) + aNumber.substring( 4, 10 );
    return aNumber.endsWith( modulo11( lNum, 2, 9 ) );
  }
//--------------------------------------------------------------------/
//                   Cálculo do Módulo 10
//--------------------------------------------------------------------/
  private static String modulo10( String aNumber, Integer aIni, Integer aFim )
  {
    integer lSoma = 0;
    integer lDig = aIni;
    integer lLen = aNumber.length();
    for ( integer i=lLen-1; i>=0; i-- )
    {
      lSoma += integer.valueOf( aNumber.substring( i, i + 1 ) ) * lDig;
      if ( lDig == aFim ) lDig = aIni;
      else lDig++;
    }
    integer lSobra = Math.mod( lSoma, 10 );
    if ( lSobra == 0 ) return '0';
    else return String.valueOf( 10 - lSobra );
  }
  
//--------------------------------------------------------------------/
//                   Cálculo do Módulo 11
//--------------------------------------------------------------------/
  private static String modulo11( String aNumber, Integer aIni, Integer aFim )
  {
    integer lSoma = 0;
    integer lDig = aIni;
    for ( integer i=aNumber.length()-1; i>=0; i-- )
    {
      lSoma += integer.valueOf( aNumber.substring( i, i + 1 ) ) * lDig;
      if ( lDig == aFim ) lDig = aIni;
      else lDig++;
    }
    integer lSobra = Math.mod( lSoma, 11 );
    if ( lSobra < 2 ) return '0';
    else return String.valueOf( 11 - lSobra );
  }
  
}