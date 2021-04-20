public with sharing class EUR_CRM_DE_CreateSalesOrderCase extends EUR_CRM_TriggerAbstract
{
    public EUR_CRM_DE_CreateSalesOrderCase() {
        super('EUR_CRM_DE_CreateSalesOrderCase');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {

        Set<String> validRecordTypes = new Set<String>{'EUR_Direct','EUR_Free_Goods_to_Customer','EUR_Free_Goods_to_Stock'};

        List<EUR_CRM_Sales_Order__c> salesOrderList = (List<EUR_CRM_Sales_Order__c>) sObjList;
        List<Case> newCases = new List<Case>();

        // Get country codes of all Sales Orders Accounts
        Set<Id> accountIds = new Set<Id>();
        for(EUR_CRM_Sales_Order__c so: salesOrderList) {
            accountIds.add(so.EUR_CRM_Account__c);
        }
        Map<Id, EUR_CRM_Account__c> countryCodes = new Map<Id, EUR_CRM_Account__c>( [SELECT Id, EUR_CRM_Country_Code__c FROM EUR_CRM_Account__c where id in :accountIds]);

        // Create Case Closed for each Sales Order
        for(EUR_CRM_Sales_Order__c so: salesOrderList) {

            if (validRecordTypes.contains(Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosById().get(so.RecordTypeId).getDeveloperName()) &&
                so.EUR_CRM_Country_Code__c <> null && so.EUR_CRM_Country_Code__c == 'DE' && so.EUR_CRM_Order_Status__c == 'Send To ERP') {

                    if (tAction == EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT || (tAction == EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE && ((EUR_CRM_Sales_Order__c) oldMap.get(so.Id)).EUR_CRM_Order_Status__c <> 'Send To ERP'))
                    {
                        Case newCase = new Case();
                        newCase.Subject = so.Name;
                        newCase.EUR_NIM_SalesOrderEU__c = so.Id;
                        newCase.Status = 'Closed';
                        newCase.Type = 'New Sales Order';
                        newCase.EUR_CRM_Account__c = so.EUR_CRM_Account__c;
                        newCase.ContactId = so.EUR_CRM_Contact_Person__c;
                        newCase.RecordTypeId = EUR_COMMON_Utils.recordTypes.get('Case:EUR_NIM_' + countryCodes.get(so.EUR_CRM_Account__c).EUR_CRM_Country_Code__c + '_Case');
                        newCase.Subject = so.Name;

                        if (so.EUR_CRM_IsMobile__c == true) {
                            newCase.EUR_NIM_Reason__c = 'Convivio Order';
                        }

                        newCases.add(newCase);
                    }
            }
        }

        if (newCases.size() > 0) {
            try{
                Database.insert(newCases);
                System.debug(LoggingLevel.ERROR, 'New cases inserted');
            } catch(Exception e) {
                System.debug(LoggingLevel.ERROR, 'New cases insert operation rolled back');
            }
            
        }
    }
}