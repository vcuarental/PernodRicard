public with sharing  class ASI_MFM_KR_PO_SEND_PDFController {
    private ApexPages.StandardController c;
    public boolean SendSuccess  {set;get;}
    public List <String> ToAddresses {set;get;}{ToAddresses = new List <String>();}
    public ASI_MFM_PO__c item {set;get;}
    public id TargetObjectId {set;get;} // Owner Id
    public Id templateId;
    public String templateApiName = 'ASI_MFM_KR_PO_Supplier_Email';
    //public DateTime LastSentTime  {set;get;}
    
    
    public boolean showResult {set;get;}
    public boolean showError {set;get;}
    public string result {set;get;}
    public string exMsg {set;get;}
    public boolean debugMode {set;get;}
    //public string debugMsg {set;get;}
    
    public string SupplierEmail{set;get;}
    
    
    public ASI_MFM_KR_PO_SEND_PDFController (ApexPages.StandardController stdController){ 
        debugMode = false;
        c = stdController;
        item = (ASI_MFM_PO__c)stdController.getRecord();
        ASI_MFM_PO__c itemR =[SELECT id,name,ownerId, recordTypeId, ASI_MFM_Email_Sent_Time__c,ASI_MFM_Supplier_Name__c,ASI_MFM_TR_Supplier_Email__c, ASI_MFM_Supplier_Name__r.gvp__Primary_Email__c,  ASI_MFM_Supplier_Name__r.Name  FROM ASI_MFM_PO__c WHERE id =:item.ID];
        SupplierEmail=string.valueOf(itemR.ASI_MFM_TR_Supplier_Email__c);
        SendSuccess=false;
       TargetObjectId= itemR.ownerId;
       // if(ASI_MFM_PO__c.ASI_MFM_TR_Supplier_Email__c!=null){
         //   Emailexist=false;
      //  }else{
       //     Emailexist=true;
       // }
        //Emailexist=true;
       // checkingEmail();
    }
    /*
    public void checkingEmail(){
        
        ASI_MFM_PO__c itemR = [SELECT id,name, recordTypeId, ASI_MFM_Supplier_Name__c,ASI_MFM_TR_Supplier_Email__c, ASI_MFM_Supplier_Name__r.gvp__Primary_Email__c,  ASI_MFM_Supplier_Name__r.Name
                               FROM ASI_MFM_PO__c WHERE id =:item.ID];
        
        if(itemR.ASI_MFM_Supplier_Name__c!=null){
            Emailexist=true;
        }else{
            Emailexist=false;
        }
    }
    */
    
    public PageReference send() 
    {
        try{
            //Get Email Template Id
            
             ToAddresses.add(SupplierEmail); 
            templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setTargetObjectId(TargetObjectId);
            email.setToAddresses( ToAddresses );
            email.setWhatId(item.ID);
            email.setSaveAsActivity(false); 
            email.setBccSender(false);
            email.setUseSignature(false);
            email.setTemplateId(templateId);
            
            if(!Test.isRunningTest()){     
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            
            ASI_MFM_PO__c po= new ASI_MFM_PO__c();
            po.id=item.ID;
            po.ASI_MFM_Email_Sent_Time__c=system.now();
            po.ASI_MFM_TR_Supplier_Email__c=SupplierEmail;
            update po;
            
            SendSuccess=true;
            
        }catch (Exception e){
            
          showResult = true;
          showError = true;
          result = 'Error occured. Please contact system administrator!';
          exMsg = e.getMessage();
          exMsg += e.getStackTraceString();
         
        }
        PageReference pageRef =null;
        
       // pageRef=new PageReference('/'+item.ID);
        
       
        return pageRef;
    }
    
}