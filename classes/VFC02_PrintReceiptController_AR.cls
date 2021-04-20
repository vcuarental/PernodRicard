/********************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck

* Nombre del pagina: VFC02_PrintReceipt_AR
* Descripcion: controlador de la pagina VFC02_PrintReceipt_AR.
* Fecha: 09/04/2013
*********************************************************************/

public with sharing class VFC02_PrintReceiptController_AR {


    public RCP_Receipt_ARG__c receipt {get;set;}
    public RCP_Receipt_ARG__c recibo {get;set;}
    public Account acc {get;set;}
    public List<DCM_Documents_ARG__c> listDocs {get;set;}
    public Decimal SubTotalImputar {get;set;}

    public Decimal TotalImputar {get;set;}
    public List<VLS_Values_ARG__c> listVals {get;set;}
    public List<DPT_Deposit_ARG__c> listDeps {get;set;}
    public List<DBT_Debit_ARG__c> listDebits {get;set;}
    public List<String> listValueType {get;set;}
    public Map<String, Decimal> mapValueTypeAmount{get;set;}

    public Decimal TotalValues {get;set;}
    public Decimal TotalDep {get;set;}
    public List<TXC_TaxCertificates_ARG__c> listTax {get;set;}
    public Decimal TotalReten {get;set;}
    public String day {get;set;}
    public String month {get;set;}

    public String year {get;set;}
    public List<String> listRef {get;set;}
    public String pageHeight {get;set;}

    private Map<String,String> translatedValueTypes = new Map<String,String>();
    private Map<String,String> translatedRetenTypes = new Map<String,String>();


    public class wrapType{
        public String Type {get;set;}
        public Decimal Value {get;set;}

        public wrapType(String typeC, Decimal ValueC){
            this.Type = typeC;
            this.Value = ValueC;
        }
    }

    public class wrapTypeTraduccion{
        public String TypeEnglish {get;set;}
        public String TypeTraduccion {get;set;}

        public wrapTypeTraduccion(String TypeEnglishC, String TypeTraduccionC){
            this.TypeEnglish = TypeEnglishC;
            this.TypeTraduccion = TypeTraduccionC;
        }
    }


    public List<wrapType> listTypeValue {get;set;}
    public Map<String,wrapTypeTraduccion> mapTypeTraduccionReten  {get;set;}
    public Map<String,wrapTypeTraduccion> mapTypeTraduccionValues {get;set;}

    public Boolean ShowReferenciasReten  {get;set;}
    public Boolean ShowReferenciasValues  {get;set;}


    public VFC02_PrintReceiptController_AR(){


        //translate value types to user language
        Schema.DescribeFieldResult valueTypeDescribe = VLS_Values_ARG__c.ValueType_AR__c.getDescribe();

        for(Schema.Picklistentry pickEntry : valueTypeDescribe.getPicklistValues()){
            translatedValueTypes.put(pickEntry.value, pickEntry.label); //.substring(10)
        }

        Schema.DescribeFieldResult retenTypeDescribe = TXC_TaxCertificates_ARG__c.ValueType_AR__c.getDescribe();

        for(Schema.Picklistentry pickEntry : retenTypeDescribe.getPicklistValues()){
            translatedRetenTypes.put(pickEntry.value, pickEntry.label); //.substring(10)
        }


        Double pageHeightValue;
        Integer lines = 0;

        pageHeightValue = 400;

        String Idreceipt = Apexpages.currentPage().getParameters().get('IdRec');

        recibo = [SELECT Id,RecordTypeId, Account_AR__c, Date_AR__c ,Name , CollectionAgent_AR__c, AN8_AR__c, Downpayments_AR__c, Discount_AR__c, Comercial_Discount__c, Debit_AR__c FROM RCP_Receipt_ARG__c WHERE Id=: Idreceipt];
        if(recibo.date_AR__c != NULL){

            if(recibo.Date_AR__c.day()<10){
                day = '0' + string.valueof(recibo.Date_AR__c.day());
            }else{
                day = string.valueof(recibo.Date_AR__c.day());
            }

            if(recibo.Date_AR__c.month()<10){
                month = '0' + string.valueof(recibo.Date_AR__c.month());
            }else{
                month = string.valueof(recibo.Date_AR__c.month());

            }
            year = string.valueof(recibo.Date_AR__c.year());
        }

        acc = [SELECT Id, Name,CNPJ__c,Corporate_Name__c FROM Account WHERE Id =: recibo.Account_AR__c];

        if(recibo.RecordTypeId == Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'LAT_AR_RCP_ReceiptOfApplyingDocuments')){
            listdocs = new list<DCM_Documents_ARG__c>([SELECT Id, tipoDocumento_AR__c,LegalInvoice_AR__c, Name, Amounttoapply_AR__c FROM DCM_Documents_ARG__c WHERE ReceiptNo_AR__c =: Idreceipt]);
        }else{
            listdocs = new list<DCM_Documents_ARG__c>([SELECT Id, tipoDocumento_AR__c,LegalInvoice_AR__c, Name, Amounttoapply_AR__c FROM DCM_Documents_ARG__c WHERE ReceiptNo_AR__c =: Idreceipt AND tipoDocumento_AR__c != 'RU']);
        }


        SubTotalImputar = 0;

        if(!listdocs.isEmpty()){
            pageHeightValue = pageHeightValue + 150;
            for(DCM_Documents_ARG__c doc: listdocs){
                lines = lines + 1;

                if(doc.Amounttoapply_AR__c != NULL){
                    SubTotalImputar = SubTotalImputar + doc.Amounttoapply_AR__c;
                }
            }
        }else{
            pageHeightValue = pageHeightValue + 40;
        }

        TotalImputar = SubTotalImputar;

        if(recibo.Downpayments_AR__c == NULL) {
            recibo.Downpayments_AR__c = 0; 
        }
        if(recibo.Discount_AR__c == NULL) {
            recibo.Discount_AR__c = 0;
        }

        if(recibo.Comercial_Discount__c == NULL) {
            recibo.Comercial_Discount__c = 0;
        }
        TotalImputar = TotalImputar + recibo.Downpayments_AR__c - recibo.Discount_AR__c - recibo.Debit_AR__c - recibo.Comercial_Discount__c;
        //listVals = new list<VLS_Values_ARG__c>([SELECT Id, ValueType_AR__c, Name, Amount_AR__c FROM VLS_Values_ARG__c WHERE ReceiptNo_AR__c =: Idreceipt]);

        listVals = new List<VLS_Values_ARG__c>();
        listDeps = new List<DPT_Deposit_ARG__c>();
        listVals = [SELECT Id, ValueType_AR__c, Name, Amount_AR__c FROM VLS_Values_ARG__c WHERE ReceiptNo_AR__c =: Idreceipt];
        listDeps = [SELECT Id, Name, Amount_AR__c, Bank_AR__c FROM DPT_Deposit_ARG__c WHERE ReceiptNo_AR__c =: Idreceipt];
        listDebits = [SELECT Id, Name, DebitAmount_AR__c, DebitNo_AR__c FROM DBT_Debit_ARG__c WHERE ReceiptNo_AR__c =: Idreceipt];

        if(!listDebits.isEmpty()){
            pageHeightValue = pageHeightValue + 30;
            for(DBT_Debit_ARG__c deb: listDebits){
                lines = lines + 1;
            }
        }else{
            pageHeightValue = pageHeightValue + 30;
        }


        Decimal SumAmount;
        TotalValues = 0;
        TotalDep = 0;
        mapValueTypeAmount = new Map<String,Decimal>();
        listValueType = new List<String>();

        mapTypeTraduccionValues = new Map<String,wrapTypeTraduccion>();
        ShowReferenciasValues = false;

        if(!listVals.isEmpty()){

            pageHeightValue = pageHeightValue + 80;
            for(VLS_Values_ARG__c val: listVals){
                lines = lines + 1;
                if(val.ValueType_AR__c != NULL){

                    ShowReferenciasValues = true;

                    wrapTypeTraduccion typetrad = new wrapTypeTraduccion(val.ValueType_AR__c.left(1),translatedValueTypes.get(val.ValueType_AR__c));
                    mapTypeTraduccionValues.put(val.ValueType_AR__c, typetrad);

                    val.ValueType_AR__c = val.ValueType_AR__c.left(1);

                }
                if(val.ValueType_AR__c != NULL && val.Amount_AR__c != NULL){
                    if(mapValueTypeAmount.containsKey(val.ValueType_AR__c)){

                        SumAmount = mapValueTypeAmount.get(val.ValueType_AR__c) + val.Amount_AR__c;
                        mapValueTypeAmount.put(val.ValueType_AR__c, SumAmount);
                    }else{
                        listValueType.add(val.ValueType_AR__c);

                        mapValueTypeAmount.put(val.ValueType_AR__c, val.Amount_AR__c);
                    }
                }
                if(val.Amount_AR__c != NULL){
                    TotalValues = TotalValues + val.Amount_AR__c;
                }
            }
            listTypeValue = new list<wrapType>();

            if(!mapValueTypeAmount.IsEmpty()){
                for(String tipo1 : mapValueTypeAmount.keyset()){

                    listTypeValue.add(new wrapType(tipo1, mapValueTypeAmount.get(tipo1)));
                }
            }

        }

        //Deposit Sections
        if(!listDeps.isEmpty()){
            pageHeightValue = pageHeightValue + 40;

            for(DPT_Deposit_ARG__c dep: listDeps){
                lines = lines + 1;

                if(dep.Amount_AR__c != NULL){
                    TotalDep = TotalDep + dep.Amount_AR__c;
                }
            }
        }



        listTax = [SELECT Id, ValueType_AR__c, Amount_AR__c FROM TXC_TaxCertificates_ARG__c WHERE ReceiptNo_AR__c =: Idreceipt];

        mapTypeTraduccionReten = new map<String, wrapTypeTraduccion>();
        ShowReferenciasReten = false;

        TotalReten = 0;
        if(!listTax.IsEmpty()){
            pageHeightValue = pageHeightValue + 40;
            for(TXC_TaxCertificates_ARG__c tax: listTax){
                lines = lines + 1;
                if(tax.ValueType_AR__c != NULL){
                    ShowReferenciasReten = true;

                    wrapTypeTraduccion typetrad2 = new wrapTypeTraduccion(tax.ValueType_AR__c.left(2),translatedRetenTypes.get(tax.ValueType_AR__c));
                    mapTypeTraduccionReten.put(tax.ValueType_AR__c, typetrad2);

                    tax.ValueType_AR__c = tax.ValueType_AR__c.left(2);
                }
                TotalReten = TotalReten + tax.Amount_AR__c;

            }
        }

        listRef = new list<String>();
        listRef.add('Original para el Cliente');
        listRef.add('Duplicado para Cred. y Cobr.');
        //listRef.add('Triplicado para el Cobrador');


        pageHeightValue = pageHeightValue + (lines * 8) + ( (mapTypeTraduccionReten.size()+3) * 10 ) + ( (mapTypeTraduccionValues.size() * 10+3) );
        pageHeightValue *=2;
        pageHeight = String.valueOf(pageHeightValue);

    }
}