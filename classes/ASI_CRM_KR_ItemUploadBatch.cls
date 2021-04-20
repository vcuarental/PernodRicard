/*------- KR CRM: For creating Stock-in Trade Header and Line by batch---------*/
public with sharing class ASI_CRM_KR_ItemUploadBatch implements Database.Batchable<sObject>, Database.Stateful{
	
    public ASI_MFM_Mass_Upload_Log__c log{GET;SET;} //{log=new ASI_MFM_Mass_Upload_Log__c(); }
    public List<ASI_KOR_Stock_In_Trade__c> SITList =new List<ASI_KOR_Stock_In_Trade__c> ();
    public class interimData {   
        ASI_KOR_Stock_In_Trade__c create_Header {set;get;}    
        ASI_KOR_WS_Stock_In_Trade_Detail__c create_Line {set;get;}   
    }
    public Map<string,interimData> Temp_Map =new Map<string,interimData> ();
    public Set<string> OldSITIDSet =new Set<string> ();
    public Set<string> CreatedSITLine_UniqueKey =new Set<string> ();
    public List<ASI_KOR_WS_Stock_In_Trade_Detail__c> SITLineList =new List<ASI_KOR_WS_Stock_In_Trade_Detail__c> ();   // Insert SIT Line
    public List<ASI_CRM_KR_Temp_SIT__c> TempDataList =new List<ASI_CRM_KR_Temp_SIT__c> (); //for query temp data
    public Set<string> SearchOldSITIDSet =new Set<string> ();  //for query temp data
    public List<ASI_CRM_KR_Temp_SIT__c> TempList =new List<ASI_CRM_KR_Temp_SIT__c> (); //for insert/update
    public Map<ID,ASI_KOR_Stock_In_Trade__c> AfterInsetHeaderMap =new Map<ID,ASI_KOR_Stock_In_Trade__c> (); 
    public ASI_CRM_KR_ItemUploadBatch(ASI_MFM_Mass_Upload_Log__c MFMlog){
        this.log=MFMlog;
        log.ASI_MFM_Error_Message__c='';  
    }
    public Set<string> HeaderIdSet =new Set<string> ();
    public Map<string,ASI_CRM_KR_Temp_SIT__c> TempMap =new Map<string,ASI_CRM_KR_Temp_SIT__c> ();	
    public integer TotalRecordCount {set;get;}
    
    public database.querylocator start(Database.BatchableContext BC){
        // This methods returns a SOQL query locator containing the records
       return Database.getQueryLocator([select id, ASI_CRM_KR_Month__c,ASI_CRM_KR_Sys_Month__c, ASI_CRM_KR_Status__c, ASI_CRM_KR_WS_CRM_No__c, ASI_CRM_KR_Year__c,ASI_CRM_KR_External_ID_Upload__c, ASI_CRM_KR_Item_Group_Code__c, ASI_CRM_KR_End_Stock_Case__c, ASI_CRM_KR_SIT_Created__c, ASI_CRM_KR_Customer_Code__c 
                                        from ASI_CRM_KR_Temp_SIT__c where ASI_CRM_KR_AccountOwnerChecking__c = true]); //where createdby.id =: UserInfo.getUserId()
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){  
        Set<string> HeaderIdSet =new Set<string> ();
        TempMap =new Map<string,ASI_CRM_KR_Temp_SIT__c> ();	
        OldSITIDSet =new Set<string> ();
        SITLineList =new List<ASI_KOR_WS_Stock_In_Trade_Detail__c> ();  
        SITList =new List<ASI_KOR_Stock_In_Trade__c> ();
        Temp_Map =new Map<string,interimData> ();
        TempList =new List<ASI_CRM_KR_Temp_SIT__c> ();
        Map<string,string> SITHeader_Key_ID_List = new Map<string,string> ();   // Insert SIT Line
        System.Savepoint sp = database.setSavepoint();

        TotalRecordCount = 0;
        
        list<ASI_CRM_KR_Temp_SIT__c> list_SITtoUpdate = new list<ASI_CRM_KR_Temp_SIT__c>();

        for(ASI_CRM_KR_Temp_SIT__c TempDataListRecord : (List<ASI_CRM_KR_Temp_SIT__c>)scope){
              
            String HeaderID = TempDataListRecord.ASI_CRM_KR_Year__c + '_'+ TempDataListRecord.ASI_CRM_KR_Sys_Month__c  + '_' +    TempDataListRecord.ASI_CRM_KR_Customer_Code__c;   
            SearchOldSITIDSet.add(HeaderID);
            TempDataList.ADD(TempDataListRecord);
            
            TempDataListRecord.ASI_CRM_KR_SIT_Created__c = true;
            list_SITtoUpdate.add(TempDataListRecord);
        }
        update list_SITtoUpdate;

        for(ASI_KOR_Stock_In_Trade__c oldSITHeader : [select id, ASI_KOR_Sys_Stock_in_trade_header_ID__c from ASI_KOR_Stock_In_Trade__c where ASI_KOR_Sys_Stock_in_trade_header_ID__c in: SearchOldSITIDSet and recordtype.developername LIKE 'ASI_KOR_SIT%']){
            OldSITIDSet.add(oldSITHeader.ASI_KOR_Sys_Stock_in_trade_header_ID__c); //Put all external ID in OldSITIDSet
            SITHeader_Key_ID_List.put(oldSITHeader.ASI_KOR_Sys_Stock_in_trade_header_ID__c,oldSITHeader.id);
        }
        
        //1. Get Records in Temp SIT object
        for(ASI_CRM_KR_Temp_SIT__c templine : TempDataList){
           
            String HeaderID = templine.ASI_CRM_KR_Year__c + '_'+ templine.ASI_CRM_KR_Sys_Month__c  + '_' +    templine.ASI_CRM_KR_Customer_Code__c;   
            
            if(OldSITIDSet.contains(HeaderID)){  //Header is already created, no need to create SIT Header for that temp object ine
                TempList.add(templine);
            }
            else{
                //2. Put data to SIT Header preparing for SIT Header Creation since there is no SIT Header
                if(!HeaderIdSet.contains(HeaderID)){
                    HeaderIdSet.add(HeaderID);
                    interimData temp =new interimData();
                    
                    ASI_KOR_Stock_In_Trade__c SITHeader= new ASI_KOR_Stock_In_Trade__c( ASI_KOR_Month__c = templine.ASI_CRM_KR_Sys_Month__c,
                                                                                       ASI_KOR_Status__c = templine.ASI_CRM_KR_Status__c,
                                                                                       ASI_KOR_Wholesaler__c = templine.ASI_CRM_KR_WS_CRM_No__c,
                                                                                       ASI_KOR_Year__c = templine.ASI_CRM_KR_Year__c);
                    
                    temp.create_Header=SITHeader;
                    SITList.add(SITHeader); //Put in SITList for later inserting to database
                    
                    TempMap.put(templine.id,templine);       
                    
                    //3. Put data to SIT Line preparing for SIT Line Creation   
                    interimData tempNew =new interimData();
                    tempNew.create_Line= new ASI_KOR_WS_Stock_In_Trade_Detail__c(ASI_KOR_Item_Group_Code__c = templine.ASI_CRM_KR_Item_Group_Code__c,
                                                                                 ASI_KOR_WS_SIT_End_Stock__c = templine.ASI_CRM_KR_End_Stock_Case__c,
                                                                                 ASI_CRM_KR_HeaderID_Upload__c = HeaderID);
                    Temp_Map.put(templine.ASI_CRM_KR_External_ID_Upload__c, tempNew);
                    SearchOldSITIDSet.add(HeaderID);
                }else{
                   //3. Put data to SIT Line preparing for SIT Line Creation   
                    interimData tempNew =new interimData();
                    tempNew.create_Line= new ASI_KOR_WS_Stock_In_Trade_Detail__c(ASI_KOR_Item_Group_Code__c = templine.ASI_CRM_KR_Item_Group_Code__c,
                                                                                 ASI_KOR_WS_SIT_End_Stock__c = templine.ASI_CRM_KR_End_Stock_Case__c,
                                                                                 ASI_CRM_KR_HeaderID_Upload__c = HeaderID);
                    Temp_Map.put(templine.ASI_CRM_KR_External_ID_Upload__c, tempNew); 
                }
            }
            
            
        }
        
        if(TempMap.size()>0){ //if there is at least one line in Temp SIT Object
            
            if(SITList.size()>0){
                try{
                insert SITList;   //Insert SIT Header
                } catch (DmlException dmle) {
                log.ASI_MFM_Error_Message__c+= dmle.getMessage() ;
                database.rollback(sp);
                } catch (Exception e) {
                log.ASI_MFM_Error_Message__c+=e.getMessage() ;
                database.rollback(sp);
                
                } 
            }
        }  
        
      //------------------------------------------------------------Insert SIT Line-------------------------------------------------------------------------------// 
        //Get SIT Header ID after inserted for mapping SIT Line to SIT Header
         AfterInsetHeaderMap =new Map<ID,ASI_KOR_Stock_In_Trade__c> (); 
        for (ASI_KOR_Stock_In_Trade__c eachHeader : [select id, ASI_KOR_Sys_Stock_in_trade_header_ID__c from ASI_KOR_Stock_In_Trade__c where ASI_KOR_Sys_Stock_in_trade_header_ID__c in: SearchOldSITIDSet and recordtype.developername LIKE 'ASI_KOR_SIT%']){
           
            AfterInsetHeaderMap.put(eachHeader.id, eachHeader); 
           
        }
       // system.assertEquals(AfterInsetHeaderMap,null);
        
        for(String UPLOAD_ID : Temp_Map.keyset()){ //Temp_Map stores SIT Line that needs to create SIT line. SIT Header is just created
            ASI_KOR_WS_Stock_In_Trade_Detail__c temp1 = Temp_Map.GET(UPLOAD_ID).create_Line;  
            //system.assertEquals(temp1,null);
            for (String eachHeader : AfterInsetHeaderMap.keyset()){
                string MappingKey = string.valueOf(AfterInsetHeaderMap.get(eachHeader).ASI_KOR_Sys_Stock_in_trade_header_ID__c); 
                
                //system.assertEquals(temp1.ASI_CRM_KR_HeaderID_Upload__c,null);
                
                if(temp1.ASI_CRM_KR_HeaderID_Upload__c == MappingKey){

                    temp1.Stock_In_Trade__c = eachHeader;   
                    //system.assertEquals(MappingKey, null);
                    if(temp1.Stock_In_Trade__c != null){	       
                        SITLineList.add(temp1);  
                    }
                }
            }
            //TotalRecordCount ++;  
        }  
        
        
       // system.assertEquals(AfterInsetHeaderMap,null);
        
        if(SITLineList.size() >= 1 ){
            try{
                TotalRecordCount = SITLineList.size();
                insert SITLineList;
                log.ASI_MFM_Configuration__c = '';
                //log.ASI_MFM_Configuration__c +=  Temp_Map.size() + ' record(s) inserted.';
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
        

        //--------------------------------------------------- Update SIT Line/Insert Line when the SIT Header is already created before running this class -------------------------------------------------------------------------------//
        //If the line is already exist, update is needed.
        if(OldSITIDSet.size() > 0){ 
            List<ASI_KOR_WS_Stock_In_Trade_Detail__c> InsertLineList  = new  List<ASI_KOR_WS_Stock_In_Trade_Detail__c>();
            Map<String,ASI_KOR_WS_Stock_In_Trade_Detail__c> CurrentLineMap  = new  Map<String,ASI_KOR_WS_Stock_In_Trade_Detail__c>();
            List<ASI_KOR_WS_Stock_In_Trade_Detail__c> UpdateLineMap  = new  List<ASI_KOR_WS_Stock_In_Trade_Detail__c>();
            //Get all SIT Line
            for(ASI_KOR_WS_Stock_In_Trade_Detail__c templine : [select id,ASI_KOR_Item_Group_Code__c,
                                                                ASI_KOR_WS_SIT_End_Stock__c,
                                                                ASI_CRM_KR_HeaderID_Upload__c,
                                                                Stock_In_Trade__r.ASI_KOR_Year__c,
                                                                Stock_In_Trade__r.ASI_KOR_Month__c,
                                                                Stock_In_Trade__r.ASI_KOR_Wholesaler__c
                                                                from ASI_KOR_WS_Stock_In_Trade_Detail__c 
                                                                where Stock_In_Trade__r.ASI_KOR_Sys_Stock_in_trade_header_ID__c in: SearchOldSITIDSet])
            { //Only Edittable SIT Header can update its line(Validation Rule) 
                string Line_uniqueKey = templine.Stock_In_Trade__r.ASI_KOR_Wholesaler__c + templine.Stock_In_Trade__r.ASI_KOR_Year__c + templine.Stock_In_Trade__r.ASI_KOR_Month__c + templine.ASI_KOR_Item_Group_Code__c;                
                CurrentLineMap.put(Line_uniqueKey,templine);
            }
            
            
            integer index = 1;
            if(CurrentLineMap.size() > 0){
                for(ASI_CRM_KR_Temp_SIT__c templine :TempList){
                    string templine_uniqueKey = templine.ASI_CRM_KR_WS_CRM_No__c + templine.ASI_CRM_KR_Year__c + templine.ASI_CRM_KR_Sys_Month__c  + templine.ASI_CRM_KR_Item_Group_Code__c ;
                    String HeaderID = templine.ASI_CRM_KR_Year__c + '_'+ templine.ASI_CRM_KR_Sys_Month__c  + '_' +    templine.ASI_CRM_KR_Customer_Code__c;  
                    string ASI_KOR_Sys_Stock_in_trade_header_ID  = templine.ASI_CRM_KR_Year__c + '_'+ templine.ASI_CRM_KR_Sys_Month__c  + '_' +    templine.ASI_CRM_KR_Customer_Code__c;
                    //if(CurrentLineMap.get(templine_uniqueKey) != null){
                    
                    
                    //system.assertEquals(templine_uniqueKey,null); //Expected: 001L000000qChkwIAC2017Maya6XL00000008QyHMAU, Actual: null
                    
                    if(CurrentLineMap.containsKey(templine_uniqueKey)){
                        
                        index++;
                        CurrentLineMap.get(templine_uniqueKey).ASI_KOR_WS_SIT_End_Stock__c = templine.ASI_CRM_KR_End_Stock_Case__c;
                        UpdateLineMap.add(CurrentLineMap.get(templine_uniqueKey));
                        TotalRecordCount ++;
                    }
                    
                    
                    
                    else{
                    //Insert Line
                    
                    interimData tempNew =new interimData();
                    tempNew.create_Line= new ASI_KOR_WS_Stock_In_Trade_Detail__c(Stock_In_Trade__c = SITHeader_Key_ID_List.get(HeaderID),
                                                                                 ASI_KOR_Item_Group_Code__c = templine.ASI_CRM_KR_Item_Group_Code__c,
                                                                                 ASI_KOR_WS_SIT_End_Stock__c = templine.ASI_CRM_KR_End_Stock_Case__c,
                                                                                 ASI_CRM_KR_HeaderID_Upload__c = HeaderID);
                   
                    InsertLineList.add(tempNew.create_Line);
                    //system.assertEquals(SITHeader_Key_ID_List.get(HeaderID),null);
                    TotalRecordCount ++;
                    }
                }
            }
            
            if(InsertLineList.size() >= 1 ){
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
            
            if(UpdateLineMap.size() >= 1 ){
                try{
                    update UpdateLineMap;
                    //log.ASI_MFM_Configuration__c +=  SITLineList.size() + ' record(s) updated.123';
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