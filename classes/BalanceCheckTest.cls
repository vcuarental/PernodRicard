@isTest
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Classe que faz o teste de cobertura da classe BalanceCheck.
* NAME: BalanceCheckTest.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 19/02/2013
*
*******************************************************************************/
private class BalanceCheckTest {

    static testMethod void myUnitTest() {
        
        BalanceCheck.PMEWS010_Execute_element lBalance = new BalanceCheck.PMEWS010_Execute_element();
        lBalance.Domnro = 1;
        lBalance.Empcod = 1;
        lBalance.Paicod = 1;
        lBalance.Tdocod = '';
        lBalance.User_x = '';
        
        
    	//Inicializa objetos do webservice
        BalanceCheck.PMEWS010SoapPort lResponse = new BalanceCheck.PMEWS010SoapPort();
        BalanceCheck.PMEWS010_ExecuteResponse_element lReturn = new BalanceCheck.PMEWS010_ExecuteResponse_element();
        lReturn.Codret = '00';
        lReturn.Domsta = 'Aprovado';
        lReturn.Msgret = '';
        lReturn.Saldo = 1000000;
        
    }
}