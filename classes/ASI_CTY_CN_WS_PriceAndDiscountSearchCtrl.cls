public without sharing class ASI_CTY_CN_WS_PriceAndDiscountSearchCtrl {
    //
    public List<ASI_CRM_Price_And_Discount_Detail__c> discountResults{get; set;}
    public ASI_CRM_Item_Group_Customer_Price__c searchPrice {get;set;}
    public ASI_CRM_AccountsAdditionalField__c searchCustomer {get;set;}
    public ASI_CRM_Price_And_Discount__c searchDiscount {get;set;}
    public ASI_CTY_CN_WS_Utils.WSPriceWrap priceWrap {get;set;}
    public List<SelectOption> customerTypes { get; set; }
    public List<SelectOption> discountTypes { get; set; }
    public List<SelectOption> pdStatus { get; set; }
    public List<SelectOption> isImports { get; set; }
    public Boolean showPrice { get; set; }
    public String selectCustomerType { get; set; }
    public String selectDiscountType { get; set; }
    public String selectStatus { get; set; }
    public String selectIsImport { get; set; }
    public String jdeCustomerCode { get; set; }
    public String inputRegion { get; set; }
    public String discountSearchListJson {get {return System.JSON.serialize(discountResults);}}
    public ApexPages.StandardSetController con {get; set;}
    public Boolean hasNext {get {return con.getHasNext();}set;}
    public Boolean hasPrevious {get {return con.getHasPrevious();}set;}
    public Integer pageNumber {get {return con.getPageNumber();}set;}

    public void first() {
        con.first();
    }

    public void last() {
        con.last();
    }

    public void previous() {
        con.previous();
    }

    public void next() {
        con.next();
    }

    public ASI_CTY_CN_WS_PriceAndDiscountSearchCtrl(){
        searchPrice = new ASI_CRM_Item_Group_Customer_Price__c();
        searchCustomer = new ASI_CRM_AccountsAdditionalField__c();
        searchDiscount = new ASI_CRM_Price_And_Discount__c();
        searchDiscount.ASI_CRM_Status__c = null;
        discountResults = new List<ASI_CRM_Price_And_Discount_Detail__c>();
        priceWrap = new ASI_CTY_CN_WS_Utils.WSPriceWrap();
        initCustomerTypes();
        initDiscountTypes();
        //initPdStatus();
        initIsImport();
        showPrice = false;
        jdeCustomerCode = '';
        inputRegion = '';
        this.con = new ApexPages.StandardSetController(discountResults);
        this.con.setPageNumber(1);
    }

    public List<ASI_CRM_Price_And_Discount_Detail__c> getSearchResults(){
        discountResults = (List<ASI_CRM_Price_And_Discount_Detail__c>)this.con.getRecords().deepclone(true, true, true);
        return discountResults;
    }


    public void search() {
        String customerId = searchPrice.ASI_CRM_Customer__c;
        String itemGroupId = searchPrice.ASI_CRM_Item_Group__c;
        String commercialTeam = searchCustomer.ASI_CRM_CN_Commercial_Team__c;
        String channel = searchCustomer.ASI_CRM_Channel__c;
        Date effFrom = searchDiscount.ASI_CRM_Effective_From__c;
        Date effTo = searchPrice.ASI_CRM_Effective_Date_To__c;
        String disStatus = searchDiscount.ASI_CRM_Status__c;
        showPrice = false;

        String query = 'SELECT Id, ASI_CRM_Price_And_Discount__c, ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c' + 
                      ', ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer_Region__c, ASI_CRM_Price_And_Discount__r.ASI_CTY_CN_WS_Customer_Type__c' + 
                      ', ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__r.Name, ASI_CRM_Price_And_Discount__r.Name' + 
                      ', ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_Item_Group_Description__r.ASI_MFM_Item_Group_Code__c' + 
                      ', ASI_CRM_Price_And_Discount__r.RecordType.DeveloperName, ASI_CRM_Price_And_Discount__r.ASI_CRM_JDE_Code__c' + 
                      ', ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__r.Name, ASI_CRM_Item_Group_Description__c, ASI_CRM_Item_Group_Description__r.Name ' + 
                      ', ASI_CTY_CN_WS_Level1_Promotion_Code__c, ASI_CTY_CN_WS_Level1_Promotion_Code__r.Name, ASI_CTY_CN_WS_Level2_Promotion_Code__c' + 
                      ', ASI_CTY_CN_WS_Promotion_Type__c , ASI_CTY_CN_WS_Disount_Value__c, ASI_CRM_Promotion_Code__c, ASI_CRM_Promotion_Code__r.Name' + 
                      ', ASI_CRM_Promotion_Code__r.ASI_CRM_Discount__c, ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c, ASI_CRM_Price_And_Discount__r.ASI_CRM_Status__c' + 
                      ', ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c, ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c, ASI_CTY_CN_WS_GL_Offset_AC_Code__c' + 
                      ', ASI_CRM_Price_And_Discount__r.ASI_CRM_Remark__c, ASI_CRM_New_Price_BT_with_VAT__c, ASI_CRM_Price_And_Discount__r.ASI_CTY_CN_WS_Is_Import__c ' + 
                      ' FROM ASI_CRM_Price_And_Discount_Detail__c ' + 
                      ' WHERE ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c != null ';

        if (String.isNotBlank(customerId)) {
            query += ' AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c = \'' + customerId + '\'';
        } 
       
        if (String.isNotBlank(itemGroupId)) {
            query += ' AND ASI_CRM_Item_Group_Description__c = \'' + itemGroupId + '\'';
        }

        if (String.isNotBlank(inputRegion)) {
            query += ' AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer_Region__c LIKE \'%' + inputRegion + '%\'';
        }

        if (String.isNotBlank(channel)) {
            query += ' AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__c = \'' + channel + '\'';
        }

        if (String.isNotBlank(jdeCustomerCode)) {
            query += ' AND ASI_CRM_Price_And_Discount__r.ASI_CRM_JDE_Code__c LIKE \'%' + jdeCustomerCode + '%\'';
        }

        if (String.isNotBlank(selectCustomerType)) {
            query += ' AND ASI_CRM_Price_And_Discount__r.ASI_CTY_CN_WS_Customer_Type__c = \'' + selectCustomerType + '\'';
        }

        if (String.isNotBlank(selectDiscountType)) {
            query += ' AND ASI_CTY_CN_WS_Promotion_Type__c = \'' + selectDiscountType + '\'';
        }

        if (String.isNotBlank(commercialTeam)) {
            query += ' AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c = \'' + commercialTeam + '\'';
        }

        if (effFrom != null) {
            query += ' AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c >= :effFrom';
        }

        if (effTo != null) {
            query += ' AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c >= :effTo';
        }

        if (String.isNotBlank(disStatus)) {
            query += ' AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Status__c = \'' + disStatus + '\'';
        }

        if (String.isNotBlank(selectIsImport)) {
            Boolean isImport = Boolean.valueOf(selectIsImport);
            query += ' AND ASI_CRM_Price_And_Discount__r.ASI_CTY_CN_WS_Is_Import__c = :isImport';
        }
        query += ' Order by ASI_CRM_Price_And_Discount__r.CreatedDate DESC LIMIT 3000';
        System.debug(LoggingLevel.INFO, '*** query: ' + query);
        this.con = new ApexPages.StandardSetController(Database.query(query));
        this.con.setPageNumber(1);
        this.con.setPageSize(20);

        if (String.isNotBlank(customerId) && String.isNotBlank(itemGroupId)) {
            //get discount price
            Map<Id, ASI_CTY_CN_WS_Utils.WSPriceWrap> priceReusltMap= ASI_CTY_CN_WS_Utils.calculateWSPriceInfo(Id.valueOf(customerId), new Set<Id>{Id.valueOf(itemGroupId)});
            priceWrap = priceReusltMap.get(Id.valueOf(itemGroupId));
            System.debug(LoggingLevel.INFO, '*** priceWrap: ' + priceWrap);
            if (priceWrap != null) {
                showPrice = true;
            }
        }
        System.debug(LoggingLevel.INFO, '*** showPrice: ' + showPrice);
    }

    private void initCustomerTypes(){
        selectCustomerType = '';
        customerTypes = new List<SelectOption>();
        customerTypes.add(new SelectOption('', ASI_CTY_CN_WS_Utils.SELECT_NONE));
        customerTypes.add(new SelectOption(ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_WS, ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_WS));
        customerTypes.add(new SelectOption(ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_OUTLET, ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_OUTLET));
    }

    private void initDiscountTypes(){
        selectDiscountType = '';
        discountTypes = new List<SelectOption>();
        discountTypes.add(new SelectOption('', ASI_CTY_CN_WS_Utils.SELECT_NONE));
        discountTypes.add(new SelectOption(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_PRICE, ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_PRICE));
        discountTypes.add(new SelectOption(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P, ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P));
        discountTypes.add(new SelectOption(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL, ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL));
        discountTypes.add(new SelectOption(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD, ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD));    
    }

    private void initIsImport(){
        selectIsImport = '';
        isImports = new List<SelectOption>();
        isImports.add(new SelectOption('', ASI_CTY_CN_WS_Utils.SELECT_NONE));
        isImports.add(new SelectOption('true', 'YES'));
        isImports.add(new SelectOption('false', 'NO'));
    }
}