/**
 * Created by aliku on 9/21/2020.
 */

({
    doInit: function (component, event, helper) {
        component.set("v.columns", [
            {
                label: "Summary",
                fieldName: "Summary"
            },
            {
                label: "Assignee",
                fieldName: "Assignee"
            },
            {
                label: "Reporter",
                fieldName: "Reporter"
            },
            {
                label: "Issue Type",
                fieldName: "Issue Type"
            },
            {
                label: "Sprint",
                fieldName: "Sprint"
            }
        ])
    },
    onDataPartLoad: function (component, event, helper) {
        const loadEvent = event.getParams();
        const data = loadEvent.data;
        const errors = loadEvent.errors;
        //const successCount = loadEvent.successCount();
        //const failedCount = loadEvent.failedCount();
        //loadEvent.abort(); to abort processing
        //console.log(data);
        //console.log(errors);
        setTimeout(function () {
            //save record to db
            loadEvent.reportSuccess(data.length - errors.length);
            loadEvent.reportError(errors.length);
            loadEvent.resume();
        }, 1000)
    },
    onDataLoadComplete: function (component, event, helper) {
        const completeEvent = event.getParams();
        //const successCount = completeEvent.successCount();
        //const failedCount = completeEvent.failedCount();
        //completeEvent.reportSuccess(0);
        //completeEvent.reportError(0);
        // alert("file processed")
    }
});