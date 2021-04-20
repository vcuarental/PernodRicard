public class EUR_CRM_OP_ActionValidationService {

    public static final String DRAFT_STATUS = 'Draft';

    public void validate(List<EUR_CRM_OP_Action__c> opActions) {
        Set<Id> templateIds = extractOpTemplateIds(opActions);
        List<EUR_CRM_Objectives_Promotions__c> objPromos = selectObjectivesPromotions(templateIds);

        System.debug('objPromos => ' + JSON.serializePretty(objPromos));
        System.debug('templateIds => ' + JSON.serializePretty(templateIds));

        for (EUR_CRM_OP_Action__c action : opActions) {
            if (!isTemplateEditable(action.EUR_CRM_OP_Template__c, objPromos)) {
                System.debug('true');
                action.addError(Label.EUR_CRM_OP_Action_Validation);
            }
        }

    }


    /*==========================================*/
    /*      High Level Helpers
    /*==========================================*/
    private Boolean isTemplateEditable(Id templateId, List<EUR_CRM_Objectives_Promotions__c> objPromos) {
        for (EUR_CRM_Objectives_Promotions__c objPromo : objPromos) {
            if (objPromo.EUR_CRM_OP_Template__c == templateId && objPromo.EUR_CRM_Status__c != DRAFT_STATUS) {
                return false;
            }
        }
        return true;
    }


    /*==========================================*/
    /*      Low Level Helpers
    /*==========================================*/
    private Set<Id> extractOpTemplateIds(List<EUR_CRM_OP_Action__c> actions) {
        Set<Id> templateIds = new Set<Id>();

        for (EUR_CRM_OP_Action__c action : actions) {
            templateIds.add(action.EUR_CRM_OP_Template__c);
        }
        return templateIds;
    }


    /*==========================================*/
    /*      SOQL Selectors
    /*==========================================*/
    private List<EUR_CRM_Objectives_Promotions__c> selectObjectivesPromotions(Set<Id> templateIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Status__c
            ,   EUR_CRM_OP_Template__c
            FROM EUR_CRM_Objectives_Promotions__c
            WHERE EUR_CRM_OP_Template__c IN :templateIds
            AND EUR_CRM_OP_Template__c != null
        ];
    }

}