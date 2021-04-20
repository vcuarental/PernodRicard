/*Filename:    ASI_CRM_TW_PromotionPOSM_Query_Ctrl.cls
* Author:      Twinkle LI (Introv Limited)
* Purpose:     Controller Class for quer POSM for TW CRM
*
* History
* -----------------------------------------------------------------------------
*/
public without sharing class ASI_CRM_TW_PromotionPOSM_Query_Ctrl{
    public List<ASI_CRM_Promotion_POSM__c> listNewPromoPOSM {set;get;}
    public Map<integer, promoPOSM> mapNewPromoPOSM {set;get;}
    
    public List<ASI_MFM_SKU_Code__c> listSKU {set;get;}
    public Map<Integer, id> mapSKU {set;get;}
    public List<ContentDocumentLink> listSKUImage {set;get;}
    public Map<String, ContentDocumentLink> mapSKUImage {set;get;}
    public String userLanguage {set; get;}
    public ASI_CRM_TW_Settings__c customSettingAccId {set; get;}
    public Set<String> setSearchSkuCode {set; get;}
    public Map<String, String> mapSKUSubBrand {set;get;}
    
    //Searching criterias
    public String searchSKU {set;get;}
    public String searchCategory {set;get;}
    public String searchSubBrand {set;get;}
    public String searchRegion {set;get;}
    
    public Set<String> setSKUCategory {set;get;}
    public Set<String> SetSKUSubBrand {set;get;}
    public Set<String> SetSKURegion {set;get;}
    
    public boolean disablePrevious {set;get;}
    public boolean disableNext {set;get;}
    
    public String querySOQL;
    private String sortDirection = 'ASC';
    private String sortExp = 'Name';
    
    //Pagination
    public String recordNumberDisplay {set;get;}//show current no out of total no.
    private Double counter = 0;  //keeps track of the offset
    private Double pageSize = 10; //sets the page size or number of SubBand
    public Double totalSize; //used to show user the total size of the list   
    
    public Integer pageNum {set;get;}
    public Double totalpageNum {set;get;}
    public Integer intTotalpageNum {set;get;}
    public Set<Integer> setPageNum {set;get;}
    
    public Class promoPOSM{
        public ASI_CRM_Promotion_POSM__c posm {get; set;}
        public String skuName {get; set;}
        public String skuImageURL {get; set;}
        public String skuCode {get; set;}
        public String packing {get; set;}
        public String subbrand {get; set;}
        public String region {get; set;}
        public String category {get; set;}
        public String stock {get; set;}
        public String department {get; set;}
    }
    
    public String sortExpression {
        get{return sortExp;}
        set{
            if(value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
            pageNum = 1;
        }
    }
    
    public String getSortDirection(){
        if(sortExpression == null || sortExpression == '')
            return 'ASC'; 
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value){  
        sortDirection = value;
    }
    
    public ASI_CRM_TW_PromotionPOSM_Query_Ctrl() {
        init();
    }
    
    public List<SelectOption> getSearchCategoryOptions() {
        List<SelectOption> searchCategoryOptions = new List<SelectOption>();
        
        searchCategoryOptions.add(new SelectOption('','--None--'));
        for(String category : setSKUCategory){
            searchCategoryOptions.add(new SelectOption(category, category));
        }        
        searchCategoryOptions.sort();
        return searchCategoryOptions;
    }
    
    public List<SelectOption> getSearchSubBrandOptions() {
        List<SelectOption> searchSubBrandOptions = new List<SelectOption>();
        
        searchSubBrandOptions.add(new SelectOption('','--None--'));
        for(String subBrand : setSKUSubBrand){
            searchSubBrandOptions.add(new SelectOption(subBrand, subBrand));
        }         
        searchSubBrandOptions.sort();
        return searchSubBrandOptions;
    }
    
    public List<SelectOption> getSearchRegionOptions() {
        List<SelectOption> searchRegionOptions = new List<SelectOption>();
        
        searchRegionOptions.add(new SelectOption('','--None--'));
        for(String region : setSKURegion){
            searchRegionOptions.add(new SelectOption(region, region));
        }         
        searchRegionOptions.sort();
        return searchRegionOptions;
    }
    
    public void init(){
        searchSKU = '';
        searchCategory = '';
        searchSubBrand = '';
        searchRegion = '';
        String sortFullExp = sortExpression + ' ' + sortDirection;
        Integer intIndexAllPromoPOSM = 0; 
        totalpageNum = 0;
        pageNum = 1;

        listSKUImage = new List<ContentDocumentLink>();
        mapSKUImage = new Map<String, ContentDocumentLink>();
        userLanguage = UserInfo.getLanguage();
        
        setSKUCategory = new Set<String>();
        setSKUSubBrand = new Set<String>();
        setSKURegion = new Set<String>();
        
        listSKU = new List<ASI_MFM_SKU_Code__c>();
        mapSKU = new Map<Integer, id>();
        listNewPromoPOSM = new List<ASI_CRM_Promotion_POSM__c>();
        setSearchSkuCode = new Set<String>();
        mapSKUSubBrand = new Map<String, String>();
        
        Set<String> setSubBrandId = new Set<String>();
        
        customSettingAccId = [SELECT ASI_CRM_TW_POSM_Image_Account_Id__c FROM ASI_CRM_TW_Settings__c];
        
        Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code');
        querySOQL = 'SELECT id, Name, ASI_CRM_Department__c, ASI_CRM_Category__c, ASI_FOC_Packing_Description__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name, ASI_CRM_Region__c, ASI_CRM_TW_Current_Stock__c, ASI_MFM_SKU_Code__c FROM ASI_MFM_SKU_Code__c WHERE RecordTypeId = \'' +RecordTypeId+ '\'' + 
                    ' AND ASI_HK_CRM_IsPOSProduct__c = true AND ASI_CRM_TW_Current_Stock__c != null AND ASI_CRM_TW_Current_Stock__c != 0'; 
                        
        listSKU = Database.query(querySOQL + ' ORDER BY '+ sortFullExp +' LIMIT 2000');        
        totalSize = listSKU.size();
        totalpageNum = math.ceil(totalSize/pageSize);
        intTotalpageNum = Integer.valueof(totalpageNum);

        for(ASI_MFM_SKU_Code__c sku : listSKU){
            mapSKU.put(intIndexAllPromoPOSM++, sku.id);
        }
        
        //Get searching picklists value
        AggregateResult[] listCategory = [SELECT ASI_CRM_Category__c FROM ASI_MFM_SKU_Code__c WHERE RecordTypeId =: RecordTypeId AND ASI_HK_CRM_IsPOSProduct__c = true AND ASI_CRM_TW_Current_Stock__c != null AND ASI_CRM_TW_Current_Stock__c != 0 GROUP BY ASI_CRM_Category__c];
        for(AggregateResult sku : listCategory){
            if(sku.get('ASI_CRM_Category__c') != null)
                setSKUCategory.add(String.valueof(sku.get('ASI_CRM_Category__c')));
        }   
             
        AggregateResult[] listSubBrand = [SELECT ASI_MFM_Sub_brand__c FROM ASI_MFM_SKU_Code__c WHERE RecordTypeId =: RecordTypeId AND ASI_HK_CRM_IsPOSProduct__c = true AND ASI_CRM_TW_Current_Stock__c != null AND ASI_CRM_TW_Current_Stock__c != 0 GROUP BY ASI_MFM_Sub_brand__c];
        for(AggregateResult sku : listSubBrand){
            setSubBrandId.add(String.valueof(sku.get('ASI_MFM_Sub_brand__c')));                
        }  
        List<ASI_MFM_Sub_brand__c> listTempSubBrand = [SELECT Name FROM ASI_MFM_Sub_brand__c WHERE Id IN: setSubBrandId];     
        for(ASI_MFM_Sub_brand__c sb : listTempSubBrand){
            mapSKUSubBrand.put(sb.id, sb.Name);
        }
        for(AggregateResult sku : listSubBrand){
            if(sku.get('ASI_MFM_Sub_brand__c') != null && mapSKUSubBrand.get(String.valueof(sku.get('ASI_MFM_Sub_brand__c'))) != null)
                setSKUSubBrand.add(mapSKUSubBrand.get(String.valueof(sku.get('ASI_MFM_Sub_brand__c'))));
        }
        
        AggregateResult[] listRegion = [SELECT ASI_CRM_Region__c FROM ASI_MFM_SKU_Code__c WHERE RecordTypeId =: RecordTypeId AND ASI_HK_CRM_IsPOSProduct__c = true AND ASI_CRM_TW_Current_Stock__c != null AND ASI_CRM_TW_Current_Stock__c != 0 GROUP BY ASI_CRM_Region__c];
        for(AggregateResult sku : listRegion){
            if(sku.get('ASI_CRM_Region__c') != null)
                setSKURegion.add(String.valueof(sku.get('ASI_CRM_Region__c')));
        } 
        
        searchCurrentPage();
    }
    
    public void search(){
        String sortFullExp = sortExpression + ' ' + sortDirection;
        Integer intIndexAllPromoPOSM = 0; 
        mapSKU = new Map<Integer, id>();
        counter = 0;
        totalpageNum = 0;
        pageNum = 1;
        
        Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code');
        querySOQL = 'SELECT id, Name, ASI_CRM_Department__c, ASI_CRM_Category__c, ASI_FOC_Packing_Description__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name, ASI_CRM_Region__c, ASI_CRM_TW_Current_Stock__c, ASI_MFM_SKU_Code__c FROM ASI_MFM_SKU_Code__c WHERE' +
                    ' RecordTypeId = \'' +RecordTypeId+ '\'' + ' AND ASI_HK_CRM_IsPOSProduct__c = true AND ASI_CRM_TW_Current_Stock__c != null AND ASI_CRM_TW_Current_Stock__c != 0'; 
        if(searchSKU != null && searchSKU != ''){ 
            searchSKU = searchSKU.replaceAll('\'','\\\\\'');
            querySOQL = querySOQL + ' AND Name like \'%' +searchSKU+ '%\'';
        }    
        if(searchCategory != null && searchCategory != ''){        
            searchCategory = searchCategory.replaceAll('\'','\\\\\'');    
            querySOQL = querySOQL + ' AND ASI_CRM_Category__c = \'' +searchCategory+ '\'';
        }
        if(searchSubBrand != null && searchSubBrand != ''){       
            searchSubBrand = searchSubBrand.replaceAll('\'','\\\\\'');     
            querySOQL = querySOQL + ' AND ASI_MFM_Sub_brand__r.Name = \'' +searchSubBrand+ '\'';
        }
        if(searchRegion != null && searchRegion != ''){  
            searchRegion = searchRegion.replaceAll('\'','\\\\\'');     
            querySOQL = querySOQL + ' AND ASI_CRM_Region__c = \'' +searchRegion+ '\'';
        }
        
        listSKU = Database.query(querySOQL + ' ORDER BY '+ sortFullExp +' LIMIT 2000'); 
        totalSize = listSKU.size();
        totalpageNum = math.ceil(totalSize/pageSize);
        intTotalpageNum = Integer.valueof(totalpageNum);
             
        for(ASI_MFM_SKU_Code__c sku : listSKU){
            mapSKU.put(intIndexAllPromoPOSM++, sku.id);
        }         
        searchCurrentPage();
    }  
    
    public void searchCurrentPage(){
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        Integer intIndexNewPromoPOSM = 0;
        mapNewPromoPOSM = new Map<integer, promoPOSM>();
        setPageNum = new Set<Integer>();
        
        disablePrevious = getDisablePrevious();
        disableNext = getDisableNext();
        
        recordNumberDisplay = '(' + String.valueOf(Integer.valueof(counter) + 1)+ ' - ' + String.valueOf(Integer.valueof(Math.min((counter + pageSize), totalSize))) + (userlanguage == 'zh_TW'?' 共 ':' of ') + String.valueOf(Integer.valueof(totalSize)) + ')';   
        
        listSKU = Database.query(querySOQL + ' AND id IN ( ' + getPagnationSKUs() + ') ORDER BY '+ sortFullExp +' LIMIT 2000');
        
        for(ASI_MFM_SKU_Code__c sku : listSKU){
            setSearchSkuCode.add(sku.ASI_MFM_SKU_Code__c);
        } 
        if(!Test.isRunningTest() && customSettingAccId != NULL && setSearchSkuCode.size() > 0){
            listSKUImage = [SELECT Id, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: customSettingAccId.ASI_CRM_TW_POSM_Image_Account_Id__c AND ContentDocument.Title IN:setSearchSkuCode];
        }
        
        for(ContentDocumentLink image : listSKUImage){
            mapSKUImage.put(image.ContentDocument.Title, image);
        }
        
        for(ASI_MFM_SKU_Code__c sku : listSKU){
            String imageURL;
            if(sku.ASI_MFM_SKU_Code__c != NULL && mapSKUImage.get(sku.ASI_MFM_SKU_Code__c) != NULL){
                imageURL = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+mapSKUImage.get(sku.ASI_MFM_SKU_Code__c).ContentDocument.LatestPublishedVersionId;
            }else{
                imageURL = NULL;
            }            
            
            ASI_CRM_Promotion_POSM__c objPOSM = new ASI_CRM_Promotion_POSM__c(RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_POSM__cASI_CRM_TW_PromotionPOSM'), ASI_CRM_SKU__c=sku.id);                
            promoPOSM classPOSM = new promoPOSM();
            classPOSM.posm = objPOSM;
            classPOSM.skuName = sku.Name;
            classPOSM.skuImageURL = imageURL;
            classPOSM.skuCode = sku.ASI_MFM_SKU_Code__c;
            classPOSM.category = sku.ASI_CRM_Category__c;
            classPOSM.department = sku.ASI_CRM_Department__c;
            classPOSM.region = sku.ASI_CRM_Region__c;
            classPOSM.subbrand = sku.ASI_MFM_Sub_brand__r.Name;
            classPOSM.stock = String.valueof(sku.ASI_CRM_TW_Current_Stock__c);
            classPOSM.packing = sku.ASI_FOC_Packing_Description__c;
            
            listNewPromoPOSM.add(objPOSM);
            mapNewPromoPOSM.put(intIndexNewPromoPOSM++, classPOSM);
        } 
        
        //Redirect page setting
        for(Integer i=1; i<=Integer.valueof(totalpageNum); i++){
            setPageNum.add(i);
        }
    }
    
    private String getPagnationSKUs(){
        String skuIdStr = '\'000000000000000\'';
        
        for(Double i = counter;i < Math.min((counter + pageSize), totalSize); i++){
            Integer j = integer.valueof(i);
            if(mapSKU.get(j) != null){
                String skuId = mapSKU.get(j);
                skuIdStr = skuIdStr + ',\'' + skuId + '\'';
            }
        }
        return skuIdStr;
    }
    
    public void reset(){
        searchSKU = '';
        searchCategory = '';
        searchSubBrand = '';
        searchRegion = '';
        sortDirection = 'ASC';
        sortExp = 'Name';
        
        search(); 
    }
    
    public void pageRedirect(){
        if(setPageNum.contains(pageNum)){
            if(Double.valueof(pageNum) != 1)
                counter = (Double.valueof(pageNum)-1)*pageSize;
            else
                counter = 0;
            searchCurrentPage();
        }
        else{
            if(userlanguage == 'zh_TW')
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, '共有'+setPageNum.size()+'頁, 請輸入正確頁數.'));              
            else
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'There are only '+setPageNum.size()+' pages, please enter correct page number.'));
        }
    }
    
    //user clicked beginning
    public PageReference Beginning(){
        pageNum = 1;
        counter = 0;
        searchCurrentPage();
        return null;
    }
    
    //user clicked previous button
    public PageReference Previous(){
        pageNum -= 1;
        counter -= pageSize;
        searchCurrentPage();
        return null;
    }
    
    //user clicked next button
    public PageReference Next(){
        pageNum += 1;
        counter += pageSize;
        searchCurrentPage();
        return null;
    }
    
    //user clicked end  
    public PageReference End(){
        pageNum = intTotalpageNum;
        counter = totalSize - pageSize;    
        searchCurrentPage();
        return null;
    }
    
    //this will disable the previous and beginning buttons
    public Boolean getDisablePrevious(){ 
        if (counter > 0) 
            disablePrevious = false;
        else 
            disablePrevious = true;
        return disablePrevious;
    }
    
    //this will disable the next and end buttons
    public Boolean getDisableNext(){
        if (counter + pageSize < totalSize) 
            disableNext = false; 
        else 
            disableNext = true;
        return disableNext;
    }
}