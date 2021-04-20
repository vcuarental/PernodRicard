/**********************************************************************************
 * Name : ASI_CRM_SG_PopulateInfl_Distr_Rate
 * Created : DC @02/19/2016 10:35 AM
 * Revision History:
 * 1. 02/19/2016 - [DC 1.0] Created
 **********************************************************************************/

public with sharing class ASI_CRM_SG_PopulateInfl_Distr_Rate extends ASI_CRM_SG_TriggerAbstract {

    public ASI_CRM_SG_PopulateInfl_Distr_Rate() {
        super('ASI_CRM_SG_PopulateInfl_Distr_Rate');
    }

    public override void executeTriggerAction(
        TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

        List<ASI_TH_CRM_Contract__c> lstNewContracts = (List<ASI_TH_CRM_Contract__c>) sObjList;
        List<ASI_CRM_SG_Rate__c> lstRateData = sortRateData(ASI_CRM_SG_Rate__c.getAll().values());

        for(ASI_TH_CRM_Contract__c contractIterator : lstNewContracts) {

            Boolean isInflationSet = false;
            Boolean isDistributionSet = false;
            if(contractIterator.ASI_TH_CRM_Start_Date__c == NULL) {
                contractIterator.ASI_CRM_Inflation_Rate__c = NULL;
                contractIterator.ASI_CRM_Distribution_Rate__c = NULL;
                break;
            }

            for(ASI_CRM_SG_Rate__c rateIterator : lstRateData) {
                if(contractIterator.ASI_TH_CRM_Start_Date__c >= rateIterator.ASI_CRM_SG_Effective_Date__c) {
                    
                    if(String.isNotBlank(rateIterator.ASI_CRM_SG_Type__c)
                    && rateIterator.ASI_CRM_SG_Type__c.equalsIgnoreCase('Distribution')
                    && isDistributionSet == false) {
                        contractIterator.ASI_CRM_Distribution_Rate__c = rateIterator.ASI_CRM_SG_Rate__c;
                        isDistributionSet = true;
                    
                    } else if(String.isNotBlank(rateIterator.ASI_CRM_SG_Type__c)
                           && rateIterator.ASI_CRM_SG_Type__c.equalsIgnoreCase('Inflation')
                           && isInflationSet == false) {
                        contractIterator.ASI_CRM_Inflation_Rate__c = rateIterator.ASI_CRM_SG_Rate__c;
                        isInflationSet = true;
                    }
                }
                if(isDistributionSet == false) {
                    contractIterator.ASI_CRM_Distribution_Rate__c = NULL;
                }
                if(isInflationSet == false) {
                    contractIterator.ASI_CRM_Inflation_Rate__c = NULL;
                }
            }
        }
    }

    public List<ASI_CRM_SG_Rate__c> sortRateData(List<ASI_CRM_SG_Rate__c> pLstRateData) {
        for (Integer outerIndex = 0; outerIndex < pLstRateData.size(); outerIndex++) {

            ASI_CRM_SG_Rate__c swapVar = new ASI_CRM_SG_Rate__c();

            for (Integer innerIndex = 0; innerIndex < pLstRateData.size() - outerIndex - 1; innerIndex++) {

                if (pLstRateData[innerIndex].ASI_CRM_SG_Effective_Date__c <     /* For ascending order use > */
                    pLstRateData[innerIndex + 1].ASI_CRM_SG_Effective_Date__c) {

                    // Swapping the element positions if found smaller.
                    swapVar = pLstRateData[innerIndex];
                    pLstRateData[innerIndex] = pLstRateData[innerIndex + 1];
                    pLstRateData[innerIndex + 1] = swapVar;
                }
            }
        }
        return pLstRateData;
    }
}