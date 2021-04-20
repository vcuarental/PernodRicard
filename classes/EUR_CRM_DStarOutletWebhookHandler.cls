/**
 * Created by Ilarion Tokarskyi on 22.12.2020.
 */

public with sharing class EUR_CRM_DStarOutletWebhookHandler implements EUR_CRM_IWebhookHandler {

    public void handleWebhook() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:EUR_CRM_DStarOutletAPI');
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setMethod('GET');
        HttpResponse response = new Http().send(req);
        List<InnerParser> parsedBody;
        try {
            parsedBody = (List<InnerParser>) JSON.deserialize(response.getBody(), List<InnerParser>.class);
            System.debug('response.getBody ==> ' + response.getBody());
            System.debug('parsed Body ==> ' + parsedBody);
        } catch (Exception ex) {
            System.debug('Parsing Error - EUR_CRM_DStarOutletWebhookHandler\n');
            System.debug('response.getBody ==> ' + response.getBody());
            System.debug(ex.getMessage());
            EUR_CRM_WebhookREST_Service.sendEmailNotification('EUR_CRM_DStarOutletWebhookHandler Error', 'Cant parse ' +
                    'response body: \n' + response.getBody());
            return;
        }
        EUR_CRM_RecommendedProductsService.RecommendedProductsParser toProcessed = new EUR_CRM_RecommendedProductsService.RecommendedProductsParser();
        toProcessed.accounts = new List<EUR_CRM_RecommendedProductsService.Account>();

        for (InnerParser account : parsedBody) {
            toProcessed.accounts.add(createAccountForParser(account.outlet, account.outletKpiLocalData.segmentation));
        }

        EUR_CRM_RecommendedProductsService service = new EUR_CRM_RecommendedProductsService();
        if (service.isInvalidBody(JSON.serialize(toProcessed))) return;
        service.updateAccountsAndUpsertRecProducts();
    }

    private EUR_CRM_RecommendedProductsService.Account createAccountForParser(Outlet outlet, Segmentation segmentation) {
        EUR_CRM_RecommendedProductsService.Account result = new EUR_CRM_RecommendedProductsService.Account();
        result.Id = outlet.outletExternalId;
        result.Affiliate = 'DE';
        result.FinancialCategory = segmentation.financialCategory;
        result.EnvironmentType = segmentation.environmentType;
        result.PhysicalInfo = segmentation.physicalInfo;
        result.StoreSize = segmentation.storeSize;
        result.SellOutPotentialFood = segmentation.sellOutPotentialFood;
        result.FoodRatio = segmentation.foodRatio;
        result.AnnualTarget = segmentation.annualTarget;
        result.VisitTargetToday = segmentation.currentVisitTarget;
        result.CurrentVisitNumber = segmentation.currentVisitNumber;
        result.LastFacingsNumber = segmentation.lastFacingNumber;
        result.DropshippingStatus = segmentation.dropshippingStatus;
        result.Products = new List<EUR_CRM_RecommendedProductsService.Product_Recommendation>();
        for (OutletAssortments outletAssortment : outlet.outletAssortments) {
            result.Products.add(createProductForParser(outletAssortment, outletAssortment.product.productExternalId));
        }
        return result;
    }

    private EUR_CRM_RecommendedProductsService.Product_Recommendation createProductForParser(OutletAssortments
            outletAssortments, String productExternalId) {
        EUR_CRM_RecommendedProductsService.Product_Recommendation result = new EUR_CRM_RecommendedProductsService.Product_Recommendation();
        result.Id = productExternalId;
        result.Rank = outletAssortments.rank;
        result.CategoryRankPR = outletAssortments.outletAssortmentLocalData.categoryRankPr;
        result.CategoryRankAll = outletAssortments.outletAssortmentLocalData.categoryRank;
        result.RankRegion = outletAssortments.outletAssortmentLocalData.stateRank;
        result.Presence = outletAssortments.outletAssortmentLocalData.presenceInSimilarStores;
        result.AverageFacings = outletAssortments.outletAssortmentLocalData.averageNumberOfFacings;
        result.IsHouseOfBrands = outletAssortments.outletAssortmentLocalData.isHouseOfBrands;
        result.ProductDropshippingStatus = outletAssortments.outletAssortmentLocalData.productDropshippingStatus;
        return result;
    }

    public class InnerParser {
        public Outlet outlet;
        public OutletKpiLocalData outletKpiLocalData;
    }

    public class OutletAssortments {
        public Product product;
        public Integer rank;
        public OutletAssortmentLocalData outletAssortmentLocalData;
    }

    public class OutletAssortmentLocalData {
        public Integer categoryRankPr;
        public Integer categoryRank;
        public Integer stateRank;
        public Integer averageNumberOfFacings;
        public Double presenceInSimilarStores;
        public Boolean isHouseOfBrands;
        public String productDropshippingStatus;
    }

    public class Outlet {
        public String outletExternalId;
        public List<OutletAssortments> outletAssortments;
    }

    public class Product {
        public String productExternalId;
    }

    public class OutletKpiLocalData {
        public Segmentation segmentation;
    }

    public class Segmentation {
        public String financialCategory;
        public String environmentType;
        public String physicalInfo;
        public String dropshippingStatus;
        public Integer storeSize;
        public Integer annualTarget;
        public Integer currentVisitNumber;
        public Integer lastFacingNumber;
        public Double sellOutPotentialFood;
        public Double foodRatio;
        public Double currentVisitTarget;
    }
}