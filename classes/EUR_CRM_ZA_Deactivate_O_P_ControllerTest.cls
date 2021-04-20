/*
*    Description : Test class for EUR_CRM_ZA_Deactivate_O_P_Controller
*
*    Version        Date                Author                Description
*    1.0            11/17/2015          Sid                   Initial Draft
*/

@isTest
public class EUR_CRM_ZA_Deactivate_O_P_ControllerTest {

    //Test Method to test Deactivate Op feature when ObjPromo Id is provided
    public static testMethod void testDeactivateOpWithId(){
    
        //Create test Action List Template
        EUR_CRM_OP_Action_List_Template__c objActionTemplate = new EUR_CRM_OP_Action_List_Template__c(); 
        objActionTemplate.EUR_CRM_External_ID__c = 'ZA_OFF_ALT_Promo';
        objActionTemplate.recordTypeId = [select Id from RecordType where Developername =: 'EUR_ZA_OP_Action_List_Template'][0].Id;
        insert objActionTemplate;
    
        List<EUR_CRM_ObjPromo__c> objPromoList = EUR_CRM_ZA_Deactivate_O_P_ControllerTest.createObjPromo(1);
        EUR_CRM_ObjPromo__c objPromo = objPromoList[0];
        objPromo.EUR_CRM_Status__c = 'test';
        objPromo.EUR_CRM_OP_Action_List_Template__c = objActionTemplate.Id;
        objPromo.recordTypeId = [select Id from RecordType where Developername =: 'EUR_ZA_Off_Trade_Promotion'][0].Id;
        insert objPromo;
        
        ApexPages.currentPage().getParameters().put('id', objPromo.Id);
        
        test.startTest();
            EUR_CRM_ZA_Deactivate_O_P_Controller objCtrl = new EUR_CRM_ZA_Deactivate_O_P_Controller(); 
            objCtrl.deactivateOP();
            System.assertNotEquals(Null, objCtrl.deactivateOP());
            System.assertEquals([Select EUR_CRM_Status__c from EUR_CRM_ObjPromo__c where Id =: objPromo.Id][0].EUR_CRM_Status__c, 'Deactivated');             
        test.stopTest();
    }    
    
    //Test Method to test Deactivate Op feature when ObjPromo Id is not provided
    public static testMethod void testDeactivateOpWithoutId(){
     
        test.startTest();
            EUR_CRM_ZA_Deactivate_O_P_Controller objCtrl = new EUR_CRM_ZA_Deactivate_O_P_Controller(); 
            objCtrl.deactivateOP();
            PageReference pr = new PageReference('/');
            System.assertNotEquals(Null, objCtrl.deactivateOP());
        test.stopTest();
    }    
    
    //Create test record for Objective/Promo 
    public static List<EUR_CRM_ObjPromo__c> createObjPromo(Integer pNumber){
    
        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
        for(Integer i = 0; i < pNumber; i++){
            EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c();
            objPromoList.add(objPromo);        
        }
        return objPromoList;
    }
}