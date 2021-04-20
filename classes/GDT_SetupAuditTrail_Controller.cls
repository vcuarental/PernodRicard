public with sharing class GDT_SetupAuditTrail_Controller {


    public GDT_SetupAuditTrail_Controller() {
        
    }

    /**
     * [runBatch description]
     */
    @AuraEnabled
    public static String runBatch(){
        try{
            Integer MAX_BATCHES = 5;
            Integer runningBatchJobs = [SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND STATUS IN ('Queued', 'Processing', 'Preparing')];
    
            if(runningBatchJobs >= MAX_BATCHES){
                return 'No resources available.  Please try again later.';
            }
            else{    
                GDT_SetupAuditTrail_Batch myBatchObject = new GDT_SetupAuditTrail_Batch();
                ID batchprocessid = Database.executebatch(myBatchObject);
                return 'Records are being updated. An email will be sent once achived.';
            }
        }catch (Exception e){
            return 'Error:  Please try again later.';
        }
    }

    @AuraEnabled
    public static List<GDT_Setup_Audit_Trail__c> getAuditTrails(String fromDate, String toDate, Boolean toControl) {
        Date fromDateD = Date.valueOf(fromDate); 
        Date toDateD = Date.valueOf(toDate); 
        toDateD = toDateD.addDays(1);
        return [SELECT Action__c,toControl__c,CreatedDate__c,CreatedById__r.username,DelegateUser__c,Display__c,Section__c FROM GDT_Setup_Audit_Trail__c where CreatedDate__c >: fromDateD and CreatedDate__c <=: toDateD and toControl__c =: toControl ORDER BY CreatedDate__c DESC NULLS FIRST LIMIT 50000];
    }



   
}