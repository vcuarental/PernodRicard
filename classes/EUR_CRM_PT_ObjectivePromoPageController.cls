public with sharing class EUR_CRM_PT_ObjectivePromoPageController {
    public String PT_OFF_TRADE_OP_TARGET_PER_BRAND_RT_DEV_NAME {get{return 'EUR_PT_Off_Trade_OP_Target_per_Brand';}}
    public String PT_OFF_TRADE_OP_TARGET_PER_ACCOUNT_RT_DEV_NAME {get{return 'EUR_PT_Off_Trade_OP_Target_per_Account';}}
    
    private EUR_CRM_ObjPromo__c objPromo;
    
    public Map<Id, List<EUR_CRM_ObjPromo_Target__c>> opTargetBrandAccountMap {get; set;}
    private List<EUR_CRM_ObjPromo_Target__c> removeOPTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
    
    public Boolean isEditable {get; set;}
    
    public EUR_CRM_PT_ObjectivePromoPageController(ApexPages.StandardController stdController) {
        isEditable = false;
        
        Id objPromoId = ((EUR_CRM_ObjPromo__c) stdController.getRecord()).Id;
        this.objPromo = [SELECT Id, recordtypeId, recordtype.developername, EUR_CRM_Status__c,
                         EUR_CRM_Is_Quota__c, EUR_CRM_Is_Publish_ready__c
                         FROM EUR_CRM_ObjPromo__c
                         WHERE ID = :objPromoId];
		
        List<EUR_CRM_ObjPromo_Target__c> opTargetList = initOPTargetList(objPromo.Id);
        opTargetBrandAccountMap = initOPTargetBrandAccountMap(opTargetList);
    }
    
    public List<EUR_CRM_ObjPromo_Target__c> initOPTargetList(Id objPromoId) {
        return [SELECT Id, 
                       Name, 
                       RecordType.Name, 
                       RecordType.DeveloperName,  
                       EUR_CRM_Brand__c, 
                       EUR_CRM_Brand__r.Name, 
                       EUR_CRM_Account__c, 
                       EUR_CRM_Account__r.Name, 
                       EUR_CRM_O_P_Target__c,
                       EUR_CRM_O_P_Target__r.Name,
                       EUR_CRM_Target_No_of_Display__c,
                       EUR_CRM_Target_No_of_Display_per_Brand__c, 
                       EUR_CRM_Actual_No_of_Display__c,
                       EUR_CRM_Actual_No_of_Display_per_Brand__c
                FROM EUR_CRM_ObjPromo_Target__c
                WHERE EUR_CRM_ObjPromo__c = :objPromoId];
    }
    
    public Map<Id, List<EUR_CRM_ObjPromo_Target__c>> initOPTargetBrandAccountMap(List<EUR_CRM_ObjPromo_Target__c> opTargetList) {
        Map<Id, List<EUR_CRM_ObjPromo_Target__c>> opTargetBrandAccountMap = new Map<Id, List<EUR_CRM_ObjPromo_Target__c>>();
        for(EUR_CRM_ObjPromo_Target__c opTarget : opTargetList) {
            List<EUR_CRM_ObjPromo_Target__c> brandOPTargetList;
            if(opTargetBrandAccountMap.containsKey(opTarget.EUR_CRM_Brand__c)) {
            	brandOPTargetList = opTargetBrandAccountMap.get(opTarget.EUR_CRM_Brand__c);
            } else {
                brandOPTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
            }
            if(opTarget.RecordType.DeveloperName.equals(PT_OFF_TRADE_OP_TARGET_PER_BRAND_RT_DEV_NAME) && brandOPTargetList.size() > 0) {
                brandOPTargetList.add(0, opTarget);
            } else {
            	brandOPTargetList.add(opTarget);
            }
            opTargetBrandAccountMap.put(opTarget.EUR_CRM_Brand__c, brandOPTargetList);
        }
        return opTargetBrandAccountMap;
    }
    
    public void deleteRecord() {
        String opTargetId = ApexPages.currentPage().getParameters().get('opTargetId');
        Id removeBrandId;
        for(Id brandId : opTargetBrandAccountMap.keySet()) {
            EUR_CRM_ObjPromo_Target__c brandOPTarget;
            Integer opTargetIndex = 0;
            Integer removeOPTargetIndex;
            for(EUR_CRM_ObjPromo_Target__c opTarget : opTargetBrandAccountMap.get(brandId)) {
                if(opTarget.RecordType.DeveloperName.equals(PT_OFF_TRADE_OP_TARGET_PER_BRAND_RT_DEV_NAME)) {
                    brandOPTarget = opTarget;
                }
                if(opTarget.Id.equals(opTargetId)) {
                    if(opTarget.RecordType.DeveloperName.equals(PT_OFF_TRADE_OP_TARGET_PER_BRAND_RT_DEV_NAME)) {
                        removeBrandId = brandId;
                    } else {
                        removeOPTargetIndex = opTargetIndex;
                    }
                }
                opTargetIndex++;
            }
            if(removeOPTargetIndex != null) {
                brandOPTarget.EUR_CRM_Target_No_of_Display_per_Brand__c -= opTargetBrandAccountMap.get(brandId).get(removeOPTargetIndex).EUR_CRM_Target_No_of_Display__c;
                brandOPTarget.EUR_CRM_Actual_No_of_Display_per_Brand__c -= opTargetBrandAccountMap.get(brandId).get(removeOPTargetIndex).EUR_CRM_Actual_No_of_Display__c;
                removeOPTargetList.add(opTargetBrandAccountMap.get(brandId).get(removeOPTargetIndex));
                opTargetBrandAccountMap.get(brandId).remove(removeOPTargetIndex);
            }
        }
        
        if(removeBrandId != null) {
            removeOPTargetList.addAll(opTargetBrandAccountMap.get(removeBrandId));
            opTargetBrandAccountMap.remove(removeBrandId);
        }
    }
    
    public void saveOPTarget() {
        List<EUR_CRM_ObjPromo_Target__c> opTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
        for(Id brandId : opTargetBrandAccountMap.keySet()) {
            EUR_CRM_ObjPromo_Target__c brandOPTarget;
            Decimal totalActualNo = 0;
            for(EUR_CRM_ObjPromo_Target__c opTarget : opTargetBrandAccountMap.get(brandId)) {
                if(opTarget.RecordType.DeveloperName.equals(PT_OFF_TRADE_OP_TARGET_PER_BRAND_RT_DEV_NAME)) {
                    brandOPTarget = opTarget;
                } else {
                    totalActualNo += opTarget.EUR_CRM_Actual_No_of_Display__c;
                    opTargetList.add(opTarget);
                }
            }
            if(brandOPTarget != null) {
                brandOPTarget.EUR_CRM_Actual_No_of_Display_per_Brand__c = totalActualNo;
                opTargetList.add(brandOPTarget);
            }
        }
        if(removeOPTargetList.size() != 0) {
            delete removeOPTargetList;
        }
        
        update opTargetList;
        isEditable = false;
    }
    
    public void resetRecord() {
        removeOPTargetList.clear();
        List<EUR_CRM_ObjPromo_Target__c> opTargetList = initOPTargetList(objPromo.Id);
        opTargetBrandAccountMap = initOPTargetBrandAccountMap(opTargetList);
        isEditable = false;
    }
    
    public void enableEdit() {
        isEditable = true;
    }
    
}