/**
 
    - 
*/
public class EUR_CRM_FI_ContractAccountHandler extends EUR_CRM_TriggerAbstract {
    
    private static final Set<String> allRecordTypes = new Set<String>{
      'EUR_FI_Direct_Off_Trade',
      'EUR_FI_Direct_On_Trade',
      'EUR_FI_Indirect_Off_Trade',
      'EUR_FI_Indirect_On_Trade' 
    };
    private final Set<String> offTradeFinlandRecordTypes = new Set<String>{
      'EUR_FI_Direct_Off_Trade',
      'EUR_FI_Indirect_Off_Trade'
    };
    
    private final Set<String> onTradeFinlandRecordTypes = new Set<String>{ 
      'EUR_FI_Indirect_On_Trade',
      'EUR_FI_Direct_On_Trade'
    };
    
    private final Set<String> validStatus = new Set<String>{ 
      'Active','Prospect','Potential Customer'
    }; 
     
    private final String ACTIVE = 'Active';
    private final String INACTIVE = 'Inactive';
    private final String OUTLET = 'Outlet';
    private final String HEAD_OFFICE = 'Head Office';

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(allRecordTypes);

            return TRt;
        }private set;
    }
    


    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id,Recordtype> accountRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : accountRecordTypes){
           accountRecordTypesMap.put(rt.id,rt);
        }
        
        List<EUR_CRM_Account__c> validAccounts = new List<EUR_CRM_Account__c>(); 
        Set<Id> validAccountIds = new Set<Id>();
        Set<Id> deleteContractAccountMap = new Set<Id>();
        Set<Id> headOfficeAccountIds = new Set<Id>();
        List<EUR_CRM_Account__c> createMapAccounts = new List<EUR_CRM_Account__c>();

        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountToinsert = new List<EUR_CRM_Contract_Account_Mapping__c>();
        List<EUR_CRM_Contract_Account_Mapping__c> contractAccountToDelete = new List<EUR_CRM_Contract_Account_Mapping__c>(); 
         
        
        for(EUR_CRM_Account__c euAccount : (List<EUR_CRM_Account__c>) sObjList){
            
            String accountRecordType = accountRecordTypesMap.get(euAccount.recordtypeid).developername;
            
            if(!onTradeFinlandRecordTypes.contains(accountRecordType))
                continue;
            if(Trigger.isInsert && euAccount.EUR_CRM_Parent_Account__c != null
                && euAccount.EUR_CRM_Business_Type__c == OUTLET){
                headOfficeAccountIds.add(euAccount.EUR_CRM_Parent_Account__c);
                createMapAccounts.add(euAccount);
            }
            if(Trigger.isUpdate){
                EUR_CRM_Account__c oldEuAccount = (EUR_CRM_Account__c) oldMap.get(euAccount.id);                
                if(euAccount.EUR_CRM_Business_Type__c == OUTLET &&
                    oldEuAccount.EUR_CRM_Parent_Account__c != euAccount.EUR_CRM_Parent_Account__c){
                    if(euAccount.EUR_CRM_Parent_Account__c != null){
                        //create mapping
                        headOfficeAccountIds.add(euAccount.EUR_CRM_Parent_Account__c);
                        createMapAccounts.add(euAccount);
                    }
                    if(oldEuAccount.EUR_CRM_Parent_Account__c != null){
                        //delete mapping
                        deleteContractAccountMap.add(euAccount.id);

                    }
                }             
                if(oldEuAccount.EUR_CRM_Business_Type__c != euAccount.EUR_CRM_Business_Type__c &&
                    euAccount.EUR_CRM_Business_Type__c == HEAD_OFFICE){
                    //delete mapping
                    deleteContractAccountMap.add(euAccount.id);
                }
            }
        }

        Map<Id,Set<Id>> headOfficeChainContracts = new Map<Id,Set<Id>>();
        if(headOfficeAccountIds.size() > 0)
        for(EUR_CRM_Contract__c chainContract : [select id, EUR_CRM_Account__c from EUR_CRM_Contract__c where
                EUR_CRM_Account__c in: headOfficeAccountIds AND
                EUR_CRM_Status__c = 'Activated' AND
                Recordtype.developername = 'EUR_FI_Chain_Contract']){
            
            if(headOfficeChainContracts.get(chainContract.EUR_CRM_Account__c) == null)
                headOfficeChainContracts.put(chainContract.EUR_CRM_Account__c, new Set<Id>());
            headOfficeChainContracts.get(chainContract.EUR_CRM_Account__c).add(chainContract.id);
        }
        if(createMapAccounts.size() >0 ){
            Id mappingRecordTypeId = [select id from Recordtype where sObjectType = 'EUR_CRM_Contract_Account_Mapping__c' AND developername = 'EUR_FI_Contract_Account_Mapping'].id;
            for(EUR_CRM_Account__c euAccount : createMapAccounts){
                Set<Id> chainContracts = headOfficeChainContracts.get(euAccount.EUR_CRM_Parent_Account__c);
                if(chainContracts != null){
                    for(Id contractId : chainContracts){
                        EUR_CRM_Contract_Account_Mapping__c mapping = new EUR_CRM_Contract_Account_Mapping__c(
                            EUR_CRM_Account__c = euAccount.Id,
                            EUR_CRM_Contract__c = contractId,
                            recordTypeId = mappingRecordTypeId
                        );
                        contractAccountToinsert.add(mapping);
                    }
                }
            }
        }
        if(deleteContractAccountMap.size() > 0)
            contractAccountToDelete = [select id from EUR_CRM_Contract_Account_Mapping__c where EUR_CRM_Account__c in: deleteContractAccountMap];
    
        Savepoint sp = Database.setSavepoint();
        try{
            system.debug('@@ inserting ' + contractAccountToinsert );
            system.debug('@@ updating ' + contractAccountToDelete); 
            if(contractAccountToDelete.size() > 0)
                delete contractAccountToDelete;    
            if(contractAccountToinsert.size() > 0) 
                insert contractAccountToinsert;   
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('ERROR: ' + e); 
        }
    }
    
    public EUR_CRM_FI_ContractAccountHandler(){
        super('EUR_CRM_FI_ContractAccountHandler');
    } 
}