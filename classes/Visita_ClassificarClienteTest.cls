/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe de teste para Visita_ClassificarCliente
* NAME: Visita_ClassificarClienteTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 03/07/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
@isTest
private class Visita_ClassificarClienteTest {

    static testMethod void myUnitTest()
    {
        Id idRecTypePlan = RecordTypeForTest.getRecType( 'Planejamento__c' , 'BRA_Standard' );
        Id idRecTypeAcc = RecordTypeForTest.getRecType( 'Account' , 'Off_Trade' );
        Id idRecTypeVis = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        
        Account lAcc = new Account();
        lAcc.Name = 'Teste';
        lAcc.Channel__c = 'On Trade';
        lAcc.Rating = 'Cliente cadastrado no JDE';
        lAcc.Corporate_Name__c = 'teste';
        lAcc.RecordTypeId = idRecTypeAcc;
        //insert lAcc;
        try{insert lAcc;}catch(Exception e){}
        
        Planejamento__c lPlan = new Planejamento__c();
        lPlan.RecordTypeId = idRecTypePlan;
        //insert lPlan;
        try{insert lPlan;}catch(Exception e){}
        
        Visitas__c lVisita = new Visitas__c();
        lVisita.Conta__c = lAcc.id;
        lVisita.Planejamento__c = lPlan.id; 
        lVisita.RecordTypeId = idRecTypeVis;
        lVisita.Resumo_da_Visita__c = 'teste';
        lVisita.Hora_da_Visita__c =  '8:00';
        //insert lVisita;
        try{insert lVisita;}catch(Exception e){}
        
        
        lVisita.Status__c = 'Encerrada';
        //update lVisita;
        try{update lVisita;}catch(Exception e){}
    
    }
}