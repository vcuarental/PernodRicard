/* Filename:    ASI_MFM_CN_POReceipt_TriggerClass.cls
 * Author:      Leo Hui (Introv Limited)
 * Purpose:     PO Receipt Trigger Class
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2015-01-07   leo.hui@introv.com      Created
 */

public with sharing class ASI_MFM_CN_POReceipt_TriggerClass {
    public static void routineBeforeDelete(list<ASI_MFM_PO_Receipt__c> trigger_old) {
        // Not allowed to delete if the "ETL" = true
        set<id> po_set = new set<id>();
        map<id, boolean> mapETL = new map<id, boolean>();
        for (ASI_MFM_PO_Receipt__c p:trigger_old) { 
            po_set.add(p.id);
            mapETL.put(p.id, false); // initialization
        }
        list<ASI_MFM_PO_Receipt_Item__c> lstReceiptItem = [SELECT id, ASI_MFM_PO_Receipt__c, ASI_MFM_ETL__c FROM ASI_MFM_PO_Receipt_Item__c WHERE ASI_MFM_PO_Receipt__c IN :po_set];
        for (ASI_MFM_PO_Receipt_Item__c line : lstReceiptItem) {
            if (line.ASI_MFM_ETL__c == true) {
                mapETL.put(line.ASI_MFM_PO_Receipt__c, true); // ETL=true found
            }
        }
        for (ASI_MFM_PO_Receipt__c p:trigger_old) { 
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_CN') && (p.ASI_MFM_ETL__c == true || p.ASI_MFM_Auto_Receipt__c || mapETL.get(p.id) == true)) {//20180531 Introv
                p.addError('Not allowed to delete because the PO Receipt/PO Receipt Item is \'ETL\' synced');
            }
        }
    }
}