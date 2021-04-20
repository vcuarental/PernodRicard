/******************************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck-Tomás Etchegaray  Date:21/03/2013    *
*******************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/


@istest
public with sharing class AP01_Account_AR_TEST {

   static testMethod void unitTest() {
    
                 
        Utils.setMigrationDoneTest(false);
 		
 		// Cria uma UDC_Tabela
		UDC__c UdcTest = new UDC__c();
		UdcTest.CodUs__c = '03';
		UdcTest.CodProd__c = '01';
		UdcTest.Name = 'KA';
		UdcTest.Internal_Id__c = '00-CT';
		UdcTest.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');
		//Database.insert(UdcTest);
		try{Database.insert(UdcTest);}catch(Exception e){}
		                                     
        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'), 
            CNPJ__c = '20354266645',
            Name = 'testAccount',
            Overdue__c = false,
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Revenue_City__c = UdcTest.id,
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            Status__c = 'Em análise - Crédito e Cobrança'
        );
        
        //insert acc;
        insert acc;//}catch(Exception e){}
        system.Test.startTest();   
        acc.overdue__c = true;
        acc.Client_code_AN8__c = '0';
        acc.Status__c = 'Em aprovação - Financeiro';
        
        //update acc;
        update acc;//}catch(Exception e){}
        
        system.Test.stopTest();                
        
    }
    
    static testMethod void unitTest2() {
   
        system.Test.startTest(); 
        Utils.setMigrationDoneTest(false);     
        
        // Cria uma UDC_Tabela
		UDC__c UdcTest = new UDC__c();
		UdcTest.CodUs__c = '03';
		UdcTest.CodProd__c = '01';
		UdcTest.Name = 'KA';
		UdcTest.Internal_Id__c = '00-CT';
		UdcTest.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');
		//Database.insert(UdcTest);
		try{Database.insert(UdcTest);}catch(Exception e){} 

                // Cria uma UDC_Tabela
        UDC__c UdcTest2 = new UDC__c();
        UdcTest2.CodUs__c = 'PY';
        UdcTest2.CodProd__c = '00';
        UdcTest2.Name = 'Blanco';
        UdcTest2.Internal_Id__c = '6--00-PY';
        UdcTest2.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');
        //Database.insert(UdcTest);
        try{Database.insert(UdcTest2);}catch(Exception e){}          
        
        Account acc2 = new Account(
            CNPJ__c = '20354266645',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_3_OnTrade_ARG'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Revenue_City__c = UdcTest.id,
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test'
        );       
        
        insert acc2;//}catch(Exception e){}
        
        system.Test.stopTest();
        
    }
   static testMethod void unitTestB() {
            
        Utils.setMigrationDoneTest(true);
        
        // Cria uma UDC_Tabela
        UDC__c UdcTest = new UDC__c();
        UdcTest.CodUs__c = '03';
        UdcTest.CodProd__c = '01';
        UdcTest.Name = 'KA';
        UdcTest.Internal_Id__c = '00-CT';
        UdcTest.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');
        //Database.insert(UdcTest);
        try{Database.insert(UdcTest);}catch(Exception e){}
        UDC__c UdcTest2 = new UDC__c();
        UdcTest2.CodUs__c = 'PY';
        UdcTest2.CodProd__c = '00';
        UdcTest2.Name = 'Blanco';
        UdcTest2.Internal_Id__c = '6--00-PY';
        UdcTest2.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');
        //Database.insert(UdcTest);
        try{Database.insert(UdcTest2);}catch(Exception e){}                             
        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'), 
            CNPJ__c = '20354266645',
            Name = 'testAccount',
            Overdue__c = false,
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Revenue_City__c = UdcTest.id,
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test',
            Status__c = 'Em análise - Crédito e Cobrança'
        );
        
        //insert acc;
        insert acc;//}catch(Exception e){}
            
        system.Test.startTest();            
        Utils.setMigrationDoneTest(true);
        
        acc.overdue__c = true;
        acc.Client_code_AN8__c = '0';
        acc.Status__c = 'Em aprovação - Financeiro';
        
        //update acc;
        update acc;//}catch(Exception e){}
        
        system.Test.stopTest();                
        
    }
    
    static testMethod void unitTest2B() {
   
        system.Test.startTest(); 
        Utils.setMigrationDoneTest(true);     
        
        // Cria uma UDC_Tabela
        UDC__c UdcTest = new UDC__c();
        UdcTest.CodUs__c = '03';
        UdcTest.CodProd__c = '01';
        UdcTest.Name = 'KA';
        UdcTest.Internal_Id__c = '00-CT';
        UdcTest.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');
        //Database.insert(UdcTest);
        try{Database.insert(UdcTest);}catch(Exception e){} 
        UDC__c UdcTest2 = new UDC__c();
        UdcTest2.CodUs__c = 'PY';
        UdcTest2.CodProd__c = '00';
        UdcTest2.Name = 'Blanco';
        UdcTest2.Internal_Id__c = '6--00-PY';
        UdcTest2.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');
        //Database.insert(UdcTest);
        try{Database.insert(UdcTest2);}catch(Exception e){}                     
        
        Account acc2 = new Account(
            CNPJ__c = '20354266645',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_3_OnTrade_ARG'),
            Name = 'testAccount2',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Revenue_City__c = UdcTest.id,
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Billing_Country__c ='test'
        );       
        
        insert acc2;//}catch(Exception e){}
        
        system.Test.stopTest();
        
    }
    
    
}