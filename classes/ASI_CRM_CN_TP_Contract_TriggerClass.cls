/**************************************************************************************************
 * Name: ASI_CRM_CN_TP_Contract_TriggerClass
 * Object: ASI_TH_CRM_Contract__c
 * Purpose: 
 * Author:  (jack yuan)
 * Create Date: 2020-3-23
 * Modify History:
 * 2020-3-23        Create this class
 **************************************************************************************************/
public without sharing class ASI_CRM_CN_TP_Contract_TriggerClass {
    public static final String CNTPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Trade_Plan');
    public static final String CNTPREADRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Trade_Plan_Read_Only');
    
    public static void routineBeforeUpsert(List<ASI_TH_CRM_Contract__c> trigger_new, Map<Id,ASI_TH_CRM_Contract__c> trigger_oldMap) {
        if (trigger_oldMap == null) return;
        Set<Id> poIds = new Set<Id>();
        for (ASI_TH_CRM_Contract__c po : trigger_new) {
            poIds.add(po.Id);
        }
        List<ASI_TH_CRM_Contract__c> poList = [SELECT ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_Sys_Approver_1__c, ASI_CRM_CN_Sys_Approver_2__c,
                                                    ASI_CRM_CN_Sys_Approver_3__c, ASI_CRM_CN_Sys_Approver_4__c,
                                                    ASI_CRM_CN_Sys_Approver_5__c, ASI_CRM_CN_Sys_Approver_6__c,
                                                    ASI_CRM_CN_Sys_Approver_7__c, ASI_CRM_CN_Sys_Approver_8__c,
                                                    ASI_CRM_CN_Sys_Approver_9__c, ASI_CRM_CN_Sys_Approver_10__c,
                                                    ASI_CRM_CN_Sys_Approver_11__c,
                                                    (SELECT ASI_MFM_Status__c,
                                                            ASI_MFM_Approver_1__c,
                                                            ASI_MFM_Approver_2__c,
                                                            ASI_MFM_Approver_3__c,
                                                            ASI_MFM_Approver_4__c,
                                                            ASI_MFM_Approver_5__c,
                                                            ASI_MFM_Approver_6__c,
                                                            ASI_MFM_Approver_7__c,
                                                            ASI_MFM_Approver_8__c,
                                                            ASI_MFM_Approver_9__c,
                                                            ASI_MFM_Approver_10__c,
                                                            ASI_MFM_Approver_11__c,
                                                            ASI_MFM_Approver_12__c,
                                                            ASI_CRM_CN_TP_Approval_Step2_Rule1__c,
                                                            ASI_CRM_CN_TP_Approval_Step2_Rule2__c,
                                                            ASI_CRM_CN_TP_Approval_Step2_Rule3__c
                                                     FROM Plans__r
                                                     WHERE ASI_MFM_Status__c = :ASI_CRM_CN_TP_Utils.TPSTATUSFINAL
                                                     AND (RecordTypeId = :CNTPRTID OR RecordTypeId = :CNTPREADRTID))
                                                FROM ASI_TH_CRM_Contract__c
                                                WHERE Id IN :poIds
                                                AND ASI_CRM_CN_TP_Is_Trade_Plan_CN__c = true];
        // System.debug(LoggingLevel.INFO, '*** poList: ' + JSON.serialize(poList));
        Map<String,List<ASI_MFM_Plan__c>> poIdplanMap = new Map<String,List<ASI_MFM_Plan__c>>();
        for (ASI_TH_CRM_Contract__c po : poList) {
            poIdplanMap.put(po.Id, po.Plans__r);
            
        }
       
        System.debug(LoggingLevel.INFO, '*** poIdplanMap: ' + JSON.serialize(poIdplanMap));
        Map<Id, Set<Id>> poIdUserIdsMap = new Map<Id, Set<Id>>();
        for (String poId : poIdplanMap.keySet()) {
            System.debug(LoggingLevel.INFO, '*** poId: ' + poId);
            System.debug(LoggingLevel.INFO, '*** poIdplanMap.get(poId): ' + poIdplanMap.get(poId));
            for (ASI_MFM_Plan__c tplan: poIdplanMap.get(poId)) {
                if (poIdUserIdsMap.containsKey(poId)) {
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_1__c);
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_2__c);
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_3__c);
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_4__c);
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_5__c);
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_6__c);
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_7__c);
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_8__c);
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_9__c);
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_10__c);
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_11__c);
                } else {
                    Set<Id> tpApproverIds = new Set<Id>();
                    tpApproverIds.add(tplan.ASI_MFM_Approver_1__c);
                    tpApproverIds.add(tplan.ASI_MFM_Approver_2__c);
                    tpApproverIds.add(tplan.ASI_MFM_Approver_3__c);
                    tpApproverIds.add(tplan.ASI_MFM_Approver_4__c);
                    tpApproverIds.add(tplan.ASI_MFM_Approver_5__c);
                    tpApproverIds.add(tplan.ASI_MFM_Approver_6__c);
                    tpApproverIds.add(tplan.ASI_MFM_Approver_7__c);
                    tpApproverIds.add(tplan.ASI_MFM_Approver_8__c);
                    tpApproverIds.add(tplan.ASI_MFM_Approver_9__c);
                    tpApproverIds.add(tplan.ASI_MFM_Approver_10__c);
                    tpApproverIds.add(tplan.ASI_MFM_Approver_11__c);
                    poIdUserIdsMap.put(poId, tpApproverIds);
                    
                }
                if (tplan.ASI_CRM_CN_TP_Approval_Step2_Rule1__c > 0 
                    || tplan.ASI_CRM_CN_TP_Approval_Step2_Rule2__c > 0 
                    || tplan.ASI_CRM_CN_TP_Approval_Step2_Rule3__c > 0) {
                    poIdUserIdsMap.get(poId).add(tplan.ASI_MFM_Approver_12__c);
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** poIdUserIdsMap: ' + poIdUserIdsMap);

        // PO can not approve when trade plan approved
        for (ASI_TH_CRM_Contract__c po : trigger_new) {
            System.debug(LoggingLevel.INFO, '*** po: ' + po);
            Set<Id> approverIds = poIdUserIdsMap.get(po.Id);
            System.debug(LoggingLevel.INFO, '*** approverIds: ' + approverIds);
            for (ASI_MFM_Plan__c tplan : poIdplanMap.get(po.Id)) {
                System.debug(LoggingLevel.INFO, '*** tplan: ' + tplan);
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_1__c)) {
                    po.ASI_CRM_CN_Sys_Approver_1__c = null;
                }
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_2__c)) {
                    po.ASI_CRM_CN_Sys_Approver_2__c = null;
                }
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_3__c)) {
                    po.ASI_CRM_CN_Sys_Approver_3__c = null;
                }
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_4__c)) {
                    po.ASI_CRM_CN_Sys_Approver_4__c = null;
                }
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_5__c)) {
                    po.ASI_CRM_CN_Sys_Approver_5__c = null;
                }
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_6__c)) {
                    po.ASI_CRM_CN_Sys_Approver_6__c = null;
                }
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_7__c)) {
                    po.ASI_CRM_CN_Sys_Approver_7__c = null;
                }
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_8__c)) {
                    po.ASI_CRM_CN_Sys_Approver_8__c = null;
                }
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_9__c)) {
                    po.ASI_CRM_CN_Sys_Approver_9__c = null;
                }
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_10__c)) {
                    po.ASI_CRM_CN_Sys_Approver_10__c = null;
                }
                if (approverIds.contains(po.ASI_CRM_CN_Sys_Approver_11__c)) {
                    po.ASI_CRM_CN_Sys_Approver_11__c = null;
                }
            }
        }
        
        
    }
}