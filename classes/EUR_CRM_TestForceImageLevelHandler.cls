@isTest
public class EUR_CRM_TestForceImageLevelHandler {
 
    public static testmethod void testing() {
        Id imageLevelRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Image_Level__c', 'EUR DK Image Level');
        
        EUR_CRM_Image_Level__c imageLevel1 = new EUR_CRM_Image_Level__c();
        imageLevel1.EUR_CRM_Name__c = 'Iconic';
        imageLevel1.RecordTypeId = imageLevelRecordTypeId;
        
        EUR_CRM_Image_Level__c imageLevel2 = new EUR_CRM_Image_Level__c();
        imageLevel1.EUR_CRM_Name__c = 'Leading';
        imageLevel1.RecordTypeId = imageLevelRecordTypeId;
        
        List<EUR_CRM_Image_Level__c> imageLevelList = new List<EUR_CRM_Image_Level__c>();
        imageLevelList.add(imageLevel1);
        imageLevelList.add(imageLevel2);
        insert imageLevelList;
        
        EUR_CRM_Account__c acct = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EUR DK On Trade')[0];
        acct.EUR_CRM_Force_Image_Level__c = 'Iconic';
        insert acct;
        
        acct.EUR_CRM_Force_Image_Level__c = 'Leading';
        update acct;
        
    }    
}