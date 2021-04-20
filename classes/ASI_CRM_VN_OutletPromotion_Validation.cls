/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_PromotionReq_CheckContract
 * Description: pay max 50% if its performance less than 50%, and full pay if performance over 50%
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-12-4       Andy Zhang              Created
 * 2018-12-10      Andy Zhang              Bug fix ASI_CRM_Contract_Achieved__c is null
 ****************************************************************************************************************************/
public class ASI_CRM_VN_OutletPromotion_Validation {
    public void executeTrigger(List<sObject> newList) {

        List<ASI_GiftBox_Request_Header__c> requestList   = (List<ASI_GiftBox_Request_Header__c>) newList;

        // Get all contracts
        Set<Id> contractIds = ASI_CRM_VN_Util_Pluck.ids(requestList, ASI_GiftBox_Request_Header__c.ASI_CRM_VN_Contract__c);
        List<ASI_CRM_VN_Contract_Expenditure__c> expenditures = [
                SELECT id, ASI_CRM_Balance_Amount__c,ASI_CRM_VN_Contract__c,ASI_CRM_VN_Contract__r.ASI_CRM_Contract_Achieved__c,ASI_CRM_Achieved_Target_for_Outlet_Pay__c,ASI_CRM_VN_Amount__c
                FROM ASI_CRM_VN_Contract_Expenditure__c
                WHERE ASI_CRM_VN_Contract__c IN :contractIds
                AND ASI_CRM_VN_Item__c = 'Outlet Promotion' for update
        ];
//system.debug('ASI_CRM_VN_Contract__c'+expenditures.ex);
        Map<id, ASI_CRM_VN_Contract_Expenditure__c> expenditureMap = new Map<id, ASI_CRM_VN_Contract_Expenditure__c>();
        Map<id, Decimal > BalanceMap = new Map<id, Decimal>();

        for (ASI_CRM_VN_Contract_Expenditure__c exp : expenditures) {
            if (!expenditureMap.containsKey(exp.ASI_CRM_VN_Contract__c)) {
                expenditureMap.put(exp.ASI_CRM_VN_Contract__c, exp);
                BalanceMap.put(exp.ASI_CRM_VN_Contract__c, exp.ASI_CRM_Balance_Amount__c);
            }

        }

        for(ASI_GiftBox_Request_Header__c request: requestList)
        {
            ASI_CRM_VN_Contract_Expenditure__c exp = expenditureMap.get(request.ASI_CRM_VN_Contract__c);
            Decimal balance = BalanceMap.get(request.ASI_CRM_VN_Contract__c);
            //system.debug('target'+exp.ASI_CRM_Achieved_Target_for_Outlet_Pay__c);
            request.ASI_CRM_VN_Amount__c = request.ASI_CRM_VN_Amount__c == null? 0:request.ASI_CRM_VN_Amount__c;
            if (balance == null) {
                request.addError('Contract should have Expenditure Promotion.');
            } else if (exp.ASI_CRM_VN_Contract__r.ASI_CRM_Contract_Achieved__c>= exp.ASI_CRM_Achieved_Target_for_Outlet_Pay__c) {
                //full claim when meet the target
                if (request.ASI_CRM_VN_Amount__c <= balance) {
                    BalanceMap.put(request.ASI_CRM_VN_Contract__c, balance - request.ASI_CRM_VN_Amount__c);
                }
                else{
                    request.addError('Contract amount exceed Expenditure balance');
                }

            }
            else{
                //50 percent claim if not meet target
                if(request.ASI_CRM_VN_Amount__c <=exp.ASI_CRM_VN_Amount__c*0.5 && request.ASI_CRM_VN_Amount__c < balance){
                    BalanceMap.put(request.ASI_CRM_VN_Contract__c, balance - request.ASI_CRM_VN_Amount__c);
                }
                else
                {
                    request.addError('Contract amount exceed Expenditure balance');
                }

            }
    }
    }

}