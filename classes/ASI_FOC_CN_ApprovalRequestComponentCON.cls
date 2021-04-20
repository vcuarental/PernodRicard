public with sharing class ASI_FOC_CN_ApprovalRequestComponentCON {
	public ASI_FOC_Free_Goods_Request__c RICurrent{get;set;}
    public id RIID{get;set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_FOC_CN_ApprovalRequestComponentCON(ApexPages.StandardController controller) {
            this.RICurrent = (ASI_FOC_Free_Goods_Request__c)controller.getRecord();
    }
    
    public ASI_FOC_CN_ApprovalRequestComponentCON(){
      
    }
    
    public boolean init(){
        RICurrent = [SELECT id, CreatedBy.Name, ASI_FOC_Request_Type__c, ASI_FOC_Purpose__c, ASI_FOC_Description__c, ASI_FOC_Deliver_to_Address_Line_1__c, ASI_FOC_Deliver_to_Address_Line_2__c, ASI_FOC_Date_of_Delivery__c, ASI_FOC_PO__r.Name, ASI_FOC_PO_Sub_brand__c, ASI_FOC_PO_Final_Amount__c, ASI_FOC_PO_Remaining_Amount__c, ASI_FOC_Free_Goods_Total_Cost__c, ASI_FOC_SYS_Request_Line_Information__c FROM ASI_FOC_Free_Goods_Request__c WHERE ID =:RIId]; 
    	return true;
    }
}