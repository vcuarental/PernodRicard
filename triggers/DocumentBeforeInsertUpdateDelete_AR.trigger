/*************************************************************************************************
*           Company: Zimmic    Developer: Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto DCM_Documents_ARG__c
**************************************************************************************************/

trigger DocumentBeforeInsertUpdateDelete_AR on DCM_Documents_ARG__c (before delete, before insert, before update) {
        
        if (trigger.isInsert){ 
            AP01_Document_AR.InsertAmountApply_ARG (trigger.New);
        }
        
        if (trigger.isUpdate){
            AP01_Document_AR.DocumentCheckPrintStatus(trigger.newMap);
            AP01_Document_AR.UpdateAmountApply_ARG (trigger.New, trigger.oldMap);
        }

        
        if (trigger.isDelete){
            AP01_Document_AR.DocumentCheckPrintStatus(trigger.oldMap);
            AP01_Document_AR.DeleteRecordReceiptsPendingSF_ARG (trigger.old);
            AP01_Document_AR.deleteDocuments(trigger.old);
            
        }
}