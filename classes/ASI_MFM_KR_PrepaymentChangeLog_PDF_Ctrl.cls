public class ASI_MFM_KR_PrepaymentChangeLog_PDF_Ctrl {
    
	public ASI_MFM_Prepayment_Proposal_Change_Log__c  header{get;set;}
    public Id headerId {get;set;} //current header Id
    public ASI_MFM_Prepayment_Proposal_Change_Log__c pcl{get;set;} //current header
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }                   
    
	public boolean init()
    {
        pcl = [SELECT Id, Name 
               , ASI_MFM_Payment__c
               , ASI_MFM_Payment__r.Name
               , ASI_MFM_Case__c
               , ASI_MFM_PM_Month__c
               , ASI_MFM_Reason__c
               , ASI_MFM_Status__c
               , ASI_MFM_Requested_By__c
               , ASI_MFM_Requested_By__r.Name
               , ASI_MFM_Last_Approved_Time__c
               From ASI_MFM_Prepayment_Proposal_Change_Log__c
               WHERE Id =: headerId 
               LIMIT 1];
        
        return true;        
    }//end method: init

}