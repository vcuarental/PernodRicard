public with sharing class ASI_CRM_HK_PAFChannelCustomer extends ASI_HK_CRM_TriggerAbstract {
    
    private TriggerAction tAction;
    private Map<ID, ASI_HK_CRM_Pre_Approval_Form__c> newMap;
    private Map<ID, ASI_HK_CRM_Pre_Approval_Form__c> oldMap;
    
    public ASI_CRM_HK_PAFChannelCustomer() {
        super('ASI_CRM_HK_PAFChannelCustomer');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if (tAction == TriggerAction.AFTER_UPDATE) {
            List<ASI_HK_CRM_Pre_Approval_Form__c> pafList = (List<ASI_HK_CRM_Pre_Approval_Form__c>)sObjList;
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCList = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
            Set<id> CustomerUpdatedIdSet = new Set<id>();
            //List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCUpdateList = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>(); //2015-12-30, modified Leo@Elufa
            //Set<id> customerIdSet = new Set<id>(); //2015-12-30, modified Leo@Elufa
            this.tAction = tAction;
            this.newMap = (Map<ID, ASI_HK_CRM_Pre_Approval_Form__c>)newMap;
            this.oldMap = (Map<ID, ASI_HK_CRM_Pre_Approval_Form__c>)oldMap;
            
            for (ASI_HK_CRM_Pre_Approval_Form__c paf : pafList) {
                if(paf.ASI_HK_CRM_PAF_Customer__c != null && paf.ASI_HK_CRM_PAF_Customer__c != this.oldMap.get(paf.id).ASI_HK_CRM_PAF_Customer__c) {
                    
                    CustomerUpdatedIdSet.add(paf.id);              
                }
                
                //2015-12-30, modified Leo@Elufa
                /*if(paf.ASI_HK_CRM_PAF_Status__c == 'FM Approved'
                   ||paf.ASI_HK_CRM_PAF_Status__c == 'FD Approved'
                   ||paf.ASI_HK_CRM_PAF_Status__c == 'MD Final')
                {
                    customerIdSet.add(paf.id);
                }//end if: checkig status*/
                //2015-12-30, modified Leo@Elufa
                
            }
            
            //2015-12-30, modified Leo@Elufa
            /*if(customerIdSet.size() > 0) {    
                PAFCUpdateList = [SELECT Id,
                                  ASI_CRM_Generate_Price_Set__c 
                                  FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                                  WHERE ASI_CRM_HK_Pre_Approval_Form__c IN :customerIdSet];              
            }
            if (PAFCUpdateList.size() > 0)
            {
                for(ASI_CRM_HK_Pre_Approval_Form_Customer__c pafc: PAFCUpdateList)
                {
                    pafc.ASI_CRM_Generate_Price_Set__c = True; //set True
                }//end for: loop pafc list
                update PAFCUpdateList;
            }//end if: pafc list size > 0*/
            //2015-12-30, modified Leo@Elufa
            
            if(CustomerUpdatedIdSet.size() > 0) {    
                PAFCList = [SELECT id FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c WHERE ASI_CRM_HK_Pre_Approval_Form__c IN :CustomerUpdatedIdSet];              
            }
            if (PAFCList.size() > 0)
            {
                delete PAFCList;
            }
            
        }
    }
}