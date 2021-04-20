@isTest
public class ASI_CRM_MY_Submit_FGR_light_ctr_Test {
    public static testMethod void test1(){
        
        ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=100000, ASI_FOC_Date__c=date.today());
        insert po;
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'));
        insert fr;
        test.startTest();
        ASI_CRM_MY_Submit_FGR_light_ctr.getRecord(fr.Id);
        ASI_CRM_MY_Submit_FGR_light_ctr.updateFGR(fr.Id);
        
        test.stopTest();
    }

}