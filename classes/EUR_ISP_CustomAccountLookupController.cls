/**
 * Custom AccountEU Lookup for Settlement Edit / Create page for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public with sharing class EUR_ISP_CustomAccountLookupController
{
	private static final Integer LIMIT_RECORDS = 25;
	public List<EUR_CRM_Account__c> results {get; set;} // search results
	public String searchString {get; set;} // search keyword

	public EUR_ISP_CustomAccountLookupController()
	{
		// get the current search string
		searchString = System.currentPageReference().getParameters().get('lksrch');
		runSearch();
	}

	// performs the keyword search
	public PageReference search()
	{
		runSearch();
		return null;
	}

	// prepare the query and issue the search command
	private void runSearch()
	{
		// TODO prepare query string for complex serarches & prevent injections
		results = performSearch(searchString);
	}

	// run the search and return the records found.
	private List<EUR_CRM_Account__c> performSearch(String searchString)
	{
		String queryString = 'SELECT Id, Name, EUR_CRM_Street__c,EUR_CRM_City__c, EUR_CRM_Postal_Code__c, EUR_CRM_Company_Name__c FROM EUR_CRM_Account__c ';
		if (String.isNotBlank(searchString))
		{
			queryString += ' WHERE EUR_CRM_Status__c  != \'Inactive\' AND' + getWhereClause(searchString, 'Name');
		}else{
			queryString += ' WHERE EUR_CRM_Status__c  != \'Inactive\'';
		}

		queryString += 'ORDER BY Name ASC LIMIT ' + LIMIT_RECORDS;
		List<EUR_CRM_Account__c> accountsList = Database.query(queryString);
		System.debug('queryString : ' + queryString);

		// search in junction if dont reach limit
		if (accountsList.size() < LIMIT_RECORDS)
		{
			accountsList.addAll(searchInJunction(accountsList, searchString, LIMIT_RECORDS - accountsList.size()));
		}
		return accountsList;
	}

	private List<EUR_CRM_Account__c> searchInJunction(List<EUR_CRM_Account__c> accounts, String searchString, Integer recordsLimit)
	{
		Set<Id> excludedAccounts = new Map<Id, EUR_CRM_Account__c>(accounts).keySet();
		List<EUR_CRM_Account__c> accountsList = new List<EUR_CRM_Account__c>();
		for (SObject userToAccount : EUR_ISP_LookupSObjectController.searchAccounts(excludedAccounts, searchString, recordsLimit))
		{
			accountsList.add((EUR_CRM_Account__c)userToAccount.getSobject('EUR_ISP_Account__r'));
		}
		return accountsList;
	}

	private String getWhereClause(String searchString, String field)
	{
		String conditionValue = String.escapeSingleQuotes(searchString).trim().toLowerCase();
		return ' (' + field + ' LIKE \'%' + conditionValue.capitalize() + '%\' OR ' +
		       field + ' LIKE \'%' + conditionValue + '%\' OR ' +
		       field + ' LIKE \'%' + conditionValue.toUpperCase() + '%\') ';
	}

	// used by the visualforce page to send the link to the right dom element
	public String getFormTag()
	{
		return System.currentPageReference().getParameters().get('frm');
	}

	// used by the visualforce page to send the link to the right dom element for the text box
	public String getTextBox()
	{
		return System.currentPageReference().getParameters().get('txt');
	}
}