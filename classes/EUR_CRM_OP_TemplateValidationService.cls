public class EUR_CRM_OP_TemplateValidationService {

    public static final String DRAFT_STATUS = 'Draft';

    public void validate(Map<Id, EUR_CRM_OP_Template__c> op_templatesByIds) {
        List<EUR_CRM_Objectives_Promotions__c> objPromos = selectObjectivesPromotions(op_templatesByIds.keySet());

        for (EUR_CRM_Objectives_Promotions__c objPromo : objPromos) {
            if (objPromo.EUR_CRM_Status__c != DRAFT_STATUS) {
                op_templatesByIds.get(objPromo.EUR_CRM_OP_Template__c).addError(Label.EUR_CRM_OP_Action_Validation);
            }
        }

    }


    /*==========================================*/
    /*      SOQL SELECTORS
    /*==========================================*/
    private List<EUR_CRM_Objectives_Promotions__c> selectObjectivesPromotions(Set<Id> templateIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            ,   EUR_CRM_OP_Template__c
            FROM EUR_CRM_Objectives_Promotions__c
            WHERE EUR_CRM_OP_Template__c IN :templateIds
        ];
    }

}