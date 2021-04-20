/*
    Developed by Kevani Chow: 17/05/2016
    Batch to Count no. of Active Contracts for each Outlet per fiscal year 
*/
global with sharing class ASI_CRM_TH_ActiveContractBatch implements Database.Batchable<sObject> ,Database.Stateful{
   global Database.QueryLocator start(Database.BatchableContext BC){
   
      Id OutletRecordTypeId = Global_RecordTypeCache.getRTId('AccountASI_TH_CRM_Outlet');
      
      String soqlQuery = 'SELECT Id, Name FROM Account WHERE RecordTypeId ='+ '\'' +OutletRecordTypeId+ '\''; //+'ORDER BY Name'
      System.debug('soqlQuery:' + soqlQuery);
   
      return Database.getQueryLocator(soqlQuery);
      
   }

   global void execute(Database.BatchableContext BC,  List<sObject> scope){
   
      if (scope == null) return;
      
      set<Id> setOutlet = new set<Id>();
      for(sObject sObj : scope){
          setOutlet.add(sObj.id);
      }
      
      //defining fiscal year
       String FiscalYear;
       String FiscalYearend1;
       String FiscalYearend2;
       String FiscalYearend3;
       String FiscalYearThisYTD;
       String FiscalYearLastYTD;
       String FiscalYearLast2YTD;
       
       
       Date snapshotdate = date.today();
       List <ASI_TH_CRM_CustomSetting__c> snapshotdateValue  = [SELECT ASI_CRM_TH_Snapshot_Date__c FROM ASI_TH_CRM_CustomSetting__c LIMIT 1];
       if (snapshotdateValue[0].ASI_CRM_TH_Snapshot_Date__c!=null)
           snapshotdate =snapshotdateValue[0].ASI_CRM_TH_Snapshot_Date__c;
       
       Date thisFYstart;
       Date thisFYend;
       Date thisYTD = snapshotdate;
       Date lastYTD = date.newInstance(snapshotdate.year()-1, snapshotdate.month(), snapshotdate.day());
       Date last2YTD = date.newInstance(snapshotdate.year()-2, snapshotdate.month(), snapshotdate.day());
       Date lastFYstart;
       Date lastFYend;
       Date last2FYstart;
       Date last2FYend;
       
       
       if(date.today().month()>6){
           thisFYstart = date.newInstance(date.today().year(), 7, 1);
           thisFYend = date.newInstance(date.today().year()+1, 6, 30);
           lastFYstart = date.newInstance(date.today().year()-1, 7, 1);
           lastFYend = date.newInstance(date.today().year(), 6, 30);
           last2FYstart = date.newInstance(date.today().year()-2, 7, 1);
           last2FYend = date.newInstance(date.today().year()-1, 6, 30);
        }else{
           thisFYstart = date.newInstance(date.today().year()-1, 7, 1);
           thisFYend = date.newInstance(date.today().year(), 6, 30);
           lastFYstart = date.newInstance(date.today().year()-2, 7, 1);
           lastFYend = date.newInstance(date.today().year()-1, 6, 30);
           last2FYstart = date.newInstance(date.today().year()-3, 7, 1);
           last2FYend = date.newInstance(date.today().year()-2, 6, 30);
        }
        
        system.debug('last2FYstart: '+last2FYstart);
        system.debug('thisFYend: '+thisFYend);
      
      //query contracts within last 2 fiscal years to this fiscal year
      Id ContractRecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_TH_CRM_Contract');
      List<ASI_TH_CRM_Contract__c> lstExisitContract= [Select Id, Name, ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Start_Date__c, 
                                                              ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Outlet__c FROM ASI_TH_CRM_Contract__c 
                                                              WHERE  ASI_TH_CRM_Outlet__c IN:setOutlet AND RecordTypeId =: ContractRecordTypeId
                                                              AND ((ASI_TH_CRM_Start_Date__c >=: last2FYstart AND ASI_TH_CRM_Start_Date__c <=: thisFYend)
                                                                    OR (ASI_TH_CRM_End_Date__c >=: last2FYstart AND ASI_TH_CRM_End_Date__c <=: thisFYend)
                                                                    OR (ASI_TH_CRM_Start_Date__c <: last2FYstart AND ASI_TH_CRM_End_Date__c >: thisFYend)) 
                                                              AND (ASI_TH_CRM_Contract_Status__c = 'Freeze' OR ASI_TH_CRM_Contract_Status__c = 'Completed' 
                                                              OR ASI_TH_CRM_Contract_Status__c = 'Editing') ORDER BY ASI_TH_CRM_Outlet__c];
      
       
       system.debug('lstExisitContract: '+lstExisitContract);
       Id activeContractId = Global_RecordTypeCache.getRTId('ASI_CRM_No_of_Active_Contracts__cASI_CRM_TH_No_of_Active_Contracts');
       List<ASI_CRM_No_of_Active_Contracts__c> lstExistingAC = [SELECT Id, ASI_CRM_Account__c, ASI_CRM_Fiscal_Year__c, ASI_CRM_No_of_Active_Contracts__c, ASI_CRM_No_of_Active_Contracts_YTD__c, ASI_CRM_Snapshot_Date__c, ASI_CRM_Customer__c FROM ASI_CRM_No_of_Active_Contracts__c WHERE RecordTypeId =:activeContractId AND ASI_CRM_Account__c IN :setOutlet];

       system.debug('lstExistingAC: '+lstExistingAC);
       Map<String, ASI_CRM_No_of_Active_Contracts__c> mapExisitingAC = new Map<String, ASI_CRM_No_of_Active_Contracts__c>();
       Map<String, ASI_CRM_No_of_Active_Contracts__c> mapACCount = new Map<String, ASI_CRM_No_of_Active_Contracts__c>();
       Map<String, ASI_CRM_No_of_Active_Contracts__c> mapACCountYTD = new Map<String, ASI_CRM_No_of_Active_Contracts__c>();
       List<ASI_CRM_No_of_Active_Contracts__c> lstUpsertAC = new List<ASI_CRM_No_of_Active_Contracts__c>();
       
       if(lstExistingAC!=null && lstExistingAC.size()>0){
           for (ASI_CRM_No_of_Active_Contracts__c ac: lstExistingAC){
                   //mapExisitingAC.put(ac.ASI_CRM_Account__c+ac.ASI_CRM_Fiscal_Year__c,ac);
                   mapExisitingAC.put(ac.ASI_CRM_Account__c+ac.ASI_CRM_Fiscal_Year__c+ac.ASI_CRM_Snapshot_Date__c.month(),ac);
           }
       }
       system.debug('mapExisitingAC: '+mapExisitingAC);

       //customer
       List<ASI_CRM_AccountsAdditionalField__c> lstCustomer = [SELECT Id, ASI_CRM_Account__c, Name FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN:setOutlet];
       system.debug('lstCustomer: '+lstCustomer);
       Map<Id,ASI_CRM_AccountsAdditionalField__c> MapCustomer= new Map<Id,ASI_CRM_AccountsAdditionalField__c>();
       if(lstCustomer!=null && lstCustomer.size()>0){
           for (ASI_CRM_AccountsAdditionalField__c cus: lstCustomer){
               if(cus.ASI_CRM_Account__c!=null)
                   MapCustomer.put(cus.ASI_CRM_Account__c,cus);
           }
      }


       
       for(ASI_TH_CRM_Contract__c contractToCount : lstExisitContract){

           

           FiscalYear='';
           FiscalYearend1='';
           FiscalYearend2='';
           FiscalYearend3='';
           FiscalYearThisYTD='';
           FiscalYearLastYTD='';
           FiscalYearLast2YTD='';
           
           ///////////////////Start Of Fiscal Year Defination//////////////////
              //Which Fiscal Year of Contract start date 
           if (contractToCount.ASI_TH_CRM_Start_Date__c >= thisFYstart && contractToCount.ASI_TH_CRM_Start_Date__c <= thisFYend)
               FiscalYear =  'FY'+string.valueof(thisFYstart).subString(2,4)+string.valueof(thisFYend).subString(2,4);
            
           if (contractToCount.ASI_TH_CRM_Start_Date__c >= lastFYstart && contractToCount.ASI_TH_CRM_Start_Date__c <= lastFYend)
               FiscalYear =  'FY'+string.valueof(lastFYstart).subString(2,4)+string.valueof(lastFYend).subString(2,4);
           
           if (contractToCount.ASI_TH_CRM_Start_Date__c >= last2FYstart && contractToCount.ASI_TH_CRM_Start_Date__c <= last2FYend)
               FiscalYear =  'FY'+string.valueof(last2FYstart).subString(2,4)+string.valueof(last2FYend).subString(2,4);
           
           //Which Fiscal Year of Contract end date
           if((contractToCount.ASI_TH_CRM_End_Date__c <= last2FYend && contractToCount.ASI_TH_CRM_End_Date__c >= last2FYstart)||(contractToCount.ASI_TH_CRM_Start_Date__c <= last2FYend && contractToCount.ASI_TH_CRM_End_Date__c >= last2FYend))
               FiscalYearend1 =  'FY'+string.valueof(last2FYstart).subString(2,4)+string.valueof(last2FYend).subString(2,4);
               
           if((contractToCount.ASI_TH_CRM_End_Date__c <= lastFYend && contractToCount.ASI_TH_CRM_End_Date__c >= lastFYstart)||(contractToCount.ASI_TH_CRM_Start_Date__c <= lastFYend && contractToCount.ASI_TH_CRM_End_Date__c >= lastFYend))
               FiscalYearend2 =  'FY'+string.valueof(lastFYstart).subString(2,4)+string.valueof(lastFYend).subString(2,4);
               
           if((contractToCount.ASI_TH_CRM_End_Date__c <= thisFYend && contractToCount.ASI_TH_CRM_End_Date__c >= thisFYstart)||(contractToCount.ASI_TH_CRM_Start_Date__c <= thisFYend && contractToCount.ASI_TH_CRM_End_Date__c >= thisFYend))
               FiscalYearend3 =  'FY'+string.valueof(thisFYstart).subString(2,4)+string.valueof(thisFYend).subString(2,4); 
           
           //Which Fiscal Year of SnapshotDate
            if((contractToCount.ASI_TH_CRM_End_Date__c <= thisYTD && contractToCount.ASI_TH_CRM_End_Date__c >= thisFYstart)||(contractToCount.ASI_TH_CRM_Start_Date__c <= thisYTD && contractToCount.ASI_TH_CRM_End_Date__c >= thisYTD))
               FiscalYearThisYTD = 'FY'+string.valueof(thisFYstart).subString(2,4)+string.valueof(thisFYend).subString(2,4);
            
            if((contractToCount.ASI_TH_CRM_End_Date__c <= lastYTD && contractToCount.ASI_TH_CRM_End_Date__c >= lastFYstart)||(contractToCount.ASI_TH_CRM_Start_Date__c <= lastYTD && contractToCount.ASI_TH_CRM_End_Date__c >= lastYTD))
               FiscalYearLastYTD = 'FY'+string.valueof(lastFYstart).subString(2,4)+string.valueof(lastFYend).subString(2,4);
            
            if((contractToCount.ASI_TH_CRM_End_Date__c <= last2YTD && contractToCount.ASI_TH_CRM_End_Date__c >= last2FYstart)||(contractToCount.ASI_TH_CRM_Start_Date__c <= last2YTD && contractToCount.ASI_TH_CRM_End_Date__c >= last2YTD))
               FiscalYearLast2YTD = 'FY'+string.valueof(last2FYstart).subString(2,4)+string.valueof(last2FYend).subString(2,4);

           
           ///////////////////End Of Fiscal Year Defination//////////////////          
              //Contract Start Date
              system.debug('FiscalYear: '+FiscalYear);
              if(FiscalYear!=''){
                  ASI_CRM_No_of_Active_Contracts__c noActiveContract = new ASI_CRM_No_of_Active_Contracts__c();
                  if(mapExisitingAC.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYear+snapshotdate.month())!=null){
                       //update
                       noActiveContract.id =mapExisitingAC.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYear+snapshotdate.month()).id;
                   }
                       if(mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYear+snapshotdate.month())!=null && mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYear+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts__c!=null){
                           //check if the map count contain record, if contains, just update count
                           noActiveContract.ASI_CRM_No_of_Active_Contracts__c = mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYear+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts__c+1;
                               
                       }else{
                           //insert
                           noActiveContract.ASI_CRM_No_of_Active_Contracts__c =1;
                           noActiveContract.ASI_CRM_Account__c = contractToCount.ASI_TH_CRM_Outlet__c;
                           if(MapCustomer.get(contractToCount.ASI_TH_CRM_Outlet__c)!=null)
                               noActiveContract.ASI_CRM_Customer__c = MapCustomer.get(contractToCount.ASI_TH_CRM_Outlet__c).id;
                           noActiveContract.ASI_CRM_Fiscal_Year__c = FiscalYear;
                           noActiveContract.RecordTypeId=activeContractId;
                        }
                        
                       if(FiscalYearThisYTD==FiscalYear||FiscalYearLastYTD==FiscalYear||FiscalYearLast2YTD==FiscalYear){ 
                            if(mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYear+snapshotdate.month())!=null && mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYear+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts_YTD__c!=null){
                                noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYear+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts_YTD__c+1;
                            
                            }else{
                                noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=1;
                            }
                        }else{
                            noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=null;
                        } 
                        
                     noActiveContract.ASI_CRM_Snapshot_Date__c=snapshotdate;
                     if(contractToCount.ASI_TH_CRM_Outlet__c!=null)
                         mapACCount.put(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYear+snapshotdate.month(),noActiveContract);    
                }
                
           
           
            //Contract End Date
            if(FiscalYearend1!=''){
               if(FiscalYear!=FiscalYearend1){
                ASI_CRM_No_of_Active_Contracts__c noActiveContract = new ASI_CRM_No_of_Active_Contracts__c();
                      if (mapExisitingAC.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend1+snapshotdate.month())!=null){
                           //update
                          noActiveContract.id = mapExisitingAC.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend1+snapshotdate.month()).id;
                      }
                      if(mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend1+snapshotdate.month())!=null && mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend1+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts__c!=null){
                           //check if the map count contain record, if contains, just update count
                           noActiveContract.ASI_CRM_No_of_Active_Contracts__c = mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend1+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts__c+1;
                       }else{
                          //insert
                          noActiveContract.ASI_CRM_No_of_Active_Contracts__c =1;
                          noActiveContract.ASI_CRM_Account__c = contractToCount.ASI_TH_CRM_Outlet__c;
                          if(MapCustomer.get(contractToCount.ASI_TH_CRM_Outlet__c)!=null)
                              noActiveContract.ASI_CRM_Customer__c = MapCustomer.get(contractToCount.ASI_TH_CRM_Outlet__c).id;
                          noActiveContract.ASI_CRM_Fiscal_Year__c = FiscalYearend1;
                          noActiveContract.RecordTypeId=activeContractId;
                      } 
                        
                      if(FiscalYearThisYTD==FiscalYearend1||FiscalYearLastYTD==FiscalYearend1||FiscalYearLast2YTD==FiscalYearend1){ 
                            if(mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend1+snapshotdate.month())!=null && mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend1+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts_YTD__c!=null){
                                noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend1+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts_YTD__c+1;
                            
                            }else{
                                noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=1;
                            }
                        }else{
                            noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=null;
                        } 
                       
                    //upsert the map count
                         noActiveContract.ASI_CRM_Snapshot_Date__c=snapshotdate;
                         if(contractToCount.ASI_TH_CRM_Outlet__c!=null)
                             mapACCount.put(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend1+snapshotdate.month(),noActiveContract);

                }     
            }
            
            if(FiscalYearend2!=''){
               if(FiscalYear!=FiscalYearend2){
               ASI_CRM_No_of_Active_Contracts__c noActiveContract = new ASI_CRM_No_of_Active_Contracts__c();
                      if (mapExisitingAC.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend2+snapshotdate.month())!=null){
                           //update
                          noActiveContract.id = mapExisitingAC.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend2+snapshotdate.month()).id;
                      }
                      
                      if(mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend2+snapshotdate.month())!=null && mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend2+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts__c!=null){
                           //check if the map count contain record, if contains, just update count
                           noActiveContract.ASI_CRM_No_of_Active_Contracts__c = mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend2+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts__c+1;
                       }else{
                          //insert
                          noActiveContract.ASI_CRM_No_of_Active_Contracts__c =1;
                          noActiveContract.ASI_CRM_Account__c = contractToCount.ASI_TH_CRM_Outlet__c;
                          if(MapCustomer.get(contractToCount.ASI_TH_CRM_Outlet__c)!=null)
                              noActiveContract.ASI_CRM_Customer__c = MapCustomer.get(contractToCount.ASI_TH_CRM_Outlet__c).id;
                          noActiveContract.ASI_CRM_Fiscal_Year__c = FiscalYearend2;
                          noActiveContract.RecordTypeId=activeContractId;
                      }   
                       
                      if(FiscalYearThisYTD==FiscalYearend2||FiscalYearLastYTD==FiscalYearend2||FiscalYearLast2YTD==FiscalYearend2){ 
                            if(mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend2+snapshotdate.month())!=null && mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend2+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts_YTD__c!=null){
                                noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend2+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts_YTD__c+1;
                            
                            }else{
                                noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=1;
                            }
                        }else{
                            noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=null;
                        } 
                       
                    //upsert the map count
                         noActiveContract.ASI_CRM_Snapshot_Date__c=snapshotdate;
                         if(contractToCount.ASI_TH_CRM_Outlet__c!=null)
                             mapACCount.put(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend2+snapshotdate.month(),noActiveContract);

                }     
            }
            
            if(FiscalYearend3!=''){
               if(FiscalYear!=FiscalYearend3){
               ASI_CRM_No_of_Active_Contracts__c noActiveContract = new ASI_CRM_No_of_Active_Contracts__c();
                      if (mapExisitingAC.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend3+snapshotdate.month())!=null){
                          //check if the map count contain record, if contains, just update count
                          noActiveContract.id = mapExisitingAC.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend3+snapshotdate.month()).id;
                      }
                      if(mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend3+snapshotdate.month())!=null && mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend3+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts__c!=null){
                           noActiveContract.ASI_CRM_No_of_Active_Contracts__c = mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend3+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts__c+1;
                       }else{
                           //insert
                          noActiveContract.ASI_CRM_No_of_Active_Contracts__c =1;
                          noActiveContract.ASI_CRM_Account__c = contractToCount.ASI_TH_CRM_Outlet__c;
                          if(MapCustomer.get(contractToCount.ASI_TH_CRM_Outlet__c)!=null)
                              noActiveContract.ASI_CRM_Customer__c = MapCustomer.get(contractToCount.ASI_TH_CRM_Outlet__c).id;
                          noActiveContract.ASI_CRM_Fiscal_Year__c = FiscalYearend3;
                          noActiveContract.RecordTypeId=activeContractId;
                      }
                      if(FiscalYearThisYTD==FiscalYearend3||FiscalYearLastYTD==FiscalYearend3||FiscalYearLast2YTD==FiscalYearend3){ 
                            if(mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend3+snapshotdate.month())!=null && mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend3+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts_YTD__c!=null){
                                noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=mapACCount.get(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend3+snapshotdate.month()).ASI_CRM_No_of_Active_Contracts_YTD__c+1;
                            
                            }else{
                                noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=1;
                            }
                        }else{
                            noActiveContract.ASI_CRM_No_of_Active_Contracts_YTD__c=null;
                        } 
                       
                    //upsert the map count
                        noActiveContract.ASI_CRM_Snapshot_Date__c=snapshotdate;
                        if(contractToCount.ASI_TH_CRM_Outlet__c!=null)
                            mapACCount.put(contractToCount.ASI_TH_CRM_Outlet__c+FiscalYearend3+snapshotdate.month(),noActiveContract);

                }     
            }
             
               
               
               
               system.debug('mapACCount: '+mapACCount);
           }
           
           for (ASI_CRM_No_of_Active_Contracts__c lstUpdatemap : mapACCount.values()){
           
               lstUpsertAC.add(lstUpdatemap);
           }

        system.debug('lstUpsertAC: '+lstUpsertAC);
        Upsert lstUpsertAC;
   }
   

   global void finish(Database.BatchableContext BC){
        system.debug('finish running!');
   } 
}