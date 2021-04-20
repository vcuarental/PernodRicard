// Le Cercle application - evolution LCS-153 - June 2017
// Scheduler for launching the batch of creation of Collects, Le Cercle Brand et Competitor brands
// There are 3 collects per year and one collect per iconic account. 
// These collects are created automatically in 2 steps in order to avoid Salesforce limitation regarding 10000 max query rows in APEX class
// Step one : launch of schedulable class PRH_BatchLeCercleCollectsCreation for deactivation of active collects and creation of new ones
// Step two : launch of schedulable class PRH_BatchLeCercleCollectsDataCreation for creation of Competitor/Le Cercle Brands linked to collects (only active Brands are taken into account)
// for creation of Competitor brands and Le Cercle brands for each new collect
// Step three : launch of schedulable class PRH_BatchUpdateCollectsCalculatedValues in order to recalculate values regarding collect's field Full Le Cercle, Nb of Pernod-Ricard product, Le Cercle Presence
global class PRH_BatchUpdateCollectsCalculatedValues implements Schedulable{

    global void execute(SchedulableContext ctx) {
        // Limitation for default batch size to 50 instead of 200 
		// This is done to avoid problem of limit of 10000 query rows when the entry point is an APEX 
        Database.executeBatch(new PRH_UpdateCollectsCalculatedValues(), 50);
    }
    
}