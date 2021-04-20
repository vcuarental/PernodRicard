public without sharing class ASI_HK_CRM_SalesOrderConfirmUrgentCon {
    
    public String urgentOrderConfirm { get; set; }
    public boolean customizeDeliveryCheckBox { get; set; }
    public boolean urgentOrderCheckBox { get; set; }    
    public DateTime deliveryDate { get; set; }
    public ID soId { get; private set; }    
    public ASI_HK_CRM_Sales_Order__c so { get; set; }
    private static final Set<String> validStatusName = new Set<String>{
      'BM Approved'
     , 'BM Rejected'
     , 'ALM Approved'
     , 'ALM Rejected'
     , 'Interfaced to JDE'
     , 'Waiting for Hold Code'
     , 'Checking Extra Items'
     //, 'Hold Code Received'
     , 'MD Approved'
     , 'MD Rejected'
     , 'Pending for Workflow'
    // , 'SA Approved'
     , 'SA Rejected'
     , 'HS Approved'
     , 'HS Rejected'
     , 'SSM Approved'
     , 'SSM Rejected'
     , 'CC'
     , 'CS'
     , 'IF'
     , 'IP'
     , 'S'
     , 'CO'
     , 'Added in Commitments'
     , 'Added in S/O entry'   
     , 'Canceled in Commitments'
     , 'Canceled in Order Entry'
     , 'Canceled in Ship. Conf.'
     , 'Enter Sales Order'
     , 'Invoice Print'
     , 'Sales Update'
     , 'Ship Confirmation'
     , 'SO Rejected'
     , 'SSC Finance updated'
     , 'FD Approved'
     , 'FD Rejected'
     , 'Approved'
     , 'Web Service Error'
     , 'Supervisor Rejected'
     , 'SSC Rejected'
     //, 'Hold Code Received'

       
    };
    
    public ASI_HK_CRM_SalesOrderConfirmUrgentCon (ApexPages.StandardController stdCon){
        this.soId = stdCon.getId();
        this.so = [SELECT Id, ASI_HK_CRM_Delivery_Date__c, ASI_HK_CRM_Urgent_Order__c, 
                   ASI_HK_CRM_Urgent_Order_Confirmed__c, ASI_HK_CRM_Order_Status_Name__c
                   , ASI_HK_CRM_Customize_Delivery_Date__c
                   , ASI_HK_CRM_Next_SO_Approver__c
                   FROM ASI_HK_CRM_Sales_Order__c WHERE Id = :soId];
        urgentOrderConfirm = this.so.ASI_HK_CRM_Urgent_Order_Confirmed__c;
        urgentOrderCheckBox = this.so.ASI_HK_CRM_Urgent_Order__c;
        deliveryDate = this.so.ASI_HK_CRM_Delivery_Date__c;
        urgentOrderCheckBox = this.so.ASI_HK_CRM_Customize_Delivery_Date__c;
        
        String queryStr = 'Select id, Name, '
            			+'(Select Id,ProcessInstanceId'
                        + ', StepStatus'
                        + ', Comments'
                        + ', CreatedDate'
                        + ', OriginalActor.Id' 
                        + ', OriginalActor.Name'
                        + ', OriginalActor.Title '
                        + ', Actor.Id'
                        + ', Actor.Name'
                        + ', Actor.Title '
                        + ' From ProcessSteps '
                        + ' WHERE StepStatus = \'Pending\')'
            			+ ' From ASI_HK_CRM_Sales_Order__c '
            			+ ' Where id =: soId';
        //boolean Urgenterror = false; //edited by Leo, 20160303
        List<sObject> parentSObjList = Database.query(queryStr);
        //id CurrentUserId = UserInfo.getUserId(); //edited by Leo, 20160303
        //if (CurrentUserId != so.ASI_HK_CRM_Next_SO_Approver__c) //edited by Leo, 20160303
            //Urgenterror = true; //edited by Leo, 20160303
        if (validStatusName.contains(so.ASI_HK_CRM_Order_Status_Name__c)) throw new SalesOrderConfirmBtnException('You are not allowed to edit this record');
    	//if (Urgenterror) throw new SalesOrderConfirmBtnException('You are not allowed to confirm urgent order'); //edited by Leo, 20160303
    }

    public PageReference save() {
        
        DateTime currentDateTime = DateTime.now();
        Date minDeliveryDate = currentDateTime.date();        
        Date currentDate = currentDateTime.date();
        Date userFillDeliveryDate = so.ASI_HK_CRM_Delivery_Date__c;
        Integer numDay = currentDate.daysBetween(userFillDeliveryDate);
        
        PageReference redirectPage = null;
        /*
        if (this.so.ASI_HK_CRM_Urgent_Order_Confirmed__c == 'Yes' && this.so.ASI_HK_CRM_Urgent_Order__c == false){
            showPageError('You must check the urgent order box in order to proceed');
        }
        else if (this.so.ASI_HK_CRM_Urgent_Order_Confirmed__c != 'Yes' && this.so.ASI_HK_CRM_Urgent_Order__c == true){
            showPageError('You must choose urgent order confirm to be true in order to proceed urgent order');
        }
        else if (numDay > 3 && this.so.ASI_HK_CRM_Urgent_Order__c == false){
            showPageError('Delivery Date can be no more than 3 days after Order Date!');
        }
        
        else if (this.so.ASI_HK_CRM_Delivery_Date__c == DateTime.now().date() && this.so.ASI_HK_CRM_Urgent_Order__c == false){

        }
        */
        //if (this.so.ASI_HK_CRM_Urgent_Order_Confirmed__c == 'No' && this.so.ASI_HK_CRM_Delivery_Date__c == DateTime.now().date()){
        //    showPageError('Non Urgent order could not set the delivery date be today');
        //}        
        //else{ 
            try{
                this.so.ASI_HK_CRM_Urgent_Order_Confirmed__c = 'Yes';
                this.so.ASI_HK_CRM_Urgent_Order__c = True;
                this.so.ASI_HK_CRM_Delivery_Date__c = currentDate;
                update this.so; 
                
                //Added by Alan Wong (Elufa) Auto Approve
                List<Id> newWorkItemIds = new List<Id>();
                for (List<ProcessInstance> pis : [Select (Select Id From Workitems) From ProcessInstance p WHERE p.TargetObjectId = :this.so.id AND p.Status = 'Pending']) {
                    for (ProcessInstance pi : pis) {
                        for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
                            for (ProcessInstanceWorkitem wi : wis ) {
                                newWorkItemIds.add(wi.id);
                            }
                        }           
                    }
                }
                if (newWorkItemIds.size() > 0){
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setAction('Approve'); //This is the action that is approve in your case, you can set it to Reject also
                    req2.setWorkitemId(newWorkItemIds.get(0));
                    Approval.ProcessResult result2 =  Approval.process(req2);
                }  
                //
                ASI_CRM_Default_Value__c CustomredirectPage = [SELECT ASI_CRM_Value__c from ASI_CRM_Default_Value__c Detail WHERE Name = 'ASI_CRM_HK_SODefaultPage' AND ASI_CRM_Country__c = 'HK'];
                
                redirectPage = new PageReference(CustomredirectPage.ASI_CRM_Value__c);             
            } catch(exception e){
                System.debug('uid'+e.getMessage());
            }
        //}
        return redirectPage;
       //return null; 
    }

    private void showPageMessage(ApexPages.Severity severity, String msg) { ApexPages.addMessage(new ApexPages.Message(severity, msg)); }
    private void showPageError(String msg) { showPageMessage(ApexPages.Severity.ERROR, msg); }

    public class SalesOrderConfirmBtnException extends Exception {
        
    }    
}