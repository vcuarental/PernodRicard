/*
For EUR_BE_Off_Trade account, the BP value will be auto assign base on Customer Taxonomey
This handler will run when before PRS insert or update, auto assign the BP value. 
*/

public with sharing class EUR_CRM_PRS_AssignAspectFromCustomerTax { //extends EUR_CRM_TriggerAbstract{

//        //  TODO : Move to RecordtypeHelper
//    public static Set<String> validRecordTypes = new Set<String>{'EUR_BE_Off_Trade'};
//
//    public static Set<String> TargetRecordSet {
//        get{
//            Set<String> TRt = new Set<String>();
//            TRt.addAll(validRecordTypes);
//
//            return TRt;
//        }private set;
//    }
//
//
//    public EUR_CRM_PRS_AssignAspectFromCustomerTax(){
//        super('EUR_CRM_PRS_AssignAspectFromCustomerTax');
//    }
//
//    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
//        System.Debug('>>>EUR_CRM_PRS_AssignAspectFromCustomerTax');
//        /*List<EUR_CRM_PRS_Segmentation__c> segmentationsForUpdateList = new List<EUR_CRM_PRS_Segmentation__c>();
//
//        List<RecordType> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
//        Map<Id, RecordType> accountRecordTypesMap = new Map<Id, RecordType>();
//        for(RecordType rt: accountRecordTypes) {
//            accountRecordTypesMap.put(rt.Id, rt);
//        }*/
//
//        //Set<Id> accountIds = new Set<Id>();
//        //List<EUR_CRM_Account__c> accountList = new List<EUR_CRM_Account__c>();
//        //Map<Id, Id> custTaxToAccIdsMap = new Map<Id, Id>(); // Key is customer taxonomy Id
//        //Map<Id,Set<Id>> custTaxToAccIdsMapSet = new Map<Id,Set<Id>>();
//
//
//        Set<Id> accountIdList = New Set<Id>();
//        List<EUR_CRM_Account__c> prsAccountList = New List<EUR_CRM_Account__c>();
//        Map<Id,Id> accountToBPMap = new Map<Id,Id>();
//
//        //Build Account Id Set
//        for(EUR_CRM_PRS_Segmentation__c PRS : (List<EUR_CRM_PRS_Segmentation__c>) sObjList){
//            accountIdList.add(PRS.EUR_CRM_Account__c);
//        }
//
//        //Retrieve BP From CTax, Build Account-BP Map
//        for(EUR_CRM_Account__c acc : [SELECT id,EUR_JB_Customer_Taxonomy__c,EUR_JB_Customer_Taxonomy__r.EUR_CRM_Business_Potential__c FROM EUR_CRM_Account__c Where Id in : accountIdList]){
//            accountToBPMap.put(acc.Id, acc.EUR_JB_Customer_Taxonomy__r.EUR_CRM_Business_Potential__c);
//        }
//        System.Debug('EUR_CRM_PRS_AssignAspectFromCustomerTax:accountToBPMap:' + accountToBPMap);
//
//        //Map BP to PRS by Account
//        for(EUR_CRM_PRS_Segmentation__c PRS : (List<EUR_CRM_PRS_Segmentation__c>) sObjList){
//
//            PRS.EUR_CRM_Business_Potential__c = accountToBPMap.get(PRS.EUR_CRM_Account__c);
//            System.Debug('EUR_CRM_PRS_AssignAspectFromCustomerTax:accountToBPMap:get:' + accountToBPMap.get(PRS.EUR_CRM_Account__c));
//        }
//
//        /*
//        for(EUR_CRM_Account__c acc : prsAccountList){
//            String devName = accountRecordTypesMap.get(acc.RecordTypeId).DeveloperName;
//            if(validRecordTypes.contains(devName)){
//                if(acc.EUR_JB_Customer_Taxonomy__c != null){
//                    custTaxToAccIdsMap.put(acc.EUR_JB_Customer_Taxonomy__c, acc.Id);
//
//                    If(custTaxToAccIdsMapSet.containsKey(acc.EUR_JB_Customer_Taxonomy__c)){
//                        Set<Id> accSet = custTaxToAccIdsMapSet.get(acc.EUR_JB_Customer_Taxonomy__c);
//                        accSet.add(acc.Id);
//                        custTaxToAccIdsMapSet.put(acc.EUR_JB_Customer_Taxonomy__c,accSet);
//                    }else{
//                        Set<Id> accSet = new Set<Id>();
//                        accSet.add(acc.Id);
//                        custTaxToAccIdsMapSet.put(acc.EUR_JB_Customer_Taxonomy__c,accSet);
//                    }
//                }
//                accountList.add(acc);
//                accountIds.add(acc.Id);
//            }
//        }
//        System.Debug('custTaxToAccIdsMapSet:' + custTaxToAccIdsMapSet);
//
//        if(accountList.size() > 0){
//            Map<Id, EUR_CRM_Customer_Taxonomy__c> accToCustTaxMap = new Map<Id, EUR_CRM_Customer_Taxonomy__c>(); // Key is Account Id
//            for(EUR_CRM_Customer_Taxonomy__c taxonomy : [SELECT Id, EUR_CRM_Business_Potential__c FROM EUR_CRM_Customer_Taxonomy__c WHERE Id IN : custTaxToAccIdsMapSet.KeySet()])
//            {
//                Set<Id> accSet = custTaxToAccIdsMapSet.get(taxonomy.Id);
//                for(Id accid : accSet){
//                    accToCustTaxMap.put(accid, taxonomy);
//                }
//                //accToCustTaxMap.put(custTaxToAccIdsMap.get(taxonomy.Id), taxonomy);
//            }
//            System.Debug('accToCustTaxMap:' + accToCustTaxMap);
//
//
//            Map<Id, EUR_CRM_PRS_Segmentation__c> accToSegMap = new Map<Id, EUR_CRM_PRS_Segmentation__c>(); // Key is Account Id
//            for(EUR_CRM_PRS_Segmentation__c segmentation : [SELECT Id, EUR_CRM_Business_Potential__c, EUR_CRM_Account__c FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c IN : accountIds])
//            {
//                accToSegMap.put(segmentation.EUR_CRM_Account__c, segmentation);
//            }
//            System.Debug('accToSegMap:' + accToSegMap);
//
//            for(EUR_CRM_Account__c acc : accountList){
//                EUR_CRM_PRS_Segmentation__c seg = accToSegMap.get(acc.Id);
//                EUR_CRM_Customer_Taxonomy__c tax = accToCustTaxMap.get(acc.Id);
//                System.Debug('BP from CTax:' + tax.EUR_CRM_Business_Potential__c);
//                if(seg != null){
//                   seg.EUR_CRM_Business_Potential__c = tax.EUR_CRM_Business_Potential__c;
//                }
//                acc.EUR_CRM_Business_Potential__c = tax.EUR_CRM_Business_Potential__c;
//                segmentationsForUpdateList.add(seg);
//            }
//        }
//
//        if(segmentationsForUpdateList.size() > 0){
//            try{
//                update segmentationsForUpdateList;
//            }
//            catch (Exception e){
//                System.debug(e);
//            }
//        }*/
//    }
}