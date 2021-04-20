public with sharing class ASI_CRM_CN_Contract_BRSF_TriggerClass {
    public ASI_CRM_CN_Contract_BRSF_TriggerClass (){}
    
    //----- added by leo @2014/06/25 (start) -----
    public static void routineBeforeUpsert(list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> trigger_new, map<id, ASI_CRM_CN_Contract_BRSF_Line_Item__c> trigger_oldMap) {
        //******* check duplicate BRSF Item (start) *******
        Set<ID> contractIdSet = new Set<ID>();
        
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf: trigger_new) {
            if(brsf.ASI_CRM_CN_Contract__c != null && brsf.ASI_CRM_CN_Sub_Brand__c != null)
            {
                if(!contractIdSet.contains(brsf.ASI_CRM_CN_Contract__c))
                    contractIdSet.add(brsf.ASI_CRM_CN_Contract__c);
            }
        }
        
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> brsfList = 
            [SELECT ASI_CRM_CN_Contract__c, ASI_CRM_CN_Sub_Brand__c, id FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c =: contractIdSet];
            
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf: trigger_new) {
            if(brsf.ASI_CRM_CN_Contract__c != null && brsf.ASI_CRM_CN_Sub_Brand__c != null)
            {
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c tempBRSF : brsfList) {                
                    if(tempBRSF.ASI_CRM_CN_Contract__c == brsf.ASI_CRM_CN_Contract__c && tempBRSF.ASI_CRM_CN_Sub_Brand__c == brsf.ASI_CRM_CN_Sub_Brand__c)
                    {
                        if(brsf.Id == null || (brsf.Id != null && brsf.Id != tempBRSF.Id))
                            brsf.addError('Duplication of BRSF Items Exist!');
                    }
                }
                
                integer count = 0;
                for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsfUpdated: trigger_new) {
                    if(brsfUpdated.ASI_CRM_CN_Contract__c == brsf.ASI_CRM_CN_Contract__c && brsfUpdated.ASI_CRM_CN_Sub_Brand__c == brsf.ASI_CRM_CN_Sub_Brand__c)
                    {
                        count += 1;
                    }
                }
                
                if(count > 1) brsf.addError('Duplication of BRSF Items Exist!');
            }
        }

        //******* check duplicate BRSF Item (end) *******
    }
    //----- added by leo @2014/06/25 (end) -----
    
    public static void routineAfterAll(list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> trigger_new, map<id, ASI_CRM_CN_Contract_BRSF_Line_Item__c> trigger_oldMap) {
        System.debug(trigger_new);
        calcLatestVol(trigger_new);
        
            
        
    }
      
    public static void routineAfterDelete(list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> trigger_old){
        calcLatestVol(trigger_old);
    }
    
    private static void calcLatestVol(List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF){
        // Calculate latest contract estimate vol in Customer for reporting
        Set<id> SContractID = new Set<id>();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf : LBRSF){
            SContractID.add(brsf.ASI_CRM_CN_Contract__c);
        }

        List<ASI_TH_CRM_Contract__c> LContract = [Select id, name, ASI_CRM_CN_Outlet_WS__c, 
            ASI_CRM_CN_BRSF_Total_Est_Monthly_Qty__c, ASI_CRM_CN_PO_Start_Date__c
            from ASI_TH_CRM_Contract__c
            where id IN :SContractID and 
            (ASI_TH_CRM_Promotion_Type__c = 'New Contract ON' or ASI_TH_CRM_Promotion_Type__c = 'New Contract OFF'
            or ASI_TH_CRM_Promotion_Type__c = 'New Contract - On' or ASI_TH_CRM_Promotion_Type__c = 'New Contract - Off')
            and ASI_CRM_CN_Status__c = 'Final'
            order by ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Start_Date__c desc ];
        System.debug(LContract);
        Set<id> SCustomerID = new Set<id>();
        for(ASI_TH_CRM_Contract__c c : LContract){
            SCustomerID.add(c.ASI_CRM_CN_Outlet_WS__c);
        }

        List<ASI_CRM_AccountsAdditionalField__c> LCustomer = [Select id, name, ASI_CRM_CN_Latest_Contract_Target_Volume__c 
            from ASI_CRM_AccountsAdditionalField__c
            where id IN :SCustomerID];
        System.debug(LCustomer);

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LContractBRSF = [SELECT ASI_CRM_CN_Contract__c, ASI_CRM_CN_Sub_Brand__c, id, ASI_CRM_CN_Est_Monthly_Qty__c  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c =: SContractID];

        calcLatestVol(LCustomer, LContract, LContractBRSF);
    }
    
    private static void calcLatestVol(List<ASI_CRM_AccountsAdditionalField__c> LCustomer, List<ASI_TH_CRM_Contract__c> LContract, List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LContractBRSF){
        Map<id,ASI_CRM_AccountsAdditionalField__c> MCustomer = new Map<id,ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c cus :LCustomer){
            MCustomer.put(cus.id, cus);
        }
        System.debug(MCustomer);
        List<ASI_CRM_AccountsAdditionalField__c> LCustomerUpdate = new List<ASI_CRM_AccountsAdditionalField__c>();
        Set<id> SCusUpdatedID = new Set<id>();
        for(ASI_TH_CRM_Contract__c con : LContract){
            if(!SCusUpdatedID.contains(con.ASI_CRM_CN_Outlet_WS__c) && MCustomer.containsKey(con.ASI_CRM_CN_Outlet_WS__c)){
                ASI_CRM_AccountsAdditionalField__c cus = MCustomer.get(con.ASI_CRM_CN_Outlet_WS__c);
                System.debug(cus);

                // get Est_Monthly_Qty from Contract BRSF Line items
                decimal sumEstMonthlyQty = 0;
                if(LContractBRSF != null && LContractBRSF.size()>0)
                {
                    for(ASI_CRM_CN_Contract_BRSF_Line_Item__c conBRSF : LContractBRSF){
                        if(conBRSF.ASI_CRM_CN_Contract__c == con.id)
                        {
                            if(conBRSF.ASI_CRM_CN_Est_Monthly_Qty__c != null)
                            {
                                sumEstMonthlyQty += conBRSF.ASI_CRM_CN_Est_Monthly_Qty__c;
                            }
                        }
                    }                                   
                }

                cus.ASI_CRM_CN_Latest_Contract_Target_Volume__c  = sumEstMonthlyQty;
                SCusUpdatedID.add(con.ASI_CRM_CN_Outlet_WS__c);
                LCustomerUpdate.add(cus);
            }
        }
        System.debug(LCustomerUpdate);
        if(LCustomerUpdate != null && LCustomerUpdate.size()>0){
            update LCustomerUpdate;
        }
    }
}