/*********************************************************************************
* Project : TW CRM Offtake upload system
* Test class : ASI_CRM_TW_Function_Test
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 08/12/2020       PRA COE               Created

*********************************************************************************/

global  class ASI_CRM_TW_OfftakeBALCalulationBatch implements  Database.Batchable<String>, Database.Stateful {
    public final List<string> customerList  ;//Customer + Year+ Month
    public string batchjobID;
    public ASI_CRM_TW_OfftakeBALCalulationBatch(List<string> customerList){
        this.customerList = customerList; 
        
    }
    
    
    public List<String> start(Database.BatchableContext BC) {
        batchjobID= BC.getJobId();
        return customerList;
    }
    
    public void execute(Database.BatchableContext BC, List<string> scope){
        Map<String,ASI_TH_CRM_Actual_Offtake__c> INMap = new Map<String,ASI_TH_CRM_Actual_Offtake__c>();
        Map<String,ASI_TH_CRM_Actual_Offtake__c> OutMap = new Map<String,ASI_TH_CRM_Actual_Offtake__c>();
        Map<String,ASI_TH_CRM_Actual_Offtake__c> LastBALMap = new Map<String,ASI_TH_CRM_Actual_Offtake__c>();
        Map<String,ASI_TH_CRM_Actual_Offtake__c> ADJMap = new Map<String,ASI_TH_CRM_Actual_Offtake__c>();
        Set<String> CustAccIdSet = new Set<String> ();
        Map<String,ASI_TH_CRM_Actual_Offtake__c> NewBALMap = new Map<String,ASI_TH_CRM_Actual_Offtake__c>();
        Map<string,ASI_CRM_AccountsAdditionalField__c> CustomerMap = new Map<string,ASI_CRM_AccountsAdditionalField__c>();
    
        string customerCode = '';
        List<String> customerLines = scope;
        string customerstr = customerLines[0];
        List<String> values = customerstr.split('_');
        string customerId = values[0];
        
        
        //*******Previous Month*******
        Integer LastYY=Integer.valueOf(values[1]);
        Integer LastMM=Integer.valueOf(values[2]);
        boolean includestk = boolean.valueOf(values[3]);//(string.valueOf(values[2])=='true' \\)?true:false;
        if(LastMM==1){
            LastMM=12;
            LastYY--;
        }else{
            LastMM--;
        }
        
        string LastMMstr=string.valueOf(LastMM);
        string LastYYstr=string.valueOf(LastYY);
        
        if(LastMM<10){
            LastMMstr='0'+LastMMstr;
        }
        
        Date LastFrom = Date.newInstance(LastYY, LastMM, 1);
        Date LastTo= Date.newInstance(LastYY, LastMM, date.daysInMonth(LastYY, LastMM) );
        
        //*******this Month*******
        Integer numberDays = date.daysInMonth(Integer.valueOf(values[1]), Integer.valueOf(values[2]));
        
        Date currentFrom = Date.newInstance(Integer.valueOf(values[1]), Integer.valueOf(values[2]), 1);
        Date currentTo= Date.newInstance(Integer.valueOf(values[1]), Integer.valueOf(values[2]), numberDays);
        
        string soqlStatement ='select id,ASI_CRM_To_Code__c,ASI_CRM_From_Code__c,ASI_TH_CRM_From_Wholesaler__r.RecordType.DeveloperName,ASI_TH_CRM_From_Wholesaler__c,ASI_CRM_SKU_Code_Uploaded__c,ASI_CRM_System_Calculated__c,ASI_TH_CRM_Outlet__c,ASI_TH_CRM_Outlet__r.Name, ASI_CRM_Action_Type__c, ASI_TH_CRM_Offtake_G_L_Date__c,ASI_TH_CRM_Quantity__c,ASI_CRM_SKU__c from ASI_TH_CRM_Actual_Offtake__c where '+
            ' ( ASI_TH_CRM_Outlet__c =\''+ customerId  +'\' or ASI_TH_CRM_From_Wholesaler__c =\''+ customerId  +'\' ) '+
            'and ASI_CRM_Log_Id__c!=null and ASI_TH_CRM_Offtake_G_L_Date__c!=null and ASI_CRM_SKU__c !=null and ASI_TH_CRM_Quantity__c!=null and  '+
            ' ASI_TH_CRM_Offtake_G_L_Date__c >='+LastYYstr+'-'+LastMMstr+'-01 and ' +
            ' ASI_TH_CRM_Offtake_G_L_Date__c <=' + values[1] + '-' + values[2] + '-' + string.valueOf(numberDays) ;
        List<ASI_TH_CRM_Actual_Offtake__c> AOList = database.query(soqlStatement);
        
        
        List<ASI_TH_CRM_Actual_Offtake__c> DeletedAOList = new List<ASI_TH_CRM_Actual_Offtake__c>();
        for(ASI_TH_CRM_Actual_Offtake__c ao :AOList){
            if(ao.ASI_TH_CRM_From_Wholesaler__c!=customerId){
                CustAccIdSet.add(ao.ASI_TH_CRM_From_Wholesaler__c);
            }
            
        }
        
          
        if(CustAccIdSet.size()>0){
            for(ASI_CRM_AccountsAdditionalField__c cust:[select id,ASI_CRM_Channel__r.Name,ASI_CRM_Account__r.ASI_HK_CRM_JDE_Account_Number__c,ASI_CRM_Account__c
                                                         from ASI_CRM_AccountsAdditionalField__c
                                                         where ASI_CRM_Account__c in : CustAccIdSet 
                                                         and  recordType.developerName like '%TW%'])
            {
                CustomerMap.put(cust.ASI_CRM_Account__c , cust );
            }
        }
        
        
        
        for(ASI_TH_CRM_Actual_Offtake__c ao :AOList){
            if(ao.ASI_TH_CRM_Outlet__c==customerId){
                customerCode = ao.ASI_CRM_To_Code__c;
            }else if(ao.ASI_TH_CRM_From_Wholesaler__c==customerId){
                customerCode = ao.ASI_CRM_From_Code__c;
            }
            
            if(ao.ASI_TH_CRM_Offtake_G_L_Date__c>=LastFrom && ao.ASI_TH_CRM_Offtake_G_L_Date__c<=LastTo){// last month
                if(ao.ASI_CRM_Action_Type__c=='BAL'){
                    LastBALMap.put(ao.ASI_CRM_SKU__c,ao);
                }
            }else if (ao.ASI_TH_CRM_Offtake_G_L_Date__c>=currentFrom && ao.ASI_TH_CRM_Offtake_G_L_Date__c<=currentTo){// this month
                //Inv:  From WS to SWS, Action Type is INV
                if( (ao.ASI_TH_CRM_From_Wholesaler__r.RecordType.DeveloperName =='ASI_CRM_TW_Wholesaler' && ao.ASI_TH_CRM_Outlet__c==customerId &&  ao.ASI_CRM_Action_Type__c=='INV') ){
                    if(!INMap.containsKey(ao.ASI_CRM_SKU__c)){
                        INMap.put(ao.ASI_CRM_SKU__c,ao);
                    }else{
                        ASI_TH_CRM_Actual_Offtake__c tempao = INMap.get(ao.ASI_CRM_SKU__c);
                        tempao.ASI_TH_CRM_Quantity__c+=ao.ASI_TH_CRM_Quantity__c;
                        INMap.remove(ao.ASI_CRM_SKU__c);
                        INMap.put(ao.ASI_CRM_SKU__c,tempao);
                    }  
                }
                
                //Inv:  From SWS to SWS, Action Type is  STK
                if(ao.ASI_TH_CRM_Outlet__c==customerId &&  ao.ASI_CRM_Action_Type__c=='STK' && CustomerMap.containskey(ao.ASI_TH_CRM_From_Wholesaler__c) && CustomerMap.get(ao.ASI_TH_CRM_From_Wholesaler__c).ASI_CRM_Channel__r.Name =='Subwholesaler' ){ 
                    if(!INMap.containsKey(ao.ASI_CRM_SKU__c)){
                        INMap.put(ao.ASI_CRM_SKU__c,ao);
                    }else{
                        ASI_TH_CRM_Actual_Offtake__c tempao = INMap.get(ao.ASI_CRM_SKU__c);
                        tempao.ASI_TH_CRM_Quantity__c+=ao.ASI_TH_CRM_Quantity__c;
                        INMap.remove(ao.ASI_CRM_SKU__c);
                        INMap.put(ao.ASI_CRM_SKU__c,tempao);
                    }                    
                }else if(includestk && ao.ASI_TH_CRM_Outlet__c==customerId &&  ao.ASI_CRM_Action_Type__c=='STK'){
                    if(!INMap.containsKey(ao.ASI_CRM_SKU__c)){
                        INMap.put(ao.ASI_CRM_SKU__c,ao);
                    }else{
                        ASI_TH_CRM_Actual_Offtake__c tempao = INMap.get(ao.ASI_CRM_SKU__c);
                        tempao.ASI_TH_CRM_Quantity__c+=ao.ASI_TH_CRM_Quantity__c;
                        INMap.remove(ao.ASI_CRM_SKU__c);
                        INMap.put(ao.ASI_CRM_SKU__c,tempao);
                    }   
                }
                
                // OUT : From SWS to XXX, Action Type is INV
                if(ao.ASI_TH_CRM_From_Wholesaler__c==customerId && ao.ASI_CRM_Action_Type__c=='INV'){ 
                    if(!OutMap.containsKey(ao.ASI_CRM_SKU__c)){ //
                        OutMap.put(ao.ASI_CRM_SKU__c,ao);
                    }else{
                        ASI_TH_CRM_Actual_Offtake__c tempao = OutMap.get(ao.ASI_CRM_SKU__c);
                        tempao.ASI_TH_CRM_Quantity__c+=ao.ASI_TH_CRM_Quantity__c;
                        OutMap.remove(ao.ASI_CRM_SKU__c);
                        OutMap.put(ao.ASI_CRM_SKU__c,tempao);
                    }
                }
                
                //From SWS to SWS, Action Type is ADJ
                if(ao.ASI_CRM_Action_Type__c=='ADJ'){
                    if(!ADJMap.containsKey(ao.ASI_CRM_SKU__c)){
                       ADJMap.put(ao.ASI_CRM_SKU__c,ao); 
                    }else{
                        ASI_TH_CRM_Actual_Offtake__c tempao = ADJMap.get(ao.ASI_CRM_SKU__c);
                        tempao.ASI_TH_CRM_Quantity__c+=ao.ASI_TH_CRM_Quantity__c;
                        ADJMap.remove(ao.ASI_CRM_SKU__c);
                        ADJMap.put(ao.ASI_CRM_SKU__c,tempao);
                    }
                    
                }
                
                if(ao.ASI_CRM_Action_Type__c=='BAL' && ao.ASI_CRM_System_Calculated__c){
                    DeletedAOList.add(ao);
                }
            }           
        }
        
        if(DeletedAOList.size()>0){
            delete DeletedAOList;
        }
        
        //The logic for SWS balance is getting previous month "BAL" +this month "IN" - this month "OUT“+ADJ

        for (string skukey : LastBALMap.keyset()){
            Decimal qty = LastBALMap.get(skukey).ASI_TH_CRM_Quantity__c;
            if(INMap.containskey(skukey)){
                qty+=INMap.get(skukey).ASI_TH_CRM_Quantity__c;
            }
            if(OutMap.containskey(skukey)){
                qty = qty-OutMap.get(skukey).ASI_TH_CRM_Quantity__c;
            }
            
            if(ADJMap.containskey(skukey)){
                 qty = qty+ADJMap.get(skukey).ASI_TH_CRM_Quantity__c;
            }
            
            ASI_TH_CRM_Actual_Offtake__c ao = ASI_CRM_TW_Function.NewBALAOcreation(LastBALMap.get(skukey),currentTo,customerId,customerCode,batchjobID);
            ao.ASI_TH_CRM_Quantity__c = qty;

            NewBALMap.put(skukey,ao);
        }
        
        for (string skukey : INMap.keyset()){
            if(!NewBALMap.containskey(skukey) ){
                Decimal qty = INMap.get(skukey).ASI_TH_CRM_Quantity__c;
                if(OutMap.containskey(skukey)){
                    qty = qty-OutMap.get(skukey).ASI_TH_CRM_Quantity__c;
                }
                if(ADJMap.containskey(skukey)){
                    qty = qty+ADJMap.get(skukey).ASI_TH_CRM_Quantity__c;
                }
                ASI_TH_CRM_Actual_Offtake__c ao = ASI_CRM_TW_Function.NewBALAOcreation(INMap.get(skukey),currentTo,customerId,customerCode,batchjobID);
                ao.ASI_TH_CRM_Quantity__c = qty;
                NewBALMap.put(skukey,ao);

            }
        }
        
        for (string skukey : OutMap.keyset()){
            if(!NewBALMap.containskey(skukey) ){
                
                ASI_TH_CRM_Actual_Offtake__c ao = ASI_CRM_TW_Function.NewBALAOcreation(OutMap.get(skukey),currentTo,customerId,customerCode,batchjobID);
                ao.ASI_TH_CRM_Quantity__c = 0-OutMap.get(skukey).ASI_TH_CRM_Quantity__c;
                if(ADJMap.containskey(skukey)){
                    ao.ASI_TH_CRM_Quantity__c = ao.ASI_TH_CRM_Quantity__c +ADJMap.get(skukey).ASI_TH_CRM_Quantity__c;
                }
                NewBALMap.put(skukey,ao);
            }
            
        }
        for (string skukey : ADJMap.keyset()){
             if(!NewBALMap.containskey(skukey) ){ 
                ASI_TH_CRM_Actual_Offtake__c ao = ASI_CRM_TW_Function.NewBALAOcreation(ADJMap.get(skukey),currentTo,customerId,customerCode,batchjobID);
                ao.ASI_TH_CRM_Quantity__c = ADJMap.get(skukey).ASI_TH_CRM_Quantity__c;
                NewBALMap.put(skukey,ao);
            }
            
        }
        if(!NewBALMap.isEmpty()){
            system.debug(NewBALMap);
           // insert NewBALMap.values();
            
            Schema.SObjectField f = ASI_TH_CRM_Actual_Offtake__c.Fields.ASI_TH_CRM_Actual_Offtake_External_ID__c;
            Database.UpsertResult [] cr = Database.upsert(NewBALMap.values(), f, false);
            
        }
        
    }
    
    
    public void finish(Database.BatchableContext BC){
        
        
    }
}