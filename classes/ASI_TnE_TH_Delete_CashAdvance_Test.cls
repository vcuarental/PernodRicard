@IsTest
public class ASI_TnE_TH_Delete_CashAdvance_Test {
    @TestSetup static void setup() {

    }
        
    static testMethod void test_WebService() {
        ASI_TnE_Cash_Advance_Pre_Approval__c rec = new ASI_TnE_Cash_Advance_Pre_Approval__c();
        rec.ASI_TnE_Requested_Employee__c = UserInfo.getUserId();
        rec.ASI_TnE_Required_Currency__c = 'THB';
        rec.ASI_TnE_Required_Amount__c = 1000;
        rec.ASI_TnE_FX_Rate__c = 1;
        rec.ASI_TnE_Status__c = 'Draft';
        rec.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__c' + 'ASI_TnE_TH_Cash_Advance_Pre_approval');
        insert rec;
        
        System.Test.startTest();
        ASI_TnE_TH_Delete_CashAdvance_Ctrl.deleteCashAdv(rec.id);
        System.Test.stopTest();
    }
    static testMethod void test_webserviceException() {
        ASI_TnE_Cash_Advance_Pre_Approval__c rec2 = new ASI_TnE_Cash_Advance_Pre_Approval__c();
        rec2.ASI_TnE_Requested_Employee__c = UserInfo.getUserId();
        rec2.ASI_TnE_Required_Currency__c = 'THB';
        rec2.ASI_TnE_Required_Amount__c = 1000;
        rec2.ASI_TnE_FX_Rate__c = 1;
        rec2.ASI_TnE_Status__c = 'Draft';
        rec2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Cash_Advance_Pre_Approval__c' + 'ASI_TnE_TH_Cash_Advance_Pre_approval');
        insert rec2;   
        Id recId = rec2.Id;
        delete rec2;
        
        System.Test.startTest();
        try {
        	ASI_TnE_TH_Delete_CashAdvance_Ctrl.deleteCashAdv(recId);
        }catch(Exception e) {
            
        }
        System.Test.stopTest();
    }
}