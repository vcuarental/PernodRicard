/**

Functions: 

for Promotion type O/P , if all required actions are successfully completed, mark the O/P account mapping record as inactive. 
(Bypass flag for Mobile app, so it doesn't need to create Visit Actions against that Promotion for that Account) "
*/
public without sharing class EUR_CRM_DE_VisitActionHandler  extends EUR_CRM_TriggerAbstract {
    private final  Set<String> validRecordTypeSet = new Set<String>{
        'EUR_DE_OFF_Leaflet_Campaign_Agree_To_Buy',
        'EUR_DE_OFF_Leaflet_Campaign_Sell_In_Qty',
        'EUR_DE_OFF_Sales_Drive_Sell_In_Qty',
        'EUR_DE_OFF_Tasting_Sell_In_Qty',
        'EUR_DE_OFF_Tasting_Discussion',
        'EUR_DE_OFF_Dist_Drive_Listing_Check',
        'EUR_DE_ON_TMKT_Promo_Confirm_Participation',
        'EUR_DE_ON_TMKT_Promo_Enter_Sell_In_Qty',
        'EUR_DE_ON_TMKT_Promo_Presentation',
        'EUR_DE_OFF_2nd_PL_Do_TMKT_Doc',
        'EUR_DE_OFF_2nd_PL_Present_Theme',
        'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Any',
        'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Carton',
        'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Gondelkopf',
        'EUR_DE_OFF_2nd_Placement_Sell_In_Qty_Promo_Display',
        'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Razz_Fazz',
        'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Standard' //,
        // 'EUR_DE_OFF_Ad_Hoc_Sell_In_Qty',
        //  'DE_OFF_Ad_hoc_Agree_To_Buy'
    };
    private final  Set<String> onTradeVisitActionRecordType = new Set<String>{
        'EUR_DE_ON_TMKT_Promo_Confirm_Participation',
        'EUR_DE_ON_TMKT_Promo_Enter_Sell_In_Qty',
        'EUR_DE_ON_TMKT_Promo_Presentation'
    };

    public EUR_CRM_DE_VisitActionHandler(){
        super('EUR_CRM_DE_VisitActionHandler');
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<Recordtype> visitActionRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Visit_Action__c');
        Map<Id,Recordtype> visitActionRecordTypesMap = new Map<Id,Recordtype>();

        for(Recordtype rt : visitActionRecordTypes ){
            visitActionRecordTypesMap.put(rt.id,rt);
        }
        Set<Id> euAccounts = new Set<Id>();
        Set<Id> objectPromos= new Set<Id>();
        Map<Id,Set<Id>> euAccountsBQS = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> objectPromosBQS = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> euAccountsBQ = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> objectPromosBQ = new Map<Id,Set<Id>>();
        Boolean thereIsOntrade = false;
        Set<Id> validVisitActions = new Set<Id>();
        List<EUR_CRM_Visit_Action__c> visitActionList = new List<EUR_CRM_Visit_Action__c>();

        for(EUR_CRM_Visit_Action__c visitAction: (List<EUR_CRM_Visit_Action__c>) sObjList){
            String rt = visitActionRecordTypesMap.get(visitAction.recordtypeid).developername;
            if(validRecordTypeSet.contains(rt)
                && visitAction.EUR_CRM_Is_Successful__c
                ){
                // None of the fields are mandatory
                // Can cause null pointer exception if not checked
                if(visitAction.EUR_CRM_Account__c != null)
                    euAccounts.add(visitAction.EUR_CRM_Account__c);
                if(visitAction.EUR_CRM_ObjPromo__c != null)
                    objectPromos.add(visitAction.EUR_CRM_ObjPromo__c);

                visitActionList.add(visitAction);
                if(!thereIsOntrade &&onTradeVisitActionRecordType.contains(rt) ){
                    thereIsOntrade = true;
                }
            }
        }

        Map<String,EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMap = new Map<String, EUR_CRM_ObjPromo_Account_Mapping__c>();
        Map<Id,Id> OPActionMap = new Map<Id,Id>();
        if(euAccounts.size() > 0 && objectPromos.size() > 0){
            OPActionMap = retrieveOPActionMapping(objectPromos,visitActionList);
            system.debug('@@ ' + OPActionMap);
            if(thereIsOntrade){
                system.debug('@@ there is ontrade');
                Map<Id, Set<Id>> varVarDetailMap = new Map<Id, Set<Id>>();

                for(EUR_CRM_ObjPromo_OnTrade_Var_Detail__c detail : [select id, EUR_CRM_Quality__r.name, EUR_CRM_Quality__c,EUR_CRM_ObjPromo_OnTrade_Variation__c   from EUR_CRM_ObjPromo_OnTrade_Var_Detail__c
                where EUR_CRM_ObjPromo_OnTrade_Variation__c in (select EUR_CRM_ObjPromo_OnTrade_Variation__c from EUR_CRM_ObjPromo__c where id in:objectPromos) ]){
                    if(varVarDetailMap.get(detail.EUR_CRM_ObjPromo_OnTrade_Variation__c) == null)
                        varVarDetailMap.put(detail.EUR_CRM_ObjPromo_OnTrade_Variation__c, new Set<Id>());
                    varVarDetailMap.get(detail.EUR_CRM_ObjPromo_OnTrade_Variation__c).add(detail.EUR_CRM_Quality__c);
                }
                for(EUR_CRM_ObjPromo__c objPromo : [select id, EUR_CRM_ObjPromo_OnTrade_Variation__c from EUR_CRM_ObjPromo__c where id in:objectPromos] ){
                    if(objectPromosBQS.get(objPromo.id) == null)
                        objectPromosBQS.put(objPromo.id, new Set<Id>());
                    Set<id> bq = varVarDetailMap.get(objPromo.EUR_CRM_ObjPromo_OnTrade_Variation__c);
                    if(bq != null)
                        objectPromosBQS.get(objPromo.id).addAll(bq);
                }
                system.debug('@@ objectPromosBQS' + objectPromosBQS);

            }
            for(EUR_CRM_ObjPromo_Account_Mapping__c opAccount : [select id, EUR_CRM_Account__c, EUR_CRM_ObjPromo__c,
                EUR_CRM_Is_Active__c from EUR_CRM_ObjPromo_Account_Mapping__c
            where EUR_CRM_Account__c in:euAccounts and EUR_CRM_ObjPromo__c in:objectPromos]){
                String key = '' + opAccount.EUR_CRM_Account__c + opAccount.EUR_CRM_ObjPromo__c;
                opAccountMap.put(key, opAccount);
            }

            for(EUR_CRM_ObjPromo_Target__c  target : [select id, EUR_CRM_BQS__c, EUR_CRM_ObjPromo__c  from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c in : objectPromos]){
                if(objectPromosBQS.get(target.EUR_CRM_ObjPromo__c) == null)
                    objectPromosBQS.put(target.EUR_CRM_ObjPromo__c, new Set<Id>());
                objectPromosBQS.get(target.EUR_CRM_ObjPromo__c).add(target.EUR_CRM_BQS__c);
            }

            for(EUR_CRM_Visit_Action__c visitAction: [select id, EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality_Size__c,EUR_CRM_Account__c from EUR_CRM_Visit_Action__c where EUR_CRM_ObjPromo__c in : objectPromos
                and EUR_CRM_Is_Successful__c = true
                and EUR_CRM_Account__c in: euAccounts
                and EUR_CRM_OP_Action__c in: OPActionMap.values()]){
                if(euAccountsBQS.get(visitAction.EUR_CRM_Account__c ) == null)
                    euAccountsBQS.put(visitAction.EUR_CRM_Account__c , new Set<Id>());
                if(visitAction.EUR_CRM_Brand_Quality_Size__c != null)
                    euAccountsBQS.get(visitAction.EUR_CRM_Account__c ).add(visitAction.EUR_CRM_Brand_Quality_Size__c);
                if(visitAction.EUR_CRM_Brand_Quality__c != null)
                    euAccountsBQS.get(visitAction.EUR_CRM_Account__c ).add(visitAction.EUR_CRM_Brand_Quality__c);
            }

            //addded NOV.05.2014
            //validVisitActions = retrieveValidVisitActions(objectPromos,visitActionList);
        }

        List<EUR_CRM_ObjPromo_Account_Mapping__c> toBeUpdatedOPAccountMapping = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        Set<Id> opAccountSet = new Set<Id>();
        Set<Id> opTemp = new Set<Id>();
        for(EUR_CRM_Visit_Action__c visitAction: visitActionList){
            String key = '' + visitAction.EUR_CRM_Account__c + visitAction.EUR_CRM_ObjPromo__c;
            EUR_CRM_ObjPromo_Account_Mapping__c opAccount = opAccountMap.get(key);
            if (opAccount == null) { continue; }
            opAccountSet.add(opAccount.id);
            Set<Id> bqsSet =euAccountsBQS.get(visitAction.EUR_CRM_Account__c);
            Set<Id> promoBQS = objectPromosBQS.get(visitAction.EUR_CRM_ObjPromo__c);
            System.debug('!!! ' +bqsSet + '!! '  + promoBQS + 'OP Account' + opAccount);
            if(opAccount != null && bqsSet !=null && promoBQS != null &&
                checkIfComplete(bqsSet , promoBQS )
                &&  !opTemp.contains(opAccount.id)
                // && !opAccountSet.contains(opAccount.id)
                // && validVisitActions.contains(visitAction.id) //ADDED NOV.05.2014
                ){
                opAccount.EUR_CRM_Is_Active__c = false;
                toBeUpdatedOPAccountMapping.add(opAccount);
                opTemp.add(opAccount.id);
            }
        }

        if(toBeUpdatedOPAccountMapping.size() > 0)
            update toBeUpdatedOPAccountMapping;
    }

    private Boolean checkIfComplete(Set<Id> bqsSet, Set<Id> promoBQS){
        Boolean complete = true;

        for(Id bqs: promoBQS){
            if(!bqsSet.contains(bqs)){
                complete = false;
                break;
            }
        }
        return complete;
    }

    //ADDED NOV.05.2014
    private Map<Id,Id> retrieveOPActionMapping(Set<Id> objectPromos, List<EUR_CRM_Visit_Action__c> visitActionList){

        Set<Id> actionListTemplates = new Set<Id>();

        Set<Id> validVisitActions = new Set<Id>();

        Map<Id,Id> oPActionMap = new Map<Id,Id>();

        Map<Id, EUR_CRM_ObjPromo__c> opMap = new Map<Id,EUR_CRM_ObjPromo__c>( [select id,EUR_CRM_OP_Action_List_Template__c from EUR_CRM_ObjPromo__c where id in: objectPromos]);

        for(EUR_CRM_ObjPromo__c objPromo : opMap.values()){
            actionListTemplates.add(objPromo.EUR_CRM_OP_Action_List_Template__c);
        }
        Map<Id,EUR_CRM_ObjPromo_Action__c> actionTemplateMap = new Map<Id,EUR_CRM_ObjPromo_Action__c>();

        for(EUR_CRM_ObjPromo_Action__c action : [select id, EUR_CRM_OP_Action_List_Template__c, EUR_CRM_OP_Sequence_Order__c
        from EUR_CRM_ObjPromo_Action__c where EUR_CRM_OP_Action_List_Template__c in: actionListTemplates
            and EUR_CRM_Can_Reoccur__c = false]){
            EUR_CRM_ObjPromo_Action__c tempAction = actionTemplateMap.get(action.EUR_CRM_OP_Action_List_Template__c);
            if(tempAction == null)
                actionTemplateMap.put(action.EUR_CRM_OP_Action_List_Template__c, action);
            else if(action.EUR_CRM_OP_Sequence_Order__c > tempAction.EUR_CRM_OP_Sequence_Order__c){
                actionTemplateMap.put(action.EUR_CRM_OP_Action_List_Template__c, action);
            }
        }
        for(Id key : opMap.keySet()){
            EUR_CRM_ObjPromo__c objPromo = opMap.get(key);
            Id actionId = actionTemplateMap.get(objPromo.EUR_CRM_OP_Action_List_Template__c) != null ? actionTemplateMap.get(objPromo.EUR_CRM_OP_Action_List_Template__c).id : null;
            oPActionMap.put(objPromo.id, actionId);
        }
        return oPActionMap;
    }

}