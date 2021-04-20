@isTest
public class ASI_CRM_CN_Account_Test {
    
    
    static testMethod void ASI_CRM_CN_AccountChartCtrl_TEST() {
        
        Id rtWS = Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN');
        Id rtOutlet = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet');
        
        list<Account> accs = new list<Account>();
        accs.add(new Account(RecordTypeId=rtWS, Name='TEST0'));
        accs.add(new Account(RecordTypeId=rtOutlet, Name='TEST1'));
        insert accs;
        
        ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c ();
        insert subBrand;
        
        list<ASI_CRM_Subbrand_Volume__c> svols = new list<ASI_CRM_Subbrand_Volume__c>();
        svols.add(new ASI_CRM_Subbrand_Volume__c(
            // ASI_CRM_Account__c = accs[0].Id,
            ASI_CRM_Subbrand__c = subBrand.Id,
            ASI_CRM_End_Date__c = system.today().addMonths(-1),
            ASI_CRM_PR_Direct__c = 1, ASI_CRM_T1_Depletion_GS__c = 1, ASI_CRM_PR_SHIPMENT__c = 1, ASI_CRM_Offtake__c = 1));
        svols.add(new ASI_CRM_Subbrand_Volume__c(
            //  ASI_CRM_Account__c = accs[1].Id,
            ASI_CRM_Subbrand__c = subBrand.Id,
            ASI_CRM_End_Date__c = system.today().addMonths(-1),
            ASI_CRM_PR_Direct__c = 1, ASI_CRM_T1_Depletion_GS__c = 1, ASI_CRM_PR_SHIPMENT__c = 1, ASI_CRM_Offtake__c = 1));
        insert svols;
        
        list<ASI_CRM_WS_Inv_History__c> ihs = new list<ASI_CRM_WS_Inv_History__c>();
        ihs.add(new ASI_CRM_WS_Inv_History__c(
            ASI_CRM_End_Date__c = system.today().addMonths(-1),
            ASI_CRM_Year__c = '2014', ASI_CRM_Month__c = '1',
            ASI_CRM_Volume__c = 1));
        insert ihs;
        
        ApexPages.StandardController scon0 = new ApexPages.StandardController(accs[0]);
        ApexPages.StandardController scon1 = new ApexPages.StandardController(accs[1]);
        
        test.startTest();
        
        { //Data
            ASI_CRM_CN_AccountChartCtrl.Data d = new ASI_CRM_CN_AccountChartCtrl.Data('TEST', 0);
            d.month = d.month;
            d.data = d.data;
        }
        
        { // Wholesaler
            ASI_CRM_CN_AccountChartCtrl con = new ASI_CRM_CN_AccountChartCtrl(scon0);
        }
        
        { // outlet
            ASI_CRM_CN_AccountChartCtrl con = new ASI_CRM_CN_AccountChartCtrl(scon1);
        }
        
        test.stopTest();
        
    }
}