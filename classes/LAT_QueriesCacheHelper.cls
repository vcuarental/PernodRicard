public class LAT_QueriesCacheHelper {
	
	private static Map<String, List<UDC__c>> udcMap;

	public LAT_QueriesCacheHelper() {	
		
	}

	public static  List<UDC__c> getUDC_List_By_CodProd_CodUs_RT(String codProd, String codUs, String recordTypeId) {
		
		if (udcMap == null) {
			udcMap 	=	new Map<String, List<UDC__c>>();
		}
		String key = codProd + '-' + codUs + '-' + recordTypeId;
		//If the query was already done before, return the result.
		if (udcMap.get(key) != null ) {
			return udcMap.get(key);
		} 
		//if not, perfom the query, add it to the map and return the result.
		else {
			List<UDC__c> udcList = [SELECT ID, Name, CodDefUsuario__c, CodProd__c, CodUs__c, Descricao2__c FROM UDC__c 
									WHERE CodProd__c=:codProd AND CodUs__c =:codUs AND RecordTypeId =:recordTypeId];

			udcMap.put(key, udcList);
			return udcList;
		}

	}

	public static  List<UDC__c> getUDC_List_By_CodProd_CodUs_RT_Name(String codProd, String codUs, String recordTypeId, List<String> names) {
		
		if (udcMap == null) {
			udcMap 	=	new Map<String, List<UDC__c>>();
		}
		String key = codProd + '-' + codUs + '-' + recordTypeId + '-' + names;
		//If the query was already done before, return the result.
		if (udcMap.get(key) != null ) {
			return udcMap.get(key);
		} 
		//if not, perfom the query, add it to the map and return the result.
		else {
			List<UDC__c> udcList = [SELECT ID, Name, CodDefUsuario__c, CodProd__c, CodUs__c, Descricao2__c FROM UDC__c 
									WHERE CodProd__c=:codProd AND CodUs__c =:codUs AND RecordTypeId =:recordTypeId AND Name IN:names];
			udcMap.put(key, udcList);
			return udcList;
		}
	}

	public static List<UDC__c> getUDC_List_By_Ids(List<String> udcIds) {
		
		if (udcMap == null) {
			udcMap 	=	new Map<String, List<UDC__c>>();
		}
		String key = '' + udcIds;
		//If the query was already done before, return the result.
		if (udcMap.get(key) != null ) {
			return udcMap.get(key);
		} 
		//if not, perfom the query, add it to the map and return the result.
		else {
			List<UDC__c> udcList = [SELECT ID, Name, CodDefUsuario__c, CodProd__c, CodUs__c, Descricao2__c FROM UDC__c 
									WHERE Id IN:udcIds];

			udcMap.put(key, udcList);
			return udcList;
		}

	}

	public static List<UDC__c> getUDC_List_By_Ids_RT(List<String> udcIds, String recordTypeId) {
		
		if (udcMap == null) {
			udcMap 	=	new Map<String, List<UDC__c>>();
		}
		String key = udcIds + '-' + recordTypeId;
		//If the query was already done before, return the result.
		if (udcMap.get(key) != null ) {
			return udcMap.get(key);
		} 
		//if not, perfom the query, add it to the map and return the result.
		else {
			List<UDC__c> udcList = [SELECT ID, Name, CodDefUsuario__c, CodProd__c, CodUs__c, Descricao2__c FROM UDC__c 
									WHERE Id IN:udcIds AND RecordTypeId =: recordTypeId ];

			udcMap.put(key, udcList);
			return udcList;
		}

	}
}