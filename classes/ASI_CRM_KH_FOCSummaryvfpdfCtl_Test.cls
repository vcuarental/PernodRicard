@isTest
public class ASI_CRM_KH_FOCSummaryvfpdfCtl_Test {
	 public static testMethod void test1(){
        
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=100000, ASI_FOC_Date__c=date.today());
        insert po;
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_KH_FOC_Request'));
        insert fr;
           ASI_HK_CRM_Product_Category__c productCategory = ASI_CRM_MY_TestClassHelper.createProductCategory();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_MY_TestClassHelper.createSKU('sku1', productCategory);
         	sku1.ASI_HK_CRM_Active__c = true;
         update sku1;
          ASI_FOC_Request_Item__c fg_L = new ASI_FOC_Request_Item__c();
            fg_L.ASI_FOC_Request_Order__c = fr.id;
            fg_L.ASI_FOC_SKU__c = sku1.id;
            fg_L.ASI_FOC_Issued_Qty__c = 24;
            fg_L.ASI_CRM_SetupCode__c = 'SAVR';
            fg_L.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_KH_FOC_Request_Items');
            fg_L.CurrencyIsoCode = 'MYR';
            insert fg_L;
        test.startTest();
        	ASI_CRM_KH_FOCSummaryvfpdfCtl ctrl = new ASI_CRM_KH_FOCSummaryvfpdfCtl();
         	ctrl.focRecordId = fr.Id;
         	ctrl.getfocRecord();
         	ctrl.getFOCItem();
         ApexPages.StandardController sc = new ApexPages.StandardController(fr);
         ASI_CRM_KH_FOCSummaryCtl ctrl1 = new ASI_CRM_KH_FOCSummaryCtl(sc);
         ctrl1.getFOCItem();
        test.stopTest();
    }
}