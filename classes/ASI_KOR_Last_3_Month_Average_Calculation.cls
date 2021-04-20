/*

Remarks: 
Current Assumptions made:
all values required are provided, if not , it is handled as 0

Static functions: 
i) averageBottles : returns last 3 month average number of bottles, values obtained from depletion details
                  : input values - venueID , brandID , cut-off date
                  
ii) averageCases   : returns last 3 month average number of cases, values obtained from depletion details
                   : input values - venueID , brandID, cut-off date
                  
iii) averageUnitCost  : returns last 3 month average unitcost , values obtained from SR Payment Settlement Details
                      : Final CA Cost / Actual Volume
                      : input values - venueID , brandID, cut-off-date 
                      
The rest are supporting functions, please read comments               

Daniel Lau

*/
public class ASI_KOR_Last_3_Month_Average_Calculation {

    //calculate and return the Last3-month Actual Average Volume   
    public static Decimal averageCases(String brandID ,String venueID,Date cut_off_date){
        List<ASI_KOR_Venue_Depletion_Detail__c> details = retrieveDepletionDetails(brandID ,venueID, cut_off_date);
        system.debug('Test verage cases ' + details);
        Decimal cases = 0;
        for(ASI_KOR_Venue_Depletion_Detail__c detail : details){
        
            cases = cases +  detail.ASI_KOR_Venue_Depl_Info_Depletion_Case__c;
        
        }
        //calculating the average 
        if(details.size()>0){
            cases = cases/details.size(); 
        }
        return  cases;
    }
    
    //calculate and return the Last3-month Actual Average Volume   
    public static Decimal averageBottles(String brandID,String venueID,Date cut_off_date){
        List<ASI_KOR_Venue_Depletion_Detail__c> details = retrieveDepletionDetails(brandID ,venueID,cut_off_date);
        Decimal bottles = 0;
        for(ASI_KOR_Venue_Depletion_Detail__c detail : details){
            bottles = bottles + detail.ASI_KOR_Venue_Depl_Info_Depletion_Volume__c;   
        }
        //calculating the average 
       if(details.size()>0){
            bottles = bottles/details.size();
       }
        return  bottles;
    }
    /*
    //calculate and return the Last3-month Actual Average Unit Cost   
    public static Decimal averageUnitCost( String brandID,String venueID,Date cut_off_date){
        //System.debug('Flag TEST XXXX' + brandID + ' ' + venueID + ' ' + cut_off_date + ' XXX ');
        List<ASI_KOR_SR_Payment_Settlement_Detail__c> details = retrievePaymentDetails(brandID,venueID,cut_off_date);
        system.debug('Test unitcost ' + details);
        Decimal cost  = 0;        
        //System.debug('Flag TEST XXXX' + details );
        for(ASI_KOR_SR_Payment_Settlement_Detail__c detail : details){
           
           if( detail.ASI_KOR_Actual_Volume__c != null && detail.ASI_KOR_Actual_Volume__c != 0 && detail.ASI_KOR_Final_CA_Amount_excl_Basic__c!=null ){
              cost =  cost + (detail.ASI_KOR_Final_CA_Amount_excl_Basic__c/detail.ASI_KOR_Actual_Volume__c);
           }
            
        }
        
        if(details.size()>0){
            cost = cost/details.size();
        }
        
        return cost;
    }
    */
     public static Integer averageUnitCostByBottles( String brandID,String venueID,Date cut_off_date){
        List<ASI_KOR_Venue_Depletion_Detail__c> details = retrieveDepletionDetails(brandID ,venueID,cut_off_date); 
        Decimal cost  = 0;        
        //System.debug('Flag TEST XXXX' + details );
        for(ASI_KOR_Venue_Depletion_Detail__c detail : details){
           
           if( detail.ASI_KOR_Venue_Depl_Info_Depletion_Volume__c != null && detail.ASI_KOR_Venue_Depl_Info_Depletion_Volume__c != 0 && detail.ASI_KOR_Venue_Depl_Info_Promotion_Amount__c !=null ){
              cost =  cost + (detail.ASI_KOR_Venue_Depl_Info_Promotion_Amount__c/detail.ASI_KOR_Venue_Depl_Info_Depletion_Volume__c);
           }
            
        }
        if(details.size()>0){
            cost = cost/details.size();
        }
        
        return cost.intValue();
    }
    
     public static Integer averageUnitCostByCases( String brandID,String venueID,Date cut_off_date){
        List<ASI_KOR_Venue_Depletion_Detail__c> details = retrieveDepletionDetails(brandID ,venueID,cut_off_date);
       
        Decimal cost  = 0;        
        //System.debug('Flag TEST XXXX' + details );
        for(ASI_KOR_Venue_Depletion_Detail__c detail : details){
           
           if( detail.ASI_KOR_Venue_Depl_Info_Depletion_Case__c != null && detail.ASI_KOR_Venue_Depl_Info_Depletion_Case__c != 0 && detail.ASI_KOR_Venue_Depl_Info_Promotion_Amount__c !=null ){
              cost =  cost + (detail.ASI_KOR_Venue_Depl_Info_Promotion_Amount__c/detail.ASI_KOR_Venue_Depl_Info_Depletion_Case__c);
           }
            
        }
        
        if(details.size()>0){
            cost = cost/details.size();
        }
        
        return cost.intValue();
    }
    
