public without sharing class ASI_MFM_KR_PREmailConntroller
{	
   /*
       public ASI_MFM_KR_PREmailConntroller(ApexPages.StandardController controller) {
            this.header = (ASI_MFM_Purchase_Request__c)controller.getRecord();
    }   
*/    
    public ASI_MFM_Purchase_Request__c header {get;set;}
    public Id headerId {get;set;} //current header Id
    public List<ASI_MFM_Purchase_Request_Line__c> prLines{get;set;} //current header's line itmes
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_MFM_Purchase_Request__c PRHeader {get;set;} {PRHeader = new ASI_MFM_Purchase_Request__c ();}
    
    public List<Attachment> AttList {get;set;}
    public boolean hasAttachment {get;set;} {hasAttachment=false;}
        
    
    public boolean init()
    {
        PRHeader=[select id, name,ASI_MFM_PR_Name__c,ASI_MFM_Raised_Date__c,ASI_MFM_Plan__r.ASI_MFM_Promotion_Code__c,ASI_MFM_Comment__c,Owner.Name,ASI_MFM_Total_Amount__c 
                  from ASI_MFM_Purchase_Request__c where id= : headerId];
        
        prLines = [SELECT Id, Name, ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,
                   ASI_MFM_Purchase_Request__r.Owner.Name,ASI_MFM_Estimated_PR_budget__c,ASI_MFM_Description__c,ASI_MFM_PO_Amount_in_PR_Currency__c,
                   ASI_MFM_Purchase_Request__r.Name,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.Name,
                   ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_AP_Code__r.Name,ASI_MFM_Plan_Line_Item__r.ASI_MFM_AccountsAdditionalField__r.Name,
                   ASI_MFM_Purchase_Request__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__r.Name 
                   FROM ASI_MFM_Purchase_Request_Line__c 
                   WHERE ASI_MFM_Purchase_Request__c =: headerId 
                   AND recordType.developerName = 'ASI_MFM_KR_Purchase_Request_Line'];
        
        for(ASI_MFM_Purchase_Request_Line__c prl:prLines){
            if(prl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c==null){
                 prl.ASI_MFM_PO_Amount_in_PR_Currency__c=0;
            }else{
                prl.ASI_MFM_PO_Amount_in_PR_Currency__c=prl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c;
            }

            if(prl.ASI_MFM_Estimated_PR_budget__c== null){
                prl.ASI_MFM_Estimated_PR_budget__c=0;
            }            
            
        }
        
        AttList= [select Id, name from Attachment where ParentId =: headerId];
        if(AttList.size()>0){
            hasAttachment=true;
        }
        
        
        return true;        
    }//end method: init
}//end class