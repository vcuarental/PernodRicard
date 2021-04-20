global without sharing class ASI_MFM_CN_InputPOReceiptPhasingUtility {
    
    public static Map<id, ASI_MFM_PO__c> getPoMap(Set<Id> poidSet) {
         return new Map<id, ASI_MFM_PO__c>([SELECT id,ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c, ASI_MFM_PO_Amount__c, ASI_MFM_Status__c, ASI_MFM_Total_Paid_Amount__c, ASI_MFM_Total_Receipt_Amount__c,
                                            RecordTypeId , ASI_MFM_Supplier_Number__c, ASI_MFM_BU_Code__r.ASI_MFM_Auto_Receipt__c, ASI_MFM_PO_Type__c, ASI_MFM_FY_Start_Date__c, ASI_MFM_FY_End_Date__c
                                     FROM ASI_MFM_PO__c 
                                     WHERE id IN :poidSet]);
    }
    
    public static Map<Id, List<ASI_MFM_PO_Receipt_Phasing__c>> getPoPhasingMap(Set<Id> poidSet) {
    	List<ASI_MFM_PO_Receipt_Phasing__c> recieptPhasingList = [SELECT id, ASI_MFM_PO_Start_Date__c, ASI_MFM_PO_End_Date__c, ASI_MFM_Version__c, ASI_MFM_Comments__c, ASI_MFM_PO__c, 
                                                                  ASI_MFM_Modify_BY__c, ASI_MFM_PO_Approved__c, ASI_MFM_Create_Date__c,
                                                                  ASI_MFM_Allocated_Amount_1__c, ASI_MFM_Allocated_Amount_2__c , ASI_MFM_Allocated_Amount_3__c, 
                                                                  ASI_MFM_Allocated_Amount_4__c, ASI_MFM_Allocated_Amount_5__c, ASI_MFM_Allocated_Amount_6__c, 
                                                                  ASI_MFM_Allocated_Amount_7__c, ASI_MFM_Allocated_Amount_8__c, ASI_MFM_Allocated_Amount_9__c, 
                                                                  ASI_MFM_Allocated_Amount_10__c, ASI_MFM_Allocated_Amount_11__c, ASI_MFM_Allocated_Amount_12__c, ASI_MFM_Amount_Total__c 
                                                                  FROM ASI_MFM_PO_Receipt_Phasing__c
                                                                  WHERE ASI_MFM_PO__c IN :poidSet
                                                                  ORDER BY ASI_MFM_PO__c, CreatedDate, Id, ASI_MFM_Version__c];
        
        Map<Id, List<ASI_MFM_PO_Receipt_Phasing__c>> recieptPhasingMap = new Map<Id, List<ASI_MFM_PO_Receipt_Phasing__c>>();
        for(ASI_MFM_PO_Receipt_Phasing__c recieptPhasing : recieptPhasingList) {
        	if(!recieptPhasingMap.containsKey(recieptPhasing.ASI_MFM_PO__c)) { recieptPhasingMap.put(recieptPhasing.ASI_MFM_PO__c, new List<ASI_MFM_PO_Receipt_Phasing__c>()); }
			recieptPhasingMap.get(recieptPhasing.ASI_MFM_PO__c).add(recieptPhasing);
		}
        return recieptPhasingMap;
    }

}