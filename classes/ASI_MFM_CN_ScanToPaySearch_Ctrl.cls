public class ASI_MFM_CN_ScanToPaySearch_Ctrl {
    Private Static Final String CNPO_RTID = Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO');
    Private Static Final String CNPO_RTID_RO = Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');    
    Private Static Final String CNPOL_RTID = Global_recordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item');
    Private Static Final String CNSUBBRAND_RTID = Global_recordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
    Private Static Final String CNFIXAPPROVALROUTE_RTID = Global_recordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route');
    Private Static Final String CNFIXAPPROVALROUTE_TYPE = 'PO ScanToPay';
    
    public ASI_MFM_Buyer_Master__c filterOwner {get;set;}
    public ASI_MFM_PO__c filterPo {get;set;}
    public ASI_MFM_PO_Line_Item__c  filterPoLineItem {get;set;}
    public ASI_MFM_PO_Line_Item__c  filterPoLineItem2 {get;set;}
    public ASI_MFM_PO_Line_Item__c  filterPoLineItem3 {get;set;}
    public ASI_MFM_PO_Line_Item__c  filterPoLineItem4 {get;set;}
    public ASI_MFM_Sub_brand__c filterSubBrand {get;set;}
    public ASI_MFM_Prefix__c filterPrefix {get;set;}
    
    public ASI_MFM_CN_ScanToPaySearch_Ctrl() {
        this.filterPo = new ASI_MFM_PO__c ();
        this.filterPoLineItem = new ASI_MFM_PO_Line_Item__c();
        this.filterPoLineItem2 = new ASI_MFM_PO_Line_Item__c();
        this.filterPoLineItem3 = new ASI_MFM_PO_Line_Item__c();
        this.filterPoLineItem4 = new ASI_MFM_PO_Line_Item__c();
        this.filterSubBrand = new ASI_MFM_Sub_brand__c ();
        this.filterPrefix = new ASI_MFM_Prefix__c();
        this.filterOwner = new ASI_MFM_Buyer_Master__c();
        
        //this.filterPo.OwnerId = UserInfo.getUserId();
        this.filterPrefix.ASI_MFM_Fiscal_year__c = getFYString(Date.today());
        this.filterPoLineItem3.ASI_MFM_List_Item_Description__c  = '500000';
        this.filterPo.ASI_MFM_CN_BU_Picklist__c = 'PRCN';

        List<ASI_CRM_Fix_Approval_Route__c> ll_fix_route = [
            SELECT Id
            , ASI_CRM_Supplier__r.ASI_MFM_Customer_Supplier_Number__c
            , ASI_CRM_MY_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c
            , ASI_CRM_CN_Region_Area_Channel__c 
            FROM ASI_CRM_Fix_Approval_Route__c
            WHERE RecordTypeId = :CNFIXAPPROVALROUTE_RTID
            AND ASI_CRM_CN_Type__c = :CNFIXAPPROVALROUTE_TYPE
            AND ASI_CRM_CN_Alternative_Approver__c =: UserInfo.getUserId()
        ];

        Set<String> setDefaultSupplierCodes = new Set<String>();
        Set<String> setDefaultSubBrandCodes = new Set<String>();
        List<String> listDefaultPOType = new List<String>();
        Set<String> setDefaultPOType = new Set<String>();
        String defaultSupplierCodes = '';
        String defaultSubBrandCodes = '';
        String defaultPOType = '';

        for(ASI_CRM_Fix_Approval_Route__c far : ll_fix_route){
            if(far.ASI_CRM_Supplier__r.ASI_MFM_Customer_Supplier_Number__c != null 
                && far.ASI_CRM_Supplier__r.ASI_MFM_Customer_Supplier_Number__c != ''){
                    setDefaultSupplierCodes.add(far.ASI_CRM_Supplier__r.ASI_MFM_Customer_Supplier_Number__c);
            }
            if(far.ASI_CRM_MY_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c != null 
                && far.ASI_CRM_MY_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c != ''){
                    setDefaultSubBrandCodes.add(far.ASI_CRM_MY_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c);
            }
            List<String> temp_POType = (far.ASI_CRM_CN_Region_Area_Channel__c == null? '' : far.ASI_CRM_CN_Region_Area_Channel__c).split(',');
            listDefaultPOType.addAll(temp_POType);
        }

        for(String s: setDefaultSupplierCodes){
            defaultSupplierCodes += (defaultSupplierCodes==''?'':', ')+s;
        }
        for(String s: setDefaultSubBrandCodes){
            defaultSubBrandCodes += (defaultSubBrandCodes==''?'':', ')+s;
        }
        
        for(String s : listDefaultPOType){
            setDefaultPOType.add(s.trim());
        }
        
        for(String s : setDefaultPOType){
            defaultPOType += (defaultPOType==''?'':', ')+s;
        }

        //default frontend.suppliercodes
        this.filterPoLineItem2.ASI_MFM_List_Item_Description__c = defaultSupplierCodes;
        //default frontend.subbrandcodes
        this.filterPoLineItem.ASI_MFM_List_Item_Description__c = defaultSubBrandCodes;
        //default frontend.poType
        this.filterPoLineItem4.ASI_MFM_List_Item_Description__c = defaultPOType;
    }
    
    @RemoteAction
    public static List<POSearchResultWrapper> search(integer iStart, integer iEnd, integer iLimit, String str){
        Map<String, Object> myMap = (Map<String, Object>)JSON.deserializeUntyped(str);
        Object criteriaList = (Object)myMap.get('criteriaArray');
        String jsonData = JSON.serialize(criteriaList);
        Map<String, String> inCriteria = (Map<String, String>)JSON.deserialize(jsonData, Map<String, String>.class);
        //Debug START
        system.debug('str value from js: '+ str);
        system.debug('str value from js converted to map: '+ myMap);
        system.debug('criteriaList: ' + criteriaList);
        system.debug('inCriteria: ' + inCriteria);
        for(String strValue : inCriteria.values()){
            system.debug('values(): ' + strValue);
        }
        for(String strKey : inCriteria.keySet()){
            system.debug('keyset(): ' + strKey);
        }
        //Debug END

        // PONum_inVal
        // Plan_inVal
        // OriAmt_inVal
        // BudgetOwner_inVal
        // Supplier_inVal
        // SupplierCodes_inVal
        // Owner_inVal
        // SubBrand_inVal
        // SubBrandCodes_inVal
        // POChannel_inVal
        // Brand_inVal
        // FY_inVal
        // POType_inVal
        // EmailSent_inVal
        // BU_inVal
        List<String> filterCondition = new List<String>();
        //MT@202004: Retrieve if qualified po lines by filtering brand and sub-brand
        String queryfilterPOLine = 'SELECT ASI_MFM_PO__c, ASI_MFM_Sub_Brand_Code_Only__c, Id';
        queryfilterPOLine += ' FROM ASI_MFM_PO_Line_Item__c';
        queryfilterPOLine += ' WHERE (ASI_MFM_PO__r.recordTypeId = :CNPO_RTID OR ASI_MFM_PO__r.recordTypeId = :CNPO_RTID_RO)';

        //poline.sub-brand
        //poline.sub-brand - 1
        String subBrandCriteria1 = '';
        String subBrandCriteria2 = '';
        String subBrandId = '';
        String subBrandCodes = '';
        if(inCriteria.containsKey('SubBrand_inVal') && inCriteria.get('SubBrand_inVal') != null && inCriteria.get('SubBrand_inVal') != '' && inCriteria.get('SubBrand_inVal') != '000000000000000' ){
            subBrandId = inCriteria.get('SubBrand_inVal');
            subBrandCriteria1 = 'ASI_MFM_Sub_brand_Code__c = :subBrandId';
        }
        //poline.sub-brand - 2
        if(inCriteria.containsKey('SubBrandCodes_inVal') && inCriteria.get('SubBrandCodes_inVal') != null && inCriteria.get('SubBrandCodes_inVal') != '' ){
            subBrandCodes = inCriteria.get('SubBrandCodes_inVal').replace(' ', '').replace(',', '\',\'');
            subBrandCriteria2 = 'ASI_MFM_Sub_Brand_Code_Only__c IN (\'' + subBrandCodes + '\')';
        }

        //Debug START
        system.debug('subBrandId: ' + subBrandId);
        system.debug('subBrandCodes: ' + subBrandCodes);
        //Debug END


        if(subBrandId != '' && subBrandCodes != ''){
            queryfilterPOLine += ' AND (' + subBrandCriteria1 + ' OR ' + subBrandCriteria2 + ')';
        }else if(subBrandId != '' || subBrandCodes != ''){
            queryfilterPOLine = queryfilterPOLine + ' AND ' + (subBrandId != '' ? subBrandCriteria1 : subBrandCriteria2);
        }

        //poline.brand
        if(inCriteria.containsKey('Brand_inVal') && inCriteria.get('Brand_inVal') != null && inCriteria.get('Brand_inVal') != '' && inCriteria.get('Brand_inVal') != '000000000000000'){
            String brandId = inCriteria.get('Brand_inVal');
            queryfilterPOLine += ' AND ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c = :brandId';
        }
        //po.name
        if(inCriteria.containsKey('PONum_inVal') && inCriteria.get('PONum_inVal') != null && inCriteria.get('PONum_inVal') != '' ){
            queryfilterPOLine += ' AND ASI_MFM_PO__r.Name LIKE \'%' + inCriteria.get('PONum_inVal') + '%\' ';
        }

        //po.plan
        if(inCriteria.containsKey('Plan_inVal') && inCriteria.get('Plan_inVal') != null && inCriteria.get('Plan_inVal') != '' && inCriteria.get('Plan_inVal') != '000000000000000'){
            Id planId = inCriteria.get('Plan_inVal');
            queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_Plan__c = :planId';
        }
        //po.amount
        if(inCriteria.containsKey('OriAmt_inVal') && inCriteria.get('OriAmt_inVal') != null && inCriteria.get('OriAmt_inVal') != '' ){
            Double amount = decimal.valueOf(inCriteria.get('OriAmt_inVal'));
            queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_PO_Original_Amount__c > :amount';
        }

        //po.budgetOwner
        if(inCriteria.containsKey('BudgetOwner_inVal') && inCriteria.get('BudgetOwner_inVal') != null && inCriteria.get('BudgetOwner_inVal') != '' && inCriteria.get('BudgetOwner_inVal') != '000000000000000'){
            Id budgetOwnerId = inCriteria.get('BudgetOwner_inVal');
            queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_Budget_Owner__c = :budgetOwnerId ';
        }
        //po.supplier
        //po.supplier - 1
        String supplierCriteria1 = '';
        String supplierCriteria2 = '';
        String supplierId = '';
        String supplierCodes = '';
        if(inCriteria.containsKey('Supplier_inVal') && inCriteria.get('Supplier_inVal') != null && inCriteria.get('Supplier_inVal') != '' && inCriteria.get('Supplier_inVal') != '000000000000000'){
            supplierId = inCriteria.get('Supplier_inVal');
            //queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c = :supplierId ';
            supplierCriteria1 = 'ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c = :supplierId';
        }
        //po.supplier - 2
        if(inCriteria.containsKey('SupplierCodes_inVal') && inCriteria.get('SupplierCodes_inVal') != null && inCriteria.get('SupplierCodes_inVal') != ''){
            supplierCodes = inCriteria.get('SupplierCodes_inVal').replace(' ', '').replace(',', '\',\'');
            supplierCriteria2 = 'ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c IN (\'' + supplierCodes + '\')';
            //queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c = :supplierId ';
        }
        //Debug START
        system.debug('supplierId: ' + supplierId);
        system.debug('supplierCodes: ' + supplierCodes);
        //Debug END


        if(supplierId != '' && supplierCodes != ''){
            queryfilterPOLine += ' AND (' + supplierCriteria1 + ' OR ' + supplierCriteria2 + ')';
        }else if(supplierId != '' || supplierCodes != ''){
            queryfilterPOLine = queryfilterPOLine + ' AND ' + (supplierId != '' ? supplierCriteria1 : supplierCriteria2);
        }
        queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_Supplier_Number__c != \'61202305\' ';

        //po.owner
        if(inCriteria.containsKey('Owner_inVal') && inCriteria.get('Owner_inVal') != null && inCriteria.get('Owner_inVal') != '' && inCriteria.get('Owner_inVal') != '000000000000000'){
            String ownerId = inCriteria.get('Owner_inVal');
            queryfilterPOLine += ' AND ASI_MFM_PO__r.OwnerId = :ownerId ';
        }
        //po.channel
        if(inCriteria.containsKey('POChannel_inVal') && inCriteria.get('POChannel_inVal') != null && inCriteria.get('POChannel_inVal') != '' ){
            String poChannel = inCriteria.get('POChannel_inVal');
            queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_PO_Channel__c = :poChannel ';
        }
        //po.fiscalYear
        if(inCriteria.containsKey('FY_inVal') && inCriteria.get('FY_inVal') != null && inCriteria.get('FY_inVal') != '' ){
            String fiscalYear = inCriteria.get('FY_inVal');
            queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c = :fiscalYear';
        }
        //po.poType
        if(inCriteria.containsKey('POType_inVal') && inCriteria.get('POType_inVal') != null && inCriteria.get('POType_inVal') != '' ){
            List<String> listPOType = inCriteria.get('POType_inVal').split(',');
            Set<String> setPOType = new Set<String>();
            for(String s : listPOType){
                setPOType.add(s.trim());
            }
            queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_PO_Type__c IN :setPOType';
        }
        //po.BU
        if(inCriteria.containsKey('BU_inVal') && inCriteria.get('BU_inVal') != null && inCriteria.get('BU_inVal') != '' ){
            String bu = inCriteria.get('BU_inVal');
            queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_CN_BU_Picklist__c = :bu ';
        }
        if(inCriteria.containsKey('EmailSent_inVal') && inCriteria.get('EmailSent_inVal') != null && inCriteria.get('EmailSent_inVal') != '' ){
            Boolean sent = inCriteria.get('EmailSent_inVal') == 'true'? true: false;
            queryfilterPOLine += ' AND ASI_MFM_PO__r.ASI_MFM_Supplier_eMail_Sent__c = :sent ';
        }

        List<ASI_MFM_PO_Line_Item__c> ll_pol = new List<ASI_MFM_PO_Line_Item__c>();
        system.debug('queryfilterPOLine: ' + queryfilterPOLine);
        ll_pol= Database.query(queryfilterPOLine);

        //Debug START
        for(ASI_MFM_PO_Line_Item__c poline : ll_pol){
            system.debug('ll_pol');
            system.debug('poline.Id: ' + poline.Id);
            system.debug('poline.ASI_MFM_Sub_Brand_Code_Only__c: ' + poline.ASI_MFM_Sub_Brand_Code_Only__c);
        }
        //Debug END
        
        //MT@202004: do a query to PO to prevent missing retrival of the PO without any po lines inappropriate assupmtion
        List<ASI_MFM_PO__c> ll_po = new List<ASI_MFM_PO__c>();
        String queryfilterPO = '';
        Set<Id> set_filterPO = new Set<Id>();
        for(ASI_MFM_PO_Line_Item__c poline : ll_pol){
            set_filterPO.add(poline.ASI_MFM_PO__c);
        }

        queryfilterPO += 'SELECT Id';
        queryfilterPO += ', Name';
        queryfilterPO += ', Owner.Name';
        queryfilterPO += ', ASI_MFM_Supplier_Name__c';
        queryfilterPO += ', ASI_MFM_Supplier_Name__r.Name';
        queryfilterPO += ', ASI_MFM_CN_BU_Picklist__c';
        queryfilterPO += ', ASI_MFM_PO_Type__c';
        queryfilterPO += ', ASI_MFM_PO_Original_Amount__c';
        queryfilterPO += ', ASI_MFM_Remarks__c';
        queryfilterPO += ', ASI_MFM_Email_CheckBox__c';
        queryfilterPO += ', ASI_MFM_Supplier_eMail_Sent__c';
        queryfilterPO += ', ASI_MFM_Supplier_Email__c';
        queryfilterPO += ' FROM ASI_MFM_PO__c';
        queryfilterPO += ' WHERE (RecordTypeId = :CNPO_RTID OR RecordTypeId = :CNPO_RTID_RO)';
        queryfilterPO += ' AND Id IN :set_filterPO';
        queryfilterPO += ' ORDER BY Name';
        queryfilterPO += ' LIMIT :iLimit OFFSET :iStart ';
        ll_po = Database.query(queryfilterPO);
        //Debug START
        system.debug('queryfilterPO: ' + queryfilterPO);
        for(ASI_MFM_PO__c po : ll_po){
            system.debug('po.Id: ' + po.Id);
            system.debug('po.Name: ' + po.Name);
        }
        //Debug END

        //MT@202004: do a query to POLines again to make sure all the lines related to final result of PO are not missed
        List<ASI_MFM_PO_Line_Item__c> ll_pol_2 = new List<ASI_MFM_PO_Line_Item__c>();
        String queryRelatedPOLines = '';
        Set<Id> set_resultPO = new Set<Id>();
        for(ASI_MFM_PO__c po : ll_po){
            set_resultPO.add(po.Id);
        }
        queryRelatedPOLines += 'SELECT Id';
        queryRelatedPOLines += ', ASI_MFM_Sub_brand_Code__r.Name';
        queryRelatedPOLines += ', ASI_MFM_PO__c';
        queryRelatedPOLines += ', ASI_MFM_PO__r.Name';
        queryRelatedPOLines += ', ASI_MFM_Sub_Brand_Name__c';
        queryRelatedPOLines += ', ASI_MFM_Sub_Brand_Code_Only__c';
        queryRelatedPOLines += ' FROM ASI_MFM_PO_Line_Item__c';
        queryRelatedPOLines += ' WHERE ASI_MFM_PO__c IN :set_resultPO';
        ll_pol_2 = Database.query(queryRelatedPOLines);

        //Debug START
        system.debug('queryRelatedPOLines: ' + queryRelatedPOLines);
        for(ASI_MFM_PO_Line_Item__c poline : ll_pol_2){
            system.debug('ll_pol_2');
            system.debug('poline.Id: ' + poline.Id);
            system.debug('poline.ASI_MFM_Sub_Brand_Code_Only__c: ' + poline.ASI_MFM_Sub_Brand_Code_Only__c);
        }
        //Debug END

        //Group the result
        Map<Id, List<ASI_MFM_PO_Line_Item__c>> map_POLines = new Map<Id, List<ASI_MFM_PO_Line_Item__c>>();
        for(ASI_MFM_PO_Line_Item__c poline : ll_pol_2){
            if(map_POLines.containsKey(poline.ASI_MFM_PO__c)){
                map_POLines.get(poline.ASI_MFM_PO__c).add(poline);
            }
            else{
                List<ASI_MFM_PO_Line_Item__c> tmp_list = new List<ASI_MFM_PO_Line_Item__c>();
                tmp_list.add(poline);
                map_POLines.put(poline.ASI_MFM_PO__c, tmp_list);
            }
        }
        
        //Prepare the result
        List<POSearchResultWrapper> ll_POList = new List<POSearchResultWrapper>();
        for(ASI_MFM_PO__c po : ll_po){
            ll_POList.add(new POSearchResultWrapper(po, map_POLines.containsKey(po.Id) ? map_POLines.get(po.Id) : null));
        }
        //Debug START
        for(POSearchResultWrapper wrapItem : ll_POList){
            //system.debug('wrapItem.po: ' + wrapItem.po);
            system.debug('wrapItem.po_sub_brand: ' + wrapItem.po_sub_brand);
            system.debug('wrapItem.id: ' + wrapItem.id);
        }
        system.debug('ll_POList.size: ' + ll_POList.size());
        //Debug END
        

        return ll_POList;
    }
    private String getFYString(Date startDate){
        String output = 'FY';
        Integer year = Integer.valueOf(String.valueOf(startDate.year()).right(2));
        Integer month = startDate.month();
        if(month >= 7){
            output += year;
            output += (year + 1);
        }
        else{
            output += (year - 1);
            output += year;
        }
        return output;
    }
    @RemoteAction
    public static SaveResult sendEmail(List<Id> l_id){
        SaveResult sr = new SaveResult();
        sr.success = false;
        
        Map<Id, ASI_MFM_PO__c> map_update_po = new Map<Id, ASI_MFM_PO__c>([
            SELECT Id
            , Name
            , ASI_MFM_Email_CheckBox__c
            FROM ASI_MFM_PO__c
            WHERE Id IN :l_id
        ]);
        List<ASI_MFM_PO__c> list_update_po = new List<ASI_MFM_PO__c>();
        for(Id poId : l_id){
                list_update_po.add(new ASI_MFM_PO__c(
                    id = poId
                    , ASI_MFM_Email_CheckBox__c = true
                ));
        }
        try{
            update list_update_po;
            sr.success = true;
        }catch (DmlException dmle) {
            Set<String> errMsgs = new Set<String>();
            Integer size = dmle.getNumDml();
            for (Integer i = 0; i < size; i++) {
                String msg = 'PO ' + map_update_po.get(dmle.getDmlId(i)).Name + ': ' + dmle.getDmlMessage(i);
                errMsgs.add(msg);
            }
            sr.messages.addAll(errMsgs);
        }catch(Exception e){
            sr.messages.add(e.getMessage());
        }

        return sr;
    }


    public class POSearchResultWrapper{
        public POSearchResultWrapper(){}
        public POSearchResultWrapper (ASI_MFM_PO__c po, List<ASI_MFM_PO_Line_Item__c> l_poli){
            String s_sub_brand = '';
            Set<String> s_sub_brand_code = new Set<String>();
            if(l_poli != null){
                for(ASI_MFM_PO_Line_Item__c obj : l_poli){
                    system.debug('PO ' + obj.ASI_MFM_PO__r.Name);                    
                    system.debug(obj.ASI_MFM_Sub_Brand_Code_Only__c);
                    if(obj.ASI_MFM_Sub_Brand_Code_Only__c != null && obj.ASI_MFM_Sub_Brand_Code_Only__c != ''){
                        //s_sub_brand += obj.ASI_MFM_Sub_Brand_Code_Only__c + '; ';
                        s_sub_brand_code.add(obj.ASI_MFM_Sub_Brand_Code_Only__c);
                    }
                }
            }
            for(String s : s_sub_brand_code){
                if(s_sub_brand == ''){
                    s_sub_brand = s;
                }
                else{
                    s_sub_brand += (', ' + s);   
                }
            }
            this.po = po;
            this.po_sub_brand = s_sub_brand;
            this.checked = false;
            this.id = po.Id;
            
            this.po_num = po.Name;
            this.po_sup_name = po.ASI_MFM_Supplier_Name__r.Name;
            this.supplierId = po.ASI_MFM_Supplier_Name__c;
            this.po_type = po.ASI_MFM_PO_Type__c;
            this.po_tot_amt = po.ASI_MFM_PO_Original_Amount__c;
            this.po_remark = po.ASI_MFM_Remarks__c;
            this.po_mail_sent = po.ASI_MFM_Supplier_eMail_Sent__c;
            this.po_bu = po.ASI_MFM_CN_BU_Picklist__c;
            this.supplierEmail = po.ASI_MFM_Supplier_Email__c;
        }
        
        public ASI_MFM_PO__c po {get;set;}
        public String po_sub_brand {get;set;}
        public Boolean checked {get;set;}
        public String id {get;set;}
        
        public String po_num {get;set;}
        public String po_sup_name {get;set;}
        public String po_bu {get;set;}
        public String po_type {get;set;}
        public Decimal po_tot_amt {get;set;}
        public String po_remark {get;set;}
        public Boolean po_mail_sent {get;set;}
        public String supplierId{get;set;}
        public String supplierEmail{get;set;}
    }

    public class SaveResult {
        public Boolean success { get; set; }
        public List<String> messages { get; set; }
        
        public SaveResult() {
            this.messages = new List<String>();
        }
    }
}