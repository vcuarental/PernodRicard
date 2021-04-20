global class EUR_CRM_DK_MassCreateFollowUpActions implements Database.Batchable<sObject>{

    private Id ON_TOOLKIT_FOLLOW_UP_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_ON_Trade_Adhoc_Activate_Toolkit_Follow_Up');
    private Id ON_INDIV_FOLLOW_UP_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_ON_Trade_Adhoc_Create_Indiv_Account_OP_Follow_Up');
    private Id OFF_TOOLKIT_FOLLOW_UP_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Activate_Toolkit_Follow_Up');
    private Id OFF_INDIV_FOLLOW_UP_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Create_Indiv_Account_OP_Follow_Up');

    private Id ON_TOOLKIT_SUB_ACTION_FOLLOW_UP_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Sub_Action__cEUR_DK_ON_Trade_Visit_Sub_Action_Adhoc_Activate_Toolkit_Follow_Up');
    private Id ON_INDIV_SUB_ACTION_FOLLOW_UP_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Sub_Action__cEUR_DK_ON_Trade_Visit_Sub_Action_Adhoc_Create_Indiv_Account_OP_Follow_Up_BQ_Vol');
    private Id OFF_TOOLKIT_SUB_ACTION_FOLLOW_UP_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Sub_Action__cEUR_DK_OFF_Trade_Visit_Sub_Action_Adhoc_Activate_Toolkit_Follow_Up');
    private Id OFF_INDIV_SUB_ACTION_FOLLOW_UP_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Sub_Action__cEUR_DK_OFF_Trade_Visit_Sub_Action_Adhoc_Create_Indiv_Account_OP_FollowUp_BQS_Vol');


    global final Set<String> validRecordTypes = new Set<String>{'EUR_DK_ON_Trade_Adhoc_Activate_Toolkit', 
                                                                'EUR_DK_ON_Trade_Adhoc_Create_Indiv_Account_OP',
                                                                'EUR_DK_OFF_Trade_Adhoc_Activate_Toolkit',
                                                                'EUR_DK_OFF_Trade_Adhoc_Create_Indiv_Account_OP'
                                                                };

    global final String query = 'SELECT Id, Name, RecordTypeId, RecordType.DeveloperName, EUR_CRM_Activation_End_Date__c, EUR_CRM_Active__c, ' +
                                'EUR_CRM_Account__c, EUR_CRM_Account__r.OwnerId, EUR_CRM_Product_Toolkit__c, EUR_CRM_Indiv_Account_OP_Name__c, ' +
                                '(SELECT Id, RecordTypeId, RecordType.DeveloperName, EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Visit_Action__c FROM Visit_Sub_Actions__r) ' +
                                'FROM EUR_CRM_Visit_Action__c ' +
                                'WHERE RecordType.DeveloperName IN : validRecordTypes ' + 
                                'AND EUR_CRM_Activation_End_Date__c < TODAY ' +
                                'AND EUR_CRM_Active__c = TRUE';

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute (Database.Batchablecontext BC, List<sObject> scope){

        System.debug(scope);

        Map<Id, EUR_CRM_Visit_Action__c> actionFollowUpsToInsert = new Map<Id, EUR_CRM_Visit_Action__c>(); // Key is Visit Action Id
        List<EUR_CRM_Visit_Sub_Action__c> subActionFollowUpsToInsert = new List<EUR_CRM_Visit_Sub_Action__c>();
        List<EUR_CRM_Visit_Action__c> visitActionsToUpdate = new List<EUR_CRM_Visit_Action__c>();

        Set<Id> toolkitIds = new Set<Id>();
        Map<Id, List<EUR_CRM_Product_Toolkit_Item__c>> toolkitMap = new Map<Id, List<EUR_CRM_Product_Toolkit_Item__c>>(); // Key is toolkit Id
        // Retrieve products from the product toolkit
        for(EUR_CRM_Visit_Action__c visit : (List<EUR_CRM_Visit_Action__c>)scope){
            if(visit.EUR_CRM_Product_Toolkit__c != null)
                toolkitIds.add(visit.EUR_CRM_Product_Toolkit__c);
        }

        System.debug(toolkitIds);

        for(EUR_CRM_Product_Toolkit_Item__c toolkitItem : [SELECT Id, RecordTypeId, RecordType.DeveloperName, EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Product_Toolkit__c 
                                                           FROM EUR_CRM_Product_Toolkit_Item__c
                                                           WHERE EUR_CRM_Product_Toolkit__c IN : toolkitIds])
        {
            if(toolkitMap.get(toolkitItem.EUR_CRM_Product_Toolkit__c) == null){
                toolkitMap.put(toolkitItem.EUR_CRM_Product_Toolkit__c, new List<EUR_CRM_Product_Toolkit_Item__c>());
            }
            toolkitMap.get(toolkitItem.EUR_CRM_Product_Toolkit__c).add(toolkitItem);
        }

        System.debug(toolkitMap);

        // Main Logic for creating action follow ups
        for(EUR_CRM_Visit_Action__c visit : (List<EUR_CRM_Visit_Action__c>)scope){

            System.debug(visit);
            System.debug(visit.RecordType.DeveloperName);

            EUR_CRM_Visit_Action__c tempFollowUp = new EUR_CRM_Visit_Action__c();  

            String rtDevName = visit.RecordType.DeveloperName;
            tempFollowUp.OwnerId = visit.EUR_CRM_Account__r.OwnerId;
            tempFollowUp.EUR_CRM_Visit_ID__c = null;
            tempFollowUp.EUR_CRM_Active__c = true;
            tempFollowUp.EUR_CRM_Account__c = visit.EUR_CRM_Account__c;
            
            if(rtDevName == 'EUR_DK_ON_Trade_Adhoc_Activate_Toolkit'){
                tempFollowUp.RecordTypeId = ON_TOOLKIT_FOLLOW_UP_RT_ID;
                tempFollowUp.EUR_CRM_Product_Toolkit__c = visit.EUR_CRM_Product_Toolkit__c;
            }
            else if(rtDevName == 'EUR_DK_OFF_Trade_Adhoc_Activate_Toolkit'){
                tempFollowUp.RecordTypeId = OFF_TOOLKIT_FOLLOW_UP_RT_ID;
                tempFollowUp.EUR_CRM_Product_Toolkit__c = visit.EUR_CRM_Product_Toolkit__c;
            }
            else if(rtDevName == 'EUR_DK_ON_Trade_Adhoc_Create_Indiv_Account_OP'){
                tempFollowUp.RecordTypeId = ON_INDIV_FOLLOW_UP_RT_ID;
                tempFollowUp.EUR_CRM_Indiv_Account_OP_Name__c = visit.EUR_CRM_Indiv_Account_OP_Name__c;
            }
            else if(rtDevName == 'EUR_DK_OFF_Trade_Adhoc_Create_Indiv_Account_OP'){
                tempFollowUp.RecordTypeId = OFF_INDIV_FOLLOW_UP_RT_ID;
                tempFollowUp.EUR_CRM_Indiv_Account_OP_Name__c = visit.EUR_CRM_Indiv_Account_OP_Name__c;
            }

            visit.EUR_CRM_Active__c = false;
            System.debug(tempFollowUp);
            actionFollowUpsToInsert.put(visit.Id, tempFollowUp);
            visitActionsToUpdate.add(visit);
        }

        System.debug(actionFollowUpsToInsert);
        if(actionFollowUpsToInsert.values().size() > 0){
            try{
                System.debug('inserting: ' + actionFollowUpsToInsert.values());
                insert actionFollowUpsToInsert.values();
            } catch (Exception e){
                System.debug(e);
            }
        }

        // Main Logic to create sub action follow ups
        for(EUR_CRM_Visit_Action__c visit : (List<EUR_CRM_Visit_Action__c>)scope){
            String rtDevName = visit.RecordType.DeveloperName;           
            if(rtDevName == 'EUR_DK_ON_Trade_Adhoc_Activate_Toolkit'){
                List<EUR_CRM_Product_Toolkit_Item__c> existingToolkitItems = toolkitMap.get(visit.EUR_CRM_Product_Toolkit__c);

                System.debug(existingToolkitItems);

                for(EUR_CRM_Product_Toolkit_Item__c item : existingToolkitItems){
                    EUR_CRM_Visit_Sub_Action__c subActionFollowUp = new EUR_CRM_Visit_Sub_Action__c();
                    subActionFollowUp.RecordTypeId = ON_TOOLKIT_SUB_ACTION_FOLLOW_UP_RT_ID;
                    subActionFollowUp.EUR_CRM_Visit_Action__c = actionFollowUpsToInsert.get(visit.Id).Id;
                    subActionFollowUp.EUR_CRM_Brand_Quality__c = item.EUR_CRM_Brand_Quality__c;
                    subActionFollowUpsToInsert.add(subActionFollowUp);
                }
            }

            else if(rtDevName == 'EUR_DK_OFF_Trade_Adhoc_Activate_Toolkit'){
                List<EUR_CRM_Product_Toolkit_Item__c> existingToolkitItems = toolkitMap.get(visit.EUR_CRM_Product_Toolkit__c);

                System.debug(existingToolkitItems);

                for(EUR_CRM_Product_Toolkit_Item__c item : existingToolkitItems){
                    EUR_CRM_Visit_Sub_Action__c subActionFollowUp = new EUR_CRM_Visit_Sub_Action__c();
                    subActionFollowUp.RecordTypeId = OFF_TOOLKIT_SUB_ACTION_FOLLOW_UP_RT_ID;
                    subActionFollowUp.EUR_CRM_Visit_Action__c = actionFollowUpsToInsert.get(visit.Id).Id;
                    subActionFollowUp.EUR_CRM_Brand_Quality_Size__c = item.EUR_CRM_Brand_Quality_Size__c;
                    subActionFollowUpsToInsert.add(subActionFollowUp);
                }
            }

            else if(rtDevName == 'EUR_DK_ON_Trade_Adhoc_Create_Indiv_Account_OP'){
                for(EUR_CRM_Visit_Sub_Action__c subAction : visit.Visit_Sub_Actions__r){
                    if(subAction.RecordType.DeveloperName == 'EUR_DK_ON_Trade_Visit_Sub_Action_Adhoc_Create_Indiv_Account_OP_Add_BQ'){
                        EUR_CRM_Visit_Sub_Action__c subActionFollowUp = new EUR_CRM_Visit_Sub_Action__c();
                        subActionFollowUp.RecordTypeId = ON_INDIV_SUB_ACTION_FOLLOW_UP_RT_ID;
                        subActionFollowUp.EUR_CRM_Brand_Quality__c = subAction.EUR_CRM_Brand_Quality__c;
                        subActionFollowUp.EUR_CRM_Visit_Action__c = actionFollowUpsToInsert.get(visit.Id).Id;
                        subActionFollowUpsToInsert.add(subActionFollowUp);
                    }
                }
            }

            else if(rtDevName == 'EUR_DK_OFF_Trade_Adhoc_Create_Indiv_Account_OP'){
                for(EUR_CRM_Visit_Sub_Action__c subAction : visit.Visit_Sub_Actions__r){
                    if(subAction.RecordType.DeveloperName == 'EUR_DK_OFF_Trade_Visit_Sub_Action_Adhoc_Create_Indiv_Account_OP_Add_BQS'){
                        EUR_CRM_Visit_Sub_Action__c subActionFollowUp = new EUR_CRM_Visit_Sub_Action__c();
                        subActionFollowUp.RecordTypeId = OFF_INDIV_SUB_ACTION_FOLLOW_UP_RT_ID;
                        subActionFollowUp.EUR_CRM_Brand_Quality_Size__c = subAction.EUR_CRM_Brand_Quality_Size__c;
                        subActionFollowUp.EUR_CRM_Visit_Action__c = actionFollowUpsToInsert.get(visit.Id).Id;
                        subActionFollowUpsToInsert.add(subActionFollowUp);
                    }
                }
            }
        }

        System.debug(subActionFollowUpsToInsert);

        if(subActionFollowUpsToInsert.size() > 0){
            try{
                insert subActionFollowUpsToInsert;
            } catch (Exception e){
                System.debug(e);
            }
        }

        System.debug(visitActionsToUpdate);

        if(visitActionsToUpdate.size() > 0){
            try{
                update visitActionsToUpdate;
            } catch (Exception e){
                System.debug(e);
            }
        }
    }

    global void finish(Database.BatchableContext BC){}
}