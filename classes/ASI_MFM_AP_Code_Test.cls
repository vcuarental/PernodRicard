@isTest
/****************************************
Test Classes:
1. ASI_MFM_AP_Code_TriggerClass
2. ASI_MFM_AP_Code_BeforeInsert
3. ASI_MFM_AP_Code_BeforeUpdate
****************************************/
public class ASI_MFM_AP_Code_Test{

    static testMethod void ASI_MFM_AP_Code_TriggerClass_TEST() {
        string TRRTid = Global_RecordTypeCache.getRTId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code');
        User user1 = [SELECT id FROM User WHERE Profile.Name != 'System Administrator' AND isActive=true  LIMIT 1];
        system.RunAs(user1){
            list<ASI_MFM_AP_Code__c > APCodeList = new list<ASI_MFM_AP_Code__c>();
            ASI_MFM_AP_Code__c apcode = new ASI_MFM_AP_Code__c(RecordTypeId=TRRTId,Name='Accrual (DF) 2099',ASI_MFM_AP_Code__c='2099', ASI_MFM_TR_Rec_Type__c='JDF');
            APCodeList.add(apcode);
            ASI_MFM_AP_Code__c apcode1 = new ASI_MFM_AP_Code__c(RecordTypeId=TRRTId,Name='Accrual 2099',ASI_MFM_AP_Code__c='20991', ASI_MFM_TR_Rec_Type__c='JDFs');
            APCodeList.add(apcode1);
            insert APCodeList;
            ASI_MFM_AP_Code__c apcode2 = [SELECT id, name, ASI_MFM_AP_Code__c FROM ASI_MFM_AP_Code__c WHERE id = :apcode.id];
            apcode2.name = 'test';
            //apcode2.ASI_MFM_AP_Code__c = 'test';
            update apcode;
        }
    }
}