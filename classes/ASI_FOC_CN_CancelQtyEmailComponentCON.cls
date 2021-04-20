public with sharing class ASI_FOC_CN_CancelQtyEmailComponentCON {
	public ASI_FOC_Request_Item__c RICurrent{get;set;}
    public id RIID{get;set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_FOC_CN_CancelQtyEmailComponentCON(ApexPages.StandardController controller) {
            this.RICurrent = (ASI_FOC_Request_Item__c)controller.getRecord();
    }
    
    public ASI_FOC_CN_CancelQtyEmailComponentCON(){
      
    }
    
    public boolean init(){
        RICurrent = [SELECT id,ASI_FOC_Request_Order__r.Name,CreatedBy.Name,ASI_FOC_SKU__r.Name,ASI_FOC_SKU_Chinese_Description__c,ASI_FOC_Packing_Description__c,ASI_FOC_SKU_Description__c,ASI_FOC_Original_Request_Quantity_PC_BT__c,ASI_FOC_Cancel_Quantity_PC_BT__c FROM ASI_FOC_Request_Item__c WHERE ID =:RIId]; 
    	return true;
    }
}