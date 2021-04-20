public class EUR_CRM_PT_ObjPromoManageController extends EUR_CRM_AbstractSelectionItem{

    public EUR_CRM_ObjPromo__c objPromo {get; set;}
    public Boolean isDraft {get; set;}
    public Boolean isDeactivated {get; set;}
    public Boolean isActive {get; set;}
    public Boolean isAccountSelectionDone {get; set;}
    public Boolean isProductSelectionDone {get; set;}
    public Boolean isManagerLevelTargetDone {get; set;}
    public Boolean isTargetManagementDone {get; set;}
    public String selectedSelectionMethod {get; set;}
    public String selectedProductSelection {get; set;}
    //public String confirmedProductLevel {get; set;}
    public ApexPages.StandardController standardController {get; set;}

    public static Integer ROWS_PER_PAGE = 50;
    public Integer euAccountsPageNum {get; set;}
    public Boolean euAccountsPageHasMore {get; set;}
    public Integer euAccountsFirstIndex {get; set;}
    public Integer totalPages;
    
    //For uploading the csv file
    public Blob contentFile {get; set;}
    public string nameFile {get; set;}
    public integer fileSize {get; set;}
    public string msg {get; set;}

    // Account Management
    private Set<Id> taxonomyIds = new Set<Id>();
    private Set<Id> accountIdsFromOPMapping = new Set<Id>();
    public List<AccountWrapper> euAccounts {get; set;}
    public List<AccountWrapper> pagedEUAccounts {get; set;}
	
    //OP Target
    public Map<Id, EUR_CRM_ObjPromo_Target__c> insertBrandIdTargetMap;
    public List<EUR_CRM_ObjPromo_Target__c> insertopTargetList;
    
    private String notExistBrandExternalId = '';
    private String notExistAccountExternalId = '';
    
    public EUR_CRM_PT_ObjPromoManageController(ApexPages.StandardController sc) {
        this.standardController = sc;
        this.objPromo = [SELECT Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName, EUR_CRM_Status__c,
                         EUR_CRM_Is_Quota__c, EUR_CRM_Is_Publish_ready__c, EUR_CRM_OP_Action_List_Template__c, 
                         EUR_CRM_Active_Start_Date__c, EUR_CRM_Active_End_Date__c
                         FROM EUR_CRM_ObjPromo__c
                         WHERE ID = :ApexPages.currentPage().getParameters().get('objPromoId')];
        this.isDraft = this.objPromo != null && this.objPromo.EUR_CRM_Status__c == 'Draft';
        this.isDeactivated = this.objpromo != null && this.objPromo.EUR_CRM_Status__c == 'Deactivated';
        this.isActive = this.objpromo != null && this.objPromo.EUR_CRM_Status__c == 'Active';
        
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('AttId'))) {
            processCSV(ApexPages.currentPage().getParameters().get('AttId'));
        }
    }
    
	public PageReference uploadCSV() {
        PageReference pageRef = null;
		if(fileSize <= 5242880){ //Fix for 5MB size limit
			if(namefile.toLowerCase().right(3)=='csv'){
				Attachment att = new Attachment(ParentId = objPromo.Id, name = namefile, body=contentFile, ContentType ='text/plain; charset=UTF-8');
                insert att;
                
                msg = 'Upload CSV Completed';
                pageRef = new PageReference('/apex/EUR_CRM_PT_ObjPromoManagePage?ObjPromoId=' + objPromo.Id + '&AttId=' + att.Id); 
                pageRef.setRedirect(true);
			} else {
				msg = 'Error: Please select csv file only!';
			}
		} else {
			msg = 'Error: File too large';
		}
        return pageRef;
	}
	
    public PageReference saveTarget() {
        PageReference pageRef = null;
        if(insertopTargetList != null && insertopTargetList.size() > 0 && String.isBlank(notExistBrandExternalId) && String.isBlank(notExistAccountExternalId)) {
            List<EUR_CRM_ObjPromo_Target__c> deleteOPTargetList = [SELECT Id FROM EUR_CRM_ObjPromo_Target__c WHERE EUR_CRM_ObjPromo__c = :objPromo.Id];
            if(deleteOPTargetList.size() > 0) delete deleteOPTargetList;
            
            insert insertBrandIdTargetMap.values();
            
            for(EUR_CRM_ObjPromo_Target__c insertOPTarget : insertopTargetList) {
                if(insertBrandIdTargetMap.containsKey(insertOPTarget.EUR_CRM_Brand__c)) {
                    Id parentOPTargetId = insertBrandIdTargetMap.get(insertOPTarget.EUR_CRM_Brand__c).Id;
                    insertOPTarget.EUR_CRM_O_P_Target__c = parentOPTargetId;
                }
            }
            
            insert insertopTargetList;
            
            //pageRef = new PageReference('/apex/EUR_CRM_PT_ObjectivePromoPage?ObjPromoId=' + objPromo.Id);
            pageRef = new PageReference('/' + objPromo.Id);
            pageRef.setRedirect(true);
        }
       	return pageRef;
    }
    
    private void processCSV(String attId) {
        Attachment att = [SELECT ParentId, name, body, ContentType FROM Attachment WHERE Id = :attId LIMIT 1];
        
        if(att.name.toLowerCase().right(3)=='csv'){
            Map<String, String> csvFieldNameMap = new Map<String, String>();
            csvFieldNameMap.put('EUR_CRM_Account__c', 'Account External ID');
            csvFieldNameMap.put('EUR_CRM_Brand__c', 'Brand External ID');
            csvFieldNameMap.put('EUR_CRM_Target_No_of_Display__c', 'Target No. of Display');
                    
            List<String> fieldAPINameList = new List<String>();
            fieldAPINameList.add('EUR_CRM_Account__c');
            fieldAPINameList.add('EUR_CRM_Brand__c');
            fieldAPINameList.add('EUR_CRM_Target_No_of_Display__c');
                    
            List<List<String>> parsedCSVList = genResults(att.body);
            List<String> headerList = new List<String>();
                    
            if(parsedCSVList != null && parsedCSVList.size() > 0) {
                headerList = parsedCSVList[0];
                parsedCSVList.remove(0);
                        
                Integer i = 0; 
                        
                Map<String, Integer> fieldPositionMap = new Map<String, Integer>();
                for(String header : headerList) {
                    fieldPositionMap.put(header.toLowerCase(), i);
                    i++;
                }
                        
                List<Map<String, String>> opTargetList = new List<Map<String, String>>();
                for(List<String> parsedCSV : parsedCSVList) {
                    Map<String, String> fieldValueMap = new Map<String, String>();
                    for(String fieldAPIName : fieldAPINameList) {
                        String labelName = csvFieldNameMap.get(fieldAPIName);
                        if(fieldPositionMap.containsKey(labelName.toLowerCase())) {
                            fieldValueMap.put(fieldAPIName, parsedCSV[fieldPositionMap.get(labelName.toLowerCase())]);
                        }
                    }
                    opTargetList.add(fieldValueMap);
                }
                        
                System.debug('Debug Log : ' + opTargetList);
                genSelectedAccountAndTarget(opTargetList);
            }
        }
    }
    
    private void genSelectedAccountAndTarget(List<Map<String, String>> opTargetList) {
		euAccountsPageNum = 0;
        euAccounts = new List<AccountWrapper>();
        
        Set<String> accountExternalIdSet = new Set<String>();
        Set<String> brandExternalIdSet = new Set<String>();
        
        for(Map<String, String> opTarget : opTargetList) {
        	accountExternalIdSet.add(opTarget.get('EUR_CRM_Account__c'));
            brandExternalIdSet.add(opTarget.get('EUR_CRM_Brand__c'));
        }
        
        List<EUR_CRM_Account__c> accountList = [SELECT Id, Name, EUR_CRM_Territory__r.EUR_CRM_Region__r.Name, Owner.Name, EUR_CRM_External_ID__c
                                                FROM EUR_CRM_Account__c 
                                                WHERE EUR_CRM_External_ID__c in :accountExternalIdSet];
        
        List<EUR_CRM_Brand__c> brandList = [SELECT Id, EUR_CRM_External_ID__c
                                            FROM EUR_CRM_Brand__c
                                            WHERE EUR_CRM_External_ID__c in :brandExternalIdSet];
        
        Map<String, EUR_CRM_Brand__c> brandExternalIdMap = new Map<String, EUR_CRM_Brand__c>();
        Map<String, EUR_CRM_Account__c> accountExternalIdMap = new Map<String, EUR_CRM_Account__c>();
      	
        for(EUR_CRM_Account__c acc : accountList) {
            euAccounts.add(new AccountWrapper(acc.Name, acc.EUR_CRM_Territory__r.EUR_CRM_Region__r.Name, acc.owner.Name));
            accountExternalIdMap.put(acc.EUR_CRM_External_ID__c, acc);
        }
        
        for(EUR_CRM_Brand__c brand : brandList) {
            brandExternalIdMap.put(brand.EUR_CRM_External_ID__c, brand);
        }
        
        Id targetPerAccountRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__cEUR_PT_Off_Trade_OP_Target_per_Account');
        Id targetPerBrandRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__cEUR_PT_Off_Trade_OP_Target_per_Brand');
        
        insertopTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
        
        insertBrandIdTargetMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
        Map<Id, Decimal> brandIdTargetNoOfDisplayMap = new Map<Id, Decimal>();
        
        notExistBrandExternalId = '';
    	notExistAccountExternalId = '';
        
        for(Map<String, String> opTarget : opTargetList) {
            Boolean isBrandOrAccountNoExist = false;
            
            if(!brandExternalIdMap.containsKey(opTarget.get('EUR_CRM_Brand__c'))) {
                notExistBrandExternalId += opTarget.get('EUR_CRM_Brand__c') + ',';
                isBrandOrAccountNoExist = true;
            } 
            
            if(!accountExternalIdMap.containsKey(opTarget.get('EUR_CRM_Account__c'))) {
                notExistAccountExternalId += opTarget.get('EUR_CRM_Account__c') + ',';
                isBrandOrAccountNoExist = true;
            }
            
            if(!isBrandOrAccountNoExist) {
                if(!insertBrandIdTargetMap.containsKey(brandExternalIdMap.get(opTarget.get('EUR_CRM_Brand__c')).Id)) {
                    insertBrandIdTargetMap.put(brandExternalIdMap.get(opTarget.get('EUR_CRM_Brand__c')).Id ,
                                               new EUR_CRM_ObjPromo_Target__c(
                                                   EUR_CRM_ObjPromo__c = objPromo.Id, 
                                                   recordTypeId = targetPerBrandRecordTypeId, 
                                                   EUR_CRM_Brand__c = brandExternalIdMap.get(opTarget.get('EUR_CRM_Brand__c')).Id,
                                                   EUR_CRM_Actual_No_of_Display_per_Brand__c = 0
                                                   )
                                               );
                }
                insertopTargetList.add(new EUR_CRM_ObjPromo_Target__c(
                                                EUR_CRM_ObjPromo__c = objPromo.Id, 
                                                recordTypeId = targetPerAccountRecordTypeId, 
                                                EUR_CRM_Brand__c = brandExternalIdMap.get(opTarget.get('EUR_CRM_Brand__c')).Id,
                                                EUR_CRM_Account__c = accountExternalIdMap.get(opTarget.get('EUR_CRM_Account__c')).Id,
                                                EUR_CRM_Target_No_of_Display__c = Decimal.valueOf(opTarget.get('EUR_CRM_Target_No_of_Display__c')),
                                                EUR_CRM_Actual_No_of_Display__c = 0
                                           )
                                      );
                Decimal targetNoOfDisplay = 0;
                if(brandIdTargetNoOfDisplayMap.containsKey(brandExternalIdMap.get(opTarget.get('EUR_CRM_Brand__c')).Id)) {
                    targetNoOfDisplay = brandIdTargetNoOfDisplayMap.get(brandExternalIdMap.get(opTarget.get('EUR_CRM_Brand__c')).Id);
                }
                targetNoOfDisplay += Decimal.valueOf(opTarget.get('EUR_CRM_Target_No_of_Display__c'));
                brandIdTargetNoOfDisplayMap.put(brandExternalIdMap.get(opTarget.get('EUR_CRM_Brand__c')).Id, targetNoOfDisplay);
            }
            
        }
        
        for(Id brandId : brandIdTargetNoOfDisplayMap.keySet()) {
            insertBrandIdTargetMap.get(brandId).EUR_CRM_Target_No_of_Display_per_Brand__c = brandIdTargetNoOfDisplayMap.get(brandId);
        }
        
        if(euAccounts.size() > 0) {
            this.isAccountSelectionDone = true;
        } else {
            this.isAccountSelectionDone = false;
        }
        if(String.isNotBlank(notExistBrandExternalId)) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Brand External Id not exist [' + notExistBrandExternalId.removeEnd(',') + ']'));
        } else if(String.isNotBlank(notExistAccountExternalId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account External Id not exist [' + notExistAccountExternalId.removeEnd(',') + ']'));
        }
        
        getPagedEUAccounts();
    }
    
	private List<List<String>> genResults(blob contentFile) {
        List<List<String>> parsedCSV = new List<List<String>>();
        if (contentFile != null){
            String fileString = contentFile.toString();
            parsedCSV = parseCSV(fileString, false);
        }
        return parsedCSV;
    }
    
    private static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        
        contents = contents.replaceAll('""','DBLQT');
        contents = contents.replaceAll('\r\n','\r');
        contents = contents.replaceAll('\n','\r');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try{
            //lines = contents.split('\n'); //correction: this only accomodates windows files
            lines = contents.split('\r'); // using carriage return accomodates windows, unix, and mac files
            //http://www.maxi-pedia.com/Line+termination+line+feed+versus+carriage+return+0d0a
        }catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line: lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field: fields) {
                
                if (field.startsWith('"') && field.endsWith('"') && field.length()>1) {
                    cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
                } else if (field.startsWith('"')  && !makeCompositeField) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"') && makeCompositeField) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('"','').replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                    system.debug('composite field2:'+compositeField.replaceAll('"','').replaceAll('DBLQT','"'));
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('"','').replaceAll('DBLQT','"'));
                }
            }
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    }
	
    public void getPagedEUAccounts() {
        pagedEUAccounts = new List<AccountWrapper>();

        euAccountsFirstIndex = euAccountsPageNum * ROWS_PER_PAGE;
        euAccountsPageHasMore = (1 + euAccountsPageNum) < getTotalPages();

        for(Integer i = euAccountsFirstIndex; i < euAccountsFirstIndex + ROWS_PER_PAGE && euAccounts.size() > i; i++) {
            pagedEUAccounts.add(euAccounts.get(i));
        }
    }

    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the first one
    *****************************************************************/
    public void firstPage(){
        euAccountsPageNum = 0;
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the last one
    *****************************************************************/
    public void lastPage(){
        euAccountsPageNum = getTotalPages() - 1;
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the next one in order
    *****************************************************************/    
    public void nextPage(){
        Math.min(euAccountsPageNum++, getTotalPages());
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   Sets the current page in the Accured Achievements to the previous one in order
    *****************************************************************/  
    public void previousPage(){
        Math.max(euAccountsPageNum--, 0);
        getPagedEUAccounts();
    }
    /*****************************************************************
    *   calculates the total number of pages needed to display the full amount of data in the alleuAccounts list
    *   returns: and Integer number of maximum number of pages needed
    *****************************************************************/  
    public Integer getTotalPages(){
       if(System.Math.mod(euAccounts.size(), ROWS_PER_PAGE ) == 0)
          return euAccounts.size() / ROWS_PER_PAGE ;
       else
          return (euAccounts.size() / ROWS_PER_PAGE ) + 1;
    }
    
    public override void add(){
    }
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + objPromo.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
	
    public class AccountWrapper {
        public String accountName {get; set;}
        public String regionName {get; set;}
        public String accountOwner {get; set;}
        
        public AccountWrapper(String accountName, String regionName, String accountOwner) {
            this.accountName = accountName;
            this.regionName = regionName;
            this.accountOwner = accountOwner;
        }
        
    }
    
}