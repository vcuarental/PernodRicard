/**
 * Created by Ilarion Tokarskyi on 26.11.2020.
 */

public with sharing class EUR_CRM_RecommendedProductsService {
    private static final String INVALID_BODY_FORMAT = 'The message has an invalid format.';
    private static final String DML_ERROR = 'Unexpected internal server error.';
    private static String invalid_Body_Ids = 'The following resource(s) were not found: ';
    private static String success_Body_Acc = 'Account(s) Successfully Updated:\n';
    private static String success_Body_Products = 'Recommended Product(s) Successfully Created or Updated:\n';
    private RecommendedProductsParser parser;
    private Set<String> accIds = new Set<String>();
    private Set<String> productIds = new Set<String>();
    private Set<Id> recProdUpsertIds = new Set<Id>();
    private List<Account> validAccountsWithProducts = new List<EUR_CRM_RecommendedProductsService.Account>();
    private List<EUR_CRM_Account__c> accToUpdate = new List<EUR_CRM_Account__c>();
    private List<EUR_CRM_Recommended_Product__c> recommendedProductsToUpsert = new List<EUR_CRM_Recommended_Product__c>();

    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public Boolean isInvalidBody(String jsonString) {
        Boolean notValidBody = false;
        try {
            this.parser = (RecommendedProductsParser) JSON.deserialize(jsonString, RecommendedProductsParser.class);
        } catch (Exception ex) {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(INVALID_BODY_FORMAT);
            System.debug(INVALID_BODY_FORMAT);
            return true;
        }

        this.setupIdSets(parser.accounts);

        if (isInvalidAccIds()) {
            RestContext.response.statusCode = 404;
            invalid_Body_Ids += '\nAccount Id(s): ' + accIds.toString();
            notValidBody = true;
        }
        if (isInvalidProductIds()) {
            RestContext.response.statusCode = 404;
            invalid_Body_Ids += '\nProduct Id(s): ' + productIds.toString();
            notValidBody = true;
        }
        if (notValidBody) {
            RestContext.response.responseBody = Blob.valueOf(invalid_Body_Ids);
            System.debug(invalid_Body_Ids);
        } else {
            validAccountsWithProducts = parser.accounts;
        }
        return notValidBody;
    }

    public void updateAccountsAndUpsertRecProducts() {
        System.debug('\n validAccountsWithProducts.size() => ' + validAccountsWithProducts.size() + '\n');
        System.debug('\n validAccountsWithProducts => ' + JSON.serializePretty(validAccountsWithProducts) + '\n');

        Map<Id, List<EUR_CRM_Recommended_Product__c>> recProdsByAccIdMap = this.getProductsByAccIdMap(accIds);
        for (Account account : validAccountsWithProducts) {
            accToUpdate.add(createAccountFromParserClass(account));
            for (Product_Recommendation productRecom : account.Products) {
                Id existProdId;
                if (recProdsByAccIdMap.containsKey(account.Id)) {
                    for (EUR_CRM_Recommended_Product__c recProd: recProdsByAccIdMap.get(account.Id)) {
                        if (productRecom.Id == recProd.EUR_CRM_Brand__c) {
                            recommendedProductsToUpsert.add(new EUR_CRM_Recommended_Product__c(Id = recProd.Id,
                                    EUR_CRM_Last_Version__c = false));
                        }
                    }
                }
                recommendedProductsToUpsert.add(createRecProductFromParserClass(productRecom, account.Id, existProdId));
            }
        }
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('\n recommendedProductsToInsert.size() => ' + recommendedProductsToUpsert.size() + '\n');
            System.debug('\n recommendedProductsToInsert => ' + JSON.serializePretty(recommendedProductsToUpsert) + '\n');
            upsert recommendedProductsToUpsert;
            this.configureIdSet(recommendedProductsToUpsert, recProdUpsertIds);

            System.debug('\n accToUpdate.size() => ' + accToUpdate.size() + '\n');
            System.debug('\n accToUpdate => ' + JSON.serializePretty(accToUpdate) + '\n');
            update accToUpdate;

            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(success_Body_Acc + accIds.toString() + '\n' +
                    success_Body_Products + recProdUpsertIds.toString());
        } catch (DmlException ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, 'Rollbacked');
            Database.rollback(sp);
            RestContext.response.responseBody = Blob.valueOf(DML_ERROR);
            RestContext.response.statusCode = 500;
        }

    }
    /* ========================================================= */
    /*     High-level Helpers
    /* ========================================================= */
    private Map<Id, List<EUR_CRM_Recommended_Product__c>> getProductsByAccIdMap(Set<String> accIds) {
        Map<Id, List<EUR_CRM_Recommended_Product__c>> result = new Map<Id, List<EUR_CRM_Recommended_Product__c>>();
        List<EUR_CRM_Recommended_Product__c> recProducts = this.getRecProdsByAccId(accIds);
        for (EUR_CRM_Recommended_Product__c recProduct: recProducts) {
            if (result.containsKey(recProduct.EUR_CRM_Account__c)) {
                result.get(recProduct.EUR_CRM_Account__c).add(recProduct);
            } else {
                result.put(recProduct.EUR_CRM_Account__c, new List<EUR_CRM_Recommended_Product__c>{recProduct});
            }
        }
        return result;
    }
    /* ========================================================= */
    /*     Low-level Helpers
    /* ========================================================= */
    private void setupIdSets(List<EUR_CRM_RecommendedProductsService.Account> accounts) {
        for (EUR_CRM_RecommendedProductsService.Account account : accounts) {
            accIds.add(account.Id);
            if (!account.Products.isEmpty()) {
                for (Product_Recommendation pr : account.Products) {
                    productIds.add(pr.Id);
                }
            }
        }
    }

    private Boolean isInvalidAccIds() {
        List<EUR_CRM_Account__c> accounts = this.getAccountsById(this.accIds);
        if (accounts.size() != accIds.size()) {
            for (EUR_CRM_Account__c account : accounts) {
                accIds.remove(account.Id);
            }
            return true;
        }
        return false;
    }

    private Boolean isInvalidProductIds() {
        List<EUR_CRM_Brand__C> products = this.getBrandsById(productIds);
        if (products.size() != productIds.size()) {
            for (EUR_CRM_Brand__C product : products) {
                productIds.remove(product.Id);
            }
            return true;
        }
        return false;
    }

    private void configureIdSet(List<SObject> records, Set<Id> toFill) {
        for (SObject record: records) {
            toFill.add(record.Id);
        }
    }

    /* ========================================================= */
    /*     Сreators
    /* ========================================================= */
    private EUR_CRM_Account__c createAccountFromParserClass(Account account) {
        return new EUR_CRM_Account__c(
                Id = account.Id,
                EUR_CRM_Financial_Info__c = account.FinancialCategory,
                EUR_CRM_Environment_Info__c = account.EnvironmentType,
                EUR_CRM_Physical_Info__c = account.PhysicalInfo,
                EUR_CRM_Store_Size__c = account.StoreSize,
                EUR_CRM_Sell_Out_Potential_Food__c = account.SellOutPotentialFood,
                EUR_CRM_Food_Ratio__c = account.FoodRatio,
                EUR_CRM_Annual_Visit_Target__c = account.AnnualTarget,
                EUR_CRM_Visit_Target_Today__c = account.VisitTargetToday,
                EUR_CRM_Current_Visit_Number__c = account.CurrentVisitNumber,
                EUR_CRM_Last_Facings_Number__c = account.LastFacingsNumber,
                EUR_CRM_Dropshipping_Status__c = account.DropshippingStatus
        );
    }

    private EUR_CRM_Recommended_Product__c createRecProductFromParserClass(Product_Recommendation prodRec, Id accId,
            Id existRecProd) {
        return new EUR_CRM_Recommended_Product__c (
                EUR_CRM_Account__c = accId,
                EUR_CRM_Brand__C = prodRec.Id,
                EUR_CRM_Rank__c = prodRec.Rank,
                EUR_CRM_PR_Category_Rank__c = prodRec.CategoryRankPR,
                EUR_CRM_All_Category_Rank__c = prodRec.CategoryRankAll,
                EUR_CRM_Region_Rank__c = prodRec.RankRegion,
                EUR_CRM_Presence__c = prodRec.Presence,
                EUR_CRM_Average_Facings__c = prodRec.AverageFacings,
                EUR_CRM_Is_HOB__c = prodRec.IsHouseOfBrands,
                Id = existRecProd,
                EUR_CRM_Product_Dropshipping_Status__c = prodRec.ProductDropshippingStatus,
                EUR_CRM_Last_Version__c = true
        );
    }
    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Account__c> getAccountsById(Set<String> accIds) {
        return [
                SELECT Id
                FROM EUR_CRM_Account__c
                WHERE Id IN :accIds
        ];
    }

    private List<EUR_CRM_Brand__C> getBrandsById(Set<String> prodIds) {
        return [
                SELECT Id
                FROM EUR_CRM_Brand__C
                WHERE Id IN :prodIds
        ];
    }

    private List<EUR_CRM_Recommended_Product__c> getRecProdsByAccId(Set<String> accIds) {
        return [
                SELECT Id,
                        EUR_CRM_Account__c,
                        EUR_CRM_Brand__c,
                        EUR_CRM_Confirmation__c
                FROM EUR_CRM_Recommended_Product__c
                WHERE EUR_CRM_Account__c IN :accIds
        ];
    }
    /* ========================================================= */
    /*     Inner Parser Classes
    /* ========================================================= */
    public class Product_Recommendation {
        public String Id;
        public Integer Rank;
        public Integer CategoryRankPR;
        public Integer CategoryRankAll;
        public Integer RankRegion;
        public Double Presence;
        public Integer AverageFacings;
        public Boolean IsHouseOfBrands;
        public String ProductDropshippingStatus;
    }

    public class Account {
        public String Id;
        public String Affiliate;
        public String FinancialCategory;
        public String EnvironmentType;
        public String PhysicalInfo;
        public Integer StoreSize;
        public Double SellOutPotentialFood;
        public Double FoodRatio;
        public Integer AnnualTarget;
        public Double VisitTargetToday;
        public Integer CurrentVisitNumber;
        public Integer LastFacingsNumber;
        public String DropshippingStatus;
        public List<Product_recommendation> Products;
    }

    public class RecommendedProductsParser {
        public List<Account> accounts;
    }
}