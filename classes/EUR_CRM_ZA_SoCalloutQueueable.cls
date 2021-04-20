/*
*    Description    :    Apex Queueable class which inovokes through After Update
*                        trigger on EUR_CRM_Sales_Order__c
*                        This class makes callout to the external web service through
*                        EUR_CRM_SO_CalloutHelper
*
*    Version    Author        Date            Description
*    1.0        Sid           12/30/2015      Initial Draft
*/

public class EUR_CRM_ZA_SoCalloutQueueable implements Queueable, Database.AllowsCallouts {
	
	Id salesOrderId;
	
	//Constructor 
    public EUR_CRM_ZA_SoCalloutQueueable(Id salesOrderId){
        
        this.salesOrderId = salesOrderId;
    }
	
    public void execute(QueueableContext context) {
        
        EUR_CRM_SO_CalloutHelper helper = new EUR_CRM_SO_CalloutHelper();
        helper.callService(this.salesOrderId);
    }
}