public with sharing class EUR_CRM_DE_ContractAutoNumberHandler extends EUR_CRM_TriggerAbstract{
	private static String countrycodeGermany = 'DE';
	//private static Integer contractNumberLength = 10;
	
	public EUR_CRM_DE_ContractAutoNumberHandler(){
		super('EUR_CRM_DE_ContractAutoNumberHandler');
	}
	
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)
	{
		Set<String> contractRecordTypeDevNameSet = new Set<String>();
		//Get All Record Type for Contract
		//Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosById();
		Map<Id, RecordType> rtMap = new Map<Id, RecordType>([SELECT Id,Name, DeveloperName 
										FROM RecordType WHERE SobjectType='EUR_CRM_Contract__c' 
										LIMIT 10000]);
		System.debug('Flag - Contract Number Trigger - Check Contract Record Type Map:' + rtMap);
		
		//Iterate new Map, list items for processing and record type name
		for (EUR_CRM_Contract__c contract: (List<EUR_CRM_Contract__c>)sObjList)
		{
			if (contract.EUR_CRM_Country_Code__c.equalsIgnoreCase(countrycodeGermany) && rtMap.containsKey(contract.RecordTypeId)){
				contractRecordTypeDevNameSet.add(rtMap.get(contract.RecordTypeId).DeveloperName);
			}
		}
		
		if (contractRecordTypeDevNameSet.size()>0){
			Map<String, EUR_CRM_Auto_Number_Container__c> autoNumberMap = new Map<String, EUR_CRM_Auto_Number_Container__c>();//Key: Name field - Record Type Developer Name
		
			System.debug('Flag - Contract Number Trigger - Check Contract Record Type Set:' + contractRecordTypeDevNameSet);
			//Search record type name at auto number container
			if (contractRecordTypeDevNameSet.size()>0){
				List<EUR_CRM_Auto_Number_Container__c> autoNumContainerList = new List<EUR_CRM_Auto_Number_Container__c>([Select Id, Name, 
															EUR_CRM_Auto_Number_Length__c, EUR_CRM_Current_Count__c,
															EUR_CRM_Number_Prefix__c FROM EUR_CRM_Auto_Number_Container__c
															WHERE Name IN: contractRecordTypeDevNameSet]);
				//Create Auto Number Container Map - Key Name field, record type developer name 
				for (EUR_CRM_Auto_Number_Container__c autoNum: autoNumContainerList){
					autoNumberMap.put(autoNum.Name, autoNum);
				}
				System.debug('Flag - Contract Number Trigger - Check Auto Number Map:' + autoNumberMap);
				
				//Iterate items for processing, assign auto number
				for (EUR_CRM_Contract__c contract: (List<EUR_CRM_Contract__c>)sObjList)
				{
					if (rtMap.containsKey(contract.RecordTypeId)){
						String recordTypeDevName = rtMap.get(contract.RecordTypeId).DeveloperName;
						if (autoNumberMap.containsKey(recordTypeDevName)){
							EUR_CRM_Auto_Number_Container__c autoNumCont = autoNumberMap.get(recordTypeDevName);
							autoNumCont.EUR_CRM_Current_Count__c += 1;
							contract.EUR_CRM_Contract_Number__c = autoNumCont.EUR_CRM_Number_Prefix__c+formatAutoNumber(Integer.valueOf(autoNumCont.EUR_CRM_Current_Count__c), Integer.valueOf(autoNumCont.EUR_CRM_Auto_Number_Length__c));
							
							autoNumberMap.put(recordTypeDevName, autoNumCont);
							
							System.debug('Flag - Contract Number Trigger - Process Item:' + contract.EUR_CRM_Contract_Number__c +'-'+autoNumberMap.get(recordTypeDevName));
						}
					}
				}
				
				//Update auto number container
				Database.update(autoNumberMap.values());
			}
		}
	}
	
	private String formatAutoNumber(Integer num, Integer autoNumLength){
		String autoNum = '';

		for (Integer i=String.valueOf(num).length(); i<autoNumLength; i++){
			autoNum += '0';
		}
		
		autoNum += num;
		return autoNum;
	}

}