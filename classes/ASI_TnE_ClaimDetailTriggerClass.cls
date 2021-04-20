/*********************************************************************************
 * Name:ASI_TnE_ClaimDetailTriggerClass
 * Description: 
 * Test Class: ASI_TnE_VN_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/11/2017       Linus Ho                [LH 1.0] Limit the maximum # of line to 25
 * 18/09/2018       Linus Ho                [LH 2.0] Update Account number by 1D & 2D
 * 08/03/2019       Wilken Lee              [WL 3.0] Update Account Number based on user setup
*********************************************************************************/
public class ASI_TnE_ClaimDetailTriggerClass {
    public static void routineBeforeUpsert(list<ASI_TnE_ClaimDetail__c> trigger_new, map<id, ASI_TnE_ClaimDetail__c> trigger_oldMap) {
            
        integer numOfLine = 0;    
        set<id> detail_set = new set<id>();
        Set<id> ownerIDSet = new Set<id>();
        
        Map<id,string> headerOwnerIDMap = new Map<id,string>();
        Map<id,User> ownerDeptCodeMap = new Map<id,User>();
        Map<String, String> accMap = new Map<String, String>(); 
        Set<id> headerIDSet = new Set<id>();
        
        if (trigger_new != null) {
            for (ASI_TnE_ClaimDetail__c d:trigger_new) {
                headerIDSet.add(d.ASI_TnE_ClaimHeader__c);
            }
            
            for (ASI_TnE_ClaimHeader__c header:[select OwnerID, ASI_TnE_Number_of_Line__c from ASI_TnE_ClaimHeader__c where id = :headerIDSet]){
                ownerIDSet.add(header.OwnerID);
                headerOwnerIDMap.put(header.id, header.OwnerID);
                numOfLine = Integer.valueOf(header.ASI_TnE_Number_of_Line__c);
            }
            
            // [LH 2.0]
            for (User u:[select ASI_TnE_Department_Code__c, ASI_JP_TnE_Department_Category_Code__c, ASI_Company_Code__c from User where id = :ownerIDSet]){
                //ownerDeptCodeMap.put(u.id, u.ASI_TnE_Department_Code__c);
                ownerDeptCodeMap.put(u.id, u);
            }
                  
            for(ASI_TnE_Account_Mapping__c accountmapping : [select ASI_TnE_Account_Number__c, ASI_TnE_Expense_Type__c from ASI_TnE_Account_Mapping__c where ASI_TnE_Country__c = 'VN']){
                accMap.put(accountmapping.ASI_TnE_Expense_Type__c, accountmapping.ASI_TnE_Account_Number__c);
            }
        
            for (ASI_TnE_ClaimDetail__c d:trigger_new) {                
                if (d.ASI_TnE_Amount__c != null){
                    if (d.ASI_TnE_VAT__c){
                        d.ASI_TnE_Original_Amount__c = Math.Round((d.ASI_TnE_Amount__c / 1.1).setScale(0));
                        d.ASI_TnE_Tax_Amount__c = Math.Round((d.ASI_TnE_Amount__c - (d.ASI_TnE_Amount__c / 1.1)).setScale(0));
                    }
                    else {
                        d.ASI_TnE_Original_Amount__c = d.ASI_TnE_Amount__c;
                        d.ASI_TnE_Tax_Amount__c = 0;
                    }
                }
                
                //20160804 Wilken: Update Account Number again whenever T&E Detail is updated
                //[LH 2.0]: get department category from user profile
                if (headerOwnerIDMap.get(d.ASI_TnE_ClaimHeader__c) != null && ownerDeptCodeMap.get(headerOwnerIDMap.get(d.ASI_TnE_ClaimHeader__c)) != null && accMap.get(d.ASI_TnE_Expense_Type__c) != null){
                /*[WL 3.0] BEGIN*/
					/*d.ASI_TnE_Account_Number__c = ownerDeptCodeMap.get(headerOwnerIDMap.get(d.ASI_TnE_ClaimHeader__c)).ASI_JP_TnE_Department_Category_Code__c == null ? '7781D' + ownerDeptCodeMap.get(headerOwnerIDMap.get(d.ASI_TnE_ClaimHeader__c)).ASI_TnE_Department_Code__c + 'VN.' + accMap.get(d.ASI_TnE_Expense_Type__c) :
                                                  '778' + ownerDeptCodeMap.get(headerOwnerIDMap.get(d.ASI_TnE_ClaimHeader__c)).ASI_JP_TnE_Department_Category_Code__c + ownerDeptCodeMap.get(headerOwnerIDMap.get(d.ASI_TnE_ClaimHeader__c)).ASI_TnE_Department_Code__c + 'VN.' + accMap.get(d.ASI_TnE_Expense_Type__c);*/
					d.ASI_TnE_Account_Number__c = ownerDeptCodeMap.get(headerOwnerIDMap.get(d.ASI_TnE_ClaimHeader__c)).ASI_Company_Code__c + '1D' + ownerDeptCodeMap.get(headerOwnerIDMap.get(d.ASI_TnE_ClaimHeader__c)).ASI_TnE_Department_Code__c + 'VN.' + accMap.get(d.ASI_TnE_Expense_Type__c);
				/*[WL 3.0] END*/
				}
            }
            
            // Added 2017-11-13 Linus@introv 
            // [LH 1.0] limit the maximum line created in 25
            if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeid).developerName.contains('ASI_TnE_VN_Claim_Detail')){ 
                if(numOfLine > 25 && trigger_oldMap == null){
                    trigger_new[0].addError('Not allowed create more than 25 lines');
                 }
            }
        }
    }
    /*
    public static void routineBeforeDelete(list<ASI_TnE_ClaimDetail__c> trigger_old) {
        set<id> detailID_set = new set<id>();
        for (ASI_TnE_ClaimDetail__c detail:trigger_old) {
            detailID_set.add(detail.ASI_TnE_ClaimHeader__c);
        }
        map<id, ASI_TnE_ClaimHeader__c> claim_map = new map<id, ASI_TnE_ClaimHeader__c>([select id from ASI_TnE_ClaimHeader__c where id in :detailID_set and ASI_TnE_Status__c = 'Finance Director Approved']);        
        for (ASI_TnE_ClaimDetail__c detail:trigger_old) {
            if (claim_map.containsKey(detail.ASI_TnE_ClaimHeader__c)) {
                detail.addError('Not allowed to delete because the claim form has been approved');
            }
        }
    }
    */ 
    public static void routineAfterInsert(list<ASI_TnE_ClaimDetail__c> trigger_new, map<id, ASI_TnE_ClaimDetail__c> trigger_oldMap) {       
        //Wilken 20160804, migrated Account Code update logic to BeforeUpsert method
    }
}