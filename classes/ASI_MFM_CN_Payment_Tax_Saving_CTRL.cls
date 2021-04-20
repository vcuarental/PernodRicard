Public class ASI_MFM_CN_Payment_Tax_Saving_CTRL {

    Public String headerId {Get; Set;}
    Public ASI_MFM_Payment__c payment {Get; Set;}
    Public ASI_TH_CRM_PaymentRequest__c tradePayment {Get; Set;}
    Public List<ASI_MFM_Tax_Saving_Line__c> taxSavingList {Get; Set;}
    Public List<selectOption> taxSavingCategory {Get; Set;}
    Public String selectedCategory {Get; Set;}
    Public String taxCat{Get; Set;}
    Public Map<Id, List<ASI_CRM_Expense_Control_Form_Line__c>> mapTaxSavingLine {Get; Set;}
    Public Map<String, String> mapTaxSavingName {Get; Set;}
    Public Map<String, String> mapTaxSavingId {Get; Set;}
    Public Map<Id, ASI_MFM_Tax_Code__c> mapTaxCode{Get; Set;}
    
    Private Final Static Map<String, Schema.SObjectField> paymentLine_FIELD_MAP = Schema.SObjectType.ASI_MFM_Payment_Line_Item__c.fields.getMap();
    Private Final Static Map<String, Schema.SObjectField> tradePaymentLine_FIELD_MAP = Schema.SObjectType.ASI_TH_CRM_PaymentRequestLineItem__c.fields.getMap();
    
    Public ASI_MFM_CN_Payment_Tax_Saving_CTRL(){
        
        headerId = ApexPages.currentPage().getParameters().get('id');
        
        if(headerId != Null && headerId != ''){
            
            tradePayment = [SELECT id
                            , Name
                            , ASI_CRM_CN_PO_No__c
                            , ASI_CRM_CN_OutletWS__c
                            , ASI_CRM_CN_OutletWS__r.Name
                            , ASI_CRM_CN_Promotion_Type__c
                            , ASI_CRM_CN_Last_Payment__c 
                            , ASI_CRM_CN_Last_Year_Payment__c
                            , ASI_TH_CRM_Status__c
                            , ASI_CRM_CN_Currency__c
                            , ASI_CRM_CN_Bottle_Collection_Rate__c
                            , ASI_CRM_CN_PO_Start_Date__c 
                            , ASI_CRM_CN_PO_End_Date__c
                            , ASI_CRM_CN_Payment_Raised_Date__c
                            , ASI_CRM_CN_Payment_Type__c
                            , ASI_CRM_CN_Description__c
                            , ASI_CRM_Invoice_Afterwards__c
                            , ASI_CRM_Entertaiment__c
                            , ASI_CRM_Entertainment_Amount__c
                            , ASI_CRM_IIT_Amount__c
                            , ASI_CRM_Tax_Code_for_Tax_Saving__c 
                            , ASI_CRM_Tax_Amount__c
                            , ASI_CRM_Tax_Saving_Category__c
                            , ASI_CRM_Total_Payment_Amount__c
                            , ASI_CRM_Total_Amount_Fx__c
                            , ASI_CRM_Sum_Of_Tax_Saving_Amount__c
                            , (SELECT id, ASI_CRM_CN_Invoice_Number__c FROM Payment_Header_Payee_Line_Itme__r WHERE ASI_CRM_CN_Invoice_Number__c!= '' ORDER By CreatedDate DESC limit 1)
                            FROM ASI_TH_CRM_PaymentRequest__c
                            WHERE id = : headerId
                           ];
            
            init('Trade A&P Payment');
            
            if(tradePayment.ASI_CRM_Tax_Saving_Category__c != Null && tradePayment.ASI_CRM_Tax_Saving_Category__c != ''){
                for(String taxSavingName : tradePayment.ASI_CRM_Tax_Saving_Category__c.split(';')){
                    
                    if(mapTaxSavingId.containsKey(taxSavingName.toLowerCase().trim())){
                        taxCat += mapTaxSavingId.get(taxSavingName.toLowerCase().trim()) + ';';
                    }
                }
            }
        }
    }
    
    Public ASI_MFM_CN_Payment_Tax_Saving_CTRL(apexPages.StandardController sc){
        
        payment = (ASI_MFM_Payment__c)sc.getRecord();
        if(payment.ASI_MFM_Tax_Code_for_Tax_Saving__c == Null)
            payment.ASI_MFM_Tax_Code_for_Tax_Saving__c = payment.ASI_MFM_Tax_Code__c;
        
        headerId = payment.id;
        
        init('Consumer A&P Payment');
        
        if(payment.ASI_MFM_Tax_Saving_Category__c != Null && payment.ASI_MFM_Tax_Saving_Category__c != ''){
            for(String taxSavingName : payment.ASI_MFM_Tax_Saving_Category__c.split(';')){
                
                if(mapTaxSavingId.containsKey(taxSavingName.toLowerCase().trim())){
                    
                    taxCat += mapTaxSavingId.get(taxSavingName.toLowerCase().trim()) + ';';
                }
            }
        }
    }
    
    Public void init(String typeOfTaxSaving){
        
        taxSavingCategory = new List<selectOption>();
        Set<String> savingPurpose = new Set<String>();
        mapTaxSavingName = new Map<String, String>();
        mapTaxSavingId = new Map<String, String>();
        mapTaxSavingLine = new Map<Id, List<ASI_CRM_Expense_Control_Form_Line__c>>();
        
        mapTaxCode = new Map<id, ASI_MFM_Tax_Code__c>([SELECT id
                                                       , ASI_MFM_VAT_Rate__c
                                                       , ASI_MFM_Manual_Input__c
                                                       FROM ASI_MFM_Tax_Code__c
                                                       WHERE RecordType.DeveloperName Like 'ASI_MFM_CN_Tax_Code'
                                                      ]);
        
        taxCat = '';
        
        taxSavingCategory.add(new selectOption('', '-- None --'));
        
        for(ASI_CRM_Expense_Control_Form_Line__c obj : [SELECT id
                                                        , ASI_MFM_A_C_Code__c
                                                        , ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c
                                                        , ASI_MFM_Department_Category__c
                                                        , ASI_MFM_Expense_Control_Form__c
                                                        , ASI_MFM_Mark_Up_Value__c
                                                        , ASI_MFM_Subbrand_Code__c
                                                        , ASI_MFM_Tax_Saving_Formula__c
                                                        , ASI_MFM_Type__c
                                                        , ASI_MFM_Expense_Control_Form__r.ASI_MFM_Mark_Up_Value__c
                                                        , ASI_MFM_Expense_Control_Form__r.Name
                                                        , ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c
                                                        , ASI_MFM_Tax_Saving_Formula_2__c
                                                        , ASI_MFM_Cr_Dr__c
                                                        , ASI_MFM_Check_Payment_Subbrand_First__c
                                                        , ASI_MFM_Group_By__c
                                                        FROM ASI_CRM_Expense_Control_Form_Line__c
                                                        WHERE recordType.DeveloperName Like 'ASI_MFM_CN_Tax_Saving_Control_Form_Line'
                                                        AND ASI_MFM_Expense_Control_Form__r.ASI_MFM_Module__c Like : typeOfTaxSaving
                                                       ]){
            
			List<ASI_CRM_Expense_Control_Form_Line__c> tmpLine = new List<ASI_CRM_Expense_Control_Form_Line__c>();
                                                           
            if(!savingPurpose.contains(obj.ASI_MFM_Expense_Control_Form__r.Name)){
                
                savingPurpose.add(obj.ASI_MFM_Expense_Control_Form__r.Name);
                taxSavingCategory.add(new selectOption(obj.ASI_MFM_Expense_Control_Form__c, obj.ASI_MFM_Expense_Control_Form__r.Name));
            }
            
            if(mapTaxSavingLine.containsKey(obj.ASI_MFM_Expense_Control_Form__c)){
                
                tmpLine = mapTaxSavingLine.get(obj.ASI_MFM_Expense_Control_Form__c);
            }
            
            tmpLine.add(obj);
            mapTaxSavingLine.put(obj.ASI_MFM_Expense_Control_Form__c, tmpLine);
            mapTaxSavingName.put(obj.ASI_MFM_Expense_Control_Form__c, obj.ASI_MFM_Expense_Control_Form__r.Name);
            mapTaxSavingId.put(obj.ASI_MFM_Expense_Control_Form__r.Name.toLowerCase().trim(), obj.ASI_MFM_Expense_Control_Form__c);
        }
        
        taxSavingList = queryTaxSavingLine(typeOfTaxSaving);
    }
    
    //--------------------------------------------------- generate tax saving lines for consumer a&p
    Public Void generateTaxSavingLine(){
        
        Set<String> formulaSet = new Set<String>();
        Set<String> fields = new Set<String>();
        List<ASI_MFM_Tax_Saving_Line__c> insertTaxSavingList = new List<ASI_MFM_Tax_Saving_Line__c>();
        List<ASI_CRM_Expense_Control_Form_Line__c> selectedTaxSavingList = new List<ASI_CRM_Expense_Control_Form_Line__c>();
        Map<String, List<ASI_CRM_Expense_Control_Form_Line__c>> mapSelectedTaxSavingCat = new Map<String, List<ASI_CRM_Expense_Control_Form_Line__c>>();
        Decimal totalGroupedAmt = 0;
        
        /*Map<String, Decimal> mapTotalAmount = new Map<String, Decimal>();
        ASI_MFM_Tax_Saving_Line__c debitLine_VAT;
        ASI_MFM_Tax_Saving_Line__c creditLine_VAT;
        ASI_MFM_Tax_Saving_Line__c debitLine_IIT;
        ASI_MFM_Tax_Saving_Line__c creditLine_IIT;*/
        
        Map<Id, ASI_MFM_Tax_Code__c> mapTaxCode = new Map<id, ASI_MFM_Tax_Code__c>([SELECT id
                                                                                    , ASI_MFM_VAT_Rate__c
                                                                                    , ASI_MFM_Manual_Input__c
                                                                                    FROM ASI_MFM_Tax_Code__c
                                                                                    WHERE RecordType.DeveloperName Like 'ASI_MFM_CN_Tax_Code'
                                                                                   ]);
        
        if(taxSavingList.size() > 0){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'This payment already has tax saving lines, please remove all lines before genertaion.'));
            Return;
        }
        
        payment.ASI_MFM_Tax_Saving_Category__c = '';
        
        for(String taxSavingId : selectedCategory.replace('[', '').replace(']', '').split(',')){
            
            taxSavingId = taxSavingId.trim();
            
            if(mapTaxSavingName.containsKey(taxSavingId)){
                
                payment.ASI_MFM_Tax_Saving_Category__c += mapTaxSavingName.get(taxSavingId) + ';';
                
                for(ASI_CRM_Expense_Control_Form_Line__c obj : mapTaxSavingLine.get(taxSavingId)){
                    
                    if(obj.ASI_MFM_Tax_Saving_Formula__c == Null || obj.ASI_MFM_Tax_Saving_Formula__c == ''){
                        
                        apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Tax Saving Category : ' + mapTaxSavingName.get(taxSavingId) + ' missing Tax Saving Formula, Please contact Admin for further assistance.'));
                        Return;
                    }
                    
                    selectedTaxSavingList.add(obj);
                }
            }
        }
        
        if(payment.ASI_MFM_Tax_Code_for_Tax_Saving__c != Null){
            
            if(mapTaxCode.containsKey(payment.ASI_MFM_Tax_Code_for_Tax_Saving__c) && !mapTaxCode.get(payment.ASI_MFM_Tax_Code_for_Tax_Saving__c).ASI_MFM_Manual_Input__c){
                
                payment.ASI_MFM_VAT_Amount__c = null;
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            Update payment;
            
        }catch(dmlException dmle){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , dmle.getMessage() ));
            database.rollback(sp);
            Return;
        }
        
        //query payment line
        String queryPaymentLineStr = queryStr(selectedTaxSavingList, fields, paymentLine_FIELD_MAP, 'ASI_MFM_Payment__c', 'ASI_MFM_Payment_Line_Item__c', 'ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,ASI_MFM_Payment__r.ASI_MFM_BU__r.ASI_MFM_L3__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_PP_Category__r.ASI_MFM_Department_Attribute__c, ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c');
        
        //Tax Saving Line Generation Logic
        
        for(ASI_MFM_Payment_Line_Item__c obj : dataBase.query(queryPaymentLineStr)){
            
            for(String taxSavingId : selectedCategory.replace('[', '').replace(']', '').split(',')){
                
                taxSavingId = taxSavingId.trim();
                Map<String, Decimal> mapCRDR = new Map<String, Decimal>();
                ASI_MFM_Tax_Saving_Line__c debitLine;
                
                if(!mapTaxSavingLine.containsKey(taxSavingId))
                    continue;
                
                for(ASI_CRM_Expense_Control_Form_Line__c line : mapTaxSavingLine.get(taxSavingId)){
                    
                    String BUPrefix = '';
                    String BUSuffix = '';
                    String ACCode = '';
                    String departmentCode = '';
                    String subbrandCode = '';
                    Decimal delta = 0;
                    
                    ASI_MFM_Tax_Saving_Line__c tmp = new ASI_MFM_Tax_Saving_Line__c(ASI_MFM_Consumer_A_P_Payment_Line__c = obj.Id
                                                                                    , ASI_MFM_Tax_Saving_Control_Form_Line__c = line.id
                                                                                    , ASI_MFM_Cr_Dr__c = line.ASI_MFM_Cr_Dr__c
                                                                                   );
                    
                    //A/C Code Logic
                    //get BU Code
                    if(obj.ASI_MFM_Payment__r.ASI_MFM_BU__c != Null && obj.ASI_MFM_Payment__r.ASI_MFM_BU__r.ASI_MFM_L3__c != Null){
                        
                        BUPrefix = obj.ASI_MFM_Payment__r.ASI_MFM_BU__r.ASI_MFM_L3__c.subString(0, 3);
                        BUSuffix = obj.ASI_MFM_Payment__r.ASI_MFM_BU__r.ASI_MFM_L3__c.subString(3);
                    }
                    
                    //get Department Code
                    if(line.ASI_MFM_Department_Category__c != Null && line.ASI_MFM_Department_Category__c != ''){
                        
                        departmentCode = line.ASI_MFM_Department_Category__c;
                    }else if(obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_PP_Category__c != Null && obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_PP_Category__r.ASI_MFM_Department_Attribute__c != ''){
                        
                        departmentCode = obj.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_PO_PP_Category__r.ASI_MFM_Department_Attribute__c;
                    }
                    
                    //get A/C Code
                    ACCode = getACCode(line.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, obj.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c);
                    
                    //get Sub Brand Code
                    subbrandCode = getSubbrandCode(line.ASI_MFM_Check_Payment_Subbrand_First__c, line.ASI_MFM_Subbrand_Code__c, obj.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c);
                    
                    //Combine A/C Code
                    tmp.ASI_MFM_Account_Code_Combination__c = ASI_MFM_CN_FormulaClass.generateACCode(BUPrefix, BUSuffix, departmentCode, ACCode, subbrandCode);
                    
                    //Tax Saving Formula Logic
                    if((line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && payment.ASI_MFM_IIT_Amount__c != Null && payment.ASI_MFM_IIT_Amount__c != 0) || (!line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && payment.ASI_MFM_VAT_Amount__c != Null && payment.ASI_MFM_VAT_Amount__c != 0)){
                        
                        if(line.ASI_MFM_Tax_Saving_Formula_2__c == Null || line.ASI_MFM_Tax_Saving_Formula_2__c == ''){
                            
                            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Tax Saving Category : ' + line.ASI_MFM_Expense_Control_Form__r.Name + ' missing Tax Saving Formula, Please contact Admin for further assistance.'));
                            database.rollback(sp);
                            Return;
                        }
                        
                        tmp.ASI_MFM_Amount__c = ASI_MFM_CN_FormulaClass.stringToValue(line.ASI_MFM_Tax_Saving_Formula_2__c, paymentLine_FIELD_MAP, fields, obj);
                        //mapTotalAmount = handleDebitCreditDelta(mapTotalAmount, (line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && payment.ASI_MFM_IIT_Amount__c != Null ? 'IIT' : 'VAT'), tmp.ASI_MFM_Cr_Dr__c, tmp.ASI_MFM_Amount__c);
                        
                    }else{
                        
                        tmp.ASI_MFM_Amount__c = ASI_MFM_CN_FormulaClass.stringToValue(line.ASI_MFM_Tax_Saving_Formula__c, paymentLine_FIELD_MAP, fields, obj);
                    }
                    
                    //handle Debit Credit delta
                    mapCRDR = handleDebitCreditDelta(mapCRDR, line.ASI_MFM_Expense_Control_Form__c, tmp.ASI_MFM_Cr_Dr__c, tmp.ASI_MFM_Amount__c);
                    
                    if(tmp.ASI_MFM_Cr_Dr__c == 'Debit' && debitLine == Null)
                        debitLine = tmp;
                    
                    /*if(payment.ASI_MFM_VAT_Amount__c != Null && !line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && debitLine_VAT == Null && tmp.ASI_MFM_Cr_Dr__c == 'Debit')
                        debitLine_VAT = tmp;
                    else if(payment.ASI_MFM_VAT_Amount__c != Null && !line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && creditLine_VAT == Null && tmp.ASI_MFM_Cr_Dr__c == 'Credit')
                        creditLine_VAT = tmp;
                    else if(payment.ASI_MFM_IIT_Amount__c != Null && line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && debitLine_IIT == Null && tmp.ASI_MFM_Cr_Dr__c == 'Debit')
                        debitLine_IIT = tmp;
                    else if(payment.ASI_MFM_IIT_Amount__c != Null && line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && creditLine_IIT == Null && tmp.ASI_MFM_Cr_Dr__c == 'Credit')
                        creditLine_IIT = tmp;*/
                    
                    if(line.ASI_MFM_Group_By__c)
                        totalGroupedAmt += tmp.ASI_MFM_Amount__c.setScale(2);
                    
                    insertTaxSavingList.add(tmp);
                }
                
                if(debitLine != Null)
                    debitLine.ASI_MFM_Amount__c = (debitLine.ASI_MFM_Amount__c != Null ? debitLine.ASI_MFM_Amount__c : 0) + (mapCRDR.get(taxSavingId + 'Credit') - mapCRDR.get(taxSavingId + 'Debit'));
                
                totalGroupedAmt += (mapCRDR.get(taxSavingId + 'Credit') - mapCRDR.get(taxSavingId + 'Debit'));
            }
        }
        
        /*if(mapTotalAmount.containsKey('IITCredit')){
            debitLine_IIT.ASI_MFM_Amount__c = (debitLine_IIT.ASI_MFM_Amount__c != Null ? debitLine_IIT.ASI_MFM_Amount__c : 0) + (payment.ASI_MFM_IIT_Amount__c - mapTotalAmount.get('IITCredit'));
            creditLine_IIT.ASI_MFM_Amount__c = (creditLine_IIT.ASI_MFM_Amount__c != Null ? creditLine_IIT.ASI_MFM_Amount__c : 0) + (payment.ASI_MFM_IIT_Amount__c - mapTotalAmount.get('IITCredit'));
        }
        
        if(mapTotalAmount.containsKey('VATCredit')){
            debitLine_VAT.ASI_MFM_Amount__c = (debitLine_VAT.ASI_MFM_Amount__c != Null ? debitLine_VAT.ASI_MFM_Amount__c : 0) + (payment.ASI_MFM_VAT_Amount__c - mapTotalAmount.get('VATCredit'));
            creditLine_VAT.ASI_MFM_Amount__c = (creditLine_VAT.ASI_MFM_Amount__c != Null ? creditLine_VAT.ASI_MFM_Amount__c : 0) + (payment.ASI_MFM_VAT_Amount__c - mapTotalAmount.get('VATCredit'));
        }*/
        
        try{
            
            payment.ASI_MFM_Sum_Of_Tax_Saving_Amount__c = totalGroupedAmt;
            
            Insert insertTaxSavingList;
            Update payment;
            taxSavingList = queryTaxSavingLine('Consumer A&P Payment');
            
        }catch(dmlException dmle){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , dmle.getMessage() ));
            database.rollback(sp);
            taxSavingList = new List<ASI_MFM_Tax_Saving_Line__c>();
            Return;
        }
        
        Return;
    }
    
    //--------------------------------------------------- generate tax saving lines for trade a&p
    Public void generateTaxSavingLine_Trade(){
        
        Set<String> formulaSet = new Set<String>();
        Set<String> fields = new Set<String>();
        List<ASI_MFM_Tax_Saving_Line__c> insertTaxSavingList = new List<ASI_MFM_Tax_Saving_Line__c>();
        List<ASI_CRM_Expense_Control_Form_Line__c> selectedTaxSavingList = new List<ASI_CRM_Expense_Control_Form_Line__c>();
        Decimal totalGroupedAmt = 0;
        
        /*Map<String, Decimal> mapTotalAmount = new Map<String, Decimal>();
        ASI_MFM_Tax_Saving_Line__c debitLine_VAT;
        ASI_MFM_Tax_Saving_Line__c creditLine_VAT;
        ASI_MFM_Tax_Saving_Line__c debitLine_IIT;
        ASI_MFM_Tax_Saving_Line__c creditLine_IIT;*/
        
        List<ASI_CRM_Region__c> hbrRegion = new List<ASI_CRM_Region__c>([SELECT id, ASI_CRM_JDE_Company_Code__c FROM ASI_CRM_Region__c WHERE Name LIKE 'HBR' AND RecordType.DeveloperName Like '%_CN_%' Limit 1]);
        
        Map<Id, ASI_MFM_Tax_Code__c> mapTaxCode = new Map<id, ASI_MFM_Tax_Code__c>([SELECT id
                                                                                    , ASI_MFM_VAT_Rate__c
                                                                                    , ASI_MFM_Manual_Input__c
                                                                                    FROM ASI_MFM_Tax_Code__c
                                                                                    WHERE RecordType.DeveloperName Like 'ASI_MFM_CN_Tax_Code'
                                                                                   ]);
        
        if(taxSavingList.size() > 0){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'This payment already has tax saving lines, please remove all lines before genertaion.'));
            Return;
        }
        
        tradePayment.ASI_CRM_Tax_Saving_Category__c = '';
        
        for(String taxSavingId : selectedCategory.replace('[', '').replace(']', '').split(',')){
            
            taxSavingId = taxSavingId.trim();
            
            if(mapTaxSavingName.containsKey(taxSavingId)){
                
                tradePayment.ASI_CRM_Tax_Saving_Category__c += mapTaxSavingName.get(taxSavingId) + ';';
                
                for(ASI_CRM_Expense_Control_Form_Line__c obj : mapTaxSavingLine.get(taxSavingId)){
                    
                    if(obj.ASI_MFM_Tax_Saving_Formula__c == Null || obj.ASI_MFM_Tax_Saving_Formula__c == ''){
                        
                        apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Tax Saving Category : ' + mapTaxSavingName.get(taxSavingId) + ' missing Tax Saving Formula, Please contact Admin for further assistance.'));
                        Return;
                    }
                    
                    selectedTaxSavingList.add(obj);
                }
            }
        }
        
        if(tradePayment.ASI_CRM_Tax_Code_for_Tax_Saving__c != Null){
            
            if(mapTaxCode.containsKey(tradePayment.ASI_CRM_Tax_Code_for_Tax_Saving__c) && !mapTaxCode.get(tradePayment.ASI_CRM_Tax_Code_for_Tax_Saving__c).ASI_MFM_Manual_Input__c){
                
                tradePayment.ASI_CRM_Tax_Amount__c = null;
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            Update tradePayment;
            
        }catch(dmlException dmle){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , dmle.getMessage() ));
            database.rollback(sp);
            Return;
        }
        
        //query payment line
        String additionalFields =  'ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c,ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_No__c, ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Code__c,ASI_TH_CRM_Payment_Request__r.ASI_CRM_Premium_Region_Code__c,ASI_TH_CRM_Payment_Request__r.ASI_CRM_Prestige_Region_Code__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_TH_CRM_Payment_Request__r.ASI_CRM_Commercial_Team__c';
        String queryPaymentLineStr = queryStr(selectedTaxSavingList, fields, tradePaymentLine_FIELD_MAP, 'ASI_TH_CRM_Payment_Request__c', 'ASI_TH_CRM_PaymentRequestLineItem__c', additionalFields);
        System.debug(LoggingLevel.INFO, '*** additionalFields: ' + additionalFields);
        //Tax Saving Line Generation Logic
        for(ASI_TH_CRM_PaymentRequestLineItem__c obj : dataBase.query(queryPaymentLineStr)){
            System.debug(LoggingLevel.INFO, '*** obj: ' + obj);
            System.debug(LoggingLevel.INFO, '*** selectedCategory: ' + selectedCategory);
            for(String taxSavingId : selectedCategory.replace('[', '').replace(']', '').split(',')){
                System.debug(LoggingLevel.INFO, '*** taxSavingId: ' + taxSavingId);
                taxSavingId = taxSavingId.trim();
                Map<String, Decimal> mapCRDR = new Map<String, Decimal>();
                ASI_MFM_Tax_Saving_Line__c debitLine;
                
                if(!mapTaxSavingLine.containsKey(taxSavingId))
                    continue;
                
                for(ASI_CRM_Expense_Control_Form_Line__c line : mapTaxSavingLine.get(taxSavingId)){
                    
                    Decimal delta = 0;
                    String BUPrefix = '';
                    String BUSuffix = '';
                    String ACCode = '';
                    String departmentCode = '';
                    String subbrandCode = '';
                    
                    ASI_MFM_Tax_Saving_Line__c tmp = new ASI_MFM_Tax_Saving_Line__c(ASI_MFM_Trade_A_P_Payment_Line__c = obj.Id
                                                                                    , ASI_MFM_Tax_Saving_Control_Form_Line__c = line.id
                                                                                    , ASI_MFM_Cr_Dr__c = line.ASI_MFM_Cr_Dr__c
                                                                                    , ASI_MFM_Suffix__c = '000'
                                                                                    , ASI_MFM_Tax_PO_Number__c = obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_PO_No__c
                                                                                   );
                    
                    //for trade tax saving only
                    tmp.ASI_CRM_Trade_Invoice_Number__c = tradePayment.Payment_Header_Payee_Line_Itme__r.size() > 0 ? tradePayment.Payment_Header_Payee_Line_Itme__r[0].ASI_CRM_CN_Invoice_Number__c : '';
                    
                    //get BU Code
                    if(obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Commercial_Team__c != '' && obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Commercial_Team__c != null
                       && ((obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Commercial_Team__c.toLowerCase() == 'premium' && obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Premium_Region_Code__c != '')
                           || (obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Commercial_Team__c.toLowerCase() == 'prestige' && obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Prestige_Region_Code__c != '')
                           || (obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Commercial_Team__c.toLowerCase() == 'hq/hotel')
                          )){
                              
                              if(obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Commercial_Team__c.toLowerCase() == 'premium'){
                                  
                                  BUPrefix = obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Premium_Region_Code__c.subString(0, 3);
                                  BUSuffix = obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Premium_Region_Code__c.subString(3);
                              }else if(obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Commercial_Team__c.toLowerCase() == 'prestige'
                                       || (obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Commercial_Team__c.toLowerCase() == 'hq/hotel'
                                           && !obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c
                                          )
                                      ){
                                          
                                          BUPrefix = obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Prestige_Region_Code__c.subString(0, 3);
                                          BUSuffix = obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Prestige_Region_Code__c.subString(3);
                                      }else if(obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_Commercial_Team__c.toLowerCase() == 'hq/hotel'
                                               && obj.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Is_IHBR_Outlet__c
                                              ){//20180309 Introv Added
                                          
                                          if(hbrRegion.size() > 0 && hbrRegion[0].ASI_CRM_JDE_Company_Code__c != Null && hbrRegion[0].ASI_CRM_JDE_Company_Code__c != ''){
                                              BUPrefix = hbrRegion[0].ASI_CRM_JDE_Company_Code__c.subString(0, 3);
                                              BUSuffix = hbrRegion[0].ASI_CRM_JDE_Company_Code__c.subString(3);
                                          }else{
                                              BUPrefix = '398';
                                              BUSuffix = '50';
                                          }
                                      }
                          }
                    
                    //get A/C Code
                    ACCode = getACCode(line.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, obj.ASI_CRM_CN_AC_Code__r.ASI_MFM_A_C_Code__c);
                    
                    //get Department Code
                    if(line.ASI_MFM_Department_Category__c != Null && line.ASI_MFM_Department_Category__c != ''){
                        
                        departmentCode = line.ASI_MFM_Department_Category__c;
                    }
                    
                    //get Sub Brand Code
                    subbrandCode = getSubbrandCode(line.ASI_MFM_Check_Payment_Subbrand_First__c, line.ASI_MFM_Subbrand_Code__c, obj.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c);
                    
                    tmp.ASI_MFM_Account_Code_Combination__c = ASI_MFM_CN_FormulaClass.generateACCode(BUPrefix, BUSuffix, departmentCode, ACCode, subbrandCode);
                    
                    //Tax Saving Formula Logic
                    if((line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && tradePayment.ASI_CRM_IIT_Amount__c != Null) || (!line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && tradePayment.ASI_CRM_Tax_Amount__c != Null)){
                        
                        if(line.ASI_MFM_Tax_Saving_Formula_2__c == Null || line.ASI_MFM_Tax_Saving_Formula_2__c == ''){
                            
                            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Tax Saving Category : ' + line.ASI_MFM_Expense_Control_Form__r.Name + ' missing Tax Saving Formula, Please contact Admin for further assistance.'));
                            database.rollback(sp);
                            Return;
                        }
                        
                        tmp.ASI_MFM_Amount__c = ASI_MFM_CN_FormulaClass.stringToValue(line.ASI_MFM_Tax_Saving_Formula_2__c, tradePaymentLine_FIELD_MAP, fields, obj);
                        //mapTotalAmount = handleDebitCreditDelta(mapTotalAmount, (tradePayment.ASI_CRM_IIT_Amount__c != Null && line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c ? 'IIT' : 'VAT'), tmp.ASI_MFM_Cr_Dr__c, tmp.ASI_MFM_Amount__c);
                        
                    }else{
                        
                        tmp.ASI_MFM_Amount__c = ASI_MFM_CN_FormulaClass.stringToValue(line.ASI_MFM_Tax_Saving_Formula__c, tradePaymentLine_FIELD_MAP, fields, obj);
                    }
                    
                    //handle Debit Credit delta
                    mapCRDR = handleDebitCreditDelta(mapCRDR, line.ASI_MFM_Expense_Control_Form__c, tmp.ASI_MFM_Cr_Dr__c, tmp.ASI_MFM_Amount__c);
                    
                    if(tmp.ASI_MFM_Cr_Dr__c == 'Debit' && debitLine == Null)
                        debitLine = tmp;
                    
                    /*if(tradePayment.ASI_CRM_Tax_Amount__c != Null && !line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && debitLine_VAT == Null && tmp.ASI_MFM_Cr_Dr__c == 'Debit')
                        debitLine_VAT = tmp;
                    else if(tradePayment.ASI_CRM_Tax_Amount__c != Null && !line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && creditLine_VAT == Null && tmp.ASI_MFM_Cr_Dr__c == 'Credit')
                        creditLine_VAT = tmp;
                    else if(tradePayment.ASI_CRM_IIT_Amount__c != Null && line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && debitLine_IIT == Null && tmp.ASI_MFM_Cr_Dr__c == 'Debit')
                        debitLine_IIT = tmp;
                    else if(tradePayment.ASI_CRM_IIT_Amount__c != Null && line.ASI_MFM_Expense_Control_Form__r.ASI_MFM_is_IIT__c && creditLine_IIT == Null && tmp.ASI_MFM_Cr_Dr__c == 'Credit')
                        creditLine_IIT = tmp;*/
                    
                    if(line.ASI_MFM_Group_By__c)
                        totalGroupedAmt += tmp.ASI_MFM_Amount__c.setScale(2);
                    if(tmp.ASI_MFM_Amount__c != 0 && tmp.ASI_MFM_Amount__c != null){
                        insertTaxSavingList.add(tmp);
                    }
                }
                
                if(debitLine != Null)
                    debitLine.ASI_MFM_Amount__c = (debitLine.ASI_MFM_Amount__c != Null ? debitLine.ASI_MFM_Amount__c : 0) + (mapCRDR.get(taxSavingId + 'Credit') - mapCRDR.get(taxSavingId + 'Debit'));
                
                totalGroupedAmt += (mapCRDR.get(taxSavingId + 'Credit') - mapCRDR.get(taxSavingId + 'Debit'));
            }
        }
        System.debug(LoggingLevel.INFO, '*** additionalFields: ' + additionalFields);
        /*if(mapTotalAmount.containsKey('IITCredit')){
            debitLine_IIT.ASI_MFM_Amount__c = (debitLine_IIT.ASI_MFM_Amount__c != Null ? debitLine_IIT.ASI_MFM_Amount__c : 0) + (tradePayment.ASI_CRM_IIT_Amount__c - mapTotalAmount.get('IITCredit'));
            creditLine_IIT.ASI_MFM_Amount__c = (creditLine_IIT.ASI_MFM_Amount__c != Null ? creditLine_IIT.ASI_MFM_Amount__c : 0) + (tradePayment.ASI_CRM_IIT_Amount__c - mapTotalAmount.get('IITCredit'));
        }
        
        if(mapTotalAmount.containsKey('VATCredit')){
            debitLine_VAT.ASI_MFM_Amount__c = (debitLine_VAT.ASI_MFM_Amount__c != Null ? debitLine_VAT.ASI_MFM_Amount__c : 0) + (tradePayment.ASI_CRM_Tax_Amount__c - mapTotalAmount.get('VATCredit'));
            creditLine_VAT.ASI_MFM_Amount__c = (creditLine_VAT.ASI_MFM_Amount__c != Null ? creditLine_VAT.ASI_MFM_Amount__c : 0) + (tradePayment.ASI_CRM_Tax_Amount__c - mapTotalAmount.get('VATCredit'));
        }*/
        
        try{
            tradePayment.ASI_CRM_Sum_Of_Tax_Saving_Amount__c = totalGroupedAmt;
            
            Insert insertTaxSavingList;
            Update tradePayment;
            taxSavingList = queryTaxSavingLine('Trade A&P Payment');
            
        }catch(dmlException dmle){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , dmle.getMessage() ));
            database.rollback(sp);
            taxSavingList = new List<ASI_MFM_Tax_Saving_Line__c>();
            Return;
        }
        
        Return;
    }
    
    //--------------------------------------------------- save without generate lines
    Public PageReference saveWithoutLine(){
        
        if(taxSavingList.size() > 0){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'This payment already has tax saving lines, please remove all lines before saving.'));
            Return null;
        }
        
        if(payment != Null)
            payment.ASI_MFM_Tax_Saving_Category__c = '';
        
        if(tradePayment != Null)
            tradePayment.ASI_CRM_Tax_Saving_Category__c = '';
        for(String taxSavingId : selectedCategory.replace('[', '').replace(']', '').split(',')){
            
            taxSavingId = taxSavingId.trim();
            if(mapTaxSavingName.containsKey(taxSavingId)){
                
                if(payment != Null)
                    payment.ASI_MFM_Tax_Saving_Category__c += mapTaxSavingName.get(taxSavingId) + ';';
                if(tradePayment != Null)
                    tradePayment.ASI_CRM_Tax_Saving_Category__c += mapTaxSavingName.get(taxSavingId) + ';';
            }
        }
        
        try{
            if(payment != Null)
                Update payment;
            
            if(tradePayment != Null)
                update tradePayment;
            
        }catch(dmlException dmle){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , dmle.getMessage() ));
            Return null;
        }
        
        Return new pageReference('/' + headerId);
    }
    
    //--------------------------------------------------- black to record
    Public PageReference Back(){
        
        Return new pageReference('/' + headerId);
    }
    
    //--------------------------------------------------- delete tax saving lines
    Public void deleteTaxSavingLine(){
        
        try{
            if(payment != Null){
                
                payment.ASI_MFM_Sum_Of_Tax_Saving_Amount__c = 0;
                update payment;
            }else if(tradePayment != Null){
                
                tradePayment.ASI_CRM_Sum_Of_Tax_Saving_Amount__c = 0;
                update tradePayment;
            }
                
                
            Delete taxSavingList;
            
        }catch(dmlException dmle){
            
            apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , dmle.getMessage() ));
            Return;
        }
        
        taxSavingList = new List<ASI_MFM_Tax_Saving_Line__c>();
        Return;
    }
    
    @TestVisible
    Private Map<String, Decimal> handleDebitCreditDelta(Map<String, Decimal> cdMap, String keyPrefix, String keySuffix, decimal payAmt){
        
        decimal delta = 0;
        
        if(cdMap.containsKey('' + keyPrefix + keySuffix))
            delta = cdMap.get('' + keyPrefix + keySuffix) != Null ? cdMap.get('' + keyPrefix + keySuffix) : 0;
        
        delta += payAmt != Null ? payAmt.setScale(2) : 0;
        
        system.debug('delta     ' + delta + '   ASI_MFM_Cr_Dr__c.  ' + keySuffix + '      tmp.ASI_MFM_Amount__c      ' + payAmt);
        
        cdMap.put('' + keyPrefix + keySuffix, delta);
        
        Return cdMap;
    }
    
    @TestVisible
    Private List<ASI_MFM_Tax_Saving_Line__c> queryTaxSavingLine(String typeOfTaxSaving){
        
        String whereClause = typeOfTaxSaving == 'Trade A&P Payment' ? 'ASI_MFM_Trade_A_P_Payment_Line__r.ASI_TH_CRM_Payment_Request__c = \'' + headerId + '\'' : 'ASI_MFM_Consumer_A_P_Payment_Line__r.ASI_MFM_Payment__c = \'' + headerId + '\'';
        
        String queryStr = 'SELECT id, Name, ASI_MFM_Account_Code_Combination__c, ASI_MFM_Amount__c'
            + ', ASI_MFM_ETL__c, ASI_MFM_G_L_Date__c, ASI_MFM_Invoice_Number__c, ASI_MFM_PO__c, ASI_MFM_Tax_PO_Number__c'
            + ', ASI_MFM_Tax_Saving_Control_Form_Line__c, ASI_MFM_Trade_A_P_Payment_Line__c, ASI_MFM_Consumer_A_P_Payment_Line__c, ASI_MFM_Tax_Saving_Control_Form_Line__r.ASI_MFM_Expense_Control_Form__r.Name'
            + ', ASI_MFM_Cr_Dr__c, ASI_CRM_Trade_Invoice_Number__c FROM ASI_MFM_Tax_Saving_Line__c WHERE ' + whereClause;
        
        Return database.query(queryStr);
    }
    
    @TestVisible
    Private String getSubbrandCode(Boolean paymentFirst, String expenseSubbrandCode, String paymentSubbrandCode){
        
        //get Sub Brand Code
        if(!paymentFirst){
            
            if(expenseSubbrandCode != Null && expenseSubbrandCode != ''){
                Return expenseSubbrandCode;
            }else if(paymentSubbrandCode != Null && paymentSubbrandCode != ''){
                Return paymentSubbrandCode;
            }
        }else{
            
            if(paymentSubbrandCode != Null && paymentSubbrandCode != ''){
                Return paymentSubbrandCode;
            }else if(expenseSubbrandCode != Null && expenseSubbrandCode != ''){
                Return expenseSubbrandCode;
            }
        }
        
        Return '';
    }
    
    @TestVisible
    Private String getACCode(String expenseACCode, String paymentACCode){
        
        if(expenseACCode != Null && expenseACCode != ''){
            
            Return expenseACCode; 
        }else if(paymentACCode != Null && paymentACCode != ''){
            
            Return paymentACCode;
        }
        
        Return '';
    }
    
    @TestVisible
    Private String queryStr(List<ASI_CRM_Expense_Control_Form_Line__c> tsl, Set<String> fieldSet, Map<String, Schema.SObjectField> schemaField, String whereClause, String targetObject, String additionalFields){
        
        //query payment line
        for(ASI_CRM_Expense_Control_Form_Line__c line : tsl){
            
            String formulaString = line.ASI_MFM_Tax_Saving_Formula__c + (line.ASI_MFM_Tax_Saving_Formula_2__c != Null && line.ASI_MFM_Tax_Saving_Formula_2__c != '' ? '@' + line.ASI_MFM_Tax_Saving_Formula_2__c : '');
            formulaString = formulaString.replaceAll( '\\s+', '');
            
            for(String str : formulaString.split('[\\p{Punct}&&[^_.]]')){
                
                if(!str.remove('.').isNumeric() && str != '' && str != Null){
                    fieldSet.add(str.toLowerCase());
                }
            }
        }
        
        String queryPaymentLineStr = 'SELECT ';
        
        for(String fieldStr : fieldSet){
            queryPaymentLineStr += fieldStr + ',';
        }
        
        for(String fieldStr : schemaField.keySet()){
            if(!fieldSet.contains(fieldStr.toLowerCase()))
                queryPaymentLineStr += fieldStr + ',';
        }
        
        queryPaymentLineStr += additionalFields;
        
        queryPaymentLineStr += ' FROM ' + targetObject + ' WHERE ' + whereClause + ' = \'' + headerId + '\'';
        
        Return queryPaymentLineStr;
    }
}