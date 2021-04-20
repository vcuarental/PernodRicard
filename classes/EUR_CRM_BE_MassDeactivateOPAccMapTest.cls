/***********************************************************************************
 * Name: EUR_CRM_BE_MassDeactivateOPAccMapTest
 * Description: Test Class for EUR_CRM_BE_MassDeactivateOPAccMapping 
 *
 * Version History
 * Date         Developer   			Comments
 * ----------   -------------------  	--------------------------------------------    
 *  5-7-2017  	[Laputa] Kevin Choi  	Created. 
***********************************************************************************/
@isTest
public class EUR_CRM_BE_MassDeactivateOPAccMapTest {
    
    @testSetUp static void setUpData(){
        Id actionListRtId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Action_List_Template__c' + 'EUR_BE_O_P_Action_List_Template');
        
        EUR_CRM_OP_Action_List_Template__c listTemplate = new EUR_CRM_OP_Action_List_Template__c();
        listTemplate.name = 'test template';
        listTemplate.EUR_CRM_External_ID__c = 'BE_Off_Trade_Sales_Drive';
        listTemplate.recordtypeId = actionListRtId;
        
        insert listTemplate;
        
        
        Id opActionRtId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Action__c' + 'EUR_BE_OFF_OP_Action');
        
        EUR_CRM_ObjPromo_Action__c opAction = new EUR_CRM_ObjPromo_Action__c(recordTypeId = opActionRtId,
                                                                             Name = 'Test ACtion',
                                                                             EUR_CRM_OP_Action_List_Template__c = listTemplate.Id);
        insert opAction;
        
    }
    
    static testMethod void testMassDeactivateOPAccMapping(){
        EUR_CRM_OP_Action_List_Template__c actionTemplate = [select id from EUR_CRM_OP_Action_List_Template__c where name =  'test template' limit 1];
        
        Id beAccountRtId = Global_RecordTypeCache.getRtId('EUR_CRM_Account__c' + 'EUR_BE_Off_Trade');
        
        EUR_CRM_Account__c beAccount = new EUR_CRM_Account__c(Name = 'Test Account');
        beAccount.RecordTypeId = beAccountRtId;
        beAccount.EUR_CRM_Status__c = 'New';
        beAccount.EUR_CRM_Business_Type__c = 'Outlet';
        insert beAccount;
        
        Id objPromortId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c' + 'EUR_BE_Off_Trade_Sales_Drive');
        
        EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c();
        objPromo.RecordTypeId = objPromortId;
        objPromo.Name = 'Test objPromo';
        objPromo.EUR_CRM_CustomerTaxonomy_Chain__c = 'TEST CHAIN';
        objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = 'TEST CHAIN';
        objPromo.EUR_CRM_OP_Action_List_Template__c = actionTemplate.Id;
        objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
        objPromo.EUR_CRM_Active_End_Date__c = Date.today().addDays(7); 
       	objPromo.EUR_CRM_Status__c = 'Deactivated';
        insert objPromo;
        
        Id opAccMappingRtId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__c' + 'EUR_BE_O_P_Account_Mapping');
        
        EUR_CRM_ObjPromo_Account_Mapping__c opAccMapping = new EUR_CRM_ObjPromo_Account_Mapping__c();
        opAccMapping.RecordTypeId = opAccMappingRtId;
        opAccMapping.EUR_CRM_Account__c = beAccount.Id;
        opAccMapping.EUR_CRM_ObjPromo__c = objPromo.Id;
        opAccMapping.EUR_CRM_Is_Active__c = true;
        insert opAccMapping;
        
        Test.startTest();
        
        EUR_CRM_BE_MassDeactivateOPAccMapping batch = new EUR_CRM_BE_MassDeactivateOPAccMapping();
        Database.executeBatch(batch);
        
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccMappingList = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        opAccMappingList.add(opAccMapping);
        EUR_CRM_BE_MassDeactivateOPAccMapping.deactivate(opAccMappingList);
        
        Test.stopTest();
        
        
    } 
}