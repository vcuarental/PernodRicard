public without sharing class ASI_CRM_TW_PAFItems_TriggerCls{
    public static void routineBeforeUpsert(list<ASI_HK_CRM_Pre_Approval_Form_Item__c> trigger_new, map<id, ASI_HK_CRM_Pre_Approval_Form_Item__c> trigger_oldMap) {
        Set<Id> setPAFId = new Set<Id>();
        Set<Id> setContractItmId = new Set<Id>();
        Set<Id> setMechanicId = new Set<Id>();
        
        Map<Id, ASI_HK_CRM_Pre_Approval_Form__c> mapPAF;
        Map<Id, ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> mapPAFMechanic;
        
        List<String> strChannels = new List<String>();
        
        for(ASI_HK_CRM_Pre_Approval_Form_Item__c itm : trigger_new){
            if(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c != NULL)
                setPAFId.add(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c);
            if(itm.ASI_HK_CRM_Mechanic__c != NULL)
                setMechanicId.add(itm.ASI_HK_CRM_Mechanic__c);
            if(itm.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment') &&
               itm.ASI_CRM_Contracted_Item__c != NULL)
                setContractItmId.add(itm.ASI_CRM_Contracted_Item__c);
        }
        
        mapPAFMechanic = new Map<Id, ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>([SELECT id, Name, ASI_CRM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c, ASI_CRM_A_C_Code__r.ASI_MFM_Reporting_Category__c, ASI_CRM_A_C_Code__r.ASI_MFM_GL_Class__c FROM ASI_HK_CRM_Pre_Approval_Form_Mechanic__c WHERE Id IN: setMechanicId]);
        mapPAF = new Map<Id, ASI_HK_CRM_Pre_Approval_Form__c>([SELECT Id, ASI_CRM_Channel__c, ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c, ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE Id IN: setPAFId]);
        system.debug('mapPAF: '+mapPAF);
        
        for(String pafId : mapPAF.KeySet()){
            if(mapPAF.get(pafId).ASI_CRM_Channel__c != NULL){
                if(mapPAF.get(pafId).ASI_CRM_Channel__c != NULL){
                    strChannels.add('\''+ mapPAF.get(pafId).ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c +'\'');
                    //setChannels.add(mapPAF.get(pafId).ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c);
                }
                if(mapPAF.get(pafId).ASI_CRM_Sub_Channel__c != NULL){
                    strChannels.add('\''+ mapPAF.get(pafId).ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c +'\'');
                    //setChannels.add(mapPAF.get(pafId).ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c);
                }
            }
        }
        
        //Map effective SKU Cost/Price for Item Group
        List<String> listType = new List<String>();
        listType.add('A&D Budget (w/VAT)');
        Map<String, ASI_CRM_MY_SKUPriceCost__c> mapSKUpc = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();
        ASI_CRM_TW_ItemGroup_UtilityCls utilityCls = new ASI_CRM_TW_ItemGroup_UtilityCls();
        for(ASI_CRM_MY_SKUPriceCost__c skupc : utilityCls.getAllEffectiveSKUpc(strChannels, setContractItmId, listType, Date.today())){
            for(String channel : strChannels){
                if(skupc.ASI_CRM_Applied_To__c.contains(channel))
                    mapSKUpc.put(skupc.ASI_CRM_Item_Group__c+channel, skupc);
            }
        }
        system.debug('Contract Item Id: '+setContractItmId);
        system.debug('Channels: '+strChannels);
        system.debug('mapSKUpc: '+mapSKUpc);
           
        for(ASI_HK_CRM_Pre_Approval_Form_Item__c itm : trigger_new){
            //update Cash per Bottle (A&D Budget)
            if(itm.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')){
                if(mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c) != NULL && 
                   mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c).ASI_CRM_Channel__c != NULL &&
                   mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c).ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c != NULL &&
                   mapSKUpc.get(itm.ASI_CRM_Contracted_Item__c+mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c).ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c) != NULL &&
                   mapSKUpc.get(itm.ASI_CRM_Contracted_Item__c+mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c).ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c).ASI_CRM_Cost__c != NULL)
                    itm.ASI_CRM_Cash_per_Bottle_A_D_Budget__c = Math.abs(mapSKUpc.get(itm.ASI_CRM_Contracted_Item__c+mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c).ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c).ASI_CRM_Cost__c);
                else if(mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c) != NULL && 
                        mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c).ASI_CRM_Sub_Channel__c != NULL &&
                        mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c).ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c != NULL &&
                        mapSKUpc.get(itm.ASI_CRM_Contracted_Item__c+mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c).ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c) != NULL &&
                        mapSKUpc.get(itm.ASI_CRM_Contracted_Item__c+mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c).ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c).ASI_CRM_Cost__c != NULL)
                    itm.ASI_CRM_Cash_per_Bottle_A_D_Budget__c = Math.abs(mapSKUpc.get(itm.ASI_CRM_Contracted_Item__c+mapPAF.get(itm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c).ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c).ASI_CRM_Cost__c);
                else
                    itm.ASI_CRM_Cash_per_Bottle_A_D_Budget__c = NULL;
            }
               
            if(itm.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment') ||
               itm.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')){
               
               //validate if selected A/C Code of PAF Mechanic has GL Class
               if(mapPAFMechanic.get(itm.ASI_HK_CRM_Mechanic__c).ASI_CRM_A_C_Code__c != null && mapPAFMechanic.get(itm.ASI_HK_CRM_Mechanic__c).ASI_CRM_A_C_Code__r.ASI_MFM_GL_Class__c == null){
                   itm.addError('Please setup GL Class of A/C Code for selected PAF Mechanic '+mapPAFMechanic.get(itm.ASI_HK_CRM_Mechanic__c).Name);
               }
               
               //update A&D or A&P value of Conditional/Fixed PAF itm
               if(mapPAFMechanic != null && mapPAFMechanic.get(itm.ASI_HK_CRM_Mechanic__c) != null && mapPAFMechanic.get(itm.ASI_HK_CRM_Mechanic__c).ASI_CRM_A_C_Code__c != null){
                   if(mapPAFMechanic.get(itm.ASI_HK_CRM_Mechanic__c).ASI_CRM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'Total A&D')
                       itm.ASI_CRM_AD_or_AP__c = 'A&D';
                   else if(mapPAFMechanic.get(itm.ASI_HK_CRM_Mechanic__c).ASI_CRM_A_C_Code__r.ASI_MFM_Reporting_Category__c == 'Trade')
                       itm.ASI_CRM_AD_or_AP__c = 'Trade A&P';    
                   else if(mapPAFMechanic.get(itm.ASI_HK_CRM_Mechanic__c).ASI_CRM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c == 'TOTAL A&P' )
                       itm.ASI_CRM_AD_or_AP__c = 'MKT A&P';
                   
               }
            }
        }
    }
}