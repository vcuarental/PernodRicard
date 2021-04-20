public class ASI_KOR_Payment_Settlement_Detail_ActVol{
      
      public static Decimal getVolumeByCase (String brandID ,String venueID, String year , String month){
      
          List<ASI_KOR_Venue_Depletion_Detail__c> depletionDetails = retrieveDepletionDetails(brandID,venueID,year,month);
          
          Decimal actualcase = 0;
          
          for(ASI_KOR_Venue_Depletion_Detail__c depletionDetail : depletionDetails){
              actualCase = actualCase + depletionDetail.ASI_KOR_Venue_Depl_Info_Depletion_Case__c;
          } 
          
          return actualCase;
                         
      }
      
      public static Decimal getVolumeByBottle(String brandID ,String venueID, String year , String month){
      
          List<ASI_KOR_Venue_Depletion_Detail__C> depletionDetails = retrieveDepletionDetails(brandID,venueID,year,month);
          
          Decimal actualBottle = 0;
          
          for(ASI_KOR_Venue_Depletion_Detail__c depletionDetail : depletionDetails){
              actualBottle = actualBottle + depletionDetail.ASI_KOR_Venue_Depl_Info_Depletion_Volume__c;
          } 
          
          return actualBottle;
      }
      
      /*
          Values needed: brandID , venueID, , Year mmonth
          retrieves Depletion details that contains the sub-brand, venue depletion ID, actual volume in case/bottle for the sub-brand
          All sub brand Depletion details returned will belong to the brand provided.
      */
        
      private static List<ASI_KOR_Venue_Depletion_Detail__c> retrieveDepletionDetails
                          (String brandID ,String venueID, String year , String month){
        
        List<ASI_KOR_Venue_Depletion_Detail__c> depletionDetailsByBrand = null;

        
        List<ASI_KOR_NSD_Payment_Settlement_Header__c> cutOffTime=
            [Select 
                ASI_KOR_SYS_Cut_off_Date__c 
             from 
                ASI_KOR_NSD_Payment_Settlement_Header__c 
             where 
                ASI_KOR_Month__c = :month and 
                ASI_KOR_Year__c = :year Limit 1
             ];
            
         Date cutOffDate = cutOffTime.get(0).ASI_KOR_SYS_Cut_off_Date__c;
        
        
         Date tempDate=Date.newInstance(integer.valueOf(year), 
            integer.valueOf(month), 
            integer.valueOf('01'));
            
            month = Datetime.newInstance(tempDate, Time.newInstance(12, 0, 0, 0)).format('MMMM');      
      
        //  retrieve venue depletion details using venue depletion ID
        if(venueID != null){
        
              List<ASI_KOR_Sub_Brand__c> subs = [Select Name From 
                        ASI_KOR_Sub_Brand__c 
                    where 
                        ASI_KOR_Brand__c =:brandID];
     
     Set<String> strings = new Set<String>();
     
     for (ASI_KOR_Sub_Brand__c sub:subs )                   
     {
         strings.add(sub.name);  
     
     }

                // obtain venue depletion details using the venue depletion id obtain 
                // in the previous SOQL
                depletionDetailsByBrand  =  
                    [Select 
                         ASI_KOR_Venue_Depl_Info_Depletion_Volume__c,
                         ASI_KOR_Venue_Depl_Info_Depletion_Case__c, 
                         ASI_KOR_Sub_Brand__c,
                         ASI_KOR_Venue_Depletion__c 
                     From 
                         ASI_KOR_Venue_Depletion_Detail__c 
                     where 
                         ASI_KOR_Venue_Depletion__c IN 
                         
                         (Select 
                              Id 
                          from 
                              ASI_KOR_Venue_Depletion__c 
                         where  
                              ASI_KOR_Month__c = :month AND 
                              ASI_KOR_Year__c = :year AND                              
                              ASI_KOR_Venue__c =:venueID 
                              AND createdDate  <= :cutOffDate
                          ) and ASI_KOR_Sub_Brand__c in :strings 
                    ];
           
               System.debug('XXX Flag0: ' + depletionDetailsByBrand  );
                  
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
                }  */    
                      
        } 
        //List containing venue depletion details
        return depletionDetailsByBrand;
        
    }
    
     
    
  

}