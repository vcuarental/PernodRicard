public with sharing class ASI_CRM_CN_ApplyBrandT1T2Ctrl {

    private ASI_CRM_AccountsAdditionalField__c customer;
    public string SuccessMessage {set;get;}
    public boolean hasError {set;get;}

    public ASI_CRM_CN_ApplyBrandT1T2Ctrl(ApexPages.StandardController controller){
        customer = (ASI_CRM_AccountsAdditionalField__c)controller.getRecord();
        SuccessMessage = '';
    }
    
    public PageReference initBT1(){
        hasError = false;
        customer.ASI_CRM_CN_Status_T1__c = 'Submitted';
        try{
            update customer;
        }
        catch(exception e){
            hasError = true;
            ApexPages.addMessages(e);
            return null;
        }
        if(!hasError){
            customer.ASI_CRM_CN_Status_T1__c = 'Draft';
            if(customer.ASI_CRM_CN_Status_T2__c != 'Final')
                    customer.ASI_CRM_CN_Status_T2__c = '';
            update customer; 
            String WSType_Search = 'WS T1';
            //ASI_CRM_CN_T1T2_ApprovalPage_Ctrl.defineApproval(WSType_Search, customer);      
            try{
                //submitApproval(customer.id);
                
                PageReference redirect = new PageReference('/apex/ASI_CRM_CN_T1T2_Approval_Page');
                redirect.getParameters().put('id',customer.id);
                redirect.getParameters().put('WSType','T1');          
                redirect.setRedirect(true); 
                
                return redirect;
                
            }
            catch(exception e){
                hasError = true;
                ApexPages.addMessages(e);
                
                return null;
            }
            //if(!hasError)
            //    SuccessMessage = 'Brand T1 Application is submitted';
        }
        else
        {
            return null;
        }
        
    }
    
    public PageReference initT2(){
        hasError = false;
        customer.ASI_CRM_CN_Status_T2__c = 'Submitted';
        try{
            //hasError = true;
            update customer;
        }
        catch(exception e){
            hasError = true;
            ApexPages.addMessages(e);
            return null;
        }
        if(!hasError){
            customer.ASI_CRM_CN_Status_T2__c = 'Draft';
            if(customer.ASI_CRM_CN_Status_T1__c != 'Final')
                    customer.ASI_CRM_CN_Status_T1__c = '';
            update customer; 
            String WSType_Search = 'WS T2';
            //ASI_CRM_CN_T1T2_ApprovalPage_Ctrl.defineApproval(WSType_Search, customer);
            try{
                
                //submitApproval(customer.id);
                PageReference redirect = new PageReference('/apex/ASI_CRM_CN_T1T2_Approval_Page');
                redirect.getParameters().put('id',customer.id);
                redirect.getParameters().put('WSType','T2');          
                redirect.setRedirect(true); 
                
                return redirect;
            }
            catch(exception e){
                hasError = true;
                ApexPages.addMessages(e);
                
                return null;
            }
            //if(!hasError)
            //    SuccessMessage = 'T2 Application is submitted';
        }
        else
        {
            return null;
        }
    }
    
    /* NOT In Use
    private static void submitApproval(id recID){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(recID);
        // submit the approval request for processing
        Approval.ProcessResult result = Approval.process(req);
        // display if the reqeust was successful
    }
    */
    

}