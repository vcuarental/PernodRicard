/*********************************************************************************
 * Name:        ASI_CRM_MY_PaymentRequestCommon
 * Description: For all PRMY Payment Request Manipulation
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -------------------------------------
 * 2015-01-03       Introv: Axel     Created
*********************************************************************************/
public class ASI_CRM_MY_PaymentRequestCommon {

    // Declaration
    private id idRTPR;
    private id idRTPRLine;
    // Declaration - End

    public ASI_CRM_MY_PaymentRequestCommon() {
        this.idRTPR = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request');
        this.idRTPRLine = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_MY_Payment_Request_Detail');
    }
    
    /** to spawn Payment Request Line Item accoding to its contract when the Payment Request Header is initially created */
    public void spawnPaymentRequestLineItems(list<ASI_TH_CRM_PaymentRequest__c> lstPR) {
        
        // Declaration
        set<id> setContract = new set<id>();
        map<id, id> mapPRContract = new map<id, id>(); // <PR ID, ContractID>
        list<ASI_CRM_ContractOtherIncentive__c> lstIncentive = new list<ASI_CRM_ContractOtherIncentive__c>();
        list<ASI_CRM_ContractVolumeIncentive__c> lstVolIncentive = new list<ASI_CRM_ContractVolumeIncentive__c>();
        list<ASI_TH_CRM_PaymentRequestLineItem__c> lstPRLineSeed = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        map<id, list<ASI_TH_CRM_PaymentRequestLineItem__c>> mapPRLineSeed = new map<id, list<ASI_TH_CRM_PaymentRequestLineItem__c>>(); // <ContractID, PRLines>
        list<ASI_TH_CRM_PaymentRequestLineItem__c> lstPRLineEntry = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        // Declaration - End
        
        for (ASI_TH_CRM_PaymentRequest__c objPR : lstPR) {
            setContract.add(objPR.ASI_TH_CRM_Contract__c);
            mapPRContract.put(objPR.ASI_TH_CRM_Contract__c, objPR.id);
        }
        
        // Get All the Incentive of the related contracts
        lstIncentive = [
            SELECT id, ASI_CRM_SKU__c, ASI_CRM_SetupCode__c, ASI_CRM_Contract__c FROM ASI_CRM_ContractOtherIncentive__c WHERE ASI_CRM_Contract__c IN :setContract
            AND ASI_CRM_SetupCode__c <> ''
        ];
        lstVolIncentive = [
            SELECT id, ASI_CRM_SKU__c, ASI_CRM_SetupCode__c, ASI_CRM_Contract__c FROM ASI_CRM_ContractVolumeIncentive__c WHERE ASI_CRM_Contract__c IN :setContract
            AND ASI_CRM_SetupCode__c <> ''
        ];
        for (ASI_CRM_ContractOtherIncentive__c objIncentive : lstIncentive) {
            ASI_TH_CRM_PaymentRequestLineItem__c objPRLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                //ASI_TH_CRM_Payment_Request__c = mapPRContract.get(objIncentive.ASI_CRM_Contract__c),
                RecordTypeID = this.idRTPRLine,
                ASI_CRM_SKU__c = objIncentive.ASI_CRM_SKU__c,
                ASI_CRM_SetupCode__c = objIncentive.ASI_CRM_SetupCode__c,
                ASI_CRM_CN_Actual_Vol__c = 0,
                ASI_TH_CRM_Amount__c = 0
            );
            lstPRLineSeed = mapPRLineSeed.get(objIncentive.ASI_CRM_Contract__c) != null ? mapPRLineSeed.get(objIncentive.ASI_CRM_Contract__c) : new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
            lstPRLineSeed.add(objPRLine);
            
            mapPRLineSeed.put(objIncentive.ASI_CRM_Contract__c, lstPRLineSeed);
        }
        
        for (ASI_CRM_ContractVolumeIncentive__c objIncentive : lstVolIncentive) {
            ASI_TH_CRM_PaymentRequestLineItem__c objPRLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                //ASI_TH_CRM_Payment_Request__c = mapPRContract.get(objIncentive.ASI_CRM_Contract__c),
                RecordTypeID = this.idRTPRLine,
                ASI_CRM_SKU__c = objIncentive.ASI_CRM_SKU__c,
                ASI_CRM_SetupCode__c = objIncentive.ASI_CRM_SetupCode__c,
                ASI_CRM_CN_Actual_Vol__c = 0,
                ASI_TH_CRM_Amount__c = 0
            );
            lstPRLineSeed = mapPRLineSeed.get(objIncentive.ASI_CRM_Contract__c) != null ? mapPRLineSeed.get(objIncentive.ASI_CRM_Contract__c) : new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
            lstPRLineSeed.add(objPRLine);
            
            mapPRLineSeed.put(objIncentive.ASI_CRM_Contract__c, lstPRLineSeed);
        }
        
        for (ASI_TH_CRM_PaymentRequest__c objPR : lstPR) {
            if (mapPRLineSeed.get(objPR.ASI_TH_CRM_Contract__c) != null) {
                list<ASI_TH_CRM_PaymentRequestLineItem__c> lstPRLines = (mapPRLineSeed.get(objPR.ASI_TH_CRM_Contract__c)).deepClone(false, false);
                for (ASI_TH_CRM_PaymentRequestLineItem__c objPRLine : lstPRLines) {
                    objPRLine.ASI_TH_CRM_Payment_Request__c = objPR.id;
                }
                
                lstPRLineEntry.addAll(lstPRLines);
            }
        }
        if (lstPRLineEntry != null && lstPRLineEntry.size() > 0) {
            insert lstPRLineEntry;
        }
    }
}