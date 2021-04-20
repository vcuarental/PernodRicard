public class ASI_CRM_SG_batchGenerateCreditItemDetail implements Database.Batchable<sObject>{
    public List<String> creditNotes;
    public Integer batchCounter = 1;
    
    public ASI_CRM_SG_batchGenerateCreditItemDetail(List<String> creditNotes){
        this.creditNotes = creditNotes;
    }
    
    public database.QueryLocator start(database.batchableContext bc){
       String queryString = 'Select Id, recordTypeId, ASI_CRM_SG_Rebate_Type__c, ASI_CRM_SG_FWO_Start_Date__c, ASI_CRM_SG_FWO_End_Date__c, ASI_CRM_Wholesaler__c from ASI_CRM_Credit_Debit_Note__c where Id IN : creditNotes';
       return database.getQueryLocator(queryString);
    }
    
    public void execute (database.batchableContext bc, List<ASI_CRM_Credit_Debit_Note__c> scope){
        System.debug ('ASI_CRM_SG_batchGenerateCreditItemDetail execute: ' + batchCounter + ' and scope size ' + scope.size());
        ASI_CRM_SG_CreditNote_TriggerClass.CreateCreditNoteItemDetail(scope, true, false);
        batchCounter +=1 ;
    }
    
    public void finish(database.BatchableContext bc){
        List<ASI_CRM_Credit_Debit_Note__c> creditNoteList = [Select Id, ASI_CRM_SG_FWO_Period__c, recordTypeId, ASI_CRM_SG_Rebate_Type__c, ASI_CRM_SG_FWO_Start_Date__c, ASI_CRM_SG_FWO_End_Date__c, ASI_CRM_Wholesaler__c from ASI_CRM_Credit_Debit_Note__c where Id IN : creditNotes limit 1];
        
        ASI_CRM_SG_CreditNote_TriggerClass.deleteCreditDebitLineItems(creditNotes);
        Integer deletedNotes = ASI_CRM_SG_CreditNote_TriggerClass.deleteCreditDebitNotes(creditNotes);
        
		AsyncApexJob a = [Select Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
                          from AsyncApexJob where Id =:bc.getJobId()];
        if(creditNoteList!= null && creditNoteList.size()>0){
            ASI_CRM_Credit_Debit_Note__c creditNote = new ASI_CRM_Credit_Debit_Note__c(id = creditNoteList[0].ASI_CRM_SG_FWO_Period__c, ASI_CRM_SG_No_Of_Credit_Notes__c = creditNotes.size()-deletedNotes);
            update creditNote;
       
        }
     
	}
}