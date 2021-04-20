/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:09/10/2013    *
*******************************************************************************/

@istest
public with sharing class LAT_MX_AP02_AccountWOS_TEST {

   static testMethod void unitTest1() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        try{insert acc;} catch(exception e){}  
        
        test.startTest();     

        acc.LAT_MX_APStep__c = 4;
        try{update acc;} catch(exception e){}
        acc.LAT_MX_APStep__c = 5;
        try{update acc;} catch(exception e){}
        
        test.stopTest();  
   
   }
   
   static testMethod void unitTest2() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        try{insert acc;} catch(exception e){}
        
        LAT_MX_PMN_PromissoryNote__c prom = new LAT_MX_PMN_PromissoryNote__c(
            LAT_MX_Executor__c = acc.Id,
            LAT_MX_Amount__c = 1000,
            LAT_MX_DueDate__c = date.today(),
            LAT_MX_Consignature1__c = 'test',
            LAT_MX_LegalRepresentative__c = 'test'       
        );
        
        try{insert prom;} catch(exception e){}
        
        test.startTest();
        
        acc.LAT_MX_APStep__c = 2;
        try{update acc;} catch(exception e){}
        acc.LAT_MX_APStep__c = 4;
        try{update acc;} catch(exception e){}
        
        test.stopTest(); 
   
   }
   
   static testMethod void unitTest3() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        try{insert acc;} catch(exception e){}
        
        LAT_MX_PMN_PromissoryNote__c prom = new LAT_MX_PMN_PromissoryNote__c(
            LAT_MX_Executor__c = acc.Id,
            LAT_MX_Amount__c = 1000,
            LAT_MX_DueDate__c = date.today(),
            LAT_MX_Consignature1__c = 'test',
            LAT_MX_LegalRepresentative__c = 'test'       
        );
        
        try{insert prom;} catch(exception e){}
        
        test.startTest();

        acc.LAT_MX_APStep__c = 5;
        try{update acc;} catch(exception e){}
        acc.LAT_MX_APStep__c = 7;
        try{update acc;} catch(exception e){}
        
        test.stopTest();
   
   }
   
   static testMethod void unitTest4() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        try{insert acc;} catch(exception e){}
        
        LAT_MX_PMN_PromissoryNote__c prom = new LAT_MX_PMN_PromissoryNote__c(
            LAT_MX_Executor__c = acc.Id,
            LAT_MX_Amount__c = 1000,
            LAT_MX_DueDate__c = date.today(),
            LAT_MX_Consignature1__c = 'test',
            LAT_MX_LegalRepresentative__c = 'test'       
        );
        
        try{insert prom;} catch(exception e){}
        
        test.startTest();

        acc.LAT_MX_APStep__c = 7;
        try{update acc;} catch(exception e){}
        acc.LAT_MX_APStep__c = 8;
        try{update acc;} catch(exception e){}
        
        test.stopTest();
   
   }
   
   static testMethod void unitTest5() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        try{insert acc;} catch(exception e){}
        
        test.startTest();
                
        acc.LAT_MX_APStep__c = 0;
        try{update acc;} catch(exception e){}
        
        test.stopTest();

   
   }
   
   static testMethod void unitTest6() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_APStep__c = 4,
            RecordTypeId = rtOffMX
        );
        try{insert acc;} catch(exception e){}
        
        test.startTest();
                
        acc.LAT_MX_APStep__c = 0;
        try{update acc;} catch(exception e){}
        
        test.stopTest();
   }

   static testMethod void unitTest7() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        try{insert acc;} catch(exception e){}
        
        LAT_MX_PMN_PromissoryNote__c prom = new LAT_MX_PMN_PromissoryNote__c(
            LAT_MX_Executor__c = acc.Id,
            LAT_MX_Amount__c = 1000,
            LAT_MX_DueDate__c = date.today(),
            LAT_MX_Consignature1__c = 'test',
            LAT_MX_LegalRepresentative__c = 'test'       
        );
        
        try{insert prom;} catch(exception e){}
        
        test.startTest();
        
        String ProfileId = userinfo.getProfileId();
        
        acc.LAT_MX_APStep__c = 4;
        try{update acc;} catch(exception e){}
        acc.LAT_MX_APStep__c = 5;
        try{update acc;} catch(exception e){}
        
        test.stopTest();
   
   }
   
   static testMethod void unitTest8() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        String rtUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard');
        
        List<UDC__c> listUDC = new List<UDC__c>();
        
        UDC__c udcFiscalRate = new UDC__c(
            Name = 'testFiscalRate',
            Internal_Id__c = '1',
            CodProd__c = 'CRM',
            CodUs__c = 'TX',
            RecordTypeId = rtUDC          
        ); 
        listUDC.add(udcFiscalRate);
        
        UDC__c udcChain = new UDC__c(
            Name = 'testChain',
            Internal_Id__c = '2',
            CodProd__c = '01',
            CodUs__c = '10',
            RecordTypeId = rtUDC          
        );
        listUDC.add(udcChain);
        
        UDC__c udcGroup = new UDC__c(
            Name = 'testGroup',
            Internal_Id__c = '3',
            CodProd__c = '01',
            CodUs__c = '09',
            RecordTypeId = rtUDC          
        );
        listUDC.add(udcGroup);
        
        try{insert listUDC;} catch(exception e){}
                
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'DFR',
            Segmentation_Type_on_trade__c = 'D1',
            RecordTypeId = rtOffMX,
            LAT_MX_BreakDownIEPS__c = 'Yes',
            LAT_MX_FiscalRate__c = udcFiscalRate.Id,
            LAT_MX_Chain__c = udcChain.Id,
            LAT_MX_Group__c = udcGroup.Id,
            LAT_MX_SupplierNumber__c = '1'
        );
        try{insert acc;} catch(exception e){}        

        acc.LAT_MX_APStep__c = 4;
        try{update acc;} catch(exception e){}
        
        LAT_MX_PMN_PromissoryNote__c prom = new LAT_MX_PMN_PromissoryNote__c(
            LAT_MX_Executor__c = acc.Id,
            LAT_MX_Amount__c = 1000,
            LAT_MX_DueDate__c = date.today(),
            LAT_MX_Consignature1__c = 'test',
            LAT_MX_LegalRepresentative__c = 'test'       
        );
        
        try{insert prom;} catch(exception e){}
        
        String userName = UserInfo.getUserName();
        
        CS006_DefaultUsers__c CsUserId = new CS006_DefaultUsers__c(
          Name = 'test',
          LAT_MX_UserName3__c = userName
        );
        
        try{insert CsUserId;} catch(exception e){}
        
        test.startTest();
        
        try{
        
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(acc.Id);
    
            Approval.ProcessResult result = Approval.process(req1);   
            
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
    
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
    
            req2.setWorkitemId(newWorkItemIds.get(0));
    
            Approval.ProcessResult result2 =  Approval.process(req2);
        
        }catch(exception e){
        }   
        
        acc.LAT_MX_APStep__c = 5;
        try{update acc;} catch(exception e){}
        
        test.stopTest();
   
   }   

   static testMethod void unitTest9() {

        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX,
            LAT_MX_APStep__c = 4
        );
        try{insert acc;} catch(exception e){}  
        
        test.startTest();      

        acc.LAT_MX_APStep__c = 0;
        try{update acc;} catch(exception e){}
        
        test.stopTest();
   
   } 

}