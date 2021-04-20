/**************************************************************************************************
 * Name: ASI_CRM_CN_TP_Plan_TriggerClass
 * Object: ASI_MFM_Plan__c
 * Purpose: 
 * Author:  (jack yuan)
 * Create Date: 2020-3-17
 * Modify History:
 * 2020-3-17        Create this class
 **************************************************************************************************/
public without sharing class ASI_CRM_CN_TP_Plan_TriggerClass {

    public static final String COVERDOUTLETRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Event__cASI_CRM_CN_TP_Outlet');
    public static final String CNPORTID = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract');
    public static final String CNTPHDRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Approval');
    public static final String CNTPHDRDRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Approval_Read_Only');
    public static final String CNTPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Trade_Plan');
    public static final String CNTPREADRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Trade_Plan_Read_Only');
    public static final String CNBPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Budget_Plan');
    public static final String CNPLITEMRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_CRM_CN_TP_Trade_Plan_Line_Item');
    public static Boolean AFTEREXECUTEFLAG = false;
    public static Boolean AFTEREXECUTEFLAG2 = false;
    public static final String SCANDATA_COST= 'PRC - Consumer Price Promotion';

    public static void routineBeforeUpsert(List<ASI_MFM_Plan__c> trigger_new) {
        
        Map<String, List<ASI_MFM_Plan__c>> bpkeyTplansMap = new Map<String, List<ASI_MFM_Plan__c>>();
        // Set<Id> kaIdSet = new Set<Id>();
        Set<String> regionSet = new Set<String>();
        Set<Id> tpHeadIds = new Set<Id>();
        Map<Id, ASI_MFM_Plan__c> tpheadMap = new Map<Id, ASI_MFM_Plan__c>();

        for (ASI_MFM_Plan__c tplan : trigger_new) {
            regionSet.add(tplan.ASI_CRM_CN_TP_Region_Team__c);
            // kaIdSet.add(tplan.ASI_CRM_CN_TP_KA_Account__c);
            String bpkey = 'BP' + '-' + tplan.ASI_CRM_CN_TP_KA_Banner__c + '-' + tplan.ASI_MFM_Fiscal_year__c;
            if (tplan.RecordTypeId == CNTPRTID || tplan.RecordTypeId == CNTPREADRTID) {
                if (bpkeyTplansMap.containsKey(bpkey)) {
                    bpkeyTplansMap.get(bpkey).add(tplan);
                } else {
                    bpkeyTplansMap.put(bpkey, new List<ASI_MFM_Plan__c>{tplan});
                }
            }
            
            if ((tplan.RecordTypeId == CNTPHDRTID || tplan.RecordTypeId == CNTPHDRDRTID) && tplan.Id != null) {
                if (tplan.ASI_MFM_Status__c == 'Draft') {
                    tplan.RecordTypeId = CNTPHDRTID;
                } else {
                    tplan.RecordTypeId = CNTPHDRDRTID;
                }
                tpheadMap.put(tplan.Id, tplan);
            }
        }

        // Sumarry step number
        if (!tpheadMap.isEmpty()) {
            // Summary the child tp step2  number
            List<AggregateResult> tplanList = [SELECT  ASI_CRM_CN_TP_Approval__c headId, 
                                                       sum(ASI_CRM_CN_TP_Approval_Step2_Rule1__c) sumRule1,
                                                       sum(ASI_CRM_CN_TP_Approval_Step2_Rule2__c) sumRule2,
                                                       sum(ASI_CRM_CN_TP_Approval_Step2_Rule3__c) sumRule3 
                                                FROM ASI_MFM_Plan__c
                                                WHERE ASI_CRM_CN_TP_Approval__c IN :tpheadMap.keySet()
                                                AND ASI_CRM_CN_TP_Approval__c != null
                                                GROUP BY ASI_CRM_CN_TP_Approval__c];
            List<ASI_MFM_Plan__c> headTPList = new List<ASI_MFM_Plan__c>();
            for (AggregateResult tplan : tplanList) {
                // ASI_MFM_Plan__c newTPHead = new ASI_MFM_Plan__c(Id = (String)tplan.get('headId'));
                ASI_MFM_Plan__c newTPHead = tpheadMap.get((String)tplan.get('headId'));
                newTPHead.ASI_CRM_CN_TP_Head_Approval_Step2__c = (Decimal)tplan.get('sumRule1') + 
                                                                 (Decimal)tplan.get('sumRule2') + 
                                                                 (Decimal)tplan.get('sumRule3');
                newTPHead.ASI_CRM_CN_TP_Head_Approval_Step3__c = (Decimal)tplan.get('sumRule1');
                headTPList.add(newTPHead);
            }
            System.debug(LoggingLevel.INFO, '*** headTPList: ' + headTPList.size());
            if (!headTPList.isEmpty()) {
                // update headTPList;
            }
            
        }

         // Query approver settings
        Map<String, User> prcUserMap = new Map<String, User>();
        List<User> prcUsers = [SELECT Id, ManagerID, ASI_CRM_Sales_Team__c FROM User WHERE CompanyName = 'Pernod Ricard China'];
        for(User u : prcUsers){
            prcUserMap.put(u.Id, u);
        }     
        Map<String, ASI_MFM_Fix_Approval_Route__c> settingMap = new Map<String, ASI_MFM_Fix_Approval_Route__c>();
        Map<String, ASI_MFM_Fix_Approval_Route__c> userSettingMap = new Map<String, ASI_MFM_Fix_Approval_Route__c>();
        List<ASI_MFM_Fix_Approval_Route__c> approvalSettings = [SELECT ASI_MFM_Module__c, ASI_MFM_Team__c, ASI_MFM_Corporate_Approver_1__c,
                                                                        ASI_MFM_Corporate_Approver_2__c, ASI_MFM_Corporate_Approver_3__c
                                                               FROM ASI_MFM_Fix_Approval_Route__c
                                                               WHERE ASI_MFM_Team__c IN :regionSet
                                                               AND ASI_MFM_Module__c = 'Trade Plan'
                                                               AND RecordType.DeveloperName = 'ASI_MFM_CN_Fix_Approval_Route'];
        for (ASI_MFM_Fix_Approval_Route__c appSetting : approvalSettings) {
            settingMap.put(appSetting.ASI_MFM_Team__c, appSetting);
            userSettingMap.put(appSetting.ASI_MFM_Team__c + appSetting.ASI_MFM_Corporate_Approver_1__c, appSetting);
        }
        System.debug(LoggingLevel.INFO, ':*** approvalSettings ' + approvalSettings);
        System.debug(LoggingLevel.INFO, '*** bpkeyTplansMap: ' + bpkeyTplansMap);
        // Trade plan related budget plan
        List<ASI_MFM_Plan__c> bplans = [SELECT Id, ASI_CRM_CN_TP_External_ID__c 
                                        FROM ASI_MFM_Plan__c 
                                        WHERE ASI_CRM_CN_TP_External_ID__c IN :bpkeyTplansMap.keySet()
                                        AND RecordTypeId = :CNBPRTID];
        System.debug(LoggingLevel.INFO, '*** bplans: ' + bplans.size());
        for (ASI_MFM_Plan__c bplan : bplans) {
            if (bpkeyTplansMap.get(bplan.ASI_CRM_CN_TP_External_ID__c) != null) {
                for (ASI_MFM_Plan__c tplan : bpkeyTplansMap.get(bplan.ASI_CRM_CN_TP_External_ID__c)) {
                    tplan.ASI_CRM_CN_TP_Budget_Plan__c = bplan.Id;
                }
            }
        }

        

        System.debug(LoggingLevel.INFO, '*** settingMap: ' + settingMap.size());
        for (ASI_MFM_Plan__c tplan : trigger_new) {
            System.debug(LoggingLevel.INFO, '*** tplan.Name: ' + tplan.Name);
            System.debug(LoggingLevel.INFO, '*** tplan: ' + tplan);
            Boolean proceed = true;
            String currentUserid = '';
            if (prcUserMap.containsKey(tplan.OwnerId)) {
                currentUserid = prcUserMap.get(tplan.OwnerId).ManagerID;
            }
            Integer approver_count = 0;
            
            ASI_CRM_Dynamic_Approval_Route__c currentApprover = null;
            User currentApproverU = null;
            while(proceed){
                if(currentUserid != null && prcUserMap.containsKey(currentUserid)){
                    
                    if(prcUserMap.get(currentUserid) != null){
                        currentApproverU = prcUserMap.get(currentUserid);
                        currentUserid = currentApproverU.ManagerID;
                    }
                    if(currentApproverU != null){
                        setApproverByCount(tplan, approver_count, currentApproverU.Id);
                    }
                    
                    String pkey = tplan.ASI_CRM_CN_TP_Region_Team__c + '' + currentApproverU.Id;
                    String pkey2 = tplan.ASI_CRM_CN_TP_Region_Team__c;
                    System.debug(LoggingLevel.INFO, '*** pkey1: ' + pkey);
                    if(userSettingMap.containsKey(pkey)){
                        System.debug(LoggingLevel.INFO, '*** pkey2: ' + pkey);
                        setApproverByCount(tplan, approver_count, currentApproverU.Id);
                        proceed = false;
                    }
                    if (settingMap.containsKey(pkey2)) {
                        tplan.ASI_MFM_Approver_12__c = settingMap.get(pkey2).ASI_MFM_Corporate_Approver_2__c;
                        tplan.ASI_MFM_Approver_13__c = settingMap.get(pkey2).ASI_MFM_Corporate_Approver_3__c;
                    }

                    approver_count++;
                    currentApproverU = null;
                } else {
                    proceed = false;
                }
            }
            
        }
        

    }

    public static void setApproverByCount(ASI_MFM_Plan__c p, Integer approver_count, Id userId) {
        if(approver_count == 0)
            p.ASI_MFM_Approver_1__c = userId;
        
        else if(approver_count == 1)
            p.ASI_MFM_Approver_2__c = userId;
        
        else if(approver_count == 2)
            p.ASI_MFM_Approver_3__c = userId;
        
        else if(approver_count == 3)
            p.ASI_MFM_Approver_4__c = userId;
        
        else if(approver_count == 4)
            p.ASI_MFM_Approver_5__c = userId;
        
        else if(approver_count == 5)
            p.ASI_MFM_Approver_6__c = userId;
        
        else if(approver_count == 6)
            p.ASI_MFM_Approver_7__c = userId;
        
        else if(approver_count == 7)
            p.ASI_MFM_Approver_8__c = userId;
        
        else if(approver_count == 8)
            p.ASI_MFM_Approver_9__c = userId;
        
        else if(approver_count == 9)
            p.ASI_MFM_Approver_10__c = userId;
        
        else if(approver_count == 10)
            p.ASI_MFM_Approver_11__c = userId;
        
    }


    public static void routineAfterUpsert(List<ASI_MFM_Plan__c> trigger_new, Map<Id, ASI_MFM_Plan__c> trigger_oldMap) {
        System.debug(LoggingLevel.INFO, '*** :ASI_CRM_CN_TP_Plan_TriggerClass.routineAfterUpsert');

        // if (AFTEREXECUTEFLAG) return;
        // AFTEREXECUTEFLAG = true;
        // Set<Id> kaIdSet = new Set<Id>();
        Set<Id> bpIds = new Set<Id>();
        Set<String> poIdSet = new Set<String>();
        Set<Id> tpIds = new Set<Id>();
        Set<Id> customerIds = new Set<Id>();
        Map<String, List<ASI_MFM_Plan__c>> tpKeyMap = new Map<String, List<ASI_MFM_Plan__c>>();
        Map<String, List<ASI_MFM_Plan__c>> regionKeyMap = new Map<String, List<ASI_MFM_Plan__c>>();
        Map<String, List<ASI_MFM_Plan__c>> regionPKeyMap = new Map<String, List<ASI_MFM_Plan__c>>();
        Map<Id, Id> insertShareMap = new Map<Id, Id>();//Map(planId, OwnerId)
        Map<Id, Id> deleteShareMap = new Map<Id, Id>();
        for (ASI_MFM_Plan__c tplan : trigger_new) {
            System.debug(LoggingLevel.INFO, '*** tplan.RecordTypeId: ' + tplan.RecordTypeId);
            if (tplan.RecordTypeId == CNTPRTID || tplan.RecordTypeId == CNTPREADRTID) {
                System.debug(LoggingLevel.INFO, '*** tplan: ' + tplan);
                // kaIdSet.add(tplan.ASI_CRM_CN_TP_KA_Account__c);
                tpIds.add(tplan.Id);
                if (trigger_oldMap != null) {
                    if(trigger_oldMap.get(tplan.Id).ASI_CRM_CN_TP_Contract__c != tplan.ASI_CRM_CN_TP_Contract__c 
                        && trigger_oldMap.get(tplan.Id).ASI_CRM_CN_TP_Contract__c == null){
                        poIdSet.add(tplan.ASI_CRM_CN_TP_Contract__c);
                    }
                    System.debug(LoggingLevel.INFO, '*** tplan.ASI_MFM_Status__c: ' + tplan.ASI_MFM_Status__c);
                    System.debug(LoggingLevel.INFO, '*** trigger_oldMap.get(tplan.Id): ' + trigger_oldMap.get(tplan.Id).ASI_MFM_Status__c);
                    if ((tplan.ASI_MFM_Status__c == ASI_CRM_CN_TP_Utils.TPSTATUSCOMPLETE && trigger_oldMap.get(tplan.Id).ASI_MFM_Status__c != ASI_CRM_CN_TP_Utils.TPSTATUSCOMPLETE)
                        || (tplan.ASI_MFM_Status__c == ASI_CRM_CN_TP_Utils.TPSTATUSSUBMITTED && trigger_oldMap.get(tplan.Id).ASI_MFM_Status__c != ASI_CRM_CN_TP_Utils.TPSTATUSSUBMITTED)
                        || (tplan.ASI_MFM_Status__c == ASI_CRM_CN_TP_Utils.TPSTATUSFINAL && trigger_oldMap.get(tplan.Id).ASI_MFM_Status__c != ASI_CRM_CN_TP_Utils.TPSTATUSFINAL)
                        || (tplan.ASI_MFM_Status__c == ASI_CRM_CN_TP_Utils.TPSTATUSDRAFT &&  trigger_oldMap.get(tplan.Id).ASI_MFM_Status__c != ASI_CRM_CN_TP_Utils.TPSTATUSDRAFT)) {
                        bpIds.add(tplan.ASI_CRM_CN_TP_Budget_Plan__c);
                    }
                    
                    // For trade plan insert 
                    if (tplan.ASI_CRM_CN_TP_Outlet_Count__c == trigger_oldMap.get(tplan.Id).ASI_CRM_CN_TP_Outlet_Count__c) {
                        customerIds.add(tplan.ASI_CRM_CN_TP_Customer__c);
                    }
                } else {
                    customerIds.add(tplan.ASI_CRM_CN_TP_Customer__c);
                }
                
                if (String.isNotBlank(tplan.ASI_CRM_CN_TP_Cover_City__c) && tplan.ASI_CRM_CN_TP_Cover_City__c != '总部') {
                    List<String> citys = new List<String>();
                    if (tplan.ASI_CRM_CN_TP_Cover_City__c.contains(',')) {
                        citys = tplan.ASI_CRM_CN_TP_Cover_City__c.split(',');
                    } else {
                        citys.add(tplan.ASI_CRM_CN_TP_Cover_City__c);
                    }
                    for (String city : citys) {
                        String tpKey = city + '-' + tplan.ASI_CRM_CN_TP_Customer__c;
                        if (tpKeyMap.containsKey(tpKey)) {
                            tpKeyMap.get(tpKey).add(tplan);
                        } else {
                            tpKeyMap.put(tpKey, new List<ASI_MFM_Plan__c>{tplan});
                        }
                    }
                } else {

                    if (regionKeyMap.containsKey(tplan.ASI_CRM_CN_TP_Region__c + '-' + tplan.ASI_CRM_CN_TP_Customer__c)) {
                        regionKeyMap.get(tplan.ASI_CRM_CN_TP_Region__c + '-' + tplan.ASI_CRM_CN_TP_Customer__c).add(tplan);
                    } else {
                        regionKeyMap.put(tplan.ASI_CRM_CN_TP_Region__c + '-' + tplan.ASI_CRM_CN_TP_Customer__c, new List<ASI_MFM_Plan__c>{tplan});
                    }
                    if (tplan.ASI_CRM_CN_TP_Region_P__c == 'Non-Central Region' && regionPKeyMap.containsKey(tplan.ASI_CRM_CN_TP_Region_P__c + '-' + tplan.ASI_CRM_CN_TP_Customer__c)) {
                        regionPKeyMap.get(tplan.ASI_CRM_CN_TP_Region_P__c + '-' + tplan.ASI_CRM_CN_TP_Customer__c).add(tplan);
                    } else if (tplan.ASI_CRM_CN_TP_Region_P__c == 'Non-Central Region'){
                        regionPKeyMap.put(tplan.ASI_CRM_CN_TP_Region_P__c + '-' + tplan.ASI_CRM_CN_TP_Customer__c, new List<ASI_MFM_Plan__c>{tplan});
                    }
                }
               
            }

            // add budget plan share for sales
            if (tplan.RecordTypeId == CNBPRTID) {
                if (Trigger.isInsert && tplan.ASI_MFM_Budget_Owner__c != null) {
                    insertShareMap.put(tplan.Id, tplan.ASI_MFM_Budget_Owner__c);
                } else if (Trigger.isUpdate) {
                    ASI_MFM_Plan__c oldPlan = (ASI_MFM_Plan__c) Trigger.oldMap.get(tplan.Id);
                    if (oldPlan.ASI_MFM_Budget_Owner__c != tplan.ASI_MFM_Budget_Owner__c) {
                        if (oldPlan.ASI_MFM_Budget_Owner__c != null) {
                            deleteShareMap.put(tplan.Id, oldPlan.ASI_MFM_Budget_Owner__c);
                        }
                        if (tplan.ASI_MFM_Budget_Owner__c != null) {
                            insertShareMap.put(tplan.Id, tplan.ASI_MFM_Budget_Owner__c);
                        }
                    }
                }
            }
        }

        //sharing budget plan for sales
        // ASI_CRM_CN_TP_Utils.processBudgetPlanShare(insertShareMap, deleteShareMap);

        // Summary actual amount on budget plan when trade plan status to complete
        List<ASI_MFM_Plan__c> updateBPList = new List<ASI_MFM_Plan__c>();
        System.debug(LoggingLevel.INFO, '*** bpIds: ' + bpIds);
        if (!bpIds.isEmpty()) {
            // List<AggregateResult> tpItemResult = [SELECT ASI_MFM_Plan__r.ASI_CRM_CN_TP_Budget_Plan__c bPId,
            //                                             SUM(ASI_CRM_CN_TP_Promotion_Payment_Amount__c) sumPaid
            //                                       FROM ASI_MFM_Plan_Line_Item__c
            //                                       WHERE ASI_MFM_Plan__r.ASI_CRM_CN_TP_Budget_Plan__c IN :bpIds
            //                                       AND ASI_MFM_Plan__r.ASI_MFM_Status__c = :ASI_CRM_CN_TP_Utils.TPSTATUSCOMPLETE
            //                                       GROUP BY ASI_MFM_Plan__r.ASI_CRM_CN_TP_Budget_Plan__c];
            // for (AggregateResult tpItem : tpItemResult) {
            //     ASI_MFM_Plan__c upBP = new ASI_MFM_Plan__c();
            //     upBP.Id = (String)tpItem.get('bPId');
            //     upBP.ASI_MFM_Actual_Amount__c = tpItem.get('sumPaid') == null ? 0.0 : (Decimal)tpItem.get('sumPaid');
            //     updateBPList.add(upBP);
            // }
            // if (!updateBPList.isEmpty()) {
            //     update updateBPList;
            // }
            List<AggregateResult> tplanList = [SELECT ASI_CRM_CN_TP_Budget_Plan__c bpId, 
                                                      ASI_MFM_Status__c tpStatus,
                                                   sum(ASI_CRM_CN_TP_Estimated_Total_Amount__c) sumEst,
                                                   sum(ASI_CRM_CN_TP_Total_Fixed_Cost__c) sumFixed,
                                                   sum(ASI_CRM_CN_TP_Payment_Fixed_Amount__c) sumPmtFixed,
                                                   sum(ASI_CRM_CN_TP_Payment_Promotion_Amount__c) sumPmtPromotion 
                                            FROM ASI_MFM_Plan__c
                                            WHERE ASI_CRM_CN_TP_Budget_Plan__c IN :bpIds
                                            GROUP BY ASI_CRM_CN_TP_Budget_Plan__c, ASI_MFM_Status__c];
            
            Map<String, Decimal> bpIdAmtMap = new Map<String, Decimal>();
            for (AggregateResult tp : tplanList) {
                String bpId = (String)tp.get('bpId');
                String tpStatus = (String)tp.get('tpStatus');
                Decimal sumEst = (Decimal)tp.get('sumEst');
                Decimal sumFixed = (Decimal)tp.get('sumFixed');
                Decimal sumPmtFixed = (Decimal)tp.get('sumPmtFixed');
                Decimal sumPmtPromotion = (Decimal)tp.get('sumPmtPromotion');
                if (bpIdAmtMap.containsKey(bpId)) {
                    Decimal actualAmt = bpIdAmtMap.get(bpId);
                    if (tpStatus == ASI_CRM_CN_TP_Utils.TPSTATUSSUBMITTED || tpStatus == ASI_CRM_CN_TP_Utils.TPSTATUSFINAL) {
                        actualAmt = actualAmt + sumEst + sumFixed;
                    } else if (tpStatus == ASI_CRM_CN_TP_Utils.TPSTATUSCOMPLETE) {
                        actualAmt = actualAmt + sumPmtFixed + sumPmtPromotion;
                    }
                    bpIdAmtMap.put(bpId, actualAmt);
                } else {
                    if (tpStatus == ASI_CRM_CN_TP_Utils.TPSTATUSSUBMITTED || tpStatus == ASI_CRM_CN_TP_Utils.TPSTATUSFINAL) {
                        bpIdAmtMap.put(bpId, sumEst + sumFixed);
                    } else if (tpStatus == ASI_CRM_CN_TP_Utils.TPSTATUSCOMPLETE) {
                        bpIdAmtMap.put(bpId, sumPmtFixed + sumPmtPromotion);
                    } else {
                        bpIdAmtMap.put(bpId, 0);
                    }
                }
            }
            List<ASI_MFM_Plan__c> bpList = new List<ASI_MFM_Plan__c>();
            for (String bpId : bpIdAmtMap.keySet()) {
                ASI_MFM_Plan__c bp = new ASI_MFM_Plan__c(Id = bpId);
                bp.ASI_MFM_Actual_Amount__c = bpIdAmtMap.get(bpId);
                bpList.add(bp);
            }
            if (!bpList.isEmpty()) {
                update bpList;
            }
            
        }

        if(poIdSet.size() > 0) {
            System.debug(LoggingLevel.INFO, '*** po update to generate BRSF: ');
            poGenerateBRSF(poIdSet);
        }
        
        // Create covered outlet related trade plan
        System.debug(LoggingLevel.INFO, '*** customerIds: ' + customerIds.size());
        List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT ASI_CRM_CN_Parent_Outlet__c,
                                                                     Name,
                                                                     ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                                                     ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
                                                                     ASI_CRM_CN_CCity__r.ASI_CRM_Chinese_Name__c,
                                                                     ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_KA_Account_Chain__c,
                                                                     ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                                                     ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,  
                                                                     ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_Chinese_Name__c  
                                                              FROM ASI_CRM_AccountsAdditionalField__c
                                                              WHERE ASI_CRM_CN_Parent_Outlet__c IN :customerIds
                                                              AND ASI_CRM_CN_Inactive_Flag__c = false];
        System.debug(LoggingLevel.INFO, '*** customers: ' + customers.size());
        Map<String, List<ASI_CRM_AccountsAdditionalField__c>> cityKeyCustomersMap = new Map<String, List<ASI_CRM_AccountsAdditionalField__c>>();
        Map<String, List<ASI_CRM_AccountsAdditionalField__c>> regionKeyCustomersMap = new Map<String, List<ASI_CRM_AccountsAdditionalField__c>>();
        Map<String, List<ASI_CRM_AccountsAdditionalField__c>> regionPKeyCustomersMap = new Map<String, List<ASI_CRM_AccountsAdditionalField__c>>();
        Map<String, List<ASI_CRM_AccountsAdditionalField__c>> hqRegionKeyCustomersMap = new Map<String, List<ASI_CRM_AccountsAdditionalField__c>>();
        for (ASI_CRM_AccountsAdditionalField__c customer : customers) {
            String tpCityKey = customer.ASI_CRM_CN_CCity__r.ASI_CRM_Chinese_Name__c + '-' + customer.ASI_CRM_CN_Parent_Outlet__c;
            if (cityKeyCustomersMap.containsKey(tpCityKey)) {
                cityKeyCustomersMap.get(tpCityKey).add(customer);
            } else {
                cityKeyCustomersMap.put(tpCityKey, new List<ASI_CRM_AccountsAdditionalField__c>{customer});
            }
            String regionParentOutletKey = customer.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c + '-' + customer.ASI_CRM_CN_Parent_Outlet__c;
            if (regionKeyCustomersMap.containsKey(regionParentOutletKey)) {
                regionKeyCustomersMap.get(regionParentOutletKey).add(customer);
            } else {
                regionKeyCustomersMap.put(regionParentOutletKey, new List<ASI_CRM_AccountsAdditionalField__c>{customer});
            }
            String regionPkey = customer.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name + '-' + customer.ASI_CRM_CN_Parent_Outlet__c;
            if (regionPKeyCustomersMap.containsKey(regionPkey)) {
                regionPKeyCustomersMap.get(regionPkey).add(customer);
            } else {
                regionPKeyCustomersMap.put(regionPkey, new List<ASI_CRM_AccountsAdditionalField__c>{customer});
            }

            String hqRegionKey = 'Headquarter' + '-' + customer.ASI_CRM_CN_Parent_Outlet__c;
            if (customer.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name == 'Headquarter'
                && hqRegionKeyCustomersMap.containsKey(hqRegionKey)) {
                hqRegionKeyCustomersMap.get(hqRegionKey).add(customer);
            } else if (customer.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name == 'Headquarter'
                && !hqRegionKeyCustomersMap.containsKey(hqRegionKey)){
                hqRegionKeyCustomersMap.put(hqRegionKey, new List<ASI_CRM_AccountsAdditionalField__c>{customer});
            }
        }
        
        // List<ASI_MFM_Event__c> coveredOutlets = new List<ASI_MFM_Event__c>();
        Map<String, ASI_MFM_Event__c> coveredOutletMap = new Map<String, ASI_MFM_Event__c>();
        System.debug(LoggingLevel.INFO, '*** tpKeyMap: ' + tpKeyMap.size());
        System.debug(LoggingLevel.INFO, '*** cityKeyCustomersMap: ' + cityKeyCustomersMap.size());
        for (String tpKey : tpKeyMap.keySet()) {
            List<ASI_MFM_Plan__c> tplans = tpKeyMap.get(tpKey);
            for (ASI_MFM_Plan__c tplan : tplans) {
                if (cityKeyCustomersMap.containsKey(tpKey)) {
                    for (ASI_CRM_AccountsAdditionalField__c cus : cityKeyCustomersMap.get(tpKey)) {
                        ASI_MFM_Event__c coveredOutlet = new ASI_MFM_Event__c();
                        coveredOutlet.Name = cus.Name;
                        coveredOutlet.RecordTypeId = COVERDOUTLETRTID;
                        coveredOutlet.ASI_MFM_Start_Date__c = tplan.ASI_MFM_Start_Date__c;
                        coveredOutlet.ASI_MFM_End_Date__c = tplan.ASI_MFM_End_Date__c;
                        coveredOutlet.ASI_CRM_CN_TP_Customer__c = cus.Id;
                        coveredOutlet.ASI_CRM_CN_TP_Plan__c = tplan.Id;
                        coveredOutlet.ASI_CRM_CN_TP_External_ID__c = tplan.Id + '-' + cus.Id;
                        // coveredOutlets.add(coveredOutlet);
                        coveredOutletMap.put(coveredOutlet.ASI_CRM_CN_TP_External_ID__c, coveredOutlet);
                    }
                }
            }  
        }

        System.debug(LoggingLevel.INFO, '*** regionPKeyMap: ' + regionPKeyMap.size());
        System.debug(LoggingLevel.INFO, '*** regionPKeyCustomersMap: ' + regionPKeyCustomersMap.size());
        for (String regionPKey : regionPKeyMap.keySet()) {
            List<ASI_MFM_Plan__c> tplans = regionPKeyMap.get(regionPKey);
            for (ASI_MFM_Plan__c tplan : tplans) {
                List<ASI_CRM_AccountsAdditionalField__c> custms = new List<ASI_CRM_AccountsAdditionalField__c>();
                for (String nameKey : regionPKeyCustomersMap.keySet()) {
                    if (!nameKey.contains('Central')) {
                        custms.addAll(regionPKeyCustomersMap.get(nameKey));
                    }
                }
                System.debug(LoggingLevel.INFO, '*** custms1: ' + custms.size());
                for (ASI_CRM_AccountsAdditionalField__c cus : custms) {
                    ASI_MFM_Event__c coveredOutlet = new ASI_MFM_Event__c();
                    coveredOutlet.Name = cus.Name;
                    coveredOutlet.RecordTypeId = COVERDOUTLETRTID;
                    coveredOutlet.ASI_MFM_Start_Date__c = tplan.ASI_MFM_Start_Date__c;
                    coveredOutlet.ASI_MFM_End_Date__c = tplan.ASI_MFM_End_Date__c;
                    coveredOutlet.ASI_CRM_CN_TP_Customer__c = cus.Id;
                    coveredOutlet.ASI_CRM_CN_TP_Plan__c = tplan.Id;
                    coveredOutlet.ASI_CRM_CN_TP_External_ID__c = tplan.Id + '-' + cus.Id;
                    // coveredOutlets.add(coveredOutlet);
                    coveredOutletMap.put(coveredOutlet.ASI_CRM_CN_TP_External_ID__c, coveredOutlet);
                }
                
            }  
        }

        System.debug(LoggingLevel.INFO, '*** regionKeyMap.size(): ' + regionKeyMap.size());
        for (String regionKey : regionKeyMap.keySet()) {
            System.debug(LoggingLevel.INFO, '*** regionKey: ' + regionKey);
            List<ASI_MFM_Plan__c> tplans = regionKeyMap.get(regionKey);
            System.debug(LoggingLevel.INFO, '*** tplans.size(): ' + tplans.size());
            for (ASI_MFM_Plan__c tplan : tplans) {
                List<ASI_CRM_AccountsAdditionalField__c> custms = new List<ASI_CRM_AccountsAdditionalField__c>();
                if (regionKeyCustomersMap.containsKey(regionKey)) {
                    System.debug(LoggingLevel.INFO, '*** regionKeyCustomersMap.size(): ' + regionKeyCustomersMap.size());
                    custms = regionKeyCustomersMap.get(regionKey);
                } else if (hqRegionKeyCustomersMap.containsKey(tplan.ASI_CRM_CN_TP_Region_Team__c)) {
                    custms = hqRegionKeyCustomersMap.get(tplan.ASI_CRM_CN_TP_Region_Team__c);
                }
                 System.debug(LoggingLevel.INFO, '*** custms: ' + custms.size()); 
                for (ASI_CRM_AccountsAdditionalField__c cus : custms) {
                    ASI_MFM_Event__c coveredOutlet = new ASI_MFM_Event__c();
                    coveredOutlet.Name = cus.Name;
                    coveredOutlet.RecordTypeId = COVERDOUTLETRTID;
                    coveredOutlet.ASI_MFM_Start_Date__c = tplan.ASI_MFM_Start_Date__c;
                    coveredOutlet.ASI_MFM_End_Date__c = tplan.ASI_MFM_End_Date__c;
                    coveredOutlet.ASI_CRM_CN_TP_Customer__c = cus.Id;
                    coveredOutlet.ASI_CRM_CN_TP_Plan__c = tplan.Id;
                    coveredOutlet.ASI_CRM_CN_TP_External_ID__c = tplan.Id + '-' + cus.Id;
                    // coveredOutlets.add(coveredOutlet);
                    coveredOutletMap.put(coveredOutlet.ASI_CRM_CN_TP_External_ID__c, coveredOutlet);
                }
                
            }  
        }

        System.debug(LoggingLevel.INFO, '*** coveredOutletMap.size(): ' + coveredOutletMap.size());
        upsert coveredOutletMap.values() ASI_CRM_CN_TP_External_ID__c;
        
        if (trigger_oldMap == null) {
            List<ASI_MFM_Plan__c> tplans = [SELECT ASI_CRM_CN_TP_Outlet_Count__c,
                                                   ASI_CRM_CN_TP_Region_Team__c,
                                                   ASI_MFM_Approver_1__c,
                                                  (SELECT Id FROM Events__r) 
                                            FROM ASI_MFM_Plan__c 
                                            WHERE Id IN :tpIds];
            for (ASI_MFM_Plan__c tplan : tplans) {
                tplan.ASI_CRM_CN_TP_Outlet_Count__c = tplan.Events__r.size();
                tplan.ASI_CRM_CN_TP_Outlet_Count__c = tplan.ASI_CRM_CN_TP_Outlet_Count__c == 0 ? 1 : tplan.ASI_CRM_CN_TP_Outlet_Count__c;
            }
            System.debug(LoggingLevel.INFO, '*** tplans: ' + tplans.size());
            
            update tplans;
        }
        
        
    }

    public static void tradePlanApporvedAfterUpdate(List<ASI_MFM_Plan__c> trigger_new, Map<Id,ASI_MFM_Plan__c> trigger_oldMap) {
        System.debug(LoggingLevel.INFO, '*** tradePlanApporvedAfterUpdate: ');
        
        Set<Id> poIdSet = new Set<Id>();
        Set<Id> bpIds = new Set<Id>();
        Set<Id> tpHeadIds = new Set<Id>();
        for (ASI_MFM_Plan__c tplan : trigger_new) {
            if (tplan.ASI_MFM_Status__c == ASI_CRM_CN_TP_Utils.TPSTATUSFINAL && trigger_oldMap.get(tplan.Id).ASI_MFM_Status__c != ASI_CRM_CN_TP_Utils.TPSTATUSFINAL) {
                if ((tplan.RecordTypeId == CNTPRTID || tplan.RecordTypeId == CNTPREADRTID) && tplan.ASI_CRM_CN_TP_Contract__c != null) {
                    poIdSet.add(tplan.ASI_CRM_CN_TP_Contract__c);
                    // bpIds.add(tplan.ASI_CRM_CN_TP_Budget_Plan__c);
                }
            }
            // if ((tplan.ASI_MFM_Status__c == ASI_CRM_CN_TP_Utils.TPSTATUSSUBMITTED 
            //       && trigger_oldMap.get(tplan.Id).ASI_MFM_Status__c != ASI_CRM_CN_TP_Utils.TPSTATUSSUBMITTED)
            //     || 
            //     (tplan.ASI_MFM_Status__c == ASI_CRM_CN_TP_Utils.TPSTATUSDRAFT 
            //         &&  trigger_oldMap.get(tplan.Id).ASI_MFM_Status__c != ASI_CRM_CN_TP_Utils.TPSTATUSDRAFT)){
            //     if (tplan.RecordTypeId == CNTPRTID || tplan.RecordTypeId == CNTPREADRTID) {
            //         bpIds.add(tplan.ASI_CRM_CN_TP_Budget_Plan__c);
            //     }
            // }

            if ((tplan.ASI_MFM_Status__c != trigger_oldMap.get(tplan.Id).ASI_MFM_Status__c || tplan.ASI_MFM_Status__c == ASI_CRM_CN_TP_Utils.TPSTATUSDRAFT) 
                 && (tplan.RecordTypeId == CNTPHDRTID || tplan.RecordTypeId == CNTPHDRDRTID)) {
                tpHeadIds.add(tplan.Id);
            }
        }
        System.debug(LoggingLevel.INFO, '*** tpHeadIds: ' + tpHeadIds.size());

        // Update child trade plan status when head trade plan status changed
        // List<ASI_MFM_Plan__c> tpHeadList = new List<ASI_MFM_Plan__c>();
        if (tpHeadIds.size() > 0) {
            List<ASI_MFM_Plan__c> headTPList = [SELECT ASI_MFM_Status__c, 
                                                    (SELECT ASI_MFM_Status__c 
                                                     FROM Approval_Plans__r) 
                                            FROM ASI_MFM_Plan__c
                                            WHERE Id IN :tpHeadIds];
            List<ASI_MFM_Plan__c> upPlanList = new List<ASI_MFM_Plan__c>();
            for (ASI_MFM_Plan__c tphead : headTPList) {
                // ASI_MFM_Plan__c newTPHead = new ASI_MFM_Plan__c(Id = tphead.Id);
                // if (tphead.ASI_MFM_Status__c == 'Draft') {
                //     newTPHead.RecordTypeId = CNTPHDRTID;
                // } else {
                //     newTPHead.RecordTypeId = CNTPHDRDRTID;
                // }
                // tpHeadList.add(newTPHead);
                for (ASI_MFM_Plan__c plan : tphead.Approval_Plans__r) {
                    plan.ASI_MFM_Status__c = tphead.ASI_MFM_Status__c;
                    if (plan.ASI_MFM_Status__c == 'Draft') {
                        plan.RecordTypeId = CNTPRTID;
                    } else {
                        plan.RecordTypeId = CNTPREADRTID;
                    } 
                    upPlanList.add(plan);
                }
            }
            System.debug(LoggingLevel.INFO, '*** upPlanList: ' + upPlanList.size());
            if (!upPlanList.isEmpty()) {
                update upPlanList;
            }
            // if (!tpHeadList.isEmpty()) {
            //     // update tpHeadList;
            //     Database.update(tpHeadList,false);
            // }
        }
        
        // Calculate Est amount on budget plan when trade plan approved
        // if (!bpIds.isEmpty()) {
        //     List<AggregateResult> tplanList = [SELECT ASI_CRM_CN_TP_Budget_Plan__c bpId, 
        //                                            sum(ASI_CRM_CN_TP_Estimated_Total_Amount__c) sumEst,
        //                                            sum(ASI_CRM_CN_TP_Total_Fixed_Cost__c) sumFixed 
        //                                     FROM ASI_MFM_Plan__c
        //                                     WHERE ASI_CRM_CN_TP_Budget_Plan__c IN :bpIds
        //                                     AND ASI_MFM_Status__c != :ASI_CRM_CN_TP_Utils.TPSTATUSDRAFT
        //                                     GROUP BY ASI_CRM_CN_TP_Budget_Plan__c];
        //     List<ASI_MFM_Plan__c> bpList = new List<ASI_MFM_Plan__c>();
        //     for (AggregateResult tp : tplanList) {
        //         String bpId = (String)tp.get('bpId');
        //         Decimal estAmount = (Decimal)tp.get('sumEst');
        //         ASI_MFM_Plan__c bp = new ASI_MFM_Plan__c(Id = bpId);
        //         bp.ASI_CRM_CN_TP_Estimated_Amount__c = estAmount;
        //         bp.ASI_CRM_CN_TP_Fixed_Cost__c = (Decimal)tp.get('sumFixed');
        //         bpList.add(bp);
        //     }
        //     update bpList;
        // }
        System.debug(LoggingLevel.INFO, '*** poIdSet: ' + poIdSet.size());
        
        if (!poIdSet.isEmpty()) {
            POModification(poIdSet);
            ApprovalProcessRecordsDelete(poIdSet);
            List<ASI_TH_CRM_Contract__c> oldPOList = new List<ASI_TH_CRM_Contract__c>();
            for (String poId : poIdSet) {
                if (String.isNotBlank(poId)) {
                    ASI_TH_CRM_Contract__c oldPO = new ASI_TH_CRM_Contract__c(Id = poId);
                    oldPO.ASI_CRM_CN_Status__c = 'Archived';
                    oldPOList.add(oldPO);
                }
                
            }
            update oldPOList;
            
            
        }
        
    }

    public static void ApprovalProcessRecordsDelete(Set<Id> poIdSet) {
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        //Get ProcessInstance Items
        Map<ID,ProcessInstance> piMap = New Map<ID,ProcessInstance>([Select Id from ProcessInstance where TargetObjectId IN :poIdSet]);
        for(ProcessInstanceWorkItem pp : [Select Id from ProcessInstanceWorkItem where ProcessInstanceId IN :piMap.keySet()]){
            // if there's a work item, set the action to 'removed' and execute
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setAction('Removed');
            req2.setWorkitemId(pp.Id);
            req2.setComments('A new version of PO is generated and this PO is automatically archived');
            requests.add(req2);
        }
        Approval.ProcessResult[] processResults = null;
        processResults = Approval.process(requests, true);
}

    @future
    public static void POModification(Set<Id> poIdSet) {
        Set<String> poIdGenerateBrsfSet = new Set<String>();
        Map<Id, List<ASI_MFM_Plan__c>> poPlansMap = new Map<Id, List<ASI_MFM_Plan__c>>();
        Map<Id, List<ASI_CRM_Contract_Cost__c>> poCostsMap = new Map<Id, List<ASI_CRM_Contract_Cost__c>>();
        Map<Id, List<ASI_CRM_ContractTarget__c>> poTargetsMap = new Map<Id, List<ASI_CRM_ContractTarget__c>>();
        Map<Id, List<ASI_CRM_CN_Covered_Outlet__c>> poOutletsMap = new Map<Id, List<ASI_CRM_CN_Covered_Outlet__c>>();
        Map<Id, List<ASI_TH_CRM_PaymentRequest__c>> poPaymentsMap = new Map<Id, List<ASI_TH_CRM_PaymentRequest__c>>();
        Map<Id, List<ASI_CRM_Approval_Comment__c>> poCommentsMap = new Map<Id, List<ASI_CRM_Approval_Comment__c>>();
        // Map<Id, List<Attachment>> poAttsMap = new Map<Id, List<Attachment>>();
        List<ASI_TH_CRM_Contract__c> polist = [SELECT ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_PO_Version__c, Name,ASI_CRM_CN_Effective_Date__c,
                                                      ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Bottle_Collection_Rate__c,OwnerId,ASI_CRM_Contract_Version_Checking__c, 
                                                      ASI_CRM_CN_Outlet_WS__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_Source_of_Contract__c,
                                                      ASI_CRM_CN_Status__c, ASI_CRM_Investment_Type__c, ASI_CRM_CN_Contract_Upload__c,
                                                      ASI_CRM_CN_Description__c, ASI_CRM_Martell_BC_Rate__c, ASI_CRM_CN_Group_Contract__c,
                                                      ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c, ASI_CRM_PO_City__c,ASI_CRM_CN_TP_Is_Trade_Plan_CN__c,
                                                      ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Budget_LE__c,ASI_TH_CRM_Outlet__c,
                                                      ASI_CRM_CN_Sys_Approver_1__c,ASI_CRM_CN_Sys_Approver_2__c, ASI_CRM_CN_Sys_Approver_3__c, 
                                                      ASI_CRM_CN_Sys_Approver_4__c, ASI_CRM_CN_Sys_Approver_5__c, ASI_CRM_CN_Sys_Approver_6__c,
                                                      ASI_CRM_CN_Sys_Approver_7__c, ASI_CRM_CN_Sys_Approver_8__c, ASI_CRM_CN_Sys_Approver_9__c,
                                                      ASI_CRM_CN_Sys_Approver_10__c, ASI_CRM_CN_Sys_Approver_11__c,ASI_CRM_CN_V0_0_PO_version__c,
                                                     (SELECT Id, ASI_CRM_CN_TP_Contract__c FROM Plans__r),
                                                     (SELECT ASI_CRM_CN_Contract__c, 
                                                             ASI_CRM_CN_Estimate_Amount__c,
                                                             ASI_CRM_CNY_Est__c,
                                                             ASI_CRM_Other_Est__c,
                                                             Name,
                                                             ASI_CRM_CN_Contract_Amount__c,
                                                             RecordTypeId,
                                                             ASI_CRM_MAF_Est__c, 
                                                             ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c,
                                                             ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c,
                                                             ASI_CRM_CN_Other_Cost_Payment_Request__c
                                                      FROM Contract_Costs__r),
                                                     // (SELECT ASI_CRM_Contract__c FROM Contract_Target__r),
                                                     // (SELECT ASI_CRM_CN_Contract__c FROM Covered_Outlet__r),
                                                     (SELECT ASI_TH_CRM_Contract__c FROM ASI_TH_CRM_PaymentRequests_Contract__r),
                                                     (SELECT Id, ASI_CRM_Contract__c FROM Contract_Approval_Comments__r)
                                                     // (SELECT ParentId, Name, Description, Body FROM Attachments)
                                                  FROM ASI_TH_CRM_Contract__c 
                                                  WHERE Id IN :poIdSet
                                                    AND ASI_CRM_CN_TP_Is_Trade_Plan_CN__c = true];
        for (ASI_TH_CRM_Contract__c po : polist) {
            poPlansMap.put(po.Id, po.Plans__r);
            poCostsMap.put(po.Id, po.Contract_Costs__r);
            // poTargetsMap.put(po.Id, po.Contract_Target__r);
            // poOutletsMap.put(po.Id, po.Covered_Outlet__r);
            poPaymentsMap.put(po.Id, po.ASI_TH_CRM_PaymentRequests_Contract__r);
            poCommentsMap.put(po.Id, po.Contract_Approval_Comments__r);
            // poAttsMap.put(po.Id, po.Attachments);
        }

        List<AggregateResult> tplans = [SELECT ASI_CRM_CN_TP_Contract__c, 
                                               min(ASI_MFM_Start_Date__c) minDate, 
                                               max(ASI_MFM_End_Date__c) maxDate 
                                        FROM ASI_MFM_Plan__c 
                                        WHERE ASI_CRM_CN_TP_Contract__c IN :poIdSet
                                        GROUP BY ASI_CRM_CN_TP_Contract__c];
        Map<String, Date> startDateMap = new Map<String, Date>();
        Map<String, Date> endDateMap = new Map<String, Date>();
        for (AggregateResult tp : tplans) {
            startDateMap.put((String)tp.get('ASI_CRM_CN_TP_Contract__c'), (Date)tp.get('minDate'));
            endDateMap.put((String)tp.get('ASI_CRM_CN_TP_Contract__c'), (Date)tp.get('maxDate'));
        }

        // Create new PO version when trade plan approved 
        Map<String, ASI_TH_CRM_Contract__c> oldNewPOMap = new  Map<String, ASI_TH_CRM_Contract__c>();
        for (ASI_TH_CRM_Contract__c po : polist) {
            ASI_TH_CRM_Contract__c newPO = po.clone();
            newPO.RecordTypeId = CNPORTID;
            newPO.Name = po.Name + '1';
            newPO.ASI_CRM_CN_Last_PO_version__c = po.Id;
            newPo.ASI_CRM_CN_V0_0_PO_version__c = po.ASI_CRM_CN_V0_0_PO_version__c == null && po.ASI_CRM_CN_PO_Version__c == '0.0' ? po.Id : po.ASI_CRM_CN_V0_0_PO_version__c;
            newPO.ASI_TH_CRM_Promotion_Type__c = 'Promotion';
            newPO.ASI_CRM_CN_Status__c = ASI_CRM_CN_TP_Utils.TPSTATUSDRAFT;
            newPO.ASI_CRM_CN_PO_Version__c = String.valueOf(Decimal.valueOf(po.ASI_CRM_CN_PO_Version__c) + 0.1);
            newPO.ASI_CRM_CN_PO_Start_Date__c = startDateMap.get(po.Id);
            newPO.ASI_CRM_CN_PO_End_Date__c = endDateMap.get(po.Id);
            newPO.ASI_CRM_CN_TP_Is_Trade_Plan_CN__c = true;
            oldNewPOMap.put(po.Id, newPO);
        }
        
        System.debug(LoggingLevel.INFO, '*** oldNewPOMap: ' + oldNewPOMap.size());
        insert oldNewPOMap.values();

        // Update all plans to relate new PO
        List<ASI_MFM_Plan__c> upTPList = new List<ASI_MFM_Plan__c>();
        List<ASI_CRM_Contract_Cost__c> upCostList = new List<ASI_CRM_Contract_Cost__c>();
        List<ASI_CRM_ContractTarget__c> upTargList = new List<ASI_CRM_ContractTarget__c>();
        List<ASI_CRM_CN_Covered_Outlet__c> upOutletList = new List<ASI_CRM_CN_Covered_Outlet__c>();
        List<ASI_TH_CRM_PaymentRequest__c> upPmtList = new List<ASI_TH_CRM_PaymentRequest__c>();
        List<ASI_CRM_Approval_Comment__c> upCommentsList = new List<ASI_CRM_Approval_Comment__c>();
        List<Attachment> upAttList = new List<Attachment>();
        for (String poId : poPlansMap.keySet()) {
            ASI_TH_CRM_Contract__c newPO = oldNewPOMap.get(poId);
            for (ASI_MFM_Plan__c tplan : poPlansMap.get(poId)) {
                tplan.ASI_CRM_CN_TP_Contract__c = newPO.Id;
                upTPList.add(tplan);
                poIdGenerateBrsfSet.add(newPO.Id);
            }
            for (ASI_CRM_Contract_Cost__c cost : poCostsMap.get(poId)) {
                ASI_CRM_Contract_Cost__c cost2 = cost.clone();
                cost2.ASI_CRM_CN_Contract__c = newPO.Id;
                upCostList.add(cost2);
            }
            // for (ASI_CRM_ContractTarget__c targ : poTargetsMap.get(poId)) {
            //     targ.ASI_CRM_Contract__c = newPO.Id;
            //     upTargList.add(targ);
            // }
            // for (ASI_CRM_CN_Covered_Outlet__c outlet : poOutletsMap.get(poId)) {
            //     outlet.ASI_CRM_CN_Contract__c = newPO.Id;
            //     upOutletList.add(outlet);
            // }
            for (ASI_CRM_Approval_Comment__c approvalComt : poCommentsMap.get(poId)) {
                approvalComt.ASI_CRM_Contract__c = newPO.Id;
                upCommentsList.add(approvalComt);
            }
            for (ASI_TH_CRM_PaymentRequest__c pmt : poPaymentsMap.get(poId)) {
                pmt.ASI_TH_CRM_Contract__c = newPO.Id;
                upPmtList.add(pmt);
            }
            
        }
        if (!upTPList.isEmpty()) {
            update upTPList;
        }

        if (!upCostList.isEmpty()) {
            insert upCostList;
        }

        
        System.debug(LoggingLevel.INFO, '*** poIdGenerateBrsfSet: ' + poIdGenerateBrsfSet);
        if(poIdGenerateBrsfSet.size() > 0) {
            System.debug(LoggingLevel.INFO, '*** po version change to generate BRSF: ');
            poGenerateBRSF(poIdGenerateBrsfSet);
        }
        // update upTargList;
        // update upOutletList;
        if (!upPmtList.isEmpty()) {
            update upPmtList;
        }
        if (!upCommentsList.isEmpty()) {
            update upCommentsList;
        }
    }

    //poGenerateBRSF
    public static void poGenerateBRSF(Set<String> poIdSet) {

        System.debug(LoggingLevel.INFO, '*** poIdSet: ' + poIdSet);

        List<ASI_CRM_Contract_Cost__c> costList = [select ASI_CRM_CN_Estimate_Amount__c,
                                                            ASI_CRM_CNY_Est__c,
                                                            ASI_CRM_Other_Est__c,
                                                            ASI_CRM_CN_Contract__c,
                                                            ASI_CRM_CN_Contract__r.ASI_CRM_CN_Description__c,
                                                            Name
                                                   from ASI_CRM_Contract_Cost__c
                                                   where ASI_CRM_CN_Contract__c IN :poIdSet
                                                   and (Name = :Label.ASI_CRM_CN_TP_PRC
                                                   or Name = :SCANDATA_COST
                                                   or Name =  :Label.ASI_CRM_CN_TP_Total_fixedCost)];

        //Map<String, Decimal> tpamountMap = new Map<String, Decimal>();
        Map<String, Decimal> totalFixedCostMap = new Map<String, Decimal>();

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsfList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<AggregateResult> subbrandResults = [select ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c poId,
                                                         ASI_MFM_Sub_brand_Code__c sudBrandId,
                                                         SUM(ASI_CRM_CN_TP_VolumesIn9L__c) qty,
                                                         SUM(ASI_CRM_CN_TP_Estimated_Amount__c) promotionCost,
                                                         SUM(ASI_CRM_CN_TP_Fixed_Cost__c) fixedCost,
                                                         ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__c regionId
                                                from ASI_MFM_Plan_Line_Item__c
                                                // where ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c = 'a8cM00000009M7RIAU'
                                                where ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c IN :poIdSet
                                                 group by ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__c,
                                                          ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c,
                                                          ASI_MFM_Sub_brand_Code__c];
        Set<String> sudbrandIdSet = new Set<String>();
        Set<String> regionIdSet = new Set<String>();
        for (AggregateResult agg : subbrandResults) {
            if (agg.get('sudBrandId') != null) sudbrandIdSet.add(String.valueOf(agg.get('sudBrandId')));
            if (agg.get('regionId') != null) regionIdSet.add(String.valueOf(agg.get('regionId')));
        }
        System.debug(LoggingLevel.INFO, '*** JSON.serialize(subbrandResults): ' + JSON.serialize(subbrandResults));

        Map<String, Decimal> promotionModeCostMap = new Map<String, Decimal>();
        List<AggregateResult> promotionModeResults = [select ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c poId,
                                                         ASI_CRM_CN_TP_Promotion_Mode__c promotionMode,
                                                         SUM(ASI_CRM_CN_TP_Estimated_Amount__c) promotionCost
                                                        from ASI_MFM_Plan_Line_Item__c
                                                        where ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c IN :poIdSet
                                                         group by ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c,
                                                                  ASI_CRM_CN_TP_Promotion_Mode__c];
        for (AggregateResult agg : promotionModeResults) {
            if (agg.get('promotionMode') != null && agg.get('promotionCost') != null && String.valueOf(agg.get('promotionMode')).contains('scan data')) {
                if (promotionModeCostMap.containsKey(String.valueOf(agg.get('poId')) + SCANDATA_COST)) {
                    Decimal newPromotionCost = promotionModeCostMap.get(String.valueOf(agg.get('poId')) + SCANDATA_COST) + Decimal.valueOf(String.valueOf(agg.get('promotionCost')));
                    promotionModeCostMap.put(String.valueOf(agg.get('poId')) + SCANDATA_COST, newPromotionCost);
                }
                promotionModeCostMap.put(String.valueOf(agg.get('poId')) + SCANDATA_COST, Decimal.valueOf(String.valueOf(agg.get('promotionCost'))));
            } else if (agg.get('promotionMode') != null && agg.get('promotionCost') != null && !String.valueOf(agg.get('promotionMode')).contains('scan data')) {
                if (promotionModeCostMap.containsKey(String.valueOf(agg.get('poId')) + Label.ASI_CRM_CN_TP_PRC)) {
                    Decimal newPromotionCost = promotionModeCostMap.get(String.valueOf(agg.get('poId')) + Label.ASI_CRM_CN_TP_PRC) + Decimal.valueOf(String.valueOf(agg.get('promotionCost')));
                    promotionModeCostMap.put(String.valueOf(agg.get('poId')) + Label.ASI_CRM_CN_TP_PRC, newPromotionCost);
                }
                promotionModeCostMap.put(String.valueOf(agg.get('poId')) + Label.ASI_CRM_CN_TP_PRC, Decimal.valueOf(String.valueOf(agg.get('promotionCost'))));
            }
        }

        List<ASI_CRM_CM_GS__c> cmgsList = [select ASI_CRM_CM_GS_per_9L__c,
                                                   ASI_CRM_PRODUCTCODE__c,
                                                   ASI_CRM_Region__c,
                                                   ASI_CRM_YEAR__c,
                                                   ASI_CRM_CN_Month__c,
                                                   ASI_CRM_TYPE__c,
                                                   ASI_CRM_VERSION__c
                                            from ASI_CRM_CM_GS__c
                                            where ASI_CRM_PRODUCTCODE__c IN :sudbrandIdSet
                                            and ASI_CRM_Region__c IN :regionIdSet
                                            and (ASI_CRM_YEAR__c = :String.valueOf(Date.today().year())
                                                 OR ASI_CRM_YEAR__c = :String.valueOf(Date.today().addYears(1).year()))
                                            and ASI_CRM_CN_Month__c = 6 
                                            and RecordType.DeveloperName = :ASI_CRM_CN_TP_Utils.CM_GS_RTNAME
                                            and (ASI_CRM_TYPE__c = :ASI_CRM_CN_TP_Utils.BUDGET_CM
                                            or ASI_CRM_TYPE__c = :ASI_CRM_CN_TP_Utils.BUDGET_GS)
                                            order by ASI_CRM_VERSION__c desc];
        System.debug(LoggingLevel.INFO, '*** cmgsList: ' + cmgsList);
        Map<String, List<ASI_CRM_CM_GS__c>> cmgsMap = new Map<String, List<ASI_CRM_CM_GS__c>>();
        for (ASI_CRM_CM_GS__c cmgs : cmgsList) {
            if ((Date.today().month() > 6 && cmgs.ASI_CRM_YEAR__c == String.valueOf(Date.today().year())) || (Date.today().month() <= 6 && cmgs.ASI_CRM_YEAR__c == String.valueOf(Date.today().addYears(1).year()))){
                continue;
            }
            String mappingKey = cmgs.ASI_CRM_PRODUCTCODE__c + '-' + cmgs.ASI_CRM_Region__c + '-' +cmgs.ASI_CRM_TYPE__c;
            List<ASI_CRM_CM_GS__c> tempList = cmgsMap.get(mappingKey);
            if(tempList != null) {
                tempList.add(cmgs);
            } else {
                tempList = new List<ASI_CRM_CM_GS__c>{cmgs};
            }
            cmgsMap.put(mappingKey, tempList);
        }
        System.debug(LoggingLevel.INFO, '*** cmgsMap: ' + cmgsMap);
        Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c> subContractBRSFMap = new Map<String,ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for (AggregateResult agg : subbrandResults) {
            ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf = new ASI_CRM_CN_Contract_BRSF_Line_Item__c();
            brsf.RecordTypeId = Schema.getGlobalDescribe().get('ASI_CRM_CN_Contract_BRSF_Line_Item__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ASI_CRM_CN_Contract_TradePlan_BRSF_Line_Item').getRecordTypeId();
            brsf.ASI_CRM_CN_Contract__c = String.valueOf(agg.get('poId'));
            brsf.ASI_CRM_CN_Sub_Brand__c = String.valueOf(agg.get('sudBrandId'));

            brsf.ASI_CRM_CN_TP_Promotion_Cost__c = agg.get('promotionCost')!=null?Decimal.valueOf(String.valueOf(agg.get('promotionCost'))):0;
            brsf.ASI_CRM_CN_TP_Fixed_Cost__c = agg.get('fixedCost')!=null?Decimal.valueOf(String.valueOf(agg.get('fixedCost'))):0;
            brsf.ASI_CRM_CN_Total_Volume_9L__c = agg.get('qty')!=null?Decimal.valueOf(String.valueOf(agg.get('qty'))):0;

            String mappingKeyPrefix = agg.get('sudBrandId') + '-' + agg.get('regionId') + '-';
            brsf.ASI_CRM_CN_TP_CM_Per_9L__c = cmgsMap.get(mappingKeyPrefix + ASI_CRM_CN_TP_Utils.BUDGET_CM) != null &&cmgsMap.get(mappingKeyPrefix + ASI_CRM_CN_TP_Utils.BUDGET_CM).size()>0?cmgsMap.get(mappingKeyPrefix + ASI_CRM_CN_TP_Utils.BUDGET_CM)[0].ASI_CRM_CM_GS_per_9L__c:0;
            brsf.ASI_CRM_CN_GS_Per_9L__c = cmgsMap.get(mappingKeyPrefix + ASI_CRM_CN_TP_Utils.BUDGET_GS) != null &&cmgsMap.get(mappingKeyPrefix + ASI_CRM_CN_TP_Utils.BUDGET_GS).size()>0?cmgsMap.get(mappingKeyPrefix + ASI_CRM_CN_TP_Utils.BUDGET_GS)[0].ASI_CRM_CM_GS_per_9L__c:0;
            if(brsf.ASI_CRM_CN_TP_Promotion_Cost__c > 0 || brsf.ASI_CRM_CN_TP_Fixed_Cost__c > 0) {
                // brsfList.add(brsf);
                String brsfKey = brsf.ASI_CRM_CN_Contract__c + '-' + brsf.ASI_CRM_CN_Sub_Brand__c;
                if (subContractBRSFMap.containsKey(brsfKey)) {
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c exsitBRSF = subContractBRSFMap.get(brsfKey);
                    exsitBRSF.ASI_CRM_CN_TP_Promotion_Cost__c += brsf.ASI_CRM_CN_TP_Promotion_Cost__c;
                    exsitBRSF.ASI_CRM_CN_TP_Fixed_Cost__c += brsf.ASI_CRM_CN_TP_Fixed_Cost__c;
                    exsitBRSF.ASI_CRM_CN_Total_Volume_9L__c += brsf.ASI_CRM_CN_Total_Volume_9L__c;
                } else {
                    subContractBRSFMap.put(brsfKey, brsf);
                }
            }
            System.debug(LoggingLevel.INFO, '*** subContractBRSFMap: ' + subContractBRSFMap);
            // if(tpamountMap.containsKey(String.valueOf(agg.get('poId')))) {
            //     if(Decimal.valueOf(String.valueOf(agg.get('promotionCost'))) != null) {
            //         tpamountMap.put(String.valueOf(agg.get('poId')), tpamountMap.get(String.valueOf(agg.get('poId'))) + Decimal.valueOf(String.valueOf(agg.get('promotionCost'))));
            //     }
            // } else {
            //     tpamountMap.put(String.valueOf(agg.get('poId')), Decimal.valueOf(String.valueOf(agg.get('promotionCost'))));
            // }
            if(totalFixedCostMap.containsKey(String.valueOf(agg.get('poId')))) {
                if(Decimal.valueOf(String.valueOf(agg.get('fixedCost'))) != null) {
                    totalFixedCostMap.put(String.valueOf(agg.get('poId')), totalFixedCostMap.get(String.valueOf(agg.get('poId'))) + Decimal.valueOf(String.valueOf(agg.get('fixedCost'))));
                }
            } else {
                totalFixedCostMap.put(String.valueOf(agg.get('poId')), Decimal.valueOf(String.valueOf(agg.get('fixedCost'))));
            }

        }

        for (ASI_CRM_Contract_Cost__c cost : costList) {
            if(cost.Name == SCANDATA_COST && promotionModeCostMap.get(cost.ASI_CRM_CN_Contract__c + SCANDATA_COST) != null) {
                    cost.ASI_CRM_CN_Estimate_Amount__c = promotionModeCostMap.get(cost.ASI_CRM_CN_Contract__c + SCANDATA_COST);
                    cost.ASI_CRM_Other_Est__c = promotionModeCostMap.get(cost.ASI_CRM_CN_Contract__c + SCANDATA_COST);
                    cost.ASI_CRM_CN_Contract_Amount__c = promotionModeCostMap.get(cost.ASI_CRM_CN_Contract__c + SCANDATA_COST);
            }
            if(cost.Name == Label.ASI_CRM_CN_TP_PRC && promotionModeCostMap.get(cost.ASI_CRM_CN_Contract__c + Label.ASI_CRM_CN_TP_PRC) != null) {
                    cost.ASI_CRM_CN_Estimate_Amount__c = promotionModeCostMap.get(cost.ASI_CRM_CN_Contract__c + Label.ASI_CRM_CN_TP_PRC);
                    cost.ASI_CRM_Other_Est__c = promotionModeCostMap.get(cost.ASI_CRM_CN_Contract__c + Label.ASI_CRM_CN_TP_PRC);
                    cost.ASI_CRM_CN_Contract_Amount__c = promotionModeCostMap.get(cost.ASI_CRM_CN_Contract__c + Label.ASI_CRM_CN_TP_PRC);
            }
            if(cost.Name == Label.ASI_CRM_CN_TP_Total_fixedCost && totalFixedCostMap.get(cost.ASI_CRM_CN_Contract__c) != null) {
                    cost.ASI_CRM_CN_Estimate_Amount__c = totalFixedCostMap.get(cost.ASI_CRM_CN_Contract__c);
                    // cost.ASI_CRM_CNY_Est__c = totalFixedCostMap.get(cost.ASI_CRM_CN_Contract__c);
                    cost.ASI_CRM_Other_Est__c = totalFixedCostMap.get(cost.ASI_CRM_CN_Contract__c);
                    cost.ASI_CRM_CN_Contract_Amount__c = totalFixedCostMap.get(cost.ASI_CRM_CN_Contract__c);
            }
            System.debug(LoggingLevel.INFO, '*** cost: ' + cost);
        }

        if(costList.size() > 0) {
            update costList;
        }

        if(subContractBRSFMap.size() > 0) {
            insert subContractBRSFMap.values();
        }

    }
}