@isTest
private class ASI_CRM_VN_OutletActualOfftkMassEditTest{

    static testMethod void testOutletActualOfftakeMassSearchEdit(){
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList ;
        String RecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().
                                                                                     get('Outlet (VN)').getRecordTypeId();
        
        Account account = ASI_CRM_VN_TestDataFactory.getAccount('testAccount');
        insert account;
        
        ASI_HK_CRM_Running_Number__c runningInstance = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,date.today().year());
        insert runningInstance;      
        
        ASI_CRM_AccountsAdditionalField__c customerInstance = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer);  
        insert customerInstance;

        ASI_MFM_Sub_brand__c  subBrand = ASI_CRM_VN_TestDataFactory.getSubBrand('testSubBrand');
        insert subBrand;
        
        actualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>{ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                               customerInstance.Id, 
                                                                                                               subBrand.Id, 
                                                                                                               Date.today(), 
                                                                                                               FALSE),
                                                                   ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                               customerInstance.Id, 
                                                                                                               subBrand.Id, 
                                                                                                               Date.today(), 
                                                                                                               FALSE)

                                                                    };
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                 null, 
                                                                                                 subBrand.Id, 
                                                                                                 Date.today(), 
                                                                                                 FALSE);
        insert actualOfftake;
                                                            
        insert actualOfftakeList ;
        
        ApexPages.currentPage().getParameters().put('id', customerInstance.Id);
        ApexPages.standardController stdcontroller = new ApexPages.standardController(customerInstance);
        
        ASI_CRM_VN_OutletActualOfftake_MassEdit controller = new ASI_CRM_VN_OutletActualOfftake_MassEdit(stdcontroller);
        controller.ao_fromDate = actualOfftakeList[0];
        controller.ao_toDate = actualOfftakeList[0];
        
        Test.StartTest();

        controller.search();
        //controller.save();
       // controller.Next();
      //  controller.Previous();
      //  controller.Beginning();
       // controller.End();
        Test.StopTest();
        
        system.assert(controller.totalSize == 2);
        system.assert(controller.actualOffTakes.size() == 2);
        system.assert(controller.totalSize == 2);
        system.assert(controller.disablePrevious);
        system.assert(controller.disableNext);
        
   }
   
    static testMethod void outletActualOfftakeMassEditSaveTest(){
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList ;

        String RecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().
                                                                                     get('Outlet (VN)').getRecordTypeId();
        
        Account account = ASI_CRM_VN_TestDataFactory.getAccount('TESTACCOUNT');
        insert account;
        
        ASI_HK_CRM_Running_Number__c runningInstance = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,date.today().year());
        insert runningInstance;      
        
        ASI_CRM_AccountsAdditionalField__c customerInstance = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer);  
        insert customerInstance;

        ASI_MFM_Sub_brand__c  subBrand =  ASI_CRM_VN_TestDataFactory.getSubBrand('testSubBrand');
        insert subBrand;
        
        
        
        actualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>{ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                               customerInstance.Id, 
                                                                                                               subBrand.Id, 
                                                                                                               Date.today(), 
                                                                                                               FALSE),
                                                                   ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                               customerInstance.Id, 
                                                                                                               subBrand.Id, 
                                                                                                               Date.today(), 
                                                                                                               FALSE)

                                                                    };
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                 null, 
                                                                                                 subBrand.Id, 
                                                                                                 Date.today(), 
                                                                                                 FALSE);
        insert actualOfftake;
                                                            
        insert actualOfftakeList ;
        
        ApexPages.currentPage().getParameters().put('id', customerInstance.Id);
        ApexPages.standardController stdcontroller = new ApexPages.standardController(customerInstance);
        
        ASI_CRM_VN_OutletActualOfftake_MassEdit controller = new ASI_CRM_VN_OutletActualOfftake_MassEdit(stdcontroller);
        controller.ao_fromDate = actualOfftakeList[0];
        controller.ao_toDate = actualOfftakeList[0];
        Datetime dt = datetime.newInstance(actualOfftakeList[0].ASI_TH_CRM_Offtake_G_L_Date__c.year(), 
                                           actualOfftakeList[0].ASI_TH_CRM_Offtake_G_L_Date__c.month(),
                                           actualOfftakeList[0].ASI_TH_CRM_Offtake_G_L_Date__c.day());
        controller.search();
        
        Test.StartTest();
        
        controller.results.get(account.Name).
                           get(subBrand.Name).
                           get(dt.format('MMM-yy')).quantity = 50;
                           
                       
        controller.save();
       // controller.Next();
      //controller.Previous();
      //  controller.Beginning();
       // controller.End();
        Test.StopTest();
        
        ASI_TH_CRM_Actual_Offtake__c updatedOffTake = [select Id,ASI_TH_CRM_Quantity__c 
                                                      from ASI_TH_CRM_Actual_Offtake__c 
                                                      where Id =: actualOfftakeList[0].Id];
        
        system.assert(controller.totalSize == 2);
        system.assert(controller.actualOffTakes.size() == 2);
        system.assertEquals(updatedOffTake.ASI_TH_CRM_Quantity__c, 50);
    
   }
   
    static testMethod void testOutletActualOfftakeMassEditForNextPrevious(){
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList ;
        String RecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().
                                                                                     get('Outlet (VN)').getRecordTypeId();
        
        Account account = ASI_CRM_VN_TestDataFactory.getAccount('testAccount');
        insert account;
        
        ASI_HK_CRM_Running_Number__c runningInstance = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,date.today().year());
        insert runningInstance;      
        
        ASI_CRM_AccountsAdditionalField__c customerInstance = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer);  
        insert customerInstance;

        ASI_MFM_Sub_brand__c  subBrand =  ASI_CRM_VN_TestDataFactory.getSubBrand('testSubBrand');
        insert subBrand;
        
        
        
        actualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>{ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                               customerInstance.Id, 
                                                                                                               subBrand.Id, 
                                                                                                               Date.today(), 
                                                                                                               FALSE),
                                                                   ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                               customerInstance.Id, 
                                                                                                               subBrand.Id, 
                                                                                                               Date.today(), 
                                                                                                               FALSE)

                                                                    };
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                 null, 
                                                                                                 subBrand.Id, 
                                                                                                 Date.today(), 
                                                                                                 FALSE);
        insert actualOfftake;
                                                            
        insert actualOfftakeList ;
        
        ApexPages.currentPage().getParameters().put('id', customerInstance.Id);
        ApexPages.standardController stdcontroller = new ApexPages.standardController(customerInstance);
        
        ASI_CRM_VN_OutletActualOfftake_MassEdit controller = new ASI_CRM_VN_OutletActualOfftake_MassEdit(stdcontroller);
        controller.ao_fromDate = actualOfftakeList[0];
        controller.ao_toDate = actualOfftakeList[0];
        controller.search();
        
        Test.StartTest();

        controller.Next();
        controller.Previous();
      //  controller.Beginning();
       // controller.End();
        Test.StopTest();
        
        system.assert(controller.totalSize == 2);
        system.assert(controller.actualOffTakes.size() == 2);
        system.assertEquals(controller.counter, 0);
        
   }
   

   static testMethod void testOutletActualOfftakeMassEditForStartEnd(){
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList ;
        String RecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().
                                                                                     get('Outlet (VN)').getRecordTypeId();
        
        Account account = ASI_CRM_VN_TestDataFactory.getAccount('testAccount');
        insert account;
        
        ASI_HK_CRM_Running_Number__c runningInstance = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,date.today().year());
        insert runningInstance;      
        
        ASI_CRM_AccountsAdditionalField__c customerInstance = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer);  
        insert customerInstance;

        ASI_MFM_Sub_brand__c  subBrand =  ASI_CRM_VN_TestDataFactory.getSubBrand('testSubBrand');
        insert subBrand;
        
        
        
        actualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>{ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                               customerInstance.Id, 
                                                                                                               subBrand.Id, 
                                                                                                               Date.today(), 
                                                                                                               FALSE),
                                                                   ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                               customerInstance.Id, 
                                                                                                               subBrand.Id, 
                                                                                                               Date.today(), 
                                                                                                               FALSE)

                                                                    };
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                 null, 
                                                                                                 subBrand.Id, 
                                                                                                 Date.today(), 
                                                                                                 FALSE);
        insert actualOfftake;
                                                            
        insert actualOfftakeList ;
        
        ApexPages.currentPage().getParameters().put('id', customerInstance.Id);
        ApexPages.standardController stdcontroller = new ApexPages.standardController(customerInstance);
        
        ASI_CRM_VN_OutletActualOfftake_MassEdit controller = new ASI_CRM_VN_OutletActualOfftake_MassEdit(stdcontroller);
        controller.ao_fromDate = actualOfftakeList[0];
        controller.ao_toDate = actualOfftakeList[0];
        controller.search();
        
        Test.StartTest();
        controller.End();
        controller.Beginning();
        Test.StopTest();
        
        system.assert(controller.totalSize == 2);
        system.assert(controller.actualOffTakes.size() == 2);
        system.assertEquals(controller.counter, 0);
        
   }
   
    static testMethod void testOutletActualOfftakeMassEditForNullCheck1(){
    
        String RecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().
                                                                                     get('Outlet (VN)').getRecordTypeId();
      

        ASI_HK_CRM_Running_Number__c runningInstance = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,date.today().year());
        insert runningInstance;      
        
        ASI_CRM_AccountsAdditionalField__c customerInstance = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer);  
        insert customerInstance;
        
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestDataFactory.getActualOffTake(null, 
                                                                                                 customerInstance.Id, 
                                                                                                 null, 
                                                                                                 Date.today(), 
                                                                                                 FALSE);
        insert actualOfftake;
        
        ApexPages.currentPage().getParameters().put('id', customerInstance.Id);
        ApexPages.standardController stdcontroller = new ApexPages.standardController(customerInstance);
        
        ASI_CRM_VN_OutletActualOfftake_MassEdit controller = new ASI_CRM_VN_OutletActualOfftake_MassEdit(stdcontroller);
        controller.ao_fromDate = actualOfftake;
        controller.ao_toDate = actualOfftake;
        controller.search();
        
        Test.StartTest();
        controller.search();
        Test.StopTest();
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean hasError = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Please select the Sub-Brand.')) hasError  = true;
        }
         system.assert(hasError);
        
   }
   
   static testMethod void testOutletActualOfftakeMassEditForNullCheck2(){
    
        String RecordTypeIdCustomer = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.getRecordTypeInfosByName().
                                                                                     get('Outlet (VN)').getRecordTypeId();
      
        Account account = ASI_CRM_VN_TestDataFactory.getAccount('testAccount');
        insert account;
        
        ASI_HK_CRM_Running_Number__c runningInstance = ASI_CRM_VN_TestDataFactory.getRunningNumber('ASI_CRM_VN_Customer_Code',1,'VN{000000}',1,date.today().year());
        insert runningInstance;      
        
        ASI_CRM_AccountsAdditionalField__c customerInstance = ASI_CRM_VN_TestDataFactory.getCustomer('customerTest','Presence','HEB',RecordTypeIdCustomer);  
        insert customerInstance;
        
        ASI_MFM_Sub_brand__c  subBrand =  ASI_CRM_VN_TestDataFactory.getSubBrand('testSubBrand');
        insert subBrand;
        
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestDataFactory.getActualOffTake(account.Id, 
                                                                                                 null, 
                                                                                                 subBrand.Id, 
                                                                                                 null, 
                                                                                                 FALSE);
        insert actualOfftake;
        
        ApexPages.currentPage().getParameters().put('id', customerInstance.Id);
        ApexPages.standardController stdcontroller = new ApexPages.standardController(customerInstance);
        
        ASI_CRM_VN_OutletActualOfftake_MassEdit controller = new ASI_CRM_VN_OutletActualOfftake_MassEdit(stdcontroller);
        controller.ao_fromDate = actualOfftake;
        controller.ao_toDate = actualOfftake;
        controller.search();
        
        Test.StartTest();
        controller.search();
        Test.StopTest();
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean hasError = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Please enter the From and To dates')) hasError  = true;
        }
         system.assert(hasError);
        
   }
   
}