/*
* Edit 10/23
* Support multiple cocktail names and change on number of cocktails
*/
public with sharing class EUR_CRM_ContractPDFController {
        
    private final String HOUSE_POURING = 'House Pouring Spirits';
    private final String PREMIUM_POURING = 'Premium Pouring Spirits';
    private final String MUST_STOCK = 'Must Stock Item';
    private final String MAY_STOCK = 'May Stock Item';
    private final String CHAMPAGNE = 'House Pouring Champagne';
    private final String MARKETING_SUPPORT = 'Marketing Support';
    private final String RETRO = 'Retro';
    private final String STOCK_DEAL ='Stock_Deal';
    private final String STOCK_ALLOWANCE ='Free Stock';
    private final String POS ='Point of Sales';
    private final String EDUCATION = 'Educations';
    private final String TRIPS = 'Trips';
    private final String COCKTAIL = 'Cocktail'; 
    
    private ApexPages.StandardController standardController;
    
    private EUR_CRM_Contract__c contractHeaderObj {get;set;}
    
    public static String LUMP_SUM {get{ return 'Lump Sum';}}
    public static String PER_BQ {get{return 'Per Brand-Quality';}}
    public String currencyCode {get{return String.valueOf(getCurrencySymbol(contractHeaderObj));}}
    
    public ContractWrapper contractWrapperObj {get;set;}
    
    public String dateFormat{get{
        Date today = Date.valueOf(date.today());
        return string.valueOf(getDateFormat(today));
    }}
    
    public String startDate{get;set;}
    public String endDate{get;set;}
    public Boolean HPShasCocktail {get;set;}
    
    public String totalContractValueStr {get{return totalContractValue.format();}}
    private Set<ContractContentWrapper> totalContractSourceKeySet {get;set;}
    public Decimal totalContractValue {get{
        Decimal total = 0;
        for (ContractContentWrapper tcSourceKey: totalContractSourceKeySet){
            System.debug('TOTAL CONTRACT SUMMARY - ' +tcSourceKey + ': ' + tcSourceKey.total);
            total += Decimal.valueOf(tcSourceKey.totalStr.replaceAll('\\D',''));
        }
        return (total/100).setScale(2);
    }}
    
    public EUR_CRM_ContractPDFController(ApexPages.StandardController standardController){
            this.standardController = standardController;
            
            ContractHeaderWrapper contractHeader = initContractHeader();
            contractHeaderObj = contractHeader.contractObj;
            
            startDate = getDateFormat(Date.valueOf(contractHeaderObj.EUR_CRM_Start_Date__c));
            endDate = getDateFormat(Date.valueOf(contractHeaderObj.EUR_CRM_End_Date__c));
            
            Map<String, ContractContentWrapper> contractContent = new Map<String, ContractContentWrapper>();
            if (contractHeaderObj!=null){
                    contractContent = initContractContent(contractHeaderObj);
            }
            //init Contract Wrapper
            contractWrapperObj = new ContractWrapper();
            //Set Header
            contractWrapperObj.header = contractHeader;
            
            //Set Content
            contractWrapperObj.housePouring = (contractContent.containsKey(HOUSE_POURING))?contractContent.get(HOUSE_POURING): new ContractContentWrapper();
            contractWrapperObj.premiumPouring = (contractContent.containsKey(PREMIUM_POURING))?contractContent.get(PREMIUM_POURING): new ContractContentWrapper();
            contractWrapperObj.mustStock = (contractContent.containsKey(MUST_STOCK))?contractContent.get(MUST_STOCK): new ContractContentWrapper();
            contractWrapperObj.mayStock = (contractContent.containsKey(MAY_STOCK))?contractContent.get(MAY_STOCK): new ContractContentWrapper();
            contractWrapperObj.champagneMechanic = (contractContent.containsKey(CHAMPAGNE))?contractContent.get(CHAMPAGNE): new ContractContentWrapper();
            contractWrapperObj.marketingAllowance = (contractContent.containsKey(MARKETING_SUPPORT))?contractContent.get(MARKETING_SUPPORT): new ContractContentWrapper();
            contractWrapperObj.retroMechanic = (contractContent.containsKey(RETRO))?contractContent.get(RETRO): new ContractContentWrapper();
            contractWrapperObj.stockDeal = (contractContent.containsKey(STOCK_DEAL))?contractContent.get(STOCK_DEAL): new ContractContentWrapper();
            contractWrapperObj.stockAllowance = (contractContent.containsKey(STOCK_ALLOWANCE))?contractContent.get(STOCK_ALLOWANCE): new ContractContentWrapper();
            contractWrapperObj.posMechanic = (contractContent.containsKey(POS))?contractContent.get(POS): new ContractContentWrapper();
            contractWrapperObj.educationMechanic = (contractContent.containsKey(EDUCATION))?contractContent.get(EDUCATION): new ContractContentWrapper();
            contractWrapperObj.trainingMechanic = (contractContent.containsKey(TRIPS))?contractContent.get(TRIPS): new ContractContentWrapper();
    
            //Set contract total souce content
            totalContractSourceKeySet = new Set<ContractContentWrapper>{contractWrapperObj.marketingAllowance, contractWrapperObj.retroMechanic, 
                                                                contractWrapperObj.stockAllowance, 
                                                                contractWrapperObj.posMechanic, contractWrapperObj.educationMechanic, 
                                                                contractWrapperObj.trainingMechanic};
    }
        
        public ContractHeaderWrapper initContractHeader(){
                ContractHeaderWrapper contractHeader;
                //Query Contract, include header, Contact and Account details
                List<EUR_CRM_Contract__c> contractTemp = [SELECT Id, Name,
                                                EUR_CRM_Account__c, EUR_CRM_Account__r.Name, 
                                                EUR_CRM_Contact__c, EUR_CRM_Contact__r.Salutation,
                                                EUR_CRM_Contact__r.FirstName, EUR_CRM_Contact__r.LastName,
                                                EUR_CRM_Contact__r.Name, EUR_CRM_Contact__r.Title,
                                                EUR_CRM_Contact__r.EUR_CRM_Position_of_Contact__c,
                                                EUR_CRM_Contact__r.MailingStreet, EUR_CRM_Contact__r.MailingCity,
                                                EUR_CRM_Contact__r.MailingState, EUR_CRM_Contact__r.MailingCountry,
                                                EUR_CRM_Contact__r.MailingPostalCode,
                                                EUR_CRM_Account__r.EUR_CRM_Street__c, EUR_CRM_Account__r.EUR_CRM_City__c,
                                                EUR_CRM_Account__r.EUR_CRM_Country__c,  EUR_CRM_Account__r.EUR_CRM_County__c, 
                                                EUR_CRM_Account__r.EUR_CRM_Postal_Code__c,
                                                CreatedBy.Name, CreatedBy.Title, CreatedBy.MobilePhone, CreatedBy.Email,
                                                EUR_CRM_Contract_Agreed_Date__c, EUR_CRM_Contract_Approved_Date__c,
                                                EUR_CRM_Contract_Signed_Date__c, //EUR_CRM_Cocktail_Percent__c,
                                                EUR_CRM_End_Date__c, EUR_CRM_Manager_Approved_TCV__c,
                                                EUR_CRM_Marketing_Package_Lump_Sum__c, EUR_CRM_Mktg_Package_Mechanic_Handling__c,
                                                EUR_CRM_Nominated_Supplier__c, EUR_CRM_Nominated_Supplier__r.Name,
                                                EUR_CRM_Payment_Method__c, EUR_CRM_Proposal_Approved_Date__c,
                                                EUR_CRM_Proposal_Date__c, EUR_CRM_Status__c,
                                                EUR_CRM_Start_Date__c, EUR_CRM_Total_Contract_Value__c,
                                                EUR_CRM_Total_Item_Value__c,
                                                EUR_CRM_Contract__c.EUR_CRM_Cocktail_Percent__c 
                                                FROM EUR_CRM_Contract__c
                                                WHERE Id =: this.standardController.getId()
                                                LIMIT 1];
                //Create ContractHeader
                if (contractTemp.size()>0)
                        contractHeader = new ContractHeaderWrapper(contractTemp.get(0));
                
                System.debug('Flag - Contract Header:' + contractHeader);
                return contractHeader;
        }
        
        public Map<String, ContractContentWrapper> initContractContent(EUR_CRM_Contract__c contract){
                Map<String, ContractContentWrapper> contractContent; //Key:System defined, final static strings
                
                Map<String, Map<Id, EUR_CRM_Contract_Mechanic__c>> contractMechanicMap; //Key:Mechanic type Name | CM Key: BQ Id
                Map<Id, Set<EUR_CRM_Contract_Cocktail__c>> cocktailMap = createCocktailMap();
                Map<Id, EUR_CRM_Contract_Line_Item__c> cocktailLineItemMap = createCocktailLineItemMap();
                Set<EUR_CRM_Contract_Cocktail__c> coctailDefault = new Set<EUR_CRM_Contract_Cocktail__c>{
                        new EUR_CRM_Contract_Cocktail__c(EUR_CRM_Cocktail_Menu__r = new EUR_CRM_Cocktail_Menu__c(Name = ''))};

                //Create Map of Contract Line Item from Query
                if (contract!=null){
                        //Init Map
                        contractContent = new Map<String, ContractContentWrapper>{HOUSE_POURING=>new ContractContentWrapper(), PREMIUM_POURING=>new ContractContentWrapper(),
                                                                                                                                        MUST_STOCK=>new ContractContentWrapper(), MAY_STOCK=>new ContractContentWrapper(),
                                                                                                                                        CHAMPAGNE=>new ContractContentWrapper(), MARKETING_SUPPORT=>new ContractContentWrapper(),
                                                                                                                                        RETRO=>new ContractContentWrapper(), STOCK_DEAL=>new ContractContentWrapper(),
                                                                                                                                        STOCK_ALLOWANCE=>new ContractContentWrapper(), POS=>new ContractContentWrapper(),
                                                                                                                                        EDUCATION=>new ContractContentWrapper(), TRIPS=>new ContractContentWrapper()};
                                                                                                                                        
                        for (EUR_CRM_Contract_Line_Item__c contractLineItem : [SELECT Id, Name,
                                                                            EUR_CRM_Available_by_the_Glass__c,
                                                                            EUR_CRM_Brand_Quality__c,
                                                                            EUR_CRM_Brand_Quality_Name_Reference__c,
                                                                            EUR_CRM_Category_Name__c,
                                                                            //EUR_CRM_Cocktail_Name__c,
                                                                            //EUR_CRM_Cocktail_Percent__c,
                                                                            EUR_CRM_Contract__c,
                                                                            EUR_CRM_Contract_Mechanic__c,
                                                                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Name__c,
                                                                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__c,
                                                                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Name,                                                                            
                                                                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Category__c,
                                                                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__c,
                                                                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Name__c,
                                                                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c,
                                                                            EUR_CRM_Process_Option_Lump_Sum__c,
                                                                            EUR_CRM_Mechanic_Type__c,
                                                                            EUR_CRM_Mechanic_Type__r.Name,
                                                                            EUR_CRM_Mechanic_Type_Name__c,
                                                                            EUR_Min_Qty_Per_Annum_9L__c,
                                                                            EUR_CRM_No_of_People__c,
                                                                            EUR_CRM_No_of_Cocktails__c,
                                                                            //EUR_CRM_Number_of_Cocktails__c,
                                                                            EUR_CRM_Retro_Per_9L__c,
                                                                            EUR_CRM_Stock_Deal__c,
                                                                            EUR_CRM_Stock_Deal__r.Name,
                                                                            EUR_CRM_Stock_Deal__r.EUR_CRM_Stock_Deal_Name__c,
                                                                            EUR_CRM_Total_Value__c,
                                                                            EUR_CRM_Value__c
                                                                            FROM EUR_CRM_Contract_Line_Item__c
                                                                            WHERE EUR_CRM_Contract__c =: this.standardController.getId()
                                                                            LIMIT 49999])
                                {
                                System.debug('Flag - Contract Content - Check CLI:' + contractLineItem);
                                
                                contractLineItem.EUR_CRM_Value__c = (contractLineItem.EUR_CRM_Value__c==null)?0:contractLineItem.EUR_CRM_Value__c;
                                
                                //if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(COCKTAIL)){
                                //        cocktailMap.put(contractLineItem.EUR_CRM_Brand_Quality__c, contractLineItem);
                                //}                                                                                                       
                                
                                //Parse to map                                  
                                //Content for House Pouring
                                if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(HOUSE_POURING)){
                                        
                                        System.debug('Flag - Contract Content - Add House Pouring');
                                        //BQ Map Key: EUR_CRM_Brand_Quality__c (Id)
                                        String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                        ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);
                                        
                                        if (cocktailLineItemMap.containsKey(contractLineItem.EUR_CRM_Brand_Quality__c)){
                                                bqMapValue.cocktailLineItemObj = cocktailLineItemMap.get(contractLineItem.EUR_CRM_Brand_Quality__c);
                                                bqMapValue.cocktailRecords.addAll(cocktailMap.containsKey(contractLineItem.EUR_CRM_Brand_Quality__c)? cocktailMap.get(contractLineItem.EUR_CRM_Brand_Quality__c): coctailDefault);
                                                HPShasCocktail = true;
                                        }
                                        Decimal partialOfTotal = contractLineItem.EUR_CRM_Total_Value__c ;
                                        Integer partialOfCount = 1;
                                        
                                        addOnContractContentWrapper(contractContent.get(HOUSE_POURING), 
                                                                                        partialOfTotal, partialOfCount, 
                                                                                        bqMapKey, bqMapValue);
                                        
                                }
                                //Content for Premium Pouring
                                else if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(PREMIUM_POURING)){
                                        
                                        System.debug('Flag - Contract Content - Add Premium Pouring');
                                        //BQ Map Key: EUR_CRM_Brand_Quality__c (Id)
                                        String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                        ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);
                                        
                                        if (cocktailLineItemMap.containsKey(contractLineItem.EUR_CRM_Brand_Quality__c)){
                                                bqMapValue.cocktailLineItemObj = cocktailLineItemMap.get(contractLineItem.EUR_CRM_Brand_Quality__c);
                                                bqMapValue.cocktailRecords.addAll(cocktailMap.containsKey(contractLineItem.EUR_CRM_Brand_Quality__c)? cocktailMap.get(contractLineItem.EUR_CRM_Brand_Quality__c): coctailDefault);
                                        }
                                        Decimal partialOfTotal = contractLineItem.EUR_CRM_Total_Value__c + contractLineItem.EUR_CRM_Value__c;
                                        Integer partialOfCount = 1;
                                        
                                        addOnContractContentWrapper(contractContent.get(PREMIUM_POURING), 
                                                                                        partialOfTotal, partialOfCount, 
                                                                                        bqMapKey, bqMapValue);
                                }
                                //Content for Must Stock
                                else if ((contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(MUST_STOCK))
                                || (contractLineItem.EUR_CRM_Mechanic_Type__r.Name!=null && contractLineItem.EUR_CRM_Mechanic_Type__r.Name.equalsIgnoreCase(MUST_STOCK))){
                                        
                                        System.debug('Flag - Contract Content - Add Must Stock - '+contractLineItem);
                                        if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null){
                                                String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                                ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);
        
                                                Decimal partialOfTotal = contractLineItem.EUR_CRM_Total_Value__c + contractLineItem.EUR_CRM_Value__c;
                                                Integer partialOfCount = 1;
                                                
                                                addOnContractContentWrapper(contractContent.get(MUST_STOCK), 
                                                                                                partialOfTotal, partialOfCount, 
                                                                                                bqMapKey, bqMapValue);
                                        }
                                        else{
                                                contractContent.get(MUST_STOCK).total += contractLineItem.EUR_CRM_Value__c;
                                        }
                                }
                                //Content for May Stock
                                else if ((contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(MAY_STOCK))){
                                    System.debug('Flag - Contract Content - Add May Stock');
                                        if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null){
                                                String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                                ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);
        
                                                Decimal partialOfTotal = 0;//contractLineItem.EUR_CRM_Total_Value__c + contractLineItem.EUR_CRM_Value__c;
                                                Integer partialOfCount = 1;
                                                
                                                addOnContractContentWrapper(contractContent.get(MAY_STOCK), 
                                                                                                partialOfTotal, partialOfCount, 
                                                                                                bqMapKey, bqMapValue);
                                        }
                                }
                                //Content for Champagne
                                else if ((contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(CHAMPAGNE))){
                                        
                                        System.debug('Flag - Contract Content - Add Champagne');
                                        
                                        String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                        ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);
                                        
                                        if (cocktailLineItemMap.containsKey(contractLineItem.EUR_CRM_Brand_Quality__c)){
                                                bqMapValue.cocktailLineItemObj = cocktailLineItemMap.get(contractLineItem.EUR_CRM_Brand_Quality__c);
                                                bqMapValue.cocktailRecords.addAll(cocktailMap.containsKey(contractLineItem.EUR_CRM_Brand_Quality__c)? cocktailMap.get(contractLineItem.EUR_CRM_Brand_Quality__c): coctailDefault);
                                        }
                                        Decimal partialOfTotal = contractLineItem.EUR_CRM_Total_Value__c + contractLineItem.EUR_CRM_Value__c;
                                        Integer partialOfCount = 1;
                                        
                                        addOnContractContentWrapper(contractContent.get(CHAMPAGNE), 
                                                                                        partialOfTotal, partialOfCount, 
                                                                                        bqMapKey, bqMapValue);
                                }
                                
                                //Content for Retro
                                if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && 
                                        (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(HOUSE_POURING)||
                                        contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(PREMIUM_POURING)||
                                        contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(CHAMPAGNE))
                                        && (contractLineItem.EUR_CRM_Retro_Per_9L__c!=null && contractLineItem.EUR_CRM_Retro_Per_9L__c>0)){
                                            
                                        System.debug('Flag - Contract Content - Add Retro');
                                                
                                        String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                        ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);

                                        Decimal partialOfTotal = contractLineItem.EUR_CRM_Total_Value__c + contractLineItem.EUR_CRM_Value__c;
                                        Integer partialOfCount = 1;
                                            addOnContractContentWrapper(contractContent.get(RETRO), 
                                                                                        partialOfTotal, partialOfCount, 
                                                                                        bqMapKey, bqMapValue);
                                        
                                        if(contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(CHAMPAGNE)){
                                            addOnContractContentWrapper(contractContent.get(RETRO), 
                                                                                        partialOfTotal, partialOfCount, 
                                                                                        bqMapKey, bqMapValue, CHAMPAGNE);
                                        }else if(contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(HOUSE_POURING)){
                                            addOnContractContentWrapper(contractContent.get(RETRO), 
                                                                                        partialOfTotal, partialOfCount, 
                                                                                        bqMapKey, bqMapValue, HOUSE_POURING);
                                        } else{
                                            addOnContractContentWrapper(contractContent.get(RETRO), 
                                                                                        partialOfTotal, partialOfCount, 
                                                                                        bqMapKey, bqMapValue, PREMIUM_POURING);
                                        }
                                }
                                //Content for Stock Deal
                                if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && 
                                        (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(HOUSE_POURING)||
                                        contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(PREMIUM_POURING))
                                        && contractLineItem.EUR_CRM_Stock_Deal__c!=null){
                                            
                                        System.debug('Flag - Contract Content - Add Stock Deal');
                                                
                                        String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                        ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);

                                        Decimal partialOfTotal = contractLineItem.EUR_CRM_Total_Value__c;
                                        Integer partialOfCount = 1;
                                        
                                        addOnContractContentWrapper(contractContent.get(STOCK_DEAL), 
                                                                                        partialOfTotal, partialOfCount, 
                                                                                        bqMapKey, bqMapValue);  
                                }
                                                                        
                                //Content for Marketing Support
                                if ((contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(MARKETING_SUPPORT))
                                        || (contractLineItem.EUR_CRM_Mechanic_Type__r.Name!=null && contractLineItem.EUR_CRM_Mechanic_Type__r.Name.equalsIgnoreCase(MARKETING_SUPPORT))){
                                        if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null){
                                                System.debug('Flag - Contract Content - Add Marketing Support');
                                                
                                                String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                                ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);
        
                                                //Decimal partialOfTotal = contractLineItem.EUR_CRM_Total_Value__c + contractLineItem.EUR_CRM_Value__c;
                                                Decimal partialOfTotal = contractLineItem.EUR_CRM_Total_Value__c;
                                                Integer partialOfCount = 1;
                                                
                                                addOnContractContentWrapper(contractContent.get(MARKETING_SUPPORT), 
                                                                                                partialOfTotal, partialOfCount, 
                                                                                                bqMapKey, bqMapValue);  
                                                System.debug('FLAG - CHECK MARKETING SUPPORT: partialOfTotal' + partialOfTotal  );
                                      
                                        }
                                        //else{
                                        //        contractContent.get(MARKETING_SUPPORT).total += contractLineItem.EUR_CRM_Value__c;
                                        //}
                                        
                                        if (contractLineItem.EUR_CRM_Process_Option_Lump_Sum__c){
                                            contractContent.get(MARKETING_SUPPORT).lumpSum = contractLineItem.EUR_CRM_Value__c;
                                        }
                                        
                                        System.debug('FLAG - CHECK MARKETING SUPPORT:' + contractLineItem + '--' + contractContent);
                                        System.debug('FLAG - CHECK MARKETING SUPPORT: contractContent.get(MARKETING_SUPPORT): ' + contractContent.get(MARKETING_SUPPORT)   );

                                }

                                //if Marketing Package is per BQ
                                if (contract.EUR_CRM_Mktg_Package_Mechanic_Handling__c!=null && contract.EUR_CRM_Mktg_Package_Mechanic_Handling__c.equalsIgnoreCase(PER_BQ)){

                                        //Content for Stock Allowance
                                        if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(STOCK_ALLOWANCE)){
                                                System.debug('Flag - Contract Content - Add Stock Allowance');
                                                
                                                String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                                ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);
        
                                                Decimal partialOfTotal = contractLineItem.EUR_CRM_Value__c;
                                                Integer partialOfCount = 1;
                                                
                                                addOnContractContentWrapper(contractContent.get(STOCK_ALLOWANCE), 
                                                                                                partialOfTotal, partialOfCount, 
                                                                                                bqMapKey, bqMapValue);  
                                        }
                                        //Content for POS
                                        if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(POS)){
                                                String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                                ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);
        
                                                Decimal partialOfTotal = contractLineItem.EUR_CRM_Value__c;
                                                Integer partialOfCount = 1;
                                                
                                                addOnContractContentWrapper(contractContent.get(POS), 
                                                                                                partialOfTotal, partialOfCount, 
                                                                                                bqMapKey, bqMapValue);
                                                                                                                    
                                        }
                                        //Content for Education
                                        if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(EDUCATION)){
                                                String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                                ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);
        
                                                Decimal partialOfTotal = contractLineItem.EUR_CRM_Value__c;
                                                Integer partialOfCount = 1;
                                                
                                                addOnContractContentWrapper(contractContent.get(EDUCATION), 
                                                                                                partialOfTotal, partialOfCount, 
                                                                                                bqMapKey, bqMapValue);  
                                        }
                                        //Content for Trips
                                        if (contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c!=null && contractLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c.equalsIgnoreCase(TRIPS)){
                                                String bqMapKey = contractLineItem.EUR_CRM_Brand_Quality__c;
                                                ContentBQWrapper bqMapValue = new ContentBQWrapper(contractLineItem);
        
                                                Decimal partialOfTotal = contractLineItem.EUR_CRM_Value__c;
                                                Integer partialOfCount = 1;
                                                
                                                addOnContractContentWrapper(contractContent.get(TRIPS), 
                                                                                                partialOfTotal, partialOfCount, 
                                                                                                bqMapKey, bqMapValue);  
                                        }       
                                }
                                                                        
                        }
                        //Process Marketing Support - IF LUMP SUM
                        System.debug('Flag - Mktg Mechanic:' + contract.EUR_CRM_Mktg_Package_Mechanic_Handling__c);
                        if ((contract.EUR_CRM_Mktg_Package_Mechanic_Handling__c!=null) && (!contract.EUR_CRM_Mktg_Package_Mechanic_Handling__c.equalsIgnoreCase(PER_BQ))){
                                //Set Total Value of Marketing Support
                                ContractContentWrapper cContentWrapper = contractContent.get(MARKETING_SUPPORT);
                                cContentWrapper.total = contract.EUR_CRM_Marketing_Package_Lump_Sum__c; 
                        }
                        //Process Cocktail
                        ContractContentWrapper housePouringContent = contractContent.get(HOUSE_POURING);
                        ContractContentWrapper premiumPouringContent = contractContent.get(PREMIUM_POURING);
                        for (Id bqId: cocktailMap.keySet()){
                                if (housePouringContent.bqMap.containsKey(String.valueOf(bqId))){
                                        ContentBQWrapper hpBQContent = housePouringContent.bqMap.get(String.valueOf(bqId));
                                        hpBQContent.cocktailLineItemObj = cocktailLineItemMap.get(bqId);
                                        hpBQContent.cocktailRecords.addAll(cocktailMap.get(bqId));

                                }
                                if (premiumPouringContent.bqMap.containsKey(String.valueOf(bqId))){
                                        ContentBQWrapper ppBQContent = premiumPouringContent.bqMap.get(String.valueOf(bqId));
                                        ppBQContent.cocktailLineItemObj = cocktailLineItemMap.get(bqId);
                                        ppBQContent.cocktailRecords.addAll(cocktailMap.get(bqId));

                                }
                        }
                    System.debug('Flag - Contract Content 1:' + contractContent);
                }
                
                System.debug('Flag - Contract Content:' + contractContent);
                return contractContent;
        }
                
        private Map<Id, Set<EUR_CRM_Contract_Cocktail__c>> createCocktailMap (){
            Map<Id, Set<EUR_CRM_Contract_Cocktail__c>> cocktailMap = new Map<Id, Set<EUR_CRM_Contract_Cocktail__c>>();
            
            for (EUR_CRM_Contract_Cocktail__c cc: [SELECT Id, Name,
                                                    EUR_CRM_Cocktail_Menu__c, 
                                                    EUR_CRM_Cocktail_Menu__r.Name,
                                                    EUR_CRM_Contract_Line_Item__c, 
                                                    EUR_CRM_Contract_Line_Item__r.EUR_CRM_No_of_Cocktails__c,
                                                    EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c
                                                    FROM EUR_CRM_Contract_Cocktail__c
                                                    WHERE EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract__c =: this.standardController.getId()
                                                    ORDER BY EUR_CRM_Contract_Line_Item__c, EUR_CRM_Cocktail_Menu__r.Name
                                                    LIMIT 49999]){
                Id key = cc.EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c;
                Set<EUR_CRM_Contract_Cocktail__c> ccSet = cocktailMap.containsKey(key)?cocktailMap.get(key):new Set<EUR_CRM_Contract_Cocktail__c>();
                ccSet.add(cc);
                cocktailMap.put(key, ccSet);
            }
            
            return cocktailMap;
        }
        
        private Map<Id, EUR_CRM_Contract_Line_Item__c> createCocktailLineItemMap (){
            Map<Id, EUR_CRM_Contract_Line_Item__c> cocktailMap = new Map<Id, EUR_CRM_Contract_Line_Item__c>();
            
            for (EUR_CRM_Contract_Line_Item__c cli: [SELECT Id, Name,
                                                    EUR_CRM_Brand_Quality__c,
                                                    EUR_CRM_Brand_Quality_Name_Reference__c,
                                                    //EUR_CRM_Cocktail_Percent__c,
                                                    EUR_CRM_Contract__c,
                                                    EUR_CRM_Contract_Mechanic__c,
                                                    EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Name__c,
                                                    EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Category__c,
                                                    EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__c,
                                                    EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Name__c,
                                                    EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c,
                                                    EUR_CRM_Process_Option_Lump_Sum__c,
                                                    EUR_CRM_Mechanic_Type__c,
                                                    EUR_CRM_Mechanic_Type_Name__c,
                                                    EUR_CRM_No_of_Cocktails__c
                                                    FROM EUR_CRM_Contract_Line_Item__c
                                                    WHERE EUR_CRM_Contract__c =: this.standardController.getId()
                                                    AND EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Type_Name__c =: COCKTAIL
                                                    LIMIT 49999]){
                cocktailMap.put(cli.EUR_CRM_Brand_Quality__c, cli);
            }
            
            return cocktailMap;
        }


        private void addOnContractContentWrapper(ContractContentWrapper contentWrapper, 
                                                                                        Decimal partialOfTotal, Integer partialOfCount, 
                                                                                        String bqMapKey, ContentBQWrapper bqMapValue){
                contentWrapper.total += partialOfTotal;
                contentWrapper.totalCount += partialOfCount;
                contentWrapper.bqMap.put(bqMapKey, bqMapValue);
                
                System.debug('Flag Add Content Wrapper:' + contentWrapper);
        }

        private void addOnContractContentWrapper(ContractContentWrapper contentWrapper, 
                                                                                        Decimal partialOfTotal, Integer partialOfCount, 
                                                                                        String bqMapKey, ContentBQWrapper bqMapValue, String category){
                 

                if(category == HOUSE_POURING){
                    contentWrapper.houseSpiritsMap.put(bqMapKey, bqMapValue);
                }else if(category==CHAMPAGNE){
                    contentWrapper.champagneMap.put(bqMapKey, bqMapValue);
                }else{
                    contentWrapper.premiumSpiritsMap.put(bqMapKey, bqMapValue);

                }
                
                System.debug('Flag Add Content Wrapper:' + contentWrapper);
        }
 
        
        public class ContractWrapper{
                public ContractHeaderWrapper header{get;set;}
                public ContractContentWrapper housePouring {get;set;}
                public ContractContentWrapper premiumPouring {get;set;}
                public ContractContentWrapper mustStock{get;set;}
                public ContractContentWrapper mayStock{get;set;}
                public ContractContentWrapper champagneMechanic {get;set;}
                public ContractContentWrapper marketingAllowance {get;set;} //Marketing Support
                public ContractContentWrapper retroMechanic {get;set;}
                public ContractContentWrapper stockDeal {get;set;}
                public ContractContentWrapper stockAllowance{get;set;}
                public ContractContentWrapper posMechanic {get;set;}
                public ContractContentWrapper educationMechanic{get;set;}
                public ContractContentWrapper trainingMechanic{get;set;}
        }
        
        public class ContractHeaderWrapper{
                public EUR_CRM_Contract__c contractObj {get;set;}
                public Date contractStartDate{get;set;}
                public Date contractEndDate{get;set;}
                
                public String marketingPackageLumpSumStr{get{
                    if (contractObj.EUR_CRM_Marketing_Package_Lump_Sum__c != null){
                        Decimal tValue = contractObj.EUR_CRM_Marketing_Package_Lump_Sum__c.setScale(2)+0.001;
                        String sValue =  String.valueOf(tValue.format());
                        return sValue.substring(0,sValue.length()-1);
                    }
                    return null;
                }}
                
                public ContractHeaderWrapper(EUR_CRM_Contract__c contractObj){
                        this.contractObj = contractObj;
                }
        }
        
        public class ContractContentWrapper{
                //TODO Convert To Field Type
                public Decimal total{get;set;}{total = 0.00;}
                public String totalStr{get{
                    //String s = ( Decimal.valueOf(total==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
                    //return s.substring(0,s.length()-1);
                    Decimal tValue = 0.00 + total.setScale(2) + 0.001;
                    tValue += (lumpSum>0)? lumpSum.setScale(2)+0.001: 0;                    
                    String sValue =  String.valueOf(tValue.format());
                    return sValue.substring(0,sValue.length()-1);
                }}
                public Decimal lumpSum {get;set;}{lumpSum = 0.00;}
                public String lumpSumStr{get{
                    Decimal tValue = lumpSum.setScale(2)+0.001;
                    String sValue =  String.valueOf(tValue.format());
                    return sValue.substring(0,sValue.length()-1);
                }}
                public Map<String, ContentBQWrapper> bqMap{get;set;}{bqMap=new Map<String, ContentBQWrapper>();}
                 public Map<String, ContentBQWrapper> houseSpiritsMap{get;set;}{houseSpiritsMap=new Map<String, ContentBQWrapper>();}
                public Map<String, ContentBQWrapper> premiumSpiritsMap{get;set;}{premiumSpiritsMap=new Map<String, ContentBQWrapper>();}
                public Map<String, ContentBQWrapper> champagneMap{get;set;}{champagneMap=new Map<String, ContentBQWrapper>();}
                public List<ContentBQWrapper> bqList{get{
                    List<ContentBQWrapper> bqValues = bqMap.values();
                    bqValues.sort();
                    return bqValues;
                }} 
                public List<ContentBQWrapper> houseSpiritsList{get{
                    List<ContentBQWrapper> values = houseSpiritsMap.values();
                    values.sort();
                    return values;
                }}
                public List<ContentBQWrapper> premiumSpiritsList{get{
                    List<ContentBQWrapper> values = premiumSpiritsMap.values();
                    values.sort();
                    return values;
                }}
                public List<ContentBQWrapper> champagneList{get{
                    List<ContentBQWrapper> values = champagneMap.values();
                    values.sort();
                    return values;
                }}
                public Integer bqMapSize{get{return bqMap.size();}}
                
                public List<ContentBrandWrapper> brandList{
                    get{
                        Map<String, ContentBrandWrapper> brandMap = new Map<String, ContentBrandWrapper>();
                        
                        for (ContentBQWrapper bqWrap: bqList){
                            String key = bqWrap.contractLineItemObj.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Name;
                            if(brandMap.containsKey(key)){
                                brandMap.get(key).bqList.add(bqWrap);
                            }else{
                                ContentBrandWrapper brandWrap = new ContentBrandWrapper(key);
                                brandWrap.bqList.add(bqWrap);
                                brandMap.put(key, brandWrap);
                            }
                        }
                        
                        List <ContentBrandWrapper> brandWrapList = (brandMap.size()<=0)?new List<ContentBrandWrapper>():brandMap.values();
                        brandWrapList.sort();
                        return brandWrapList;
                    }
                }
                
                public Integer totalCount {get;set;}{totalCount = 0;}
                
                public Boolean isAvailable{get{return (this.total>0 || this.bqMapSize>0?true:false);}}
        }
        
        public class ContentBrandWrapper implements Comparable{
            public String brandName {get;set;}
            public List<ContentBQWrapper> bqList {get;set;}{bqList = new List<ContentBQWrapper>();}
            public Integer bqListSize {get{return bqList.size();}}
            
            public ContentBrandWrapper(String brandName){
                this.brandName = brandName;
            }
            
            public Integer compareTo(Object compareTo){
                ContentBrandWrapper brandWrapper = (ContentBrandWrapper) compareTo;
                if (brandName == brandWrapper.brandName) return 0;
                if (brandName > brandWrapper.brandName) return 1;
                return -1;
            }
        }
        
        public class ContentBQWrapper implements Comparable{
                public Integer compareTo(Object compareTo){
                    ContentBQWrapper bqWrapper = (ContentBQWrapper) compareTo;
                    if(contractLineItemObj.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Name__c == bqWrapper.contractLineItemObj.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Name__c){
                        if(contractLineItemObj.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Name__c == bqWrapper.contractLineItemObj.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Name__c)return 0;
                        if(contractLineItemObj.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Name__c > bqWrapper.contractLineItemObj.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic_Name__c)return 0;
                        return -1;
                    }
                    if(contractLineItemObj.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Name__c > bqWrapper.contractLineItemObj.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Name__c) return 1;
                    return -1;
                }
                public String itemName {get;set;}
                public EUR_CRM_Contract_Line_Item__c contractLineItemObj {get;set;}
                //Cocktail
                public EUR_CRM_Contract_Line_Item__c cocktailLineItemObj {get;set;}
                public Set<String> cocktailNames {get{
                    List<String> cNames = new List<String>();
                    for (EUR_CRM_Contract_Cocktail__c cc : cocktailRecords){
                        cNames.add(cc.EUR_CRM_Cocktail_Menu__r.Name );
                    }
                    cNames.sort();
                    return new Set<String>(cNames);
                }}
                public Set<EUR_CRM_Contract_Cocktail__c> cocktailRecords {get;set;}{cocktailRecords = new Set<EUR_CRM_Contract_Cocktail__c>();}
                public Boolean hasCocktail {get{return (cocktailRecords.size()>0?true:false);}}
                
                public ContentBQWrapper(EUR_CRM_Contract_Line_Item__c contractLineItemObj){
                        this.contractLineItemObj = contractLineItemObj;
                }
        }
        
        private String getCurrencyIsoCode(SObject someObject){
        String currencyIso = UserInfo.isMultiCurrencyOrganization() ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
        return currencyIso;
        }

        private String getCurrencySymbol(SObject someObject) {
            return getCurrencySymbolFromIso(getCurrencyIsoCode(someObject));
        }

        private String getCurrencySymbolFromIso(String Iso) {
             String currencySymbol = 
               ('USD' == Iso ? '$' : 
               ('CAD' == Iso ? '$' : 
               ('EUR' == Iso ? '€' : 
               ('GBP' == Iso ? '£' : 
               ('JPY' == Iso ? '¥' : 
               ('KRW' == Iso ? '₩' : 
               ('CNY' == Iso ? '元' : 
               Iso)))))));
               return currencySymbol;
        }
        
        private String getDateFormat(Date dateField){
            Integer dateDay = dateField.day();
            Integer dateMonth = dateField.month();
            Integer dateYear = dateField.year();
            String sup = '';
            
            if (dateDay == 1 || dateDay == 21 || dateDay ==31){
                sup = 'st';
            }else if (dateDay == 2 || dateDay == 22){
                sup = 'nd';
            }else if (dateDay == 3 || dateDay == 23){
                sup = 'rd';
            }else{
                sup = 'th';
            }
            
            List<String> mNames = new List<String>{'January', 'February', 'March', 'April', 
                                                    'May', 'June', 'July', 'August', 'September', 
                                                    'October', 'November', 'December'};
            
            String dateSup = String.valueOf(dateDay) + '<sup>' + sup + '</sup> ' + mNames[dateMonth - 1] + ', ' + String.valueOf(dateYear);
            
            return dateSup;
        }

}