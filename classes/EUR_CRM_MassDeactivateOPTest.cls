/***********************************************************************************
* Name: EUR_CRM_MassDeactivateOPTest
* Description: Test Class for EUR_CRM_MassDeactivateOP 
*
* Version History
* Date         Developer   			Comments
* ----------   -------------------  	--------------------------------------------    
*  5-7-2017  	[Laputa] Kevin Choi  	Created. 
***********************************************************************************/
@isTest
public class EUR_CRM_MassDeactivateOPTest {
    
    static testMethod void executeBatch(){
        List<EUR_CRM_ObjPromo__c> objPromoInsertList = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_OP_Action_List_Template__c> listTemplateInsert = new List<EUR_CRM_OP_Action_List_Template__c>(); 
		List<EUR_CRM_ObjPromo_Target__c> targetList = new List<EUR_CRM_ObjPromo_Target__c>();
        
        
        Id actionListRtId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Action_List_Template__c' + 'EUR_BE_O_P_Action_List_Template');
        EUR_CRM_OP_Action_List_Template__c listTemplate = new EUR_CRM_OP_Action_List_Template__c();
        listTemplate.name = 'test template';
        listTemplate.EUR_CRM_External_ID__c = 'BE_Off_Trade_Sales_Drive';
        listTemplate.recordtypeId = actionListRtId;        
        listTemplateInsert.add(listTemplate);
        
         EUR_CRM_OP_Action_List_Template__c listTemplate2 = new EUR_CRM_OP_Action_List_Template__c();
        listTemplate2.name = 'test template';
        listTemplate2.EUR_CRM_External_ID__c = 'BE_On_Trade_Promo_Kit_Activation';
        listTemplate2.recordtypeId = actionListRtId;
        listTemplateInsert.add(listTemplate2);
        
        EUR_CRM_OP_Action_List_Template__c listTemplate3 = new EUR_CRM_OP_Action_List_Template__c();
        listTemplate3.name = 'test template';
        listTemplate3.EUR_CRM_External_ID__c = 'BE_Off_Trade_Secondary_placement_Spyder_display';
        listTemplate3.recordtypeId = actionListRtId;
        listTemplateInsert.add(listTemplate3); 
        
        insert listTemplateInsert;
        
        
        Id opActionRtId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Action__c' + 'EUR_BE_OFF_OP_Action'); 
        EUR_CRM_ObjPromo_Action__c opAction = new EUR_CRM_ObjPromo_Action__c(recordTypeId = opActionRtId,
                                                                             Name = 'Test ACtion',
                                                                             EUR_CRM_OP_Action_List_Template__c = listTemplate.Id);
        insert opAction;
        
        
        Id objPromortId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c' + 'EUR_BE_Off_Trade_Sales_Drive');
        EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c();
        objPromo.RecordTypeId = objPromortId;
        objPromo.Name = 'Test objPromo';
        objPromo.EUR_CRM_CustomerTaxonomy_Chain__c = 'TEST CHAIN';
        objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = 'TEST CHAIN';
        objPromo.EUR_CRM_OP_Action_List_Template__c = listTemplate.Id;
        objPromo.EUR_CRM_Active_Start_Date__c = Date.today().addDays(-2);
        objPromo.EUR_CRM_Active_End_Date__c = Date.today(); 
        objPromo.EUR_CRM_Status__c = 'Active';
        objPromoInsertList.add(objPromo);
        
        Id objPromortId2 = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c' + 'EUR_BE_On_Trade_Promo_Kit_Activation');
        EUR_CRM_ObjPromo__c objPromo2 = new EUR_CRM_ObjPromo__c();
        objPromo2.RecordTypeId = objPromortId2;
        objPromo2.Name = 'Test objPromo 2';
        objPromo2.EUR_CRM_CustomerTaxonomy_Chain__c = 'chain';
        objPromo2.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = 'chain';
        objPromo2.EUR_CRM_OP_Action_List_Template__c = listTemplate2.Id;
        objPromo2.EUR_CRM_Active_Start_Date__c = Date.today().addDays(-2);
        objPromo2.EUR_CRM_Active_End_Date__c = Datetime.now().date(); 
        objPromo2.EUR_CRM_Status__c = 'Active';
        objPromo2.EUR_CRM_Evaluation_Period_End_Date__c = Date.today();
        objPromoInsertList.add(objPromo2);
        
        Id objPromortId3 = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c' + 'EUR_BE_Off_Trade_Secondary_placement_Spyder_display');
        EUR_CRM_ObjPromo__c objPromo3 = new EUR_CRM_ObjPromo__c();
        objPromo3.RecordTypeId = objPromortId3;
        objPromo3.Name = 'Test objPromo 3';
        objPromo3.EUR_CRM_CustomerTaxonomy_Chain__c = 'chain';
        objPromo3.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = 'chain';
        objPromo3.EUR_CRM_OP_Action_List_Template__c = listTemplate2.Id;
        objPromo3.EUR_CRM_Active_Start_Date__c = Date.today().addDays(-2);
        objPromo3.EUR_CRM_Active_End_Date__c = Datetime.now().date(); 
        objPromo3.EUR_CRM_Status__c = 'Active';
        objPromo3.EUR_CRM_Evaluation_Period_End_Date__c = Date.today();
        objPromoInsertList.add(objPromo3);
        
        
        insert objPromoInsertList;
        
        
        Test.startTest();
        EUR_CRM_MassDeactivateOP batch = new EUR_CRM_MassDeactivateOP();
        Database.executeBatch(batch);
        
        //List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
        //objPromoList.add(objPromo);
        //objPromoList.add(objPromo2);
        EUR_CRM_MassDeactivateOP.deactivate(objPromoInsertList);
        Test.stopTest();
        
    }
}