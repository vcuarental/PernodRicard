@isTest
private class ASI_TH_CRM_TestClass1{
    
    static testMethod void testOutletActualOfftakeMassEdit(){
        Account account = new Account(Name='testAccount');
        insert account;
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
        customer.ASI_CRM_Account__c = account.id;
        customer.ASI_CRM_Trusted_Offtake_SIT__c = 'Total Offtake';
        customer.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Outlet');
        insert customer;
        
        ASI_MFM_Sub_brand__c  subBrand = new ASI_MFM_Sub_brand__c(Name='testSubBrand');
        insert subBrand;
        
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = new ASI_TH_CRM_Actual_Offtake__c(ASI_TH_CRM_From_Wholesaler__c=account.Id,ASI_TH_CRM_Outlet__c=account.Id,ASI_TH_CRM_Sub_brand__c=subBrand.Id,ASI_TH_CRM_Offtake_G_L_Date__c=Date.today());
        insert actualOfftake;
        
        Test.StartTest();
        ApexPages.currentPage().getParameters().put('id', account.Id);
        ApexPages.standardController stdcontroller = new ApexPages.standardController(account);
        
        ASI_TH_CRM_OutletActualOfftake_MassEdit controller = new ASI_TH_CRM_OutletActualOfftake_MassEdit(stdcontroller);
        controller.ao_fromDate = actualOfftake;
        controller.ao_toDate = actualOfftake;
        
        controller.search();
        controller.save();
        controller.Next();
        controller.Previous();
        controller.Beginning();
        controller.End();
        Test.StopTest();
    }
    
    static testMethod void testStockInTradeDetailMassEdit(){
        Account account = new Account(Name='testAccount');
        insert account;
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
        customer.ASI_CRM_Account__c = account.id;
        customer.ASI_CRM_Trusted_Offtake_SIT__c = 'Total Offtake';
        customer.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Outlet');
        insert customer;
        
        ASI_MFM_Sub_brand__c  subBrand = new ASI_MFM_Sub_brand__c(Name='testSubBrand');
        insert subBrand;
        
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName='ASI_TH_CRM_WS_Stock_In_Trade_Detail'];
        
