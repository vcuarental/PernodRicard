public without sharing class ASI_CRM_MY_Contract_GenClaimRequest_Ctrl {
    
    public final String  FOC_OPTION {get; private set;}{FOC_OPTION='FOC';}
    public final String  CASH_OPTION {get; private set;}{CASH_OPTION='Cash';}
	public String selectedType {get; set;}{selectedType=FOC_OPTION;}
    public final String  VOLUME_OPTION {get; private set;}{VOLUME_OPTION='VOLUME';}
    public final String  OTHER_OPTION {get; private set;}{OTHER_OPTION='OTHER';}
    public final String  ALL_OPTION {get; private set;}{ALL_OPTION='ALL';}
    public String selectedIncentiveType {get; set;}{selectedIncentiveType=ALL_OPTION;}
    public Boolean isShowIncentiveOption {get; set;}{isShowIncentiveOption=false;}
    public Integer selectedFromYear {get;set;}
    public Integer selectedFromMonth {get;set;}
    public Integer selectedToYear {get;set;}
    public Integer selectedToMonth {get;set;}
    public List<SelectOption> fromYearOptions {get;private set;}{fromYearOptions = new List<SelectOption>();}
    public List<SelectOption> toYearOptions {get; private set;}{toYearOptions = new List<SelectOption>();}
    public List<SelectOption> monthOptions {get; private set;}{monthOptions = new List<SelectOption>();}
    private Id currentUserId =UserInfo.getUserId();
    private Set<Id> s_visiableUserIds = new Set<Id>{currentUserId};
    public Boolean genMonthly {get; set;}{genMonthly = false;}
    public String contractId {get; set;}{contractId = '';}
    public String contractTxt {get; set;}{contractId = '';}
    private Map<Id, String> availableContract_IdName = new Map<Id,String>();
    public Boolean hasCalcFOC {get; private set;} {hasCalcFOC= true;}
    public Boolean hasCalcPayment {get; private set;} {hasCalcPayment= true;}
    public Boolean hasPreviewed{get; private set;}{hasPreviewed =false;}
    public Boolean showRelatedSection{get; private set;}{showRelatedSection =false;}
    public Boolean showRelatedRcd{get; private set;}{showRelatedRcd =false;}
    public Boolean hasRelatedRecords{get; private set;}{hasRelatedRecords =false;}
    public Boolean showNewFOCRecords{get; private set;}{showNewFOCRecords =false;}
    public Boolean showNewCashRecords{get; private set;}{showNewFOCRecords =false;}
    private List<Integer> matchedIndex =new List<Integer>();

    private ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
    public Date today{get; private set;}{today =my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();}
    public Integer cutoffDay {get; private set;}{cutoffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;}
	public Decimal GST {get; private set;}{GST = my_cs!=null && my_cs.ASI_CRM_MY_GST_Rate__c!=null ? my_cs.ASI_CRM_MY_GST_Rate__c : 6;}
    
    public List<ASI_CRM_Calculated_FOC_Line__c> l_UnusedCalcFOCLine {get;private set;} {l_UnusedCalcFOCLine= new List<ASI_CRM_Calculated_FOC_Line__c>(); }
    public List<ASI_CRM_Calculated_Payment_Item__c> l_UnusedCalcPaymentLine {get;private set;} {l_UnusedCalcPaymentLine= new List<ASI_CRM_Calculated_Payment_Item__c>(); }

    public  List<ASI_CRM_Calculated_FOC_Line__c> l_RelatedCalcFOCLine {get;private set;} {l_RelatedCalcFOCLine= new List<ASI_CRM_Calculated_FOC_Line__c>(); }
    public  List<ASI_CRM_Calculated_Payment_Item__c> l_RelatedCalcPaymentLine {get;private set;} {l_RelatedCalcPaymentLine= new List<ASI_CRM_Calculated_Payment_Item__c>(); }

    public List<ASI_CRM_Calculated_FOC_Line__c> l_ProceededCalcFOCLine {get;private set;} {l_ProceededCalcFOCLine= new List<ASI_CRM_Calculated_FOC_Line__c>(); }
    public List<ASI_CRM_Calculated_Payment_Item__c> l_ProceededCalcPaymentLine {get;private set;} {l_ProceededCalcPaymentLine= new List<ASI_CRM_Calculated_Payment_Item__c>(); }

    public List<ASI_FOC_Request_Item__c> l_newAllFOCLine{get; private set;}{l_newAllFOCLine = new List<ASI_FOC_Request_Item__c>();}
    private set<ASI_FOC_Request_Item__c> s_newFOCLine{get; private set;}{s_newFOCLine = new set<ASI_FOC_Request_Item__c>();}
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> l_newAllPaymentLine{get; private set;}{l_newAllPaymentLine = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();}
    private set<ASI_TH_CRM_PaymentRequestLineItem__c> s_newPaymentLine{get; private set;}{s_newPaymentLine = new set<ASI_TH_CRM_PaymentRequestLineItem__c>();}

    public ASI_CRM_MY_Contract_GenClaimRequest_Ctrl() {
        
        //Init data realted fields' values for selections:
        Date tempDate = today;
        if(today.day()< cutoffDay || today.month() ==1){
            tempDate = tempDate.addMonths(-1);
        }
        selectedToYear= tempDate.year();
        selectedToMonth = tempDate.month();

        tempDate = tempDate.addMonths(-2);
        selectedFromYear= tempDate.year();
        selectedFromMonth = tempDate.month();
        
        for(Integer i=3; i>=0; i--){
            fromYearOptions.add(new SelectOption (String.valueof(today.year()-i),String.valueof(today.year()-i)));
            toYearOptions.add(new SelectOption (String.valueof(today.year()-i), String.valueof(today.year()-i)));
        }
        for(Integer i=1; i<=12; i++){
            monthOptions.add(new SelectOption (String.valueof(i),String.valueof(i)));
        }
	
        //Get sales under current user, if current user is sales manager:
        List<User> l_availableUsers= new List<user>();
        l_availableUsers =[SELECT Id, ManagerId FROM User WHERE ManagerId =: currentUserId ];
        for(User u: l_availableUsers){
            s_visiableUserIds.add(u.Id);
        }
        
        
        //Get Calculated FOC & Calculated Payment:
        /**l_UnusedCalcFOC =[SELECT Id, Name, ASI_CRM_Customer__c, ASI_CRM_Contract__c, ASI_CRM_Used_For_FOC__c, OwnerId, ASI_CRM_Year__c, ASI_CRM_Month__c FROM ASI_CRM_Calculated_FOC__c WHERE RecordTypeId =:Global_RecordTypeCache.getRtId('ASI_CRM_Calculated_FOC__cASI_CRM_MY_Calculated_FOC') AND ASI_CRM_Used_For_FOC__c =false AND OwnerId=:currentUserId 
                            ORDER BY ASI_CRM_Customer__c, ASI_CRM_Contract__c, Name, ASI_CRM_Year__c, ASI_CRM_Month__c ASC 
                            ];**/
        
        
        ////////////////////////////      04-09-2018      //////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////
        //AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.OwnerId IN:s_visiableUserIds
        //Instead of 
        //AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.OwnerId IN:s_visiableUserIds 
        ////////////////////////////////////////////////////////////////////////////////////
        //AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.OwnerId IN:s_visiableUserIds
        //Instead of 
        //AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.OwnerId IN:s_visiableUserIds
		////////////////////////////      04-09-2018      //////////////////////////////////
        l_UnusedCalcFOCLine =[SELECT 
                        Id, 
                        Name, 
                        ASI_CRM_ExcessQuantity__c, 
                        ASI_CRM_Calculated_FOC__c, 
                        ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__c, 
                        ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c,
                        ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.name,
                        ASI_CRM_Calculated_FOC__r.ASI_CRM_Used_For_FOC__c,
                        ASI_CRM_Calculated_FOC__r.OwnerId,
                        ASI_CRM_Calculated_FOC__r.ASI_CRM_Year__c, 
                        ASI_CRM_Calculated_FOC__r.ASI_CRM_Month__c, 
                        ASI_CRM_SKU__c,ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c,
                        ASI_CRM_Original_SKU__c,
                        ASI_CRM_Original_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c,
                        ASI_CRM_FOC__c,ASI_CRM_FOC_WS__c,
                        ASI_CRM_Remain__c,ASI_CRM_Remain_WS__c, 
                        ASI_CRM_SetupCode__c, 
                        ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.OwnerId,
                        ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.ASI_CRM_MY_IsAutoRequest__c 
                        FROM ASI_CRM_Calculated_FOC_Line__c 
                        WHERE RecordTypeId =:Global_RecordTypeCache.getRtId('ASI_CRM_Calculated_FOC_Line__cASI_CRM_MY_Calculated_FOC_Item') 
                        AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Used_For_FOC__c =false 
                        AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.OwnerId IN:s_visiableUserIds 
                        AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.ASI_CRM_Obsolete_Version__c=false 
                        AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.ASI_CRM_Terminate__c =false 
                        AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.ASI_CRM_MY_IsAutoRequest__c = true
                        AND ASI_CRM_FOC__c>0
                        ORDER BY ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__c, ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c, ASI_CRM_Calculated_FOC__r.ASI_CRM_Year__c, ASI_CRM_Calculated_FOC__r.ASI_CRM_Month__c ASC 
                    ];
        
        l_UnusedCalcPaymentLine =[SELECT 
                                  	Id, 
                                  	Name, 
                                  	ASI_CRM_SKU__c, ASI_CRM_ExcessQuantity__c,
                                  	ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c, 
                                  	ASI_CRM_Cash__c,ASI_CRM_Actual_Volume__c,ASI_CRM_Target_Volume__c, 
                                  	ASI_CRM_Calculated_Payment__c, ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__c, 
                                  	ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c, 
                                  	ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.name, 
                                  	ASI_CRM_Calculated_Payment__r.ASI_CRM_Year__c, 
                                  	ASI_CRM_Calculated_Payment__r.ASI_CRM_Month__c,ASI_CRM_SetupCode__c,
                                  	ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c, 
                                  	ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.OwnerId,
                                  	ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.ASI_CRM_MY_IsAutoRequest__c
                                  	FROM ASI_CRM_Calculated_Payment_Item__c
                                    WHERE RecordTypeId =:Global_RecordTypeCache.getRtId('ASI_CRM_Calculated_Payment_Item__cASI_CRM_Calculated_Payment_Item_Type') 
                                  	AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Used_for_Payment__c= false 
                                  	AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.OwnerId IN:s_visiableUserIds 
                                  	AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = false 
                                  	AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.ASI_CRM_Terminate__c = false
                                  	AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.ASI_CRM_MY_IsAutoRequest__c = true
                                    AND ASI_CRM_Cash__c>0
                                    ORDER BY  ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__c, ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c, ASI_CRM_Calculated_Payment__r.ASI_CRM_Year__c, ASI_CRM_Calculated_Payment__r.ASI_CRM_Month__c ASC
                            ];

        if(l_UnusedCalcFOCLine.size()<=0){
            hasCalcFOC= false;
        }
        
        if(l_UnusedCalcPaymentLine.size()<=0){
            hasCalcPayment = false;
        }

        if(!hasCalcFOC && !hasCalcPayment){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There is no valid Calculated FOC & Payment record for your owned contracts.'));
        }else if (!hasCalcFOC){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There is no valid Calculated FOC record for your owned contracts.'));
        }else if(!hasCalcPayment){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There is no valid Calculated Payment record for your owned contracts.'));
        }

    }


    public pageReference previewRelatedCalcRecords(){

        if(validateValues()){
            showRelatedSection =true;
            showRelatedRcd =true;
            matchRelatedRecods();
            if(l_RelatedCalcPaymentLine.size()>0 || l_RelatedCalcFOCLine.size()>0){
                hasRelatedRecords = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please review "Related Records" below and then click "Proceed To Gen" if expected records are correct.'));
            }else{
                hasRelatedRecords =false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There are no related records based on your criteria (Refer to the "Related Records" below).'));
            }
        }
        
        return null;
    }

    public pageReference genRequest(){
         if( validateValues()){ 
            showRelatedSection =true;
            showRelatedRcd =true;
            matchRelatedRecods();
			
             
            //FOC Request 
           	 
            if(selectedType == FOC_OPTION ){
                if(l_RelatedCalcFOCLine.size()>0){
                    id idRT_FOC = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_FOC_MY_FreeGoodsRequest');
                    id idRT_FOCLine = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_FOC_MY_RequestItem');
                    
                    Map< String, List<ASI_CRM_Calculated_FOC_Line__c>> m_contractDate_calcFOCLine = new Map<String, List<ASI_CRM_Calculated_FOC_Line__c>>();
                    Map< String, Set<Id>> m_contractDate_calcFOCIds = new Map< String, Set<Id>>();
                    for(ASI_CRM_Calculated_FOC_Line__c calcFOCLine : l_RelatedCalcFOCLine){
                        String key = calcFOCLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c+'_'+calcFOCLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Year__c+'_'+calcFOCLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Month__c;
                        if(m_contractDate_calcFOCLine.get(key)!=null){
                            m_contractDate_calcFOCLine.get(key).add(calcFOCLine);
                        }else{
                            m_contractDate_calcFOCLine.put(key, new List<ASI_CRM_Calculated_FOC_Line__c>{calcFOCLine});
                        }

                        if(m_contractDate_calcFOCIds.get(key)!=null){
                            m_contractDate_calcFOCIds.get(key).add(calcFOCLine.ASI_CRM_Calculated_FOC__c);
                        }else{
                            m_contractDate_calcFOCIds.put(key, new Set<Id>{calcFOCLine.ASI_CRM_Calculated_FOC__c});
                        }

                    }
                    List<ASI_FOC_Free_Goods_Request__c> l_newFOC = new List<ASI_FOC_Free_Goods_Request__c>();
                    List<ASI_FOC_Request_Item__c> l_newFOCLine = new List<ASI_FOC_Request_Item__c> ();
                    List<ASI_CRM_Calculated_FOC__c> l_calcFOCToUpdate = new List<ASI_CRM_Calculated_FOC__c>();

                    Savepoint sp = Database.setSavepoint();
                    try{
                        if(genMonthly){
                            
                            Map<String,ASI_FOC_Free_Goods_Request__c> m_contractDate_FOC = new Map<String,ASI_FOC_Free_Goods_Request__c>();    
                            for(String key :m_contractDate_calcFOCLine.keySet()){
                                String[] temp = key.split('_');
                                Date startDate = Date.newInstance(Integer.valueOf(temp[1]), Integer.valueOf(temp[2]), 1);
                                Date endDate = startDate.addMonths(1).addDays(-1);

                                ASI_FOC_Free_Goods_Request__c foc = new ASI_FOC_Free_Goods_Request__c();
                                foc.ASI_CRM_Outlet__c = m_contractDate_calcFOCLine.get(key)[0].ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__c;
                                foc.ASI_CRM_Contract__c = m_contractDate_calcFOCLine.get(key)[0].ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c;
                                foc.OwnerId = m_contractDate_calcFOCLine.get(key)[0].ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.OwnerId;
                                foc.ASI_CRM_Status__c ='Draft';
                                foc.ASI_CRM_Date_From__c =startDate;
                                foc.ASI_CRM_Date_To__c =endDate;
                                foc.RecordTypeId =idRT_FOC;
                                foc.ASI_FOC_Description__c ='FOC Auto Generation';
                                foc.ASI_CRM_Auto_Generation__c =true;
                                foc.ASI_CRM_AP_Type__c =false;
                                foc.ASI_CRM_MY_Display_Price__c =false;
                                foc.CurrencyIsoCode = 'MYR';
                                m_contractDate_FOC.put(key, foc);
                                l_newFOC.add(foc);

                            }
                            if(l_newFOC.size()>0){
                                insert l_newFOC;
                            }

                            for(String key :m_contractDate_calcFOCLine.keySet()){
                                for(ASI_CRM_Calculated_FOC_Line__c calcFocLine : m_contractDate_calcFOCLine.get(key) ){
                                    ASI_FOC_Request_Item__c focLine = new ASI_FOC_Request_Item__c();
                                    focLine.ASI_FOC_Request_Order__c = m_contractDate_FOC.get(key).Id;
                                    focLine.ASI_FOC_SKU__c = calcFocLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=null ? calcFocLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c : calcFocLine.ASI_CRM_SKU__c;
                                    focLine.ASI_FOC_Issued_Qty__c = calcFocLine.ASI_CRM_FOC__c!=null?calcFocLine.ASI_CRM_FOC__c:0;
                                    focLine.ASI_CRM_SetupCode__c =calcFocLine.ASI_CRM_SetupCode__c;
                                    focLine.RecordTypeId = idRT_FOCLine;
                                    focLine.CurrencyIsoCode = 'MYR';
                                    String str_Date = calcFocLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Year__c+calcFocLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Month__c;
                                    focLine.ASI_FOC_Remark__c= str_Date;
                                    if(calcFocLine.ASI_CRM_Original_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=null){
                                        if(calcFocLine.ASI_CRM_Original_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=calcFocLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c && calcFocLine.ASI_CRM_Original_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=calcFocLine.ASI_CRM_SKU__c){
                                             focLine.ASI_FOC_Remark__c += ' Cross-brand SKU';
                                        }
                                    }else{
                                        if(calcFocLine.ASI_CRM_Original_SKU__c!=calcFocLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c && calcFocLine.ASI_CRM_Original_SKU__c!=calcFocLine.ASI_CRM_SKU__c){
                                             focLine.ASI_FOC_Remark__c += ' Cross-brand SKU';
                                        }
                                    }
                                   
                                    l_newFOCLine.add(focLine);
                                }
                            }
                            insert l_newFOCLine;
                            s_newFOCLine.addAll(l_newFOCLine);

                            
                            for(String key:m_contractDate_calcFOCIds.keySet()){
                                for(Id calcFOCId : m_contractDate_calcFOCIds.get(key) ){
                                    ASI_CRM_Calculated_FOC__c calcFOC = new ASI_CRM_Calculated_FOC__c(Id=calcFOCId, ASI_CRM_Used_For_FOC__c=true, ASI_CRM_Used_By_FOC__c=m_contractDate_FOC.get(key).Id);
                                    l_calcFOCToUpdate.add(calcFOC);
                                }
                            }
                            update l_calcFOCToUpdate;
                        }else{
                            ASI_FOC_Free_Goods_Request__c newFOC = new ASI_FOC_Free_Goods_Request__c();
                            Date startDate = Date.newInstance(selectedFromYear, selectedFromMonth, 1);
                            Date endDate = Date.newInstance(selectedToYear, selectedToMonth, 1).addMonths(1).addDays(-1);
                            newFOC.ASI_CRM_Outlet__c = l_RelatedCalcFOCLine[0].ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__c;
                            newFOC.OwnerId = l_RelatedCalcFOCLine[0].ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.OwnerId;
                            newFOC.ASI_CRM_Contract__c =contractId;
                            newFOC.ASI_CRM_Status__c ='Draft';
                            newFOC.ASI_CRM_Date_From__c =startDate;
                            newFOC.ASI_CRM_Date_To__c =endDate;
                            newFOC.RecordTypeId =idRT_FOC;
                            newFOC.ASI_FOC_Description__c ='FOC Auto Generation';
                            newFOC.ASI_CRM_Auto_Generation__c =true;
                            newFOC.ASI_CRM_AP_Type__c =false;
                            newFOC.ASI_CRM_MY_Display_Price__c =false;
                            newFOC.CurrencyIsoCode = 'MYR';
                            
                            l_newFOC.add(newFOC);
                            insert newFOC;
                            


                            for(ASI_CRM_Calculated_FOC_Line__c calcFocLine : l_RelatedCalcFOCLine ){
                                ASI_FOC_Request_Item__c focLine = new ASI_FOC_Request_Item__c();
                                focLine.ASI_FOC_Request_Order__c =newFOC.Id;
                                focLine.ASI_FOC_SKU__c = calcFocLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=null ? calcFocLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c : calcFocLine.ASI_CRM_SKU__c;
                                focLine.ASI_FOC_Issued_Qty__c = calcFocLine.ASI_CRM_FOC__c!=null?calcFocLine.ASI_CRM_FOC__c:0;
                                focLine.ASI_CRM_SetupCode__c =calcFocLine.ASI_CRM_SetupCode__c;
                                focLine.RecordTypeId = idRT_FOCLine;
                                focLine.CurrencyIsoCode = 'MYR';
                                String str_Date = calcFocLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Year__c+calcFocLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Month__c;
                                focLine.ASI_FOC_Remark__c= str_Date;
                                if(calcFocLine.ASI_CRM_Original_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=null){
                                    if(calcFocLine.ASI_CRM_Original_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=calcFocLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c && calcFocLine.ASI_CRM_Original_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=calcFocLine.ASI_CRM_SKU__c){
                                         focLine.ASI_FOC_Remark__c += 'Cross-brand SKU';
                                    }
                                }else{
                                    if(calcFocLine.ASI_CRM_Original_SKU__c!=calcFocLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c && calcFocLine.ASI_CRM_Original_SKU__c!=calcFocLine.ASI_CRM_SKU__c){
                                         focLine.ASI_FOC_Remark__c += 'Cross-brand SKU';
                                    }
                                }

                                l_newFOCLine.add(focLine);
                            }
                            system.debug('***before***'+l_newFOCLine);
                            insert l_newFOCLine;
                            s_newFOCLine.addAll(l_newFOCLine);
                            system.debug('***after***'+l_newFOCLine);

                            for(String key:m_contractDate_calcFOCIds.keySet()){
                                for(Id calcFOCId : m_contractDate_calcFOCIds.get(key) ){
                                    ASI_CRM_Calculated_FOC__c calcFOC = new ASI_CRM_Calculated_FOC__c(Id=calcFOCId, ASI_CRM_Used_For_FOC__c=true, ASI_CRM_Used_By_FOC__c=newFOC.Id);
                                    l_calcFOCToUpdate.add(calcFOC);
                                }
                            }
                            update l_calcFOCToUpdate;
                        }

                        retrieveNewFOCLine();
                        copyToProceededRcd();
                        showNewFOCRecords= true;
                        showRelatedRcd =false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, l_newFOC.size()+' FOC Request(s) with '+l_newFOCLine.size()+' line(s) are generated. Please review "Related Records" below for your reference.'));
                    }catch(exception e){
                        Database.rollback(sp);
                        String err= e.getMessage();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Generation failed. Error: '+err));
                    }
                }else{
                    hasRelatedRecords =false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There are no related records based on your criteria (Refer to the "Related Records" below).'));
                }
            //Cash Payment:
            }
            else if(selectedType == CASH_OPTION ){
                if(l_RelatedCalcPaymentLine.size()>0){
                    id idRT_PaymentRequest = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request');
                    id idRT_PaymentRequestItem = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_MY_Payment_Request_Detail');
                    s_newPaymentLine = new set<ASI_TH_CRM_PaymentRequestLineItem__c>();
                    
                    //Map differentiate Incentive Type, Date:
                    Map<String, Map< String, List<ASI_CRM_Calculated_Payment_Item__c>>> m_type_contractDate_calcPaymentLine = new Map<String,Map<String, List<ASI_CRM_Calculated_Payment_Item__c>>>();
                    
                    Map< String, Set<Id>> m_contractDate_calcPaymentIds = new Map< String, Set<Id>>();
                    Map< String, Set<Id>> m_type_calcPaymentIds = new Map< String, Set<Id>>();
                    for(ASI_CRM_Calculated_Payment_Item__c calcPaymentLine : l_RelatedCalcPaymentLine){
                        
                        Map< String, List<ASI_CRM_Calculated_Payment_Item__c>> m_contractDate_calcPaymentLine = new Map<String, List<ASI_CRM_Calculated_Payment_Item__c>>();
                        String incentiveType = calcPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c;
                        if(m_type_contractDate_calcPaymentLine.get(incentiveType)!=null){
                            m_contractDate_calcPaymentLine = m_type_contractDate_calcPaymentLine.get(incentiveType);
                        }else{
                            m_type_contractDate_calcPaymentLine.put(incentiveType, m_contractDate_calcPaymentLine);
                        }
                        String key = incentiveType+calcPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c+'_'+calcPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Year__c+'_'+calcPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Month__c;
                        if(m_contractDate_calcPaymentLine.get(key)!=null){
                            m_contractDate_calcPaymentLine.get(key).add(calcPaymentLine);
                        }else{
                            m_contractDate_calcPaymentLine.put(key, new List<ASI_CRM_Calculated_Payment_Item__c>{calcPaymentLine});
                        }

                        if(m_contractDate_calcPaymentIds.get(key)!=null){
                            m_contractDate_calcPaymentIds.get(key).add(calcPaymentLine.ASI_CRM_Calculated_Payment__c);
                        }else{
                            m_contractDate_calcPaymentIds.put(key, new Set<Id>{calcPaymentLine.ASI_CRM_Calculated_Payment__c});
                        }

                        if(m_type_calcPaymentIds.get(incentiveType)!=null){
                            m_type_calcPaymentIds.get(incentiveType).add(calcPaymentLine.ASI_CRM_Calculated_Payment__c);
                        }else{
                            m_type_calcPaymentIds.put(incentiveType, new Set<Id>{calcPaymentLine.ASI_CRM_Calculated_Payment__c});
                        }

                        m_type_contractDate_calcPaymentLine.put(incentiveType, m_contractDate_calcPaymentLine);
                    }
                    List<ASI_TH_CRM_PaymentRequest__c> l_newPayment = new List<ASI_TH_CRM_PaymentRequest__c>();
                    List<ASI_TH_CRM_PaymentRequestLineItem__c> l_newPaymentLine = new List<ASI_TH_CRM_PaymentRequestLineItem__c> ();
                    List<ASI_CRM_Calculated_Payment__c> l_calcPaymentToUpdate = new List<ASI_CRM_Calculated_Payment__c>();

                    Savepoint sp = Database.setSavepoint();
                    try{
                        if(genMonthly){
                            Map<String,ASI_TH_CRM_PaymentRequest__c> m_contractDate_Payment = new Map<String,ASI_TH_CRM_PaymentRequest__c>();
                            for(String str_type : m_type_contractDate_calcPaymentLine.keySet()){
                                for(String key :m_type_contractDate_calcPaymentLine.get(str_type).keySet()){
                                    String[] temp = key.split('_');
                                    Date startDate = Date.newInstance(Integer.valueOf(temp[1]), Integer.valueOf(temp[2]), 1);
                                    Date endDate = startDate.addMonths(1).addDays(-1);

                                    ASI_TH_CRM_PaymentRequest__c payment = new ASI_TH_CRM_PaymentRequest__c();

                                    payment.ASI_CRM_CN_OutletWS__c = m_type_contractDate_calcPaymentLine.get(str_type).get(key)[0].ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__c;
                                    payment.ASI_TH_CRM_Contract__c = m_type_contractDate_calcPaymentLine.get(str_type).get(key)[0].ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c;
                                    payment.OwnerId = m_type_contractDate_calcPaymentLine.get(str_type).get(key)[0].ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.OwnerId;
                                    payment.ASI_TH_CRM_Status__c ='Draft';
                                    payment.ASI_CRM_Date_From__c =startDate;
                                    payment.ASI_CRM_Date_To__c =endDate;
                                    payment.RecordTypeId =idRT_PaymentRequest;
                                    payment.ASI_CRM_CN_Description__c ='Payment Auto Generation';
                                    payment.ASI_CRM_Auto_Generate__c =true;
                                    payment.ASI_CRM_A_P_Type__c = str_type=='Other Incentive'? true:false;
                                    payment.ASI_CRM_Incentive_Type__c =str_type;
                                    payment.CurrencyIsoCode = 'MYR';
                                    payment.ASI_CRM_GST__c = true;
                                    //payment.ASI_CRM_GST_Rate__c = GST;
                                    m_contractDate_Payment.put(key, payment);
                                    l_newPayment.add(payment);

                                }
                            }   
                            
                            if(l_newPayment.size()>0){
                                insert l_newPayment;
                            }
                            for(String str_type : m_type_contractDate_calcPaymentLine.keySet()){
                                for(String key :m_type_contractDate_calcPaymentLine.get(str_type).keySet()){
                                    for(ASI_CRM_Calculated_Payment_Item__c calcPaymentLine : m_type_contractDate_calcPaymentLine.get(str_type).get(key) ){
                                        ASI_TH_CRM_PaymentRequestLineItem__c paymentLine = new ASI_TH_CRM_PaymentRequestLineItem__c();
                                        paymentLine.ASI_TH_CRM_Payment_Request__c = m_contractDate_Payment.get(key).Id;
                                        paymentLine.ASI_CRM_SKU__c = calcPaymentLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=null ? calcPaymentLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c : calcPaymentLine.ASI_CRM_SKU__c;
                                        //paymentLine.ASI_TH_CRM_Amount__c = calcPaymentLine.ASI_CRM_Cash__c;
                                        paymentLine.ASI_CRM_Net_Amount__c  = calcPaymentLine.ASI_CRM_Cash__c;
                                        paymentLine.ASI_CRM_Tax_Amount__c  = (1 + (GST/100)) * calcPaymentLine.ASI_CRM_Cash__c;
                                        paymentLine.ASI_CRM_SetupCode__c =calcPaymentLine.ASI_CRM_SetupCode__c;
                                        paymentLine.RecordTypeId = idRT_PaymentRequestItem;
                                        paymentLine.ASI_CRM_CN_Actual_Vol__c =calcPaymentLine.ASI_CRM_Actual_Volume__c;
                                        paymentLine.ASI_CRM_CN_Target_BT__c =calcPaymentLine.ASI_CRM_Target_Volume__c;
                                        paymentLine.CurrencyIsoCode = 'MYR';
                                        String str_Date = calcPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Year__c+calcPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Month__c;
                                        paymentLine.ASI_CRM_Remark__c= str_Date;
                                        l_newPaymentLine.add(paymentLine);
                                        
                                    }
                                }
                            }
                            
                            insert l_newPaymentLine;
                            s_newPaymentLine.addAll(l_newPaymentLine);

                            
                            for(String key:m_contractDate_calcPaymentIds.keySet()){
                                for(Id calcPaymentId : m_contractDate_calcPaymentIds.get(key) ){
                                    ASI_CRM_Calculated_Payment__c calcPayment = new ASI_CRM_Calculated_Payment__c(Id=calcPaymentId, ASI_CRM_Used_for_Payment__c=true, ASI_CRM_Used_By_Payment_Request__c=m_contractDate_Payment.get(key).Id);
                                    l_calcPaymentToUpdate.add(calcPayment);
                                }
                            }
                            update l_calcPaymentToUpdate;
                        }
                        else{
                            Map<String,ASI_TH_CRM_PaymentRequest__c> m_type_Payment = new Map<String,ASI_TH_CRM_PaymentRequest__c>();
                            Date startDate = Date.newInstance(selectedFromYear, selectedFromMonth, 1);
                            Date endDate = Date.newInstance(selectedToYear, selectedToMonth, 1).addMonths(1).addDays(-1);

                            for(String str_type :m_type_contractDate_calcPaymentLine.keySet()){
                               ASI_TH_CRM_PaymentRequest__c payment = new ASI_TH_CRM_PaymentRequest__c();
                                payment.ASI_CRM_CN_OutletWS__c = l_RelatedCalcPaymentLine[0].ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__c;
                                payment.ASI_TH_CRM_Contract__c = l_RelatedCalcPaymentLine[0].ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c;
                                payment.OwnerId = l_RelatedCalcPaymentLine[0].ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.OwnerId;
                                payment.ASI_TH_CRM_Status__c ='Draft';
                                payment.ASI_CRM_Date_From__c =startDate;
                                payment.ASI_CRM_Date_To__c =endDate;
                                payment.RecordTypeId =idRT_PaymentRequest;
                                payment.ASI_CRM_CN_Description__c ='Payment Auto Generation';
                                payment.ASI_CRM_Auto_Generate__c =true;
                                payment.ASI_CRM_A_P_Type__c = str_type=='Other Incentive'? true:false;
                                payment.ASI_CRM_Incentive_Type__c =str_type;
                                payment.CurrencyIsoCode = 'MYR';
                                payment.ASI_CRM_GST__c = true;
                                //payment.ASI_CRM_GST_Rate__c = GST;
                                m_type_Payment.put(str_type, payment);
                                l_newPayment.add(payment);
                                
                            }
                            
                            if(l_newPayment.size()>0){
                                insert l_newPayment;    
                            }
                            
                            for(String str_type :m_type_contractDate_calcPaymentLine.keySet()){
                                for(String key :m_type_contractDate_calcPaymentLine.get(str_type).keySet()){
                                    for(ASI_CRM_Calculated_Payment_Item__c calcPaymentLine : m_type_contractDate_calcPaymentLine.get(str_type).get(key) ){
                                        ASI_TH_CRM_PaymentRequestLineItem__c paymentLine = new ASI_TH_CRM_PaymentRequestLineItem__c();
                                        paymentLine.ASI_TH_CRM_Payment_Request__c = m_type_Payment.get(str_type).Id;
                                        paymentLine.ASI_CRM_SKU__c = calcPaymentLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=null ? calcPaymentLine.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c : calcPaymentLine.ASI_CRM_SKU__c;
                                        //paymentLine.ASI_TH_CRM_Amount__c = calcPaymentLine.ASI_CRM_Cash__c;
                                        paymentLine.ASI_CRM_Net_Amount__c = calcPaymentLine.ASI_CRM_Cash__c;
                                        paymentLine.ASI_CRM_Tax_Amount__c  = (1 + (GST/100)) * calcPaymentLine.ASI_CRM_Cash__c;
                                        paymentLine.ASI_CRM_SetupCode__c =calcPaymentLine.ASI_CRM_SetupCode__c;
                                        paymentLine.RecordTypeId = idRT_PaymentRequestItem;
                                        paymentLine.ASI_CRM_CN_Actual_Vol__c =calcPaymentLine.ASI_CRM_Actual_Volume__c;
                                        paymentLine.ASI_CRM_CN_Target_BT__c =calcPaymentLine.ASI_CRM_Target_Volume__c;
                                        paymentLine.CurrencyIsoCode = 'MYR';
                                        String str_Date = calcPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Year__c+calcPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Month__c;
                                        paymentLine.ASI_CRM_Remark__c= str_Date;
                                        l_newPaymentLine.add(paymentLine);   
                                    }
                                }
                            }
                            insert l_newPaymentLine;
                            s_newPaymentLine.addAll(l_newPaymentLine);


                            for(String type:m_type_calcPaymentIds.keySet()){
                                for(Id calcPaymentId : m_type_calcPaymentIds.get(type) ){
                                    ASI_CRM_Calculated_Payment__c calcPayment = new ASI_CRM_Calculated_Payment__c(Id=calcPaymentId, ASI_CRM_Used_for_Payment__c=true, ASI_CRM_Used_By_Payment_Request__c=m_type_Payment.get(type).Id);
                                    l_calcPaymentToUpdate.add(calcPayment);
                                }
                            }
                            update l_calcPaymentToUpdate;
                            
                        }
                        retireveNewPaymentLine();
                        copyToProceededRcd();
                        showNewCashRecords= true;
                        showRelatedRcd =false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, l_newPayment.size()+' Payment Request(s) with '+l_newPaymentLine.size()+' line(s) are generated. Please review "Related Records" below for your reference.'));
                    }catch(exception e){
                        Database.rollback(sp);
                        String err= e.getMessage();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Generation failed. Error: '+err));
                    }
                    
                }else {
                    hasRelatedRecords =false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There are no related records based on your criteria (Refer to the "Related Records" below).'));
                }
                
            }
			
         }
        return null;
    }

    private void matchRelatedRecods(){
        l_RelatedCalcFOCLine= new List<ASI_CRM_Calculated_FOC_Line__c>();
        l_RelatedCalcPaymentLine= new List<ASI_CRM_Calculated_Payment_Item__c>();
        if(selectedType == FOC_OPTION && hasCalcFOC){
            matchedIndex = new List<Integer>();
            for(ASI_CRM_Calculated_FOC_Line__c foc :l_UnusedCalcFOCLine){
                if(l_UnusedCalcFOCLine.indexOf(foc)>0)
                    matchedIndex.add(l_UnusedCalcFOCLine.indexOf(foc));
                if(foc.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c == contractId){
                    Integer focDateInfo = Integer.valueOf(foc.ASI_CRM_Calculated_FOC__r.ASI_CRM_Year__c)*100 + Integer.valueOf(foc.ASI_CRM_Calculated_FOC__r.ASI_CRM_Month__c);
                    Integer selectedFromDateInfo= selectedFromYear*100 +selectedFromMonth;
                    Integer selectedToDateInfo= selectedToYear*100 +selectedToMonth;
                    if(selectedFromDateInfo<=focDateInfo && focDateInfo<=selectedToDateInfo){
                        l_RelatedCalcFOCLine.add(foc);
                    }
                }
            }
        }

        if(selectedType == CASH_OPTION && hasCalcPayment){
            matchedIndex = new List<Integer>();
            
            if(selectedIncentiveType == ALL_OPTION){
            	
                for(ASI_CRM_Calculated_Payment_Item__c cash :l_UnusedCalcPaymentLine){
                    if(l_UnusedCalcPaymentLine.indexOf(cash)>0)
                        matchedIndex.add(l_UnusedCalcPaymentLine.indexOf(cash));
                    if(cash.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c == contractId){
                        Integer cashDateInfo = Integer.valueOf(cash.ASI_CRM_Calculated_Payment__r.ASI_CRM_Year__c)*100 + Integer.valueOf(cash.ASI_CRM_Calculated_Payment__r.ASI_CRM_Month__c);
                        Integer selectedFromDateInfo= selectedFromYear*100 +selectedFromMonth;
                        Integer selectedToDateInfo= selectedToYear*100 +selectedToMonth;
                        
                        if(selectedFromDateInfo<=cashDateInfo && cashDateInfo<=selectedToDateInfo){
                            l_RelatedCalcPaymentLine.add(cash);
                        }
                    }
                }
                
            }
            else{
				
				String selected_incentive = selectedIncentiveType == VOLUME_OPTION ? 'Volume Incentive' : 'Other Incentive';
                for(ASI_CRM_Calculated_Payment_Item__c cash :l_UnusedCalcPaymentLine){
                    if(l_UnusedCalcPaymentLine.indexOf(cash)>0)
                        matchedIndex.add(l_UnusedCalcPaymentLine.indexOf(cash));
                    if(cash.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c == contractId && cash.ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c == selected_incentive){
                        Integer cashDateInfo = Integer.valueOf(cash.ASI_CRM_Calculated_Payment__r.ASI_CRM_Year__c)*100 + Integer.valueOf(cash.ASI_CRM_Calculated_Payment__r.ASI_CRM_Month__c);
                        Integer selectedFromDateInfo= selectedFromYear*100 +selectedFromMonth;
                        Integer selectedToDateInfo= selectedToYear*100 +selectedToMonth;
                        
                        if(selectedFromDateInfo<=cashDateInfo && cashDateInfo<=selectedToDateInfo){
                            
                            l_RelatedCalcPaymentLine.add(cash);
                            
                        }
                    }
                }
				                
            }
            
            
        }
    }

    private void retrieveNewFOCLine(){
        if(s_newFOCLine.size()>0){
            Set<Id> s_Id = new Set<Id>();
            for(ASI_FOC_Request_Item__c focLine :s_newFOCLine){
                s_Id.add(focLine.Id);
                l_newAllFOCLine = [SELECT Id, name, ASI_FOC_SKU__c,ASI_FOC_Request_Order__c,ASI_FOC_Issued_Qty__c,ASI_CRM_SetupCode__c,ASI_CRM_GLReasonCode__c,ASI_FOC_Remark__c,ASI_CRM_Min_SP__c,ASI_CRM_Bottle_Value__c,
                ASI_FOC_Request_Order__r.ASI_CRM_Outlet__c,ASI_FOC_Request_Order__r.ASI_CRM_Contract__c,ASI_FOC_Request_Order__r.ASI_CRM_Date_From__c,ASI_FOC_Request_Order__r.ASI_CRM_Date_To__c,ASI_FOC_Request_Order__r.ASI_CRM_System_Remark__c 
                FROM ASI_FOC_Request_Item__c WHERE Id in:s_Id ORDER BY ASI_FOC_Request_Order__r.ASI_CRM_Outlet__c, ASI_FOC_Request_Order__r.ASI_CRM_Contract__c,ASI_FOC_Request_Order__c,ASI_FOC_SKU__c ASC];

            }

        }
    }

    private void retireveNewPaymentLine(){
        if(s_newPaymentLine.size()>0){
            Set<Id> s_Id = new Set<Id>();
            for(ASI_TH_CRM_PaymentRequestLineItem__c calcPaymentLine :s_newPaymentLine){
                s_Id.add(calcPaymentLine.Id);
                l_newAllPaymentLine = [SELECT 
                                        Id, 
                                        name, 
                                       	ASI_CRM_SKU__c,
                                       	ASI_TH_CRM_Payment_Request__c,
                                       	ASI_CRM_CN_Target_BT__c,
                                       	ASI_CRM_CN_Actual_Vol__c,
                                       	ASI_CRM_SetupCode__c,
                                       	ASI_CRM_CN_AC_Code__c,
                                       	ASI_TH_CRM_Amount__c,
                                       	ASI_CRM_Remark__c,
                                       	ASI_TH_CRM_COA__c,
               					 		ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_OutletWS__c,
                                       	ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,
                                       	ASI_TH_CRM_Payment_Request__r.ASI_CRM_Date_From__c,	
                                       	ASI_TH_CRM_Payment_Request__r.ASI_CRM_Date_To__c,
                                       	ASI_TH_CRM_Payment_Request__r.ASI_CRM_GST_Rate__c,
                                       	ASI_TH_CRM_Payment_Request__r.ASI_CRM_A_P_Type__c, 
                                       	ASI_TH_CRM_Payment_Request__r.ASI_CRM_Incentive_Type__c 
                                       FROM ASI_TH_CRM_PaymentRequestLineItem__c 
                                       WHERE Id in:s_Id 
                                       ORDER BY ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_OutletWS__c, 
                                       	ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,
                                       	ASI_TH_CRM_Payment_Request__c,
                                       	ASI_CRM_SKU__c ASC];

            }

        }
    }

    private void copyToProceededRcd(){
        if(selectedType == FOC_OPTION ){
            l_ProceededCalcFOCLine.addAll(l_RelatedCalcFOCLine);
            for(ASI_CRM_Calculated_FOC_Line__c relatedCalcFoc :l_RelatedCalcFOCLine){
                if(l_UnusedCalcFOCLine.indexOf(relatedCalcFoc)!=-1){
                    l_UnusedCalcFOCLine.remove(l_UnusedCalcFOCLine.indexOf(relatedCalcFoc));
                }
            }
            l_RelatedCalcFOCLine= new List<ASI_CRM_Calculated_FOC_Line__c>();
        }else{
            l_ProceededCalcPaymentLine.addAll(l_RelatedCalcPaymentLine);
            for(ASI_CRM_Calculated_Payment_Item__c relatedCalcCash :l_RelatedCalcPaymentLine){
                if(l_UnusedCalcPaymentLine.indexOf(relatedCalcCash)!=-1){
                    l_UnusedCalcPaymentLine.remove(l_UnusedCalcPaymentLine.indexOf(relatedCalcCash));
                }
            }
            l_RelatedCalcPaymentLine= new List<ASI_CRM_Calculated_Payment_Item__c>();
        }
        
    }
	
    /*
    public pageReference proceedGeneration(){

       
        if( validateValues()){ 
            
           	Integer startDay = 1;
            Integer endDay = Date.daysInMonth(selectedToYear, selectedToMonth);
            Date startDate = Date.newInstance(selectedFromYear, selectedFromMonth, startDay);
            Date endDate = Date.newInstance(selectedToYear, selectedToMonth, endDay);
			Set<Id> contractSet = new Set<Id>();            
            contractSet.add(contractId);
            Id jobId;
            if(selectedType == FOC_OPTION){
                jobId = generateFOC(startDate, endDate, contractSet, genMonthly);
            }
            else{
            	jobId = generatePaymentRequest(startDate, endDate, contractSet, genMonthly);  
            }             

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The reuqest generation is in the progress. Please check later.'));
        }
        else{
            
        }
 
        return null;
    }
	*/


    public boolean validateValues(){
        boolean isValidate = true;
        //Check Date:
        if((selectedFromYear *100+selectedFromMonth)>(selectedToYear*100+selectedToMonth)){
            isValidate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"From Date" should be no larger than "To Date". Please re-select.'));
        }
        //system.debug('selected  date:'+selectedFromYear+'-'+selectedFromMonth+' TO '+selectedToYear+'-'+selectedToMonth);
        
        if((selectedToYear *100+selectedToMonth)> (today.year()*100+today.month()) || (selectedFromYear *100+selectedFromMonth)> (today.year()*100+today.month())  ){
            isValidate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The selected period has not yet to come. Please re-select.'));
        }else if( cutoffDay!=null && selectedToYear == today.year() && selectedToMonth == today.month() && today.day()< cutoffDay){
            isValidate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Offtake records are not cut off until today. If you want to gen request for current month, please wait and try after "'+cutoffDay+'". Please re-select.'));
        }

        //Check Contract:
        if((String.isEmpty(contractId)) || (!String.isEmpty(contractId)&& !availableContract_IdName.containsKey(contractId))){
            isValidate = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Contract. Please re-select.'));
        }
        //system.debug('contractId='+contractId);
        
        return isValidate;
    }
    /*
    public Id generateFOC(Date dateStart, Date dateEnd, set<Id> contractSet, boolean isSeparate){
        Id jobId = Database.executeBatch(new ASI_CRM_MY_Free_Goods_Request_Batch(dateStart, dateEnd, contractSet, isSeparate), 10000);
        return jobId;
    }
	*/    

    /*
	public Id generatePaymentRequest(Date dateStart, Date dateEnd, set<Id> contractSet, boolean isSeparate){
    	Id jobId = Database.executeBatch(new ASI_CRM_MY_CalculatedPaymentReq_Batch(dateStart, dateEnd, contractSet, isSeparate), 10000);
        return jobId;
    }  
	*/
    
    public void changeGenType(){
        
        isShowIncentiveOption = selectedType == FOC_OPTION ? false : true;
        //isShowIncentiveOption = true;
       	system.debug('changeGenType '+isShowIncentiveOption );
        
    }
	
    public void show() {
        system.debug('@@@show@@@');
    }

    public String getJSONContract(){
        Map<Id, MY_Contract> m_Id_contract = new Map<Id,MY_Contract>();
        /**List<ASI_TH_CRM_Contract__c> l_contract  =[SELECT Id, Name FROM ASI_TH_CRM_Contract__c WHERE ASI_TH_CRM_Contract_Status__c ='Final' AND OwnerId=:currentUserId];
        for(ASI_TH_CRM_Contract__c ct : l_contract){
            MY_Contract new_ct = new MY_Contract(ct.Id, String.escapeSingleQuotes(ct.Name));
            m_Id_contract.add(new_ct);
        }**/

        for(ASI_CRM_Calculated_FOC_Line__c cFOCLine : l_UnusedCalcFOCLine){
            if(cFOCLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c != null){
                MY_Contract new_ct = new MY_Contract(cFOCLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c, String.escapeSingleQuotes(cFOCLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.Name));
                availableContract_IdName.put(cFOCLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c,cFOCLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.Name);
                m_Id_contract.put(new_ct.Id, new_ct);
            }
        }

        for(ASI_CRM_Calculated_Payment_Item__c cPaymentLine : l_UnusedCalcPaymentLine){
            if(cPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c != null){
                MY_Contract new_ct = new MY_Contract(cPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c, String.escapeSingleQuotes(cPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.Name));
                availableContract_IdName.put(cPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c,cPaymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.Name);
                m_Id_contract.put(new_ct.Id, new_ct);
            }
        }

        return JSON.serialize(m_Id_contract.values());
    }   

    public class MY_Contract {
        public String Id {get;set;}
        public String Name {get;set;}

        public MY_Contract(){
            Id ='';
            Name ='';
        }
        public MY_Contract(String Id, String Name){
            this.Id = Id;
            this.Name = Name;
        }

    }
    
    


}