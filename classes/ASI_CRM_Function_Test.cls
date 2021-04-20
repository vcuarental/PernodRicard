@isTest
public class ASI_CRM_Function_Test {

    static testMethod void ASI_CRM_Function_TEST() {
        
        test.startTest();
        List<Account> accList1 = new List<Account>();
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');           
        accList1.add(acc1);
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name2', ASI_LUX_Email_Business__c = 'Testing0Email@test.com');          
        accList1.add(acc2);
        insert accList1;
        
        
        //Query
       List<SObject>  accountList = ASI_CRM_Function.fetchsObjectData(' select id from Account WHERE Name =\'Name1\' ');
        
        
        List<string> DeletedIdList = new List<string>();
        DeletedIdList.add(acc2.Id);
        ASI_CRM_Function.upsertObjectData(accountList,DeletedIdList,Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'));
        
        
        ASI_CRM_Function.upsertsObjList(accountList);

        //Test failed case
        for(sObject so :accountList){
            so.put('Name', null);
        }
        ASI_CRM_Function.upsertsObjList(accountList);
        
        ASI_CRM_Function.upsertObjectData(accountList,DeletedIdList,Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'));
        
        
        
        ASI_CRM_Function.getCreatableFieldsSOQL('Account', 'NOT ISNULL(Id)', 'Name');
        ASI_CRM_Function.GetfieldTypeList('ASI_MFM_Plan_Line_Item__c');
        
        test.stopTest();
    }
}