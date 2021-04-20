public with sharing class EUR_CRM_ProsSegmentationManager {
	private List<RecordType> prosSegmentationRecordTypes{get;set;}
	private Map<Id, String> prosFactoryClassMap{get;set;}
	
	private final String PORTUGAL = 'EUR_CRM_ProsSegmentationFactory.EUR_PRT_PROS_Segmentation';
	
	private final String PORTUGAL_PROSSEGMENTATION_DEVNAME = 'EUR_PRT_PROS_Segmentation';

	public EUR_CRM_ProsSegmentationManager()
	{
		prosFactoryClassMap = new Map<Id, String>();
		prosSegmentationRecordTypes = [SELECT Id, Name, DeveloperName FROM RecordType 
								WHERE SobjectType='EUR_CRM_Pros_Segmentation__c'];
		
		System.debug('Flag - Pros Segmentation Record Type:' + prosSegmentationRecordTypes);
		//TODO: Support other affiliate 
		for(RecordType recordType: prosSegmentationRecordTypes){
			if(recordType.DeveloperName.equalsIgnoreCase(PORTUGAL_PROSSEGMENTATION_DEVNAME)) 
				prosFactoryClassMap.put(recordType.Id, PORTUGAL);
		}
		
		System.debug('Flag - Pros Segmentation Record Type Map:' + prosFactoryClassMap);
	}
	
	public EUR_CRM_ProsSegmentationFactory.IProsSegmentationInterface newClassInstance(Id recordTypeId)
	{
		String className = null;
		if (prosFactoryClassMap.containsKey(recordTypeId))
		{
			className = prosFactoryClassMap.get(recordTypeId);
			Type t = Type.forName(className);
			System.debug('Flag - Pros Segmentation Manager - ClassName:' + className +'-'+  t );
			return (EUR_CRM_ProsSegmentationFactory.IProsSegmentationInterface)t.newInstance();
		}
		return null;
	}
	/*
	public Id assignRecordId(String countryCode){
		Id recordId = null;
		RecordType rec = assignRecordType(countryCode);
		if(rec!=null)
			recordId = rec.Id;
		
		return recordId;
	}
	
	private RecordType assignRecordType (String countryCode){
		RecordType recordType = null;
		if (countryCode!=null){
			for (RecordType rec: prosSegmentationRecordTypes){
				String code = rec.DeveloperName.replace('EUR_', '').replace('_PROS_Segmentation', '');
				if(countryCode.equalsIgnoreCase(code))
				{
					recordType = rec;
					break;
				}
			}
		}
		
		return recordType;
	}
	*/
}