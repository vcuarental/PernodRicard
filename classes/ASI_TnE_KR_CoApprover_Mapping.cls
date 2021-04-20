public without sharing class ASI_TnE_KR_CoApprover_Mapping {
    
    static set<id> budgetOwnerSet = new Set<id>();
    static set<id> coApproverSet = new set<id>();
    static set<id> headerID = new set<id>();
    private static String statusDraft = 'Draft';
    private static String statusSubmitted = 'Submitted';
    private static String statusApproved = 'Approved';
    private static String statusCompleted = 'Complete';
    private static String statusFinal = 'Final';
    private static String statusReject = 'Rejected';
    
    
    public static void coApprover(list<ASI_TnE_ClaimDetail__c> triggerNew,map<id,ASI_TnE_ClaimDetail__c> triggerNewMap){
        
        list<id> sortedCoApprover = new list<id>();
        list<id> sortedBudgetOwner = new list<id>();
        list<id> coApprover = new list<id>();
        list<id> budgetOwner = new list<id>();
        String budgetOwnerStr;
        String coApproverStr;
    
    Map<id, ASI_JP_TnE_Expense_Classification__c> Classifications = new Map<id, ASI_JP_TnE_Expense_Classification__c>([select id,ASI_JP_TnE_Account_Mapping__r.ASI_TnE_KR_CO_Approver__c from ASI_JP_TnE_Expense_Classification__c where recordType.DeveloperName = 'ASI_TnE_KR_Expense_Classification']);
    
        for(ASI_TnE_ClaimDetail__c obj : triggerNew){
            
            /*if(obj.ASI_TnE_Receipt_Number__c==null){
                    obj.ASI_TnE_Receipt_Number__c=0;
                }else{
                    obj.ASI_TnE_Receipt_Number__c += 1;
                }*/
            
            budgetOwnerSet.add(obj.ASI_TnE_KR_Owner__c);
            
            if(obj.ASI_TnE_Expense_Classification__c!=null){
                //for(ASI_JP_TnE_Expense_Classification__c Classification : Classifications){
                    system.debug('checkaaa ' + Classifications);
                    
                    //if(obj.ASI_TnE_Expense_Classification__c==Classification.id){
                        obj.ASI_TnE_KR_Co_Approver__c=Classifications.get(obj.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_KR_CO_Approver__c;
                        coApproverSet.add(Classifications.get(obj.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_KR_CO_Approver__c);
                        headerID.add(obj.ASI_TnE_ClaimHeader__c);
                    //}
                //}
            }
        }        
			budgetOwner.addall(budgetOwnerSet);
            coApprover.addall(coApproverSet);
        	coApprover.sort();
        	budgetOwner.sort();
        
        for(integer i=coApprover.size()-1;i>=0;i--){
            sortedCoApprover.add(coApprover[i]);
        }
        for(integer i = budgetOwner.size()-1;i>=0;i--){
        	sortedBudgetOwner.add(budgetOwner[i]);
        }
        
        list<ASI_TnE_ClaimHeader__c> claimHeader = [SELECT id,ASI_TnE_KR_CoApprover_1__c,
                                                    ASI_TnE_KR_CoApprover_2__c,
                                                    ASI_TnE_KR_CoApprover_3__c,
                                                    ASI_TnE_KR_CoApprover_4__c,
                                                    ASI_TnE_KR_CoApprover_5__c
                                                    from ASI_TnE_ClaimHeader__c where id in : headerID
                                                   	AND (ASI_TnE_Status__c =: statusDraft
                                                         OR ASI_TnE_Status__c =: statusReject)];
		list<ASI_TnE_ClaimHeader__c> updateHeader = new list<ASI_TnE_ClaimHeader__c>();        
        
        for(ASI_TnE_ClaimHeader__c obj: claimHeader){
			for(integer i = 1;i<=5;i++){
                
                budgetOwnerStr = 'ASI_TnE_KR_Budget_Owner_'+i+'__c';
                coApproverStr = 'ASI_TnE_KR_CoApprover_'+i+'__c';
                
                if(i<=sortedCoApprover.size()){
                	obj.put(coApproverStr,sortedCoApprover[i-1]);
                }else{
                    obj.put(coApproverStr,null);
                }

                if(i<=sortedBudgetOwner.size()){
                	obj.put(budgetOwnerStr,sortedBudgetOwner[i-1]);
                }else{
                    obj.put(budgetOwnerStr,null);
                }
            }
            updateHeader.add(obj);
        }
        update updateHeader;
    }
}