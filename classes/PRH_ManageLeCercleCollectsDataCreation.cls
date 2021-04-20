// Le Cercle application - evolution LCS-153 - July 2017
// Creation batch of Data related to the Le Cercle collects (Competitor Brands and Le Cercle Brands)
// 2 jobs are scheduled in order to create collects and their data :
// System.Schedule('Creation of Le Cercle collects', '0 13 11 * * ? *', new PRH_BatchLeCercleCollectsCreation());
// System.Schedule('Creation of Brands for Le Cercle collects', '0 29 11 * * ? *', new PRH_BatchLeCercleCollectsDataCreation());

// ***** IMPORTANT INFORMATION *****
// These classes PRH_ManageLeCercleCollectsCreation and PRH_ManageLeCercleCollectsDataCreation replace previous one listed below that are kept 
// in case of an issue with this new implementation :
// - System.Schedule('Creation of Le Cercle collects', '0 13 17 * * ? *', new PRH_ManageCollectsForIconicAcc());
// - System.Schedule('Creation of Brands for collects', '0 03 11 * * ? *', new PRH_ScheduleBatchBRCreationForCollects());
global class PRH_ManageLeCercleCollectsDataCreation implements Database.Batchable<sObject>, Database.Stateful {
    public String Query;
   
    Public Date todayDate = system.today();
    Public Integer currentDay = todayDate.day();
    Public Integer currentMonth = todayDate.month();
    Public Integer currentYear = todayDate.year();
    Public Date PRH_PeriodStartDate;
    Public Date PRH_PeriodEndDate;
    Public Date PRH_PeriodStartDatePreviousCollect;
    Public Integer PRH_NbOfNewCollects;
    public Integer nextStep = 0;
    
    public void setNextStep(Integer val) {
        nextStep = val;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Retrieve current date
        System.debug('**************************** PRH_ManageLeCercleCollectsDataCreation Execution started ****************************');
        System.debug('--> PRH_ManageLeCercleCollectsDataCreation, start current date :' + system.today().format());
        
        // Define Start and End date for new collects to create regarding current date
        if (Test.isRunningTest()) {
            if (nextStep == 0) {
                currentDay = 07;
                currentMonth = 05;
                currentYear = 2017;
            } else if (nextStep == 1) {
                currentDay = 07;
                currentMonth = 09;
                currentYear = 2017;
            } else if (nextStep == 2) {
                currentDay = 07;
                currentMonth = 12;
                currentYear = 2017;
            } else if (nextStep == 3) {
                currentDay = 07;
                currentMonth = 01;
                currentYear = 2018;
            } 
        }

        // Define Start and End date for new collects to create regarding current date
        if ((currentMonth >= 3) && (currentMonth <= 6)) {
            if (Test.isRunningTest()) {
                PRH_PeriodStartDate = date.newInstance(2017, 03, 01);
                PRH_PeriodEndDate = date.newInstance(2017, 06, 30);
                PRH_PeriodStartDatePreviousCollect = date.newInstance(2016, 11, 01);
            } else {
                PRH_PeriodStartDate = date.newInstance(currentYear, 03, 01);
                PRH_PeriodEndDate = date.newInstance(currentYear, 06, 30);
                PRH_PeriodStartDatePreviousCollect = date.newInstance(currentYear-1, 11, 01);
            }
        } else if ((currentMonth >= 7) && (currentMonth <= 10)) {
            if (Test.isRunningTest()) {
                PRH_PeriodStartDate = date.newInstance(2017, 07, 01);
                PRH_PeriodEndDate = date.newInstance(2017, 10, 31);
                PRH_PeriodStartDatePreviousCollect = date.newInstance(2017, 03, 01);
            } else {
                PRH_PeriodStartDate = date.newInstance(currentYear, 07, 01);
                PRH_PeriodEndDate = date.newInstance(currentYear, 10, 31);
                PRH_PeriodStartDatePreviousCollect = date.newInstance(currentYear, 03, 01);
            }
        } else if ((currentMonth == 11) || (currentMonth == 12)) {
            if (Test.isRunningTest()) {
                PRH_PeriodStartDate = date.newInstance(2017, 11, 01);
                PRH_PeriodEndDate = date.newInstance(2018, 02, 28);
                PRH_PeriodStartDatePreviousCollect = date.newInstance(2017, 07, 01);
            } else {
                if (Date.isLeapYear(currentYear+1) == true) { // next year is a leap year
                    PRH_PeriodEndDate = date.newInstance(currentYear+1, 02, 29);
                } else {
                    PRH_PeriodEndDate = date.newInstance(currentYear+1, 02, 28);
                }
                PRH_PeriodStartDate = date.newInstance(currentYear, 11, 01);  // year, month, day
                PRH_PeriodStartDatePreviousCollect = date.newInstance(currentYear, 07, 01);
            }
        } else if ((currentMonth == 1) || (currentMonth == 2)) {
            if (Test.isRunningTest()) {
                PRH_PeriodStartDate = date.newInstance(2017, 11, 01);
                PRH_PeriodEndDate = date.newInstance(2018, 02, 28);
                PRH_PeriodStartDatePreviousCollect = date.newInstance(2017, 07, 01);
            } else {
                if (Date.isLeapYear(currentYear) == true) { // this is a leap year
                    PRH_PeriodEndDate = date.newInstance(currentYear, 02, 29);
                } else {
                    PRH_PeriodEndDate = date.newInstance(currentYear, 02, 28);
                }
                PRH_PeriodStartDate = date.newInstance(currentYear-1, 11, 01);  // year, month, day
                PRH_PeriodStartDatePreviousCollect = date.newInstance(currentYear-1, 07, 01);
            }
        }

        System.debug('--> PRH_ManageLeCercleCollectsDataCreation, PRH_PeriodStartDate=' + PRH_PeriodStartDate + ', PRH_PeriodStartDatePreviousCollect='  + PRH_PeriodStartDatePreviousCollect);
        
        // Define query for retrieving the list of previous collects linked to Iconic Accounts not in state suppress
        this.Query = 'SELECT id, PRH_Iconic_Account__c, PRH_Iconic_Account__r.OwnerId, PRH_Iconic_Account__r.PRH_Owner_2__c FROM PRH_Collect__c WHERE PRH_Active__c=false AND PRH_Period_Start__c = :PRH_PeriodStartDatePreviousCollect AND PRH_Iconic_Account__c IN (SELECT id FROM PRH_Luxury_Accounts__c WHERE PRH_Suppress_and_archive__c=false)';
        System.debug('--> PRH_ManageLeCercleCollectsDataCreation, Query=' + this.Query);

        return Database.getQueryLocator(this.Query);
    }

    public void execute(Database.BatchableContext BC, List<PRH_Collect__c> previousCollectsList){
        PRH_Competitor_Brands__c compBrand;
        PRH_Brand_Criteria__c leCercleBrand;
        Integer nbActiveBrands = 0;
        List<PRH_Competitor_Brands__c> listOfNewCompetitorBRs;
        List<PRH_Brand_Criteria__c> listOfNewLeCercleBRs;
        Map<ID, ID> collectsMap;
        Map<ID, ID> collectsOwnerMap;
        Map<ID, ID> collectsOwner2Map;
        Map<ID, PRH_Brand_Luxury_Brand__c> brandsMap;
        listOfNewLeCercleBRs = new List<PRH_Brand_Criteria__c>();
        listOfNewCompetitorBRs = new List<PRH_Competitor_Brands__c>();
        list<PRH_Brand_Criteria__Share> listOfCriteriaShare = new List<PRH_Brand_Criteria__Share>();
        List<PRH_Collect__c> newCollectsList;
        List<ID> owner2IDList = new List<ID>();
        Map<ID, ID> owner2IDMap;
        ID ownerID;
        
        try {
            System.debug('PRH_ManageLeCercleCollectsDataCreation, previousCollectsList.size=' + previousCollectsList.size());
            if (previousCollectsList.size() > 0) {
                // Store in a map information relative to Brands regarding field Active
                nbActiveBrands = 0;
                brandsMap = new Map<ID, PRH_Brand_Luxury_Brand__c>([SELECT Id, PRH_Active__c, PRH_Competitor_Brand__c FROM PRH_Brand_Luxury_Brand__c]); 
                // After populating the map, iterate through the map entries 
                for (ID idKey : brandsMap.keyset()) { 
                    PRH_Brand_Luxury_Brand__c b = brandsMap.get(idKey); 
                    System.debug('--> PRH_ManageLeCercleCollectsDataCreation, idKey = ' + idKey + ', b = ' + b); 
                    if (b.PRH_Active__c == True) {
                        nbActiveBrands++;
                    }
                } 
                System.debug('--> PRH_ManageLeCercleCollectsDataCreation, there are ' + nbActiveBrands + ' active iconic brands (total = ' + brandsMap.size() + ')'); 

                // Store in a set all the brands Id that are going to be linked to the collect
                // In case new brand has been created recently and is not present in previous collect, this new brand must be added in the new collect        
                Set<Id> createdBR = new Set<Id>();
                
                newCollectsList = [SELECT Id, PRH_Iconic_Account__c, PRH_Iconic_Account__r.OwnerId, PRH_Iconic_Account__r.PRH_Owner_2__c FROM PRH_Collect__c WHERE PRH_Active__c=true];
                collectsMap = new Map<ID, ID>();
                collectsOwnerMap = new Map<ID, ID>(); 
                collectsOwner2Map = new Map<ID, ID>();
                owner2IDMap = new Map<ID, ID>(); 
                // Creating Map with id of previous collect as key and id of new collect as value. This map allows to link the collects related to the same Iconic
                for (PRH_Collect__c pc:previousCollectsList) {
                    for (PRH_Collect__c nc:newCollectsList) {
                        if (pc.PRH_Iconic_Account__c == nc.PRH_Iconic_Account__c) {
                            collectsMap.put(pc.Id, nc.Id);
                            collectsOwnerMap.put(pc.Id, nc.PRH_Iconic_Account__r.OwnerId);
                            collectsOwner2Map.put(nc.Id, nc.PRH_Iconic_Account__r.PRH_Owner_2__c); // Warning : ID of new collects
                            // Store all distinc ID of owners2 in a map for retriction of user query
                            if (owner2IDMap.containsKey(nc.PRH_Iconic_Account__r.PRH_Owner_2__c) == False) {
                                owner2IDMap.put(nc.PRH_Iconic_Account__r.PRH_Owner_2__c, nc.PRH_Iconic_Account__r.PRH_Owner_2__c);
                            } 
                            //System.debug('PRH_ManageLeCercleCollectsDataCreation, nc.Id=' + nc.Id + 'nc.PRH_Iconic_Account__r.PRH_Owner_2__c' + nc.PRH_Iconic_Account__r.PRH_Owner_2__c);
                        }
                    }
                }
                System.debug('PRH_ManageLeCercleCollectsDataCreation, owner2IDMap.size()=' + owner2IDMap.size());
                for (ID idKey : owner2IDMap.keyset()) { 
                    owner2IDList.add(idKey);
                }
                System.debug('PRH_ManageLeCercleCollectsDataCreation, owner2IDList.size()=' + owner2IDList.size());
                System.debug('PRH_ManageLeCercleCollectsDataCreation, the number of key-value pairs for collectsMap is ' + collectsMap.size());
                System.debug('PRH_ManageLeCercleCollectsDataCreation, the number of key-value pairs for collectsOwner2Map is ' + collectsOwner2Map.size());
                /*
                for (Id id : collectsMap.keySet())
                {
                    System.debug('Key (previous collect) = ' + id + ', Value (new collect) = ' + collectsMap.get(id));
                }
                */
                
                // For all new active collects, creation of LeCercle and Competitor brands with same value of previous collect LeCercle and Competitor brands
                List<PRH_Competitor_Brands__c> compBrandList = [SELECT Id, PRH_Iconic_Brand__c, PRH_Collect__c, PRH_Presence__c, PRH_Volume__c, OwnerId FROM PRH_Competitor_Brands__c WHERE PRH_Collect__c IN:previousCollectsList];
                System.debug('--> PRH_ManageLeCercleCollectsDataCreation, compBrandList.size() = ' + compBrandList.size());
                for (PRH_Competitor_Brands__c cb:compBrandList) {
                    // Create a new Brand Competitor linked with the new created collect if the Brand is active
                    System.debug('--> PRH_ManageLeCercleCollectsDataCreation, PRH_Competitor_Brands__c cb.Id = ' + cb.Id + ', cb.PRH_Iconic_Brand__c = ' + cb.PRH_Iconic_Brand__c);
                    if (cb.PRH_Iconic_Brand__c != null) {
                        PRH_Brand_Luxury_Brand__c b = brandsMap.get(cb.PRH_Iconic_Brand__c);
                        System.debug('--> PRH_ManageLeCercleCollectsDataCreation, PRH_Brand_Luxury_Brand__c b = ' + b);
                        if (b != null) {
                            if (b.PRH_Active__c == True) {
                                compBrand = new PRH_Competitor_Brands__c(
                                    PRH_Collect__c = collectsMap.get(cb.PRH_Collect__c),      // Id of new collect attached to same Iconic Account
                                    PRH_Iconic_Brand__c = cb.PRH_Iconic_Brand__c,
                                    PRH_Presence__c = cb.PRH_Presence__c,
                                    PRH_Volume__c = cb.PRH_Volume__c,
                                    OwnerId = cb.OwnerId
                                );
                                listOfNewCompetitorBRs.add(compBrand);
                                // Remind that the brand is linked to the collect
                                createdBR.add(cb.PRH_Iconic_Brand__c);
                            }
                        }                           
                    }                   
                }
                
                List<PRH_Brand_Criteria__c> lecercleBrandList = [SELECT Id, PRH_Brand__c, PRH_Collect__c, PRH_Number_of_Branded_Events__c, PRH_Presence__c, PRH_Visibility__c, PRH_Branded_Event__c, PRH_Volume__c, OwnerId FROM PRH_Brand_Criteria__c WHERE PRH_Collect__c IN:previousCollectsList];
                System.debug('--> PRH_ManageLeCercleCollectsDataCreation, lecercleBrandList.size() = ' + lecercleBrandList.size());
                for (PRH_Brand_Criteria__c lcb:lecercleBrandList) {
                    // Create a new Le Cercle Brand linked with to the new created collect if the Brand is active
                    System.debug('--> PRH_ManageLeCercleCollectsDataCreation, PRH_Brand_Criteria__c lcb.Id = ' + lcb.Id + ', lcb.PRH_Brand__c = ' + lcb.PRH_Brand__c);
                    if (lcb.PRH_Brand__c != null) {
                        PRH_Brand_Luxury_Brand__c b = brandsMap.get(lcb.PRH_Brand__c);
                        System.debug('--> PRH_ManageLeCercleCollectsDataCreation, PRH_Brand_Luxury_Brand__c b = ' + b);
                        if (b != null) {
                            ownerID = collectsOwnerMap.get(lcb.PRH_Collect__c);    // Owner ID of the Iconic Account
                            if (b.PRH_Active__c == True) {
                                leCercleBrand = new PRH_Brand_Criteria__c(
                                    PRH_Collect__c = collectsMap.get(lcb.PRH_Collect__c),      // Id of new collect attached to same Iconic Account
                                    PRH_Brand__c = lcb.PRH_Brand__c,
                                    PRH_Number_of_Branded_Events__c = lcb.PRH_Number_of_Branded_Events__c,
                                    PRH_Presence__c = lcb.PRH_Presence__c,
                                    PRH_Visibility__c = lcb.PRH_Visibility__c,
                                    PRH_Branded_Event__c = lcb.PRH_Branded_Event__c,
                                    PRH_Volume__c = lcb.PRH_Volume__c,
                                    OwnerId = lcb.OwnerId
                                );
                                System.debug('--> PRH_ManageLeCercleCollectsDataCreation, leCercleBrand = ' + leCercleBrand);
                                listOfNewLeCercleBRs.add(leCercleBrand);
                                // Remind that the brand is linked to the collect
                                createdBR.add(lcb.PRH_Brand__c);
                            }
                        }
                    }
                }
                
                // Check number of brands added 
                // If number is less than active brands, it is necessary to add the new brands not inserted as emtpy one in the collects
                System.debug('--> PRH_ManageLeCercleCollectsDataCreation, createdBR.size() = ' + createdBR.size() + ', nbActiveBrands = ' + nbActiveBrands);
                System.debug('--> PRH_ManageLeCercleCollectsDataCreation, listOfNewCompetitorBRs.size() = ' + listOfNewCompetitorBRs.size() );
                System.debug('--> PRH_ManageLeCercleCollectsDataCreation, listOfNewLeCercleBRs.size() = ' + listOfNewLeCercleBRs.size() );
                if (createdBR.size() < nbActiveBrands) {
                    for (PRH_Collect__c pc:previousCollectsList) {                  
                        // For each Brand
                        for (Id key : brandsMap.keySet()) {
                            // If brand isn't present in the set of Brands already treated
                            PRH_Brand_Luxury_Brand__c b = brandsMap.get(key); 
                            if (b.PRH_Active__c == true) {
                                if (createdBR.contains(b.Id) == False) {
                                    // System.debug('--> PRH_ManageLeCercleCollectsDataCreation, new Brand = ' + b.id + ' added to collect ' + collectsMap.get(pc.id)); 
                                    // If flag Competitor is equal to True
                                    if (b.PRH_Competitor_Brand__c == true) {
                                        // Create a new Brand Competitor linked with to the new created collect
                                        compBrand = new PRH_Competitor_Brands__c(
                                            PRH_Collect__c = collectsMap.get(pc.id),
                                            PRH_Iconic_Brand__c = b.id,
                                            OwnerId = pc.PRH_Iconic_Account__r.OwnerId
                                        );
                                        listOfNewCompetitorBRs.add(compBrand);
                                    } else {
                                        // Create a new Le Cercle Brand linked with to the new created collect
                                        leCercleBrand = new PRH_Brand_Criteria__c(
                                            PRH_Brand__c = b.id,
                                            PRH_Collect__c = collectsMap.get(pc.id),
                                            OwnerId = pc.PRH_Iconic_Account__r.OwnerId
                                        );
                                        listOfNewLeCercleBRs.add(leCercleBrand);
                                    }
                                }
                            }
                        }
                    }
                }
                if (listOfNewCompetitorBRs.size() > 0) {
                    System.debug('--> PRH_ManageLeCercleCollectsDataCreation, ' + listOfNewCompetitorBRs.size() + ' Competitor Brands are going to be created');
                    insert listOfNewCompetitorBRs;
                }
                if (listOfNewLeCercleBRs.size() > 0) {
                    System.debug('--> PRH_ManageLeCercleCollectsDataCreation, ' + listOfNewLeCercleBRs.size() + ' Le Cercle Brands are going to be created');
                    insert listOfNewLeCercleBRs;
                }
            }
        } catch (Exception e) {
            System.Debug('--> PRH_ManageLeCercleCollectsDataCreation, error: '+ e.getMessage());
            System.Debug('--> PRH_ManageLeCercleCollectsDataCreation, error: '+ e.getLineNumber());
            System.Debug('--> PRH_ManageLeCercleCollectsDataCreation, error: '+ e.getStackTraceString());
        } 

        // Manage sharings for new Le Cercle Brands
        if ((previousCollectsList.size() > 0) && (collectsOwner2Map.size() > 0)) {
            ID owner2ID;
            User owner2User;
            PRH_Brand_Criteria__share newShare;
            List<PRH_Brand_Criteria__c> newLeCercleBrandList = [SELECT Id, PRH_Collect__c FROM PRH_Brand_Criteria__c WHERE PRH_Collect__c IN:newCollectsList ORDER BY CreatedDate DESC LIMIT 30000]; // LCS-1483: error Too many query rows: 50001
            Map<ID, User> usersMap = new Map<ID, User>([SELECT Id, IsActive FROM User WHERE Id IN:owner2IDList]); 
            System.debug('--> PRH_ManageLeCercleCollectsDataCreation, usersMap.size() = ' + usersMap.size());
            
            for (PRH_Brand_Criteria__c lcb:newLeCercleBrandList) { 
                owner2ID = null;
                owner2User = null;
                newShare = new PRH_Brand_Criteria__share();
                newShare.AccessLevel = 'Edit';
                newShare.ParentId = lcb.Id;
                owner2ID = collectsOwner2Map.get(lcb.PRH_Collect__c);
                if (owner2ID != null) {
                    owner2User = usersMap.get(owner2ID); 
                    if (owner2User != null) { // Check if user is active or not (no share for inactive users)
                        if (owner2User.IsActive == True) {
                            newShare.UserOrGroupId = owner2ID;
                            listOfCriteriaShare.add(newShare);
                        } else {
                            System.debug('--> PRH_ManageLeCercleCollectsDataCreation, owner2ID ('+ owner2ID +') is an inactive user, no share');
                        }
                    } else {
                        System.debug('--> PRH_ManageLeCercleCollectsDataCreation, owner2ID is null, no share');
                    }
                }
            }
            if (listOfCriteriaShare.size() > 0) {
                System.debug('--> PRH_ManageLeCercleCollectsDataCreation, ' + listOfCriteriaShare.size() + ' sharing Le Cercle Brands are going to be created');
                //upsert listOfCriteriaShare;
                Database.SaveResult[] srList = Database.insert(listOfCriteriaShare, false);

                // Check insert result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('--> PRH_ManageLeCercleCollectsDataCreation, successfully inserted share: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('--> PRH_ManageLeCercleCollectsDataCreation, The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            }  
        }
    }

    public void finish(Database.BatchableContext BC) {
       
    }
}