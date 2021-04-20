@isTest(seeAllData=true)
private class InscricaoEstadualTest {

    static testMethod void myUnitTest() {
      chama( 'BA', '103127394' );
      chama( 'BA', '612345-57' );
      chama( 'BA', '1000003-06' );
      chama( 'AC', '01.004.823/001-12' );
      chama( 'AL', '24.0.00004-8' );
      chama( 'AL', '240000048' );
      chama( 'AP', '03.012.345-9' );
      chama( 'AP', '03.021.345-9' );
      chama( 'AP', '03.018.345-9' );
      chama( 'AM', '45.674.221-2' );
      chama( 'BA', '123456-63' );
      chama( 'CE', '06.000.001-5');
      chama( 'DF', '07.300001.001-09');
      chama( 'ES', '03.327.866-0' );
      chama( 'GO', '10.987.654-7' );
      chama( 'GO', '17.987.654-7' );
      chama( 'GO', '15.000.026-7' );
      chama( 'GO', '11.094.402-1' );
      chama( 'MA', '12.000.038-5' );
      chama( 'MT', '0013000001-9' );
      chama( 'MS', '28.030.452-8' );
      chama( 'MG', '062.307.904/0081' );
      chama( 'PA', '15.999999-5' );
      chama( 'PB', '06.000.001-5' );
      chama( 'PE', '18.1.001.0000004-9' );
      chama( 'PE', '0321418-40' );
      chama( 'PI', '01.234.567-9' );
      chama( 'PR', '123.45678-50' );
      chama( 'RJ', '99.999.99-3' );
      chama( 'RS', '224/365879-2' );
      chama( 'SC', '251.040.852' );
      chama( 'SE', '27123456-3' );
      chama( 'RN', '20.040.040-1' );
      chama( 'RN', '20.0.040.040-0' );
      chama( 'RO', '0000000062521-3' );
      chama( 'RR', '24.006.628-1' );
      chama( 'TO', '29.01.022783-6' );
      chama( 'TO', '29.98.022783-6' );
      chama( 'SP', '110.042.490.114' );
      chama( 'SP', 'P-011000424.3/002' );
      chama( 'BR', '' );
    }
    
    private static void chama( String aUF, String aNum )
    {
      system.debug( aUF +'='+InscricaoEstadual.validaIE( aUF, aNum ));
    }
    
}