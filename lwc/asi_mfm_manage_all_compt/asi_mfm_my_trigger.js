//ASI MFM MY Payment Line Before Upsert checking
function ASI_MFM_MY_PaymentLine_BeforeUpsert(PaymentLineList) {
    console.log('ASI_MFM_MY_PaymentLine_BeforeUpsert');
    var checkingResult = { passValidation: true, Msg: '' };

    var InvoiceDateMap = {};
    var GLDateMap = {};
    var invoicedateError = false;
    var gldateError = false;

    //One Invoice No. can only have one Invoice Date
    //One Invoice No. can only have one GL Date
    PaymentLineList.forEach(function (line) {

        var invoiceDate = line.ASI_MFM_Invoice_Date__c.toString();

        var GLDstr = line.ASI_MFM_G_L_Date__c.toString();
        var invoicekey = line.ASI_MFM_Payee__c + line.ASI_MFM_Invoice_Number__c;
        console.log('invoicekey : '+invoicekey + ' GLDstr : '+GLDstr + ' invoiceDate : '+ invoiceDate);

        //Invoice Date checking
        if (InvoiceDateMap.hasOwnProperty(invoicekey)) {
            if (InvoiceDateMap[invoicekey] != invoiceDate) {
                invoicedateError = true;
            }
        } else {
            InvoiceDateMap[invoicekey] = invoiceDate;
        }

        //G/L Date checking
        if (GLDateMap.hasOwnProperty(invoicekey)) {
            if (GLDateMap[invoicekey] != GLDstr) {
                gldateError = true;
            }
        } else {
            GLDateMap[invoicekey] = GLDstr;
        }
    });


    if (invoicedateError) {
        checkingResult.passValidation = false;
        checkingResult.Msg += 'One Invoice No. can only have one Invoice Date.'
    }

    if (gldateError) {
        checkingResult.passValidation = false;
        checkingResult.Msg += 'One Invoice No. can only have one GL Date.'
    }

    return checkingResult;
}






//ASI MFM MY PO Line Before Upsert checking
function ASI_MY_POLine_BeforeUpsert(recordId,POlist, preReservedData) {

    var checkingResult = { passValidation: true, Msg: '' };
    var fxrate = preReservedData.header[0].ASI_MFM_Exchange_Rate__c != null ? preReservedData.header[0].ASI_MFM_Exchange_Rate__c : 1;
    var planAmount = preReservedData.plan[0].ASI_MFM_Plan_Amount__c != null ? preReservedData.plan[0].ASI_MFM_Plan_Amount__c : 0;

    var totalPOAmount = 0;
    //looping current PO Amount
    POlist.forEach(function (line) {
        totalPOAmount += Number(line.ASI_MFM_Amount__c) * Number(fxrate);
    });

    //looping other PO amount
    preReservedData.plan[0].POs__r.forEach(function (line) {
        if(line.Id != recordId){//console.log('enter looping other PO amount ' );
            totalPOAmount += Number(line.ASI_MFM_PO_Amount__c) * Number(line.ASI_MFM_Exchange_Rate__c);
        }
    });
    console.log('Plan & PO amount checking : totalPOAmount : '+totalPOAmount + ', planAmount : ' + planAmount);
    if (totalPOAmount > planAmount) {

        checkingResult.passValidation = false;
        checkingResult.Msg = 'Total PO amount exceeds the available plan balance.'
    }

    return checkingResult;
}


export { ASI_MFM_MY_PaymentLine_BeforeUpsert, ASI_MY_POLine_BeforeUpsert };