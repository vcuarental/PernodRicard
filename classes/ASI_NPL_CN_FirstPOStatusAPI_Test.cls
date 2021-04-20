@IsTest
private class ASI_NPL_CN_FirstPOStatusAPI_Test {

    static testMethod void test_ASI_NPL_CN_FirstPOStatusAPI() {
        initData();
    }

    static void initData(){

        ASI_CN_NPL_Item_Master__c item = new ASI_CN_NPL_Item_Master__c();
        item.ASI_CN_NPL_Item_Goup_Code__c = 'test item group code';
        item.RecordTypeId  = Schema.SObjectType.ASI_CN_NPL_Item_Master__c.getRecordTypeInfosByDeveloperName().get('ASI_CN_NPL_Item_Master_TypeA').getRecordTypeId();
        insert item;

        ASI_CN_NPL_NPL_Request__c npl = new ASI_CN_NPL_NPL_Request__c();
        npl.ASI_CN_NPL_Item_Master__c = item.id;
        insert npl;

        ASI_NPL_CN_FirstPOStatusAPI.RequestWrapper obj = new ASI_NPL_CN_FirstPOStatusAPI.RequestWrapper();
        obj.Item_Group_Code = 'test item group code';
        obj.PO_Release_Date = '2019-01-24';
        obj.Request_ETA_Date = '2019-01-24';
        obj.Invoice_Date = '2019-01-24';
        obj.ETA_Date = '2019-01-24';
        obj.ATA_Date = '2019-01-24';
        obj.Estimate_Customer_Clearance_Date = '2019-01-24';
        obj.Available_Date = '2019-01-24';

        Test.startTest();
        ASI_NPL_CN_FirstPOStatusAPI.updateFirstPOStatusByItemGroup(obj);
        Test.stopTest();

    }

}