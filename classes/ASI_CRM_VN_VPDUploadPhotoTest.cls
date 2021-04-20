/*********************************************************************************
 * Name: ASI_CRM_VN_VPDUploadPhotoTest
 * Description: Test class for ASI_CRM_VN_VPDUploadPhotoCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 07/04/2018       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_VN_VPDUploadPhotoTest {
    @TestSetup
    public static void setupData() {
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();

        String profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User newUser = ASI_CRM_VN_TestClassHelper.createUser(profileId);
        newUser.email = 'jeffrey.cheung@laputatech.com';
        insert newUser;

        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;

        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;

        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;

        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.OwnerId = newUser.Id;
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
        insert onTradeCustomer;


        ASI_HK_CRM_Visitation_Plan__c firstHalfPlan = ASI_CRM_VN_TestClassHelper.createVisitationPlan();
        firstHalfPlan.OwnerId = newUser.Id;
        firstHalfPlan.ASI_CRM_VN_Period__c = 'First Half';
        firstHalfPlan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_VN_Visitation_Plan');
        ASI_HK_CRM_Visitation_Plan__c secondHalfPlan = ASI_CRM_VN_TestClassHelper.createVisitationPlan();
        secondHalfPlan.OwnerId = newUser.Id;
        secondHalfPlan.ASI_CRM_VN_Period__c = 'Second Half';
        secondHalfPlan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_VN_Visitation_Plan');

        insert firstHalfPlan;
        insert secondHalfPlan;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c detail1 = ASI_CRM_VN_TestClassHelper.createVisitationPlanDetail(
                Date.today().day() < 16 ? firstHalfPlan.Id : secondHalfPlan.Id,
                onTradeCustomer.Id
        );
        detail1.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_VN_Visitation_Plan_Detail');
        detail1.ASI_HK_CRM_Visit_Date__c = Date.today().addDays(-1);
        insert detail1;
    }
    
    public static testmethod void testCtrl() {
        ASI_HK_CRM_Visitation_Plan_Detail__c detail = [SELECT Id FROM ASI_HK_CRM_Visitation_Plan_Detail__c LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(detail);
        ASI_CRM_VN_VPDUploadPhotoCtrl ctrl = new ASI_CRM_VN_VPDUploadPhotoCtrl(sc);
        
        PageReference pageRef = Page.ASI_CRM_VN_VPDUploadPhotoPage;
        pageRef.getParameters().put('fileName', 'Testing');
        pageRef.getParameters().put('fileBody', '');
        pageRef.getParameters().put('latitude', '0');
        pageRef.getParameters().put('longitude', '0');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        	ctrl.upload();
        Test.stopTest();
    }
}