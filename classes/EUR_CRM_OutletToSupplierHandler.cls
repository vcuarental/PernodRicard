/**
* 
* IF Account is recordtype AO / KE 
* AND is linked to one ore many Outlet To Supplier Mapping records 
* IF Status of Customer Field = 'Active'
* mark the field "Supplier Is Active" to TRUE for each related Outlet to Supplier Mapping record
* IF Status of Customer field = "Inactive", 
* mark the field "Supplier Is Active" to FALSE for each related Outlet to Supplier Mapping record
*
*
*  2017.JAN.19 Exit if no record to process
*/
public with sharing class EUR_CRM_OutletToSupplierHandler extends EUR_CRM_TriggerAbstract {
    private static final String  isActive = 'Active';
    private static final String  isInActive = 'Inactive';
    public EUR_CRM_OutletToSupplierHandler (){
        super('EUR_CRM_OutletToSupplierHandler');
    }

    private static Set<String> validRecordTypes = EUR_CRM_RecordTypeHelper.OutletToSupplierHandler_validRecordTypes;
    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(validRecordTypes);

            return TRt;
        }private set;
    }
    private Map<Id,EUR_CRM_Account__c> parentAccountMap = new Map<Id,EUR_CRM_Account__c>();
    private Map<Id,Recordtype> accountRecordTypesMap;

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        System.Debug('EUR_CRM_OutletToSupplierHandler');
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        accountRecordTypesMap = new Map<Id,Recordtype>();

        for(Recordtype rt : accountRecordTypes){
            accountRecordTypesMap.put(rt.id,rt);
        }

        for(EUR_CRM_Account__c acct : (List<EUR_CRM_Account__c>) sObjList){
            String rtDevName = accountRecordTypesMap.get(acct.recordtypeid).developername;
            EUR_CRM_Account__c oldEuAccount =  Trigger.IsUpdate ? ((EUR_CRM_Account__c ) oldMap.get(acct.id)) : null;
            if(Trigger.isUpdate && isChanged(acct,oldEuAccount)){
                if(validRecordTypes.contains(rtDevName) && acct.EUR_CRM_Status__c!=null){
                    // get all the parent Account Id's
                    parentAccountMap.put(acct.Id,acct);
                }
            }
        }

        if(parentAccountMap.size() == 0)
        {
            return;
        }

        List<EUR_CRM_Outlet_to_Supplier_Mapping__c> outletToSupplierMappingToUpdate = new List<EUR_CRM_Outlet_to_Supplier_Mapping__c>();
        for(EUR_CRM_Outlet_to_Supplier_Mapping__c osm:[Select EUR_CRM_Supplier_Account__c,EUR_CRM_Outlet_Account__c from EUR_CRM_Outlet_to_Supplier_Mapping__c where EUR_CRM_Supplier_Account__c in:parentAccountMap.keySet()]){
            if(parentAccountMap.containsKey(osm.EUR_CRM_Supplier_Account__c) && parentAccountMap.get(osm.EUR_CRM_Supplier_Account__c).EUR_CRM_Status__c!=null){
                System.debug('it\'s ok');
                if(parentAccountMap.get(osm.EUR_CRM_Supplier_Account__c).EUR_CRM_Status__c==isActive){
                    osm.EUR_CRM_Supplier_is_Active__c = true;
                }
                if(parentAccountMap.get(osm.EUR_CRM_Supplier_Account__c).EUR_CRM_Status__c==isInActive){
                    osm.EUR_CRM_Supplier_is_Active__c = false;
                }
                outletToSupplierMappingToUpdate.add(osm);
            }
        }
        // Update the related EUR_CRM_Outlet_to_Supplier_Mapping__c records
        if(outletToSupplierMappingToUpdate.size()>0){

            try{
                update outletToSupplierMappingToUpdate;
            }
            catch(DMLException e){
                ApexPages.addMessages(e);
            }
        }
    }

    private Boolean isChanged(EUR_CRM_Account__c euAccount, EUR_CRM_Account__c oldEuAccount){
        return  euAccount.EUR_CRM_Status__c != oldEuAccount.EUR_CRM_Status__c;
    }
}