public with sharing class ASI_HK_CRM_RoutingTableGenerator {

	public static final String DEF_VALUE_HEADER_NAME = 'Test Routing Setting';
	
	public static final String RT_HeaderDefault = 'ASI_HK_CRM_SO_Routing_Table_Header';
	public static final String RT_DetailSpecificUser = 'ASI_HK_CRM_SO_Routing_Table_Detail_Specfic_User';
	public static final String RT_DetailUserField = 'ASI_HK_CRM_SO_Routing_Table_Detail_User_Field';

	private static Map<String, RecordType> RTMapHeader {
		get {
			if (RTMapHeader == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_HK_CRM_SO_Routing_Table_Header__c'];
				RTMapHeader = new Map<String, RecordType>();
				for (RecordType rt : RTList) {
					RTMapHeader.put(rt.DeveloperName, rt);
				}
			}
			return RTMapHeader;
		}
		set;
	}
	private static Map<String, RecordType> RTMapDetail {
		get {
			if (RTMapDetail == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_HK_CRM_SO_Routing_Table_Detail__c'];
				RTMapDetail = new Map<String, RecordType>();
				for (RecordType rt : RTList) {
					RTMapDetail.put(rt.DeveloperName, rt);
				}
			}
			return RTMapDetail;
		}
		set;
	}

	public static RecordType getHeaderRecordTypeByDevName(String devName) { return RTMapHeader.get(devName); }
	public static RecordType getDetailRecordTypeByDevName(String devName) { return RTMapDetail.get(devName); }
	
	public ASI_HK_CRM_SO_Routing_Table_Header__c generateBasicRoutingTableHeader() {
		return new ASI_HK_CRM_SO_Routing_Table_Header__c(
			Name = DEF_VALUE_HEADER_NAME
		);
	}

	public ASI_HK_CRM_SO_Routing_Table_Header__c generateRoutingTableHeader(ID rtID) {
		ASI_HK_CRM_SO_Routing_Table_Header__c result = generateBasicRoutingTableHeader();
		result.RecordTypeId = rtID;
		return result;
	}

	public ASI_HK_CRM_SO_Routing_Table_Header__c generateRoutingTableHeader() {
		return generateRoutingTableHeader(getHeaderRecordTypeByDevName(RT_HeaderDefault).Id);
	}
	
	public ASI_HK_CRM_SO_Routing_Table_Detail__c generateBasicRoutingTableDetail(ASI_HK_CRM_SO_Routing_Table_Header__c rHeader) {
		return new ASI_HK_CRM_SO_Routing_Table_Detail__c(
			ASI_HK_CRM_SO_Routing_Table_Header__c = rHeader.Id
		);
	}

	public ASI_HK_CRM_SO_Routing_Table_Detail__c generateRoutingTableDetail(ASI_HK_CRM_SO_Routing_Table_Header__c rHeader, ID rtID) {
		ASI_HK_CRM_SO_Routing_Table_Detail__c result = generateBasicRoutingTableDetail(rHeader);
		result.RecordTypeId = rtID;
		return result;
	}

	public ASI_HK_CRM_SO_Routing_Table_Detail__c generateRoutingTableDetail(ASI_HK_CRM_SO_Routing_Table_Header__c rHeader, String rtDevName) {
		return generateRoutingTableDetail(rHeader, getDetailRecordTypeByDevName(rtDevName).Id);
	}

}