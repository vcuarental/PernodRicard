public with sharing class EUR_DOC_SampleLookupController {

    private final static Integer MAX_RESULTS = 10;
    private static Map<String, String> mapTrade_values = new Map<String, String>();

    @AuraEnabled(Cacheable=true)
    public static List<EUR_DOC_LookupSearchResult> searchAccounts(String searchTerm, List<String> selectedIds) {
        loadFilterTrade();
        searchTerm += '*';
        String whereClause = getCountryCode();
        
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_Account__c (Id,Name,EUR_CRM_Street__c,EUR_CRM_City__c,EUR_CRM_Channel__c '+whereClause+') LIMIT '+MAX_RESULTS);

        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        String accountIcon = 'standard:account';
        EUR_CRM_Account__c [] accounts = ((List<EUR_CRM_Account__c>) searchResults[0]);
        System.debug('SOSL real : ' + accounts);
        for (EUR_CRM_Account__c account : accounts) {
                    results.add(new EUR_DOC_LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, 'Account • '+ account.EUR_CRM_Street__c+' '+account.EUR_CRM_City__c, mapTrade_values.get(account.EUR_CRM_Channel__c)));
        }

        System.debug(Limits.getCpuTime());
        System.debug(results);
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<EUR_DOC_LookupSearchResult> searchUsers(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';
        String whereClause = getCountryCode();

        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING User (Id,Name,Email '+whereClause+') LIMIT '+MAX_RESULTS);

        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        String userIcon = 'standard:user';
        User [] users = ((List<User>) searchResults[0]);
        for (User us : users) {
            results.add(new EUR_DOC_LookupSearchResult(us.Id, 'User', userIcon, us.Name, 'User • '+ us.Email, null));
        }

        System.debug(Limits.getCpuTime());
        System.debug(results);
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<EUR_DOC_LookupSearchResult> searchTaxonomy(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';
        
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_Customer_Taxonomy__c (Id,Name,EUR_CRM_Chain__c,EUR_CRM_Sub_Chain__c) LIMIT '+MAX_RESULTS);
        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        String taxIcon = 'custom:custom72';
        EUR_CRM_Customer_Taxonomy__c [] taxs = ((List<EUR_CRM_Customer_Taxonomy__c>) searchResults[0]);
        for (EUR_CRM_Customer_Taxonomy__c tax : taxs) {
            results.add(new EUR_DOC_LookupSearchResult(tax.Id, 'EUR_CRM_Customer_Taxonomy__c', taxIcon, tax.Name, 'Taxonomy • '+tax.EUR_CRM_Chain__c+' • '+tax.EUR_CRM_Sub_Chain__c, null));
        }

        System.debug(Limits.getCpuTime());
        System.debug(results);
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<EUR_DOC_LookupSearchResult> searchTerritory(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';
        
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_Territory__c (Id,Name,EUR_CRM_Territory_Code__c) LIMIT '+MAX_RESULTS);
        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        String terIcon = 'custom:custom26';
        EUR_CRM_Territory__c [] ters = ((List<EUR_CRM_Territory__c>) searchResults[0]);
        for (EUR_CRM_Territory__c ter : ters) {
            results.add(new EUR_DOC_LookupSearchResult(ter.Id, 'EUR_CRM_Territory__c', terIcon, ter.Name, 'Territory • '+ter.EUR_CRM_Territory_Code__c, null));
        }

        System.debug(Limits.getCpuTime());
        System.debug(results);
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<EUR_DOC_LookupSearchResult> searchRegion(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';
        
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_Region__c (Id,Name,EUR_CRM_Region_Code__c) LIMIT '+MAX_RESULTS);
        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        String regIcon = 'custom:custom64';
        EUR_CRM_Region__c [] regs = ((List<EUR_CRM_Region__c>) searchResults[0]);
        for (EUR_CRM_Region__c reg : regs) {
            results.add(new EUR_DOC_LookupSearchResult(reg.Id, 'EUR_CRM_Region__c', regIcon, reg.Name, 'Region' +(reg.EUR_CRM_Region_Code__c == null ? '' : ' • ' + reg.EUR_CRM_Region_Code__c), null));
        }

        System.debug(Limits.getCpuTime());
        System.debug(results);
        return results;
    }

    @AuraEnabled(Cacheable=false)
    public static List<EUR_DOC_LookupSearchResult> searchObjectivePromotion(String searchTerm, List<String> selectedIds) {
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_Objectives_Promotions__c (Id,Name,EUR_CRM_Active_Start_Date__c, EUR_CRM_Active_End_Date__c, EUR_CRM_Status__c) LIMIT '+MAX_RESULTS);

        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        
        EUR_CRM_Objectives_Promotions__c [] ops = ((List<EUR_CRM_Objectives_Promotions__c>) searchResults[0]);

        

        for (EUR_CRM_Objectives_Promotions__c op : ops) {
            String debut = (op.EUR_CRM_Active_Start_Date__c == null ? '' : (Datetime.newInstance(op.EUR_CRM_Active_Start_Date__c, Time.newInstance(0,0,0,0))).format('MMM d, yyyy', 'Europe/paris'));
            String fin = (op.EUR_CRM_Active_End_Date__c == null ? '' : (Datetime.newInstance(op.EUR_CRM_Active_End_Date__c, Time.newInstance(0,0,0,0))).format('MMM d, yyyy', 'Europe/paris'));
            results.add(
                new EUR_DOC_LookupSearchResult(
                    op.Id, 
                    'EUR_CRM_Objectives_Promotions__c', 
                    'custom:custom20', 
                    op.Name, 
                    'OP • '+debut + ' • ' + fin + ' • ' + op.EUR_CRM_Status__c, 
                    null
                )
            );
        }

        return results;
    }

    @AuraEnabled(Cacheable=false)
    public static List<EUR_DOC_LookupSearchResult> searchPOSM(String searchTerm, List<String> selectedIds) {
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_POS_Material__c (Id,Name, RecordType.Name, EUR_CRM_POS_Material_Code__c) LIMIT '+MAX_RESULTS);

        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        
        EUR_CRM_POS_Material__c [] posms = ((List<EUR_CRM_POS_Material__c>) searchResults[0]);

        
        for (EUR_CRM_POS_Material__c posm : posms) {
            
            results.add(
                new EUR_DOC_LookupSearchResult(
                    posm.Id, 
                    'EUR_CRM_POS_Material__c', 
                    'custom:custom10', 
                    posm.Name, 
                    posm.RecordType.name + (posm.EUR_CRM_POS_Material_Code__c == null ? '' : ' • ' + posm.EUR_CRM_POS_Material_Code__c), 
                    null
                )
            );
        }

        return results;
    }

    @AuraEnabled(Cacheable=false)
    public static List<EUR_DOC_LookupSearchResult> searchB(String searchTerm, List<String> selectedIds) {
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_Brand__c (Id,Name,EUR_CRM_Brand_Code__c,recordtype.name) LIMIT '+MAX_RESULTS);
        
        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        
        EUR_CRM_Brand__c [] b_S = ((List<EUR_CRM_Brand__c>) searchResults[0]);

        for (EUR_CRM_Brand__c b : b_S) {
            
            results.add(
                new EUR_DOC_LookupSearchResult(
                    b.Id, 
                    'EUR_CRM_Brand__c', 
                    'custom:custom51', 
                    b.Name, 
                    b.recordtype.name + (b.EUR_CRM_Brand_Code__c == null ? '' : ' • ' + b.EUR_CRM_Brand_Code__c), 
                    null
                )
            );
        }

        return results;
    }

    @AuraEnabled(Cacheable=false)
    public static List<EUR_DOC_LookupSearchResult> searchBQ(String searchTerm, List<String> selectedIds) {
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_Quality__c (Id,Name, EUR_CRM_Quality_Code__c,recordtype.name) LIMIT '+MAX_RESULTS);

        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        
        EUR_CRM_Quality__c [] bq_S = ((List<EUR_CRM_Quality__c>) searchResults[0]);

        for (EUR_CRM_Quality__c bq : bq_S) {
            
            results.add(
                new EUR_DOC_LookupSearchResult(
                    bq.Id, 
                    'EUR_CRM_Quality__c', 
                    'custom:custom14', 
                    bq.Name, 
                    bq.recordtype.name + (bq.EUR_CRM_Quality_Code__c == null ? '' : ' • ' + bq.EUR_CRM_Quality_Code__c), 
                    null
                )
            );
        }

        return results;
    }

    @AuraEnabled(Cacheable=false)
    public static List<EUR_DOC_LookupSearchResult> searchBQS(String searchTerm, List<String> selectedIds) {
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_Size__c (Id,Name, EUR_CRM_Size_Code__c,recordtype.name) LIMIT '+MAX_RESULTS);
        
        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        
        EUR_CRM_Size__c [] bqs_S = ((List<EUR_CRM_Size__c>) searchResults[0]);

        for (EUR_CRM_Size__c bqs : bqs_S) {
            
            results.add(
                new EUR_DOC_LookupSearchResult(
                    bqs.Id, 
                    'EUR_CRM_Size__c', 
                    'custom:custom34', 
                    bqs.Name, 
                    bqs.recordtype.name  + (bqs.EUR_CRM_Size_Code__c == null ? '' : ' • ' + bqs.EUR_CRM_Size_Code__c),
                    null
                )
            );
        }

        return results;
    }

    @AuraEnabled(Cacheable=false)
    public static List<EUR_DOC_LookupSearchResult> searchToolkit(String searchTerm, List<String> selectedIds) {
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_Product_Toolkit__c (Id,Name, Recordtype.Name) LIMIT '+MAX_RESULTS);

        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        
        EUR_CRM_Product_Toolkit__c [] toolkits = ((List<EUR_CRM_Product_Toolkit__c>) searchResults[0]);

        for (EUR_CRM_Product_Toolkit__c t : toolkits) {
            
            results.add(
                new EUR_DOC_LookupSearchResult(
                    t.id, 
                    'EUR_CRM_Product_Toolkit__c', 
                    'custom:custom34', 
                    t.Name, 
                    t.recordtype.name, 
                    null
                )
            );
        }

        return results;
    }

    @AuraEnabled(Cacheable=false)
    public static List<EUR_DOC_LookupSearchResult> searchSKU(String searchTerm, List<String> selectedIds) {
        List<List<SObject>> searchResults = search.query('FIND {'+String.escapeSingleQuotes(searchterm)+'} IN ALL FIELDS RETURNING EUR_CRM_SKU__c (Id,Name, Recordtype.Name) LIMIT '+MAX_RESULTS);

        List<EUR_DOC_LookupSearchResult> results = new List<EUR_DOC_LookupSearchResult>();
        
        EUR_CRM_SKU__c [] skus = ((List<EUR_CRM_SKU__c>) searchResults[0]);

        for (EUR_CRM_SKU__c s : skus) {
            
            results.add(
                new EUR_DOC_LookupSearchResult(
                    s.id, 
                    'EUR_CRM_SKU__c', 
                    'custom:custom34', 
                    s.Name, 
                    s.recordtype.name, 
                    null
                )
            );
        }

        return results;
    }

    public static String getCountryCode() {
        String whereClause='';
        String pfName = [SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId()].Name;
        System.debug(!pfName.contains('Admin')+' '+!pfName.contains('admin'));
        if (!pfName.contains('Admin') && !pfName.contains('admin')) {
            whereClause = ' WHERE EUR_CRM_Country_Code__c=\''+[SELECT EUR_CRM_Country_Code__c FROM User WHERE Id=:UserInfo.getUserId()].EUR_CRM_Country_Code__c+'\'';
        }
        return whereClause;
    }

    private static void loadFilterTrade() 
    {
        if(mapTrade_values.isEmpty()) {
            for(EUR_DOC_FilterTrade__mdt ft : [SELECT DeveloperName, EUR_DOC_Accepted_Values__c FROM EUR_DOC_FilterTrade__mdt]) 
            {
                for(String sChanValue : ft.EUR_DOC_Accepted_Values__c.split(';')){
                    mapTrade_values.put(sChanValue, ft.DeveloperName);
                }
            }
            System.debug('MapTradeUpdated: ' + mapTrade_values);
        }
    }
}