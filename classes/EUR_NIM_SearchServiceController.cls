/**
    SearchService class is Apex class to perform SOQL based on Account, Contact
    
    @author Minakshi Waghulde
    
    @copyright PARX
*/
public with sharing class EUR_NIM_SearchServiceController 
{
    private static string countryCode;
    private static string[] countryCodeList;
    private static string limitResult = ' limit 1000';
    /* Method to search Account / Contacts based on the search fields */
    @AuraEnabled
	public static List<EUR_NIM_Service.AccountContactResult> searchByAccountContact(String companyName, String customerNumberERP, String street, String postalCode, String city, String phone, String firstName, String lastName) 
	{
        List<EUR_NIM_Service.AccountContactResult> acList = new List<EUR_NIM_Service.AccountContactResult>();
        Map<Id,EUR_CRM_Account__c> aMap = new Map<Id,EUR_CRM_Account__c>();
        Set<Id> accountIdInContact = new Set<Id>();
        
        if (String.isNotBlank(companyName) || String.isNotBlank(street) || String.isNotBlank(postalCode) || 
            String.isNotBlank(city) || String.isNotBlank(customerNumberERP))
        {
            EUR_NIM_Service.Criteria companyNameCriteria = new EUR_NIM_Service.Criteria('Name', String.isNotBlank(companyName) ? String.escapeSingleQuotes(companyName) : companyName, 'LIKE');
            EUR_NIM_Service.Criteria customerNumberERPCriteria = new EUR_NIM_Service.Criteria('EUR_CRM_Customer_No_ERP__c', String.isNotBlank(customerNumberERP)? String.escapeSingleQuotes(customerNumberERP) : customerNumberERP, 'LIKE');
            EUR_NIM_Service.Criteria streetCriteria = new EUR_NIM_Service.Criteria('EUR_CRM_Street__c', String.isNotBlank(street) ? String.escapeSingleQuotes(street) : street, 'LIKE');
            EUR_NIM_Service.Criteria postalCodeCriteria = new EUR_NIM_Service.Criteria('EUR_CRM_Postal_Code__c', String.isNotBlank(postalCode)? String.escapeSingleQuotes(postalCode) : postalCode, 'LIKE');
            EUR_NIM_Service.Criteria cityCriteria = new EUR_NIM_Service.Criteria('EUR_CRM_City__c', String.isNotBlank(city) ? String.escapeSingleQuotes(city) : city, 'LIKE');
            
            String account_where_cond = EUR_NIM_Service.generateWhereQuery(new List<EUR_NIM_Service.Criteria>{companyNameCriteria, customerNumberERPCriteria, 
                                                                    streetCriteria, postalCodeCriteria, cityCriteria});
            system.debug('Account where_cond: ' + account_where_cond);

            String queryString = 'select Id, Name, EUR_CRM_Customer_No_ERP__c, EUR_CRM_Street__c, EUR_CRM_City__c, EUR_CRM_Country__c, ' +
                                    'EUR_CRM_Postal_Code__c from EUR_CRM_Account__c WHERE ' + account_where_cond;
            
            queryString += ' AND EUR_CRM_Status__c = \'Active\'';
            queryString += getCountryFilterString(true);
            queryString += limitResult;
            system.debug('queryString: ' + queryString);
            List<EUR_CRM_Account__c> aList = Database.query(queryString);

            for(EUR_CRM_Account__c acc : aList)
            {
                aMap.put(acc.Id, acc);
            }            
            
            system.debug('Account Map: ' + aMap);
        }
        
        // the following logic will remove a duplicate account from the account result when both account and contact 
        //fields are used in the query.
        if (String.isNotBlank(firstName) || String.isNotBlank(lastName) || String.isNotBlank(phone))
        {
            EUR_NIM_Service.Criteria phoneCriteria = new EUR_NIM_Service.Criteria('Phone', String.isNotBlank(phone) ? String.escapeSingleQuotes(phone) : phone, 'LIKE');
            EUR_NIM_Service.Criteria firstNameCriteria = new EUR_NIM_Service.Criteria('FirstName', String.isNotBlank(firstName)?String.escapeSingleQuotes(firstName):firstName, 'LIKE');
            EUR_NIM_Service.Criteria lastNameCriteria = new EUR_NIM_Service.Criteria('LastName', String.isNotBlank(lastName)?String.escapeSingleQuotes(lastName):lastName, 'LIKE');
            
            String contact_where_cond = EUR_NIM_Service.generateWhereQuery(new List<EUR_NIM_Service.Criteria>{phoneCriteria, firstNameCriteria, lastNameCriteria});
            system.debug('Contact where_cond: ' + contact_where_cond);

            String contactQueryString = 'Select Id, EUR_CRM_Account__r.Id, Phone, FirstName, LastName, EUR_CRM_Account__r.Name, '+
                                    'EUR_CRM_Account__r.EUR_CRM_Street__c, ' +
                                ' EUR_CRM_Account__r.EUR_CRM_City__c,  EUR_CRM_Account__r.EUR_CRM_Country__c, '+
                                'EUR_CRM_Account__r.EUR_CRM_Postal_Code__c ' +
                                ' From Contact WHERE ' + contact_where_cond;
            
            contactQueryString += ' AND EUR_CRM_Account__r.EUR_CRM_Status__c = \'Active\'';
            contactQueryString += getCountryFilterString(false);
            contactQueryString += limitResult;
            system.debug('queryString: ' + contactQueryString);
            List<Contact> cList = Database.query(contactQueryString);
            
            system.debug('cList: ' + cList);
            if(cList.size() > 0)
            {
                for (Contact c : cList)
                {
                    accountIdInContact.add(c.EUR_CRM_Account__r.Id);
                    acList.add(new EUR_NIM_Service.AccountContactResult(null, c,c.EUR_CRM_Account__r.Id, c.EUR_CRM_Account__r.Name)); 
                }                
            }
        }

        for (EUR_CRM_Account__c a : aMap.values())
        {
            if(!accountIdInContact.contains(a.Id))
            {
                acList.add(new EUR_NIM_Service.AccountContactResult(a, null,a.Id, a.Name)); 
            }
        }

        system.debug('acList: ' + acList);
        return acList;
	}
    
    /*
        @description build a string in order to query the record based on the user country code
    */
    private static String getCountryFilterString(boolean isAccount)
    {
        String countryCodeAPIName = isAccount ? 'EUR_CRM_Country_Code__c' : 'EUR_CRM_Account__r.EUR_CRM_Country_Code__c';
        String queryCondition = '';
        String profileName = [select Name from Profile where Id =: UserInfo.getProfileId()].Name;

        if (profileName != null && profileName != '' && profileName.startsWith('EUR NIM'))
        {
            // special condition for DE, we limit the condition also for delivery type = Direct
            if (profileName.startsWith('EUR NIM DE'))
            {
                queryCondition += ' AND ' + countryCodeAPIName + ' = \'DE\'';
                return queryCondition += isAccount ?   ' AND EUR_CRM_Delivery_Type__c = \'Direct\'' : ' AND EUR_CRM_Account__r.EUR_CRM_Delivery_Type__c=\'Direct\''; 
            }

            // special condition for DB and IDL, an agent should able to see both affiliates 
            if (profileName.startsWith('EUR NIM DB') || profileName.startsWith('EUR NIM IDL'))
            {
                return ' AND ' + countryCodeAPIName + ' in ( \'DB\', \'IDL\' )'; 
            }

            String countryCode = profileName.split(' ').get(2);
            return ' AND ' + countryCodeAPIName + ' = \'' + countryCode + '\''; 
        }
        return ''; 
    }
    
}