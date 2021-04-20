public class ASI_MFM_KR_PayEmailController
{
    /*
    public ASI_MFM_KR_PayEmailController(ApexPages.StandardController controller) {
            this.header = (ASI_MFM_Payment__c)controller.getRecord();
    }
    */
    public ASI_MFM_Payment__c header{get;set;}
    public Id headerId {get;set;} //current header Id
    public ASI_MFM_Payment__c pay{get;set;} //current header
    public List<ASI_MFM_Payment_Line_Item__c> payLines{get;set;} //current header's line itmes
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
      
    public List<Attachment> AttList {get;set;}
    public boolean hasAttachment {get;set;} {hasAttachment=false;}
        
    
    
    public boolean init()
    {
        pay = [SELECT Id, Name,ASI_MFM_Invoice_Number__c,owner.Name,ASI_MFM_Supplier_Name__r.Name,ASI_MFM_AP_Remark__c,ASI_MFM_Remarks__c,
               ASI_MFM_Sys_Approver_1__r.Name,
               ASI_MFM_Sys_Approver_2__r.Name,
               ASI_MFM_Sys_Approver_3__r.Name,
               ASI_MFM_Sys_Approver_4__r.Name,
               ASI_MFM_Sys_Approver_5__r.Name,
               ASI_MFM_Sys_Approver_6__r.Name,
               ASI_MFM_Sys_Approver_7__r.Name,
               ASI_MFM_Sys_Approver_8__r.Name,
               ASI_MFM_Sys_Approver_9__r.Name,
               ASI_MFM_Sys_Approver_10__r.Name,
               ASI_MFM_Sys_Approver_11__r.Name
               FROM ASI_MFM_Payment__c 
               WHERE Id =: headerId 
               LIMIT 1];
        
        payLines = [SELECT Id, Name,
                    ASI_MFM_Payment__r.Name,
                    ASI_MFM_Payment__r.Owner.Name,
                    ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.Name,ASI_MFM_Paid_Amount_in_PO_Currency__c,
                    ASI_MFM_Invoice_Date__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_KR_subLedger__r.Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.Name,ASI_MFM_Paid_Amount_in_Base_Currency__c,
                    ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_AP_Remark__c,ASI_MFM_Where_Customer__r.Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,
                    ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__r.Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c,
                    ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment__r.ASI_MFM_Currency__c,
                    ASI_MFM_PO__r.ASI_MFM_Plan__r.Name,
                    ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c 
                    FROM ASI_MFM_Payment_Line_Item__c 
                    WHERE ASI_MFM_Payment__c =: headerId 
                    AND recordType.developerName = 'ASI_MFM_KR_Payment_Line_Item'];
        
        for(ASI_MFM_Payment_Line_Item__c pl: payLines){
            //Set Plan line Amount
            if(pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c ==null){
                pl.ASI_MFM_Paid_Amount_in_PO_Currency__c=0;
            }else{
                pl.ASI_MFM_Paid_Amount_in_PO_Currency__c=pl.ASI_MFM_PO_Line_Item__r.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c;
            }
            
            //Set Payment Line Amount
            if(pl.ASI_MFM_Paid_Amount_in_Base_Currency__c==null || Test.isRunningTest()){
                if(pl.ASI_MFM_Payment__r.ASI_MFM_Currency__c == 'KRW'){
                    pl.ASI_MFM_Paid_Amount_in_Base_Currency__c=pl.ASI_MFM_Payment_Amount__c;
                }
                
                if(pl.ASI_MFM_Payment__r.ASI_MFM_Currency__c != 'KRW' && pl.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c!=null){
                     pl.ASI_MFM_Paid_Amount_in_Base_Currency__c=pl.ASI_MFM_Payment_Amount__c*pl.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c;
                }else{
                    pl.ASI_MFM_Paid_Amount_in_Base_Currency__c=0;
                }
            }
            
        }
        
        AttList= [select Id, name from Attachment where ParentId =: headerId];
        if(AttList.size()>0){
            hasAttachment=true;
        }
        
        return true;        
    }//end method: init
}//end class