    /*
    // retrieve PR Payment Settlement Details according to brand and venue for last 3 months
     private static List<ASI_KOR_SR_Payment_Settlement_Detail__c> retrievePaymentDetails(String brandID ,String venueID, Date cut_off_date){
        
        List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementDetail = 
            new List<ASI_KOR_SR_Payment_Settlement_Detail__c>() ;
        Datetime cutoff =Datetime.newInstance(cut_off_date, Time.newInstance(12, 0, 0, 0));
        String month1 = cutoff.addMonths(-1).format('M');
        String year1 = cutoff.format('yyyy');
        String month2 = cutoff.addMonths(-2).format('M');
        String year2 = cutoff.format('yyyy');
        String month3 = cutoff.addMonths(-3).format('M');
        String year3 = cutoff.format('yyyy');
       
       
       List<ASI_KOR_SR_Payment_Settlement_Detail__c> settlementDetail = 
       
       [Select 
           ASI_KOR_Actual_Volume__c , ASI_KOR_UOM__c, ASI_KOR_Venue_Name__c, ASI_KOR_Final_CA_Amount_excl_Basic__c
        From 
            ASI_KOR_SR_Payment_Settlement_Detail__c 
        Where
            ASI_KOR_Venue_Name__c = :venueID AND ASI_KOR_Brand__c = :brandID AND ASI_KOR_SR_Payment_Settlement__c
                IN 
           (Select 
                ID  
            From 
                ASI_KOR_SR_Payment_Settlement_Header__c 
            where  
                ( ASI_KOR_Month__c= :month1 AND  ASI_KOR_Year__c= :year1) OR 
                ( ASI_KOR_Month__c= :month2 AND  ASI_KOR_Year__c= :year2) OR 
                ( ASI_KOR_Month__c= :month3 AND  ASI_KOR_Year__c= :year3)
            ) 
           
       ];
        
         return settlementDetail;
     }
     
     */
    
    // retrieve venue depletion details for last 3 months
    // according to brand & venue, returns a list with 
    // Venue Depletion Details containing 
    // volume (bottles), volume(cases) , depletion ID, Sub-brand name
    private static List<ASI_KOR_Venue_Depletion_Detail__c> retrieveDepletionDetails(String brandID ,String venueID, Date cut_off_date){
    
        // retrieve the current month & year 
        // get the last 3 month's month & year 
        List<ASI_KOR_Venue_Depletion_Detail__c> depletionDetailsByBrand ;
            
        Datetime cutoff =Datetime.newInstance(cut_off_date, Time.newInstance(12, 0, 0, 0));
        /* Patched by Vincent 20160129 BEGIN 
        String month1 = cutoff.addMonths(-1).format('MMMM');
        String year1 = cutoff.format('yyyy');
        String month2 = cutoff.addMonths(-2).format('MMMM');
        String year2 = cutoff.format('yyyy');
        String month3 = cutoff.addMonths(-3).format('MMMM');
        String year3 = cutoff.format('yyyy');
        */
        String month1 = cutoff.addMonths(-1).format('MMMM');
        String year1 = cutoff.addMonths(-1).format('yyyy');
        String month2 = cutoff.addMonths(-2).format('MMMM');
        String year2 = cutoff.addMonths(-2).format('yyyy');
        String month3 = cutoff.addMonths(-3).format('MMMM');
        String year3 = cutoff.addMonths(-3).format('yyyy');
        /* Patched by Vincent 20160129 END */
        
        // if there's a selected venue query for the venue depletion ID within 3 months
        //  retrieve venue depletion details using venue depletion ID
        if(venueID != null){
                 List<ASI_KOR_Sub_Brand__c> subs = [Select Name From 
                        ASI_KOR_Sub_Brand__c 
                    where 
                        ASI_KOR_Brand__c =:brandID];             
                 Set<String> subBrands = new Set<String>();
                 for (ASI_KOR_Sub_Brand__c sub:subs )           
                 {
                     subBrands.add(sub.name);   
                 }
                // obtain venue depletion details using the venue depletion id obtain 
                // in the previous SOQL
                depletionDetailsByBrand =  
                    [Select 
                         ASI_KOR_Venue_Depl_Info_Depletion_Volume__c,
                         ASI_KOR_Venue_Depl_Info_Depletion_Case__c, 
                         ASI_KOR_Sub_Brand__c,
                         ASI_KOR_Venue_Depletion__c,
                         ASI_KOR_Venue_Depl_Info_Promotion_Amount__c
                     From 
                         ASI_KOR_Venue_Depletion_Detail__c 
                     where 
                         ASI_KOR_Venue_Depletion__c IN 
                         
                         (Select 
                              Id 
                          from 
                              ASI_KOR_Venue_Depletion__c 
                         where  
                              ((ASI_KOR_Month__c = :month1 AND ASI_KOR_Year__c = :year1) OR 
                              (ASI_KOR_Month__c = :month2 AND ASI_KOR_Year__c = :year2) OR 
                              (ASI_KOR_Month__c = :month3 AND ASI_KOR_Year__c = :year3))AND 
                               ASI_KOR_Venue__c =:venueID
                          )
                         and
                         ASI_KOR_Sub_Brand__c in: subBrands
                    ];


                 // Verify brand and return last 3 month venue depletion details 
                 // according to the brand & venue provided
               /* 
                for( ASI_KOR_Venue_Depletion_Detail__c detail : details){
                   
                   List <ASI_KOR_Sub_Brand__c> brandIDs =
                   [Select 
                       ASI_KOR_Brand__c 
                    From 
                        ASI_KOR_Sub_Brand__c 
                    where 
                        Name = :detail.ASI_KOR_Sub_Brand__c
                    ];
                        
                     for(ASI_KOR_Sub_Brand__c id : brandIDs){
                     
                         if (id.ASI_KOR_Brand__c == brandID){
                             depletionDetailsByBrand.add(detail);
                         }
                     
                     }   
                }      */
                  
        } 
        //List containing venue depletion details
        return depletionDetailsByBrand;
        
    }
    
     
    
  }