@isTest
public with sharing class ASI_CRM_CN_Brand_T1_Gp_Item_Test{

/*    
    static testMethod void ASI_CRM_CN_Brand_T1_Gp_Item_Test(){
        init();
    }
    
    public static void init(){
        //create Brand
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c();
        brand1.RecordType=[Select id, Name from RecordType where Name='CN MFM Brand'];
        brand1.Name='Brand 1';
        
        insert brand1;
        
        //create Brand_T1_Group
        ASI_CRM_CN_Brand_T1_Group__c Brand_T1_Group1 = new ASI_CRM_CN_Brand_T1_Group__c();
        Brand_T1_Group1.Name='Brand T1 Group 1';
        insert Brand_T1_Group1;
        ASI_CRM_CN_Brand_T1_Group__c Brand_T1_Group2 = new ASI_CRM_CN_Brand_T1_Group__c();
        Brand_T1_Group1.Name='Brand T1 Group 2';
        insert Brand_T1_Group2;
        //create Brand_T1_Group_item
        ASI_CRM_CN_Brand_T1_Group_Item__c Brand_T1_Group_Item1 = new ASI_CRM_CN_Brand_T1_Group_Item__c();
        Brand_T1_Group_Item1.ASI_CRM_CN_Brand_T1_Group__c=Brand_T1_Group1.id;
        Brand_T1_Group_Item1.ASI_CRM_CN_Brand__c=brand1.id;
        insert Brand_T1_Group_Item1;
        ASI_CRM_CN_Brand_T1_Group_Item__c Brand_T1_Group_Item2 = new ASI_CRM_CN_Brand_T1_Group_Item__c();
        Brand_T1_Group_Item2.ASI_CRM_CN_Brand_T1_Group__c=Brand_T1_Group1.id;
        Brand_T1_Group_Item2.ASI_CRM_CN_Brand__c=brand1.id;
        insert Brand_T1_Group_Item2;
        
    }
*/
    
    static testMethod void ASI_CRM_CN_Brand_T1_Gp_Item_TriggerClass_TEST() {
        
        //create Brand
        ASI_MFM_Brand__c brand1 = new ASI_MFM_Brand__c();
        brand1.RecordType=[Select id, Name from RecordType where Name='CN MFM Brand'];
        brand1.Name='Brand 1';
        insert brand1;
        
        //create Brand_T1_Group
        list<ASI_CRM_CN_Brand_T1_Group__c> groups = new list<ASI_CRM_CN_Brand_T1_Group__c>();
        ASI_CRM_CN_Brand_T1_Group__c Brand_T1_Group1 = new ASI_CRM_CN_Brand_T1_Group__c();
        Brand_T1_Group1.Name='Brand T1 Group 1';
        groups.add(Brand_T1_Group1);
        ASI_CRM_CN_Brand_T1_Group__c Brand_T1_Group2 = new ASI_CRM_CN_Brand_T1_Group__c();
        Brand_T1_Group1.Name='Brand T1 Group 2';
        groups.add(Brand_T1_Group2);
        insert groups;
        
        //create Brand_T1_Group_item
        list<ASI_CRM_CN_Brand_T1_Group_Item__c> groupItems1 = new list<ASI_CRM_CN_Brand_T1_Group_Item__c>();
        list<ASI_CRM_CN_Brand_T1_Group_Item__c> groupItems2 = new list<ASI_CRM_CN_Brand_T1_Group_Item__c>();
        list<ASI_CRM_CN_Brand_T1_Group_Item__c> groupItems3 = new list<ASI_CRM_CN_Brand_T1_Group_Item__c>();

        ASI_CRM_CN_Brand_T1_Group_Item__c Brand_T1_Group_Item1 = new ASI_CRM_CN_Brand_T1_Group_Item__c();
        Brand_T1_Group_Item1.ASI_CRM_CN_Brand_T1_Group__c=Brand_T1_Group1.id;
        Brand_T1_Group_Item1.ASI_CRM_CN_Brand__c=brand1.id;
        Brand_T1_Group_Item1.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_T1_Group_Item__cASI_CRM_CN_Brand_T1_Group_Item');
        groupItems1.add(Brand_T1_Group_Item1);
        insert groupItems1;

        ASI_CRM_CN_Brand_T1_Group_Item__c Brand_T1_Group_Item2 = new ASI_CRM_CN_Brand_T1_Group_Item__c();
        Brand_T1_Group_Item2.ASI_CRM_CN_Brand_T1_Group__c=Brand_T1_Group1.id;
        Brand_T1_Group_Item2.ASI_CRM_CN_Brand__c=brand1.id;
        groupItems2.add(Brand_T1_Group_Item2);

        ASI_CRM_CN_Brand_T1_Group_Item__c Brand_T1_Group_Item3 = new ASI_CRM_CN_Brand_T1_Group_Item__c();
        Brand_T1_Group_Item3.ASI_CRM_CN_Brand_T1_Group__c=Brand_T1_Group2.id;
        Brand_T1_Group_Item3.ASI_CRM_CN_Brand__c=brand1.id;
        groupItems3.add(Brand_T1_Group_Item3);

        Database.SaveResult[] sr;
            
        test.startTest();
        
        ASI_CRM_CN_Brand_T1_Gp_Item_TriggerClass tc = new ASI_CRM_CN_Brand_T1_Gp_Item_TriggerClass();
        tc.check_duplication(groupItems2);
        sr = Database.insert(groupItems2, false);
        //system.assert(!sr[0].isSuccess());

        tc.check_duplication(groupItems3);
        sr = Database.insert(groupItems3, false);
        //system.assert(sr[0].isSuccess());

        
        test.stopTest();
    }
    
}