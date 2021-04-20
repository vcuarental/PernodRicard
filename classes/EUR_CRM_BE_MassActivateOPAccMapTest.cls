@isTest
public class EUR_CRM_BE_MassActivateOPAccMapTest {
    
    @testSetUp static void setUpData(){
        Id actionListRtId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Action_List_Template__c' + 'EUR_BE_O_P_Action_List_Template');
        
        EUR_CRM_OP_Action_List_Template__c listTemplate = new EUR_CRM_OP_Action_List_Template__c();
        listTemplate.name = 'test template';
        listTemplate.EUR_CRM_External_ID__c = 'BE_Off_Trade_Sales_Drive';
        listTemplate.recordtypeId = actionListRtId;
        
        insert listTemplate;
        
        Id opActionRtId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Action__c' + 'EUR_BE_OFF_OP_Action');
        
        EUR_CRM_ObjPromo_Action__c opAction = new EUR_CRM_ObjPromo_Action__c(recordTypeId = opActionRtId,
                                                                             Name = 'Test Action',
                                                                             EUR_CRM_OP_Action_List_Template__c = listTemplate.Id);
        insert opAction;
        
    }
    
    static testMethod void testMassActivateOPAccMapping(){
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
       	objPromo.EUR_CRM_Status__c = 'Drafted';
        insert objPromo;
        
        objPromo.EUR_CRM_Status__c = 'Published';
        update objPromo;
        
        objPromo.EUR_CRM_Status__c = 'Active';
        update objPromo;
        
        Id opAccMappingRtId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__c' + 'EUR_BE_O_P_Account_Mapping');
        
        EUR_CRM_ObjPromo_Account_Mapping__c opAccMapping = new EUR_CRM_ObjPromo_Account_Mapping__c();
        opAccMapping.RecordTypeId = opAccMappingRtId;
        opAccMapping.EUR_CRM_Account__c = beAccount.Id;
        opAccMapping.EUR_CRM_ObjPromo__c = objPromo.Id;
        opAccMapping.EUR_CRM_Is_Active__c = FALSE;
        insert opAccMapping;
        
        
        
        List<EUR_CRM_ObjPromo_Account_Mapping__c> testAccMapping = [SELECT Id, EUR_CRM_Is_Active__c, EUR_CRM_Account__c, EUR_CRM_ObjPromo__r.EUR_CRM_Active_End_Date__c, EUR_CRM_ObjPromo__r.EUR_CRM_Active_Start_Date__c,EUR_CRM_ObjPromo__r.EUR_CRM_Status__c ,EUR_CRM_ObjPromo__c
                                                            FROM EUR_CRM_ObjPromo_Account_Mapping__c 
                                                            WHERE Recordtype.DeveloperName =  'EUR_BE_O_P_Account_Mapping'];
        system.debug('testAccMapping: '+testAccMapping);
        for (EUR_CRM_ObjPromo_Account_Mapping__c a: testAccMapping){
            List<EUR_CRM_ObjPromo__c> sample = [select EUR_CRM_Status__c from EUR_CRM_ObjPromo__c where id = :a.EUR_CRM_ObjPromo__c limit 1];
            system.debug(sample.get(0).EUR_CRM_Status__c);
        }
           
        
        Test.startTest();
        EUR_CRM_MassActivateOP batch1 = new EUR_CRM_MassActivateOP();
        Database.executeBatch(batch1,200);
        EUR_CRM_BE_MassActivateOPAccountMapping batch2 = new EUR_CRM_BE_MassActivateOPAccountMapping();
        Database.executeBatch(batch2,200);
        Test.stopTest();
        
        
    } 
}