/************************
*Create Date: 2016-12-29
*Created By : Jay
*Purpose    : Auto assign city after user enter postal code, reference EUR_CRM_Postal_Code_City_Mapping__c
*Record Type: 
*************************/

public class EUR_CRM_Account_City_PostalCode_Handler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_Account_City_PostalCode_Handler() {
        super('EUR_CRM_Account_City_PostalCode_Handler');
    }

    @TestVisible
    private static Map<String, String> postalCodeRTDevNameByValidAccountRTDevName = new Map<String, String>{
            'EUR_DE_OFF_STD' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_Off_Trade_New_Business' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_Off_Trade_Retail' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_ON_Consumers' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_ON_Enquiry_Acquisition' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_ON_Service_agency' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_On_Trade_B2B' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_On_Trade_Gastronomy' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_On_Trade_Hotel' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_On_Trade_New_Business' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_On_Trade_Special_Stores' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_On_Trade_System_Gastronomy' => 'EUR_DE_Postal_Code_City_Mapping',
            'EUR_DE_On_Trade_Wholesaler' => 'EUR_DE_Postal_Code_City_Mapping'
    };


    public static Set<String> TargetRecordSet {
        get {
            Set<String> TRt = new Set<String>();
            TRt.addAll(postalCodeRTDevNameByValidAccountRTDevName.keySet());

            return TRt;
        }
        private set;
    }


    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        Set<String> accPostalCodes = new Set<String>();
        Set<String> postalCodeRecordTypes = new Set <String>();
        List<EUR_CRM_Account__c> targetAccount = new List<EUR_CRM_Account__c>();

        //TODO: following conditions take out in separate methods
        if (tAction == TriggerAction.BEFORE_INSERT || (tAction == TriggerAction.BEFORE_UPDATE && isPostalCodeChanged(newMap, oldMap))) {

            // TODO: use Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosById().get('<id>').getDeveloperName();
            Map<Id, Recordtype> allAccountRecordTypesByIds = EUR_CRM_AccountUtils.recordtypeMap;

            for (EUR_CRM_Account__c acc : (List<EUR_CRM_Account__c>) sObjList) {
                String accountRecordType = allAccountRecordTypesByIds.get(acc.RecordTypeId).DeveloperName;

                if (postalCodeRTDevNameByValidAccountRTDevName.containsKey(accountRecordType) && acc.EUR_CRM_Postal_Code__c != null) {
                    accPostalCodes.add(acc.EUR_CRM_Postal_Code__c);
                    postalCodeRecordTypes.add(postalCodeRTDevNameByValidAccountRTDevName.get(accountRecordType));
                    targetAccount.add(acc);
                }
            }
        }

        if (accPostalCodes.size() > 0 && postalCodeRecordTypes.size() > 0) {
            List<EUR_CRM_Postal_Code_City_Mapping__c> postalCodeList = selectPostalCodesWherePostalCodeAndRecordTypes(accPostalCodes, postalCodeRecordTypes);
            Map<String, String> postalCodeCityMap = getCityNameByPostalCode(postalCodeList);

            assignAccountCityByPostalCode(targetAccount, postalCodeCityMap);
        }
    }

    /*============================
    * High Level Helpers
    * ============================*/

    private static void assignAccountCityByPostalCode(List<EUR_CRM_Account__c> targetAccounts, Map<String, String> postalCodeCityMap) {
        for (EUR_CRM_Account__c acc : targetAccounts) {
            acc.EUR_CRM_City__c = postalCodeCityMap.get(acc.EUR_CRM_Postal_Code__c);
        }
    }

    /*============================
    * Middle Level Helpers
    * ============================*/

    private static Map<String, String> getCityNameByPostalCode(List<EUR_CRM_Postal_Code_City_Mapping__c> postalCodes) {
        Map<String, String> postalCodeCityMap = new Map<String, String>();
        for (EUR_CRM_Postal_Code_City_Mapping__c pc : postalCodes) {
            postalCodeCityMap.put(pc.EUR_CRM_Postal_Code__c, pc.EUR_CRM_City__c);
        }
        return postalCodeCityMap;

    }

    private static Boolean isPostalCodeChanged(Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        Boolean isFieldChanged = false;
        if (newMap != null && oldMap != null) {
            List<EUR_CRM_Account__c> oldAccounts = (List<EUR_CRM_Account__c>) oldMap.values();
            List<EUR_CRM_Account__c> newAccounts = (List<EUR_CRM_Account__c>) newMap.values();
            for (Integer i = 0; i < oldAccounts.size(); i++) {
                if (oldAccounts.get(i).EUR_CRM_Postal_Code__c != newAccounts.get(i).EUR_CRM_Postal_Code__c) {
                    isFieldChanged = true;
                }
            }
        }
        return isFieldChanged;
    }


    /*============================
    * SOQL Selectors
    * ============================*/

    private static List<EUR_CRM_Postal_Code_City_Mapping__c> selectPostalCodesWherePostalCodeAndRecordTypes(Set<String> postalCodes, Set<String> recordTypes) {
        return [
                SELECT Id
                        , EUR_CRM_City__c
                        , EUR_CRM_Postal_Code__c
                FROM EUR_CRM_Postal_Code_City_Mapping__c
                WHERE EUR_CRM_Postal_Code__c IN :postalCodes
                AND RecordType.DeveloperName IN :recordTypes
        ];
    }
}