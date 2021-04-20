/**
Listing Template- automatically assign a listing template. using customer taxonomy.
*/
public with sharing class EUR_CRM_DE_ListingTemplateHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_DE_ListingTemplateHandler(){
        super('EUR_CRM_DE_ListingTemplateHandler');
    }

    private static Set<String> onTradeEUAccountRecordTypeSet = new Set<String>{
        //'EUR_DE_ON_Consumers',
        //'EUR_DE_ON_Enquiry_Acquisition',
        'EUR_DE_ON_Gastronomy'
        //'EUR_DE_ON_Service_agency',
        //'EUR_DE_ON_Wholesaler'
    };
    private static Set<String> allEUAccountRecordTypeSet = new Set<String>{
        'EUR_DE_ON_Consumers',
        'EUR_DE_ON_Enquiry_Acquisition',
        'EUR_DE_ON_Gastronomy',
        'EUR_DE_ON_Service_agency',
        'EUR_DE_ON_Wholesaler',
        'EUR_DE_OFF_STD',

        'EUR_DE_Off_Trade_Retail',
        'EUR_DE_Off_Trade_New_Business'
    };
    private static Set<String> offTradeEUAccountRecordTypeSet = new Set<String>{
        'EUR_DE_OFF_STD',
//        'EUR_DE_ON_Wholesaler',

        'EUR_DE_Off_Trade_Retail',
        'EUR_DE_Off_Trade_New_Business'
    };

    private static Set<String> offTradeTemplaeRecordTypeSet = new Set<String>{
        'EUR_DE_OFF_Trade_Template',
        'EUR_DE_WS_Template'
    };

    private static Set<String> validStatusOfCustomer = new Set<String>{
        'Active', 'Agency Managed', 'Potential customer', 'New customer'
    };

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            //TRt.addAll(onTradeEUAccountRecordTypeSet);
            TRt.addAll(allEUAccountRecordTypeSet);
            //TRt.addAll(offTradeEUAccountRecordTypeSet);
            //TRt.addAll(offTradeTemplaeRecordTypeSet);

            return TRt;
        }private set;
    }



    private Set<String> taxonomyBannerPicklists = new Set<String>();
    private Set<String> taxonomyVertriebsregionPicklists = new Set<String>();
    private static String ACTIVE = 'Active';
    private static String INACTIVE = 'Inactive';

    /**
    
    */
    private Map<Id,Recordtype> accountRecordTypesMap;
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        System.Debug('EUR_CRM_DE_ListingTemplateHandler');
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        accountRecordTypesMap = new Map<Id,Recordtype>();

        for(Recordtype rt : accountRecordTypes){
           accountRecordTypesMap.put(rt.id,rt);
        }
       // Map<Id, Recordtype> recordtypeMap = EUR_CRM_AccountUtils.recordtypeMap;
        Set<Id> custTaxonomy = new Set<Id>();
        List<EUR_CRM_Account__c> validAccounts = new List<EUR_CRM_Account__c>();

        List<EUR_CRM_Account__c> onTradeAccounts = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> offTradeAccounts = new List<EUR_CRM_Account__c>();

        Set<String> groupOutletTypeSet = new Set<String>();
        Set<String> outletTypeSet = new Set<String>();
        Set<String> imageLevelSet = new Set<String>();
        Set<String> volumePotentialSet = new Set<String>();

        for(EUR_CRM_Account__c euAccount : (List<EUR_CRM_Account__c>) sObjList){
            system.debug('### Flag 2');
            EUR_CRM_Account__c oldEuAccount =  Trigger.IsUpdate ? ((EUR_CRM_Account__c ) oldMap.get(euAccount.id)) : null;
            if(offTradeEUAccountRecordTypeSet.contains(accountRecordTypesMap.get(euAccount.RecordtypeId).DeveloperName)
                && (Trigger.IsInsert || (Trigger.IsUpdate && isChanged(euAccount,oldEuAccount,false)))
//                && validStatusOfCustomer.contains(euAccount.EUR_CRM_Status_of_Customer__c)){
                ){
                    custTaxonomy.add(euAccount.EUR_JB_Customer_Taxonomy__c);
                    validAccounts.add(euAccount);
                    offTradeAccounts.add(euAccount);
           system.debug('### Flag 3');

            }
            if(onTradeEUAccountRecordTypeSet.contains(accountRecordTypesMap.get(euAccount.RecordtypeId).DeveloperName)
                && (Trigger.IsInsert || (Trigger.IsUpdate && isChanged(euAccount,oldEuAccount,true)))
                && validStatusOfCustomer.contains(euAccount.EUR_CRM_Status_of_Customer__c)){
                validAccounts.add(euAccount);
                onTradeAccounts.add(euAccount);
                groupOutletTypeSet.add(euAccount.EUR_CRM_Group_Outlet_Type__c);
                outletTypeSet.add(euAccount.EUR_CRM_Outlet_Type__c);
                imageLevelSet.add(euAccount.EUR_CRM_Image_Level__c);
                volumePotentialSet.add(euAccount.EUR_CRM_Volume_Potential__c);
            system.debug('### Flag 4');
            }
            if(allEUAccountRecordTypeSet.contains(accountRecordTypesMap.get(euAccount.RecordtypeId).DeveloperName)
              && Trigger.IsUpdate && euAccount.EUR_CRM_Status_of_Customer__c == INACTIVE){
                euAccount.EUR_CRM_Listing_Template__c = null;
                system.debug('### Flag 5');
            }
        }

        if(offTradeAccounts.size() > 0){
            system.debug('### Flag 6');
//            initTaxonomyPicklists();
//            taxonomyBannerHandler(offTradeAccounts,custTaxonomy,tAction,oldMap);
            assignTemplateOffTradeAccounts(offTradeAccounts,custTaxonomy);
        }
        if(onTradeAccounts.size() > 0){
            assignTemplateOnTradeAccounts(onTradeAccounts,groupOutletTypeSet, outletTypeSet, imageLevelSet, volumePotentialSet);
        }

    }

