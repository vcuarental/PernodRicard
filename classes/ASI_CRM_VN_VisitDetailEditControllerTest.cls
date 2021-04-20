/*********************************************************************************
 * Name: ASI_CRM_VN_VisitDetailEditControllerTest
 * Description: Test Class for ASI_CRM_VN_VisitDetailEditController
 *
 * Version History
 * Date                Developer             Comments
 * ---------------  --------------------  --------------------------------------------------------------------------------
 * 11/10/2015          Alvin         Created      
 * 
*********************************************************************************/

@isTest
   
public class ASI_CRM_VN_VisitDetailEditControllerTest {
    
    public static testmethod void testForASI_CRM_VNRecordType(){
    
        Id devRecordTypeIdVisit = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getRecordTypeInfosByName().
                                                                                   get('VN Visitation Plan').getRecordTypeId();
        ASI_HK_CRM_Visitation_Plan__c visitationInstance = ASI_CRM_VN_TestDataFactory.getVisitationPlan('TestVisitation_Plan',
                                                                                                         devRecordTypeIdVisit);
        insert visitationInstance;
        
        Id devRecordTypeId = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan_Detail__c.getRecordTypeInfosByName().
                                                                                     get('VN Visitation Plan Detail').getRecordTypeId();
        ASI_HK_CRM_Visitation_Plan_Detail__c instance = ASI_CRM_VN_TestDataFactory.getPlanDetail('customer',
                                                                                                 'outletName',
                                                                                                 devRecordTypeId,
                                                                                                 visitationInstance.id);
        insert instance;
        
        Test.startTest();
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(instance);
        ASI_CRM_VN_VisitDetailEditController controller = new ASI_CRM_VN_VisitDetailEditController(stdCon);
        PageReference objPageRefer = controller.pageRedirect();
        
        Test.stopTest();
        
        system.assert(objPageRefer.getUrl().contains('saveURL'));
        
    }   
    
    public static testmethod void testForNonASI_CRM_VNRecordType(){
    
        Id devRecordTypeIdVisit = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getRecordTypeInfosByName().
                                                                                   get('VN Visitation Plan').getRecordTypeId();
        ASI_HK_CRM_Visitation_Plan__c visitationInstance = ASI_CRM_VN_TestDataFactory.getVisitationPlan('TestVisitation_Plan',
                                                                                                         devRecordTypeIdVisit);
        insert visitationInstance;

        Id devRecordTypeId = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan_Detail__c.getRecordTypeInfosByName().
                                                                                     get('TW Visitation Plan Detail').getRecordTypeId();
        ASI_HK_CRM_Visitation_Plan_Detail__c instance = ASI_CRM_VN_TestDataFactory.getPlanDetail('customer',
                                                                                                 'outletName',
                                                                                                  devRecordTypeId,
                                                                                                  visitationInstance.id);
        insert instance;

        Test.startTest();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(instance);
        ASI_CRM_VN_VisitDetailEditController controller = new ASI_CRM_VN_VisitDetailEditController(stdCon);
        PageReference objPageRefer = controller.pageRedirect();
        Test.stopTest();

        system.assert(!objPageRefer.getUrl().contains('saveURL'));     
    }   
    
    public static testmethod void testForNull(){
    
        Id devRecordTypeIdVisit = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getRecordTypeInfosByName().
                                                                                   get('VN Visitation Plan').getRecordTypeId();
        ASI_HK_CRM_Visitation_Plan__c visitationInstance = ASI_CRM_VN_TestDataFactory.getVisitationPlan('TestVisitation_Plan',
                                                                                                         devRecordTypeIdVisit);
        insert visitationInstance;
        
        Id devRecordTypeId = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan_Detail__c.getRecordTypeInfosByName().
                                                                                     get('TW Visitation Plan Detail').getRecordTypeId();
        ASI_HK_CRM_Visitation_Plan_Detail__c instance = ASI_CRM_VN_TestDataFactory.getPlanDetail('customer',
                                                                                                 'outletName',
                                                                                                 devRecordTypeId,
                                                                                                 visitationInstance.id);
        insert instance;
        
        Test.startTest();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(instance);
        ASI_CRM_VN_VisitDetailEditController controller = new ASI_CRM_VN_VisitDetailEditController(stdCon);
        controller.detail = null;
        PageReference objPageRefer = controller.pageRedirect();
        Test.stopTest();
        
        system.assert(objPageRefer == null);
        
    }   
    
}