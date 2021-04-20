/**
 * Created by Ilarion Tokarskyi on 22.12.2020.
 */

public with sharing class EUR_CRM_DStarVisitWebhookHandler implements EUR_CRM_IWebhookHandler {

    public void handleWebhook() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:EUR_CRM_DStarVisitAPI');
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setMethod('GET');
        HttpResponse response = new Http().send(req);

        List<InnerParser> parsedBody;
        try{
           parsedBody = (List<InnerParser>) JSON.deserialize(response.getBody(), List<InnerParser>.class);
            System.debug('response.getBody ==> ' + response.getBody());
            System.debug('parsed Body ==> ' + parsedBody);
        } catch (Exception ex) {
            System.debug('Parsing Error - EUR_CRM_DStarVisitWebhookHandler\n');
            System.debug('response.getBody ==> ' + response.getBody());
            System.debug(ex.getMessage());
            EUR_CRM_WebhookREST_Service.sendEmailNotification('EUR_CRM_DStarVisitWebhookHandler Error', 'Cant parse ' +
                    'response body: \n' +response.getBody());
            return;
        }
        EUR_CRM_RecommendedVisitsParser toProcessed = new EUR_CRM_RecommendedVisitsParser();
        toProcessed.Weeks = new List<EUR_CRM_RecommendedVisitsParser.Week>();

        for (InnerParser week: parsedBody) {
            toProcessed.Weeks.add(createWeekForParser(week));
        }

        EUR_CRM_RecommendedVisitsService service = new EUR_CRM_RecommendedVisitsService();
        System.debug('Succ1');
        if (service.isInvalidBody(JSON.serialize(toProcessed))) return;
        System.debug('Succ2');
        service.insertRecommendedObjects();
    }

    private EUR_CRM_RecommendedVisitsParser.Week createWeekForParser(InnerParser week) {
        EUR_CRM_RecommendedVisitsParser.Week result = new EUR_CRM_RecommendedVisitsParser.Week();
        result.Affiliate = 'DE';
        result.WeekStartDate = week.weekStartDate;
        result.accounts = new List<EUR_CRM_RecommendedVisitsParser.Account>();
        result.accounts.add(createAccountForParser(week));
        return result;
    }

    private EUR_CRM_RecommendedVisitsParser.Account createAccountForParser(InnerParser week) {
        EUR_CRM_RecommendedVisitsParser.Account result = new EUR_CRM_RecommendedVisitsParser.Account();
        result.Id = week.outlet.outletExternalId;
        result.visitRank = week.visitRank;
        result.VisitType = week.visitType;
        result.PromotionScore = week.promotionLocalData.promotionScore;
        result.BusinessDevScore = week.perfectStoreData.totalScore;
        result.Promotions = new List<EUR_CRM_RecommendedVisitsParser.Upcoming_promotion>();
        for (Promotion promotion: week.promotions) {
            result.Promotions.add(createPromotionForParser(promotion));
        }
        return result;
    }

    private EUR_CRM_RecommendedVisitsParser.Upcoming_promotion createPromotionForParser(Promotion promotion) {
        EUR_CRM_RecommendedVisitsParser.Upcoming_promotion result = new EUR_CRM_RecommendedVisitsParser.Upcoming_promotion();
        result.Promotion = promotion.promotionName;
        result.Products = new List<String>();
        for (RecProd recProd: promotion.recommendedProduct) {
            result.Products.add(recProd.product.productExternalId);
        }
        return result;
    }

    public class InnerParser {
        public String weekStartDate;
        public Integer visitRank;
        public String visitType;
        public Outlet outlet;
        public PromLocalData promotionLocalData;
        public PerfStoreData perfectStoreData;
        public List<Promotion> promotions;
    }

    public class Outlet {
        public String outletExternalId;
    }

    public class PromLocalData {
        public Double promotionScore;
    }

    public class PerfStoreData {
        public Double totalScore;
    }

    public class Promotion {
        public String promotionName;
        public List<RecProd> recommendedProduct;
    }

    public class RecProd {
        public Product product;
    }

    public class Product {
        public String productExternalId;
    }
}