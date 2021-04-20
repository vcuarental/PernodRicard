public with sharing class EUR_TR_TeknaMapController {
    public EUR_TR_TeknaMapController() {

    }

    @AuraEnabled
	public static Map<String, String> GetLocation(string Id, string ObjectName, string FieldName, string TitleName, string DescriptionFieldName){
		Map<String, String> locationInfo = new Map<String,String>();

		if (String.isNotEmpty(Id) && String.isNotEmpty(ObjectName) && String.isNotEmpty(FieldName) && String.isNotEmpty(TitleName)){
			String latField = FieldName.replace('__c', '__Latitude__s');
			String lngField = FieldName.replace('__c', '__Longitude__s');
			String description = String.isNotEmpty(DescriptionFieldName) ? ',' + DescriptionFieldName : '';
			String query = 'select ' + latField + ',' + lngField + ',' + TitleName + description + ' from ' + ObjectName + ' where Id=\'' + Id + '\'';
			List<sObject> result = database.query(query);

			locationInfo.put('latitude', String.isEmpty(String.valueOf(result[0].get(latField))) ? '': String.valueOf(result[0].get(latField)));
			locationInfo.put('longitude', String.isEmpty(String.valueOf(result[0].get(lngField))) ? '' : String.valueOf(result[0].get(lngField)));
			locationInfo.put('title', String.isEmpty(String.valueOf(result[0].get(TitleName))) ? '' : String.valueOf(result[0].get(TitleName)));
			locationInfo.put('description', String.isEmpty(DescriptionFieldName) ? '' : String.valueOf(result[0].get(DescriptionFieldName)));
		}
		
		return locationInfo;
		
	}
}