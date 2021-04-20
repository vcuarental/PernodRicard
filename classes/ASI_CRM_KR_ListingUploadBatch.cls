public with sharing class ASI_CRM_KR_ListingUploadBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public ASI_MFM_Mass_Upload_Log__c log {get;set;}
    public List<ASI_CRM_KR_TempListedMenuPrice__c> TempDataList =new List<ASI_CRM_KR_TempListedMenuPrice__c> (); //storing temp listing data
    public Set<string> SearchOldListingIDSet =new Set<string> ();  //for storing old Listing Header Key
    public Set<string> OldListingIDSet =new Set<string> ();
    public List<ASI_CRM_KR_TempListedMenuPrice__c> UpsertLineList =new List<ASI_CRM_KR_TempListedMenuPrice__c> (); //for insert/update
    public class interimData { 
        ASI_CRM_KR_Listed_Menu_Price__c create_Header {set;get;}    
        ASI_KOR_Venue_Listed_Menu_Product__c create_Line {set;get;}  
    }
    public List<ASI_CRM_KR_Listed_Menu_Price__c> InsertListingHeaderList =new List<ASI_CRM_KR_Listed_Menu_Price__c> ();
    public Map<string,interimData> InsertListingLineMap =new Map<string,interimData> ();
    public Map<ID,ASI_CRM_KR_Listed_Menu_Price__c> AfterInsetHeaderMap =new Map<ID,ASI_CRM_KR_Listed_Menu_Price__c> (); 
    public List<ASI_KOR_Venue_Listed_Menu_Product__c> ListingLineList =new List<ASI_KOR_Venue_Listed_Menu_Product__c> ();   // Insert SIT Line
    public Set<string> LineInsertIDSet =new Set<string> ();  //purpose: if before running this class, header is already existed, but no detail line(s)
    public integer TotalRecordCount {set;get;}
    
    public ASI_CRM_KR_ListingUploadBatch(ASI_MFM_Mass_Upload_Log__c MFMlog){
        this.log=MFMlog;
        log.ASI_MFM_Error_Message__c='';  
    }
    
    public database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id, ASI_CRM_KR_Venue__c,ASI_CRM_KR_Quarter__c, ASI_CRM_KR_Fiscal_Year__c, ASI_CRM_KR_Item_Group_Code__c, ASI_CRM_KR_Listed_Price__c,ASI_CRM_KR_Unique_ID__c
                                        from ASI_CRM_KR_TempListedMenuPrice__c 
                                        where ASI_CRM_KR_AccountOwnerChecking__c=true]);
        
        
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        TotalRecordCount = 0;
        System.Savepoint sp = database.setSavepoint(); 
        OldListingIDSet = new Set<string> ();
        Map<string,string> ListingHeader_Key_ID_List = new Map<string,string> (); 
        UpsertLineList =new List<ASI_CRM_KR_TempListedMenuPrice__c> ();
        Set<string> HeaderIdSet =new Set<string> ();
        InsertListingHeaderList =new List<ASI_CRM_KR_Listed_Menu_Price__c> ();
        InsertListingLineMap =new Map<string,interimData> ();
        ListingLineList =new List<ASI_KOR_Venue_Listed_Menu_Product__c> (); 
        
        //Prepare the Temp Data List
        for(ASI_CRM_KR_TempListedMenuPrice__c TempDataListRecord : (List<ASI_CRM_KR_TempListedMenuPrice__c>)scope){
            string TempDataListRecordASI_CRM_KR_Venue;                                                         
                if(string.valueof(TempDataListRecord.ASI_CRM_KR_Venue__c).length() > 15){
                     TempDataListRecordASI_CRM_KR_Venue = (string.valueof(TempDataListRecord.ASI_CRM_KR_Venue__c)).left(15);
                }    
            
            String HeaderID = TempDataListRecord.ASI_CRM_KR_Fiscal_Year__c + '_'+  TempDataListRecord.ASI_CRM_KR_Quarter__c + '_'+ TempDataListRecordASI_CRM_KR_Venue ;
            SearchOldListingIDSet.add(HeaderID);
            TempDataList.add(TempDataListRecord);
            LineInsertIDSet.add(HeaderID);
        }
        
        
        
        //Prepare Existing Listed Menu Price Entries List
        for(ASI_CRM_KR_Listed_Menu_Price__c oldListingHeader : [select id, ASI_CRM_KR_Unique_ID__c
                                                                from ASI_CRM_KR_Listed_Menu_Price__c 
                                                                where ASI_CRM_KR_Unique_ID__c in: SearchOldListingIDSet and recordtype.developername = 'ASI_CRM_KR']){
            OldListingIDSet.add(oldListingHeader.ASI_CRM_KR_Unique_ID__c);  //Put all external ID in OldListingIDSet
            ListingHeader_Key_ID_List.put(oldListingHeader.ASI_CRM_KR_Unique_ID__c,oldListingHeader.id);
        }
        
        
        
        for(ASI_CRM_KR_TempListedMenuPrice__c templine : TempDataList){
            string templineASI_CRM_KR_Venue;                                                         
            if(string.valueof(templine.ASI_CRM_KR_Venue__c).length() > 15){
                templineASI_CRM_KR_Venue = (string.valueof(templine.ASI_CRM_KR_Venue__c)).left(15);
            }      
            
            String HeaderID = templine.ASI_CRM_KR_Fiscal_Year__c + '_'+ templine.ASI_CRM_KR_Quarter__c  + '_' +   templineASI_CRM_KR_Venue;
            
            if(OldListingIDSet.contains(HeaderID)){ //Header is already created, no need to create Header for that temp ine
                UpsertLineList.add(templine);
            }
            else{
                //Need to create Listing Header since there is no existing Listing Header
                if(!HeaderIdSet.contains(HeaderID)){
                     HeaderIdSet.add(HeaderID);
                    interimData temp =new interimData();
                    
                    ASI_CRM_KR_Listed_Menu_Price__c ListingHeader = new ASI_CRM_KR_Listed_Menu_Price__c(ASI_CRM_KR_Quarter__c = templine.ASI_CRM_KR_Quarter__c,
                                                                                                       ASI_CRM_KR_Fiscal_Year__c = templine.ASI_CRM_KR_Fiscal_Year__c,
                                                                                                       ASI_CRM_KR_Venue__c = templine.ASI_CRM_KR_Venue__c);
                    temp.create_Header=ListingHeader;
                    InsertListingHeaderList.add(ListingHeader); //Put in InsertListingHeaderList for later inserting to database
                    
                    //Put data to Listing Line preparing for Listing Line Creation
                    interimData tempNew =new interimData();
                    tempNew.create_Line= new ASI_KOR_Venue_Listed_Menu_Product__c(ASI_KOR_Item_Group_Code__c = templine.ASI_CRM_KR_Item_Group_Code__c,
                                                                                 ASI_KOR_Listed_Price__c = templine.ASI_CRM_KR_Listed_Price__c,
                                                                                 ASI_CRM_KR_HeaderID_Upload__c = HeaderID,
                                                                                 ASI_KOR_ListedMenuProduct_to_Venue_Link__c= templine.ASI_CRM_KR_Venue__c); //ASI_CRM_KR_Listed_Menu_Product_Header__c
                
                	InsertListingLineMap.put(templine.ASI_CRM_KR_Unique_ID__c, tempNew);
                	SearchOldListingIDSet.add(HeaderID);
                	LineInsertIDSet.remove(HeaderID);
                }
                else{
                    // Put data to Listing Line preparing for Listing Line Creation
                    interimData tempNew =new interimData();
                    tempNew.create_Line= new ASI_KOR_Venue_Listed_Menu_Product__c(ASI_KOR_Item_Group_Code__c = templine.ASI_CRM_KR_Item_Group_Code__c,
                                                                                 ASI_KOR_Listed_Price__c = templine.ASI_CRM_KR_Listed_Price__c,
                                                                                 ASI_CRM_KR_HeaderID_Upload__c = HeaderID,
                                                                                 ASI_KOR_ListedMenuProduct_to_Venue_Link__c= templine.ASI_CRM_KR_Venue__c); //ASI_CRM_KR_Listed_Menu_Product_Header__c
                    InsertListingLineMap.put(templine.ASI_CRM_KR_Unique_ID__c, tempNew); 
                    LineInsertIDSet.remove(HeaderID);
                }
            }
        }
        
        if(InsertListingHeaderList.size()>0){ 
            try{
                
                insert InsertListingHeaderList;   //Insert Header
                } catch (DmlException dmle) {
                log.ASI_MFM_Error_Message__c+= dmle.getMessage() ;
                database.rollback(sp);
                } catch (Exception e) {
                log.ASI_MFM_Error_Message__c+=e.getMessage() ;
                database.rollback(sp);
                
                } 
            
        }
        
        //------------------------------------------------------------Insert Listing Line-----------------------------------------------------//
        //Get Header ID after inserted for mapping Listing Line to Header
        
        AfterInsetHeaderMap =new Map<ID,ASI_CRM_KR_Listed_Menu_Price__c> (); 
        for (ASI_CRM_KR_Listed_Menu_Price__c eachHeader : [select id, ASI_CRM_KR_Quarter__c,  ASI_CRM_KR_Fiscal_Year__c, ASI_CRM_KR_Venue__c, ASI_CRM_KR_Unique_ID__c
                                                           from ASI_CRM_KR_Listed_Menu_Price__c 
                                                           where ASI_CRM_KR_Unique_ID__c in: SearchOldListingIDSet and recordtype.developername = 'ASI_CRM_KR']){
            AfterInsetHeaderMap.put(eachHeader.id, eachHeader); 

        }
        
        for(String UPLOAD_ID : InsertListingLineMap.keyset()){ //InsertListingLineMap stores Listing Line that needs to create Listing line. Listing Header is just created
             
            ASI_KOR_Venue_Listed_Menu_Product__c temp1 = InsertListingLineMap.get(UPLOAD_ID).create_line;
            
             for (String eachHeader : AfterInsetHeaderMap.keyset()){
                 
                 string MappingKey = string.valueOf(AfterInsetHeaderMap.get(eachHeader).ASI_CRM_KR_Unique_ID__c); 
                //  SYSTEM.assertEquals(temp1.ASI_CRM_KR_HeaderID_Upload__c,NULL); //FY1617_Q4_001L000000p2VNcIAM = FY1617_Q4_001L000000p2VNc
                 if(temp1.ASI_CRM_KR_HeaderID_Upload__c == MappingKey){
                     
                     temp1.ASI_CRM_KR_Listed_Menu_Product_Header__c = eachHeader;  
                     if(temp1.ASI_CRM_KR_Listed_Menu_Product_Header__c != null){	       
                        ListingLineList.add(temp1);  
                    }
                 }
             }
        }
        
        if(ListingLineList.size() > 0 ){
            try{
                TotalRecordCount = ListingLineList.size();
                insert ListingLineList;
                log.ASI_MFM_Configuration__c = '';
                log.ASI_MFM_Configuration__c = TotalRecordCount + ' record(s) upserted.';
            
            }catch (DmlException dmle) {
                //system.assertEquals(null,  dmle.getMessage());
                log.ASI_MFM_Error_Message__c+=dmle.getMessage() ;  
                database.rollback(sp);
            }catch (Exception e){
                //system.assertEquals(null, e);
                log.ASI_MFM_Error_Message__c+=e.getMessage() ;  
                database.rollback(sp);
            }
            
        }
        
        //--------------------------------- Update Line/Insert Line when the Header is already created before running this class -------------//
        if(SearchOldListingIDSet.size() > 0 ){
            List<ASI_KOR_Venue_Listed_Menu_Product__c> InsertLineList  = new  List<ASI_KOR_Venue_Listed_Menu_Product__c>();
            Map<String,ASI_KOR_Venue_Listed_Menu_Product__c> CurrentLineMap  = new  Map<String,ASI_KOR_Venue_Listed_Menu_Product__c>();
            List<ASI_KOR_Venue_Listed_Menu_Product__c> UpdateLineMap  = new  List<ASI_KOR_Venue_Listed_Menu_Product__c>();
            
            for(ASI_KOR_Venue_Listed_Menu_Product__c templine : [select id,ASI_KOR_Item_Group_Code__c,
                                                                ASI_KOR_Listed_Price__c,
                                                                ASI_CRM_KR_HeaderID_Upload__c,
                                                                ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Quarter__c,
                                                                ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Fiscal_Year__c,
                                                                ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Venue__c
                                                                from ASI_KOR_Venue_Listed_Menu_Product__c 
                                                                where ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Unique_ID__c in: SearchOldListingIDSet])
            { 
                string templineASI_CRM_KR_Venue;   
                if(string.valueof(templine.ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Venue__c).length() > 15){
                         templineASI_CRM_KR_Venue = (string.valueof(templine.ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Venue__c)).left(15);
                 }  
                    
                string Line_uniqueKey = templine.ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Fiscal_Year__c + templine.ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Quarter__c + templineASI_CRM_KR_Venue + templine.ASI_KOR_Item_Group_Code__c;                
                CurrentLineMap.put(Line_uniqueKey,templine);
            }
            
            if(CurrentLineMap.size() > 0){
               
                for(ASI_CRM_KR_TempListedMenuPrice__c templine :UpsertLineList){
                    
                    string templineASI_CRM_KR_Venue;    
                    
                    if(string.valueof(templine.ASI_CRM_KR_Venue__c).length() > 15){
                         templineASI_CRM_KR_Venue = (string.valueof(templine.ASI_CRM_KR_Venue__c)).left(15);
                    }   
                    
                    string templine_uniqueKey = templine.ASI_CRM_KR_Fiscal_Year__c + templine.ASI_CRM_KR_Quarter__c + templineASI_CRM_KR_Venue  + templine.ASI_CRM_KR_Item_Group_Code__c ;
                    String HeaderID = templine.ASI_CRM_KR_Fiscal_Year__c + '_' +templine.ASI_CRM_KR_Quarter__c + '_' + templineASI_CRM_KR_Venue ;
                    
                    //system.assertEquals(CurrentLineMap,null);    //FY1617Q1001L000000p2VNcIAMa6XL00000008QsmMAE
                    //system.assertEquals(templine_uniqueKey,null);  //FY1617Q4001L000000p2VNca6XL00000008QtoMAE
                    
                    if(CurrentLineMap.containsKey(templine_uniqueKey)){
                        //Update Line
                        CurrentLineMap.get(templine_uniqueKey).ASI_KOR_Listed_Price__c = templine.ASI_CRM_KR_Listed_Price__c;
                        UpdateLineMap.add(CurrentLineMap.get(templine_uniqueKey));
                        
                        
                        LineInsertIDSet.remove(HeaderID);
                        TotalRecordCount ++;
                    }
                    
                    else{
                    //Insert Line
               
                    interimData tempNew =new interimData();
                    
                    //system.assertEquals(ListingHeader_Key_ID_List, null);  //FY1617_Q2_001L000000p2VNc
                    //system.assertEquals(HeaderID, null);                    //FY1617_Q4_001L000000p2VNcIAM
                    
                    tempNew.create_Line= new ASI_KOR_Venue_Listed_Menu_Product__c(ASI_KOR_Listed_Price__c = templine.ASI_CRM_KR_Listed_Price__c,
                                                                                 ASI_CRM_KR_Listed_Menu_Product_Header__c = ListingHeader_Key_ID_List.get(HeaderID),
                                                                                 ASI_KOR_ListedMenuProduct_to_Venue_Link__c= templine.ASI_CRM_KR_Venue__c,
                                                                                 ASI_KOR_Item_Group_Code__c = templine.ASI_CRM_KR_Item_Group_Code__c);
                    
                    InsertLineList.add(tempNew.create_Line);
                    
                   // SYSTEM.assertEquals(HeaderID,NULL);
                    LineInsertIDSet.remove(HeaderID);
                    TotalRecordCount ++;
                    } 
                    
                }
                
            }
            
            else{
                //If before running this ctrl, the header is already created but no detail lines.
                for(ASI_CRM_KR_TempListedMenuPrice__c templine :TempDataList){
                    string templineASI_CRM_KR_Venue;    
                    
                    if(string.valueof(templine.ASI_CRM_KR_Venue__c).length() > 15){
                         templineASI_CRM_KR_Venue = (string.valueof(templine.ASI_CRM_KR_Venue__c)).left(15);
                    }   
                    
                    string templine_uniqueKey = templine.ASI_CRM_KR_Fiscal_Year__c + templine.ASI_CRM_KR_Quarter__c + templineASI_CRM_KR_Venue  + templine.ASI_CRM_KR_Item_Group_Code__c ;
                    String HeaderID = templine.ASI_CRM_KR_Fiscal_Year__c + '_' +templine.ASI_CRM_KR_Quarter__c + '_' + templineASI_CRM_KR_Venue ;
                    
                    
                    if(LineInsertIDSet.contains(HeaderID)){
                            //Insert Line
                   
                        interimData tempNew =new interimData();
                        
                        //system.assertEquals(ListingHeader_Key_ID_List, null);  //FY1617_Q2_001L000000p2VNc
                        //system.assertEquals(HeaderID, null);                    //FY1617_Q4_001L000000p2VNcIAM
                        
                        tempNew.create_Line= new ASI_KOR_Venue_Listed_Menu_Product__c(ASI_KOR_Listed_Price__c = templine.ASI_CRM_KR_Listed_Price__c,
                                                                                     ASI_CRM_KR_Listed_Menu_Product_Header__c = ListingHeader_Key_ID_List.get(HeaderID),
                                                                                     ASI_KOR_ListedMenuProduct_to_Venue_Link__c= templine.ASI_CRM_KR_Venue__c,
                                                                                     ASI_KOR_Item_Group_Code__c = templine.ASI_CRM_KR_Item_Group_Code__c);
                        
                        InsertLineList.add(tempNew.create_Line);
                        TotalRecordCount ++;
                    }
                    
                      
                }  
                
            }
            if(InsertLineList.size() > 0 ){
                try{
                    insert InsertLineList;
                    log.ASI_MFM_Configuration__c = TotalRecordCount + ' record(s) upserted.';
                    //system.assertEquals(InsertLineList,null);
                } 
                catch (DmlException dmle) {
                    log.ASI_MFM_Error_Message__c+= dmle.getMessage();
                    database.rollback(sp);
                }
                catch (Exception e){
                    
                    
                    log.ASI_MFM_Error_Message__c+=e.getMessage();
                    database.rollback(sp);
                }
                //system.assertEquals(null, SITLineList);
            }  
            
            if(UpdateLineMap.size() > 0 ){
                try{
                    update UpdateLineMap;
                    log.ASI_MFM_Configuration__c = TotalRecordCount + ' record(s) upserted.';
                    update log;
                }
                catch (DmlException dmle) {
                    //system.assertEquals(null,  dmle.getMessage());
                    log.ASI_MFM_Error_Message__c+= dmle.getMessage();
                    database.rollback(sp);
                }
                catch (Exception e){
                    
                    //system.assertEquals(null, e);
                    log.ASI_MFM_Error_Message__c+=e.getMessage();
                    database.rollback(sp);
                }
                //system.assertEquals(null, SITLineList);
            }
        }
    }  

    
    public void finish(Database.BatchableContext BC){
        if(log.ASI_MFM_Error_Message__c==''){
            log.ASI_MFM_Status__c='Success';
        }else{
            log.ASI_MFM_Status__c='Failed';
        }
        update log;
    }
}