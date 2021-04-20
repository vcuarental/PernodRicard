/****************************************************
*Dev: Denis Aranda  Version: 1  Consulting: Valuenet*
*  Descripción: Boton en Recibo que deja al usuario *
*  ARG_Tesorería y AR_Creditos_y_Cobranzas crear un *
*     texto para JDE con informacion del recibo     *
****************************************************/

global with sharing class BTN10_TXT_TO_JDE_AR {

	webService static String Verify(){
		return 'ok';
	}	
    
    public static map<String, Integer> mapFieldSize = new map<String, Integer>{'AN8_AR__c'=>8,'deb.DebitNoteType_AR__c'=>1, 'deb.Serial_AR__c'=>4, 'recibo.Name7'=>7, 'recibo.Name10'=>10, 'Bank_AR__c'=>3, 'BranBranch_AR__c'=>3, 'name_8'=>8, 'Amount_AR__c'=>14, 'IssueDate_AR_c__c'=>10, 'DueDate_AR__c'=>10, 'LegalInvoice_AR__c'=>2, 'LegalInvoice_AR__c1'=>13, 'Amounttoapply_AR__c'=>14, 'dataVencimentoAtual_AR__c'=>10, 'tipoDocumento_AR__c'=>3, 'tax.Name'=>8, 'ValueType_AR__c'=>2, 'espacioEnBlanco10'=>10, 'espacioEnBlanco3'=>3, 'Downpayments_AR__c'=>14, 'Discount_AR__c'=>14, 'Debit_AR__c'=>14, 'Depositos.Name'=>7};
    public static map<String, String> mapLegalInvoiceNo = new map<String, String>{'01'=>'FC', '06'=> 'FC', '02'=> 'ND', '07'=> 'ND', '03'=> 'NC', '08'=> 'NC'};
    public static list<DCM_Documents_ARG__c> docToUpdate = new list<DCM_Documents_ARG__c>();
    public static list<VLS_Values_ARG__c> valuesToUpdate = new list<VLS_Values_ARG__c>();
    public static list<TXC_TaxCertificates_ARG__c> taxToUpdate = new list<TXC_TaxCertificates_ARG__c>();
    
    webService static String txtToJdeButton(list<id> idsRegister){
    	
        String idContact = UserInfo.getProfileId();
        Profile profileUser = [SELECT id, Name FROM Profile WHERE id =: idContact];
        string profileUserName = profileUser.Name;
        
        system.debug('Token Profile : ' + profileUserName);
        
        if(profileUserName != 'ARG_Tesorería' && profileUserName != 'LAT_AR2_Tesoreria' && profileUserName != 'AR_Creditos_y_Cobranzas' && profileUserName != 'LAT_SystemAdministrator' && profileUserName != 'Administrador del sistema' && profileUserName != 'Administrador do sistema'){
        	return Label.BTN10_00007_AR;
        }
        
        Integer numberOfIdsSelected = idsRegister.size();
        if (numberOfIdsSelected < 1){
            return Label.BTN10_00001_AR;
        }

        list<RCP_Receipt_ARG__c> recibos = [SELECT Id, Name, RedemptionDateTime_AR__c, Debit_AR__c, AN8_AR__c, RedemptionNo_AR__c, Status_AR__c, Downpayments_AR__c, Discount_AR__c,
                                           (SELECT Id, Name, AN8_AR__c, LegalInvoice_AR__c, Amounttoapply_AR__c, dataVencimentoAtual_AR__c, tipoDocumento_AR__c, AplicationsTXTissued_AR__c
                                            FROM Documents__r),
                                           (SELECT Id, Name, Bank_AR__c, BranBranch_AR__c, Amount_AR__c, IssueDate_AR_c__c, DueDate_AR__c, Deposit_AR__r.AccType_AR__c, Deposit_AR__r.Name, ValueTXTissued_AR__c
                                            FROM Values__r),
                                           (SELECT Id, Name, AccType_AR__c
                                            FROM Deposits__r),
                                           (SELECT Id, Name, ValueType_AR__c, Amount_AR__c
                                            FROM Tax_Certificates__r),
                                           (SELECT Id, Name, ReceiptNo_AR__c, ReceiptNo_AR__r.Name, DebitNoteType_AR__c, Serial_AR__c, DebitNo_AR__c, DebitAmount_AR__c
                                            FROM Debits__r)
                                            FROM RCP_Receipt_ARG__c WHERE Id =: idsRegister];
        
        //Verifico que todos esten verificados
        for(RCP_Receipt_ARG__c rec: recibos){
            if(rec.Status_AR__c != 'Receipt Verified'){
                return Label.BTN10_00003_AR;
            }
        }
        
        String myTxtValores = '';
        String myTxtAplicaciones = '';
        
        for(RCP_Receipt_ARG__c rec: recibos){
            //Codigo aplica para Valores
            myTxtValores += generateLineValues(rec);
            //Codigo aplica para Aplicaciones 3.a Documentos aplicados
            myTxtAplicaciones += generateLineDocAplicados(rec);
            //Codigo aplica para Aplicaciones 3.b Retenciones
            myTxtAplicaciones += generateLineRetenciones(rec);
            //Codigo aplica para Aplicaciones 3.c Pagos a cuentas
            myTxtAplicaciones += generateLinePagoACuentas(rec);
            //Codigo aplica para Aplicaciones 3.d Desc Financieros
            myTxtAplicaciones += generateLineDescFinancieros(rec);
            //Codigo aplica para Aplicaciones 3.e Debitos
            myTxtAplicaciones += generateLineDebitos(rec);
            rec.Status_AR__c = 'Receipt With TXT';
        }
        
        if(myTxtValores!='' || myTxtAplicaciones!=''){
            
            List<Document> documentos = new List<Document>();
            Folder folder = [SELECT id, Name FROM Folder WHERE DeveloperName='Receipts_With_TXT_AR' limit 1];
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            Document docValores = new Document();
            if(myTxtValores!=''){
                docValores.Body = Blob.ValueOf(myTxtValores);
                docValores.FolderId = folder.Id;
                docValores.Name = 'TXT Values '+Datetime.now();
                docValores.Type = 'txt';
                docValores.contentType = 'application/octet';
                documentos.add(docValores);
                //Genero el attached para el mail
                Messaging.EmailFileAttachment txtvals = new Messaging.EmailFileAttachment();
                txtvals.setFileName('TXT Values '+Datetime.now());
                txtvals.setContentType('text/plain');
                txtvals.setBody(Blob.ValueOf(myTxtValores));
                attachments.add(txtvals);
            }
            Document docAplicaciones = new Document();
            if(myTxtAplicaciones!=''){
                docAplicaciones.Body = Blob.ValueOf(myTxtAplicaciones);
                docAplicaciones.FolderId = folder.Id;
                docAplicaciones.Name = 'TXT Aplicaciones '+Datetime.now();
                docAplicaciones.Type = 'txt';
                docAplicaciones.contentType = 'application/octet';
                documentos.add(docAplicaciones);
                //Genero el attached para el mail
                Messaging.EmailFileAttachment txtapps = new Messaging.EmailFileAttachment();
                txtapps.setFileName('TXT Aplicaciones '+Datetime.now());
                txtapps.setContentType('text/plain');
                txtapps.setBody(Blob.ValueOf(myTxtAplicaciones));
                attachments.add(txtapps);
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {UserInfo.getUserEmail()};
            mail.setToAddresses(toAddresses);
            mail.setSubject(Label.BTN10_00005_AR);
            String cuerpoDeMail ='';
            mail.setHTMLBody(cuerpoDeMail);
            mail.setFileAttachments(attachments);
            
            Savepoint sp = Database.setSavepoint();
            try{
                insert documentos;
                for(RCP_Receipt_ARG__c rec: recibos){
                    rec.Id_TXT_Values_Document_AR__c = docValores.Id;
                    rec.Id_TXT_Aplications_Document_AR__c = docAplicaciones.Id;
                }
                update recibos;
                update docToUpdate;
                update valuesToUpdate;
                update taxToUpdate;
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }catch(Exception e){Database.rollback(sp); return 'Error: '+e.getMessage();}
        
        }else{
            return Label.BTN10_00006_AR;
        }
        
        return Label.BTN10_00002_AR;
    }
    
    public static String generateLineValues(RCP_Receipt_ARG__c rec){
        String lineaValores = '';
        for(VLS_Values_ARG__c val: rec.Values__r){
            //TXT VALORES de Objetos donde Depositos/AccType_AR__c´=Collection Bank Account
            if(val.Deposit_AR__r.AccType_AR__c != 'Collection Bank Account'){
                lineaValores += getRestOfBlankStr(val.Deposit_AR__r.Name, 'Depositos.Name');
                lineaValores += getRestOfBlankStr(rec.AN8_AR__c, 'AN8_AR__c');
                lineaValores += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'recibo.Name10');
                lineaValores += getRestOfBlankStr(val.Bank_AR__c, 'Bank_AR__c');
                lineaValores += getRestOfBlankStr(val.BranBranch_AR__c, 'BranBranch_AR__c');
                lineaValores += 'DB';
                lineaValores += getRestOfBlankStr(val.Name, 'name_8');
                lineaValores += '048';
                lineaValores += getRestOfBlankStr(val.Amount_AR__c, 'Amount_AR__c');
                lineaValores += getRestOfBlankStr(val.IssueDate_AR_c__c, 'IssueDate_AR_c__c');
                lineaValores += getRestOfBlankStr(val.DueDate_AR__c, 'DueDate_AR__c');
                lineaValores += '\r\n';
                val.ValueTXTissued_AR__c = true;
                valuesToUpdate.add(val);
            }
        }
        return lineaValores;
    }
    
    public static String generateLineDocAplicados(RCP_Receipt_ARG__c rec){
        String lineaAplicaciones = '';
        for(DCM_Documents_ARG__c doc: rec.Documents__r){
            //3.a) Documentos aplicados (todos los registros de objeto Documentos, excepto los RU ('tipoDocumento_AR__c'=RU)
            if(doc.tipoDocumento_AR__c != 'RU'){
                string LegalInvoiceNo = (doc.LegalInvoice_AR__c!=null) ? doc.LegalInvoice_AR__c.substring(0,2):'';
                lineaAplicaciones += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'recibo.Name7');
                lineaAplicaciones += getRestOfBlankStr(rec.AN8_AR__c, 'AN8_AR__c');
                lineaAplicaciones += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'recibo.Name10');
                lineaAplicaciones += doc.LegalInvoice_AR__c==null?getBlankStr('LegalInvoice_AR__c'):(mapLegalInvoiceNo.get(LegalInvoiceNo)==null?getBlankStr('LegalInvoice_AR__c'):mapLegalInvoiceNo.get(LegalInvoiceNo));
                
                if(doc.LegalInvoice_AR__c==null){
                    lineaAplicaciones += getBlankStr('LegalInvoice_AR__c1');
                }else{
                    Integer len = doc.LegalInvoice_AR__c.length();
                    if(len<15){
                        lineaAplicaciones += getRestOfBlankStr((doc.LegalInvoice_AR__c.substring(2,len)), 'LegalInvoice_AR__c1');
                    }else{
                        lineaAplicaciones += doc.LegalInvoice_AR__c.substring(2,15);
                    }
                }
                
                lineaAplicaciones += getRestOfBlankStr(doc.Amounttoapply_AR__c, 'Amounttoapply_AR__c');
                lineaAplicaciones += doc.tipoDocumento_AR__c == 'FA'?(getRestOfBlankStr(doc.dataVencimentoAtual_AR__c, 'dataVencimentoAtual_AR__c')):getBlankStr('dataVencimentoAtual_AR__c');
                lineaAplicaciones += doc.tipoDocumento_AR__c == 'FA'?(getRestOfBlankStr(doc.tipoDocumento_AR__c, 'tipoDocumento_AR__c')):getBlankStr('tipoDocumento_AR__c');
                lineaAplicaciones += '\r\n';
                doc.AplicationsTXTissued_AR__c = true;
                docToUpdate.add(doc);
            }
        }
        return lineaAplicaciones;
    }
    
    public static String generateLineRetenciones(RCP_Receipt_ARG__c rec){
        String lineaAplicaciones3b = '';
        for(TXC_TaxCertificates_ARG__c tax :rec.Tax_Certificates__r){
            //3.b) Retenciones
            lineaAplicaciones3b += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'recibo.Name7');
            lineaAplicaciones3b += getRestOfBlankStr(rec.AN8_AR__c, 'AN8_AR__c');
            lineaAplicaciones3b += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'recibo.Name10');
            lineaAplicaciones3b += getRestOfBlankStr(tax.ValueType_AR__c, 'ValueType_AR__c');
            lineaAplicaciones3b += 'A';
            lineaAplicaciones3b += '0000';
            lineaAplicaciones3b += getRestOfBlankStr(tax.Name, 'tax.Name');
            lineaAplicaciones3b += getRestOfBlankStr(tax.Amount_AR__c, 'Amount_AR__c');
            lineaAplicaciones3b += getBlankStr('espacioEnBlanco10');
            lineaAplicaciones3b += getBlankStr('espacioEnBlanco3');
            lineaAplicaciones3b += '\r\n';
            tax.AplicationsTXTissued_AR__c = true;
            taxToUpdate.add(tax);
        }
        return lineaAplicaciones3b;
    }
    
    public static String generateLinePagoACuentas(RCP_Receipt_ARG__c rec){
        String lineaAplicaciones3c = '';
        //3.c) Pagos a Cuenta: Si Downpayments_AR__c <> 0 en Recibos, entonces generar en TXT Aplicaciones una linea con documento AN (Anticipo) con nro. de documento  = Recibo
        if(rec.Downpayments_AR__c != 0 && rec.Downpayments_AR__c != null){//check
            lineaAplicaciones3c += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'recibo.Name7');
            lineaAplicaciones3c += getRestOfBlankStr(rec.AN8_AR__c, 'AN8_AR__c');
            lineaAplicaciones3c += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'recibo.Name10');
            lineaAplicaciones3c += 'AN';
            lineaAplicaciones3c += 'A';
            lineaAplicaciones3c += '0000';
            lineaAplicaciones3c += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'name_8');
            lineaAplicaciones3c += rec.Downpayments_AR__c!=null?getRestOfBlankStr((rec.Downpayments_AR__c<0)?(rec.Downpayments_AR__c*(-1)):rec.Downpayments_AR__c, 'Downpayments_AR__c'):getBlankStr('Downpayments_AR__c');
            lineaAplicaciones3c += getBlankStr('espacioEnBlanco10');
            lineaAplicaciones3c += getBlankStr('espacioEnBlanco3');
            lineaAplicaciones3c += '\r\n';
        }
        return lineaAplicaciones3c;
    }
    
    public static String generateLineDescFinancieros(RCP_Receipt_ARG__c rec){
        String lineaAplicaciones3d = '';
        
        //3.d) Descuento Financiero: Si Discount_AR__c <> en Recibos, entonces generar en TXT Aplicaciones con documento DF (Debito Financiero) con nro. de documento = Recibo
        if(rec.Discount_AR__c != 0 && rec.Discount_AR__c != null){
            lineaAplicaciones3d += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'recibo.Name7');
            lineaAplicaciones3d += getRestOfBlankStr(rec.AN8_AR__c, 'AN8_AR__c');
            lineaAplicaciones3d += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'recibo.Name10');
            lineaAplicaciones3d += 'DF';
            lineaAplicaciones3d += 'A';
            lineaAplicaciones3d += '0000';
            lineaAplicaciones3d += getRestOfBlankStr(Integer.ValueOf(rec.Name), 'name_8');
            lineaAplicaciones3d += rec.Discount_AR__c!=null?getRestOfBlankStr((rec.Discount_AR__c>0)?(rec.Discount_AR__c*(-1)):rec.Discount_AR__c, 'Discount_AR__c'):getBlankStr('Discount_AR__c');
            lineaAplicaciones3d += getBlankStr('espacioEnBlanco10');
            lineaAplicaciones3d += getBlankStr('espacioEnBlanco3');
            lineaAplicaciones3d += '\r\n';

        }
        return lineaAplicaciones3d;
    }
    
    public static String generateLineDebitos(RCP_Receipt_ARG__c rec){
        String lineaAplicaciones3e = '';
        
        //3.e) Debitos: Si Debit_AR__c <> 0 en Recibos, entonces generar en TXT Aplicaciones con documento DD (Debito) con nro de documento = Recibo
        for(DBT_Debit_ARG__c deb: rec.Debits__r){
		    if(rec.Debit_AR__c != 0 && rec.Debit_AR__c != null){  
		        lineaAplicaciones3e += getRestOfBlankStr(Integer.ValueOf(deb.ReceiptNo_AR__r.Name), 'recibo.Name7');
		        lineaAplicaciones3e += getRestOfBlankStr(rec.AN8_AR__c, 'AN8_AR__c');
		        lineaAplicaciones3e += getRestOfBlankStr(Integer.ValueOf(deb.ReceiptNo_AR__r.Name), 'recibo.Name10');
		        lineaAplicaciones3e += 'ND';
		        lineaAplicaciones3e += getRestOfBlankStr(deb.DebitNoteType_AR__c, 'deb.DebitNoteType_AR__c');
		        lineaAplicaciones3e += getRestOfBlankStr(deb.Serial_AR__c, 'deb.Serial_AR__c');
		        lineaAplicaciones3e += getRestOfBlankStr(deb.DebitNo_AR__c, 'name_8');
		        lineaAplicaciones3e += deb.DebitAmount_AR__c!=null?getRestOfBlankStr((deb.DebitAmount_AR__c>0)?(deb.DebitAmount_AR__c*(-1)):deb.DebitAmount_AR__c, 'Debit_AR__c'):getBlankStr('Debit_AR__c');
		        lineaAplicaciones3e += getBlankStr('espacioEnBlanco10');
		        lineaAplicaciones3e += getBlankStr('espacioEnBlanco3');
		        lineaAplicaciones3e += '\r\n';
		    
		    }
        }
        return lineaAplicaciones3e;
    }
    
    public static string getRestOfBlankStr(String Value, String field){
        if(value!=null){
            String strReturn = value;
            for(Integer i=value.length(); i<mapFieldSize.get(field); i++){strReturn += ' ';}
            return strReturn;
        }
        return getBlankStr(field);
    }
    public static string getRestOfBlankStr(Decimal Value, String field){
        if(value!=null){
            Boolean isNeg=false;
            if(value<0){isNeg=true;}
            String strReturn = String.ValueOf(Math.abs(value)).replace('.','');
            Integer len = strReturn.length();
            for(Integer i=len; i<(isNeg?mapFieldSize.get(field)-1:mapFieldSize.get(field)); i++){strReturn='0'+strReturn;}
            if(isNeg){strReturn = '-'+strReturn;}
            return strReturn;
        }
        return getBlankStr(field);
    }
    public static string getRestOfBlankStr(Date value, String field){
        if(value!=null){
            String strReturn = value.day()<10?'0'+string.valueOf(value.day()):string.valueOf(value.day());
                   strReturn +='/';
                   strReturn += value.month()<10?'0'+value.month():string.valueOf(value.month());
                   strReturn +='/';
                   strReturn += string.valueOf(value.year());
            for(Integer i=string.valueOf(value).length(); i<mapFieldSize.get(field); i++){strReturn += ' ';}
            return strReturn;
        }
        return getBlankStr(field);
    }
    public static string getBlankStr(String field){
        String strReturn = '';
        for(Integer i=0; i<mapFieldSize.get(field); i++){strReturn += ' ';}
        return strReturn;
    }
    /*TEST CODE IN BTN10_TXT_TO_JDE_Arg_Test CLASS*/
}