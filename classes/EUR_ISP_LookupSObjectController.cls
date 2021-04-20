/**
 * Apex Controller for looking up an SObject via SOSL
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_LookupSObjectController
{
	private static final Integer RECORDS_LIMIT = 50;
	/**
	 * Aura enabled method to get already selected Sobject for a specific Id
	 */
	@AuraEnabled
	public static SelectionData getSelectedData(String sObjectId, String sObjectAPIName)
	{
		SelectionData outputResult = NULL;
		if (String.isBlank(sObjectId))
		{
			return outputResult;
		}

		// Sanitze the input
		sObjectId = String.escapeSingleQuotes(sObjectId);
		sObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);

		if (sObjectAPIName == 'EUR_ISP_Vendor__c')
		{
			for (SObject theObject : Database.query('SELECT Id, Name, EUR_ISP_Vendor_Name__c FROM ' + sObjectAPIName + ' WHERE Id = \'' + sObjectId + '\''))
			{
				outputResult = new SelectionData(theObject, 'EUR_ISP_Vendor_Name__c');
			}
		}
		else
		{
			for (SObject theObject : Database.query('SELECT Id, Name FROM ' + sObjectAPIName + ' WHERE Id = \'' + sObjectId + '\''))
			{
				outputResult = new SelectionData(theObject);
			}
		}

		return outputResult;
	}

	/**
	 * Aura enabled method to get inital data for the lookup component for a specific SObject
	 */
	@AuraEnabled
	public static List<SelectionData> getInitSelectionData(String sObjectAPIName)
	{
		// Sanitze the input
		sObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
		List<SelectionData> outputResults = new List<SelectionData>();

		// Build our SOQL query
		for (SObject theObject : Database.query('SELECT Id, Name FROM ' + sObjectAPIName + ' ORDER BY Name ASC LIMIT ' + RECORDS_LIMIT))
		{
			outputResults.add(new SelectionData(theObject));
		}
		return outputResults;
	}

	/**
	 * Aura enabled method to search a specified SObject for a specific string
	 */
	@AuraEnabled
	public static List<SelectionData> getSelectionData(String searchString, String sObjectAPIName)
	{
		List<SelectionData> outputResults = new List<SelectionData>();
		if (String.isBlank(searchString))
		{
			return outputResults;
		}

		// Sanitze the input
		searchString = String.escapeSingleQuotes(searchString);
		sObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);

		// Build our SOSL query
		List<List<SObject>> searchList = search.query('FIND \'' + searchString + '*\' IN ALL FIELDS RETURNING ' + sObjectAPIName + ' (id,name) LIMIT ' + RECORDS_LIMIT);
		for (SObject theObject : searchList[0])
		{
			outputResults.add(new SelectionData(theObject));
		}
		return outputResults;
	}

	@AuraEnabled
	public static List<SelectionData> getAccounts(String searchString)
	{
		List<SelectionData> outputResults = new List<SelectionData>();
		// Build our SOQL query
		String queryString = 'SELECT EUR_ISP_Account__c, EUR_ISP_Account__r.Id, EUR_ISP_Account__r.Name ' +
		                     'FROM EUR_ISP_UserAccount__c ' +
		                     'WHERE EUR_ISP_User__c =\'' + UserInfo.getUserId() + '\' ';

		if (String.isNotBlank(searchString))
		{
			String conditionValue = String.escapeSingleQuotes(searchString).trim().toLowerCase();

			queryString += 'AND (EUR_ISP_Account__r.Name LIKE \'%' + conditionValue.capitalize() + '%\' OR ' +
			               'EUR_ISP_Account__r.Name LIKE \'%' + conditionValue + '%\' OR ' +
			               'EUR_ISP_Account__r.Name LIKE \'%' + conditionValue.toUpperCase() + '%\') ';
		}
		queryString += 'ORDER BY EUR_ISP_Account__r.Name ASC LIMIT ' + RECORDS_LIMIT;

		for (SObject userToAccount : Database.query(queryString))
		{
			outputResults.add(new SelectionData(userToAccount.getSobject('EUR_ISP_Account__r')));
		}
		return outputResults;
	}

	@AuraEnabled
	public static List<SelectionData> getVendors(String searchString, String accountId)
	{
		List<SelectionData> outputResults = new List<SelectionData>();
		if (String.isBlank(accountId))
		{
			return outputResults;
		}

		// Build our SOQL query
		String queryString = 'SELECT EUR_ISP_Vendor__c, EUR_ISP_Vendor__r.Id, EUR_ISP_Vendor__r.Name, EUR_ISP_Vendor__r.EUR_ISP_ERP_ID__c, EUR_ISP_Vendor__r.EUR_ISP_Vendor_Name__c ' +
		                     'FROM EUR_ISP_AccountVendor__c ' +
		                     'WHERE EUR_ISP_Account__c =\'' + String.escapeSingleQuotes(accountId) + '\' ' +
		                     'AND EUR_ISP_Active__c = true ' +
		                     'AND EUR_ISP_Vendor__r.EUR_ISP_Enabled_For_selection__c = true ';

		if (String.isNotBlank(searchString))
		{
			queryString += 'AND (EUR_ISP_Vendor__r.Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\' ';
			queryString += 'OR EUR_ISP_Vendor__r.EUR_ISP_Vendor_Name__c LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\' ';
			queryString += 'OR EUR_ISP_Vendor__r.EUR_ISP_ERP_ID__c LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\') ';
		}
		queryString += 'ORDER BY EUR_ISP_Vendor__r.Name ASC LIMIT ' + RECORDS_LIMIT;

		for (SObject accountToVendor : Database.query(queryString))
		{
			EUR_ISP_Vendor__c theVendor = (EUR_ISP_Vendor__c) accountToVendor.getSObject('EUR_ISP_Vendor__r');
			SelectionData theSelection = new SelectionData(theVendor, 'EUR_ISP_Vendor_Name__c');
			if (String.isNotBlank(theVendor.EUR_ISP_ERP_ID__c))
			{
				theSelection.label += ' - ' + theVendor.EUR_ISP_ERP_ID__c;
			}
			outputResults.add(theSelection);
		}
		return outputResults;
	}

	public static List<sObject> searchAccounts(Set<Id> accIdsToExclude, String searchString, Integer recordsLimit)
	{
		// Build our SOQL query
		String queryString = 'SELECT EUR_ISP_Account__c, EUR_ISP_Account__r.Id, EUR_ISP_Account__r.Name ' +
		                     'FROM EUR_ISP_UserAccount__c ' +
		                     'WHERE EUR_ISP_User__c =\'' + UserInfo.getUserId() + '\' AND EUR_ISP_Account__c NOT IN: accIdsToExclude ';

		if (String.isNotBlank(searchString))
		{
			String conditionValue = String.escapeSingleQuotes(searchString).trim().toLowerCase();

			queryString += 'AND (EUR_ISP_Account__r.Name LIKE \'%' + conditionValue.capitalize() + '%\' OR ' +
			               'EUR_ISP_Account__r.Name LIKE \'%' + conditionValue + '%\' OR ' +
			               'EUR_ISP_Account__r.Name LIKE \'%' + conditionValue.toUpperCase() + '%\') ';
		}
		queryString += 'ORDER BY EUR_ISP_Account__r.Name ASC LIMIT ' + recordsLimit;
		return Database.query(queryString);
	}

	/**
	 * Inner class to wrap up an SObject Label and its Id
	 */
	public class SelectionData
	{
		@AuraEnabled
		public String id {get; set;}
		@AuraEnabled
		public String label {get; set;}

		public SelectionData(SObject theObject)
		{
			this.id = theObject.Id;
			this.label = (String)theObject.get('Name');
		}

		public SelectionData(SObject theObject, String fieldName)
		{
			this.id = theObject.Id;
			this.label = (String)theObject.get(fieldName);
		}
	}
}