//    private void initTaxonomyPicklists(){
//        Schema.DescribeFieldResult fieldResult = EUR_CRM_Account__c.EUR_CRM_Taxonomy_Banner__c.getDescribe();
//        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
//
//        for (Schema.PicklistEntry a : ple ) {
//              taxonomyBannerPicklists.add(a.getValue());
//        }
//
//        Schema.DescribeFieldResult fieldResult2 = EUR_CRM_Account__c.EUR_CRM_Taxonomy_Vertriebsregion__c.getDescribe();
//        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
//        for (Schema.PicklistEntry a : ple2 ) {
//              taxonomyVertriebsregionPicklists.add(a.getValue());
//        }
//    }
//    private void taxonomyBannerHandler(List<EUR_CRM_Account__c> euAccounts, Set<Id> custTaxonomy, TriggerAction tAction, Map<ID, sObject> oldMap){
//        Map<Id,EUR_CRM_Customer_Taxonomy__c> custTaxMap = new Map<Id,EUR_CRM_Customer_Taxonomy__c>();
//        custTaxMap = new Map<Id,EUR_CRM_Customer_Taxonomy__c>([select id,EUR_CRM_Level_3__c,EUR_CRM_Level_5__c from EUR_CRM_Customer_Taxonomy__c where id in:custTaxonomy  ]);
//
//        for(EUR_CRM_Account__c euAccount : euAccounts){
//            EUR_CRM_Account__c oldAccount = tAction == TriggerAction.BEFORE_UPDATE ? ((EUR_CRM_Account__c) oldMap.get(euAccount.id)) : null;
//
//            if(custTaxMap.get(euAccount.EUR_JB_Customer_Taxonomy__c) != null &&
//               taxonomyBannerPicklists.contains( custTaxMap.get(euAccount.EUR_JB_Customer_Taxonomy__c).EUR_CRM_Level_3__c) ){
//
//                euAccount.EUR_CRM_Taxonomy_Banner__c =  custTaxMap.get(euAccount.EUR_JB_Customer_Taxonomy__c).EUR_CRM_Level_3__c;
//
//                if(custTaxMap.get(euAccount.EUR_JB_Customer_Taxonomy__c) != null &&
//                   taxonomyVertriebsregionPicklists.contains( custTaxMap.get(euAccount.EUR_JB_Customer_Taxonomy__c).EUR_CRM_Level_5__c) ){
//
//                euAccount.EUR_CRM_Taxonomy_Vertriebsregion__c =  custTaxMap.get(euAccount.EUR_JB_Customer_Taxonomy__c).EUR_CRM_Level_5__c;
//
//                }else{
//                euAccount.EUR_CRM_Taxonomy_Vertriebsregion__c = euAccount.EUR_CRM_Taxonomy_Banner__c;
//                }
//            }else{
//               euAccount.EUR_CRM_Taxonomy_Banner__c = 'No Match';
//                euAccount.EUR_CRM_Taxonomy_Vertriebsregion__c = 'No Match';
//                euAccount.EUR_CRM_Module__c = null; // Added NOV.03.2014 : bug if customer taxonomy didn't change.
//            }
//            if(tAction == TriggerAction.BEFORE_UPDATE && euAccount.EUR_JB_Customer_Taxonomy__c !=  oldAccount.EUR_JB_Customer_Taxonomy__c){
//                euAccount.EUR_CRM_Module__c = null;
//            }
//        }
//
//    }

    private void assignTemplateOffTradeAccounts(List<EUR_CRM_Account__c> euAccounts, Set<Id> custTaxonomy){
        system.debug('## : ' + euAccounts + '  ' + custTaxonomy);
        Map<ID,Map<String,Id>> templateMap = new Map<ID,Map<String,Id>>();
        String GENERIC = 'GenericXXX';
        if(custTaxonomy.size()>0){
            for(EUR_CRM_JB_Template__c template :[select id,EUR_CRM_Module__c,EUR_CRM_Default__c,EUR_CRM_Customer_Taxonomy__c from EUR_CRM_JB_Template__c where EUR_CRM_Customer_Taxonomy__c in:custTaxonomy and recordtype.developername in:offTradeTemplaeRecordTypeSet]){
                if(template.EUR_CRM_Customer_Taxonomy__c != null){
                    Map<String,Id> temp = templateMap.get(template.EUR_CRM_Customer_Taxonomy__c);
                    if(temp == null){
                        temp = new Map<String,Id>();
                    }
                    temp.put(template.EUR_CRM_Module__c, template.id);

                    if(template.EUR_CRM_Default__c){
                         temp.put(GENERIC, template.id);
                    }
                    templateMap.put(template.EUR_CRM_Customer_Taxonomy__c,temp);
                }
            }
        }

        for(EUR_CRM_Account__c euAccount : euAccounts){
             system.debug('## Flag 2');
            if(templateMap.get(euAccount.EUR_JB_Customer_Taxonomy__c ) != null ){
             system.debug('## Flag 3');
                    if(templateMap.get(euAccount.EUR_JB_Customer_Taxonomy__c ).get(euAccount.EUR_CRM_Module__c) != null){
             system.debug('## Flag 4');
                        euAccount.EUR_CRM_Listing_Template__c = templateMap.get(euAccount.EUR_JB_Customer_Taxonomy__c ).get(euAccount.EUR_CRM_Module__c);
                    }else{
             system.debug('## Flag 5');
                        euAccount.EUR_CRM_Listing_Template__c = templateMap.get(euAccount.EUR_JB_Customer_Taxonomy__c ).get(GENERIC);
                    }
                }else{
             system.debug('## Flag 6');
                        euAccount.EUR_CRM_Listing_Template__c = null;
                }
        System.debug('\n euAccount.EUR_CRM_Listing_Template__c => ' + euAccount.EUR_CRM_Listing_Template__c + '\n');
        }

    }
    public static void assignTemplateOnTradeAccounts(List<EUR_CRM_Account__c> acctSegmentationUpdate,
                                        Set<String> groupOutletTypeSet, Set<String> outletTypeSet,
                                        Set<String> imageLevelSet, Set<String> volumePotentialSet){
        //Key:Concat of segmentation details

        System.Debug('##assignTemplateOnTradeAccounts');

        Map<String, EUR_CRM_JB_Template_Criteria__c> templateCriteriaMap = new Map<String, EUR_CRM_JB_Template_Criteria__c>();

        for(EUR_CRM_JB_Template_Criteria__c tCriteria: [SELECT Id, EUR_JB_Active__c, EUR_JB_Template__r.EUR_CRM_Record_Type_Name__c,
                                                            EUR_JB_External_ID__c, EUR_JB_Group_Outlet_Type__c, EUR_JB_Image_Level__c,
                                                            EUR_JB_Outlet_Type__c, EUR_JB_Template__c, EUR_JB_Volume_Potential__c
                                                            FROM EUR_CRM_JB_Template_Criteria__c
                                                            WHERE EUR_JB_Group_Outlet_Type__c IN: groupOutletTypeSet
                                                            AND EUR_JB_Outlet_Type__c IN:outletTypeSet
                                                            AND EUR_JB_Image_Level__c IN:imageLevelSet
                                                            AND EUR_JB_Volume_Potential__c IN:volumePotentialSet
                                                            AND EUR_JB_Active__c=true
                                                            AND EUR_JB_Template__r.recordtype.developername = 'EUR_DE_ON_TRADE_Template'

                                                            ORDER by lastmodifieddate asc
                                                             LIMIT 49999]){

            String key = createKey(tCriteria.EUR_JB_Group_Outlet_Type__c,tCriteria.EUR_JB_Outlet_Type__c,
                                    tCriteria.EUR_JB_Image_Level__c,tCriteria.EUR_JB_Volume_Potential__c,
                                    tCriteria.EUR_JB_Template__r.EUR_CRM_Record_Type_Name__c);
            templateCriteriaMap.put(key, tCriteria);
        }

        System.Debug('templateCriteriaMap:'+templateCriteriaMap);
        //Iterate Account List to set value
        for(EUR_CRM_Account__c acct: acctSegmentationUpdate){
                String acctKey = createKey(acct.EUR_CRM_Group_Outlet_Type__c,acct.EUR_CRM_Outlet_Type__c,
                                        acct.EUR_CRM_Image_Level__c,acct.EUR_CRM_Volume_Potential__c,
                                        'EUR_DE_ON_TRADE_Template');
                if (templateCriteriaMap.containsKey(acctKey)){
                    acct.EUR_CRM_Listing_Template__c = templateCriteriaMap.get(acctKey).EUR_JB_Template__c;
                }
        }
    }
    public static String createKey(String g, String o, String i, String v, String recordTypeName){
        return g+'-'+o+'-'+i+'-'+v + recordTypeName;
    }
    private Boolean isChanged(EUR_CRM_Account__c euAccount, EUR_CRM_Account__c oldEuAccount, Boolean isOntrade){
        if(isOntrade){
            return    (oldEuAccount.EUR_CRM_Group_Outlet_Type__c != euAccount.EUR_CRM_Territory__c) ||
                    (oldEuAccount.EUR_CRM_Image_Level__c != euAccount.EUR_CRM_Image_Level_Name__c)  ||
                    (oldEuAccount.EUR_CRM_Outlet_Type__c  != euAccount.EUR_CRM_Group_Outlet_Type_Name__c) ||
                    (oldEuAccount.EUR_CRM_Volume_Potential__c != euAccount.EUR_CRM_Volume_Potential__c) ||
                    (oldEuAccount.EUR_CRM_Status_of_Customer__c  != euAccount.EUR_CRM_Status_of_Customer__c) ||
                    (oldEuAccount.EUR_CRM_Listing_Template__c  != euAccount.EUR_CRM_Listing_Template__c);
        }else{
            return (oldEuAccount.EUR_JB_Customer_Taxonomy__c  != euAccount.EUR_JB_Customer_Taxonomy__c) ||
            (oldEuAccount.EUR_CRM_Status_of_Customer__c  != euAccount.EUR_CRM_Status_of_Customer__c) ||
            (oldEuAccount.EUR_CRM_Module__c  != euAccount.EUR_CRM_Module__c) ;
        }
    }
}