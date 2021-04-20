@isTest
public class ASI_CRM_SG_FGSubmitForApp_ctrl_Test {
    public static testMethod void test1(){
         ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=100000, ASI_FOC_Date__c=date.today());
        insert po;
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC'));
        insert fr;
        ASI_FOC_Request_Item__c freeGoodsItem = new ASI_FOC_Request_Item__c(
                           recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_SG_CRM_Request_Items'),
                           ASI_FOC_Request_Order__c = fr.id
                       );
        insert freeGoodsItem;
        test.startTest();
        	ASI_CRM_SG_FGSubmitForApp_ctrl.getRecord(fr.Id);
        ASI_CRM_SG_FGSubmitForApp_ctrl.getRecord(null);
        test.stopTest();
    }
        
}