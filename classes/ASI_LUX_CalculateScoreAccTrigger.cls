/*********************************************************************************
 * Name:ASI_LUX_CalculateScoreAccTrigger
 * Description: Calculate Lux Account score for manual Data Input in Lux Account
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/10/2014       Laputa: Conrad          Created
 * 07/11/2014       Laputa: Conrad          Add Account recordtypeID change
*********************************************************************************/

public with sharing class ASI_LUX_CalculateScoreAccTrigger extends ASI_HK_CRM_TriggerAbstract {

    public ASI_LUX_CalculateScoreAccTrigger() {
        super('ASI_LUX_CalculateScoreAccTrigger');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<Account> validAccountList = new List<Account>();
        
        
        //if(oldMap == null) {
            validAccountList = (List<Account>)sObjList;
        //} 
        /*else {
            // If Update trigger, filter out the ones that are valid AKA the ones where the update affects the score
            Map<ID, Account> accOldMap= (Map<ID, Account>) oldmap;
            
            for(Account acc : (List<Account>)sObjList) {
                // Only filter out the sales order where the Amount or Order Date has been updated: only applies for after update
                if(acc.ASI_LUX_Well_conn_within_social_circle__c != accOldMap.get(acc.id).ASI_LUX_Well_conn_within_social_circle__c
                    || acc.ASI_LUX_Recognized_within_their_industry__c != accOldMap.get(acc.id).ASI_LUX_Recognized_within_their_industry__c
                    || acc.ASI_LUX_Has_media_interest__c != accOldMap.get(acc.id).ASI_LUX_Has_media_interest__c
                    || (acc.recordtypeID != accOldMap.get(acc.id).recordtypeID)) {
                        validAccountList.add(acc);
                    }
            }
            
        }*/
        
        if (validAccountList.size() > 0) {
            
            for (account acc : validAccountList) {
            
                Decimal totalScore = 0;
                
                if(acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c != null && acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c != '') {
                    String[] splitPurchaseBehavior = acc.ASI_LUX_Purchase_Behavior_Spend_YTD__c.split(' ');
                    if(splitPurchaseBehavior.size() > 1) {
                        String purchaseScore = splitPurchaseBehavior[1].subString(0,splitPurchaseBehavior[1].length()-1);
                        if(purchaseScore.isNumeric()) {
                            totalScore += Decimal.valueof(purchaseScore);
                        }
                    }
                }
                
                if(acc.ASI_LUX_Purchase_Behavior_Freq_YTD__c != null && acc.ASI_LUX_Purchase_Behavior_Freq_YTD__c != '') {
                    String[] splitPurchaseFrequency = acc.ASI_LUX_Purchase_Behavior_Freq_YTD__c.split(' ');
                    if(splitPurchaseFrequency.size() > 2) {
                        String purchaseFreqScore = splitPurchaseFrequency[2];
                        if(purchaseFreqScore.isNumeric()) {
                            totalScore += Decimal.valueof(purchaseFreqScore);
                        }
                    }
                }
                
                if ('1 Low'.equals (acc.ASI_LUX_Well_conn_within_social_circle__c)){
                    totalScore = totalScore + 1;
                }else if ('3 Medium'.equals (acc.ASI_LUX_Well_conn_within_social_circle__c)){
                    totalScore = totalScore + 3;
                } else if ('5 High'.equals (acc.ASI_LUX_Well_conn_within_social_circle__c)){
                    totalScore = totalScore + 5;
                } 

                if ('1 Low'.equals (acc.ASI_LUX_Recognized_within_their_industry__c)){
                    totalScore = totalScore + 1;
                }else if ('3 Medium'.equals (acc.ASI_LUX_Recognized_within_their_industry__c)){
                    totalScore = totalScore + 3;
                }else if ('5 High'.equals (acc.ASI_LUX_Recognized_within_their_industry__c)){
                    totalScore = totalScore + 5;
                }

                if ('1 Low'.equals (acc.ASI_LUX_Has_media_interest__c)){
                    totalScore = totalScore + 1;
                }else if ('3 Medium'.equals (acc.ASI_LUX_Has_media_interest__c)){
                    totalScore = totalScore + 3;
                }else if ('5 High'.equals (acc.ASI_LUX_Has_media_interest__c)){
                    totalScore = totalScore + 5;
                }
                
                acc.ASI_LUX_Total_Score__c = totalScore;
                
            }
        }
        
    }

}