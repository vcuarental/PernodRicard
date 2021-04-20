/*********************************************************************************
 * Name:        ASI_PricingApproval_TriggerClass
 * Description: 
 * Related Test Class: 
 *
 * Version History
 *  Date             Developer               Comments
 *  ---------------  --------------------    --------------------------------------------------------------------------------
 *  2017-04-22       Wilken Lee               [WL 1.0] Update Status as "Final Approved" after all directors approvers approved
 *  2017-10-03       Wilken Lee               [WL 2.0] ITCRF-0004270 Assign approver only if all 4 approvers fields are blank.
*********************************************************************************/
public class ASI_PricingApproval_TriggerClass{
    public static void routineBeforeUpsert(list<ASI_Pricing_Approval__c> trigger_new){
        //Wilken 20170301 Assign approvers based on Change Type
        List<ASI_Pricing_Approval_Setting__c> pricingApprovalSettings = ASI_Pricing_Approval_Setting__c.getall().values();
        Set<String> approverUsernameSet = new Set<String>();
        for (ASI_Pricing_Approval_Setting__c setting:pricingApprovalSettings){
            approverUsernameSet.add(setting.ASI_Pricing_First_Approver_Username__c);
            approverUsernameSet.add(setting.ASI_Pricing_Second_Approver_Username__c);
            approverUsernameSet.add(setting.ASI_Pricing_Third_Approver_Username__c);
            approverUsernameSet.add(setting.ASI_Pricing_Forth_Approver_Username__c);
        }
        
        List<User> approversList = [select id, Username from User where Username in :approverUsernameSet];
        Map<String, Id> approverIdMap = new Map<String, Id>();
        for (User u:approversList)
            approverIdMap.put(u.Username, u.Id);
        
        for (ASI_Pricing_Approval__c apc : trigger_new){
            if (apc.ASI_Base_Price_Setup__c == null)
                apc.ASI_Base_Price_Setup__c = apc.ASI_SSC_Logistic__c;
            if (apc.ASI_Advanced_Pricing__c){
                if (apc.ASI_Advanced_Price_Setup__c == null)
                    apc.ASI_Advanced_Price_Setup__c = apc.ASI_SSC_Backup__c;
            }
            
            //Wilken 20170301 Assign approvers based on Change Type
            for (ASI_Pricing_Approval_Setting__c setting:pricingApprovalSettings){
                /*[WL 2.0 BEGIN]*/
                //if (apc.ASI_Pricing_Change_Type__c == setting.ASI_Pricing_Change_Type__c){
                if (apc.ASI_Pricing_Change_Type__c == setting.ASI_Pricing_Change_Type__c && apc.ASI_Pricing_First_Level_Approval__c == null
                    && apc.ASI_Pricing_Second_Level_Approval__c == null && apc.ASI_Pricing_Third_Level_Approval__c == null && apc.ASI_Pricing_Forth_Level_Approval__c == null){
                /*[WL 2.0 END]*/
                    apc.ASI_Pricing_First_Level_Approval__c = approverIdMap.get(setting.ASI_Pricing_First_Approver_Username__c);
                    apc.ASI_Pricing_Second_Level_Approval__c = approverIdMap.get(setting.ASI_Pricing_Second_Approver_Username__c);
                    apc.ASI_Pricing_Third_Level_Approval__c = approverIdMap.get(setting.ASI_Pricing_Third_Approver_Username__c);
                    apc.ASI_Pricing_Forth_Level_Approval__c = approverIdMap.get(setting.ASI_Pricing_Forth_Approver_Username__c);
                }
            }
        }
    }
    
    public static void routineAfterUpdate(list<ASI_Pricing_Approval__c> trigger_new, map<id, ASI_Pricing_Approval__c>trigger_oldMap){
        //Copy approval process recall comment to Remarks (2014-11-3 by Stella Sing (Introv)
        set<id> pcIdSet = new set<id>();
        List<ASI_Pricing_Approval__c> pricingListForUpdate = new List<ASI_Pricing_Approval__c>();
        ASI_Pricing_Approval__c pricingForUpdate = new ASI_Pricing_Approval__c();
        
        for (ASI_Pricing_Approval__c pc : trigger_new){
            if (trigger_oldMap.containskey(pc.id)){
                if (trigger_oldMap.get(pc.id).ASI_Recall__c != pc.ASI_Recall__c && pc.ASI_Recall__c == true){
                    pcIdSet.add(pc.Id);
                    system.debug('Recall checked!');
                }
            }
            
            //[WL 1.0 Begin]
            if (pc.ASI_Pricing_Total_Approval_Levels__c == pc.ASI_Approved_Level__c && pc.ASI_Status__c == 'Submitted'){
                pricingForUpdate.Id = pc.Id;
                pricingForUpdate.ASI_Status__c =  'Final Approved';
                pricingListForUpdate.add(pricingForUpdate);
            }
            
            system.debug('Total Approval Levels: ' + pc.ASI_Pricing_Total_Approval_Levels__c + ' Approved Level: ' + pc.ASI_Approved_Level__c);
            //[WL 1.0 End]
        }
        if (pcIdSet.size() > 0)
            CopyRecallCommenttoRemarks(pcIdSet);
        
        //[WL 1.0 Begin]
        if (pricingListForUpdate.size() > 0)
            update pricingListForUpdate;
        //[WL 1.0 End]
        //End ----- Copy approval process recall comment to Remarks 
    }
    //Copy Recall comment from approval process to remarks
    public static void CopyRecallCommenttoRemarks(set<id> pcIdSet){
        list<ASI_Pricing_Approval__c> palist = [SELECT id, (SELECT Id, TargetObjectId, ActorId, StepStatus, Comments, CreatedDate FROM ProcessSteps WHERE StepStatus = 'Removed' ORDER BY CreatedDate DESC) FROM ASI_Pricing_Approval__c WHERE id IN :pcIdSet];
        list<ProcessInstanceHistory> PIlist = new list<ProcessInstanceHistory>();
        for (ASI_Pricing_Approval__c pa : palist){
            PIList.addAll(pa.ProcessSteps);
        }   
        system.debug('paList: ' + paList); 
        list<ASI_Pricing_Approval__c> UpdateList = new list<ASI_Pricing_Approval__c>();
        id tempId;
        for (ProcessInstanceHistory pi : PIList){
            if (tempId != pi.TargetObjectId){
                ASI_Pricing_Approval__c updatePA = new ASI_Pricing_Approval__c();
                updatePA.id = pi.TargetObjectId;
                updatePA.ASI_Remarks__c = pi.Comments;
                UpdateList.add(updatePA);
                system.debug('pi.Comments: ' + pi.Comments);
            }
            tempId = pi.TargetObjectId;
        }
        if (UpdateList.size() > 0)
            update UpdateList;
    }    
}