        ASI_TH_CRM_Offtake_Stock_In_Trade__c stockInTrade = new ASI_TH_CRM_Offtake_Stock_In_Trade__c(ASI_TH_CRM_Account__c=account.Id);
        insert stockInTrade;
        
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetail = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account__c=account.Id,ASI_TH_CRM_Sub_brand__c=subBrand.Id,ASI_TH_CRM_SIT__c=stockInTrade.Id,RecordTypeId=recordType.Id,ASI_TH_CRM_Date__c=Date.today());
        insert stockInTradeDetail;        
        
        Test.StartTest();
        ApexPages.currentPage().getParameters().put('id', account.Id);
        ApexPages.standardController stdcontroller = new ApexPages.standardController(account);
        
        ASI_TH_CRM_StockInTradeDetail_MassEdit controller = new ASI_TH_CRM_StockInTradeDetail_MassEdit(stdcontroller);
        controller.stockInTrade = stockInTrade;
        controller.st_fromDate = stockInTradeDetail;
        controller.st_toDate = stockInTradeDetail;
        
        controller.search();
        controller.save();
        Test.StopTest();
    }
    
    static testMethod void testRSPMassEdit(){
        ASI_MFM_Sub_brand__c  subBrand = new ASI_MFM_Sub_brand__c(Name='testSubBrand', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_TH_CRM_Sub_brand'));
        insert subBrand;
        
        ASI_TH_CRM_RSP__c rsp_fromDate = new ASI_TH_CRM_RSP__c(ASI_TH_CRM_Sub_Brand__c=subBrand.Id,ASI_TH_CRM_Date__c=Date.today().addMonths(-1), RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_RSP__cASI_TH_CRM_RSP'));
        insert rsp_fromDate;
        
        ASI_TH_CRM_RSP__c rsp_toDate = new ASI_TH_CRM_RSP__c(ASI_TH_CRM_Sub_Brand__c=subBrand.Id,ASI_TH_CRM_Date__c=Date.today(), RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_RSP__cASI_TH_CRM_RSP'));
        insert rsp_toDate;                
        
        Test.StartTest();
        ApexPages.standardController stdcontroller = new ApexPages.standardController(rsp_fromDate);
        
        ASI_TH_CRM_RSP_MassEdit controller = new ASI_TH_CRM_RSP_MassEdit(stdcontroller);
        controller.rsp_fromDate = rsp_fromDate;
        controller.rsp_toDate = rsp_toDate;
        
        controller.search();
        controller.save();
        controller.copy();
        controller.Next();
        controller.Previous();
        controller.Beginning();
        controller.End();       
        Test.StopTest();
    }      
    
    static testMethod void testSITDetailMT1st(){
        Account account = new Account(Name='testAccount');
        insert account;
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
        customer.ASI_CRM_Account__c = account.id;
        customer.ASI_CRM_Trusted_Offtake_SIT__c = 'Total Offtake';
        customer.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Outlet');
        insert customer;
        
        ASI_MFM_Sub_brand__c  subBrand = new ASI_MFM_Sub_brand__c(Name='testSubBrand');
        insert subBrand;
        
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName='ASI_TH_CRM_MT_Stock_In_Trade_Detail'];
        
        ASI_TH_CRM_Offtake_Stock_In_Trade__c stockInTrade = new ASI_TH_CRM_Offtake_Stock_In_Trade__c(ASI_TH_CRM_Account__c=account.Id);
        insert stockInTrade;
        
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetail = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account__c=account.Id,ASI_TH_CRM_Sub_brand__c=subBrand.Id,ASI_TH_CRM_SIT__c=stockInTrade.Id,RecordTypeId=recordType.Id,ASI_TH_CRM_Date__c=Date.today(),ASI_TH_CRM_Ending_Stock_Draft__c=0);
        insert stockInTradeDetail;        
        
        Test.StartTest();
        ApexPages.currentPage().getParameters().put('id', account.Id);
        ApexPages.standardController stdcontroller = new ApexPages.standardController(account);
        
        ASI_TH_CRM_SITDetail_MT1st_MassEdit controller = new ASI_TH_CRM_SITDetail_MT1st_MassEdit(stdcontroller);
        controller.stockInTrade = stockInTrade;
        controller.st_fromDate = stockInTradeDetail;
        controller.st_toDate = stockInTradeDetail;
        
        controller.search();
        controller.save();
        Test.StopTest();
    }
    
    static testMethod void testSITDetailMT2nd(){
        Account account = new Account(Name='testAccount');
        insert account;
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
        customer.ASI_CRM_Account__c = account.id;
        customer.ASI_CRM_Trusted_Offtake_SIT__c = 'Total Offtake';
        customer.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Outlet');
        insert customer;
        
        ASI_MFM_Sub_brand__c  subBrand = new ASI_MFM_Sub_brand__c(Name='testSubBrand');
        insert subBrand;
        
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName='ASI_TH_CRM_MT_Stock_In_Trade_Detail'];
        
        ASI_TH_CRM_Offtake_Stock_In_Trade__c stockInTrade = new ASI_TH_CRM_Offtake_Stock_In_Trade__c(ASI_TH_CRM_Account__c=account.Id);
        insert stockInTrade;
        
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetail = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account__c=account.Id,ASI_TH_CRM_Sub_brand__c=subBrand.Id,ASI_TH_CRM_SIT__c=stockInTrade.Id,RecordTypeId=recordType.Id,ASI_TH_CRM_Date__c=Date.today(),ASI_TH_CRM_Total_Offtake_Final__c=0);
        insert stockInTradeDetail;        
        
        Test.StartTest();
        ApexPages.currentPage().getParameters().put('id', account.Id);
        ApexPages.standardController stdcontroller = new ApexPages.standardController(account);
        
        ASI_TH_CRM_SITDetail_MT2nd_MassEdit controller = new ASI_TH_CRM_SITDetail_MT2nd_MassEdit(stdcontroller);
        controller.stockInTrade = stockInTrade;
        controller.st_fromDate = stockInTradeDetail;
        controller.st_toDate = stockInTradeDetail;
        
        controller.search();
        controller.save();
        Test.StopTest();
    }
    
    static testMethod void testSITDetailOTFinalInitCtrl(){     
        Test.StartTest();
        ASI_TH_CRM_SITDetailOTFinalInitCtrl.initOfftakeTotal();
        Test.StopTest();
    }
    
    static testMethod void testScheduler(){
        Account account = new Account(Name='testAccount');
        insert account;
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
        customer.ASI_CRM_Account__c = account.id;
        customer.ASI_CRM_Trusted_Offtake_SIT__c = 'Total Offtake';
        customer.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Outlet');
        insert customer;
        
        ASI_MFM_Sub_brand__c  subBrand = new ASI_MFM_Sub_brand__c(Name='testSubBrand');
        insert subBrand;
        
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName='ASI_TH_CRM_WS_Stock_In_Trade_Detail'];   
        
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetailThis = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account__c=account.Id,ASI_TH_CRM_Sub_brand__c=subBrand.Id,RecordTypeId=recordType.Id,ASI_TH_CRM_Date__c=Date.today(),ASI_TH_CRM_Total_Offtake_Final__c=0);
        insert stockInTradeDetailThis;
        
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetailLast = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account__c=account.Id,ASI_TH_CRM_Sub_brand__c=subBrand.Id,RecordTypeId=recordType.Id,ASI_TH_CRM_Date__c=Date.today().addMonths(-1));
        insert stockInTradeDetailLast;
        
        RecordType recordTypeRSP = [SELECT Id FROM RecordType WHERE DeveloperName='ASI_TH_CRM_RSP'];
        
        ASI_TH_CRM_RSP__c rsp = new ASI_TH_CRM_RSP__c(ASI_TH_CRM_Sub_Brand__c=subBrand.Id,RecordTypeId=recordTypeRSP.Id,ASI_TH_CRM_Date__c=Date.today().addMonths(-1));
        insert rsp; 
        
        ASI_TH_CRM_Offtake_Stock_In_Trade__c stockInTrade = new ASI_TH_CRM_Offtake_Stock_In_Trade__c(ASI_TH_CRM_Account__c=account.Id);
        insert stockInTrade;
        
        RecordType recordTypeMT = [SELECT Id FROM RecordType WHERE DeveloperName='ASI_TH_CRM_MT_Stock_In_Trade_Detail'];
        
        RecordType recordTypeTemp = [SELECT Id FROM RecordType WHERE DeveloperName='ASI_TH_CRM_MT_SITD_Temp'];
        
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetailTemp = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account_2nd_Upload__c=account.Id,ASI_TH_CRM_Sub_brand__c=subBrand.Id,RecordTypeId=recordTypeTemp.Id,ASI_TH_CRM_Date__c=Date.today(),ASI_TH_CRM_Total_Offtake_Final__c=0);
        insert stockInTradeDetailTemp; 
        
        ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c stockInTradeDetailMT = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account__c=account.Id,ASI_TH_CRM_Sub_brand__c=subBrand.Id,RecordTypeId=recordTypeMT.Id,ASI_TH_CRM_Date__c=Date.today(),ASI_TH_CRM_Total_Offtake_Final__c=0);
        insert stockInTradeDetailMT;                 
        
        //20170831 Introv
        
        List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> tmpList = new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
        tmpList.add(new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account__c=account.Id
                                                                    , ASI_TH_CRM_Sub_brand__c=subBrand.Id
                                                                    , RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_TH_CRM_WS_Stock_In_Trade_Detail')
                                                                    , ASI_TH_CRM_Date__c=Date.today().addMonths(-1)
                                                                    , ASI_TH_CRM_Total_Offtake_Final__c=100
                                                                    , ASI_TH_CRM_Ending_Stock_Final__c = 100
                                                                    , ASI_TH_CRM_SIT__c = stockInTrade.id
                                                                   ));
        tmpList.add(new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account__c=account.Id
                                                                    , ASI_TH_CRM_Sub_brand__c=subBrand.Id
                                                                    , RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_TH_CRM_MT_Stock_In_Trade_Detail')
                                                                    , ASI_TH_CRM_Date__c=Date.today().addMonths(-1)
                                                                    , ASI_TH_CRM_Total_Offtake_Final__c=0
                                                                    , ASI_TH_CRM_Ending_Stock_Final__c = 100
                                                                    , ASI_TH_CRM_SIT__c = stockInTrade.id
                                                                   ));
        tmpList.add(new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c(ASI_TH_CRM_Account__c=account.Id
                                                                    , ASI_TH_CRM_Sub_brand__c=subBrand.Id
                                                                    , RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_TH_CRM_MT_Stock_In_Trade_Detail')
                                                                    , ASI_TH_CRM_Date__c=Date.today().addMonths(-1)
                                                                    , ASI_TH_CRM_Total_Offtake_Final__c=100
                                                                    , ASI_TH_CRM_Ending_Stock_Final__c = 100
                                                                    , ASI_TH_CRM_SIT__c = stockInTrade.id
                                                                   ));
        insert tmpList;
        update tmpList;
        
        Test.StartTest();
        
        string CORN_EXP = '0 0 0 1 4 ?';
        
        system.schedule('Stock-In-Trade Detail batch job', CORN_EXP, new ASI_TH_CRM_SITDetail_Init_Schedule());
        
        system.schedule('RSP batch job', CORN_EXP, new ASI_TH_CRM_RSPGenarateScheduler());
        
        system.schedule('Stock-In-Trade Detail MT Offtake Final init batch job', CORN_EXP, new ASI_TH_CRM_SITDetailOTFinalInitScheduler());
        
        //20170831 Introv
        database.executebatch(new ASI_TH_CRM_SITDetail_Init_Batch());
        
        Test.StopTest();
    }   
}