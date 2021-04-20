import { LightningElement, api } from "lwc";
import sendToDrupalJs from "@salesforce/apex/MYPJ_LWCC07_SendEventToDrupal.sendToDrupal";

export default class mypj_LWC07_SendEventToDrupal extends LightningElement {
  @api recordId;
  returnValue;
  spinnerClass = "slds-hide";

  sendToDrupal() {
    this.spinnerClass = "";
    sendToDrupalJs({ recordId: this.recordId })
      .then((result) => {
        this.returnValue = result;
        this.spinnerClass = "slds-hide";
      })
      .catch((error) => {
        // this.returnValue = error;
        this.returnValue = { isError: true, message: error.body.message };
        // this.returnValue.isError = true;
        // this.returnValue.message = error.body.message;
        this.spinnerClass = "slds-hide";
      });
  }

  get isError() {
    return this.returnValue.isError === true;
  }
}