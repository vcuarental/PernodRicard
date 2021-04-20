/**
 * Created by larsz on 19.11.2020.
 */

public with sharing class EUR_CRM_RecommendedVisitsParser {
    public class Upcoming_promotion {
        public String Promotion;
        public List<String> Products;
    }

    public List<Week> Weeks;

    public class Week {
        public String Affiliate;
        public String WeekStartDate;
        public List<Account> accounts;
    }

    public class Account {
        public String Id;
        public String VisitType;
        public Double PromotionScore;
        public Double BusinessDevScore;
        public List<Upcoming_promotion> Promotions;
        public Integer visitRank;
    }

    public static EUR_CRM_RecommendedVisitsParser parse(String json) {
        return (EUR_CRM_RecommendedVisitsParser) System.JSON.deserialize(json, EUR_CRM_RecommendedVisitsParser.class);
    }
}