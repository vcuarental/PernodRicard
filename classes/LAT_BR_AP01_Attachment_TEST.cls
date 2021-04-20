/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/
@isTest
public with sharing class LAT_BR_AP01_Attachment_TEST {
    
    @isTest   
    static void unitTest(){
        
        Account acc = new Account(
			RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'), 
			CNPJ__c = '54651716001150',
			Name = 'testAccount',
			Type = 'Prospect_ARG',
			Corporate_Name__c = 'test',
			Channel_Type__c = 'Direto',
			Sub_Channel__c = 'Delicatessen',
			AddressLine1_AR__c= 'test',
			Shipping_Neighbourhood__c = 'test',
			Revenue_Neighbourhood__c = 'test',
			Billing_Neighbourhood__c ='test',
			Shipping_Country__c ='test',
			Revenue_Country__c ='test',
			Client_code_AN8__c = '123697',
			Billing_Country__c ='test'
		);
		insert acc;  
        Test.startTest();
        Planejamento__c plan = new Planejamento__c(
            Name = 'Test', 
            M_s_de_Ref_rencia__c = 'Janeiro', 
            Ano_de_Referencia__c = '2013', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard')
        );
        insert plan;
        
        Visitas__c vis = new Visitas__c(
            Name = 'TEST', 
            Planejamento__c = plan.id, 
            Hora_da_Visita__c = '02:00', 
            Descrever_Motivo__c = 'Test', 
            Resumo_da_Visita__c = 'Test', 
            RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard') 
        );
        insert vis;
        
        Blob b = Blob.valueOf('Test Data'); 
        
        Attachment attach = new Attachment(
            ParentId = vis.Id,
            Name = 'test',
            Body = b
        );  
          
        try{insert attach;} catch(exception e){} 
        
        try{delete attach;} catch(exception e){} 
        
        test.stopTest();    
        
    }
    @isTest   
    static void unitTest2(){
        UDC__c regional = new UDC__c(      
            CodDefUsuario__c = '1',    
            CodProd__c     = '01',     
            CodUs__c     = '01',    
            Internal_Id__c   = '1-1-01-01',      
            RecordTypeId = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard')     
        );
        insert regional;  

        Account a = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
		a.RecordTypeId = Global_RecordTypeCache.getRtId('Account'+'LAT_On_Trade_Com_Pagamento');
        a.Rating_segmentation_targert_market__c = 'STANDARD';
        a.Client_code_AN8__c = '123451236';
        a.Regional__c = regional.Id;
        insert a;
        Test.startTest();
        LAT_Contract2__c con = getTestContract();
        insert con;

        Attachment att = new Attachment (Name = 'Acordo Comercial Test', ParentId = con.Id, Body = Blob.valueof('asdasd' ));
        insert att;
        update att;
        Test.stopTest();
    }

    public static LAT_Contract2__c getTestContract() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        LAT_Contract2__c con = new LAT_Contract2__c();
        con.TotalMoneyPerceivedValue__c = 1000.00;
        con.TotalMoneyPRBCost__c = 100.00;
        con.TotalProductsPerceivedValue__c = 10.00;
        con.TotalProductsPRBCost__c = 10.00;
        con.StartDate__c = Date.today().addDays(-105);
        con.EndDate__c = Date.today().addDays(105);
        con.Value__c = 100000.00;
        con.Account__c = acc.Id;
        return con;
      }
}