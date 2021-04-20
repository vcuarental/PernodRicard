/**
 *   A test class to cover the functionality for the ASI_CRM_VN_VisitDetailGPSController apex class
 * 
 **/
@isTest
public class ASI_CRM_VN_VisitDetailGPSControllerTest {
	
    private static testMethod void testParse() {
        Map<String, Schema.RecordTypeInfo> recordTypeHKVisitPlanInfo = 
                                     Schema.SObjectType.ASI_HK_CRM_Visitation_Plan__c.getRecordTypeInfosByName();
        ASI_HK_CRM_Visitation_Plan__c objVisitPLan = new ASI_HK_CRM_Visitation_Plan__c();
		objVisitPLan.recordTypeId = recordTypeHKVisitPlanInfo.get('HK CRM Visitation Plan').getRecordTypeId();
        objVisitPLan.ASI_CRM_Branch__c = 'test Crm Branch';
        objVisitPLan.ASI_HK_CRM_Confirmed__c = false;
        objVisitPLan.ASI_HK_CRM_Manager_Email__c = 'test@gmail.com';
        objVisitPLan.ASI_HK_CRM_Month__c = 'July';
        insert objVisitPLan;
        ASI_HK_CRM_Visitation_Plan_Detail__c objDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c(
        														ASI_HK_CRM_Status__c = 'Planned',
        														ASI_CRM_Visit_Address__c = 'Street no 4,Test country',
        														ASI_HK_CRM_Visitation_Plan__c = objVisitPLan.Id);
        insert objDetail;
        Test.setMock(HttpCalloutMock.class, new ASI_CRM_VN_MockLocReGenerator());

        ApexPages.StandardController sc = new ApexPages.StandardController(objDetail);
        Test.startTest();
        ASI_CRM_VN_VisitDetailGPSController objDetailsController = new ASI_CRM_VN_VisitDetailGPSController(sc);
        objDetailsController.latitudeStr = '80.99';
        objDetailsController.longitudeStr = '80.00';
        objDetailsController.googleMapRequest();
        test.stopTest();
        
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> listCrmVisitationPlan = [Select Id,ASI_CRM_Visit_Address__c,ASI_HK_CRM_Status__c from ASI_HK_CRM_Visitation_Plan_Detail__c
                                                                     Where Id =:objDetail.Id ];
        system.debug('listCrmVisitationPlan[0].ASI_HK_CRM_Status__c***'+listCrmVisitationPlan[0]);
        system.assertEquals('Achieved', listCrmVisitationPlan[0].ASI_HK_CRM_Status__c);
        
        
        
        
    
    }
}