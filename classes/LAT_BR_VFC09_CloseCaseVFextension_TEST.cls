/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest
public class LAT_BR_VFC09_CloseCaseVFextension_TEST {

    static testMethod void myUnitTest() {  
       UDC__c udc = new UDC__c(
           CodProd__c = '01',
           CodUs__c = '01',
           CodDefUsuario__c = '1',
           Internal_Id__c = '01-01',
           RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
       );
       
       insert udc;
       
       User us = [SELECT Id, C_digo_JDE__c FROM User WHERE Id =: userInfo.getUserId()];
       
       us.C_digo_JDE__c = '7';
       
       update us;
        
        Account acc = new Account(
            CNPJ__c = '54651716001150',
            Name = 'testAcco',
            Overdue__c = true,
            Type = 'On_Trade',
            Corporate_Name__c = 'test92569',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c = 'test0',
            Shipping_Neighbourhood__c = 'test3',
            Revenue_Neighbourhood__c = 'test2',
            Billing_Neighbourhood__c ='test1',
            Shipping_Country__c ='test4',
            Revenue_Country__c ='test5',
            Billing_Country__c ='test8',
            Status__c = 'Cliente cadastrado no JDE',
            Client_code_AN8__c = '0',
            Rating_segmentation_targert_market__c = 'Mainstream',
            LAT_BR_RegionalClientOnPremise__c = 'REG MT',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'),
            Segmentation_Type_on_trade__c = 'Mainstream',
            Regional__c = udc.Id,
            Regional_Manager__c = us.Id
        );
          
        insert acc;
        
        LAT_Contract__c ActualContract = new LAT_Contract__c();        
        date fechas = Date.newInstance(Integer.ValueOf(2013), 1, 1);
        ActualContract.StartDate__c = fechas;
        ActualContract.Status__c = 'Aprovado';
        ActualContract.Account__c = acc.id;
        date fecha = Date.newInstance(Integer.ValueOf(2014), 1, 1);
        ActualContract.LAT_BR_RealValidityDate__c = fecha;
        ActualContract.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract__c' + 'Ativacao_de_contrato');
        insert ActualContract; 

        Case caso = new Case();
        caso.AccountId = acc.id;       
        caso.RecordTypeId = Global_RecordTypeCache.getRtId('Case' + 'Alteracao_cadastro_de_clientes');
        caso.LAT_Contract__c = ActualContract.id ;
        insert caso;
        
     
        Test.startTest();    
        ApexPages.StandardController sc = new ApexPages.StandardController(caso);       
        LAT_BR_VFC09_CloseCaseVFextension instanceTest = new LAT_BR_VFC09_CloseCaseVFextension(sc);
        instanceTest.actionsButtom();

    
        Test.stopTest();
    
    }
    //MIGRATED 21/11/2016
    static testMethod void myUnitTestLATCase() { 
       UDC__c udc = new UDC__c(
           CodProd__c = '01',
           CodUs__c = '01',
           CodDefUsuario__c = '1',
           Internal_Id__c = '01-01',
           RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
       );
       
       insert udc;
       
       User us = [SELECT Id, C_digo_JDE__c FROM User WHERE Id =: userInfo.getUserId()];
       
       us.C_digo_JDE__c = '7';
       
       update us;
        
        Account acc = new Account(
            CNPJ__c = '54651716001150',
            Name = 'testAcco',
            Overdue__c = true,
            Type = 'On_Trade',
            Corporate_Name__c = 'test92569',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c = 'test0',
            Shipping_Neighbourhood__c = 'test3',
            Revenue_Neighbourhood__c = 'test2',
            Billing_Neighbourhood__c ='test1',
            Shipping_Country__c ='test4',
            Revenue_Country__c ='test5',
            Billing_Country__c ='test8',
            Status__c = 'Cliente cadastrado no JDE',
            Client_code_AN8__c = '0',
            Rating_segmentation_targert_market__c = 'Mainstream',
            LAT_BR_RegionalClientOnPremise__c = 'REG MT',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'),
            Segmentation_Type_on_trade__c = 'Mainstream',
            Regional__c = udc.Id,
            Regional_Manager__c = us.Id
        );
          
        insert acc;
        
        LAT_Contract__c ActualContract = new LAT_Contract__c();        
        date fechas = Date.newInstance(Integer.ValueOf(2013), 1, 1);
        ActualContract.StartDate__c = fechas;
        ActualContract.Status__c = 'Aprovado';
        ActualContract.Account__c = acc.id;
        date fecha = Date.newInstance(Integer.ValueOf(2014), 1, 1);
        ActualContract.LAT_BR_RealValidityDate__c = fecha;
        ActualContract.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract__c' + 'Ativacao_de_contrato');
        insert ActualContract;

        
        

        LAT_Case__c caso = new LAT_Case__c();
        caso.LAT_Account__c = acc.id;       
        caso.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Case__c' + 'Alteracao_cadastro_de_clientes');
        caso.LAT_Contract__c = ActualContract.id ;
        insert caso;
        
        Test.startTest();    
        Utils.setMigrationDoneTest(true);  
        ApexPages.StandardController sc = new ApexPages.StandardController(caso);       
        LAT_BR_VFC09_CloseLATCaseVFextension instanceTest = new LAT_BR_VFC09_CloseLATCaseVFextension(sc);
        instanceTest.actionsButtom();     

        LAT_Solution__c sol = new LAT_Solution__c();
        sol.LAT_SolutionName__c = 'Test';

        ApexPages.StandardController sc2 = new ApexPages.StandardController(caso); 
        ApexPages.currentPage().getParameters().put('id', caso.id);      
        LAT_VFC_CloseCase pag = new LAT_VFC_CloseCase(sc2);
        pag.latSolution = sol;
        pag.closeCase();
        Test.stopTest();
    
    }
}