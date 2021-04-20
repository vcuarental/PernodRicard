global with sharing class ASI_MFM_CN_InputPOReceiptPhasingCtl {
    public ASI_MFM_PO__c PO {get; private set;}
    public Date poStartDate{get; private set;}
    public Date poEndDate{get; private set;}
    public Date currentDate{get; private set;}
    public String poStatus{get; private set;}
    public String poStartStr{get; private set;}
    public String poEndStr{get; private set;}
    public String modifyBy {get; private set;}
    public Decimal poPaidAmount {get; private set;}
    public Decimal poAmount {get; private set;}
    public Boolean editable {get; private set;}
    public Date fyStartDate {get; private set;}
    public Date fyEndDate {get; private set;}
    public Boolean prepaidPo {get; private set;}

	public String savedDatas   {get; set;}
    
	public String message {get;set;}
    
    public id pid {get; private set;}
    
	public ASI_MFM_CN_InputPOReceiptPhasingCtl(ApexPages.StandardController sc) {
        message = 'init message';
        pid = apexpages.currentPage().getParameters().get('id');
        PO = ASI_MFM_CN_InputPOReceiptPhasingUtility.getPoMap(new Set<id>{pid}).get(pid);
        fyStartDate = PO.ASI_MFM_FY_Start_Date__c;
        fyEndDate = PO.ASI_MFM_FY_End_Date__c;
        poStartDate = PO.ASI_MFM_PO_Start_Date__c;
        poEndDate = PO.ASI_MFM_PO_End_Date__c;
        poStartStr = PO.ASI_MFM_PO_Start_Date__c.format();
        poEndStr = PO.ASI_MFM_PO_End_Date__c.format();
        poAmount = PO.ASI_MFM_PO_Amount__c;
        poPaidAmount = PO.ASI_MFM_Total_Paid_Amount__c ;
        poStatus = PO.ASI_MFM_Status__c;
        prepaidPo = false;
        if(PO.ASI_MFM_Total_Paid_Amount__c>0 && (PO.ASI_MFM_Total_Receipt_Amount__c==null || PO.ASI_MFM_Total_Receipt_Amount__c==0)) {
            prepaidPo = true;
        }
        currentDate = date.today();
        modifyBy = UserInfo.getName();
        
        String supplierNum = PO.ASI_MFM_Supplier_Number__c;
        String poType = PO.ASI_MFM_PO_Type__c.toUpperCase();
        Boolean autoReciept = PO.ASI_MFM_BU_Code__r.ASI_MFM_Auto_Receipt__c;
        Boolean poTyepEditable = (poType!='EMARKET'
                                  && poType!='IT OPEX' 
                                  && poType!='IT CAPEX HARDWARE REGION' 
                                  && poType!='IT CAPEX HARDWARE HQ' 
                                  && poType!='IT CAPEX SOFTWARE' 
                                  && poType!='IT CAPEX RENOVATION');
        editable = (supplierNum!='61202305' && poTyepEditable && autoReciept && poStatus!='Submitted');
        getPhasingList();
        //submitedJson='';
    }
    
    private static List<ReceiptPhasing> requestPhasingObj(Id poid) {
        Map<Id, List<ASI_MFM_PO_Receipt_Phasing__c>> recieptPhasingMap = ASI_MFM_CN_InputPOReceiptPhasingUtility.getPoPhasingMap(new Set<Id>{poid});
        List<ASI_MFM_PO_Receipt_Phasing__c> recieptPhasingList = new List<ASI_MFM_PO_Receipt_Phasing__c>();
        if(recieptPhasingMap.containsKey(poid)){recieptPhasingList=recieptPhasingMap.get(poid);}
        List<ReceiptPhasing> phasingList = new List<ReceiptPhasing>();
        system.debug(JSON.serialize(recieptPhasingList));
        for(ASI_MFM_PO_Receipt_Phasing__c rp :recieptPhasingList){
            phasingList.add(new ReceiptPhasing(rp));
        }
        return phasingList;
    }
    
    public void getPhasingList() {
        List<ReceiptPhasing> phasingList = requestPhasingObj(pid);
        String jsonstring = JSON.serializepretty(phasingList);
        String jsonModified = jsonstring.replace('\r\n', '');
        jsonModified = jsonModified.replace('\n', '');
        jsonModified = jsonModified.replace('\r', '');
        savedDatas = jsonModified;
    }
    
    @RemoteAction
    global static ResultObj validate(String dataSet) {
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
        List<Object> dataList = (List<Object>)dataMap.get('submitedList');
        Id poid = (Id)dataMap.get('poid');
        ReceiptPhasing lastPhasing = null;
        ReceiptPhasing lastSystem = null;
        ReceiptPhasing lastApprovedUser = null;
        Boolean approved = false;
		for(Object dataObj : dataList) {
            String jsonData = JSON.serialize(dataObj);
            ReceiptPhasing phasingObj = (ReceiptPhasing)JSON.deserialize(jsonData, ReceiptPhasing.class);
            if(lastPhasing==null || lastPhasing.version<phasingObj.version) {
                lastPhasing = phasingObj;
            }
            if(phasingObj.modify=='SYSTEM' && (lastSystem==null || lastSystem.version<phasingObj.version)) {
                lastSystem = phasingObj;
            }
            if(phasingObj.modify!='SYSTEM' && phasingObj.approved && (lastApprovedUser==null || lastApprovedUser.version<phasingObj.version)) {
                lastApprovedUser = phasingObj;
            }
            if(phasingObj.approved) {
                approved = true;
            }
        }
		
        if(lastPhasing.modify=='SYSTEM') return new ResultObj(false, 'Please Insert New Receipt Phasing.', null);
        
        ASI_MFM_PO__c PO = ASI_MFM_CN_InputPOReceiptPhasingUtility.getPoMap(new Set<id>{poid}).get(poid);
        system.debug('ASI_MFM_PO_Amount__c ' + PO.ASI_MFM_PO_Amount__c + '  : ' + lastPhasing.countTotal());
        system.debug('PO.ASI_MFM_PO_Start_Date__c' +PO.ASI_MFM_PO_Start_Date__c.year() + '-' + PO.ASI_MFM_PO_Start_Date__c.month());
        system.debug('PO.ASI_MFM_PO_End_Date__c' +PO.ASI_MFM_PO_End_Date__c.year() + '-' + PO.ASI_MFM_PO_End_Date__c.month());
        
        //20180911 Introv
        if(PO.ASI_MFM_PO_Start_Date__c.year()==PO.ASI_MFM_PO_End_Date__c.year() && PO.ASI_MFM_PO_Start_Date__c.month()==PO.ASI_MFM_PO_End_Date__c.month()) { 
            if(PO.ASI_MFM_PO_Amount__c<lastPhasing.countTotal()) return new ResultObj(false, 'Total Receipt Phasing Amount cannot be greater than PO Amount.', null);//20180906 Introv
        } else {
            if(PO.ASI_MFM_PO_Amount__c!=lastPhasing.countTotal()) return new ResultObj(false, 'Total Receipt Phasing Amount must equal to PO Amount.', null);//20180911 Introv
        }
		//20180911 Introv
        
        String debug ='';
        Decimal paidAmount = PO.ASI_MFM_Total_Paid_Amount__c ;
        if(paidAmount>0 && lastApprovedUser!=null) {
            Date today = system.today();
            String currentAmountKey = 'amount'+today.month();
            Date runningDate = PO.ASI_MFM_PO_Start_Date__c.addMonths(1).toStartofMonth().addDays(-1);
            Date startDate   = PO.ASI_MFM_PO_Start_Date__c;
            Date endDate     = PO.ASI_MFM_PO_End_Date__c;
            while(runningDate<endDate) {
                if(runningDate<today) { paidAmount -= lastApprovedUser.getAmount('amount'+runningDate.month()); }
                runningDate = runningDate.addMonths(2).toStartofMonth().addDays(-1);
            }
            Decimal currentAmount = lastPhasing.getAmount(currentAmountKey); 
            SYSTEM.debug('currentAmount: ' + currentAmount );
            SYSTEM.debug('currentAmountKey: ' + currentAmountKey );
            SYSTEM.debug('lastPhasing: ' + JSON.serialize(lastPhasing) );
            if(currentAmount<paidAmount) return new ResultObj(false, 'Receipt Phasing amount cannot be smaller than paid amount: ' +paidAmount, null);   
        }



        //if(approved && !lastPhasing.checkEqual(lastSystem) && (lastPhasing.comment==null||lastPhasing.comment=='')) return new ResultObj(false, 'Please Input reason that Receipt Phasing is different from system suggested version.', null);
        if(approved && lastApprovedUser!=null &&!lastPhasing.checkEqual(lastApprovedUser) && (lastPhasing.comment==null||lastPhasing.comment=='')) return new ResultObj(false, 'Please Input reason that Receipt Phasing is different from last approved version.', null);
        
        List<ReceiptPhasing> updateResultList = updatePhasing(dataMap);

        return new ResultObj(true, 'succcess', updateResultList);

    }
    
    private static List<ReceiptPhasing> updatePhasing(Map<String,Object> dataMap) {
        Id phasingRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO_Receipt_Phasing__cASI_MFM_CN_PO_Receipt_Phasing');
        List<Object> dataList = (List<Object>)dataMap.get('submitedList');
        String deletedJsonStr = JSON.serialize(dataMap.get('deleteIdList'));
        Id poid = (Id)dataMap.get('poid');
        List<String> deleteIdList = (List<String>)JSON.deserialize(deletedJsonStr, List<String>.class);
        ASI_MFM_PO_Receipt_Phasing__c lastPhasing = null;
        List<ASI_MFM_PO_Receipt_Phasing__c> phasingList= new List<ASI_MFM_PO_Receipt_Phasing__c>();
		for(Object dataObj : dataList) {
            String jsonData = JSON.serialize(dataObj);
            ReceiptPhasing phasingObj = (ReceiptPhasing)JSON.deserialize(jsonData, ReceiptPhasing.class);
            
            ASI_MFM_PO_Receipt_Phasing__c phasing = new ASI_MFM_PO_Receipt_Phasing__c(
                ASI_MFM_Latest_Phasing__c = false,
                ASI_MFM_Version__c = phasingObj.version+'',
                ASI_MFM_Comments__c = phasingObj.comment+'',
                ASI_MFM_PO__c = phasingObj.poid,
                ASI_MFM_Modify_BY__c = phasingObj.modify,
                ASI_MFM_PO_Approved__c = phasingObj.approved,
                ASI_MFM_Allocated_Amount_1__c = phasingObj.amount1,
                ASI_MFM_Allocated_Amount_2__c = phasingObj.amount2,
                ASI_MFM_Allocated_Amount_3__c = phasingObj.amount3,
                ASI_MFM_Allocated_Amount_4__c = phasingObj.amount4,
                ASI_MFM_Allocated_Amount_5__c = phasingObj.amount5,
                ASI_MFM_Allocated_Amount_6__c = phasingObj.amount6,
                ASI_MFM_Allocated_Amount_7__c = phasingObj.amount7,
                ASI_MFM_Allocated_Amount_8__c = phasingObj.amount8,
                ASI_MFM_Allocated_Amount_9__c = phasingObj.amount9,
                ASI_MFM_Allocated_Amount_10__c = phasingObj.amount10,
                ASI_MFM_Allocated_Amount_11__c = phasingObj.amount11,
                ASI_MFM_Allocated_Amount_12__c = phasingObj.amount12,
                RecordTypeId = phasingRTID
            );
            phasing.ASI_MFM_PO_Start_Date__c = Date.parse(phasingObj.postart);
            phasing.ASI_MFM_PO_End_Date__c = Date.parse(phasingObj.poend);
            
            if(phasingObj.id!=null && phasingObj.id!='') {
                phasing.id=phasingObj.id;
            } else {
                phasing.ASI_MFM_Create_Date__c = System.now();
            }
            if(lastPhasing==null || integer.valueof(lastPhasing.ASI_MFM_Version__c) < integer.valueof(phasing.ASI_MFM_Version__c)) {
                lastPhasing = phasing;
            }
            phasingList.add(phasing);
        }

        if(lastPhasing!=null) lastPhasing.ASI_MFM_Latest_Phasing__c = true;
        if(phasingList.size()>0) {
            upsert phasingList;
        }

        if(deleteIdList.size()>0) {
        	List<ASI_MFM_PO_Receipt_Phasing__c> deletePhasingList = [SELECT id FROM ASI_MFM_PO_Receipt_Phasing__c WHERE id IN :deleteIdList];
            delete deletePhasingList;
        }

        Id poRTID = Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO');
        ASI_MFM_PO__c PO = ASI_MFM_CN_InputPOReceiptPhasingUtility.getPoMap(new Set<id>{poid}).get(poid);
        if(PO.ASI_MFM_Status__c!='Draft' && !phasingList.get(phasingList.size()-1).ASI_MFM_PO_Approved__c) {
            PO.ASI_MFM_Status__c = 'Draft';
            PO.RecordTypeId = poRTID;
            update PO;
        }
        
        return requestPhasingObj(poid);
    }
    
/*
    public PageReference updatePhasingList(){
		Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(submitedJson);
        updatePhasing(dataMap);
        return null;
    }
*/
    
    global class ResultObj {
    	public String message;
        public Boolean success;
        public List<ReceiptPhasing> phasingList;
        public ResultObj(Boolean b, String m, List<ReceiptPhasing> pl){
            message = m;
            success = b;
            phasingList = pl;
        }
    }
    
    global class ReceiptPhasing {
        public String id;
        public String poid;
		public String rowcontrol;
		public Integer version;
		public String modify;
		public String postart;
		public String poend;
        public String create;
		public String comment;
        public Boolean approved;
      	public Decimal total;
		public Decimal amount1;
		public Decimal amount2;
		public Decimal amount3;
		public Decimal amount4;
		public Decimal amount5;
		public Decimal amount6;
		public Decimal amount7;
		public Decimal amount8;
		public Decimal amount9;
		public Decimal amount10;
		public Decimal amount11;
		public Decimal amount12;

        public ReceiptPhasing(ASI_MFM_PO_Receipt_Phasing__c data){
            if(data.id!=null){id = data.id;} 
            if(data.ASI_MFM_PO__c!=null){poid = data.ASI_MFM_PO__c;} 
            rowcontrol = '0';
            version = Integer.valueOf(data.ASI_MFM_Version__c);
            modify  = data.ASI_MFM_Modify_BY__c;
            postart = data.ASI_MFM_PO_Start_Date__c.format();
            poend   = data.ASI_MFM_PO_End_Date__c.format();
            create  = data.ASI_MFM_Create_Date__c.format();
            total   = data.ASI_MFM_Amount_Total__c;
            comment = data.ASI_MFM_Comments__c;
            approved= data.ASI_MFM_PO_Approved__c;
            amount1 = data.ASI_MFM_Allocated_Amount_1__c;
            amount2 = data.ASI_MFM_Allocated_Amount_2__c;
            amount3 = data.ASI_MFM_Allocated_Amount_3__c;
            amount4 = data.ASI_MFM_Allocated_Amount_4__c;
            amount5 = data.ASI_MFM_Allocated_Amount_5__c;
            amount6 = data.ASI_MFM_Allocated_Amount_6__c;
            amount7 = data.ASI_MFM_Allocated_Amount_7__c;
            amount8 = data.ASI_MFM_Allocated_Amount_8__c;
            amount9 = data.ASI_MFM_Allocated_Amount_9__c;
            amount10 = data.ASI_MFM_Allocated_Amount_10__c;
            amount11 = data.ASI_MFM_Allocated_Amount_11__c;
            amount12 = data.ASI_MFM_Allocated_Amount_12__c;
            if(comment==null) comment='';
        }
        
        public Decimal getAmount(String key) {
            if(key=='amount1') { return this.amount1; } 
            else if(key=='amount2') {return this.amount2; }
            else if(key=='amount3') {return this.amount3; }
            else if(key=='amount4') {return this.amount4; }
            else if(key=='amount5') {return this.amount5; }
            else if(key=='amount6') {return this.amount6; }
            else if(key=='amount7') {return this.amount7; }
            else if(key=='amount8') {return this.amount8; }
            else if(key=='amount9') {return this.amount9; }
            else if(key=='amount10') {return this.amount10; }
            else if(key=='amount11') {return this.amount11; }
            else if(key=='amount12') {return this.amount12; }
            return 0;
        }
        
        public Decimal countTotal() {
            return amount1+amount2+amount3+amount4+amount5+amount6+amount7+amount8+amount9+amount10+amount11+amount12;
        }
        
        public Boolean checkEqual(ReceiptPhasing phase) {
            if(phase==null) return false;
            return (this.amount1==phase.amount1 && this.amount2==phase.amount2 && this.amount3==phase.amount3
                   && this.amount4==phase.amount4 && this.amount5==phase.amount5 && this.amount6==phase.amount6
                   && this.amount7==phase.amount7 && this.amount8==phase.amount8 && this.amount9==phase.amount9 
                   && this.amount10==phase.amount10 && this.amount11==phase.amount11 && this.amount12==phase.amount12);
        }
	}

}