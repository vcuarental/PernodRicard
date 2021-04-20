/**
*   Class: EUR_CRM_CommonRoutine
*   
*   Contains common routines related to Object Access
*
*/
public with sharing class EUR_CRM_CommonRoutine {

    /**
    *   Function:    dmlWithPartialSuccess
    *   Description: Does DML operation, but catches any error that happens and sends alert email accordingly
    *   Parameters:  operation(mandatory) - Valid values are 'Insert', 'Upsert', 'Update', 'Delete', and 'Undelete'
    *                recordList(mandatory) - List of sObjects to be processed
    *   Return:      None
    */
    public static void dmlWithPartialSuccess(String operation, List<sObject> recordList) {
        Database.SaveResult[] recordSaveResultList;
        Database.UpsertResult[] recordUpsertResultList;
        Database.DeleteResult[] recordDeleteResultList;
        Database.UndeleteResult[] recordUndeleteResultList;
        
        try {
            // Tries to perform a specified DML operation for the sObject list
            if(operation == 'Insert') {
                recordSaveResultList = Database.insert(recordList, false);
            } else if(operation == 'Upsert') {
                recordUpsertResultList = Database.upsert(recordList, false);
            } else if(operation == 'Update') {
                recordSaveResultList = Database.update(recordList, false);
            } else if(operation == 'Delete') {
                recordDeleteResultList = Database.delete(recordList, false);
            } else if(operation == 'Undelete') {
                recordUndeleteResultList = Database.undelete(recordList, false);
            }
        } catch(DMLException e) {
            // Catches any unhandled DML exception
            System.debug('dmlWithPartialSuccess ERROR: ' + e.getMessage());
        } finally {
            // Loops to see if there are any errors and sends email accordingly
            
            // Construct a map to record the reason for failure for each record that fails
            Map<Id, String> failedRecordToReason = new Map<Id, String>();
            if(recordUpsertResultList != null) {
                for(Database.UpsertResult ur: recordUpsertResultList) {
                    if(!ur.isSuccess()) {
                        failedRecordToReason.put(ur.getId(), ur.getErrors()[0].getMessage());
                    }
                }
            } else if(recordSaveResultList != null){
                for(Database.SaveResult sr: recordSaveResultList) {
                    if(!sr.isSuccess()) {
                        failedRecordToReason.put(sr.getId(), sr.getErrors()[0].getMessage());
                    }
                }
            } else if(recordDeleteResultList != null) {
                for(Database.DeleteResult dr: recordDeleteResultList) {
                    if(!dr.isSuccess()) {
                        failedRecordToReason.put(dr.getId(), dr.getErrors()[0].getMessage());
                    }
                }                
            } else if(recordUndeleteResultList != null) {
                for(Database.UndeleteResult ur: recordUndeleteResultList) {
                    if(!ur.isSuccess()) {
                        failedRecordToReason.put(ur.getId(), ur.getErrors()[0].getMessage());
                    }
                }                
            }
            
            System.debug(failedRecordToReason);
            if(failedRecordToReason.size() > 0) {
                String content = Label.EUR_CRM_Failed_To_Update + ' ' + recordList[0].getSobjectType() + ' :\n\n';
                for(Id recordId: failedRecordToReason.keySet()) {
                    content += Label.EUR_CRM_Id + ' ' + recordId + '\n';
                    content += Label.EUR_CRM_Reason + ' ' + failedRecordToReason.get(recordId) + '\n\n';
                }
                
                System.debug('ERROR MESSAGE: ' + content);
                
                EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail('Record Update Failed', content, UserInfo.getUserId(), new String[]{});
            }  
        }
    }

}