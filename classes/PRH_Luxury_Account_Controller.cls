public class PRH_Luxury_Account_Controller {
    public PRH_Luxury_Accounts__c luxAcc {get;set;}
    public List<PRH_Collect__c> PRH_Collects{get;set;}
    public Boolean rendered{get;set;}
    public Boolean renderButton{get;set;}
    public List<PRH_Brand_Criteria__c> LeCercleBrands {get;set;}
    public List<PRH_Brand_Criteria__c> LeCercleBrands1 {get;set;}
    //public List<PRH_Brand_Criteria__c> LeCercleBrands2 {get;set;}  // LCS-1355
    //public List<PRH_Brand_Criteria__c> LeCercleBrands3 {get;set;}  // LCS-1355
    public List<PRH_Competitor_Brands__c> competitorBrands {get;set;}
    public List<PRH_Competitor_Brands__c> competitorBrands1 {get;set;}
    //public List<PRH_Competitor_Brands__c> competitorBrands2 {get;set;}  // LCS-1355
    //public List<PRH_Competitor_Brands__c> competitorBrands3 {get;set;}  // LCS-1355
    public String PRH_OngoingCollectTitle{get;set;}
    public String PRH_Previous1CollectTitle{get;set;}
    //public String PRH_Previous2CollectTitle{get;set;}  // LCS-1355
    //public String PRH_Previous3CollectTitle{get;set;}  // LCS-1355
    public Boolean renderTab1{get;set;}
    //public Boolean renderTab2{get;set;}  // LCS-1355
    //public Boolean renderTab3{get;set;}  // LCS-1355
    public Boolean renderTabActiveOngoingCollect{get;set;}
    public Boolean renderTabInactiveOngoingCollect{get;set;}
    public PRH_Collect__c PRH_OngoingCollect{get;set;}
    public PRH_Collect__c PRH_Previous1Collect{get;set;}
    //public PRH_Collect__c PRH_Previous2Collect{get;set;}  // LCS-1355
    //public PRH_Collect__c PRH_Previous3Collect{get;set;}  // LCS-1355
    
    public PRH_Luxury_Account_Controller(ApexPages.StandardController controller) {

        rendered = true;
        renderButton=true;
        ID ongoingCollect_Id;
        
        Id loggedInUser=  Userinfo.getUserId();
        List<PermissionSetAssignment> permissionList = [SELECT PermissionSetId
                                                        FROM PermissionSetAssignment
                                                        WHERE AssigneeId = :loggedInUser];
        System.debug('Test : ' + permissionList);
        List<ID> idList = new List<ID>();
        for(PermissionSetAssignment psa : permissionList){
            idList.add(psa.PermissionSetId);
        }      
        System.debug('Test : ' + idList);                                          
        List<PermissionSet> permissionNameList = [Select Name From PermissionSet Where ID in :idList];                                          
        Set<String> permissionNames = new Set<String>();
        for(PermissionSet ps : permissionNameList){
            permissionNames.add(ps.name);
        }
        System.debug('Test : ' + permissionNameList);
        if(permissionNames.contains('PRH_Iconic_Platform_USA')||permissionNames.contains('PRH_Iconic_Platform_USA_Sales_Directors')||permissionNames.contains('PRH_Iconic_Platform_USA_Regional_Directors')){
            rendered = false;
        }
        if(permissionNames.contains('PRH_Iconic_Platform_PR_Holding') || permissionNames.contains('PRH_Iconic_Platform_Regional_Directors')){
            renderButton = false;
        }
        luxAcc =((PRH_Luxury_Accounts__c)controller.getRecord());

        try {
            luxAcc =[Select 
                        id, Name , PRH_Existing_Account__r.Name ,PRH_Detailed_address__c,PRH_City__c,PRH_Telephone__c,PRH_High_Networth_Individuals__c /*, PRH_Contracted__c */
                    From 
                        PRH_Luxury_Accounts__c 
                    Where 
                        id = :luxAcc.id Limit 1];  
            
            // Retrieve all collects linked to the Iconic Account 
            PRH_Collects =[Select 
                        id, Name, PRH_Active__c, /*PRH_Full_Active_Le_Cercle_Portfolio__c,*/ PRH_Le_Cercle_Brand_Presence__c, PRH_Collect_Last_Modified_Date__c, PRH_Iconic_Account__c, PRH_Number_of_Pernod_Ricard_products__c , PRH_Period_End__c, PRH_Period_Start__c 
                    From 
                        PRH_Collect__c 
                    Where 
                        PRH_Iconic_Account__c = :luxAcc.id ORDER BY Name DESC];
            System.debug('==> PRH_Luxury_Account_Controller, ' + PRH_Collects.size() + ' Collect(s) retrieved for Iconic account ' + luxAcc.Name);  
            System.debug('==> PRH_Luxury_Account_Controller, PRH_Collects : ' + PRH_Collects);  
        } catch (Exception e) {
            System.Debug('### error:'+ e.getMessage());
            System.Debug('### error:'+ e.getLineNumber());
            System.Debug('### error:'+ e.getStackTraceString());
        }
        // Manage dynamic Tab display
        manageTabRerender();
        manageCollectDataDisplay();
    }
    
    public PageReference editAll(){
        return new PageReference('/apex/PRH_Iconic_Platform_Mass_Edit_Desktop?id='+luxAcc.id);
    }
    
    public void manageTabRerender() {
        // Retrieve current date
        System.debug('=> manageTabRerender, current date :' + system.today().format());
        PRH_OngoingCollectTitle = 'Collect - JJ/MM/YYYY to JJ/MM/YYYY';
        PRH_Previous1CollectTitle = 'Collect - JJ/MM/YYYY to JJ/MM/YYYY';
        //PRH_Previous2CollectTitle = 'Collect - JJ/MM/YYYY to JJ/MM/YYYY';
        //PRH_Previous3CollectTitle = 'Collect - JJ/MM/YYYY to JJ/MM/YYYY';
        String periodStart;
        String periodEnd;
        
        renderTab1 = false;
        //renderTab2 = false;
        //renderTab3 = false;
        renderTabActiveOngoingCollect = false;
        renderTabInactiveOngoingCollect = false;
        
        if (PRH_Collects.size() > 0) {
            // Display 1, 2, 3 or 4 Tabs depending of the number of collects
            System.debug('==> manageTabRerender, PRH_Collects[0] = ' + PRH_Collects[0] );
            if (PRH_Collects[0].PRH_Active__c == true) {
                renderTabActiveOngoingCollect = true;
                renderTabInactiveOngoingCollect = false;
            } else {
                renderTabActiveOngoingCollect = false;
                renderTabInactiveOngoingCollect = true;
            }
            if (PRH_Collects.size() == 1) {
                System.debug('==> manageTabRerender, PRH_Collects.size() = ' + PRH_Collects.size() );
                renderTab1 = false;
                //renderTab2 = false;
                //renderTab3 = false;
                periodStart = PRH_Collects[0].PRH_Period_Start__c.day() + '/' + PRH_Collects[0].PRH_Period_Start__c.month() + '/' + PRH_Collects[0].PRH_Period_Start__c.year();
                periodEnd = PRH_Collects[0].PRH_Period_End__c.day() + '/' + PRH_Collects[0].PRH_Period_End__c.month() + '/' + PRH_Collects[0].PRH_Period_End__c.year();
                PRH_OngoingCollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd;
            } else if (PRH_Collects.size() == 2) {
                System.debug('==> manageTabRerender, PRH_Collects.size() = ' + PRH_Collects.size() );
                renderTab1 = true;
                //renderTab2 = false;
                //renderTab3 = false;
                periodStart = PRH_Collects[0].PRH_Period_Start__c.day() + '/' + PRH_Collects[0].PRH_Period_Start__c.month() + '/' + PRH_Collects[0].PRH_Period_Start__c.year();
                periodEnd = PRH_Collects[0].PRH_Period_End__c.day() + '/' + PRH_Collects[0].PRH_Period_End__c.month() + '/' + PRH_Collects[0].PRH_Period_End__c.year();
                PRH_OngoingCollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd;                
                periodStart = PRH_Collects[1].PRH_Period_Start__c.day() + '/' + PRH_Collects[1].PRH_Period_Start__c.month() + '/' + PRH_Collects[1].PRH_Period_Start__c.year();
                periodEnd = PRH_Collects[1].PRH_Period_End__c.day() + '/' + PRH_Collects[1].PRH_Period_End__c.month() + '/' + PRH_Collects[1].PRH_Period_End__c.year();
                PRH_Previous1CollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd;              
            } else if (PRH_Collects.size() == 3) {
                System.debug('==> manageTabRerender, PRH_Collects.size() = ' + PRH_Collects.size() );
                renderTab1 = true;
                //renderTab2 = true;
                //renderTab3 = false;
                periodStart = PRH_Collects[0].PRH_Period_Start__c.day() + '/' + PRH_Collects[0].PRH_Period_Start__c.month() + '/' + PRH_Collects[0].PRH_Period_Start__c.year();
                periodEnd = PRH_Collects[0].PRH_Period_End__c.day() + '/' + PRH_Collects[0].PRH_Period_End__c.month() + '/' + PRH_Collects[0].PRH_Period_End__c.year();
                PRH_OngoingCollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd;    
                periodStart = PRH_Collects[1].PRH_Period_Start__c.day() + '/' + PRH_Collects[1].PRH_Period_Start__c.month() + '/' + PRH_Collects[1].PRH_Period_Start__c.year();
                periodEnd = PRH_Collects[1].PRH_Period_End__c.day() + '/' + PRH_Collects[1].PRH_Period_End__c.month() + '/' + PRH_Collects[1].PRH_Period_End__c.year();
                PRH_Previous1CollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd;  
                //periodStart = PRH_Collects[2].PRH_Period_Start__c.day() + '/' + PRH_Collects[2].PRH_Period_Start__c.month() + '/' + PRH_Collects[2].PRH_Period_Start__c.year();
                //periodEnd = PRH_Collects[2].PRH_Period_End__c.day() + '/' + PRH_Collects[2].PRH_Period_End__c.month() + '/' + PRH_Collects[2].PRH_Period_End__c.year();
                //PRH_Previous2CollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd;    
            } else if (PRH_Collects.size() >= 4) {
                System.debug('==> manageTabRerender, PRH_Collects.size() = ' + PRH_Collects.size() );
                renderTab1 = true;
                //renderTab2 = true;
                //renderTab3 = true;
                periodStart = PRH_Collects[0].PRH_Period_Start__c.day() + '/' + PRH_Collects[0].PRH_Period_Start__c.month() + '/' + PRH_Collects[0].PRH_Period_Start__c.year();
                periodEnd = PRH_Collects[0].PRH_Period_End__c.day() + '/' + PRH_Collects[0].PRH_Period_End__c.month() + '/' + PRH_Collects[0].PRH_Period_End__c.year();
                PRH_OngoingCollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd;
                periodStart = PRH_Collects[1].PRH_Period_Start__c.day() + '/' + PRH_Collects[1].PRH_Period_Start__c.month() + '/' + PRH_Collects[1].PRH_Period_Start__c.year();
                periodEnd = PRH_Collects[1].PRH_Period_End__c.day() + '/' + PRH_Collects[1].PRH_Period_End__c.month() + '/' + PRH_Collects[1].PRH_Period_End__c.year();             
                PRH_Previous1CollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd;  
                //periodStart = PRH_Collects[2].PRH_Period_Start__c.day() + '/' + PRH_Collects[2].PRH_Period_Start__c.month() + '/' + PRH_Collects[2].PRH_Period_Start__c.year();
                //periodEnd = PRH_Collects[2].PRH_Period_End__c.day() + '/' + PRH_Collects[2].PRH_Period_End__c.month() + '/' + PRH_Collects[2].PRH_Period_End__c.year();
                //PRH_Previous2CollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd;    
                //periodStart = PRH_Collects[3].PRH_Period_Start__c.day() + '/' + PRH_Collects[3].PRH_Period_Start__c.month() + '/' + PRH_Collects[3].PRH_Period_Start__c.year();
                //periodEnd = PRH_Collects[3].PRH_Period_End__c.day() + '/' + PRH_Collects[3].PRH_Period_End__c.month() + '/' + PRH_Collects[3].PRH_Period_End__c.year();
                //PRH_Previous3CollectTitle = 'Collect ' + periodStart + ' to ' + periodEnd;    
            }
        }
    }
    
    public void manageCollectDataDisplay() {

        if (PRH_Collects.size() > 0) {
            ID ongoingCollect_Id;
            // Retrieve Full_Active_l_Atelier_Portfolio and Number_of_Pernod_Ricard_products from active collect linked to the luxury account
            ongoingCollect_Id = PRH_Collects[0].id;
            PRH_OngoingCollect = PRH_Collects[0];
            PRH_OngoingCollect.PRH_Number_of_Pernod_Ricard_products__c = (PRH_OngoingCollect.PRH_Number_of_Pernod_Ricard_products__c == null) ? 0: PRH_OngoingCollect.PRH_Number_of_Pernod_Ricard_products__c;
    
            //system.debug('==> manageCollectDataDisplay, PRH_OngoingCollect.PRH_Full_Active_Le_Cercle_Portfolio__c=' + PRH_OngoingCollect.PRH_Full_Active_Le_Cercle_Portfolio__c );
            system.debug('==> manageCollectDataDisplay, PRH_OngoingCollect.PRH_Number_of_Pernod_Ricard_products__c=' + PRH_OngoingCollect.PRH_Number_of_Pernod_Ricard_products__c );
            system.debug('==> manageCollectDataDisplay, PRH_OngoingCollect.PRH_Collect_Last_Modified_Date__c=' + PRH_OngoingCollect.PRH_Collect_Last_Modified_Date__c );    
            // Retrieve informations displayed for 'Le Cercle Brands' Tab
            try {
                LeCercleBrands = 
                [Select  
                    PRH_Collect__c ,PRH_Brand__c, PRH_Presence__c,PRH_Brand__r.RecordType.DeveloperName ,
                    PRH_Brand__r.PRH_Sequence__c,PRH_Brand__r.Name,PRH_Branded_Event__c,PRH_Visibility__c,
                    PRH_Volume__c, PRH_Number_of_Branded_Events__c
                From PRH_Brand_Criteria__c 
                Where PRH_Collect__c = :ongoingCollect_Id
                AND PRH_Brand__r.PRH_Competitor_Brand__c=false
                //AND PRH_Brand__r.PRH_Active__c=true
                Order by PRH_Brand__r.PRH_Sequence__c , PRH_Brand__r.Name
                ];
                System.debug('==> manageCollectDataDisplay, ' + LeCercleBrands.size() + ' LeCercleBrands(s) retrieved for ongoingCollect_Id ' + ongoingCollect_Id);
                
                if (LeCercleBrands.size() > 0) {
                    for (PRH_Brand_Criteria__c b:LeCercleBrands) {
                        b.PRH_Volume__c = (b.PRH_Volume__c == null) ? 0: b.PRH_Volume__c;
                        b.PRH_Number_of_Branded_Events__c = (b.PRH_Number_of_Branded_Events__c == null) ? 0: b.PRH_Number_of_Branded_Events__c;
                    }
                }
            } catch (Exception e) {
                System.Debug('### manageCollectDataDisplay error:'+ e.getMessage());
                System.Debug('### manageCollectDataDisplay error:'+ e.getLineNumber());
                System.Debug('### manageCollectDataDisplay error:'+ e.getStackTraceString());
            }
            
            // Retrieve informations displayed for 'Competitor Brands' Tab
            try {
                competitorBrands = [SELECT 
                                    Id, PRH_Presence__c, PRH_Volume__c,PRH_Iconic_Brand__r.Name,
                                    PRH_Iconic_Brand__r.RecordType.DeveloperName,PRH_Collect__c,
                                    PRH_Iconic_Brand__c
                                    FROM PRH_Competitor_Brands__c
                                    WHERE PRH_Collect__c=:ongoingCollect_Id
                                    AND PRH_Iconic_Brand__r.PRH_Competitor_Brand__c=true
                                    //AND PRH_Iconic_Brand__r.PRH_Active__c=true
                                    //AND PRH_Iconic_Account__r.PRH_Suppress_and_archive__c=false
                                    ORDER BY PRH_Iconic_Brand__r.PRH_Sequence__c,PRH_Iconic_Brand__r.Name];
            } catch (Exception e) {
                System.Debug('### manageCollectDataDisplay error:'+ e.getMessage());
                System.Debug('### manageCollectDataDisplay error:'+ e.getLineNumber());
                System.Debug('### manageCollectDataDisplay error:'+ e.getStackTraceString());
            }
            System.debug('==> manageCollectDataDisplay, ' + competitorBrands.size() + ' competitorBrand(s) retrieved for collect Id ' + ongoingCollect_Id); 
            System.debug('==> manageCollectDataDisplay, competitorBrands : ' + competitorBrands);   
            
            if (PRH_Collects.size() >= 2) {
                ID collect_Id;
                // Retrieve Full_Active_l_Atelier_Portfolio and Number_of_Pernod_Ricard_products from previous 1 collect linked to the luxury account
                collect_Id = PRH_Collects[1].id;            
                PRH_Previous1Collect = PRH_Collects[1];
                PRH_Previous1Collect.PRH_Number_of_Pernod_Ricard_products__c = (PRH_Previous1Collect.PRH_Number_of_Pernod_Ricard_products__c == null) ? 0: PRH_Previous1Collect.PRH_Number_of_Pernod_Ricard_products__c;
    
                //system.debug('==> manageCollectDataDisplay, PRH_Previous1Collect.PRH_Full_Active_Le_Cercle_Portfolio__c=' + PRH_Previous1Collect.PRH_Full_Active_Le_Cercle_Portfolio__c );
                system.debug('==> manageCollectDataDisplay, PRH_Previous1Collect.PRH_Number_of_Pernod_Ricard_products__c=' + PRH_Previous1Collect.PRH_Number_of_Pernod_Ricard_products__c );    
                // Retrieve informations displayed for 'Le Cercle Brands' Tab for previous 1 collect                
                try {
                    LeCercleBrands1 = 
                    [Select  
                        PRH_Collect__c ,PRH_Brand__c, PRH_Presence__c,PRH_Brand__r.RecordType.DeveloperName ,
                        PRH_Brand__r.PRH_Sequence__c,PRH_Brand__r.Name,PRH_Branded_Event__c,PRH_Visibility__c,
                        PRH_Volume__c, PRH_Number_of_Branded_Events__c
                    From PRH_Brand_Criteria__c 
                    Where PRH_Collect__c = :collect_Id
                    AND PRH_Brand__r.PRH_Competitor_Brand__c=false
                    //AND PRH_Brand__r.PRH_Active__c=true
                    Order by PRH_Brand__r.PRH_Sequence__c , PRH_Brand__r.Name
                    ];
                    System.debug('==> manageCollectDataDisplay, ' + LeCercleBrands1.size() + ' LeCercleBrands(s) retrieved for collect_Id ' + collect_Id);
                    System.debug('==> manageCollectDataDisplay, LeCercleBrands : ' + LeCercleBrands1);
                    
                    if (LeCercleBrands1.size() > 0) {
                        for (PRH_Brand_Criteria__c b:LeCercleBrands1) {
                            b.PRH_Volume__c = (b.PRH_Volume__c == null) ? 0: b.PRH_Volume__c;
                            b.PRH_Number_of_Branded_Events__c = (b.PRH_Number_of_Branded_Events__c == null) ? 0: b.PRH_Number_of_Branded_Events__c;
                        }
                    }
                } catch (Exception e) {
                    System.Debug('### manageCollectDataDisplay error:'+ e.getMessage());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getLineNumber());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getStackTraceString());
                }
            
                // Retrieve informations displayed for 'Competitor Brands' Tab
                try {
                    competitorBrands1 = [SELECT 
                                        Id, PRH_Presence__c, PRH_Volume__c,PRH_Iconic_Brand__r.Name,
                                        PRH_Iconic_Brand__r.RecordType.DeveloperName,PRH_Collect__c,
                                        PRH_Iconic_Brand__c
                                        FROM PRH_Competitor_Brands__c
                                        WHERE PRH_Collect__c=:collect_Id
                                        AND PRH_Iconic_Brand__r.PRH_Competitor_Brand__c=true
                                        //AND PRH_Brand__r.PRH_Active__c=true
                                        //AND PRH_Iconic_Account__r.PRH_Suppress_and_archive__c=false
                                        ORDER BY PRH_Iconic_Brand__r.PRH_Sequence__c,PRH_Iconic_Brand__r.Name];
                } catch (Exception e) {
                    System.Debug('### manageCollectDataDisplay error:'+ e.getMessage());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getLineNumber());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getStackTraceString());
                }
                System.debug('==> manageCollectDataDisplay, ' + competitorBrands1.size() + ' competitorBrand(s) retrieved for collect Id ' + collect_Id);   
                System.debug('==> manageCollectDataDisplay, competitorBrands1 : ' + competitorBrands1);
            }
            
            /* LCS-1355
            if (PRH_Collects.size() >= 3) {
                ID collect_Id;
                // Retrieve Full_Active_l_Atelier_Portfolio and Number_of_Pernod_Ricard_products from previous 2 collect linked to the luxury account
                collect_Id = PRH_Collects[2].id;    
                PRH_Previous2Collect = PRH_Collects[2];
                PRH_Previous2Collect.PRH_Number_of_Pernod_Ricard_products__c = (PRH_Previous2Collect.PRH_Number_of_Pernod_Ricard_products__c == null) ? 0: PRH_Previous2Collect.PRH_Number_of_Pernod_Ricard_products__c;
    
                //system.debug('==> manageCollectDataDisplay, PRH_Previous2Collect.PRH_Full_Active_Le_Cercle_Portfolio__c=' + PRH_Previous2Collect.PRH_Full_Active_Le_Cercle_Portfolio__c );
                system.debug('==> manageCollectDataDisplay, PRH_Previous2Collect.PRH_Number_of_Pernod_Ricard_products__c=' + PRH_Previous2Collect.PRH_Number_of_Pernod_Ricard_products__c );
                
                // Retrieve informations displayed for 'Le Cercle Brands' Tab for previous 2 collect
                try {
                    LeCercleBrands2 = 
                    [Select  
                        PRH_Collect__c ,PRH_Brand__c, PRH_Presence__c,PRH_Brand__r.RecordType.DeveloperName ,
                        PRH_Brand__r.PRH_Sequence__c,PRH_Brand__r.Name,PRH_Branded_Event__c,PRH_Visibility__c,
                        PRH_Volume__c, PRH_Number_of_Branded_Events__c
                    From PRH_Brand_Criteria__c 
                    Where PRH_Collect__c = :collect_Id
                    AND PRH_Brand__r.PRH_Competitor_Brand__c=false
                    //AND PRH_Brand__r.PRH_Active__c=true
                    Order by PRH_Brand__r.PRH_Sequence__c , PRH_Brand__r.Name
                    ];
                    System.debug('==> manageCollectDataDisplay, ' + LeCercleBrands2.size() + ' LeCercleBrands(s) retrieved for collect_Id ' + collect_Id);
                    System.debug('==> manageCollectDataDisplay, LeCercleBrands : ' + LeCercleBrands2);
                    
                    if (LeCercleBrands2.size() > 0) {
                        for (PRH_Brand_Criteria__c b:LeCercleBrands2) {
                            b.PRH_Volume__c = (b.PRH_Volume__c == null) ? 0: b.PRH_Volume__c;
                            b.PRH_Number_of_Branded_Events__c = (b.PRH_Number_of_Branded_Events__c == null) ? 0: b.PRH_Number_of_Branded_Events__c;
                        }
                    }
                } catch (Exception e) {
                    System.Debug('### manageCollectDataDisplay error:'+ e.getMessage());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getLineNumber());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getStackTraceString());
                }
                
                // Retrieve informations displayed for 'Competitor Brands' Tab
                try {
                    competitorBrands2 = [SELECT 
                                        Id, PRH_Presence__c, PRH_Volume__c,PRH_Iconic_Brand__r.Name,
                                        PRH_Iconic_Brand__r.RecordType.DeveloperName,PRH_Collect__c,
                                        PRH_Iconic_Brand__c
                                        FROM PRH_Competitor_Brands__c
                                        WHERE PRH_Collect__c=:collect_Id
                                        AND PRH_Iconic_Brand__r.PRH_Competitor_Brand__c=true
                                        //AND PRH_Iconic_Brand__r.PRH_Active__c=true
                                        //AND PRH_Iconic_Account__r.PRH_Suppress_and_archive__c=false
                                        ORDER BY PRH_Iconic_Brand__r.PRH_Sequence__c,PRH_Iconic_Brand__r.Name];
                } catch (Exception e) {
                    System.Debug('### manageCollectDataDisplay error:'+ e.getMessage());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getLineNumber());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getStackTraceString());
                }
                System.debug('==> manageCollectDataDisplay, ' + competitorBrands2.size() + ' competitorBrand(s) retrieved for collect Id ' + collect_Id);   
                System.debug('==> manageCollectDataDisplay, competitorBrands2 : ' + competitorBrands2);
            }
            
            if (PRH_Collects.size() >= 4) {
                ID collect_Id;
                // Retrieve Full_Active_l_Atelier_Portfolio and Number_of_Pernod_Ricard_products from previous 3 collect linked to the luxury account
                collect_Id = PRH_Collects[3].id;
                PRH_Previous3Collect = PRH_Collects[2];
                PRH_Previous3Collect.PRH_Number_of_Pernod_Ricard_products__c = (PRH_Previous3Collect.PRH_Number_of_Pernod_Ricard_products__c == null) ? 0: PRH_Previous3Collect.PRH_Number_of_Pernod_Ricard_products__c;
    
                //system.debug('==> manageCollectDataDisplay, PRH_Previous3Collect.PRH_Full_Active_Le_Cercle_Portfolio__c=' + PRH_Previous3Collect.PRH_Full_Active_Le_Cercle_Portfolio__c );
                system.debug('==> manageCollectDataDisplay, PRH_Previous3Collect.PRH_Number_of_Pernod_Ricard_products__c=' + PRH_Previous3Collect.PRH_Number_of_Pernod_Ricard_products__c );
                // Retrieve informations displayed for 'Le Cercle Brands' Tab for previous 3 collect                
                try {
                    LeCercleBrands3 = 
                    [Select  
                        PRH_Collect__c ,PRH_Brand__c, PRH_Presence__c,PRH_Brand__r.RecordType.DeveloperName ,
                        PRH_Brand__r.PRH_Sequence__c,PRH_Brand__r.Name,PRH_Branded_Event__c,PRH_Visibility__c,
                        PRH_Volume__c, PRH_Number_of_Branded_Events__c
                    From PRH_Brand_Criteria__c 
                    Where PRH_Collect__c = :collect_Id
                    AND PRH_Brand__r.PRH_Competitor_Brand__c=false
                    //AND PRH_Brand__r.PRH_Active__c=true
                    Order by PRH_Brand__r.PRH_Sequence__c , PRH_Brand__r.Name
                    ];
                    System.debug('==> manageCollectDataDisplay, ' + LeCercleBrands3.size() + ' LeCercleBrands(s) retrieved for collect_Id ' + collect_Id);
                    System.debug('==> manageCollectDataDisplay, LeCercleBrands : ' + LeCercleBrands3);
                    
                    if (LeCercleBrands3.size() > 0) {
                        for (PRH_Brand_Criteria__c b:LeCercleBrands3) {
                            b.PRH_Volume__c = (b.PRH_Volume__c == null) ? 0: b.PRH_Volume__c;
                            b.PRH_Number_of_Branded_Events__c = (b.PRH_Number_of_Branded_Events__c == null) ? 0: b.PRH_Number_of_Branded_Events__c;
                        }
                    }
                } catch (Exception e) {
                    System.Debug('### manageCollectDataDisplay error:'+ e.getMessage());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getLineNumber());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getStackTraceString());
                }
                
                // Retrieve informations displayed for 'Competitor Brands' Tab
                try {
                    competitorBrands3 = [SELECT 
                                        Id, PRH_Presence__c, PRH_Volume__c,PRH_Iconic_Brand__r.Name,
                                        PRH_Iconic_Brand__r.RecordType.DeveloperName,PRH_Collect__c,
                                        PRH_Iconic_Brand__c
                                        FROM PRH_Competitor_Brands__c
                                        WHERE PRH_Collect__c=:collect_Id
                                        AND PRH_Iconic_Brand__r.PRH_Competitor_Brand__c=true
                                        //AND PRH_Iconic_Brand__r.PRH_Active__c=true
                                        //AND PRH_Iconic_Account__r.PRH_Suppress_and_archive__c=false
                                        ORDER BY PRH_Iconic_Brand__r.PRH_Sequence__c,PRH_Iconic_Brand__r.Name];
                } catch (Exception e) {
                    System.Debug('### manageCollectDataDisplay error:'+ e.getMessage());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getLineNumber());
                    System.Debug('### manageCollectDataDisplay error:'+ e.getStackTraceString());
                }
                System.debug('==> manageCollectDataDisplay, ' + competitorBrands3.size() + ' competitorBrand(s) retrieved for collect Id ' + collect_Id);   
                System.debug('==> manageCollectDataDisplay, competitorBrands3 : ' + competitorBrands3);
            }
            */
        }
    }
    
    public String getFiscalYrLabel() {
        
        Datetime dt = System.now();
        String objColumnLabel = '';
        String julyOnwardsMonth = 'FYTD '+String.valueOf(dt.year()).substring(2,4)
                    +'/'+String.valueOf(dt.year()+1).substring(2,4) + ' Vol (in Liters)';
        String belowJulyMonth = 'FYTD '+String.valueOf(dt.year()-1).substring(2,4)+'/'
                    +String.valueOf(dt.year()).substring(2,4) + ' Vol (in Liters)';

        objColumnLabel = (dt.month()>=7) ? julyOnwardsMonth : belowJulyMonth;

        return objColumnLabel;
    }

    public String getFiscalYrNbActivation() {
        
        Datetime dt = System.now();
        String objColumnLabel = '';
        String julyOnwardsMonth = 'FYTD '+String.valueOf(dt.year()).substring(2,4)
                    +'/'+String.valueOf(dt.year()+1).substring(2,4) + ' N° Activations';
        String belowJulyMonth = 'FYTD '+String.valueOf(dt.year()-1).substring(2,4)+'/'
                    +String.valueOf(dt.year()).substring(2,4) + ' N° Activations';

        objColumnLabel = (dt.month()>=7) ? julyOnwardsMonth : belowJulyMonth;

        return objColumnLabel;
    }

}