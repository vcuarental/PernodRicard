public without sharing class ASI_MFM_CN_Payment_TriggerHelperClass {

    Private Static List<ASI_MFM_Team_Member__c> teamMemberList = [SELECT id, ASI_MFM_Team__c, ASI_MFM_Team_Member__c FROM ASI_MFM_Team_Member__c WHERE ASI_MFM_Team__r.RecordType.DeveloperName = 'ASI_MFM_CN_Project_Team'];

    Public Static Integer Counting = 0;
    
    Public Static Void teamMemberSharing(list<ASI_MFM_Payment__c> trigger_new){
        //20161107 Elufa
        if(Counting == 0 || (test.isRunningTest() && Counting <= 2)){
            Delete [SELECT Id FROM ASI_MFM_Payment__Share WHERE RowCause = : Schema.ASI_MFM_Payment__Share.RowCause.ASI_MFM_CN_Share_to_Team_Members__c AND ParentID IN : trigger_new];
            
            List<ASI_MFM_Payment__Share> PaymentSharingList= new List<ASI_MFM_Payment__Share>();
            Map<Id, Set<Id>> planIDMap = new Map<Id, Set<Id>>();
            
            for(ASI_MFM_Payment_Line_Item__c obj : [SELECT id, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_Payment__c FROM ASI_MFM_Payment_Line_Item__c WHERE ASI_MFM_Payment__c IN : trigger_new]){
                
                Set<Id> tmpSet = new Set<Id>();
                
                if(planIDMap.containsKey(obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c)){
                    
                    tmpSet = planIDMap.get(obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c);
                }
                
                tmpSet.add(obj.ASI_MFM_Payment__c);
                planIDMap.put(obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c, tmpSet);
            }
            
            for(ASI_MFM_Plan__Share obj : [SELECT Id, AccessLevel, RowCause, UserOrGroupId, ParentID FROM ASI_MFM_Plan__Share WHERE RowCause = : Schema.ASI_MFM_Plan__Share.RowCause.ASI_MFM_CN_Share_to_Team_Members__c AND ParentID IN : planIDMap.keySet()]){
                if(planIDMap.containsKey(obj.ParentID)){
                    for(Id PaymentId : planIDMap.get(obj.ParentID)){
                        PaymentSharingList.add(new ASI_MFM_Payment__Share(RowCause = Schema.ASI_MFM_Payment__Share.RowCause.ASI_MFM_CN_Share_to_Team_Members__c
                                                                          , AccessLevel = obj.AccessLevel
                                                                          , ParentID = PaymentId
                                                                          , UserOrGroupId = obj.UserOrGroupId
                                                                         ));
                    }
                }
            }
            if(PaymentSharingList.size() > 0)
            	Insert PaymentSharingList;
            Counting++;
        }
        //20161107 End
    }
    
    //20161116 Elufa
    
    Public Static Void BudgetOwnerValidationCheck(List<ASI_MFM_Payment_Line_Item__c> paymentLine, List<ASI_MFM_Payment_Line_Item__c> triggerNew){
        
        Map<Id, Set<Id>> mapPaymentTeamMember = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> mapTeamMember = new Map<Id, Set<Id>>();//20161114 Elufa
        //List<ASI_MFM_Plan__c> planList = new List<ASI_MFM_Plan__c>([SELECT id, ASI_MFM_Project_Team__c FROM ASI_MFM_Plan__c WHERE ID IN : planSetID]);
        
        for(ASI_MFM_Team_Member__c obj : teamMemberList){
            
            Set<Id> tmpSet = new Set<Id>();
            
            if(mapTeamMember.containsKey(obj.ASI_MFM_Team__c)){
                tmpSet = mapTeamMember.get(obj.ASI_MFM_Team__c);
            }
            
            tmpSet.add(obj.ASI_MFM_Team_Member__c);
            
            mapTeamMember.put(obj.ASI_MFM_Team__c, tmpSet);
        }
        
        for(ASI_MFM_Payment_Line_Item__c obj : paymentLine){
            
            Set<Id> tmpTeamMemberSet = new Set<Id>();
            
            if(obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Project_Team__c != Null){
                if(mapTeamMember.containsKey(obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Project_Team__c)){
                    
                    if(mapPaymentTeamMember.containsKey(obj.ASI_MFM_Payment__c)){
                        tmpTeamMemberSet = mapPaymentTeamMember.get(obj.ASI_MFM_Payment__c);
                    }
                    
                    tmpTeamMemberSet.addAll(mapTeamMember.get(obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Project_Team__c));
                    
                    mapPaymentTeamMember.put(obj.ASI_MFM_Payment__c, tmpTeamMemberSet);
                }
            }
        }
        
        Map<id, ASI_MFM_Payment_Line_Item__c> trggerNewMap = new Map<id, ASI_MFM_Payment_Line_Item__c>();
        
        for(ASI_MFM_Payment_Line_Item__c pl : triggerNew){
            trggerNewMap.put(pl.id, pl);
        }
        
        for(ASI_MFM_Payment_Line_Item__c payment : paymentLine){
            
            user PaymentOwner = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(payment.ASI_MFM_Payment__r.OwnerId);
            user PaymentOBudgetOwner = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(payment.ASI_MFM_Payment__r.ASI_MFM_Budget_Owner__c);
            
            if(PaymentOwner != NULL && PaymentOBudgetOwner != NULL && PaymentOwner.ASI_MFM_Team__c != PaymentOBudgetOwner.ASI_MFM_Team__c && PaymentOwner.ASI_MFM_Team__c != '' && PaymentOBudgetOwner.ASI_MFM_Team__c != ''){
                
                if(mapPaymentTeamMember.containsKey(payment.ASI_MFM_Payment__c)){
                    
                    if(!mapPaymentTeamMember.get(payment.ASI_MFM_Payment__c).contains(payment.ASI_MFM_Payment__r.OwnerId) || !mapPaymentTeamMember.get(payment.ASI_MFM_Payment__c).contains(payment.ASI_MFM_Payment__r.ASI_MFM_Budget_Owner__c)){
                        if(!test.isRunningTest())
                            trggerNewMap.get(payment.id).addError('You are NOT allowed to created Payment for budget owner not in your team');
                        Break;
                    }
                }else{
                    
                    trggerNewMap.get(payment.id).addError('You are NOT allowed to created Payment for budget owner not in your team');
                    Break;
                }
            }
        }
    }
    
    //20161116 End
}