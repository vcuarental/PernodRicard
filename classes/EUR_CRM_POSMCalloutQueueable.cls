public class EUR_CRM_POSMCalloutQueueable implements Queueable, Database.AllowsCallouts {
    
    Id posmOrderId;
    
    //Constructor 
    public EUR_CRM_POSMCalloutQueueable(Id posmOrdersId){
        
        this.posmOrderId = posmOrdersId;
    }
    
    public void execute(QueueableContext context) {
        
        EUR_CRM_POSM_CalloutHelper helper = new EUR_CRM_POSM_CalloutHelper();
        helper.callService(this.posmOrderId);
    }
}