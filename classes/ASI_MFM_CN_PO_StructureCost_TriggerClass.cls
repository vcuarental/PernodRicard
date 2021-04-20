public without Sharing class ASI_MFM_CN_PO_StructureCost_TriggerClass {

    Public Static Void beforeInsertMethod(List<ASI_MFM_PO__c> triggerNew){
        
        List<ASI_MFM_Prefix__c> prefixlist = new List<ASI_MFM_Prefix__c>([SELECT id, Name, ASI_MFM_Next_Number__c, ASI_MFM_Fiscal_year__c 
                                                                          FROM ASI_MFM_Prefix__c 
                                                                          WHERE ASI_MFM_Module__c = 'Structure Cost Budget' AND ASI_MFM_Inactive__c = False 
                                                                          Order By CreatedDate
                                                                          Limit 1]);
        
        Map<Id, ASI_MFM_Expense_Control_Form__c> mapECF = new Map<Id, ASI_MFM_Expense_Control_Form__c>([SELECT id, ASI_MFM_BU__c, ASI_MFM_BudgetOwner__c
                                                                                                        FROM ASI_MFM_Expense_Control_Form__c
                                                                                                        WHERE RecordType.DeveloperName Like 'ASI_MFM_CN_Expense_Control_Form'
                                                                                                       ]);
        
        Boolean updatePrefix = False;
        
        for(ASI_MFM_PO__c obj : triggerNew){
            
            //Bypass if it is Cloned Budget
            if(obj.ASI_MFM_Cloned_PO__c == Null && obj.ASI_MFM_Status__c != 'Archived'){
                if(mapECF.containsKey(obj.ASI_MFM_Expense_Type__c)){
                    
                    obj.ASI_MFM_Budget_Owner__c = mapECF.get(obj.ASI_MFM_Expense_Type__c).ASI_MFM_BudgetOwner__c;
                    obj.ASI_MFM_BU_Code__c = mapECF.get(obj.ASI_MFM_Expense_Type__c).ASI_MFM_BU__c;
                }
                
                if(prefixlist.size() > 0){
                    
                    obj.ASI_MFM_Prefix__c = prefixlist[0].id;
                    
                    obj.Name = prefixlist[0].Name + prefixlist[0].ASI_MFM_Fiscal_year__c.subString(2, 4);
                    
                    obj.Name += ('' + (10000 + prefixlist[0].ASI_MFM_Next_Number__c)).subString(1);
                    
                    //There is a workflow to clone PO Name as PO External ID every time it is edit.
                    obj.ASI_MFM_PO_External_ID__c = obj.Name;
                    
                    prefixlist[0].ASI_MFM_Next_Number__c = prefixlist[0].ASI_MFM_Next_Number__c + 1;
                    
                    updatePrefix = True;
                }else{
                    
                    obj.addError('No effective Prefix can be found, Please contact Admin.');
                }
            }
        }
        
        if(prefixlist.size() > 0 && updatePrefix)
        	Update prefixlist;
    }
    
    Public Static Void beforeUpdateMethod(List<ASI_MFM_PO__c> triggerNew, Map<Id, ASI_MFM_PO__c> triggerOldMap ){
        
        List<ASI_MFM_PO__c> clonePOList = new List<ASI_MFM_PO__c>();
        Boolean hasError = False;
        
        for(ASI_MFM_PO__c obj : triggerNew){
            
            
            if(obj.ASI_MFM_Expense_Type__c != triggerOldMap.get(obj.Id).ASI_MFM_Expense_Type__c){
                
                obj.addError('Not allowed to changed expense type');
            }
            
            if(obj.ASI_MFM_LE__c != triggerOldMap.get(obj.Id).ASI_MFM_LE__c && obj.ASI_MFM_Status__c != 'Archived'){
                
                if(triggerOldMap.get(obj.Id).ASI_MFM_LE__c > obj.ASI_MFM_LE__c){
                    obj.addError('LE cannot less than current PO');
                    hasError = True;
                    break;
                }else{
                    
                    ASI_MFM_PO__c tmp = triggerOldMap.get(obj.id).clone(false, true);
                    tmp.ASI_MFM_Cloned_PO__c = obj.id;
                    tmp.ASI_MFM_Status__c = 'Archived';
                    tmp.Name = tmp.Name + '.' + tmp.ASI_MFM_LE__c;
                    tmp.Id = Null;
                    
                    clonePOList.add(tmp);
                }
            }
        }
        
        if(clonePOList.size() > 0 && !hasError){
            try{
                
                Insert clonePOList;
                
            }catch(dmlException dmle){
                
            }
        }
    }
}