public without sharing class ASI_CRM_CN_PaymentInstruction_CmpntCtrl {

    public boolean isCancel {set;get;}
    public ASI_CRM_CN_PH_Payee_Line_Item__c thisPayee {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public Boolean t1T2 { get; set; }
    
    public boolean init(){ 
        if (thisPayee != null){
            if (thisPayee.ASI_CRM_CN_Amount__c < 0){
                isCancel = true;
            }
        }
        return true;
    }
}