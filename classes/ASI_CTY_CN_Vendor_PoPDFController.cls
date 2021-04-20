/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_PoPDFController       
 * Test Class:  ASI_CTY_CN_Vendor_PoPDFCtlTest
 * Description: PO PDF Controller In Vendor Community
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-11-12       BLS-HUJINCHAO           Create Class
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_PoPDFController {
	public Id po_id {get;set;}
	public Id POID {get;set;}
    public Integer poLineSize {get;set;}
    public Boolean isPDF {get;set;}
    public String content {get;set;}
    public String domain {get;set;}
    public Date orderDate {get;set;}
    public String poRemarkSubString {get;set;}
    public String accCode {get;set;}
    public Decimal deliveryAmount {get;set;}
    public Decimal totalAmount {get;set;}
    public Map<String,String> posmItemPhotoMap {get;set;}
    public List<ASI_MFM_PO_POSM_Line__c> posmLineList {get;set;}
    public List<ASI_MFM_PO_Line_Item__c> poLineList {get;set;}
    public ASI_MFM_PO__c po {get;set;}
    public Map<Id, ASI_MFM_PO_POSM_Line__c> posmLineMap {get;set;}
    public Map<Id, List<ASI_MFM_Item_Group_Line__c>> bundleItemLineMap {get;set;}
    public Map<Id, PosmLineObj> summaryMap {get;Set;}
    public Set<String> itemGroupSet {get;set;}
    public String itemGroupName {get;set;}
    public String itemGroupCode {get;set;}

	// a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }

    public ASI_CTY_CN_Vendor_PoPDFController() {}

    public void initDate() {
        po_id = ApexPages.currentPage().getParameters().get('po_id');
        isPDF = Boolean.valueOf(ApexPages.currentPage().getParameters().get('is_pdf'));
        POID = po_id;
        System.debug(LoggingLevel.INFO, '*** po_id: ' + po_id);
        System.debug(LoggingLevel.INFO, '*** isPDF: ' + isPDF);
    }

    public boolean init() {
        posmLineList = [SELECT Id,name,ASI_MFM_Item_Group_Code__c,ASI_MFM_Unit_Price__c,ASI_MFM_Quantity__c,
                        ASI_MFM_Total_Price__c,ASI_MFM_Total_Price_w_VAT__c,ASI_MFM_Bundle_Item_Group__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Name, 
                        ASI_MFM_PO__r.ASI_MFM_Currency__c,
                        ASI_MFM_PO__r.ASI_MFM_Payment_Term__c,
                        ASI_MFM_PO__r.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.Name,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_1__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_2__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_3__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_4__c,
                        ASI_MFM_PO__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c,
                        ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Phone,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_LUX_Email_Business__c,
                        ASI_MFM_PO__r.Owner.name, ASI_MFM_PO__r.ASI_MFM_eMarket_Buyer__r.name,
                        ASI_MFM_PO__r.ASI_MFM_Remarks__c,ASI_MFM_PO__r.Name,
                        ASI_MFM_PO__r.ASI_MFM_CN_PO_Amount_RMB__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,
                        ASI_MFM_Item_Group__c,ASI_MFM_Item_Group__r.ASI_CRM_Brand__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Inspection__c,ASI_MFM_Item_Group__r.ASI_MFM_Unit__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Safety_Instruction__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Period_of_Validity__c,
                        ASI_MFM_Contact_Person__c,ASI_MFM_Phone_Number__c,ASI_MFM_City__c,
                        ASI_MFM_Item_Group__r.ASI_CRM_CN_Eng_Name__c,
                        ASI_MFM_Item_Group__r.ASI_CRM_CN_Chinese_Name__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Campaign_Name__c,
                        ASI_MFM_Item_Group__r.ASI_CRM_CN_Pack_Value__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Importation__c,
                        ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_1__c, ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_1__r.name,
                        ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_2__c, ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_2__r.name,
                        ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_3__c, ASI_MFM_Item_Group__r.ASI_MFM_Category_Level_3__r.name,
                        ASI_MFM_Delivery_Address_Warehouse__c, ASI_MFM_Delivery_Address_Warehouse__r.name,
                        ASI_MFM_Delivery_Address_Outlet__c, ASI_MFM_Delivery_Address_Outlet__r.name,
                        ASI_MFM_Detail_Address__c, ASI_MFM_PO__r.CreatedDate
                        FROM ASI_MFM_PO_POSM_Line__c 
                        WHERE ASI_MFM_PO__c=:POID];
        System.debug(LoggingLevel.INFO, '*** posmLineList: ' + posmLineList);

        po = [SELECT Id, Name, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Currency__c,
                        ASI_MFM_Payment_Term__c, ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.Name,
                        ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_1__c,
                        ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_2__c,
                        ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_3__c,
                        ASI_MFM_Supplier_Name__r.ASI_MFM_Address_Line_4__c,
                        ASI_MFM_PO_Amount__c,
                        ASI_MFM_Remarks__c,
                        ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c,
                        ASI_MFM_Supplier_Name__r.Phone,ASI_MFM_Supplier_Name__r.ASI_LUX_Email_Business__c,
                        Owner.Name, ASI_MFM_eMarket_Buyer__r.Name,CreatedDate
                        FROM ASI_MFM_PO__c 
                        WHERE Id =:POID];
        System.debug(LoggingLevel.INFO, '*** po: ' + po);

        poLineList = [SELECT Id, Name, ASI_MFM_A_C_Code__c, ASI_MFM_Item_Group_Code__c,
                        ASI_MFM_Quantity__c, ASI_MFM_Unit_Price__c, ASI_MFM_Amount__c,
                        ASI_MFM_List_Item_Description__c, ASI_CTY_CN_Vendor_Sample_Fee__c,
                        ASI_MFM_Delivery_Fee__c, ASI_MFM_A_C_Code__r.Name
                        FROM ASI_MFM_PO_Line_Item__c 
                        WHERE ASI_MFM_PO__c =:POID AND RecordTypeId = :ASI_CTY_CN_Vendor_Util.poLineItemRecordId];
        System.debug(LoggingLevel.INFO, '*** poLineList: ' + poLineList);
        if (poLineList != null && poLineList.size() > 0) {
            poLineSize = poLineList.size();
        } else {
            poLineSize = 0;
        }
        
        itemGroupSet = new Set<String>();

        Set<String> itemGroupSetTemp = new Set<String>();
        posmItemPhotoMap = new Map<String,String>();
        if(poLineList.size() > 0) {
            totalAmount = 0;
            Set<String> itemGroupCodes = new Set<String>();
            for (ASI_MFM_PO_Line_Item__c pl : poLineList) {
                if (pl.ASI_MFM_Item_Group_Code__c != null) {
                    itemGroupCodes.add(pl.ASI_MFM_Item_Group_Code__c);
                    itemGroupCode = pl.ASI_MFM_Item_Group_Code__c;
                }
                
                accCode = pl.ASI_MFM_A_C_Code__r.Name;
                if (pl.ASI_MFM_Delivery_Fee__c) {
                    totalAmount = totalAmount + pl.ASI_MFM_Amount__c;
                }

                if (pl.ASI_CTY_CN_Vendor_Sample_Fee__c) {
                    if (poLineSize == 1) {
                        itemGroupName = pl.ASI_MFM_List_Item_Description__c.split(':')[1].trim();
                    }
                    totalAmount = totalAmount + pl.ASI_MFM_Amount__c;
                }

                if (!pl.ASI_MFM_Delivery_Fee__c && !pl.ASI_CTY_CN_Vendor_Sample_Fee__c) {
                    itemGroupName = pl.ASI_MFM_List_Item_Description__c;
                    totalAmount = totalAmount + pl.ASI_MFM_Amount__c;
                }
            }

            List<ASI_MFM_Item_Group__c> itemGroupList = null;
            if (itemGroupCodes.size() > 0) {
                itemGroupList = [SELECT Id, Name, ASI_MFM_Item_Group_Code__c FROM ASI_MFM_Item_Group__c WHERE ASI_MFM_Item_Group_Code__c IN :itemGroupCodes AND RecordTypeId =: ASI_CTY_CN_Vendor_Util.itemGroupRecordId];

                if (itemGroupList == null || itemGroupList.size() == 0) {
                    itemGroupCodes.clear();
                    if (posmLineList != null && posmLineList.size() > 0) {
                        for(ASI_MFM_PO_POSM_Line__c posmLine :posmLineList){
                            if(posmLine.ASI_MFM_Item_Group_Code__c != null) {
                                itemGroupCodes.add(posmLine.ASI_MFM_Item_Group_Code__c);
                                itemGroupCode = posmLine.ASI_MFM_Item_Group_Code__c;
                            }
                        }
                        System.debug(LoggingLevel.INFO, '*** itemGroupCodes: ' + itemGroupCodes);
                        itemGroupList = [SELECT Id, Name, ASI_MFM_Item_Group_Code__c FROM ASI_MFM_Item_Group__c WHERE ASI_MFM_Item_Group_Code__c IN :itemGroupCodes AND RecordTypeId =: ASI_CTY_CN_Vendor_Util.itemGroupRecordId];
                        System.debug(LoggingLevel.INFO, '*** itemGroupList: ' + itemGroupList);
                    }
                }
                Set<Id> itemGroupIdSet = new Set<Id>();
                
                if (itemGroupList != null && itemGroupList.size() > 0) {
                    for(ASI_MFM_Item_Group__c ig :itemGroupList) {
                        itemGroupSetTemp.add(String.valueOf(ig.Id));
                        posmItemPhotoMap.put(ig.ASI_MFM_Item_Group_Code__c, '-1');
                        itemGroupIdSet.add(ig.Id);
                    }
                }
                
                if (itemGroupIdSet.size() > 0) {
                    for(ASI_CRM_Product_Warehouse_Photo__c photo: [SELECT ASI_CRM_Item_Group__c, ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c, ASI_Image_URL__c, ASI_MFM_Image_URL_720_480__c FROM ASI_CRM_Product_Warehouse_Photo__c 
                        WHERE ASI_CRM_Item_Group__c IN :itemGroupIdSet AND ASI_Image_URL__c != NULL AND ASI_MFM_Image_URL_720_480__c != NULL AND RecordTypeId =: ASI_CTY_CN_Vendor_Util.itemGroupPhotoRecordId]) {
                        posmItemPhotoMap.put(photo.ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c, photo.ASI_MFM_Image_URL_720_480__c);
                    }

                    if (!isPDF) {
                        String reocrdTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Final_Artwork_Photo');
                        List<ASI_CRM_Product_Warehouse_Photo__c> tmpAttachment = [SELECT Id, ASI_CRM_Photo_Version__c, CreatedDate FROM ASI_CRM_Product_Warehouse_Photo__c
                                                                                        WHERE ASI_CRM_Item_Group__c IN :itemGroupIdSet
                                                                                        AND RecordTypeId = : reocrdTypeId
                                                                                        ORDER BY CreatedDate DESC LIMIT 1];
                        Id warehousePhotoId;
                        if (tmpAttachment != null && tmpAttachment.size() > 0) {
                            warehousePhotoId = tmpAttachment[0].Id;
                            Id contentDocumentId;
                            set<String> documentIdSet = new set<String>();
                            ContentDocumentLink link = [SELECT Id, LinkedEntityId, ContentDocumentId
                               FROM ContentDocumentLink
                               WHERE LinkedEntityId =: warehousePhotoId LIMIT 1];
                            if (link != null) {
                                contentDocumentId = link.ContentDocumentId;
                                ContentVersion cv = [SELECT Id, ContentDocumentId, FileExtension, VersionData
                                    FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId =:contentDocumentId];
                                String contentTemp = EncodingUtil.base64Encode(cv.VersionData);
                                content = 'data:image/' + cv.FileExtension + ';base64,' + contentTemp;
                            }
                        }
                    }
                }

                System.debug(LoggingLevel.INFO, '*** itemGroupCode: ' + itemGroupCode);
                System.debug(LoggingLevel.INFO, '*** posmItemPhotoMap: ' + posmItemPhotoMap);
            }
        }

        System.debug(LoggingLevel.INFO, '*** posmLineList: ' + posmLineList);

        if(posmLineList != null && posmLineList.size() > 0) {
            
            posmLineMap = new Map<Id,ASI_MFM_PO_POSM_Line__c>();
            summaryMap = new Map<Id, PosmLineObj>();
            
            Set<Id> bundleItemIdSet = new Set<Id>();
            bundleItemLineMap = new Map<Id, List<ASI_MFM_Item_Group_Line__c>>();
            
            for(ASI_MFM_PO_POSM_Line__c posmLine :posmLineList){
                bundleItemLineMap.put(posmLine.ASI_MFM_Item_Group__c,new List<ASI_MFM_Item_Group_Line__c>());
                
                if(posmLine.ASI_MFM_Bundle_Item_Group__c) {
                    bundleItemIdSet.add(posmLine.ASI_MFM_Item_Group__c);
                }

                if(!itemGroupSet.contains(String.valueOf(posmLine.ASI_MFM_Item_Group__c))) {
                    itemGroupSet.add(String.valueOf(posmLine.ASI_MFM_Item_Group__c));
                    summaryMap.put(posmLine.ASI_MFM_Item_Group__c,new PosmLineObj(posmLine));
                    posmLineMap.put(posmLine.ASI_MFM_Item_Group__c,posmLine);
                } else {
                    summaryMap.get(posmLine.ASI_MFM_Item_Group__c).addSummay(posmLine);
                }
            }


            // SELECT Bundle Item line
            List<ASI_MFM_Item_Group_Line__c> componentItemList = [SELECT ASI_MFM_Item_Group__c, ASI_MFM_Chinese_Name__c , ASI_MFM_English_Name__c, ASI_MFM_Item_Group_Code__c, ASI_MFM_Unit_Quantity_in_Bundle__c
                                                                  FROM ASI_MFM_Item_Group_Line__c
                                                                  WHERE ASI_MFM_Item_Group__c IN :bundleItemIdSet];
            for(ASI_MFM_Item_Group_Line__c itemLine : componentItemList) {
                if(!bundleItemLineMap.containsKey(itemLine.ASI_MFM_Item_Group__c)) bundleItemLineMap.put(itemLine.ASI_MFM_Item_Group__c, new List<ASI_MFM_Item_Group_Line__c>());
                bundleItemLineMap.get(itemLine.ASI_MFM_Item_Group__c).add(itemLine);
            }

            domain=URL.getSalesforceBaseUrl().toExternalForm();
            
            if(posmLineList.size()>0) {
                poRemarkSubString = posmLineList[0].ASI_MFM_PO__r.ASI_MFM_Remarks__c;
                poRemarkSubString = poRemarkSubString.substring(0, Math.min(5, poRemarkSubString.length()));
            }
        }
        itemGroupSet.addAll(itemGroupSetTemp);
        if (itemGroupSet.size() == 0) {
            itemGroupSet.add('-1');
            itemGroupCode = '-1';
            posmItemPhotoMap.put(itemGroupCode, '-1');
            if (poLineList != null && poLineList.size() > 0) {
                itemGroupName = poLineList[0].ASI_MFM_List_Item_Description__c;
            } else {
                itemGroupName = po.ASI_MFM_Remarks__c;
            }
        }
        System.debug(LoggingLevel.INFO, '*** itemGroupLast: ' + itemGroupSet);
        System.debug(LoggingLevel.INFO, '*** itemGroupName: ' + itemGroupName);
        
        return true;
    }
    
    public class DeliveryObj {
        public String address {get;set;}
        public String city {get;set;}
        public String detailAddr {get;set;}
        public String person {get;set;}
        public String phone {get;set;}
        public Decimal qty {get;set;}
        
        public DeliveryObj(ASI_MFM_PO_POSM_Line__c posmLine) {
            address = (posmline.ASI_MFM_Delivery_Address_Outlet__r.name!=null)? posmline.ASI_MFM_Delivery_Address_Outlet__r.name:posmline.ASI_MFM_Delivery_Address_Warehouse__r.name;
            city = posmline.ASI_MFM_City__c;
            String temp = '';
            if (posmline.ASI_MFM_Detail_Address__c != null) {
                for(Integer i = 0 ; i < posmline.ASI_MFM_Detail_Address__c.length(); i++){                       
                    if (Math.Mod(i, 16) == 0 && i != 0) {
                        temp = temp + posmline.ASI_MFM_Detail_Address__c.Substring(i,i+1) + '\n';
                    } else {
                        temp = temp + posmline.ASI_MFM_Detail_Address__c.Substring(i,i+1);
                    }
                }
            }
            
            detailAddr = temp;
            person = posmline.ASI_MFM_Contact_Person__c;
            phone = posmline.ASI_MFM_Phone_Number__c;
            qty = posmline.ASI_MFM_Quantity__c;
        }
    }
    
    public class PosmLineObj {
        public Decimal count {get;set;}
        public Decimal qty {get;set;}
        public Decimal total {get;set;}
        public Decimal totalvat {get;set;}
        public Decimal unitPrice {get;set;}
        public List<DeliveryObj> delivery {get;set;}
        
        public PosmLineObj(ASI_MFM_PO_POSM_Line__c posmLine) {
            this.unitPrice = (posmLine.ASI_MFM_Unit_Price__c!=null)?posmLine.ASI_MFM_Unit_Price__c:0;
            this.qty = (posmLine.ASI_MFM_Quantity__c!=null)?posmLine.ASI_MFM_Quantity__c:0;
            this.total = (posmLine.ASI_MFM_Total_Price__c!=null)?posmLine.ASI_MFM_Total_Price__c:0;
            this.totalvat = (posmLine.ASI_MFM_Total_Price_w_VAT__c!=null)?posmLine.ASI_MFM_Total_Price_w_VAT__c:0;
            this.count = 1;
            this.delivery = new List<DeliveryObj>{new DeliveryObj(posmLine)};
        }
        
        public void addSummay(ASI_MFM_PO_POSM_Line__c posmLine){
            this.unitPrice += (posmLine.ASI_MFM_Unit_Price__c!=null)?posmLine.ASI_MFM_Unit_Price__c:0;
            this.qty += (posmLine.ASI_MFM_Quantity__c!=null)?posmLine.ASI_MFM_Quantity__c:0;
            this.total += (posmLine.ASI_MFM_Total_Price__c!=null)?posmLine.ASI_MFM_Total_Price__c:0;
            this.totalvat += (posmLine.ASI_MFM_Total_Price_w_VAT__c!=null)?posmLine.ASI_MFM_Total_Price_w_VAT__c:0;
            this.count++;
            this.delivery.add(new DeliveryObj(posmLine));
        }
    }
}